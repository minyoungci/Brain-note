# Caption field policy — Gate05b draft

작성일: 2026-05-28
Workspace: `/home/vlm/minyoungi`
Status: draft policy for Gate05b planning; must be reviewed before training

## 0. Scope

This policy defines which fields may enter controlled ROI/structured-language supervision for Gate05b.

Gate05b goal:

> Use ROI-derived anatomical/status language during training only, while keeping inference image-only.

This is not a permission to use diagnosis, biomarker, cohort, scanner, or QC shortcut text as if it were clean clinical language.

## 1. Global rules

Allowed by default:

- Modality identity: T1w MRI.
- Anatomical ROI identity: hippocampus, amygdala, thalamus, lateral ventricle, parahippocampal cortex, and other explicitly approved ROI names.
- Deterministic ROI status derived from approved image-derived ROI scalar/stat artifacts.
- Conservative train-reference wording: lower / within / higher / much lower / much higher relative to training reference distribution.
- Localization-only ROI text when morphology scalar is missing but ROI quality gate passes.

Forbidden by default:

- Diagnosis labels: CN, MCI, AD, dementia, Alzheimer, disease class, conversion label.
- Diagnosis-derived phrases: AD-like, dementia-compatible, normal cognition, cognitively impaired, patient group.
- PET/ATN/biomarker fields: amyloid, tau, PET positivity, centiloid, SUVR, CSF, ATN.
- Clinical scores when they are downstream/probe targets: CDR, CDR-SB, MMSE, ADAS, severity labels derived from them.
- Cohort/site/scanner/manufacturer/field-strength strings in generated captions.
- QC/availability status as natural-language biological description.
- Race/ethnicity claims unless the field is explicitly audited and the use is justified.

## 2. Task-specific policy

### CN/MCI/AD diagnosis downstream evaluation

Allowed text fields:

- `modality`
- `roi_name`
- `hemisphere` where applicable
- `roi_localization_caption`
- `roi_morphology_caption` derived only from image-derived ROI scalar/status rules
- `roi_pair_text` / `roi_row_text` if they contain only approved ROI status/localization language

Forbidden text fields:

- diagnosis label or label-derived word
- CDR/MMSE/ADAS severity descriptions
- PET/amyloid/tau/CSF/ATN words
- cohort/site/scanner strings
- QC pass/fail wording as text input

Special rule:

- Baseline07 showed quality/mask status carries signal. Therefore, if Gate05b uses quality/mask status in any text or auxiliary target, report a separate `with_quality_status` vs `severity_only` comparison.

### PET/ATN downstream probe

Allowed text fields:

- image-derived ROI anatomy/status only, if generated without PET/ATN information
- modality and anatomical localization

Forbidden text fields:

- amyloid/tau/PET/CSF/ATN values or positivity
- PET timing/proximity phrases
- biomarker-derived labels

Special rule:

- PET/ATN may be privileged supervision only in a separately named branch. It cannot be mixed into a leakage-safe downstream PET probe.

### Retrieval / representation pretraining

Allowed text fields:

- controlled ROI anatomy/status language
- global safe caption fields such as modality only, or age bucket/sex only if explicitly approved for that experiment

Forbidden text fields:

- target labels for the same downstream task
- cohort/scanner/site identifiers
- biomarker labels unless the run is explicitly a privileged biomarker-supervision branch and downstream evaluation excludes those fields

## 3. Wording rules

Preferred wording:

- `The left hippocampus is lower than the training reference range.`
- `The lateral ventricle is higher than the training reference range.`
- `The thalamus is localized as a quality-approved ROI.`

Avoid unless separately approved:

- normal / abnormal
- atrophy / enlarged
- AD-like / dementia-compatible
- Alzheimer / disease / diagnosis
- amyloid-positive / tau-positive

Rationale:

- Train-reference ROI bins are statistical bins, not clinical normative diagnoses.
- Baseline07 proves ROI status/QC text already carries target signal; wording must not amplify that into hidden label leakage.

## 4. Required audit columns for generated text artifacts

Every Gate05b text artifact should carry enough metadata to audit leakage:

- `row_id`
- `subject_id`
- `session_id`
- `split`
- `roi_name`
- `text_version`
- `template_id`
- `allowed_fields_used`
- `forbidden_fields_checked`
- `source_artifact`
- `quality_status_used_for_filtering`
- `quality_status_used_as_text` boolean
- `biomarker_fields_used` boolean
- `diagnosis_fields_used` boolean
- `cohort_scanner_fields_used` boolean

## 5. Baseline07 connection

Baseline07 registered shortcut values:

- Internal macro OvR AUC: `0.7212`
- Internal bACC: `0.5494`
- LOCO mean bACC: `0.5411 ± 0.0299`
- LOCO mean macro OvR AUC: `0.7027`

Interpretation:

- These values are not VLM evidence.
- They are the non-image shortcut threshold that ROI-language experiments must beat using image-only inference.
- If a Gate05b text-supervised image encoder fails to beat Baseline07-compatible evaluation, the result is not a strong representation claim.

## 6. Training gate

Before any Gate05b GPU run:

1. Confirm generated text contains no forbidden terms with word-boundary checks.
2. Confirm no diagnosis/PET/cohort/scanner fields were used in text generation.
3. Confirm split labels are reused, not recomputed silently.
4. Confirm Baseline07 severity-only vs quality+severity comparison is included in the report.
5. Save the exact text policy version in the run config.
