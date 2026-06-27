# Stage 6 LOCO Split Readiness Plan

## Scope

Audit whether the subject-level cohort draft is suitable for LOCO splitting
without creating the official split.

## Inputs

- `outputs/subject_level_cohort_manifest_draft.csv`
- `outputs/unit_selection_review.csv`

## Outputs

- `outputs/loco_split_readiness_by_fold.csv`
- `outputs/loco_split_readiness_by_dataset.csv`
- `outputs/loco_split_readiness_report.md`

## Checks

- fold train/test subject counts,
- subject-overlap count,
- secondary-unit leakage count,
- lesion-volume median by held-out fold,
- timing warning distribution,
- scanner strength distribution.

## Why This Comes Before Official Split

The user must approve split definition before official split manifests are
created. This readiness audit informs that approval decision without committing
to a split artifact.
