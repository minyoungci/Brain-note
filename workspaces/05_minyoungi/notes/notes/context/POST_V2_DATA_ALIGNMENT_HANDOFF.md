# POST_V2_DATA_ALIGNMENT_HANDOFF

Updated: 2026-05-21
Workspace rule: **이 VLM workflow의 작업 산출물과 상태 보고 범위는 `/home/vlm/minyoungi`에만 둔다.** 다른 workspace는 Min이 현재 요청에서 명시한 경우에만 별도로 다룬다.

## Current canonical integrated manifest

OASIS 포함, A4 제외/external-validation 예약 상태의 v2 integrated audit manifest:

```text
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
```

Companion audit files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0_by_cohort.csv
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0_class_counts.csv
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0_summary.json
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0_validation_checks.json
```

Previous non-OASIS partial manifest remains archived at:

```text
/home/vlm/minyoungi/manifests/v2_partial/vlm_ready_manifest_v2_partial_non_oasis_v1_kdrc_union.csv
```

Recovered/moved legacy context from earlier out-of-scope work:

```text
/home/vlm/minyoungi/notes/context/recovered_from_minyoung4_20260520/MOVE_LOG.json
```

## Manifest scope

Included in integrated core pool:

```text
ADNI
AIBL
AJU
KDRC
NACC
OASIS
```

Reserved outside core pool:

```text
A4 = external validation candidate after preprocessing completes
```

## Latest verified counts

```text
total rows: 11,750
core training rows: 11,199
row_id unique: True
duplicate cohort-subject-session: 0
t1w_preproc_path exists: 11,736 / 11,736
brain_mask_path exists: 11,736 / 11,736
image_ready_but_path_missing: 0
core_path_missing: 0
core_nonclassifiable: 0
rows with final_shape/voxel metadata: 11,736 / 11,750
unique final_shape: 192x224x192
OASIS rows added: 1,615
OASIS clinical joined: 1,615 / 1,615
OASIS core training: 1,609
```

KDRC clinical sources unioned:

```text
/home/vlm/data/raw/KDRC/데이터분양_데이터통합_2026-05-04_104848660.xlsx
/home/vlm/data/raw/KDRC/KDRC_0513_extracted/KDRC_clinical.xlsx
```

OASIS clinical source:

```text
/home/vlm/data/metadata/reingest_minyoung4/experiment_manifest_v7.csv
```

## Must-not-forget rule

```text
v2 preprocessing 완료
→ preprocessing inventory
→ VLM-ready manifest alignment
→ alignment/bias/missingness/biomarker audit
→ caption allowed/forbidden policy
→ subject-disjoint/cohort-held-out splits
→ shortcut baselines
→ only then VLM common-core training
```

## Stop conditions before VLM training

- subject-disjoint split not verified
- target-specific forbidden text fields not defined
- caption leakage policy not created
- cohort-only/missingness-only shortcut risk not measured
- biomarker target appears in training caption for same prediction task
- ROI/native-grid transfer remains BLOCKED_PROVISIONAL and must not be used as evidence/features yet

## Next recommended action

1. Create `CAPTION_FIELD_POLICY.md` / leakage rules.
2. Create subject-disjoint split from integrated manifest.
3. Run cohort/class/missingness shortcut audit before any VLM training.
4. Keep A4 out of core training; add later as `dataset_role=external_validation`.

## Training-safety artifacts added

Updated: 2026-05-21

Final/confirmed files kept next to the integrated manifest:

```text
/home/vlm/minyoungi/manifests/v2_integrated/CAPTION_FIELD_POLICY.md
/home/vlm/minyoungi/manifests/v2_integrated/subject_disjoint_split_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/subject_disjoint_split_v0_balance_by_cohort.csv
/home/vlm/minyoungi/manifests/v2_integrated/subject_disjoint_split_v0_class_summary.csv
/home/vlm/minyoungi/manifests/v2_integrated/subject_disjoint_split_v0_report.md
```

Policy:

- Use only confirmed fields for v0 training.
- Diagnosis task caption allows only age bucket + sex at v0.
- Diagnosis/CDR/biomarker/cohort/scanner/site fields are forbidden in diagnosis captions.
- Core split is subject-disjoint by `cohort + subject_id`; non-core rows are retained as `not_core_training`.
- Experimental/scratch files should not be kept; only confirmed artifacts above are retained/updated.

## Shortcut audit v0 added

Updated: 2026-05-21

Final/confirmed shortcut audit files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_results.csv
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_cohortwise_results.csv
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_confusion_matrices.json
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_feature_sets.json
/home/vlm/minyoungi/manifests/v2_integrated/shortcut_audit_v0/shortcut_audit_v0_classification_reports.json
```

Purpose:

- Quantify non-image shortcut risk before controlled caption generation and image-only/VLM training.
- Use `subject_disjoint_split_v0` only.
- Keep only confirmed audit outputs under `shortcut_audit_v0/`; no scratch experiment files are retained.

Next recommended action:

```text
Create controlled_captions_v0.csv using CAPTION_FIELD_POLICY.md, then prepare image-only baseline design.
```

## Controlled captions v0 added

Updated: 2026-05-21

Final/confirmed controlled caption files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/controlled_captions_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/controlled_captions_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/controlled_captions_v0_templates.json
```

Purpose:

- Provide leakage-safe global captions for diagnosis-task experiments.
- Use only modality + age bucket + sex.
- Use 8 surface-form templates with deterministic `sha256(row_id) % 8` assignment.
- Keep semantic fields fixed across template variants; wording variation does not add clinical, cohort, scanner, biomarker, or ROI information.

Verified counts:

```text
caption file rows: 11,750
eligible core caption rows: 11,199
excluded non-core rows: 551
train / val / internal_test eligible rows: 7,838 / 1,681 / 1,680
forbidden-term hits in eligible caption_v0: 0
```

Important limitation:

```text
controlled_captions_v0 is intentionally low-information and should not be treated as a rich radiology-report surrogate.
For individual-level image-text alignment, develop separate ROI-grounded image-derived captions after FastSurfer feature inventory/QC.
```

Next recommended action:

```text
Inspect FastSurfer ROI volumetric/thickness feature availability and design roi_captions_v0 with ICV normalization, train-only reference fitting, segmentation QC, and no diagnosis/CDR/PET-derived language.
```

## FastSurfer ROI feature inventory v0 added

Updated: 2026-05-21

Final/confirmed inventory files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/fastsurfer_roi_feature_inventory_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/fastsurfer_roi_feature_inventory_v0_structures.csv
/home/vlm/minyoungi/manifests/v2_integrated/fastsurfer_roi_feature_inventory_v0_availability_by_cohort.csv
```

Verified availability:

```text
core rows inspected: 11,199
stats_dir_exists: 11,199 / 11,199
aseg+DKT.stats: 11,199 / 11,199
aseg+DKT.VINN.stats: 11,199 / 11,199
aseg.VINN.stats: 11,199 / 11,199
```

Parsed source:

```text
FastSurfer stats source for first ROI-caption design: aseg+DKT.stats
columns: Index, SegId, NVoxels, Volume_mm3, StructName, normMean, normStdDev, normMin, normMax, normRange
example structures: 100
AD-relevant inventory candidates: 28
```

Important guardrail:

```text
This is read-only inventory only. ROI captions are not generated yet because CAPTION_FIELD_POLICY.md still marks ROI/native-grid evidence as BLOCKED_PROVISIONAL.
Before roi_captions_v0 training use, approve/update policy with QC, normalization, and train-only reference rules.
```

Next recommended action:

```text
Design ROI caption policy v0: choose primary AD ROI subset, parse aseg+DKT.stats volumes, choose head-size normalization proxy or locate eTIV/ICV, fit reference distribution on train split only, then generate roi_captions_v0 as image-derived morphology captions without disease/diagnosis phrases.
```

## ROI captions v0 added

Updated: 2026-05-21

Final/confirmed ROI caption files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/roi_captions_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/roi_captions_v0_reference_stats.csv
/home/vlm/minyoungi/manifests/v2_integrated/roi_captions_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/roi_captions_v0_templates.json
/home/vlm/minyoungi/manifests/v2_integrated/ROI_QUANT_TO_TEXT_RULES_v0.md
```

Policy update:

```text
/home/vlm/minyoungi/manifests/v2_integrated/CAPTION_FIELD_POLICY.md
ROI-grounded branch status changed from BLOCKED_PROVISIONAL to CONDITIONALLY_READY_FOR_ROI_CAPTION_V0_DESIGN.
This applies only to separate roi_captions_v0* artifacts, not to controlled_captions_v0 global diagnosis captions.
```

ROI caption v0 design:

```text
source: FastSurfer aseg+DKT.stats
raw measure: Volume_mm3
head-size proxy: MaskVol from stats header; no eTIV/ICV found in inspected stats headers
normalized value: Volume_mm3 / MaskVol * 1000
reference fit: train split only
status cutoff: z <= -1 lower_than_reference; z >= 1 higher_than_reference; otherwise within_reference_range
primary ROIs per row: 16
quant-to-text rule file: ROI_QUANT_TO_TEXT_RULES_v0.md
```

Quant-to-text stability rule:

```text
same quantitative input + same reference statistics + same policy version
→ same ROI status
→ same caption text
Do not silently change thresholds/templates/ROI list/normalization; create v1 if changed.
```

Verified counts:

```text
core rows with ROI captions: 11,199
roi caption rows: 179,184
train / val / internal_test rows: 125,408 / 26,896 / 26,880
missing stats files: 0
row_id + roi_name duplicates: 0
missing normalized values: 0
qc_status pass: 179,184 / 179,184
forbidden-term hits in roi_caption: 0
```

ROI status counts:

```text
within_reference_range: 128,206
higher_than_reference: 25,899
lower_than_reference: 25,079
```

Important limitations:

```text
1. This v0 uses volume only, not cortical thickness.
2. MaskVol is a temporary proxy, not confirmed eTIV/ICV.
3. Train-only reference is not CN-only and is not a clinical normative reference.
4. Captions are morphology/status descriptions, not disease statements.
5. Visual segmentation QC was not performed in this step; existing fs_qc_status/final_qc_status were used.
```

Next recommended action:

```text
Run ROI-feature-only shortcut/probe baseline under subject_disjoint_split_v0, then compare image-only vs image+controlled_caption vs image+ROI-caption designs.
```

## ROI feature probe v0 added

Updated: 2026-05-21

Files:

```text
/home/vlm/minyoungi/manifests/v2_integrated/roi_feature_probe_v0/ROI_FEATURE_PROBE_v0_REPORT.md
/home/vlm/minyoungi/manifests/v2_integrated/roi_feature_probe_v0/roi_feature_probe_v0_results.csv
/home/vlm/minyoungi/manifests/v2_integrated/roi_feature_probe_v0/roi_feature_probe_v0_predictions.csv
/home/vlm/minyoungi/manifests/v2_integrated/roi_feature_probe_v0/roi_feature_probe_v0_metadata.json
/home/vlm/minyoungi/manifests/v2_integrated/roi_feature_probe_v0/*_coefficients.csv
```

Design:

```text
CPU-only numpy baselines; sklearn/scipy not installed.
No MRI voxels used.
Feature sets: dummy majority, age+sex, 16 ROI normalized volumes, 16 ROI z-scores, 48 ROI status one-hot, ROI z + age/sex.
Classifiers: nearest centroid and class-weighted softmax.
Softmax L2 selected on val; internal_test used as held-out estimate.
```

Internal-test key results:

```text
best overall: roi_z16_plus_age_sex_softmax
  balanced_accuracy=0.5703, macro_f1=0.5272, accuracy=0.5893

best ROI-only: roi_status48_softmax
  balanced_accuracy=0.5347, macro_f1=0.4979, accuracy=0.5583

roi_z16_softmax / roi_norm16_softmax
  balanced_accuracy=0.5221, macro_f1=0.4817, accuracy=0.5179

age_sex_softmax
  balanced_accuracy=0.4620, macro_f1=0.4402

dummy majority
  balanced_accuracy=0.3333, macro_f1=0.2326
```

Interpretation:

```text
16 FastSurfer ROI volume/status features contain moderate diagnosis signal but are far below the earlier risky non-image/CDR shortcut audit.
MCI recall remains weak, so roi_captions_v0 should be treated as ROI morphology supervision/baseline evidence, not a standalone diagnosis solution.
```

Next recommended action:

```text
Define first image-only smoke baseline and report it alongside dummy, age/sex, and ROI-feature-only baselines.
```

## v2_integrated cleanup / current organized layout

Updated: 2026-05-21

The top-level `/home/vlm/minyoungi/manifests/v2_integrated/` artifact files were reorganized into role-based subdirectories. Use `MANIFEST_INDEX.md` as the current file map; older sections above may mention the pre-cleanup root-level paths.

Current entry points:

```text
/home/vlm/minyoungi/manifests/v2_integrated/README.md
/home/vlm/minyoungi/manifests/v2_integrated/MANIFEST_INDEX.md
/home/vlm/minyoungi/manifests/v2_integrated/CLEANUP_LOG_20260521.json
/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/splits/subject_disjoint_split_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/captions/policy/CAPTION_FIELD_POLICY.md
/home/vlm/minyoungi/manifests/v2_integrated/captions/controlled_v0/controlled_captions_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/captions/roi_v0/roi_captions_v0.csv
/home/vlm/minyoungi/manifests/v2_integrated/audits/shortcut_audit_v0/shortcut_audit_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/audits/clinical_biomarker_availability_v0/CLINICAL_BIOMARKER_AVAILABILITY_AUDIT_v0.md
/home/vlm/minyoungi/manifests/v2_integrated/audits/fastsurfer_roi_feature_inventory_v0/fastsurfer_roi_feature_inventory_v0_report.md
/home/vlm/minyoungi/manifests/v2_integrated/probes/roi_feature_probe_v0/ROI_FEATURE_PROBE_v0_REPORT.md
```

Verified after cleanup:

```text
root-level files now limited to README.md, MANIFEST_INDEX.md, CLEANUP_LOG_20260521.json
all required canonical/split/caption/audit/probe files exist at organized paths
no artifact was deleted; files were moved and the exact mapping is in CLEANUP_LOG_20260521.json
```

## Image-only smoke baseline v0 added

Updated: 2026-05-21

Final/confirmed experiment entry points:

```text
/home/vlm/minyoungi/experiments/image_only_smoke_v0/README.md
/home/vlm/minyoungi/experiments/image_only_smoke_v0/LATEST_RUN.md
/home/vlm/minyoungi/experiments/image_only_smoke_v0/run_image_only_smoke_v0.py
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T062217Z/REPORT.md
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T062217Z/metrics.json
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T062217Z/predictions.csv
```

Design:

```text
workspace: /home/vlm/minyoungi only
input: T1w preprocessed image; brain mask used only to zero non-brain voxels
excluded inputs: captions, ROI scalar features, CDR, biomarkers, cohort/site/scanner, PET-derived fields
split: subject_disjoint_split_v0
sample: train 80/class, val 40/class, internal_test 40/class
model: tiny 3D CNN
downsample_shape: 32x40x32
device: cuda:7
epochs: 6
```

Latest completed result:

```text
train:         balanced_accuracy=0.5167, macro_f1=0.4145, accuracy=0.5167
val:           balanced_accuracy=0.4750, macro_f1=0.3805, accuracy=0.4750
internal_test: balanced_accuracy=0.4500, macro_f1=0.3581, accuracy=0.4500
```

Interpretation:

```text
This confirms the first image-only path can load canonical T1w images, respect the subject-disjoint split, train a tiny CNN, and produce held-out metrics. It is smoke evidence, not final model evidence. MCI recall is 0 in this small run; the model mostly separates CN vs AD-like patterns and collapses MCI into CN/AD.
```

Note:

```text
runs/image_only_smoke_v0_20260521T061207Z is an incomplete timed-out exploratory run and should not be reported as a completed result.
```

## Image-only scaled smoke run added

Updated: 2026-05-21

Completed run:

```text
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z
```

Configuration:

```text
sample: train 240/class, val 80/class, internal_test 80/class
epochs: 8
device: cuda:7
```

Result:

```text
train:         balanced_accuracy=0.5097, macro_f1=0.5085, accuracy=0.5097
val:           balanced_accuracy=0.4208, macro_f1=0.4132, accuracy=0.4208
internal_test: balanced_accuracy=0.3875, macro_f1=0.3743, accuracy=0.3875
```

