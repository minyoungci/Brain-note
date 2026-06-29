# 04. Data Augmentation Plan

## 목적과 위치

augmentation은 **main novelty가 아니다.** hybrid 기여에서 augmentation은 두 보조 역할만 한다.

```text
- C2/C3 robustness: scanner/intensity/spacing 변동 하에서 표현·전이가 안정적임을 보인다.
- C1 downstream: protocol별 fine-tuning에서 과적합/검출을 통제한다(특히 작은-n lesion).
```

원칙: **전처리를 먼저 정렬(동일 Yucca 4-step)한 뒤** augmentation을 본다. augmentation으로 전처리
불일치를 보상하지 않는다. dense reconstruction mask 변형은 *novelty 실험이 아니라* robustness 점검이다.

## Pretraining Augmentation (현재 recipe 기준)

| Augmentation | Branch | Rationale | Risk |
|---|---|---|---|
| random crop 96^3 | dense/global | memory·local context | global anatomy엔 too small 위험 |
| flip x/y/z | both | orientation robustness | 좌우 임상 라벨 주의 |
| intensity scale/shift | both | scanner intensity invariance | 과하면 recon 손상 |
| Gaussian noise | both | acquisition noise | 작은 lesion texture 손상 |
| bias field | both | coil variation | z-norm과 충돌 가능 |
| gamma/contrast | both | contrast variation | pathology intensity 소거 위험 |

### Mask 변형 (robustness 점검 — novelty 아님)

```text
M0: 현재 3D block mask (60%)  — base
M1: multi-scale block mask    — anatomy/lesion scale robustness
M2: anisotropic slab mask     — thick-slice 방향 robustness
```

측정: dense reconstruction 안정성, segmentation 전이, **global 전이 비퇴화**.
주의: 이는 SparK-style dense branch의 robustness이며, 새 손실/누수 주장이 아니다.

## Dense-Global Conflict 진단 (C2 메커니즘 보조)

augmentation·가중치가 목적함수 충돌을 만들 수 있다. C2(rank trade-off)와 연결되는 진단:

```text
grad_cosine = cos(grad(L_dense), grad(L_global))
```

augmentation recipe·w_global별로 추적. 음의 cosine이 클수록 dense/global 충돌 → rank 압축·inverted-U
하강과 정합되는지 확인(C2 메커니즘 보강). 이는 *분석*이지 method claim이 아니다.

## Downstream Fine-Tuning Augmentation (C1 protocol별)

### Segmentation (보수적 우선)

| Augmentation | 권장 |
|---|---|
| foreground oversampling crop | yes (작은-n lesion 핵심) |
| flip / small rotation(±10–15°) / scale(0.9–1.1) | yes(라벨 허용 시) |
| mild noise / contrast / gamma | mild |
| elastic deformation | cautious |
| copy-paste lesion | not default (해부학적 배치 제약 없이는 위험) |

protocol 주의(C1과 정합):
```text
tubular/anatomy(trigeminal) = frozen/low-LR + 보수적 aug
lesion(meningioma)          = full-FT + foreground oversampling/high-recall
```

### Classification / Regression (C2/C3 global)

| Augmentation | 권장 |
|---|---|
| random crop/resize, mild intensity jitter, mild affine | yes |
| cutmix/mixup | validation 후에만 |

brain age 주의: atrophy/disease를 모사하는 augmentation 금지(global morphology 보존).
외부 multi-site(C3): augmentation으로 site 차이를 *가리지* 말고, site-disjoint split로 *드러낸다*.

## Augmentation Ablation Matrix (보조)

| ID | Pretraining aug | Downstream aug | 질문 |
|---|---|---|---|
| Aug0 | base | base | baseline |
| Aug1 | stronger intensity | base | scanner robustness (C3 보조) |
| Aug2 | anisotropic mask | base | thick-slice robustness |
| Aug3 | base | foreground oversampling sweep | lesion recall (C1) |

## Recommended Order

1. core 증거(C1/C2) 고정 전에는 augmentation 바꾸지 않는다.
2. downstream foreground oversampling sweep(저비용)만 먼저.
3. pretraining mask/intensity 변형은 C3 robustness 절이 필요할 때만.
4. copy-paste는 해부학적 제약 구현 전엔 쓰지 않는다.

## Paper Framing

```text
augmentation은 robustness 분석으로 제시한다 (main novelty 아님).
"method가 scanner/intensity/spacing 변동에서 안정적"임을 C3와 함께 뒷받침한다.
```
