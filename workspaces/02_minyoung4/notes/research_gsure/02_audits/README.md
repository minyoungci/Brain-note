# G-SURE Audits

This directory stores small, reproducible data audits required before modeling.

## Current Audit Status

Completed preparation now includes:

- path-level NIfTI and segmentation inventory,
- mask value and geometry audit,
- target-mapping review,
- candidate cohort and subject-level cohort manifests,
- LOCO split-readiness audit,
- official split builder dry-run,
- loader smoke script,
- split-aware tile budget and tile-grid dry-run scripts,
- OOF prediction and reliability-label validators,
- pre-split readiness preflight,
- official split artifact checker,
- post-split validation runner.

No official split manifest has been created yet. No GPU work, preprocessing
cache, model inference, prediction artifact, or reliability label artifact has
been created.

## Outputs

Expected outputs are written under `outputs/`:

- `mask_path_inventory.csv`: one row per discovered NIfTI file.
- `mask_path_summary_by_dataset.csv`: dataset-level file and mask counts.
- `mask_path_summary_by_key.csv`: segmentation-key counts.
- `mask_path_audit_report.md`: human-readable summary and next checks.
- `mask_value_geometry_audit.csv`: one row per segmentation mask with label and
  geometry checks.
- `mask_value_summary_by_key.csv`: segmentation-key value/geometry summary.
- `structural_coverage_by_unit.csv`: same-unit MRI channel availability.
- `mask_value_geometry_report.md`: human-readable Stage 2 summary.
- `subject_level_cohort_manifest_draft.csv`: one selected unit per subject for
  the draft primary cohort.
- `loco_split_readiness_by_fold.csv`: LOCO readiness summary without creating
  official split artifacts.
- `tile_grid_dry_run_subject_level_summary.csv`: draft-cohort full-volume tile
  coverage check for GPU-preview candidates.

## Important Limit

Stage 1 only infers candidate semantics from paths and filenames. Stage 2 reads
mask values and headers, but still cannot prove clinical meaning without source
documentation and target-mapping decisions.

Official split creation remains approval-gated. After approval, use:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```
