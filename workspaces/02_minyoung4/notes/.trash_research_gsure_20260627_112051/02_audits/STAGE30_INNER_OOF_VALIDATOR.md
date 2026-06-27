# Stage 30: Inner-OOF Prediction Manifest Validator

## Task

Add a metadata-only validator for future inner-OOF prediction manifests used as
QC-label sources.

## Research Question

Can we block the most obvious inner-OOF leakage cases before any QC labels are
generated?

## Added Artifact

```text
research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py
```

## What The Validator Checks

Required inner-OOF invariants:

- `outer_role == train`,
- `inner_role == test`,
- `dataset == inner_heldout_dataset`,
- `dataset != outer_heldout_dataset`,
- `outer_heldout_dataset != inner_heldout_dataset`,
- `inner_train_datasets` equals all expected consortia except outer and inner
  held-out consortia,
- `full_volume_assembled == 1`,
- `mask_used_for_tile_placement == 0`,
- canonical, probability, and target shapes match,
- threshold source is fixed or train-only,
- duplicate primary prediction keys are rejected.

## Current Status

The validator has a synthetic positive/negative self-test. It has not been run
on real prediction manifests because:

- no official split exists,
- no B1 outer predictions exist,
- no inner-OOF predictions exist.

## Linked Files

Updated:

```text
research_gsure/02_audits/scripts/check_pre_split_readiness.py
research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md
research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md
research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md
```

## Validation Required

Run:

```bash
python -m py_compile research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py
python research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py --synthetic-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
git diff --check
```

## Interpretation

This is an engineering guardrail for a future experiment stage. It is not
evidence that QC baselines, segmentation, or G-SURE will work.

## Remaining Gate

Official split creation, GPU training, inference, real prediction manifests, and
real reliability label generation remain approval-gated.
