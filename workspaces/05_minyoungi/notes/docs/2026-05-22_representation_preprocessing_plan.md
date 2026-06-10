# 3D Brain Representation Learning 전처리·실험 설계 블로그

작성일: 2026-05-22  
위치: `/home/vlm/minyoungi/docs/2026-05-22_representation_preprocessing_plan.md`  
참고 원본: `notes/context/*`, `manifests/v2_integrated/*`, `experiments/*`

> 이 문서는 Min이 읽기 위한 blog형 설명이다. `notes/`는 내가 작업 전 참고하는 source-of-truth/context이고, `docs/`는 “무엇이 왜 어려웠고, 지금 어떻게 고치는 중인지”를 사람이 이해하기 쉽게 정리하는 공간으로 둔다.

---

## 0. 한 문장 결론

현재 계획은 **전처리는 Option B 방식으로 voxel-wise ROI 후보와 QC report만 먼저 만들고**, representation learning은 **ROI-volume distillation을 main route가 아니라 auxiliary/diagnostic branch로 낮춘 뒤, 3D anatomy + disease-axis + ROI-caption alignment를 단계적으로 학습**하는 것이다.

아직 하면 안 되는 것:

```text
대형 VLM 학습으로 바로 점프
voxel-wise ROI mask-guided loss 바로 사용
FastSurfer를 final_tensor에 다시 돌리는 방식
ROI-volume teacher 하나만 믿고 main claim 만들기
```

먼저 할 것:

```text
1. Option B full candidate/QC preprocessing branch
2. current flatpool encoder 재평가: CN/AD axis, MCI projection, age, cohort probe
3. Teacher-S vs Teacher-B 동일 조건 비교
4. DKT volume teacher expansion smoke
5. external 3D SSL/foundation frozen baseline 확인
```

---

## 1. 우리가 하려는 representation learning은 무엇인가?

목표는 단순한 CN/MCI/AD classifier가 아니다. 목표는 **3D T1w MRI에서 뇌 해부학적 구조와 치매 진행 축을 담는 representation**을 만드는 것이다.

좋은 representation은 다음을 만족해야 한다.

- hippocampus, entorhinal cortex, temporal cortex, ventricle 같은 AD-relevant anatomy를 반영한다.
- CN→AD disease-axis를 어느 정도 분리한다.
- MCI를 억지 hard class 하나로만 맞추지 않고, CN과 AD 사이의 heterogeneous state로 해석할 수 있어야 한다.
- cohort/scanner shortcut에만 의존하지 않는다.
- 나중에 ROI caption, controlled clinical caption, VLM/MLLM alignment로 확장 가능해야 한다.

즉 최종 그림은 다음과 같다.

```text
3D T1w MRI
  → 3D image encoder
  → anatomical representation
  → ROI morphology / disease-axis / caption alignment / downstream probe
```

CN/MCI/AD balanced accuracy는 중요하지만, 이것만으로 representation의 질을 판단하면 위험하다. 특히 MCI는 biological continuum + cohort label policy + scanner/domain shift가 섞여서 3-class metric이 noisy하다.

---

## 2. 지금까지 무엇이 실패했고 무엇을 배웠나?

### 2.1 image-only tiny CNN smoke

처음 image-only baseline은 canonical final tensor를 읽고 학습 루프를 돌리는 데는 성공했다.

확인된 것:

```text
input: T1w final_tensor
split: subject-disjoint split
excluded: caption, ROI scalar, CDR, biomarker, cohort/site/scanner
model: tiny 3D CNN
```

하지만 성능은 약했다.

```text
80/class smoke internal_test balanced_accuracy ≈ 0.45
240/class scaled smoke internal_test balanced_accuracy ≈ 0.39
MCI recall collapse 관찰
```

해석:

- image path와 split은 작동한다.
- 하지만 작은 3D CNN만으로는 안정적인 disease representation을 만들지 못했다.
- 특히 MCI는 CN/AD 사이에 섞여 hard 3-class 성능을 흔든다.

### 2.2 ROI scalar teacher는 완전히 틀린가?

아니다. FastSurfer ROI volume 기반 teacher는 완전 garbage가 아니다.

근거:

```text
16/16 AD-relevant ROI directionality 유지
ROI-only internal_test balanced_accuracy 대략 0.50~0.57
native-space overlay gross QC에서 큰 off-brain/misregistration 없음
```

하지만 한계가 분명하다.

```text
volume-only teacher
MaskVol proxy 사용; eTIV/ICV 아님
true cortical thickness 없음
MCI signal 약함
ComBat/bias reduction을 하면 disease signal도 일부 줄어듦
```

따라서 ROI-volume teacher는 “보조적인 anatomical signal”로는 쓸 수 있지만, 이것만 main supervision으로 쓰면 representation ceiling이 낮다.

### 2.3 voxel-wise ROI mask transfer 실패

가장 중요한 전처리 실패는 이것이다.

```text
FastSurfer native ROI mask → final_tensor grid affine-only resampling
median relative volume error ≈ -0.892
```

해석:

- native ROI volume의 약 11%만 남는 수준이다.
- 이 mask를 그대로 ROI crop, attention, segmentation loss에 쓰면 잘못된 anatomy를 가르치게 된다.
- 그래서 현재 voxel-wise ROI supervision은 금지다.

중요한 구분:

```text
image-only final_tensor: PASS
FastSurfer scalar ROI stats: usable as scalar teacher
voxel-wise ROI mask in final_tensor: previously BLOCKED, now Option B candidate/QC branch로 재개 가능
```

전처리 전체가 실패한 것이 아니라, **segmentation-to-final_tensor transform provenance/QC가 실패했던 것**이다.

### 2.4 CNN collapse의 일부 원인은 구현/최적화 문제였다

tiny overfit/head audit에서 확인된 것:

```text
row_id one-hot head: perfect memorization
raw image random projection head: perfect memorization
GAP CNN lr=1e-3: unstable
GAP CNN lr=1e-4: near-perfect tiny overfit
flatpool CNN: perfect tiny overfit
```

결론:

```text
label/CE/metric plumbing은 정상
image tensor와 label 연결도 정상
문제 일부는 low-dimensional GAP bottleneck + aggressive lr/optimization
```

그래서 flatpool CNN diagnostic student로 바꿨고, 12/class teacher-latent objective는 통과했다.

### 2.5 하지만 80/class representation은 아직 약하다

flatpool CNN으로 tiny overfit 문제는 해결됐지만 80/class에서 internal_test는 아직 약하다.

```text
Teacher-S internal_test teacher ceiling ≈ 0.52
student frozen internal_test balanced_accuracy ≈ 0.48
```

현재 병목은 다음으로 이동했다.

```text
1. teacher ceiling 낮음
2. teacher-student transfer gap
3. 80/class generalization 약함
4. CN/MCI/AD hard 3-class evaluation mismatch
```

---

## 3. 전처리는 어떻게 진행할 것인가?

전처리 방향은 **Option B**다.

```text
기존 FastSurfer output 유지
FastSurfer aparc/aseg를 final_tensor grid로 정확히 transfer
FastSurfer를 final_tensor에 다시 돌리지 않음
```

왜 이렇게 하는가?

- FastSurfer는 native/conformed T1 input contract에 맞춰져 있다.
- final_tensor는 skull-strip, RAS, 1mm, crop/pad, z-score가 적용된 model input이다.
- final_tensor를 FastSurfer input으로 쓰면 segmentation model contract를 깨뜨릴 수 있다.
- 따라서 기존 FastSurfer output을 보존하고, 동일한 RAS/1mm/crop-pad transform을 label에 nearest-neighbor로 적용하는 쪽이 안전하다.

### 3.1 현재 Option B smoke 결과

6 cohort smoke는 성공했다.

```text
report: /home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_6cohort_smoke_20260522T033423Z/
selected = 18
runs = 18
pass_run = 18
issue_count = 0
Deep5 ROI: hippocampus, amygdala, thalamus, lateral_ventricle, parahippocampal_cortex
relative_volume_error max_abs = 0.0
centroid_shift_vox ≈ 0
inside_brain_frac mostly 1.0
```

이건 좋은 신호지만, 아직 “전체 데이터에서 voxel-wise ROI supervision 가능”이라는 뜻은 아니다.

### 3.2 다음 전처리 작업

다음 단계는 **full candidate/QC branch**다.

허용:

```text
candidate ROI mask 생성
per-subject QC JSON/CSV
full summary CSV
ROI-level issue table
cohort-level failure audit
overlay contact sheet
subject/ROI readiness report
```

금지:

```text
기존 final_tensor 수정
기존 FastSurfer output 수정
canonical manifest 수정
roi_final_ready=True 설정
voxel-wise ROI loss 활성화
```

즉 전처리는 “학습용 확정 데이터 생성”이 아니라, 먼저 **후보 생성 + QC 증거 만들기**다.

---

## 4. 앞으로 어떤 모델과 학습 방법을 쓸 것인가?

### 4.1 지금까지 사용한/검증한 모델

```text
ROI-only probe:
  16 ROI z/status/age/sex를 사용한 non-image baseline

image-only tiny CNN:
  final_tensor T1w만 입력으로 사용한 smoke baseline

GAP CNN teacher-latent:
  collapse/optimization issue 확인

flatpool CNN diagnostic student:
  tiny overfit pass, 80/class teacher-transfer diagnostic 진행

Teacher-S:
  signal-preserving ROI teacher
  CN-only age/sex residual z 기반

Teacher-B:
  bias-reduced ROI teacher
  ComBat + CN-only residual branch
```

### 4.2 다음 모델/학습 후보

#### A. Flatpool diagnostic encoder 재평가

목적:

```text
현재 3-class bal_acc ≈0.48이 representation failure인지,
MCI hard-class noise 때문인지 분리한다.
```

평가:

```text
CN vs AD binary probe
CN→AD disease-axis score
MCI projection
age prediction probe
cohort probe
```

#### B. Teacher-S vs Teacher-B 동일 조건 비교

목적:

```text
signal 보존과 cohort bias 감소 사이 trade-off를 같은 student/eval protocol에서 비교한다.
```

판정:

```text
Teacher-B가 cohort probe를 낮추고 disease-axis를 유지하면 Teacher-B 우선
Teacher-S가 훨씬 강하면 Teacher-S는 main signal, Teacher-B는 bias audit/regularizer
둘 다 약하면 ROI-volume teacher route를 auxiliary로 내림
```

#### C. DKT volume teacher expansion

목적:

```text
16 ROI scalar teacher의 정보량 병목을 직접 테스트한다.
```

방법:

```text
FastSurfer aseg+DKT.VINN.stats의 ~100개 region Volume_mm3 사용
train-only reference fitting
age/sex residual z 또는 optional ComBat branch
flatpool teacher-latent distillation
```

왜 thickness가 아니라 volume인가?

```text
현재 sample FastSurfer output에는 true cortical thickness/surface stats가 보이지 않는다.
즉시 가능한 것은 DKT cortical/subcortical volume expansion이다.
```

#### D. External 3D SSL/foundation baseline

목적:

```text
ROI distillation이 아니라 외부 3D self-supervised representation이 더 좋은지 확인한다.
```

후보:

```text
3D-Neuro-SimCLR: repository 확인됨
BrainFound: paper 확인됨, code/weight 위치 추가 확인 필요
```

평가:

```text
frozen encoder + linear/logistic probe
CN/MCI/AD secondary
CN vs AD primary
MCI projection
age probe
cohort probe
```

---

## 5. 최종 VLM/representation learning 설계

최종적으로는 다음 4개 branch를 합친다.

### Branch 1. Image anatomy encoder

입력:

```text
3D T1w final_tensor
brain mask
optionally ROI-local masks after Option B QC approval
```

학습:

```text
3D SSL / masked reconstruction / contrastive learning
age or brain morphology auxiliary task
ROI-local pooling if masks pass QC
```

### Branch 2. ROI morphology teacher

입력:

```text
FastSurfer scalar ROI stats
Teacher-S / Teacher-B / DKT-Vol variants
```

역할:

```text
main objective가 아니라 anatomical auxiliary signal
teacher ceiling과 bias를 항상 따로 보고
```

### Branch 3. Controlled text/caption encoder

입력:

```text
controlled_captions_v0: modality + age bucket + sex
roi_captions_v0: image-derived ROI morphology captions
```

주의:

```text
diagnosis/CDR/PET/biomarker/cohort/scanner words 금지
roi captions는 disease statement가 아니라 morphology/status statement
```

### Branch 4. Evaluation/probe suite

필수 평가:

```text
image-only downstream probe
ROI-only probe
image+ROI auxiliary probe
caption retrieval/alignment
CN vs AD axis
MCI projection
age/anatomy prediction
cohort/scanner shortcut probe
cohort-held-out evaluation
```

---

## 6. 왜 어려운가?

### 6.1 MRI는 3D이고 signal이 약하다

2D natural image처럼 object boundary가 뚜렷하지 않고, 질병 관련 변화는 작고 넓게 퍼져 있다. hippocampal/entorhinal volume 변화도 cohort, age, sex, head size, scanner에 영향을 받는다.

### 6.2 MCI는 hard class가 아니다

MCI는 CN과 AD 사이의 진행 상태일 수도 있고, stable MCI/convertor/non-AD etiology가 섞일 수 있다. 따라서 3-class accuracy가 representation quality를 과소평가하거나 왜곡할 수 있다.

### 6.3 text supervision이 leakage를 만들기 쉽다

caption에 diagnosis, CDR, PET positivity, cohort/site/scanner 정보가 들어가면 image-language representation이 아니라 shortcut을 학습한다. 그래서 controlled caption policy와 forbidden field audit이 필수다.

### 6.4 ROI mask는 공간 정합이 매우 민감하다

scalar ROI volume은 FastSurfer stats에서 바로 쓸 수 있지만, voxel-wise ROI mask를 model input grid에 맞추려면 transform chain이 정확해야 한다. label map은 nearest-neighbor로 옮겨야 하고, volume/centroid/inside-brain/visual QC가 모두 필요하다.

---

## 7. 실행 순서와 gate

```text
Phase 0. 문서/설계 정리
  - notes는 reference source-of-truth
  - docs는 Min용 blog/explanation

Phase 1. Option B preprocessing full candidate/QC
  - candidate ROI masks + QC report only
  - no manifest mutation
  - no training use yet

Phase 2. Current representation diagnostics
  - E1 flatpool re-evaluation
  - E2 Teacher-S vs Teacher-B
  - E3 DKT volume teacher expansion
  - E4 external SSL frozen baseline feasibility

Phase 3. Route decision
  - ROI teacher가 강해지면 anatomical teacher auxiliary 유지
  - external SSL이 강하면 SSL/foundation adaptation 우선
  - 모두 약하면 preprocessing/data/evaluation 재점검

Phase 4. VLM alignment smoke
  - image embedding ↔ ROI caption embedding retrieval
  - controlled caption은 leakage-safe low-info baseline
  - ROI caption은 image-derived morphology grounding

Phase 5. Larger training
  - Min 승인 후에만 long/GPU/multi-GPU run
```

---

## 8. 이 문서와 연결된 그림

PaperBanana 생성까지 완료했다.

```text
paperbanana command: available
provider key: set
generated PNG: available
```

`docs/figures/`에는 세 가지를 함께 둔다.

1. PaperBanana용 prompt 파일: 그림을 재생성하거나 수정할 때 사용
2. PaperBanana 생성 PNG: Min이 바로 읽을 수 있는 설명용 그림
3. deterministic SVG draft: provider 없이도 구조를 확인할 수 있는 fallback 구조도

파일:

```text
docs/figures/paperbanana_preprocessing_option_b_prompt.md
docs/figures/paperbanana_representation_learning_prompt.md
docs/figures/paperbanana/preprocessing_option_b.png
docs/figures/paperbanana/representation_learning_roadmap.png
docs/figures/preprocessing_option_b_draft.svg
docs/figures/representation_learning_draft.svg
```

그림 역할:

- `preprocessing_option_b.png`: 이전 affine-only ROI transfer 실패와 Option B candidate/QC branch를 한 장으로 설명한다.
- `representation_learning_roadmap.png`: 3D T1w input, ROI teacher, caption branch, alignment objective, evaluation gate가 어떻게 연결되는지 보여준다.

---

## 9. 최종 decision statement

> 지금은 “바로 VLM을 크게 학습하는 단계”가 아니라, 전처리의 ROI-final_tensor 정합을 full QC candidate로 확정하고, representation learning에서는 ROI-volume teacher의 한계를 검증하면서 더 강한 anatomical/SSL route로 넘어갈지를 결정하는 단계다. ROI caption과 VLM alignment는 최종 목표지만, 그 전에 image encoder가 3D brain anatomy와 disease-axis를 담는지, 그리고 ROI mask가 실제 final_tensor 공간에서 안전하게 맞는지를 증명해야 한다.
