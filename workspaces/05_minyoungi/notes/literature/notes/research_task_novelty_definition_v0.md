# 연구 구체화 초안: 문헌 리뷰 기반 Task / Novelty / Claim Gate

Created: 2026-05-16

Source evidence:
- `reports/manual_review_anchor_synthesis.md`
- `registry/pmc_fulltext_snippets.md`
- `registry/expanded_literature_graph.md`
- `data/external_index/20260516/expanded_literature_graph.csv`

## 1. Bottom line

현재 문헌 근거와 우리 데이터 현실을 합치면, 가장 방어 가능한 연구 정의는 다음이다.

> **PET-privileged, sparse-modality structural T1w MRI representation learning for amyloid/centiloid risk transfer under multi-cohort domain shift.**

한국어로 풀면: **PET이 비싸고 sparse하게만 존재하는 상황에서, 대규모 T1w MRI를 주 입력으로 사용하고 PET-derived amyloid/centiloid를 privileged supervision/검증 endpoint로 삼아, cohort/domain shift에서도 유효한 AD-biomarker representation을 학습하는 연구**다.

하지 말아야 할 framing:
- “T1w MRI로 PET을 대체한다.” → 선행연구 성능이 modest하고 임상적으로 과장 위험이 큼.
- “새로운 AD/MCI/CN classifier.” → saturated하고 reviewer novelty가 약함.
- “MRI/PET multimodal fusion diagnosis SOTA.” → ADNI-only/random split류 선행연구가 많고 task 자체가 약함.
- “JEPA/SSL 자체가 novelty.” → prior negative/weak evidence와 task mismatch 위험이 큼. Objective는 수단이어야 함.

## 2. 최신 문헌에서 보이는 task trend

### Trend A — T1w 또는 multi-contrast MRI로 amyloid PET status 예측
- Direct anchor: AJNR 2025 `Deep Learning-Based Prediction of PET Amyloid Status Using MRI`.
- 확인된 핵심 수치: development `4056 examinations`, external Stanford `149 examinations`, T1w-only AUC 약 `0.61`, T1w+FLAIR AUC 약 `0.67`, external AUC 약 `0.65`, MCI subgroup AUC 약 `0.71`.
- 해석: T1w-only signal은 존재하지만 약함. FLAIR 또는 clinical/tabular를 추가하면 개선될 가능성이 큼.
- 우리에게 주는 압박: T1w-only 성능이 covariate-only/disease-axis baseline보다 약하면 main claim 불가.

### Trend B — MRI + clinical/diagnostic data로 ATN biomarker prediction
- Direct anchor: Radiology 2023 `MRI-based Deep Learning Assessment of Amyloid, Tau, and Neurodegeneration Biomarker Status...`.
- 확인된 수치: amyloid PET/MRI pairs `2099`, tau `557`, FDG `2768`, split `70/10/20`, AUC amyloid `0.79`, tau `0.73`, neurodegeneration `0.86`.
- 해석: 성능은 높지만 MRI-only가 아니라 diagnostic/clinical data가 섞일 수 있음.
- 우리에게 주는 압박: imaging-only, covariate-only, imaging+covariate contribution을 반드시 분리해야 함.

### Trend C — Missing modality / any-modality multimodal learning
- MICCAI/MIDL류 최신 흐름은 모든 modality가 완비된 이상적 fusion보다, 일부 modality가 빠지는 현실적 setting을 다룸.
- 우리 데이터 구조와 잘 맞음: T1w는 상대적으로 많고 PET/centiloid/SUVR는 subset이며 cohort별 modality availability가 다름.
- 단, 우리의 novelty는 generic missing-modality network가 아니라 **PET을 privileged sparse target으로 쓰는 dementia-specific domain-shift benchmark + representation objective**여야 함.

### Trend D — Multi-cohort/domain generalization
- NeuroImage: Clinical 2021 cross-cohort paper는 ADNI 내부 성능이 external cohort에서 떨어지는 것을 보여줌.
- 확인된 anchor: ADNI AD `336`, CN `520`, MCI converters `231`, non-converters `628`; external PND에서 AUC drop 약 `0.04–0.10`.
- 우리 강점: ADNI/OASIS/NACC/AIBL/Korean domain을 평가축으로 만들 수 있음.
- 위험: label semantics, PET endpoint, scanner/site/preprocessing 차이를 통제하지 않으면 오히려 shortcut benchmark가 됨.

## 3. 우리 데이터와의 직접 비교

Observed/known workspace basis:
- Tier 1: 대규모 T1w MRI inventory/pretraining pool. Memory 기준 V7 inventory는 약 `10,834 rows / 5,565 subjects`; path-valid basis는 workspace 상태에 따라 재확인 필요.
- Tier 4/5: PET-derived endpoint subset. 이전 audit 기준 ADNI/OASIS/NACC quantitative PET + Korean SUVR/AJU/KDRC readiness가 존재하지만, label semantics와 path validity를 다시 audit해야 함.
- Longitudinal: 6–60 month T1w pair pool은 가능하지만 progression event가 작고, 이전 JEPA/temporal objective는 static diagnosis claim에는 약했음.
- Korean target: AJU+KDRC는 external/domain-shift 가치가 크지만, AJU `Amy_opi` semantics와 KDRC SUVR/reading endpoint contract를 다시 확인해야 함.

우리 데이터가 선행연구보다 강할 수 있는 지점:
- multi-cohort/domain-shift evaluation을 처음부터 설계할 수 있음.
- T1w-only deployment + PET privileged supervision이라는 현실적 sparse expensive-modality setting을 만들 수 있음.
- MCI-only, close MRI-PET interval, centiloid ranking/residual 같은 harder claim gate를 둘 수 있음.
- Korean cohort를 final external biological/domain validation으로 사용할 수 있음.

우리 데이터가 약한 지점:
- FLAIR/tau/FDG/plasma/genetics 등 최신 multimodal 논문이 쓰는 추가 modality가 부족하거나 불균형할 수 있음.
- T1w-only amyloid binary prediction은 선행연구 기준 성능 ceiling이 높지 않을 가능성이 큼.
- PET observation은 MNAR일 가능성이 높음. PET이 찍힌 사람과 안 찍힌 사람이 무작위가 아닐 수 있음.
- Korean PET endpoint는 semantic/codebook 검증 없이는 label로 쓰면 위험함.

## 4. 후보 task ranking

### Rank 1 — Main task: T1w-only amyloid/centiloid representation transfer under sparse PET supervision

Computable definition:
- Input: T1w MRI only.
- Privileged supervision / target: PET-derived amyloid positivity, centiloid/SUVR continuous value, ordinal amyloid burden bins.
- Train/eval unit: subject-session image row; split unit: subject.
- Primary evaluation: internal test + leave-one-cohort-out or ADNI↔OASIS; Korean target as external if endpoint contract passes.
- Primary metrics: AUROC/AUPRC for amyloid positivity; Spearman/R2/MAE for centiloid/SUVR; pairwise ranking AUC for amyloid burden ordering.

Novelty hypothesis:

> Sparse PET supervision can shape T1w representations that transfer to amyloid/centiloid endpoints across cohorts better than diagnosis-trained disease-axis, ROI volumes, and non-image shortcut baselines.

This is plausible but not yet proven.

Required baselines:
- dummy / prevalence baseline
- age + sex
- age + sex + cohort/site/scanner
- diagnosis/disease-axis score where allowed as side baseline, not main input claim
- hippocampus/entorhinal/FreeSurfer ROI volume baseline
- supervised T1w CNN/ViT from scratch
- pretrained/frozen encoder variants if available

Claim gate:
- Must beat strongest non-image baseline on same rows/splits.
- Must report MCI-only and close-window subgroup.
- Must show external/cohort-shift robustness, not only random split.
- Must separate binary amyloid classification from continuous centiloid/SUVR ranking/regression.

### Rank 2 — Secondary task: Missing-modality robust PET-privileged learning

- Problem: PET/FLAIR/clinical availability is incomplete across cohorts.
- Input at deployment: T1w only; optional training-time PET/FLAIR/clinical side channels only as privileged/teacher/regularizer.
- Novelty: not generic fusion; focus on expensive biomarker-missing setting and domain-shift-safe T1w representation.
- Venue fit: MICCAI/MIDL more realistic than NeurIPS/ICLR main unless algorithm is made general and validated outside dementia.

### Rank 3 — Tertiary task: Longitudinal T1w disease-velocity representation validated by PET/progression

- Input: baseline/follow-up T1w pair, time gap.
- Target/probe: future amyloid/centiloid change if available, MCI stable vs worsening, AD-axis movement.
- Risk: event counts likely small; prior temporal objectives can learn identity/anatomy rather than disease velocity.
- Use only after Rank 1 establishes a meaningful PET/disease-axis endpoint.

### Deprioritized tasks

- AD/CN/MCI diagnosis-only classification.
- MRI/PET fusion diagnosis with random split only.
- PET image synthesis as main claim without clinical/PET quantitative validation.
- generic JEPA/MAE pretraining without PET/progression/domain-shift claim gate.

## 5. Candidate paper list requiring immediate full review

- `A_full_review_candidate` score `23` — Deep Learning–Based Prediction of PET Amyloid Status Using MRI (American Journal of Neuroradiology, 2024). DOI `10.3174/ajnr.A8899`; PMID `40579043`; reasons: amyloid/PET endpoint; centiloid quantitative endpoint; PET modality/endpoint; MRI modality; T1/T1w signal; AD/dementia domain; MCI subgroup/progression; external validation cue
- `B_screen_candidate` score `11` — Predicting Brain Amyloid Positivity from T1 weighted brain MRI and MRI-derived Gray Matter, White Matter and CSF maps using Transfer Learning on 3D CNNs* (bioRxiv (Cold Spring Harbor Laboratory), 2023). DOI `10.1101/2023.02.15.528705`; PMID `NA`; reasons: amyloid/PET endpoint; MRI modality; T1/T1w signal; AD/dementia domain
- `B_screen_candidate` score `11` — Hybrid MRI–tabular deep learning for predicting Alzheimer’s amyloid positivity with external validation and an explainable clinical framework (Results in Engineering, 2026). DOI `10.1016/j.rineng.2026.110627`; PMID `NA`; reasons: amyloid/PET endpoint; MRI modality; AD/dementia domain; external validation cue
- `B_screen_candidate` score `10` — Design and validation of the ADNI MR protocol (Alzheimer's & Dementia, 2024). DOI `10.1002/alz.14162`; PMID `39115941`; reasons: MRI modality; T1/T1w signal; AD/dementia domain; longitudinal cue
- `B_screen_candidate` score `10` — A Multi-Task Cross-Domain Deep Learning Model for Joint PET and MRI-Based Prediction of Alzheimer's Disease Progression (International Conferences on Information Science and System, 2026). DOI `10.1109/ICISS67859.2026.11454020`; PMID `NA`; reasons: PET modality/endpoint; MRI modality; AD/dementia domain; domain/generalization cue
- `C_background_candidate` score `9` — Alzheimer’s Disease Detection from Fused PET and MRI Modalities Using an Ensemble Classifier (Machine Learning and Knowledge Extraction, 2023). DOI `10.3390/make5020031`; PMID `NA`; reasons: PET modality/endpoint; MRI modality; AD/dementia domain; moderate citation count
- `C_background_candidate` score `9` — MRI-based Deep Learning Assessment of Amyloid, Tau, and Neurodegeneration Biomarker Status across the Alzheimer Disease Spectrum (Radiology, 2023). DOI `10.1148/radiol.222441`; PMID `NA`; reasons: amyloid/PET endpoint; MRI modality; AD/dementia domain
- `C_background_candidate` score `9` — Deep Learning-Based Prediction of PET Amyloid Status Using Multi-Contrast MRI (Proceedings on CD-ROM - International Society for Magnetic Resonance in Medicine. Scientific Meeting and Exhibition/Proceedings of the International Society for Magnetic Resonance in Medicine, Scientific Meeting and Exhibition, 2025). DOI `10.58530/2025/4222`; PMID `NA`; reasons: amyloid/PET endpoint; PET modality/endpoint; MRI modality
- `C_background_candidate` score `9` — Cross-Modal Knowledge Distillation for PET-Free Amyloid-Beta Detection from MRI (NA, 2026). DOI `NA`; PMID `NA`; reasons: amyloid/PET endpoint; PET modality/endpoint; MRI modality
- `C_background_candidate` score `9` — Erratum for: MRI-based Deep Learning Assessment of Amyloid, Tau, and Neurodegeneration Biomarker Status across the Alzheimer Disease Spectrum (Radiology, 2025). DOI `10.1148/radiol.259008`; PMID `NA`; reasons: amyloid/PET endpoint; MRI modality; AD/dementia domain
- `C_background_candidate` score `8` — Decoding Blood-Brain Barrier Dysfunction in Alzheimer's Disease: Innovations and Challenges in Multimodal MRI and PET Imaging Biomarkers. (Ageing Research Reviews, 2025). DOI `10.1016/j.arr.2025.102952`; PMID `41271114`; reasons: PET modality/endpoint; MRI modality; AD/dementia domain
- `C_background_candidate` score `7` — Estimation of brain amyloid accumulation using deep learning in clinical [11C]PiB PET imaging (EJNMMI Physics, 2023). DOI `10.1186/s40658-023-00562-7`; PMID `NA`; reasons: amyloid/PET endpoint; PET modality/endpoint
- `C_background_candidate` score `7` — Characterizing Amyloid Pathogenic Spread in Alzheimer’s Disease Through A Network Diffusion Model (ACM International Conference on Bioinformatics, Computational Biology and Biomedicine, 2025). DOI `10.1145/3765612.3767223`; PMID `41488126`; reasons: amyloid/PET endpoint; AD/dementia domain
- `C_background_candidate` score `7` — Time-saved and time-invested with anti-amyloid treatments in early Alzheimer's disease: practical considerations. (Journal of clinical neuroscience, 2025). DOI `10.1016/j.jocn.2025.111584`; PMID `40865297`; reasons: amyloid/PET endpoint; AD/dementia domain
- `C_background_candidate` score `7` — Neuro-Anatomy Guided Deep Learning for Early Alzheimer’s Disease and Mild Cognitive Impairment Classification using Structural MRI (International Congress on Information and Communication Technology, 2026). DOI `10.1109/ICICT68280.2026.11511124`; PMID `NA`; reasons: MRI modality; AD/dementia domain; MCI subgroup/progression
- `C_background_candidate` score `6` — Recent advances in Alzheimer’s disease: mechanisms, clinical trials and new drug development strategies (Signal Transduction and Targeted Therapy, 2024). DOI `10.1038/s41392-024-01911-3`; PMID `NA`; reasons: AD/dementia domain; high citation count
- `C_background_candidate` score `6` — Gut microbiome composition may be an indicator of preclinical Alzheimer’s disease (Science Translational Medicine, 2023). DOI `10.1126/scitranslmed.abo2984`; PMID `NA`; reasons: AD/dementia domain; high citation count
- `C_background_candidate` score `6` — Biomarker-based staging of Alzheimer disease: rationale and clinical applications (Nature Reviews Neurology, 2024). DOI `10.1038/s41582-024-00942-2`; PMID `NA`; reasons: AD/dementia domain; high citation count

## 6. Provisional novelty statement

Defensible version:

> We study structural T1w MRI representation learning in a sparse expensive-biomarker regime, using amyloid PET/centiloid/SUVR as privileged supervision and biological validation, and evaluate whether the learned representation adds imaging-specific value beyond demographic/cohort/diagnosis/ROI shortcuts under multi-cohort domain shift.

Not defensible yet:
- “We achieve SOTA amyloid prediction.” → not before full benchmark.
- “T1w replaces PET.” → clinically overclaimed.
- “Longitudinal SSL learns disease progression.” → not before velocity/progression/PET-change evidence.
- “Novel MRI/PET fusion model.” → saturated and not aligned with sparse deployment reality.

## 7. Experiments implied by literature review

Phase 0 — data contract audit:
- Build/verify manifest with columns: `subject_id`, `session_id`, `cohort`, `t1w_path`, `pet_endpoint_type`, `amyloid_positive`, `centiloid_or_suvr`, `mri_pet_delta_days`, `age`, `sex`, `diagnosis`, `scanner/site` if available.
- Verify path existence and subject-level split disjointness.
- Audit PET missingness by cohort/diagnosis/age/sex.

Phase 1 — non-image and ROI baseline gate:
- Covariate-only: age/sex/cohort/site/diagnosis variants.
- ROI-only: hippocampus/entorhinal/ventricle/global atrophy if available.
- Disease-axis score baseline if existing CN/AD encoder or structural score is available.

Phase 2 — T1w imaging baseline:
- Supervised T1w CNN/ViT for amyloid binary + centiloid/SUVR regression.
- Frozen representation probes from existing encoders if any.
- Same split as Phase 1.

Phase 3 — PET-privileged representation:
- Multi-task binary + continuous + ordinal/ranking PET endpoint.
- Optional teacher/privileged loss using PET endpoint but T1w-only inference.
- Domain adversarial or leave-one-cohort validation only after baseline gate passes.

Phase 4 — longitudinal extension:
- Evaluate whether baseline-to-follow-up T1w change improves PET/progression endpoints beyond static baseline.
- Include random-pair/shuffled-time controls.

## 8. Immediate next action

Do not start GPU modeling yet. Next step is to build the **data-task feasibility table** for Rank 1 using live manifests: row counts, subjects, cohort distribution, endpoint availability, path validity, and split feasibility. If Rank 1 lacks enough clean PET labels or MCI/close-window rows, downgrade the task before coding.
