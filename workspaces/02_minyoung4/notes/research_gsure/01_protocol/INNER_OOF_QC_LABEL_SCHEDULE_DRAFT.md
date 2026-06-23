# Inner-OOF QC Label Schedule Draft

## Scope

This document defines the leakage-safe schedule for generating training labels
for DeVries-style and QCResUNet-style quality-control baselines.

This document does not approve:

- official split creation,
- GPU training,
- inference,
- prediction generation,
- reliability label generation.

## Research Goal Reminder

G-SURE must compare against segmentation QC baselines without leaking held-out
consortium labels. Q1/Q2 baselines need segmentation-error labels for training,
but those labels cannot come from in-sample segmentation predictions or from the
outer held-out consortium.

## Core Rule

For every outer LOCO fold:

```text
outer held-out consortium = evaluation only
outer train consortia = only source for QC training labels
QC training labels = generated from inner-OOF predictions inside outer train
```

In-sample segmentation predictions are diagnostic only and are not eligible for
Q1/Q2/Q3 training labels.

## Outer-Inner Structure

For each outer held-out consortium `H`:

1. Train the B1 segmentation model on all non-`H` consortia.
2. Predict full-volume maps for `H`.
3. Use those `H` predictions only for outer evaluation.
4. For each train consortium `I` among non-`H` consortia:
   - train an inner B1 model on consortia excluding both `H` and `I`,
   - predict full-volume maps for `I`,
   - generate error/reliability labels for `I`,
   - use those labels as QC training labels for Q1/Q2/Q3 in the outer fold.
5. Train Q1/Q2/Q3 only on the union of inner-OOF labels from the outer train
   consortia.
6. Evaluate Q1/Q2/Q3 on the outer held-out `H` predictions and labels.

## Subject Counts

Current draft selected-subject counts:

| dataset | subjects |
|---|---:|
| MU-Glioma-Post | 203 |
| UCSD-PTGBM | 178 |
| UPENN-GBM | 611 |
| UTSW | 622 |
| total | 1,614 |

## Required Inner-OOF Prediction Schedule

| outer heldout H | outer train subjects | inner heldout I | inner train datasets | inner train subjects | inner predicted subjects |
|---|---:|---|---|---:|---:|
| MU-Glioma-Post | 1,411 | UCSD-PTGBM | UPENN-GBM + UTSW | 1,233 | 178 |
| MU-Glioma-Post | 1,411 | UPENN-GBM | UCSD-PTGBM + UTSW | 800 | 611 |
| MU-Glioma-Post | 1,411 | UTSW | UCSD-PTGBM + UPENN-GBM | 789 | 622 |
| UCSD-PTGBM | 1,436 | MU-Glioma-Post | UPENN-GBM + UTSW | 1,233 | 203 |
| UCSD-PTGBM | 1,436 | UPENN-GBM | MU-Glioma-Post + UTSW | 825 | 611 |
| UCSD-PTGBM | 1,436 | UTSW | MU-Glioma-Post + UPENN-GBM | 814 | 622 |
| UPENN-GBM | 1,003 | MU-Glioma-Post | UCSD-PTGBM + UTSW | 800 | 203 |
| UPENN-GBM | 1,003 | UCSD-PTGBM | MU-Glioma-Post + UTSW | 825 | 178 |
| UPENN-GBM | 1,003 | UTSW | MU-Glioma-Post + UCSD-PTGBM | 381 | 622 |
| UTSW | 992 | MU-Glioma-Post | UCSD-PTGBM + UPENN-GBM | 789 | 203 |
| UTSW | 992 | UCSD-PTGBM | MU-Glioma-Post + UPENN-GBM | 814 | 178 |
| UTSW | 992 | UPENN-GBM | MU-Glioma-Post + UCSD-PTGBM | 381 | 611 |

## Compute Implication

For one B1 segmentation configuration and one seed:

```text
outer B1 models: 4
inner B1 models: 12
total B1-like segmentation fits before QC training: 16
```

This count excludes TTA, ensemble/repeated-seed baselines, and Q1/Q2/Q3
training. Therefore Q1/Q2/Q3 should not be launched until:

1. official split exists,
2. post-split validation passes,
3. first B1 outer predictions are non-degenerate,
4. prediction artifact validators pass,
5. Min approves the extra compute.

## Manifest Requirement

Outer OOF predictions and inner-OOF predictions should not share the same
validator contract without explicit support for inner-fold provenance.

Required future inner-OOF manifest fields:

```text
experiment_id
model_id
prediction_id
outer_fold_id
outer_heldout_dataset
inner_fold_id
inner_heldout_dataset
outer_role
inner_role
dataset
subject_id
unit_id
leakage_group_id
target_source_path
probability_map_path
binary_mask_path
uncertainty_map_path
prediction_space
canonical_shape
probability_shape
target_shape
orientation
spacing
patch_shape
overlap
tile_count
full_volume_assembled
mask_used_for_tile_placement
mask_used_for_metric_only
threshold_source
threshold_value
inner_train_datasets
outer_split_manifest_path
inner_split_manifest_path
checkpoint_path
config_path
command_log_path
created_at_utc
```

Required invariants:

- `outer_role == train` for every inner-OOF prediction row.
- `inner_role == test`.
- `dataset == inner_heldout_dataset`.
- `dataset != outer_heldout_dataset`.
- `inner_heldout_dataset != outer_heldout_dataset`.
- `inner_train_datasets` excludes both `outer_heldout_dataset` and
  `inner_heldout_dataset`.
- `full_volume_assembled == 1`.
- `mask_used_for_tile_placement == 0`.
- one subject unit may have at most one primary prediction per
  `experiment_id` / `model_id` / `outer_fold_id` / `inner_fold_id`.

The current outer OOF prediction validator is not sufficient for this inner-OOF
manifest. A separate validator or an explicit validator extension is required
before real inner-OOF labels are generated.

Draft inner-OOF metadata validator:

```text
research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py
```

Current status:

- synthetic self-test only,
- no real inner-OOF predictions exist,
- artifact-level probability-map validation is still required after real
  predictions exist.

## QC Training Dataset Per Outer Fold

For outer fold `H`, the QC training set is:

```text
all inner-OOF predictions where outer_heldout_dataset == H
```

The QC evaluation set is:

```text
outer OOF predictions where heldout_dataset == H
```

Outer evaluation labels may be generated from outer predictions and GT after
prediction artifact validation, but they may not be used for Q1/Q2/Q3 fitting,
threshold selection, early stopping, architecture selection, or hyperparameter
tuning.

## Recommended Staged Execution

1. Finish official split and post-split validation.
2. Run B1 outer segmentation only.
3. Inspect whether B1 outer predictions are non-degenerate.
4. If viable, design and approve the inner-OOF compute plan.
5. Generate inner-OOF B1 predictions.
6. Validate inner-OOF prediction manifests and artifacts.
7. Generate inner-OOF error/reliability labels.
8. Train Q1/Q2/Q3.
9. Evaluate Q1/Q2/Q3 on outer held-out predictions.
10. Proceed to G-SURE method only if Q baselines leave a gap.

## Fallback Option

If the 12 inner consortium-heldout fits are computationally infeasible, a
subject-level K-fold split within the outer train consortia may be proposed as a
fallback. This fallback is weaker because it does not test consortium shift
inside the QC-label generation process.

The fallback requires a separate approval and must be labeled as a compute
compromise, not as equivalent to the primary inner-consortium OOF schedule.

## Stop Rules

Stop before QC baseline training if:

- B1 outer predictions are degenerate,
- inner-OOF artifact validation fails,
- any inner row overlaps the outer held-out consortium,
- in-sample predictions would be needed for training labels,
- patch-only predictions would be used as error labels,
- compute requirements exceed the approved budget.
