# Stage 29: Inner-OOF QC Label Schedule

## Task

Define how G-SURE can train DeVries-style and QCResUNet-style QC baselines
without leaking outer held-out consortium information.

## Research Question

Within each outer LOCO fold, how can train-consortia segmentation error labels
be generated without using in-sample segmentation predictions?

## Action

Added:

```text
research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md
```

Updated:

```text
research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md
research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md
research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md
research_gsure/ROADMAP.md
```

## Schedule Summary

For each outer held-out consortium `H`:

1. train B1 on all non-`H` consortia,
2. predict full-volume maps for `H` for outer evaluation only,
3. inside non-`H` consortia, leave one train consortium `I` out,
4. train inner B1 on consortia excluding both `H` and `I`,
5. predict full-volume maps for `I`,
6. use those inner-OOF errors as Q1/Q2/Q3 training labels,
7. evaluate Q1/Q2/Q3 only on outer held-out `H`.

## Compute Implication

For one B1 segmentation configuration and one seed:

```text
outer B1 models: 4
inner B1 models: 12
total B1-like segmentation fits: 16
```

This is why QC baselines must be staged after B1 viability is proven and after
Min approves extra compute.

## Key Risk

The current outer OOF prediction validator is not enough for inner-OOF QC-label
generation. A future validator needs explicit fields for:

- `outer_fold_id`,
- `outer_heldout_dataset`,
- `inner_fold_id`,
- `inner_heldout_dataset`,
- `outer_role`,
- `inner_role`,
- `inner_train_datasets`.

## Interpretation

This stage prevents a subtle but serious leakage path: training a QC/error-map
baseline on labels derived from in-sample segmentation predictions or outer
held-out rows.

## Validation Required

Run:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "INNER_OOF_QC_LABEL_SCHEDULE|inner-OOF|outer_heldout_dataset|inner_heldout_dataset" research_gsure SCRATCHPAD.md
git diff --check
```

## Remaining Gate

Official split creation is still not approved. No inner-OOF predictions exist.
