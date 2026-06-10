# VLM 연구 가능성 판단: PET 예측을 넘는 데이터 구성

Created UTC: `2026-05-18`
Workspace: `/home/vlm/minyoungi/literature`

## 한 줄 결론

가능하다. 단, 현재 데이터는 **의사 판독문이 붙은 전형적 radiology VLM dataset**이라기보다, **3D MRI/PET + 구조화 임상/tabular metadata를 자연어 caption/report로 변환해 학습하는 neuroimaging VLM/MLLM dataset**에 가깝다.

즉 좋은 framing은 다음이다.

> T1w/FLAIR/DTI/PET 같은 brain image와 diagnosis, CDR/CDR-SB, age/sex, scanner, longitudinal visit, amyloid/PET endpoint를 language-supervised representation으로 묶어 치매 진행·biomarker·cohort shift를 설명/예측하는 VLM.

## 왜 VLM이 가능하다고 보는가

### 1. 이미지 쪽은 충분히 크다

현재 canonical reingest manifest 기준:

- Source: `/home/vlm/data/metadata/reingest_minyoung4/experiment_manifest_v7.csv`
- CN/MCI/AD + classifiable rows: `10,806`
- 전 row에서 `has_t1w=True`, `has_seg=True`, `has_mask=True`, `complete=True`
- 컨소시엄별 rows:
  - ADNI: `5,037`
  - NACC: `1,876`
  - OASIS: `1,615`
  - AJU: `1,287`
  - AIBL: `991`

이 정도면 3D MRI foundation-level pretraining은 아니어도, **domain-specific contrastive/fusion VLM fine-tuning**에는 현실적인 크기다.

### 2. 텍스트 대신 쓸 수 있는 구조화 임상 정보가 있다

현재 manifest에 이미 다음 필드가 있다.

- diagnosis
- CDR global
- CDR-SB
- age
- sex
- scanner
- field strength
- visit/scan_date 일부

CN/MCI/AD classifiable 10,806 rows 중 non-missing count:

- age: `10,632`
- sex: `10,806`
- cdr_global: `10,349`
- cdrsb: `9,607`
- scanner: `10,389`
- field_strength: `10,520`

따라서 직접 판독문은 없어도 다음과 같은 natural-language caption을 만들 수 있다.

```text
A 73-year-old female participant from ADNI with T1-weighted MRI, CDR global 0.5, CDR-SB 2.0, diagnosed as MCI, scanned on a 3T scanner.
```

이건 chest X-ray report VLM과는 다르지만, Alzheimer neuroimaging VLM 문헌에서 이미 쓰는 방향과 맞다.

### 3. longitudinal captioning이 가능하다

subject/session count 기준으로 longitudinal signal도 있다.

- ADNI: subjects `1,754`, multi-session subjects `870`, max sessions `16`
- OASIS: subjects `750`, multi-session subjects `404`, max sessions `8`
- NACC: subjects `1,420`, multi-session subjects `365`, max sessions `4`
- AJU: subjects `1,001`, multi-session subjects `286`, max sessions `2`
- AIBL: subjects `618`, multi-session subjects `178`, max sessions `5`

따라서 단순 이미지-라벨 분류보다 더 VLM다운 task가 가능하다.

예:

- baseline MRI + text prompt → future diagnosis/CDR-SB prediction
- visit sequence → progression summary generation
- image-text retrieval: “MCI with high CDR-SB and hippocampal atrophy-like profile”에 맞는 case retrieval
- image-conditioned structured report generation
- missing modality imputation / PET endpoint explanation

### 4. Korean AJU/KDRC multimodal extension이 차별점이 될 수 있다

기존 note `2026-05-18_six_consortium_modality_status.md` 기준 raw multimodal potential:

- AJU: T1w + PET + FLAIR + DTI/DWI + T2/GRE + fMRI-like raw holdings
- KDRC: T1w + PET + FLAIR + T2 + DTI NIfTI holdings
- OASIS: T1w + PET + DWI + fMRI/BOLD + metadata
- ADNI: T1w + PET + FLAIR + fMRI/rest + rich metadata

특히 KDRC는 path-valid PET NIfTI가 QC-pass T1w와 `552` rows / `552` subjects로 연결된 상태라, **PET을 privileged supervision 또는 VLM의 biomarker text endpoint**로 쓰기 좋다.

## 단, “VLM”이라고 부르려면 조심해야 할 점

### 1. 진짜 radiology report pair가 없다

현재 데이터는 대부분 structured clinical table + imaging이다. 따라서 다음 표현은 위험하다.

- “radiology report VLM”
- “clinical free-text report generation”
- “report-grounded diagnosis”

더 안전한 표현:

- structured-caption supervised VLM
- tabular-to-text neuroimaging VLM
- language-supervised 3D MRI representation learning
- image-text retrieval over clinical state descriptions
- PET/ATN-aware multimodal representation learning

### 2. synthetic caption은 label leakage 위험이 있다

caption에 `diagnosis=MCI`를 넣고 diagnosis를 맞히면 trivial leakage다. 따라서 task별로 caption field를 엄격히 나눠야 한다.

예:

- diagnosis prediction task에서는 caption에서 diagnosis 제거
- CDR-SB prediction task에서는 caption에서 CDR-SB 제거
- amyloid prediction task에서는 amyloid/PET status 제거
- retrieval task에서는 caption을 supervision으로 쓰되 downstream test prompt와 label leakage를 분리

### 3. 2D VLM 그대로 쓰면 3D MRI 정보 손실이 크다

가능한 선택지:

1. Slice-based 2D CLIP/BiomedCLIP fine-tuning
   - 빠르고 구현 쉬움
   - representative slice selection 필요
   - 3D pathology를 놓칠 수 있음

2. 3D encoder + text encoder contrastive learning
   - 연구적으로 더 맞음
   - 구현/메모리/QC 부담 큼

3. ROI/segmentation feature + text encoder fusion
   - 가장 안정적인 baseline
   - VLM novelty는 약하지만 leakage/control 확인에 좋음

추천은 `ROI/tabular-text baseline → 2D slice VLM smoke → 3D encoder VLM` 순서다.

## PET 예측보다 더 좋은 VLM task 후보

### Task A. Image-text retrieval / representation learning

질문:

> MRI embedding이 clinical state caption과 잘 정렬되는가?

입력:

- T1w 또는 T1w+FLAIR/DTI/PET
- age/sex/CDR/CDR-SB/diagnosis/scanner를 조합한 caption

평가:

- image→text retrieval Recall@K
- text→image retrieval Recall@K
- held-out cohort retrieval
- diagnosis/CDR/PET linear probe

장점:

- VLM다운 task
- label 하나 맞히기보다 representation claim이 자연스러움

위험:

- caption template가 너무 쉬우면 scanner/dataset shortcut을 배울 수 있음

### Task B. Longitudinal progression VLM

질문:

> baseline image와 clinical text가 future CDR-SB/diagnosis conversion을 설명하는 language-supervised representation을 만드는가?

예:

```text
Given baseline T1w MRI and age/sex/CDR, predict whether this subject progresses from MCI to AD within N years.
```

장점:

- Min의 VLM/MLLM 기반 치매 진행·임상상태 예측 방향과 잘 맞음
- PET 단일 endpoint보다 clinical relevance가 큼

필수 baseline:

- clinical-only
- ROI-only
- T1w-only
- image+clinical fusion
- language-supervised image+text

### Task C. PET/ATN-aware VLM

질문:

> PET/ATN endpoint를 expensive privileged label로 사용해 MRI-text representation을 정렬하면, PET 없는 cohort에서도 biomarker-related representation이 유지되는가?

장점:

- PET 예측만 하는 것보다 framing이 넓다
- KDRC/OASIS PET path-valid와 ADNI/AIBL PET metadata를 활용 가능

주의:

- PET image 자체를 input에 넣고 PET status를 맞히면 task가 trivial해질 수 있음
- PET은 supervision/validation endpoint로 두는 것이 더 안전함

### Task D. Case retrieval / cohort-shift audit assistant

질문:

> 자연어 query로 유사한 neurodegeneration pattern/case를 검색할 수 있는가?

예:

```text
Retrieve older MCI subjects with high CDR-SB, low hippocampal volume-like morphology, and amyloid-positive PET if available.
```

장점:

- 실제 연구 보조/데이터 탐색 도구로 유용
- 논문 task로는 retrieval benchmark가 필요

## 내 판단

### 가능성: 높음

VLM을 할 수 있는 데이터 구성은 맞다. 특히 **MRI + 구조화 임상정보 + longitudinal labels + PET/amyloid endpoint 일부 + multi-cohort domain shift** 조합은 꽤 좋다.

### 하지만 이름은 조심해야 한다

처음부터 “large VLM” 또는 “radiology report VLM”으로 가면 공격받기 쉽다. 더 안전한 시작점은:

> language-supervised multimodal neuroimaging representation learning for dementia progression and PET/ATN-aware validation

한국어:

> 치매 진행 및 PET/ATN 검증을 위한 언어지도 멀티모달 뇌영상 표현학습

### 가장 좋은 연구 framing

> Can structured clinical language supervise 3D MRI representations that generalize across dementia cohorts and align with expensive PET/ATN biomarkers?

한국어:

> 구조화 임상 정보를 자연어 supervision으로 바꿔 학습한 3D MRI 표현이 치매 cohort 간 일반화되고, 고비용 PET/ATN biomarker와 정렬되는가?

## 바로 읽어야 할 VLM 관련 문헌 후보

아래는 direct reading queue에 추가 후보로 봐야 한다.

1. `A vision–language foundation model for Alzheimer's disease diagnosis` / AD-specific VLM, 3D MRI T1 + multimodal clinical information.
2. `Leveraging Multimodal Models for Enhanced Neuroimaging Diagnostics in Alzheimer’s Disease` / OASIS-4 structured data로 synthetic diagnostic report를 만들어 BiomedCLIP+T5 학습.
3. `NeuroVLM: A Contrastive Vision-Language Model for Medical Reasoning in Alzheimer's Disease` / ADNI T1 MRI + structured clinical captions 기반 retrieval VLM.
4. `Enhancing vision-language models for medical imaging` / BrainMD, representative slice selection, 3D volume을 2D VLM에 넣을 때의 방법론.
5. `Vision-language foundation model for 3D medical imaging` review / 3D medical VLM architecture와 evaluation caveat.

## 추천 next action

1. `VLM-ready manifest`를 따로 만든다.
   - image path
   - subject/session
   - diagnosis/CDR/CDR-SB/age/sex/scanner
   - longitudinal next-visit label
   - PET/amyloid availability flag
   - forbidden/leakage fields per task

2. caption template 3종을 만든다.
   - non-leaky demographic caption
   - clinical-state caption
   - biomarker-supervision caption

3. baseline부터 한다.
   - clinical/tabular-only
   - ROI-only
   - image-only
   - image+tabular fusion
   - image+text contrastive/fusion

4. VLM claim gate를 둔다.
   - random split 성능이 아니라 cohort-held-out에서 유의미해야 함
   - clinical-only보다 좋아야 함
   - caption leakage 제거 후에도 유지되어야 함
   - scanner/dataset prediction shortcut을 audit해야 함
