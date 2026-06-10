# Amyloid-Burden-Aware Contrastive Learning 연구 주제 검토

- Date: 2026-05-20
- Workspace: `/home/vlm/minyoung4`
- Purpose: Min이 제안한 `Geometric Reciprocal Alignment for Continuous Clinical Trajectory: Severity-Weighted Contrastive Learning in 3D Brain MRI` 아이디어에 대한 비판적 검토 및 더 안전한 연구 framing 정리
- Status: **Research direction note only**. 아직 구현/실험 방향 확정 아님.

---

## 1. Bottom Line

제안한 방향은 **살릴 수 있다**. 하지만 현재 제목과 방법론은 fancy term이 앞서 있고, 데이터 현실과 reviewer attack point가 덜 반영되어 있다.

판정:

```text
Kill: 아님
그대로 제출: 위험
수정해서 pursue: 가능
핵심 수정 방향: APOE를 넘는 T1w의 cross-cohort incremental value 검증으로 좁히기
```

가장 안전한 핵심 질문:

```text
Does structural T1w MRI provide incremental predictive signal beyond APOE genotype and clinical covariates for amyloid PET positivity across cohorts?
```

한국어:

```text
구조적 T1w MRI가 APOE genotype 및 임상 공변량을 넘어 amyloid PET positivity 예측에 추가 정보를 제공하는가?
```

---

## 2. Original Proposed Title

```text
Geometric Reciprocal Alignment for Continuous Clinical Trajectory:
Severity-Weighted Contrastive Learning in 3D Brain MRI
```

한국어:

```text
연속적 임상 궤적을 위한 기하학적 상호 정렬:
3D 뇌 MRI에서의 중증도 가중 대조 학습
```

### 문제점

- `trajectory`는 longitudinal/time-axis evidence가 있을 때 쓰는 것이 안전하다.
- 현재 구상은 대부분 cross-sectional severity-aware representation에 가깝다.
- `reciprocal alignment`는 실제 구현과 claim을 과장할 수 있다.
- 텍스트 modality가 없으므로 CLIP-style framing은 reviewer에게 어색하게 보일 수 있다.

---

## 3. 좋은 점

### 3.1 Binary amyloid label보다 현실적임

Amyloid pathology와 structural atrophy는 실제로 binary가 아니라 연속적 스펙트럼이다. 따라서 단순 `amyloid negative vs positive` 분류보다 다음을 반영하려는 방향은 연구적으로 더 좋다.

- amyloid burden의 연속성
- APOE risk gradient
- age-related atrophy
- cohort/domain differences

### 3.2 현재 데이터와 일부 맞음

현재 verified 기준으로 다음 자료가 있다.

- AJU: amyloid normal/abnormal label, APOE genotype
- KDRC: PET visual read, SUVR, APOE genotype
- NACC: AMYLOID_STATUS, CENTILOIDS, APOE ε4 count

따라서 binary classification보다 한 단계 높은 PET-informed representation learning을 설계할 여지가 있다.

### 3.3 Cross-cohort generalization 문제를 전면에 둔 점

NACC vs AJU/KDRC는 단순히 데이터를 합치는 문제가 아니다.

잠재 차이:

- ethnicity/population
- scanner/site/protocol
- PET tracer/reference region
- label generation pipeline
- clinical recruitment bias

이 문제를 방법론과 평가에서 명시적으로 다루는 것은 좋은 방향이다.

---

## 4. 핵심 위험 1: `D_clinical` 정의가 취약함

제안된 clinical distance:

```text
D_clinical = distance(APOE ε4 count, SUVR, Age)
```

이는 위험하다. 세 변수의 의미와 scale이 완전히 다르기 때문이다.

### APOE ε4 count

- discrete genetic risk factor
- 값: 0/1/2
- disease severity라기보다 risk modifier

### SUVR / Centiloid

- PET-derived amyloid burden
- target에 매우 가까운 변수
- tracer/reference-region/cohort 차이가 큼

### Age

- strong confounder
- atrophy와 관련 있으나 amyloid와 단순한 동일 축이 아님
- age를 disease-distance anchor에 넣으면 모델이 age morphology를 amyloid trajectory로 오해할 위험이 있음

Reviewer attack:

```text
Why should one APOE ε4 allele be geometrically comparable to 10 centiloids or 5 years of age?
```

이 질문에 답하지 못하면 방법론이 무너진다.

---

## 5. 핵심 위험 2: PET SUVR을 anchor로 쓰면 prediction claim이 약해짐

Training loss에서 SUVR/centiloid를 clinical distance에 넣으면 사실상 다음과 같다.

```text
MRI embedding을 PET burden에 맞춰 supervised metric learning
```

이 자체는 나쁘지 않다. 하지만 claim을 정직하게 해야 한다.

### 위험한 claim

```text
We predict amyloid PET positivity from T1w MRI using severity-weighted contrastive learning.
```

Reviewer 반응:

```text
You used PET SUVR to define the training geometry. Isn't this just supervised PET-informed representation learning?
```

### 더 안전한 claim

```text
We learn PET-burden-aware structural MRI representations using continuous amyloid severity and APOE risk,
and test whether this representation improves cross-cohort amyloid status prediction and amyloid burden estimation.
```

즉, **PET-informed supervised representation learning**이라고 정직하게 가야 한다.

---

## 6. 핵심 위험 3: continuous severity가 모든 cohort에 공통이 아님

현재 데이터 현실:

- NACC: centiloids 있음
- KDRC: SUVR 있음
- AJU: 현재 verified 기준으로 binary visual label만 확인됨

따라서 continuous severity loss를 모든 cohort에 바로 적용하기 어렵다.

안전한 설계:

```text
Common training:
  binary amyloid status + APOE + age/sex covariates

Continuous severity auxiliary training:
  NACC/KDRC subset only, where centiloid/SUVR exists

AJU:
  binary label only; continuous severity로 억지 변환 금지
```

AJU를 continuous loss에 억지로 넣으면 label semantics가 흐려진다.

---

## 7. 추천 연구 질문

가장 강한 버전:

```text
Does continuous amyloid-burden-aware contrastive learning produce structural MRI representations
that generalize better across cohorts than binary amyloid supervision or APOE-only baselines?
```

한국어:

```text
연속형 amyloid burden을 반영한 contrastive representation learning이,
단순 binary amyloid supervision이나 APOE-only baseline보다
cohort-generalizable한 T1w MRI 표현을 만드는가?
```

핵심 검증 축:

1. Binary label보다 continuous target이 나은가?
2. APOE/age/diagnosis 같은 강한 confounder를 넘어서는 MRI signal이 있는가?
3. AJU/KDRC/NACC 간 external validation에서 버티는가?

---

## 8. 추천 Method 재설계

### 8.1 Input

```text
Image branch:
  3D T1w MRI

Clinical/genetic variables:
  APOE ε4 count
  age
  sex
  diagnosis if allowed/available
```

### 8.2 Primary Target

```text
Amyloid PET positivity: 0/1
```

모든 cohort에서 공통으로 만들 수 있는 target.

### 8.3 Secondary Continuous Target

```text
Centiloid/SUVR
```

단, cohort별 harmonization 가능성이 검증된 경우에만 사용.

---

## 9. Loss 설계 제안

너무 복잡한 geometric reciprocal loss보다 아래처럼 단순하게 시작하는 것이 좋다.

### 9.1 Classification Loss

```text
L_cls = BCE(amyloid_status)
```

### 9.2 Soft Supervised Contrastive Loss

Pairwise target similarity:

```text
s_ij = exp(-D_ij / τ_c)
```

단순한 후보:

```text
D_ij = w_pet * |amyloid_severity_i - amyloid_severity_j|
```

Age/APOE는 distance main term에 직접 섞기보다 아래 중 하나로 쓰는 것이 안전하다.

- conditioned covariates
- stratified sampling variables
- residual/control variables
- baseline inputs

### 9.3 Regression Loss for Continuous PET Burden

가능한 subset에서만:

```text
L_reg = SmoothL1(predicted_centiloid_or_SUVR, target)
```

### 9.4 Total Loss

```text
L = L_cls + λ1 L_soft_contrast + λ2 L_reg
```

---

## 10. 필수 Baselines

이 연구는 baseline이 생사를 가른다.

최소 baseline:

```text
B0: Age + sex + diagnosis logistic regression
B1: APOE-only logistic regression
B2: Age + sex + APOE logistic regression
B3: T1w-only 3D CNN/ViT
B4: T1w + APOE late fusion
B5: Binary supervised contrastive learning
B6: Proposed soft/continuous contrastive learning
```

핵심 비교:

```text
Proposed > Binary SupCon?
Proposed > T1w + APOE BCE?
Proposed > APOE-only?
Proposed external validation에서 유지?
```

만약 proposed가 internal test에서만 좋고 external cohort에서 무너지면 연구 가치가 약하다.

---

## 11. Evaluation Design

### 11.1 Primary Evaluation

External cohort validation을 primary로 둬야 한다.

예시:

```text
Train: AJU + KDRC
Test: NACC
```

또는:

```text
Train: NACC + AJU
Test: KDRC
```

### 11.2 Binary Metrics

```text
AUROC
AUPRC
balanced accuracy
sensitivity/specificity at fixed threshold
calibration slope/intercept
ECE
```

### 11.3 Continuous Metrics

Continuous target이 있는 subset에서:

```text
MAE
Spearman correlation
R²
```

### 11.4 Representation Diagnostics

```text
embedding vs amyloid burden correlation
embedding neighborhood purity
cohort separability test
linear probe performance
```

중요 sanity check:

```text
Can a classifier predict cohort from the learned embedding?
```

만약 cohort prediction이 너무 잘 되면 latent가 disease보다 site/cohort를 품고 있을 가능성이 크다.

---

## 12. 추천 제목 후보

### 후보 1: 가장 정직한 method-oriented title

```text
Amyloid-Burden-Aware Contrastive Learning for APOE-Informed Prediction from 3D Structural Brain MRI
```

### 후보 2: cross-cohort 강조

```text
Continuous Amyloid-Supervised Representation Learning for Cross-Cohort Prediction from 3D T1w MRI and APOE
```

### 후보 3: 과학 질문 중심, 가장 추천

```text
Does Structural MRI Add Predictive Signal Beyond APOE?
Continuous Amyloid-Guided Contrastive Learning Across Brain Aging Cohorts
```

후보 3이 가장 날카롭다. 방법론보다 검증 가능한 과학 질문을 앞세우기 때문이다.

---

## 13. 최종 Recommended Framing

```text
Working title:
Does Structural MRI Add Predictive Signal Beyond APOE?
Continuous Amyloid-Guided Contrastive Learning Across Brain Aging Cohorts

Core hypothesis:
A T1w MRI encoder trained with continuous amyloid-burden-aware soft contrastive learning
will learn representations that improve amyloid PET positivity prediction
beyond APOE genotype and clinical covariates,
especially under cross-cohort external validation.

Main data:
AJU + KDRC + NACC

Primary target:
amyloid PET positivity

Auxiliary target:
centiloid/SUVR where available

Primary comparison:
Proposed continuous soft contrastive learning
vs binary supervised contrastive learning
vs T1w+APOE BCE
vs APOE-only/clinical-only baselines

Critical test:
external cohort validation and incremental value over APOE.
```

---

## 14. Current Data Reality Guardrails

현재 verified 기준:

```text
Main plausible cohorts:
  AJU + KDRC + NACC

Likely usable scale for T1w + APOE + amyloid PET +/-:
  ~2,676 T1w rows
  ~2,260 subjects

Subject-level class:
  amyloid negative: ~1,343
  amyloid positive: ~917
  positive rate: ~40.6%
```

Cohort-specific caveats:

```text
AJU:
  binary amyloid normal/abnormal label verified
  APOE genotype verified
  continuous SUVR/centiloid not yet verified as common target

KDRC:
  visual PET positive/negative verified
  SUVR available
  APOE genotype verified

NACC:
  AMYLOID_STATUS verified
  CENTILOIDS available
  APOE ε4 count available
  a small number of amyloid-status conflict subjects must be excluded/handled

AIBL:
  T1w + APOE exists
  amyloid +/- label not yet verified locally

ADNI:
  large T1w source exists
  local APOE not yet verified in current raw subset

OASIS:
  T1w/PET-related data exist
  APOE not verified locally

UK Biobank:
  not present in current B200 local raw path
```

---

## 15. Final Verdict

좋은 씨앗이다. 하지만 현재 framing은 껍질에 fancy 용어가 너무 많다.

안전한 수정 방향:

```text
Trajectory라고 과장하지 말 것.
Continuous amyloid burden-aware representation으로 좁힐 것.
APOE/Age/SUVR를 하나의 거리공간에 단순히 섞지 말 것.
핵심 claim은 T1w가 APOE와 clinical covariates를 넘어서는 incremental signal을 주는가로 잡을 것.
```

감자식 한 줄:

```text
좋은 씨앗인데, 지금은 fancy 용어가 너무 많다.
껍질 벗기고 “APOE를 넘는 T1w의 cross-cohort incremental value”로 가면 훨씬 강해진다.
```
