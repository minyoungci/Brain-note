# ResEnc + S3D-style dense + InfoNCE-global 구조 설명

이 문서는 `pipeline.png`에 그려진 최신 사전학습 구조를 논문 Methods 섹션처럼 상세히 설명하기 위한 기록이다. 대상 모델은 FOMO300K 3D brain MRI를 이용해 하나의 SSL 체크포인트를 학습하고, 이후 7개 이질 downstream task에 전이하기 위한 단일 체크포인트 foundation model이다. 핵심 설계는 다음과 같다.

> **ResEnc U-Net backbone + S3D-style masked-conv dense MAE + SimPool/InfoNCE global objective**

이 구조의 목적은 단순한 reconstruction 성능이 아니라, 하나의 체크포인트가 segmentation, classification, regression을 동시에 잘 처리하도록 하는 것이다. 특히 FOMO26 downstream 구성에서는 segmentation task가 리더보드의 큰 비중을 차지하므로, dense spatial feature와 U-Net decoder 전이 가능성을 보존하는 것이 중요하다. 동시에 brain age regression 및 classification task를 위해 global representation도 충분히 학습되어야 한다. 따라서 모델은 하나의 shared ResEnc backbone 위에 dense branch와 global branch를 동시에 둔다.

## 1. 전체 개요

입력은 전처리된 단일 채널 3D brain MRI volume이다. 학습 시점에는 각 volume에서 두 개의 crop view를 만든다.

- `v1`: dense masked-conv MAE branch에 사용되는 student view
- `v2`: InfoNCE global branch에서 EMA teacher target으로 사용되는 teacher view

각 view는 `1 x 96 x 96 x 96` 크기이다. `v1`에는 약 60% voxel block이 숨겨지는 3D block mask가 적용된다. 모델은 masked voxel을 복원하도록 dense branch를 학습하고, 동시에 `v1`의 global embedding이 `v2`의 teacher embedding과 가까워지도록 InfoNCE loss를 학습한다.

학습 손실은 다음과 같다.

```text
L = w_dense * L_dense + w_global * L_global + lambda_KoLeo * L_KoLeo
```

현재 구현에서 `lambda_KoLeo`는 `args.koleo_w`로 주입되며 기본값은 `0.1`이다. `w_global`은 실험 variant에 따라 다르다.

- `resenc_s3d_full`: `w_global = 1.0`
- `resenc_s3d_wg0.5`: `w_global = 0.5`
- `resenc_s3d_pure`: `w_global = 0.0`

이 세 variant는 dense-only와 dense+global의 trade-off를 직접 비교하기 위한 실험이다.

## 2. 데이터 처리 파이프라인

### 2.1 Offline preprocessing

원본 FOMO300K MRI는 사전 처리된 `.npy` volume으로 저장되어 학습에 사용된다. `pipeline.png`의 Step 1은 이 offline preprocessing 단계를 나타낸다.

이 단계의 목적은 학습 loop가 원본 NIfTI 변환, orientation 정합, resampling 같은 무거운 I/O 및 전처리 작업에 매번 묶이지 않도록 하는 것이다. 실제 학습 코드는 전처리된 `.npy` 파일 목록을 manifest 기반으로 읽고, online 단계에서 crop 및 z-normalization을 수행한다.

구현상 학습 파일 목록은 `pretrain/data.py`의 `build_filelist()`가 만든다. 이 함수는 manifest의 `status=ok` 항목을 사용하고, `composition=all/anat/dwi`에 따라 corpus 조성을 선택할 수 있다. 또한 `min_size=args.crop` 필터를 걸어 crop보다 작은 축을 가진 volume이 zero-padding으로 학습 target을 오염시키지 않도록 한다.

### 2.2 Online crop and z-normalization

매 step마다 `NpyMultiCrop` dataset은 volume을 로드하고, 같은 원본에서 두 개의 random global crop을 생성한다. 각 crop은 `96^3` 크기로 잘린 뒤 z-normalization된다.

```text
volume.npy -> random crop -> z-norm -> v1, v2
```

현재 구현에는 명시적인 intensity augmentation은 들어가 있지 않다. 즉, 현재 학습의 online 변형은 주로 random crop과 z-normalization이다. 이는 figure에서 `Online: load .npy -> random crop -> z-norm`으로 표현하는 것이 가장 정확하다.

두 view를 만드는 이유는 dense branch와 global branch의 역할이 다르기 때문이다.

- Dense branch는 `v1`에서 숨겨진 voxel을 복원하며 local/dense spatial feature를 학습한다.
- Global branch는 `v1` student embedding과 `v2` EMA teacher embedding을 대조 학습하여 subject-level global representation을 학습한다.

## 3. 3D block mask

Dense branch에는 3D block mask가 적용된다. 현재 기본 mask ratio는 약 `0.6`이다. mask는 voxel 단위 random point mask가 아니라 block 단위 mask이다. ResEnc branch에서는 `mask_block=16`이 기본이므로, `96^3` crop은 `6 x 6 x 6 = 216`개의 block으로 나뉜다.

학습 loop는 `block_mask()`로 block-level binary mask를 만들고, 이를 repeat-interleave하여 voxel-level mask `mvox`로 확장한다.

```text
bmask: (B, 216)
mvox : (B, 1, 96, 96, 96)
```

여기서 `mvox=1`인 위치는 hidden voxel이고, `vis=1-mvox`는 visible voxel을 뜻한다. Dense branch는 masked input을 단순히 encoder에 넣는 방식이 아니라, `forward_masked()`에서 각 stage 뒤에 re-mask를 적용한다. 이 점이 현재 구조의 핵심이다.

## 4. Shared ResEnc U-Net backbone

Backbone은 3D CNN 기반 ResEnc U-Net이다. ViT가 아니라 ResEnc를 선택한 이유는 segmentation task에서 spatial inductive bias와 U-Net decoder 전이가 중요했기 때문이다. FOMO task 구성에서 segmentation은 리더보드 비중이 크고, 작은 병변/구조를 다루기 때문에 token-level global abstraction만으로는 충분하지 않았다.

현재 ResEnc encoder의 stage 구성은 다음과 같다.

```text
Conv3d stem:        1 x 96^3   -> 32 x 96^3
Stage 1, stride 1:  32 x 96^3  -> 32 x 96^3
Stage 2, stride 2:  32 x 96^3  -> 64 x 48^3
Stage 3, stride 2:  64 x 48^3  -> 128 x 24^3
Stage 4, stride 2:  128 x 24^3 -> 256 x 12^3
Stage 5, stride 2:  256 x 12^3 -> 320 x 6^3
```

`Stage 5` 출력은 그대로 bottleneck feature이다. 즉, 별도의 추가 bottleneck downsampling stage가 있는 것이 아니라, Stage 5의 출력 `320 x 6^3`이 global branch와 decoder branch의 공통 출발점이 된다.

ResEnc를 선택한 연구적 이유는 다음과 같다.

1. **Segmentation inductive bias**  
   CNN/U-Net 계열은 3D segmentation에서 local continuity, multi-scale hierarchy, skip connection을 자연스럽게 보존한다. FOMO downstream segmentation은 few-shot이고 병변이 작기 때문에, 처음부터 spatial prior가 강한 backbone이 유리하다.

2. **공식 downstream pipeline과의 마찰 감소**  
   FOMO/Asparagus downstream finetune baseline은 ResEnc U-Net 중심이다. 따라서 ResEnc 계열 foundation checkpoint는 공식 segmentation finetune 구조와 통합 비용이 낮다.

3. **이전 실험의 관찰**  
   ViT 계열은 global regression 신호는 강했지만, frozen/few-shot segmentation probe에서 encoder 기여가 거의 없었다. 반면 ResEnc는 dense feature가 segmentation에 실제로 기여하는 유일한 arm으로 관찰되었다.

## 5. Branch A: S3D-style masked-conv MAE

### 5.1 왜 dense branch가 필요한가

Segmentation task는 voxel-level 혹은 region-level localization 능력을 요구한다. 단순한 CLS/global representation만으로는 segmentation head가 작은 병변이나 해부학적 구조를 안정적으로 복원하기 어렵다. 따라서 backbone은 global discrimination뿐 아니라 dense spatial representation도 학습해야 한다.

초기 dense objective는 MAE reconstruction이었다. 그러나 일반 U-Net skip을 그대로 켜면 masked region 주변의 clean feature가 skip connection을 통해 decoder로 전달되어, encoder가 masked voxel을 실제로 추론하지 않아도 reconstruction loss가 낮아지는 문제가 생긴다. 이를 **MAE skip leakage**라고 볼 수 있다.

이 문제를 피하기 위해 한때 skip-free MAE를 사용했다. 그러나 skip-free MAE는 decoder와 high-resolution skip feature를 사전학습하지 못했고, 이후 segmentation finetune에서 오히려 scratch보다 나쁜 negative transfer가 관찰되었다. 즉, leakage를 막기 위해 skip을 완전히 끄면 dense decoder transfer라는 목적이 약해졌다.

현재 구조는 이 두 문제를 동시에 해결하기 위해 S3D/SparK식 submanifold masked-conv 원리를 도입했다.

### 5.2 S3D-style submanifold masked-conv approximation

원래 S3D류 접근의 핵심은 sparse/submanifold convolution을 이용해 visible region에서만 feature를 전파하고, masked region에는 정보가 흘러들어가지 않도록 하면서도 U-Net skip connection을 사용할 수 있게 하는 것이다.

하지만 현재 환경에서는 `spconv` 기반 true sparse convolution이 B200/CUDA 13.0 환경에서 안정적으로 동작하지 않았다. 실제로 prebuilt CUDA 12 계열 `spconv`는 B200 `sm_100` 환경에서 SIGFPE 문제가 발생했고, source build는 리스크가 컸다.

따라서 현재 구현은 **true sparse convolution이 아니라 dense convolution + re-mask** 방식의 submanifold-style approximation이다.

핵심 규칙은 다음과 같다.

1. 입력에서 hidden voxel을 먼저 0으로 만든다.
2. Conv3d stem 이후 hidden voxel 위치를 다시 0으로 만든다.
3. 각 encoder stage 이후에도 같은 방식으로 re-mask한다.
4. stride-2 downsampling이 발생하는 stage에서는 visibility mask도 max-pooling으로 함께 downsample한다.
5. decoder skip에는 re-mask된 stage feature만 전달한다.

이렇게 하면 decoder가 skip connection을 사용하더라도 masked region의 원본 정보는 전달되지 않는다. 즉, skip은 켜져 있지만 leakage는 막힌다.

구현상 `ResEncUNet.forward_masked(x, vis)`가 이 역할을 수행한다. `vis=1`은 visible voxel, `vis=0`은 hidden voxel이다.

```text
x = stem(x * vis) * vis
for stage in encoder:
    if downsample:
        vis = max_pool3d(vis, 2)
    x = stage(x) * vis
    feats.append(x)
decoder(bottleneck, feats)
```

이 방식은 true sparse convolution보다 계산량은 더 크지만, 의존성 없이 PyTorch 기본 연산만으로 구현 가능하고, B200/CUDA 13 환경에서 안정적으로 동작한다. 또한 anti-leakage 검증에서 masked input에 큰 perturbation을 넣어도 reconstruction 차이가 0으로 유지되어, masked voxel 정보 누수가 차단됨을 확인했다.

### 5.3 Dense loss

Decoder는 bottleneck feature와 masked stage skip feature를 사용해 전체 `96^3` volume을 복원한다. 하지만 loss는 전체 voxel에 대해 계산하지 않고 masked voxel에 대해서만 계산한다.

```text
L_dense = MSE(recon, v1) over masked voxels only
```

이 설계의 이유는 visible voxel을 단순히 identity mapping하는 것을 보상하지 않기 위해서이다. 모델은 숨겨진 block을 주변 visible context와 learned anatomical prior를 이용해 복원해야 한다.

### 5.4 Decoder transfer

이 구조에서 decoder는 사전학습 후 버리는 auxiliary head가 아니다. Segmentation downstream에서는 dense pretraining을 통해 학습된 encoder와 decoder가 함께 전이될 수 있다. 특히 FOMO segmentation task는 few-shot이기 때문에, decoder를 scratch로 학습하면 데이터가 부족하다. 따라서 dense branch는 단순히 encoder regularization이 아니라 segmentation finetune을 위한 decoder pretraining으로 해석된다.

이전 skip-free MAE에서는 decoder가 segmentation에 유리한 high-resolution skip feature를 학습하지 못해 negative transfer가 발생했다. 현재 S3D-style branch는 skip을 누수 없이 사전학습하므로, decoder transfer 가능성을 되살리는 것이 핵심 목적이다.

## 6. Branch B: InfoNCE global objective

### 6.1 왜 global branch가 필요한가

FOMO downstream은 segmentation만 있는 것이 아니다. Classification 및 brain age regression task도 포함되어 있다. Segmentation 성능만 최적화된 checkpoint는 dense spatial feature에는 강할 수 있지만, subject-level phenotype이나 age-related global variation을 잘 담지 못할 수 있다.

따라서 bottleneck feature에서 global vector를 추출하고, 이를 contrastive objective로 학습한다.

### 6.2 SimPool

ResEnc는 ViT처럼 CLS token이 없다. CNN feature map에서 global representation을 얻기 위해 단순 average pooling을 쓸 수도 있지만, 전체 brain volume에서 task-relevant region의 중요도가 균일하다고 가정하기 어렵다.

SimPool은 learnable query를 이용한 attention pooling으로, bottleneck feature map `320 x 6^3`을 하나의 `320`차원 global vector로 압축한다.

```text
320 x 6^3 feature map -> 216 tokens x 320 -> SimPool -> 320-d global vector
```

SimPool을 사용하는 이유는 CNN backbone에 CLS token과 유사한 global aggregation mechanism을 부여하기 위해서이다. 이 global vector는 classification/regression downstream에서 사용될 수 있다.

### 6.3 DINO-style projection head

Global vector는 projection head를 통과해 `1024`차원 projection으로 변환된다. Projection head는 DINO-style MLP 구조를 따른다.

```text
global vector -> MLP -> L2-normalized bottleneck -> L2-normalized prototype -> projection
```

이 구조를 사용하는 이유는 ResEnc/SimPool에서 나오는 global vector의 magnitude가 낮을 때 plain MLP head가 거의 uniform한 logit을 만들 수 있기 때문이다. 이전 실험에서 ResEnc + DINO self-distillation은 teacher distribution이 uniform에 가까워지며 global loss가 `ln(1024)` 근처에 고정되는 붕괴를 보였다. L2-normalized bottleneck과 prototype은 logit scale을 입력 magnitude에 덜 민감하게 만들어 projection head의 안정성을 높인다.

다만 projection head만으로 ResEnc global collapse가 완전히 해결되지는 않았다. 최종적으로는 objective 자체를 DINO self-distillation에서 InfoNCE로 바꾸는 것이 결정적이었다.

### 6.4 InfoNCE loss

Global branch는 student `v1` projection과 EMA teacher `v2` projection 사이의 in-batch contrastive loss를 사용한다.

```text
L_global = CE(normalize(proj_student(v1)) @ normalize(proj_teacher(v2)).T / tau, diagonal targets)
```

대각 성분은 같은 원본 volume에서 나온 positive pair이고, 나머지 batch sample은 negative pair이다. 이 negative가 ResEnc global branch에서 특히 중요했다. 이전 DINO/sinkhorn 계열 objective는 CNN global branch에서 uniform teacher/student collapse를 반복적으로 보였지만, InfoNCE는 in-batch negatives가 representation collapse를 직접적으로 막아주었다.

실험적으로 InfoNCE 전환 후 global loss가 정상적으로 감소했고, brain age regression 성능도 크게 개선되었다. 이는 dense segmentation-oriented backbone인 ResEnc가 global regression/classification task도 동시에 학습할 수 있음을 보여주는 핵심 결과였다.

## 7. EMA teacher

Teacher는 student의 EMA 버전이다. Teacher는 `v2`를 입력으로 받아 global projection을 만들고, student는 `v1` projection을 만든다. 이후 student projection이 teacher projection과 같은 sample끼리는 가까워지고, 다른 sample끼리는 멀어지도록 InfoNCE loss가 계산된다.

중요한 점은 decoder가 EMA 업데이트 대상에서 제외된다는 것이다. 구현상 teacher module 안에는 전체 `SSLModel` 구조가 존재하지만, EMA parameter update는 encoder와 global projection 관련 파라미터에만 적용된다. ResEnc decoder와 reconstruction head는 student-only dense branch로 남는다.

이 설계의 이유는 다음과 같다.

1. Dense reconstruction decoder는 teacher target 생성에 필요하지 않다.
2. Decoder를 EMA teacher에 포함하면 체크포인트와 업데이트 의미가 불필요하게 복잡해진다.
3. Global contrastive branch는 encoder + SimPool + projection head만 있으면 충분하다.

따라서 figure의 `decoder present but NOT EMA-updated / unused for global` 설명은 현재 코드의 실제 동작을 정확히 반영한다.

## 8. KoLeo regularization

KoLeo loss는 global embedding의 spread를 유지하기 위한 anti-collapse regularizer이다. 모든 batch embedding이 좁은 공간으로 모이는 것을 막고, representation diversity를 유지하는 역할을 한다.

현재 loss에는 다음 형태로 들어간다.

```text
L_total = w_dense * L_dense + w_global * L_global + lambda_KoLeo * L_KoLeo
```

KoLeo는 DINO-style SSL에서 자주 쓰이는 collapse 방지 수단이다. 다만 이번 구조에서 collapse를 근본적으로 막은 주된 변화는 InfoNCE negative 도입이며, KoLeo는 보조 안정화 역할로 보는 것이 정확하다.

## 9. Single SSL checkpoint와 downstream 전이

학습이 끝나면 하나의 SSL checkpoint가 저장된다. 이 checkpoint는 segmentation, classification, regression task에 동일하게 사용된다.

- Segmentation: ResEnc encoder와 dense decoder를 전이한다.
- Classification/regression: bottleneck에서 SimPool로 얻은 global vector를 사용한다.
- Task 6/7: linear probe 및 fairness/scanner-invariance 평가에 사용한다.

이 설계는 FOMO26의 단일 체크포인트 제약과 직접적으로 맞물린다. 핵심 질문은 하나의 checkpoint가 dense task와 global task를 동시에 만족할 수 있는가이다. 현재 구조는 이 질문에 대해 dense branch와 global branch를 명시적으로 분리하되, backbone은 공유하는 방식으로 접근한다.

## 10. 왜 이 모듈 조합인가

### 10.1 ResEnc backbone

ResEnc는 segmentation task에서 유리한 spatial inductive bias를 제공한다. 이전 실험에서 ViT 계열은 brain age regression에는 강했지만, segmentation probe에서 pretrained encoder의 기여가 거의 없었다. 반면 ResEnc는 segmentation에서 encoder 기여가 확인되었다.

따라서 최종 구조는 ViT 중심이 아니라 ResEnc 중심으로 이동했다. 이는 단순히 문헌 선호 때문이 아니라, 내부 실험에서 segmentation bottleneck을 직접 확인한 결과이다.

### 10.2 S3D-style dense MAE

기존 skip-free MAE는 leakage는 막았지만 segmentation transfer가 나빴다. 반대로 일반 skip-enabled U-Net MAE는 leakage 위험이 있었다. S3D-style masked-conv는 두 문제의 절충이 아니라, 둘을 동시에 해결하려는 구조이다.

- skip을 켜서 segmentation decoder transfer를 가능하게 한다.
- re-mask로 hidden voxel 정보 누수를 차단한다.
- masked voxel MSE로 non-trivial reconstruction을 강제한다.

### 10.3 InfoNCE global

ResEnc + DINO self-distillation은 global branch에서 반복적으로 붕괴했다. Teacher/student가 uniform distribution에 머물고, global loss가 `ln(K)` 근처에 고정되었다. Sinkhorn이나 global weight 조절만으로는 이 문제를 안정적으로 해결하지 못했다.

InfoNCE는 in-batch negative를 통해 collapse를 구조적으로 방지한다. 이 변경 후 ResEnc global branch가 살아났고, regression 성능이 크게 개선되었다. 따라서 현재 구조에서 InfoNCE는 단순한 선택지가 아니라, CNN global representation을 살린 핵심 변경이다.

### 10.4 SimPool

CNN에는 CLS token이 없기 때문에 global vector를 만들 별도 pooling이 필요하다. SimPool은 attention pooling으로 bottleneck feature map에서 global representation을 만들며, global branch와 downstream cls/reg head의 접점을 제공한다.

### 10.5 EMA teacher

EMA teacher는 target representation의 temporal stability를 높인다. Student가 매 step 급격히 바뀌더라도 teacher는 부드럽게 따라오므로 contrastive target이 안정된다. 다만 decoder는 global target과 무관하므로 EMA에서 제외한다.

## 11. 이전 실험에서 확인한 문제와 개선 내역

### 11.1 Cosine conflict balancing 가설 기각

초기에는 dense loss와 global loss가 encoder 내에서 서로 충돌할 수 있다고 가정했다. 그러나 conflict pilot에서 aggregate cosine은 거의 0에 가까웠고, layer-wise conflict map에서도 강한 cosine conflict가 보이지 않았다. 즉, PCGrad류 cosine conflict 해결을 핵심 novelty로 삼기 어렵다는 결론이 나왔다.

대신 실험은 dense/global이 싸우는 문제가 아니라, backbone과 objective가 각각 dense/global representation을 제대로 학습하는지의 문제로 이동했다.

### 11.2 내부 평가 하네스의 shortcut 문제

초기 segmentation proxy는 voxel-AUROC 기반이었고, random encoder도 높은 점수를 내는 문제가 있었다. 이는 병변 위치 prior와 decoder 표현력이 metric을 포화시키는 shortcut이었다.

이를 해결하기 위해 실제 Dice 기반 probe와 random baseline, bootstrap CI, constant-prior floor를 도입했다. 이후 segmentation 판단은 절대값이 아니라 pretrained-vs-random 또는 pretrained-vs-scratch 차이로 해석하게 되었다.

### 11.3 ViT segmentation 기여 부족

ViT 계열은 global/regression에는 유망했지만, segmentation에서는 pretrained token이 실제 기여하지 않는 현상이 관찰되었다. 특히 conv-stem skip이 있는 decoder에서는 random encoder도 일정 성능을 냈고, pretrained encoder의 추가 기여가 0에 가까웠다.

이 결과는 segmentation 중심 FOMO task에서 ResEnc를 우선하는 결정적 근거가 되었다.

### 11.4 ResEnc DINO global collapse

ResEnc는 dense reconstruction은 잘 학습했지만, DINO self-distillation 기반 global branch는 붕괴했다. Global loss가 `ln(1024)` 근처에 고정되고, teacher entropy가 uniform에 가까웠다.

Plain MLP head의 낮은 logit scale 문제도 있었지만, DINO-style normalized head만으로는 완전 해결되지 않았다. 최종적으로 InfoNCE objective가 ResEnc global branch를 살렸다.

### 11.5 Skip-free MAE의 segmentation negative transfer

Leakage를 막기 위해 skip-free MAE를 사용했더니, segmentation finetune에서 pretrained model이 scratch보다 나쁜 negative transfer를 보였다. Meningioma segmentation에서 pretrained Dice가 scratch보다 낮았고, 150 epoch 및 crop128 조건에서도 gap이 유지되었다.

이 결과는 dense pretraining이 단순히 reconstruction loss를 낮추는 것이 아니라, downstream decoder transfer와 맞아야 한다는 점을 보여주었다.

### 11.6 S3D-style re-mask로 negative transfer 완화

S3D-style submanifold masked-conv approximation을 도입한 뒤, early checkpoint 기준 segmentation transfer가 크게 개선되었다.

관찰된 early signal은 다음과 같다.

- skip-free pretrained Dice: 약 `0.016`
- S3D-style pretrained Dice: 약 `0.078`
- scratch Dice: 약 `0.088`
- pretrained - scratch gap: `-0.046` 수준에서 `-0.009` 수준으로 축소

이는 아직 pretrained가 scratch를 확실히 이겼다는 뜻은 아니다. 그러나 기존의 명확한 negative transfer가 거의 동률 수준까지 완화되었다는 점에서, 구조적 방향이 맞다는 강한 early evidence로 볼 수 있다. 최종 판단은 full 150k step 완료 후 동일 프로토콜의 segmentation transfer 평가로 내려야 한다.

### 11.7 spconv 의존성 제거

True sparse convolution을 위해 `spconv`를 사용하려 했으나, B200/CUDA 13 환경에서 안정적으로 동작하지 않았다. 의존성 빌드 리스크가 큰 상황에서, dense conv + re-mask 방식으로 S3D-style submanifold behavior를 근사했다.

이 선택은 성능과 구현 안전성 사이의 타협이다. True sparse conv보다 compute 효율은 낮지만, 현재 학습 환경에서 재현 가능하고 안정적이며, anti-leakage 검증을 통과했다.

## 12. 현재 해석과 남은 검증

현재 구조는 다음 두 축을 동시에 만족시키기 위한 가장 유력한 후보이다.

1. **Dense/segmentation axis**  
   S3D-style masked-conv MAE가 skip-free MAE의 negative transfer를 완화했고, decoder transfer 가능성을 회복했다.

2. **Global classification/regression axis**  
   InfoNCE global objective가 ResEnc global collapse를 해결했고, brain age regression에서 큰 개선을 보였다.

다만 아직 최종 결론은 아니다. Early segmentation result는 promising하지만, final 150k checkpoint에서 pretrained가 scratch를 안정적으로 이기는지 확인해야 한다. 특히 Task2 meningioma는 subject 수가 작고 confidence interval이 넓기 때문에, 단일 early result만으로 구조를 최종 확정하면 안 된다.

따라서 다음 검증 순서는 다음과 같다.

1. `resenc_s3d_full`, `resenc_s3d_wg0.5`, `resenc_s3d_pure`를 150k step까지 완료한다.
2. 같은 segmentation finetune 프로토콜로 Task2 meningioma를 재평가한다.
3. 가능하면 crop128 또는 공식 downstream에 가까운 full-resolution/patch160 설정으로 재검증한다.
4. `wg0.5`가 dense 성능을 크게 손상하지 않으면서 global 성능을 유지하는지 확인한다.
5. Task3 brain age 및 classification probe를 다시 평가해 global branch의 이득이 유지되는지 확인한다.
6. Task4 trigeminal은 작은 구조물이므로 고해상도 조건에서 별도 검증한다.

## 13. 요약

본 구조는 이전 실험에서 드러난 두 가지 실패를 직접 해결하기 위해 설계되었다.

- **ResEnc global collapse**는 InfoNCE negative contrast로 해결한다.
- **Skip-free MAE segmentation negative transfer**는 S3D-style masked-conv re-mask와 skip-enabled decoder pretraining으로 완화한다.

따라서 이 모델은 단순히 `ResEnc + MAE + contrastive`의 조합이 아니다. 각 모듈은 이전 실험에서 관찰된 실패 모드를 해결하기 위해 들어갔다.

최종적으로 기대하는 것은 하나의 SSL checkpoint가 다음 성질을 갖는 것이다.

- segmentation task에는 encoder + decoder transfer로 dense spatial prior를 제공한다.
- classification/regression task에는 SimPool global vector를 제공한다.
- 하나의 backbone이 dense와 global branch를 동시에 학습하되, 두 objective가 서로를 심각하게 방해하지 않도록 loss weight를 조절한다.

현재 가장 중요한 판정점은 full 150k step 이후 segmentation transfer가 scratch를 넘어서는지, 그리고 `w_global=0.5` 또는 `1.0` variant가 dense 성능을 유지하면서 global 성능을 보존하는지이다.
