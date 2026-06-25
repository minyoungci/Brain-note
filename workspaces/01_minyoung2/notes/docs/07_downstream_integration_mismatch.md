# 07. Foundation model ↔ downstream task 불일치와 해결 전략

> 목적: `ResEnc + S3D-style dense + InfoNCE-global` foundation checkpoint를 FOMO26 downstream 7-task 제출 파이프라인에 연결할 때, 무엇이 맞지 않았고 어떻게 해결하는지 단일 문서로 고정한다. 결론부터 말하면 **foundation checkpoint 자체는 수정하지 않는다.** 불일치는 downstream 전처리, 입력 어댑터, task head, 출력 복원, 컨테이너 계약에서 흡수한다.

## 0. 현재 확정값

- 단일 foundation checkpoint: `experiments/phase_b/resenc_s3d_wg0.5/latest.pt`
- 모델 구조: 1-channel `ResEnc-L` backbone + S3D-style dense decoder + SimPool global vector + InfoNCE projection head
- pretrain 입력 분포:
  - Yucca 4-step: `crop_to_nonzero -> volume_wise_znorm/rescale[0,1] -> RAS -> 1mm isotropic`
  - 저장 후 학습 시 96^3 random crop + crop-wise z-normalization
- 제출 방향:
  - Asparagus 런타임 미채택
  - custom downstream/inference/container pipeline
  - Asparagus는 recipe와 입출력 참고용

## 1. 불일치 1: 공식 Asparagus 모델 구조와 우리 foundation 구조가 다름

### 문제

처음에는 공식 baseline이 ResEnc U-Net이므로 우리 ResEnc checkpoint를 Asparagus `resenc_unet_b`에 쉽게 올릴 수 있을 것으로 봤다. 실제 조사 결과, 이 가정은 틀렸다.

우리 모델:

```text
ResEnc-L
channels = (32, 64, 128, 256, 320)
blocks   = (1, 2, 2, 2, 2)
activation = GELU
downsample = stride-2 conv inside ResBlock
```

Asparagus baseline:

```text
resenc_unet_b 계열
stage/block 수와 activation/downsample 방식이 다름
```

따라서 Asparagus model에 우리 checkpoint를 drop-in load할 수 없다. 더 위험한 경우는 일부 stem/encoder 키만 조용히 로드되고 나머지는 random-init으로 남는 "거짓 성공"이다.

### 해결

Asparagus model에 맞추려고 foundation을 바꾸지 않는다. 대신 우리 코드의 `build_models("resenc_s3d")`로 동일 구조를 재구성하고, checkpoint를 직접 로드한다.

현재 구현 원칙:

```python
model.load_state_dict(sd["student"], strict=False)
assert not missing
assert not unexpected
```

즉, 부분 로드를 허용하지 않는다. missing/unexpected key가 하나라도 있으면 실패시켜야 한다.

관련 코드:

- `downstream/core.py::load_backbone`
- `pretrain/models.py::ResEncUNet`
- `pretrain/models.py::SSLModel`

## 2. 불일치 2: downstream raw NIfTI가 pretrain 입력 분포와 다름

### 문제

foundation은 raw scanner volume을 직접 본 적이 없다. pretrain corpus는 이미 Yucca 4-step을 거친 `.npy`였다.

반면 downstream 데이터는 task마다 다음이 다르다.

- raw intensity range가 제각각
- skull/background 상태가 제각각
- spacing이 0.4mm급부터 5.6mm slice thickness까지 다양
- orientation/shape가 task마다 다름
- Task1/2는 매우 비등방적인 2D-stack 성격
- Task4/5는 큰 3D volume

이 상태로 모델에 바로 넣으면 pretrained representation이 기대한 분포와 달라진다.

### 해결

컨테이너 내부에서 pretrain과 같은 Yucca 4-step을 적용한다.

공통 전처리:

```text
raw nii.gz
-> crop_to_nonzero
-> volume_wise_znorm/rescale[0,1]
-> RAS
-> 1mm isotropic
-> model input
```

중요한 정정:

```text
pretrain은 별도 skull-strip이 아니다.
SynthStrip/HD-BET 같은 skull stripping을 한 것이 아니라 Yucca crop_to_nonzero를 사용했다.
```

따라서 downstream에서도 skull-strip을 새로 추가하는 것이 아니라 Yucca 4-step을 복제하는 것이 정합적이다.

관련 코드:

- `preprocessing/preprocess_fomo300k.py::PREPROCESS_CONFIG`
- `downstream/core.py::YUCCA_CFG`
- `downstream/core.py::yucca_pp`

## 3. 불일치 3: foundation은 1채널인데 Task1/2는 멀티모달

### 문제

foundation stem은 다음 구조다.

```text
Conv3d(1, 32, kernel=3)
```

하지만 downstream 입력은 다음처럼 여러 모달이다.

```text
Task1: adc + dwi_b1000 + flair + (swi or t2s)
Task2: dwi_b1000 + flair + (swi or t2s)
Task3: t1w
Task4: t2w
Task5: t1
Task6/7: arbitrary single input, embedding output
```

즉 Task1/2는 foundation의 1채널 입력과 직접 맞지 않는다.

### 해결 A: foundation 수정 없는 late fusion

가장 보수적인 방법은 모달별로 같은 1채널 foundation을 반복 적용하는 것이다.

```text
adc       -> same 1ch ResEnc -> global/dense feature
dwi       -> same 1ch ResEnc -> global/dense feature
flair     -> same 1ch ResEnc -> global/dense feature
swi/t2s   -> same 1ch ResEnc -> global/dense feature
                              -> mean/concat/head fusion
```

이 방식은 foundation weight를 한 개도 바꾸지 않는다. 특히 Task6/7은 finetune 금지이므로 이 방식이 가장 규칙적으로 안전하다.

### 해결 B: downstream finetune용 stem widening

Task1/2처럼 finetune이 허용되는 task에서는 성능을 위해 stem widening을 추가로 쓸 수 있다.

```text
Conv3d(1, 32, 3) -> Conv3d(N, 32, 3)
```

초기화:

```text
new_weight[:, i] = old_weight[:, 0] / N
```

이렇게 하면 N개 모달이 동일할 때 기존 1채널 stem과 출력 scale이 맞는다. 이후 downstream finetune에서 modality별 가중치를 학습한다.

중요한 점:

```text
stem widening은 foundation checkpoint 자체를 수정하는 것이 아니다.
downstream finetune model의 초기화 방식이다.
원본 foundation checkpoint는 그대로 보존된다.
```

### 현재 우선순위

- Task6/7: late fusion 또는 single input frozen embedding만 허용
- Task1/2 baseline: late fusion으로 먼저 end-to-end 구축
- Task1/2 성능 개선: stem widening finetune을 ablation으로 추가

## 4. 불일치 4: `swi`와 `t2s`가 상호대체인데 고정 모달처럼 다루면 누락됨

### 문제

Task1/2에서 마지막 모달은 `swi` 또는 `t2s` 중 하나다. 둘 다 항상 존재하지 않는다.

실측:

```text
Task1: swi 16, t2s 5, both 0, none 0
Task2: swi 8,  t2s 15, both 0, none 0
```

따라서 `modalities=["...","t2s"]`처럼 고정하면 `swi`만 있는 subject에서 중요한 모달을 놓친다.

### 해결

논리 모달을 도입한다.

```text
t2star := swi if exists else t2s
```

로더는 task별 고정 모달 목록을 실제 파일명 목록이 아니라 논리 모달 목록으로 관리해야 한다.

```text
Task1: adc, dwi_b1000, flair, t2star
Task2: dwi_b1000, flair, t2star
```

이 수정은 foundation과 무관한 downstream loader 수정이다.

## 5. 불일치 5: pretrain은 96^3 crop, downstream은 큰 원본 volume

### 문제

foundation 학습은 96^3 crop 기반이었다. downstream은 whole volume이다.

예:

```text
Task4: 360 x 512 x 512
Task5: 512 x 191 x 512
Task1/2: 384 x 512 x 30, highly anisotropic
```

global task에서 whole-volume forward를 할 수는 있지만, SimPool token count와 field-of-view가 pretrain과 크게 달라질 수 있다. segmentation은 whole-volume direct inference가 memory/time 측면에서 위험하다.

### 해결

두 경로를 분리한다.

Global cls/reg/embed:

```text
Yucca-preprocessed 1mm volume
-> 96^3 sliding-window feature extraction
-> window global vectors
-> mean/max/attention pooling
-> task head or embedding
```

Segmentation:

```text
Yucca-preprocessed 1mm volume
-> 128^3 또는 160^3 sliding-window
-> dense logits aggregation
-> threshold/argmax
-> original space resample-back
```

현재 `downstream/core.py`는 global feature extraction의 공통 기반이고, segmentation sliding-window/aggregation은 별도 S4 구현 대상이다.

## 6. 불일치 6: segmentation 출력 공간이 validator/eval 요구와 다름

### 문제

모델 내부 예측은 Yucca 전처리 공간에서 나온다.

```text
1mm isotropic + RAS + cropped nonzero bbox
```

하지만 validator와 challenge evaluator는 원본 NIfTI 공간을 기대한다.

Task2/4 validator 조건:

```text
output.nii.gz
3D
integer labels
same shape as any input
valid affine
Task2 max label 1
Task4 max label 2
```

따라서 전처리 공간 segmentation을 그대로 저장하면 shape mismatch로 validator 실패 또는 metric 오류가 난다.

### 해결

전처리 때 원본 geometry metadata를 보존하고, segmentation 출력은 원본 공간으로 되돌린다.

흐름:

```text
raw NIfTI
-> preprocess_case_for_inference(...): preprocessed image + properties
-> model predicts preprocessed-space logits
-> inverse crop/orientation/spacing using properties
-> save NIfTI with reference affine/header
```

현재 `downstream/core.py::yucca_pp(..., for_inference=True)`는 props를 받을 준비를 해두었다. 다음 구현에서는 `reverse_preprocessing` 또는 동일한 nearest-neighbor resample-back 로직을 추가해야 한다.

## 7. 불일치 7: Task4는 binary가 아니라 multiclass

### 문제

기존 `pretrain/seg_finetune.py`는 binary Dice/BCE 중심이다. 하지만 Task4 label은 `{0,1,2}`이다.

### 해결

Task4는 별도 multiclass segmentation head와 loss를 사용한다.

```text
out_channels = 3  # background + class1 + class2
loss = CrossEntropy + multiclass Dice
inference = argmax(logits, dim=channel)
output labels in {0,1,2}
```

Task2는 binary 유지:

```text
out_channels = 1 or 2
threshold or argmax
output labels in {0,1}
```

이 역시 foundation 변경이 아니라 downstream head 변경이다.

## 8. 불일치 8: Task6/7은 finetune 금지

### 문제

Task1-5는 finetune 가능하지만, Task6/7은 frozen embedding container만 제출해야 한다. 따라서 Task6/7에 task-specific stem widening, task head training, supervised adaptation을 넣으면 안 된다.

### 해결

Task6/7은 foundation encoder를 frozen 상태로 사용한다.

```text
input NIfTI
-> Yucca 4-step
-> 1-channel foundation forward
-> global_vec
-> np.save(output.npy, embedding)
```

embedding 조건:

```text
1D float array
finite
all cases same dimension
```

embedding dim은 320이어도 되고 1024일 필요는 없다. validator는 1D float와 dimension consistency만 본다.

## 9. foundation model 수정 없이 가능한 이유

Foundation model은 pretrained checkpoint다. 제출 규칙의 "single checkpoint"는 모든 downstream task가 같은 pretrained source에서 출발해야 한다는 의미다. Downstream task head와 finetuning model은 task별로 달라질 수 있다. Task6/7만 frozen 제약이 있다.

따라서 다음은 foundation 수정이 아니다.

```text
1. raw NIfTI를 pretrain과 같은 방식으로 전처리
2. 모달별로 같은 1채널 foundation을 반복 적용
3. task-specific cls/reg/seg head를 붙임
4. finetune 허용 task에서 downstream head 또는 전체 model을 finetune
5. segmentation 출력을 원본 공간으로 resample-back
6. container entrypoint와 output format을 task별로 맞춤
```

반대로 다음은 foundation 수정에 가깝거나 Task6/7에서 금지될 수 있다.

```text
1. FOMO300K가 아닌 외부 데이터로 checkpoint를 다시 사전학습
2. task별로 서로 다른 pretrained checkpoint 선택
3. Task6/7 embedding을 supervised finetuned model에서 추출
4. checkpoint architecture를 바꾼 뒤 그것을 새 foundation처럼 사용
```

## 10. 현재 구현 상태와 남은 조치

### 구현됨

- `downstream/core.py`
  - wg0.5 checkpoint strict load
  - Yucca 전처리 config 복제
  - label 파일명 차이 흡수
  - subject/session 명명 차이 일부 흡수
  - 1채널 foundation 기반 global feature 추출

- `downstream/eval_global.py`
  - Yucca 전처리 기반 cls/reg frozen probe
  - random baseline feature cache와 비교 가능

- `downstream/eval_seg.py`
  - Yucca 전처리 기반 Task4 trigeminal seg-transfer 재평가
  - 기존 resize probe artifact 확인용

### 즉시 수정 필요

1. `swi/t2s` 대체 로더
   - `t2star := swi if exists else t2s`
   - Task1/2 모달 누락 방지

2. segmentation 원본공간 복원
   - `for_inference=True` props 활용
   - output NIfTI shape/affine/header validator 통과

3. Task4 multiclass support
   - 3-channel logits
   - CE + multiclass Dice
   - argmax output label range `[0,2]`

4. sliding-window inference
   - segmentation: 128^3/160^3 patch aggregation
   - global: 96^3 window feature pooling
   - 120 sec/case benchmark

5. 결과 저장
   - eval scripts는 stdout뿐 아니라 JSON 저장
   - 실험 결과 유실 방지

## 11. 최종 요약

문제는 foundation model이 downstream에 "쓸 수 없다"가 아니다. 문제는 다음 네 계층이 직접 맞지 않는다는 것이다.

```text
공식 Asparagus 구조
downstream raw NIfTI 분포
multi-modal task 입력
validator output geometry
```

해결은 foundation checkpoint를 고치는 것이 아니라, 그 주변에 정확한 adapter를 만드는 것이다.

```text
raw NIfTI
-> pretrain-identical Yucca preprocessing
-> 1-channel foundation reused per modality
-> task-specific fusion/head
-> seg sliding-window + original-space restore
-> validator-compliant output
```

이 방식이면 `resenc_s3d_wg0.5/latest.pt`를 단일 foundation checkpoint로 유지하면서 FOMO26 7-task downstream 제출 파이프라인에 연결할 수 있다.
