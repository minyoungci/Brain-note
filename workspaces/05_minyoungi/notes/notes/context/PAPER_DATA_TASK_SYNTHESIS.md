# PAPER_DATA_TASK_SYNTHESIS — VLM 문헌 × 보유 데이터 비교

Updated: 2026-05-19
Workspace: `/home/vlm/minyoungi`

## 결론

현재 보유 데이터와 선행 VLM 문헌을 비교하면, 우리가 바로 정해야 할 main task는 PET 단일 예측이 아니라 다음이다.

> **ROI-grounded structured clinical language supervision for 3D dementia MRI representation learning, evaluated by leakage-controlled retrieval, cohort-held-out probes, longitudinal clinical-state prediction, and PET/ATN-aware validation.**

한국어:

> **ROI/segmentation으로 시각적 근거를 둔 3D 치매 MRI 표현을 구조화 임상 언어로 학습하고, retrieval·cohort-held-out probe·longitudinal 임상상태 예측·PET/ATN 정렬로 검증하는 VLM 연구.**

## 1. 선행 문헌에서 이미 된 것

### ADLIP — Alzheimer’s & Dementia 2025

- Paper: *A vision–language foundation model for Alzheimer's disease diagnosis using MRI and clinical data*
- PMID: `41457461`
- DOI: `10.1002/alz.71029`
- Data reported in extracted summary:
  - ADNI + HABS-HD.
  - ADNI subset: `841 participants`, `3396 longitudinal MRI scans`.
  - Uses `3D T1-weighted MRI` + structured clinical records/cognitive/functional/genetic/biomarker information.
- Tasks/claims:
  - AD/MCI/CN three-class classification.
  - zero-shot diagnosis.
  - longitudinal disease tracking.
  - racial subgroup generalization.
- Implication for us:
  - “3D MRI + structured clinical text VLM for AD diagnosis” is already directly covered.
  - Our novelty cannot be merely “make a CLIP-like AD VLM.”
  - We need stronger controls: ROI grounding, field-leakage policy, clinical-only/ROI-only baselines, cohort-held-out, PET/ATN validation.

### NeuroVLM — WACV Workshops 2026

- Paper: *NeuroVLM: A Contrastive Vision-Language Model for Medical Reasoning in Alzheimer's Disease Diagnosis*
- Data/method from abstract and existing note:
  - ADNI T1-weighted MRI scans paired with structured clinical captions.
  - CLIP-style contrastive fine-tuning.
  - Retrieval benchmark.
  - Existing note recorded: about `2294 T1w MRI scans`, `639 subjects`, image-to-text R@1 around `53.77%`.
- Tasks/claims:
  - image-text retrieval.
  - natural language query over brain MRI repository.
- Implication for us:
  - ADNI-only T1 + structured caption retrieval is close prior art.
  - We must not present basic retrieval as sufficient novelty.
  - Our differentiators should be multi-cohort, 3D/ROI grounding, leakage audits, and downstream clinical/PET/longitudinal validation.

### Natural Text Supervision MRI — bioRxiv/EMBC 2025

- Paper: *Leveraging a Vision-Language Model with Natural Text Supervision for MRI Retrieval, Captioning, Classification, and Visual Question Answering*
- PMID preprint: `40027630`; later EMBC DOI: `10.1109/EMBC58623.2025.11251809`
- Method:
  - separate text and image encoders.
  - self-supervised pretraining + joint contrastive fine-tuning.
  - shared embedding, retrieval, captioning, classification, VQA.
- Implication for us:
  - Report-free or text-prompt-based brain MRI VLM is methodologically plausible.
  - But preprint/general framework means our paper must be specific, controlled, and more falsifiable.

### 3D medical VLM / CT-CLIP / CT-GLIP family

- M3D/M3D-LaMed, Med3DVLM, CT-CLIP/CT-RATE, CT-GLIP provide architecture/evaluation anchors.
- Difference from us:
  - CT-RATE-like work uses real radiology reports.
  - Our data mostly has structured clinical/tabular fields, not physician free-text reports.
- Implication:
  - Avoid “radiology report VLM.”
  - Use “structured clinical language-supervised 3D MRI representation learning.”

## 2. 보유 데이터 근거

### Canonical reingest manifest basis

Source checked live:

`/home/vlm/data/metadata/reingest_minyoung4/experiment_manifest_v7.csv`

Observed:

- rows: `10834`
- CN/MCI/AD + `is_classifiable=True`: `10806`
- columns include:
  - `dataset`, `subject_id`, `session_id`, `scanner`, `field_strength`
  - `has_t1w`, `has_seg`, `has_mask`, `complete`
  - `diagnosis`, `cdr_global`, `cdrsb`, `age`, `sex`
  - `visit`, `scan_date`

Filtered row counts:

- ADNI: `5037`
- NACC: `1876`
- OASIS: `1615`
- AJU: `1287`
- AIBL: `991`

Clinical/text field availability in filtered 10806 rows:

- age: `10632`
- sex: `10806`
- cdr_global: `10349`
- cdrsb: `9607`
- scanner: `10389`
- field_strength: `10520`

Longitudinal structure:

- ADNI: `1754` subjects, `870` multi-session, max sessions `16`
- OASIS: `750` subjects, `404` multi-session, max sessions `8`
- NACC: `1420` subjects, `365` multi-session, max sessions `4`
- AJU: `1001` subjects, `286` multi-session, max sessions `2`
- AIBL: `618` subjects, `178` multi-session, max sessions `5`

Interpretation:

- This is strong for structured-caption VLM design.
- It is not yet enough to launch modeling because current `session_dir` paths in this manifest point to old `/home/vlm/data/preprocessed_v4`; mapped path validity under `/home/vlm/data/preprocessed_minyoung4` was only `1374` T1w rows in a live check.
- Therefore v7 is good for cohort/label/text planning, but VLM modeling should use official QC-pass paths below.

### Official v1 QC-pass T1w basis

Verified manifest index:

`/home/vlm/data/preprocessed_official/v1/reports/verified_paths_and_manifests_20260512.csv`

Key files:

- official ready T1w manifest:
  - `/home/vlm/data/preprocessed_official/v1/_reports/official_v1_preprocessing_inventory_20260511/official_v1_ready_preprocessed_manifest_6683_20260511.csv`
- full clinical manifest:
  - `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/manifests/full_clinical_20260511/qc_pass_t1w_6683_full_clinical_source_preserving_manifest_20260511.csv`
- ROI candidate input manifest:
  - `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/ROI_Candidates_20260511/inputs/qc_pass_t1w_6683_roi_candidate_input_manifest_20260511.csv`
- PET pairing manifest:
  - `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Pairing_Audit_20260511/qc_pass_t1w_pet_pairing_manifest_20260511.csv`

Official ready T1w rows:

- total: `6683`
- consortium counts:
  - ADNI: `2284`
  - OASIS: `1293`
  - AIBL: `991`
  - NACC: `906`
  - AJU: `657`
  - KDRC: `552`
- CN/MCI/AD diagnosis rows: `6131`
- subjects among CN/MCI/AD rows: `3087`

Class counts by consortium:

- ADNI: AD `91`, CN `1278`, MCI `915`
- AIBL: AD `129`, CN `721`, MCI `141`
- AJU: AD `90`, CN `10`, MCI `557`
- NACC: AD `85`, CN `616`, MCI `205`
- OASIS: AD `173`, CN `1083`, MCI `37`

Full clinical manifest readiness:

- `t1w_image_ready`: `6683`
- `final_tensor_exists`: `6683`
- `final_mask_exists`: `6683`
- clinical nonmissing:
  - age: `6092`
  - sex: `6131`
  - diagnosis: `6131`
  - scanner: `6057`
  - field_strength: `5950`
- CDR-like fields exist but are consortium-specific, e.g.:
  - `adni_label__cdr_global`, `adni_label__cdrsb`: `2006`
  - `oasis_label__cdr_global`, `oasis_label__cdrsb`: `1107`
  - `aibl__cdr_global`: `990`
  - AJU raw CDR components: `657`

PET pairing manifest:

- total rows: `6683`
- `pet_available_any`: `4363`
- `pet_within_180d`: `2536`
- `pet_within_365d`: `2916`
- `pet_centiloids`: `2274`
- `pet_summary_suvr`: `2895`
- `pet_amyloid_status`: `3239`

PET availability by consortium:

- ADNI: any `2132`, within180d `1470`, within365d `1817`
- AIBL: any `984`, within180d `911`, within365d `927`
- AJU: any `437`, within180d `0`, within365d `0`
- KDRC: any `552`, within180d `0`, within365d `0`
- NACC: any `258`, within180d `155`, within365d `172`
- OASIS: any `0` in this pairing manifest

Interpretation:

- Official v1 QC-pass basis is the safer modeling basis than old v7 `session_dir` paths.
- It has smaller rows than v7 but valid tensors/masks and KDRC extension.
- PET/ATN branch is feasible as validation/supervision, especially ADNI/AIBL/NACC; AJU/KDRC require endpoint-date semantics caution.

## 3. Task selection by evidence

### Candidate 1 — Recommended main task

**ROI-grounded structured clinical language VLM for cohort-held-out 3D dementia MRI representation**

Task question:

> Can ROI-grounded 3D T1w MRI representations align with structured clinical language and generalize across cohorts without collapsing to diagnosis, CDR, age, scanner, template, or cohort shortcuts?

Why this is strongest:

- ADLIP and NeuroVLM already prove structured-text AD VLM feasibility, so we need a stricter, more defensible version.
- Our official data has `6683` QC-pass T1w tensors/masks, `6131` CN/MCI/AD rows, multi-cohort coverage, and clinical fields.
- ROI/segmentation and mask availability is our differentiator versus generic caption retrieval.

Inputs:

- 3D T1w tensor.
- brain mask and ROI/segmentation-derived signals where QC passes.
- structured captions generated under a task-specific field policy.

Outputs:

- image embedding.
- text embedding.
- image-text retrieval Recall@K / median rank.
- cohort-held-out downstream probes:
  - diagnosis or clinical-state probe, with target fields removed.
  - CDR/CDR-SB severity probe where cross-consortium harmonization is possible.
  - PET/ATN probe as branch.
- leakage audit metrics:
  - text-only baseline.
  - clinical-only baseline.
  - scanner/cohort prediction baseline.
  - ROI-only baseline.

Decision:

- Make this the main task.

### Candidate 2 — Strong validation task

**Longitudinal clinical-state/progression VLM**

Task question:

> Does baseline MRI + allowed clinical language representation predict future CDR-SB/diagnosis change better than clinical-only, ROI-only, and image-only baselines?

Why useful:

- More clinically meaningful than AD/CN/MCI classification.
- v7 planning manifest indicates multi-session structure across all five main cohorts.
- ADLIP claims longitudinal evaluation; we need a more leakage-controlled and cohort-held-out version.

Risk:

- Official v1 clinical fields are consortium-specific; CDR-SB harmonization may need careful mapping.
- Future label definitions must be made before modeling.

Decision:

- Use as second-stage validation after manifest and caption policy are stable.

### Candidate 3 — PET/ATN-aware branch

**PET/ATN-privileged VLM alignment**

Task question:

> Does structured-language/ROI-grounded MRI representation align with expensive PET/ATN biomarkers, especially when PET is missing at inference?

Why useful:

- PET availability is substantial in official v1 pairing manifest.
- PET is biologically meaningful and helps avoid pure diagnosis-classifier novelty weakness.

Risk:

- This must not become PET-only prediction as the main research.
- PET date/endpoint semantics differ by consortium, especially AJU/KDRC.

Decision:

- Keep as branch/validation axis, not main task.

### Candidate 4 — Natural-language case retrieval assistant

Task question:

> Can natural language query retrieve similar dementia MRI cases under controlled captions and held-out cohorts?

Why useful:

- Very VLM-native and aligned with NeuroVLM.

Risk:

- Easy to inflate by template shortcuts.
- Needs hard negatives and leakage-aware retrieval design.

Decision:

- Use as benchmark inside Candidate 1, not standalone main claim.

## 4. Proposed first task contract

### Task name

`ROI-grounded Structured Clinical Language Supervision for Multi-Cohort 3D Dementia MRI`

### Unit

- one `subject-session` T1w MRI row.
- split group: `subject_id`.
- evaluation group: `cohort/consortium`.

### Inputs

Required:

- QC-pass 3D T1w tensor.
- brain mask.
- subject/session/cohort identifiers.
- age, sex, scanner, field strength when available.
- diagnosis and CDR/CDR-SB only according to task-specific field policy.

Optional / branch:

- ROI/segmentation features or ROI mask/tokens.
- PET/ATN endpoints for privileged alignment/validation.
- longitudinal next-visit labels.

### Outputs

Primary:

- image embedding.
- text embedding.
- retrieval metrics under hard-negative setup.
- cohort-held-out probe metrics.

Secondary:

- longitudinal progression probe.
- PET/ATN alignment probe.
- case retrieval examples.

### Required baselines

Before any VLM claim:

- text-only caption baseline.
- clinical/tabular-only baseline.
- ROI-only baseline.
- image-only 3D CNN/encoder baseline.
- image+clinical fusion baseline.
- scanner/cohort shortcut audit.

### Forbidden shortcuts

- target label in caption for same target.
- PET/amyloid field in PET prediction caption.
- future label in baseline/longitudinal caption.
- scanner/cohort in caption for tasks where held-out generalization is claimed, unless explicitly tested as metadata baseline.
- subject/session leakage across split.

## 5. Immediate next artifact order

1. `CAPTION_FIELD_POLICY.md`
   - allowed/forbidden fields for retrieval, diagnosis, CDR/CDR-SB, PET/ATN, longitudinal tasks.
2. `VLM_READY_MANIFEST_SPEC.md`
   - official v1 QC-pass basis + optional v7 planning fields, with explicit path validity.
3. `PAPER_READING_MATRIX.md`
   - ADLIP, NeuroVLM, Natural Text Supervision MRI, M3D/M3D-LaMed, CT-CLIP/CT-GLIP.
4. `BASELINE_GATE.md`
   - what must be beaten before the model can be called useful VLM.

## 6. Current decision

For now, choose **Candidate 1 as the main research task**, with Candidate 2 and Candidate 3 as validation branches.

Do not start GPU modeling yet. The next work is paper extraction + caption/manifest/baseline policy.
