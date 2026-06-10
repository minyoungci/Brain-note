# 직접 읽어야 하는 핵심 문헌 우선순위

Created UTC: `2026-05-18`
Workspace: `/home/vlm/minyoungi/literature`

## 결론

지금 Min이 먼저 원문으로 읽어야 할 문헌은 **MRI→amyloid/PET/ATN prediction**, **cross-cohort generalization**, **structural MRI disease-axis baseline**, **ADNI/OASIS/NACC/AIBL protocol anchor** 순서다.

우리 연구 framing은 아직 다음처럼 제한하는 것이 가장 안전하다.

> T1w MRI가 PET을 대체한다가 아니라, sparse expensive PET/ATN endpoint를 privileged supervision/validation으로 써서 T1w representation이 non-image shortcut과 cohort shift를 얼마나 넘어서는지 검증한다.

## Tier 0 — 오늘/내일 바로 정독

### 1. Deep Learning-Based Prediction of PET Amyloid Status Using MRI

- Queue: `B1`
- PMID: `40579043`
- DOI: `10.3174/ajnr.A8899`
- Venue/year: *AJNR*, 2025; arXiv record in graph: `2411.12061`
- Direct relevance: T1w MRI 또는 T1w+FLAIR로 PET amyloid positivity를 예측하는 가장 직접적인 competitor/benchmark.
- Confirmed key facts:
  - Development: `4056 examinations`
  - External Stanford test: `149 examinations`
  - Public datasets: ADNI, OASIS3, A4
  - Endpoint: dataset-specific recommended Centiloid threshold 기반 amyloid positivity
  - T1w-only: AUC `0.61`, accuracy `0.59`
  - T1w+FLAIR: internal AUC `0.67`, accuracy `0.63`; external AUC `0.65`, accuracy `0.62`
  - MCI subgroup: AUC `0.71`
- 읽으면서 뽑을 것:
  - train/validation/test split이 subject-level인지 exam-level인지
  - 각 cohort별 row/subject count와 amyloid threshold
  - T1w-only preprocessing, FLAIR 추가 효과, EfficientNet input construction
  - external Stanford cohort selection and failure cases
  - covariate-only/clinical baseline 유무
- 우리에게 주는 압박:
  - T1w-only PET signal은 real but modest. 우리 모델이 covariate/diagnosis/ROI baseline을 못 이기면 main claim 불가.

### 2. MRI-based Deep Learning Assessment of Amyloid, Tau, and Neurodegeneration Biomarker Status across the Alzheimer Disease Spectrum

- Queue: `B2`
- PMID: `37815445`
- PMCID: `PMC10623183`
- DOI: `10.1148/radiol.222441`
- Venue/year: *Radiology*, 2023
- Direct relevance: PET-defined ATN status를 MRI+diagnostic data로 예측하는 strong benchmark.
- Confirmed key facts:
  - MRI-PET within `30 days`
  - Pairs: amyloid `2099`, tau `557`, FDG/neurodegeneration `2768`
  - Split: random `70/10/20`
  - Test AUC: amyloid `0.79`, tau `0.73`, neurodegeneration `0.86`
  - Predictors include MRI CNN features + demographics/APOE/cognitive scores/hippocampal volumes/diagnosis.
- 읽으면서 뽑을 것:
  - MRI-only contribution vs clinical/diagnostic contribution
  - APOE/cognition/hippocampus/diagnosis coefficients and ablation
  - PET thresholding method and leakage risk
  - whether split is subject-disjoint
- 우리에게 주는 압박:
  - imaging-specific value를 분리하지 않으면 reviewer가 “clinical shortcut”이라고 볼 가능성이 큼.

### 3. Cross-cohort generalizability of deep and conventional machine learning for MRI-based diagnosis and prediction of Alzheimer's disease

- Queue: `C2`
- PMID: `34118592`
- PMCID: `PMC8203808`
- DOI: `10.1016/j.nicl.2021.102712`
- Venue/year: *NeuroImage: Clinical*, 2021
- Direct relevance: ADNI-trained MRI model이 external cohort에서 얼마나 generalize되는지에 대한 reviewer-risk anchor.
- Confirmed key facts:
  - ADNI baseline: AD about `336`, CN `520`, MCI converters `231`, MCI non-converters `628`
  - Compared SVM vs CNN; minimally processed T1w vs modulated GM maps
  - ADNI AD-vs-CN AUC: SVM GM `0.940`, SVM T1w `0.801`, CNN GM `0.933`, CNN T1w `0.898`
  - External PND에서 AD-CN AUC drop 약 `0.04–0.07`; MCI prediction drop 약 `0.04–0.10`
- 읽으면서 뽑을 것:
  - exact external cohort inclusion/exclusion
  - preprocessing별 성능 차이
  - MCI conversion definition
  - random split vs external validation protocol
- 우리에게 주는 압박:
  - cohort/domain shift를 main evaluation 축으로 안 넣으면 novelty가 약함.

### 4. Using machine learning to quantify structural MRI neurodegeneration patterns of Alzheimer's disease into dementia score

- Queue: `C3`
- PMID: `32614505`
- PMCID: `PMC7469784`
- DOI: `10.1002/hbm.25115`
- Venue/year: *Human Brain Mapping*, 2020
- Direct relevance: multi-dataset structural MRI disease-axis score precedent. CN/AD disease-axis 자체는 novelty가 아님을 보여주는 baseline anchor.
- Confirmed key facts:
  - Training: stable NC `423`, stable DAT `330`
  - Independent validation: `8834` unseen images from ADNI, AIBL, OASIS, MIRIAD
  - Feature basis: structural MRI volume/FreeSurfer-derived ROI features
  - Reported pMCI vs sMCI AUC: `0.81` for 6-month TTC, `0.73` up to 7 years
- 읽으면서 뽑을 것:
  - MRDATS feature construction and score calibration
  - cohort-specific test performance
  - MCI conversion windows and failure cases
  - CSF/PET correlation analyses
- 우리에게 주는 압박:
  - disease-axis score는 strong baseline으로 넣어야 함. PET/amyloid transfer 또는 cohort-shift robustness 없으면 새로움 부족.

### 5. Design and validation of the ADNI MR protocol

- Queue: `A2`
- PMID: `39115941`
- PMCID: `PMC11497751`
- DOI: `10.1002/alz.14162`
- Venue/year: *Alzheimer's & Dementia*, 2024
- Direct relevance: ADNI4 MR protocol and longitudinal compatibility/harmonization anchor.
- Confirmed key facts:
  - ADNI4 includes nine MRI sequences.
  - Main changes include compressed-sensing T1w, 1mm isotropic 3D FLAIR, pCASL across vendors, multi-PLD ASL, CS 3D T2w.
  - Protocol aims to maintain longitudinal consistency while adopting newer technologies.
- 읽으면서 뽑을 것:
  - T1w MP-RAGE/vendor-specific protocol constraints
  - FLAIR/ASL/T2 availability implications
  - longitudinal comparability caveats
  - scanner/site harmonization claims that affect our multi-cohort framing

## Tier 1 — 이번 주 full review

### 6. The Alzheimer's Disease Neuroimaging Initiative (ADNI): MRI methods

- Queue: `A1`
- PMID: `18302232`
- PMCID: `PMC2544629`
- DOI: `10.1002/jmri.21049`
- Why: ADNI MRI acquisition/preprocessing original protocol anchor. ADNI-derived T1w 연구와 비교하려면 먼저 알아야 함.

### 7. Structural MRI and Amyloid PET Imaging for Prediction of Conversion to Alzheimer's Disease in MCI: A Meta-Analysis

- Queue: `C1`
- PMID: `28326120`
- PMCID: `PMC5355020`
- DOI: `10.4306/pi.2017.14.2.205`
- Why: MCI conversion에서 structural MRI vs amyloid PET의 오래된 effect-size context.
- Key extracted fact: 24 MRI studies and 8 amyloid PET studies; 674/1741 progressed to AD; amyloid PET effect stronger than MRI in selected studies.

### 8. Multimodal integration of plasma biomarkers, MRI, and genetic risk to predict cerebral amyloid burden in Alzheimer's disease

- Queue: `B3`
- PMID: `41135743`
- DOI: `10.1016/j.neuroimage.2025.121550`
- Venue/year: *NeuroImage*, 2025
- Why: plasma/genetics/clinical markers may be stronger shortcut baselines for amyloid burden. If available biomarkers beat imaging easily, our claim must be imaging-specific and sparse-deployment focused.

### 9. OASIS-3 dataset paper / official documentation

- Queue: `A3`
- Current status: exact canonical paper/DOI still needs lookup.
- Why: OASIS3 is a direct external/cohort-shift comparator for MRI/PET/clinical longitudinal work.
- 읽을 때 target:
  - MRI/PET availability
  - clinical diagnosis semantics
  - longitudinal visit structure
  - amyloid/FDG/SUVR/centiloid documentation

### 10. NACC UDS/MRI/neuropathology documentation

- Queue: `A4`
- Current status: representative official docs and imaging papers still need lookup.
- Why: NACC is not ADNI-like; clinical ascertainment, MRI availability, and pathology labels differ. Shortcut/domain-shift analysis에 필수.

### 11. AIBL cohort / amyloid PET / MRI documentation

- Queue: `A5`
- Current status: dataset/protocol document full review needed.
- Why: AIBL is useful as amyloid-rich comparator/external validation. PET tracer, centiloid/SUVR semantics, MRI compatibility 확인 필요.

## Tier 2 — baseline/caution only; 정독보다 abstract+methods screen

### 12. Multi-scale multimodal deep learning framework for Alzheimer's disease diagnosis

- PMID: `39579666`
- DOI: `10.1016/j.compbiomed.2024.109438`
- Why: recent MRI/PET diagnosis fusion baseline. 단, diagnosis-only fusion은 saturated라 main novelty anchor로 쓰면 위험.

### 13. An Effective Multimodal Image Fusion Method Using MRI and PET for Alzheimer's Disease Diagnosis

- Queue: `D1`
- PMID: `34713109`
- PMCID: `PMC8521941`
- DOI: `10.3389/fdgth.2021.637386`
- Why: ADNI MRI/PET fusion diagnosis baseline/caution.
- Key extracted fact: ADNI `381 subjects`, 10-fold setup, high AD-vs-NC/MCI-vs-NC accuracy. Reviewer에게 “그런 류 연구는 이미 많다”는 근거가 됨.

### 14. Predicting the progression of MCI and Alzheimer's disease on structural brain integrity and other features with machine learning

- Queue: `C4`
- PMID: `40285975`
- PMCID: `PMC12972442`
- DOI: `10.1007/s11357-025-01626-5`
- Why: recent structural MRI + features progression paper. Full review 전에는 claim anchor보다 baseline/feature list 확인용.

## 읽기 순서

1. B1 AJNR 2025 — direct competitor. 먼저 읽고 우리 task의 성능 ceiling/claim limit을 정한다.
2. B2 Radiology 2023 — ATN benchmark. clinical shortcut baseline을 어떻게 분리해야 하는지 본다.
3. C2 NeuroImage: Clinical 2021 — cross-cohort protocol. split/evaluation 설계에 반영한다.
4. C3 Human Brain Mapping 2020 — disease-axis baseline. 우리 baseline list에 넣는다.
5. A2/A1 ADNI protocol — preprocessing/harmonization caveat를 정리한다.
6. C1/B3 — MCI/PET effect-size와 plasma/genetic shortcut baseline을 확인한다.
7. OASIS/NACC/AIBL docs — external cohort label semantics를 확정한다.
8. D1/D2/C4 — saturated baseline/caution으로만 정리한다.

## 원문 review extraction template

각 논문 정독 후 아래 블록을 채운다.

```yaml
title:
pmid_doi_url:
venue_year:
dataset:
sample_count:
modality_input:
pet_or_biomarker_endpoint:
unit_of_analysis:
split_subject_disjoint:
external_validation:
metrics:
baselines:
ablation_mri_only_vs_covariate:
main_result:
limitations:
shortcut_or_leakage_risk:
relevance_to_our_data:
claim_strength_for_us:
exact_quotes_or_tables_to_capture:
review_status:
```

## 다음 작업

- `B1`, `B2`, `C2`, `C3`, `A2`부터 full-text table extraction을 시작한다.
- 특히 `split_subject_disjoint`, `external_validation`, `covariate-only baseline`, `MCI-only`, `MRI-PET interval`, `threshold definition`을 놓치면 안 된다.
