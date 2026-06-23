# OOF Prediction and Reliability Label Contract

## Scope

This contract defines the minimum artifact and provenance requirements for
segmentation predictions that will later be used to create G-SURE reliability
and error labels.

This document does not approve official split creation, GPU training, inference,
or prediction generation.

## Research Goal Reminder

G-SURE is not a Dice-only segmentation study. The research depends on trustworthy
full-volume out-of-fold segmentation predictions. Those predictions define where
the baseline model failed, and those failure maps become the supervision or
evaluation target for reliability and visual grounding.

## Core Rule

A prediction may be used for reliability/error labels only if it is:

```text
full-volume + held-out/out-of-fold + provenance-recorded + shape-validated
```

Any prediction that is in-sample, patch-only, center-crop-only, missing
provenance, or generated with held-out mask access for crop/tile placement is
not eligible.

## Required Prediction Manifest

Every baseline or uncertainty method that writes predictions must produce a CSV
manifest with one row per predicted subject unit.

Required columns:

```text
experiment_id
model_id
prediction_id
fold_id
heldout_dataset
split_role
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
train_manifest_path
split_manifest_path
checkpoint_path
config_path
command_log_path
created_at_utc
```

Allowed nullable columns:

```text
uncertainty_map_path
binary_mask_path
checkpoint_path
command_log_path
```

Nullable does not mean optional in schema; the column must exist, but the value
may be empty when the artifact is not produced at that stage.

## Manifest Invariants

Hard requirements:

- `split_role` must be `test` for OOF reliability-label source predictions.
- `heldout_dataset` must equal the held-out consortium for the fold.
- `dataset` must equal `heldout_dataset` for LOCO test rows.
- `leakage_group_id` must identify exactly one subject-level unit.
- `full_volume_assembled` must be `1`.
- `mask_used_for_tile_placement` must be `0`.
- `mask_used_for_metric_only` may be `1` only after prediction assembly.
- `probability_shape` must equal `target_shape`.
- `canonical_shape` must equal `probability_shape`.
- `probability_map_path` must point to a full-volume probability map, not a tile.
- `threshold_source` must not be `heldout_test_metric`.
- one subject unit may have at most one primary prediction per
  `experiment_id` / `model_id` / `fold_id`.

Forbidden:

- In-sample training predictions as reliability-label source.
- Validation predictions from train consortia as held-out evidence.
- Predictions from center crops that do not reconstruct full canonical volume.
- Predictions whose threshold was selected on held-out test Dice.
- Reliability labels generated before probability maps are assembled.

## Probability Map Requirements

For the first binary whole-lesion task:

```text
probability map values: float in [0, 1]
shape: canonical full-volume shape
target: selected_mask > 0
channel order for source model: [T1, T1ce, T2, FLAIR]
```

The probability map must preserve enough geometry metadata to compare it against
the canonical target mask. If saved as NIfTI, affine/orientation/spacing must
match the canonical target space. If saved as another tensor format, the manifest
must record the canonical shape/orientation/spacing and the loader must provide a
reviewed mapping back to subject space.

## Binary Mask Threshold Policy

For baseline reporting:

- Threshold must be fixed by train/validation data only.
- The first reliability-label generation uses fixed threshold `0.5`.
- If optimized, the optimization data and objective must be recorded in
  `threshold_source`.
- Held-out test Dice may not be used to choose threshold.

For reliability labels:

- Store continuous probability maps first.
- Generate binary predictions from the pre-declared threshold only.
- Keep threshold-independent error-localization metrics when possible.

## Error Label Definitions

Let:

```text
GT = selected_mask > 0
P  = full-volume probability map
B  = binary prediction from P using the pre-declared threshold
```

Primary error maps:

```text
FN = GT == 1 and B == 0
FP = GT == 0 and B == 1
ERR = FN union FP
```

Required continuous severity map:

```text
soft_error = abs(GT - P)
```

Optional boundary/ambiguity maps:

```text
boundary_band = dilation(GT, r) - erosion(GT, r)
```

The boundary radius `r`, morphology connectivity, and any smoothing must be
pre-declared before generating labels.

The first label-generation policy is specified in:

```text
research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md
```

## Reliability Label Manifest

Reliability/error label generation must write a second manifest with one row per
subject unit.

Required columns:

```text
reliability_label_id
source_prediction_id
experiment_id
fold_id
heldout_dataset
dataset
subject_id
unit_id
leakage_group_id
target_source_path
probability_map_path
binary_mask_path
fn_map_path
fp_map_path
err_map_path
boundary_map_path
soft_error_map_path
threshold_value
boundary_radius
label_generation_config_path
created_at_utc
```

`source_prediction_id` must link back to a row in the OOF prediction manifest.

## Training Eligibility For Later G-SURE

Reliability/error labels may be used to train a second-stage model only under
one of these conditions:

1. They are generated from OOF predictions for the same training subjects.
2. They are generated from train-only predictions that never saw the target row
   during fitting.
3. They are used only as held-out evaluation labels, not training labels.

Labels generated from a model evaluated on its own training rows are diagnostic
only and must not be used for reliability-head training.

For DeVries-style and QCResUNet-style QC baselines, train-row labels should come
from the inner-OOF schedule:

```text
research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md
```

The current OOF prediction manifest schema and validator primarily target outer
LOCO held-out predictions. Inner-OOF predictions require explicit inner-fold
provenance before they are used for QC training labels.

Draft inner-OOF metadata validator:

```text
research_gsure/02_audits/scripts/validate_inner_oof_prediction_manifest.py
```

## Minimum Validation Before Label Generation

Before reliability/error labels are generated:

1. Confirm official split manifest exists.
2. Confirm prediction manifest row count equals expected held-out subject count
   for each fold.
3. Confirm no duplicate `prediction_id`.
4. Confirm no train/test subject overlap for each prediction row.
5. Confirm every probability map exists.
6. Confirm full-volume assembled flag is `1`.
7. Confirm probability/target/canonical shapes match.
8. Confirm no held-out mask was used for tile placement.
9. Confirm threshold policy is train-only or fixed.

The metadata validator for these checks is:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest <prediction_manifest.csv> \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --check-files
```

This validator is required before reliability/error label generation, but it is
not sufficient by itself: probability value ranges and image geometry also need
artifact-level checks.

For the first baseline, the primary artifact format is a canonical-space NIfTI
probability map. The artifact-level validator is:

```bash
python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest <prediction_manifest.csv>
```

Both metadata and artifact-level validators must pass before reliability/error
labels are generated.

After both validators pass, the draft first-pass label generator and label
manifest validator are:

```text
research_gsure/02_audits/scripts/generate_reliability_labels.py
research_gsure/02_audits/scripts/validate_reliability_label_manifest.py
```

## Minimum Reporting

Every report using reliability labels must include:

- OOF prediction manifest path,
- reliability label manifest path,
- fold counts,
- threshold policy,
- full-volume assembly policy,
- label generator and validator versions/paths,
- failure maps used,
- any excluded predictions and reasons,
- whether labels were used for training, evaluation, or both.

## Open Decisions

These remain unresolved until implementation:

- whether later methods may use non-NIfTI probability map formats,
- whether later methods use train-fold validation thresholds instead of
  `fixed_0.5`,
- whether boundary labels become a supervised target or remain diagnostic,
- whether uncertainty maps are saved as NIfTI or tensor arrays,
- acceptance thresholds for full artifact validation runtime.
