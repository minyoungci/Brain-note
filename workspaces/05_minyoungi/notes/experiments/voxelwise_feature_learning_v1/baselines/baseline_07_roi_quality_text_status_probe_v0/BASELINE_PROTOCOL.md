# Baseline 07 Protocol — ROI quality/text/status-only shortcut probe v0

## Status

Accepted baseline snapshot for ROI-derived text/status/QC shortcut auditing.

This is **not** VLM or image-model evidence. It is a hand-engineered ROI quality/text/status baseline that later ROI-language/VLM experiments must beat on identical splits.

## Task

- Target: CN/MCI/AD multiclass classification
- Split/evaluation:
  - subject-disjoint internal test using `manifests/v2_integrated/splits/subject_disjoint_split_v0.csv`
  - leave-one-cohort-out over ADNI/AIBL/AJU/KDRC/NACC/OASIS
- Inputs:
  - ROI quality text/status: `manifests/v2_integrated/captions/roi_quality_text_v0/official_roi_quality_text_v0.csv`
  - ROI text v1 local severity rows: `manifests/v2_integrated/captions/roi_text_v1/roi_local_text_v1.csv`
- Model: `StandardScaler + LogisticRegression(class_weight=balanced)` for non-dummy feature sets; most-frequent dummy baseline.

## Feature sets compared

- `dummy_most_frequent`: 0 features
- `roi_quality_gate_and_mask_status`: 45 features
- `roi_text_v1_severity_scores`: 16 features
- `roi_text_v1_severity_onehot`: 80 features
- `quality_plus_severity_scores`: 61 features
- `quality_plus_severity_onehot`: 125 features

## Contract checks

- Feature rows: `11,199`
- Split rows used: `11,199`
- Train/val/internal_test rows: `7,838` / `1,681` / `1,680`
- ROI quality rows loaded: `53,115`
- ROI quality unique join keys: `10,623`
- ROI text v1 local rows loaded: `179,184`
- ROI text v1 unique row IDs: `11,199`
- Quality feature missing rows: `0`
- Severity feature missing rows: `0`

## Primary registered comparison values

Primary comparison row uses `quality_plus_severity_onehot` because it has the strongest LOCO mean balanced accuracy among non-dummy feature sets.

- Internal test `quality_plus_severity_onehot`:
  - accuracy: `0.572024`
  - balanced accuracy: `0.549421`
  - macro-F1: `0.525727`
  - macro OvR AUC: `0.721156`
- LOCO `quality_plus_severity_onehot`:
  - mean balanced accuracy: `0.541138`
  - std balanced accuracy: `0.029862`
  - mean macro-F1: `0.463608`
  - mean macro OvR AUC: `0.702750`
  - folds: `6`

Note: Internal best balanced accuracy is `quality_plus_severity_scores` at `0.555761`. The registry primary row is intentionally selected by LOCO mean bACC, not internal-test bACC.

## Artifacts in this baseline snapshot

- `summary.json`
- `REPORT.md` / `REPORT_KO.md`
- `loco_mean_by_feature_set.csv`
- `metrics.csv`
- `metrics_full.json`
- `BASELINE_PROTOCOL.md`

Large/generated artifacts intentionally remain in the ignored result directory and are not baseline-snapshotted:

- `features.csv`
- `predictions.csv`

## Interpretation guardrail

If a later ROI-language/VLM run does not beat this baseline under the same split and LOCO protocol, it is weak evidence for learned image-language representation. It may be repackaging deterministic ROI severity/status or QC/mask-availability metadata.
