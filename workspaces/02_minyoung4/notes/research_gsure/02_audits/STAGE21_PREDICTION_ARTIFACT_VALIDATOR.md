# Stage 21 Prediction Artifact Validator

## Scope

Add an artifact-level validator for future OOF prediction NIfTI files. This
stage did not create official split files, generate real predictions, run
inference, run GPU, preprocess data, or train a model.

## Goal Reminder

G-SURE reliability/error labels can only be trusted if the source probability
maps are valid full-volume artifacts in the target space. Metadata alone is not
enough: probability values, shape, affine, orientation, and spacing must also be
checked.

## Added Script

```text
research_gsure/02_audits/scripts/validate_prediction_artifacts.py
```

The validator checks NIfTI artifacts referenced by a prediction manifest:

- probability map path exists,
- target mask path exists,
- probability and target shapes match,
- probability shape matches manifest `probability_shape` and `canonical_shape`,
- target shape matches manifest `target_shape`,
- probability affine matches target affine,
- probability orientation matches target orientation and manifest orientation,
- probability voxel spacing matches target spacing and manifest spacing,
- probability values are finite and in `[0, 1]`,
- target values are finite and non-empty,
- optional binary mask is finite, geometry-matched, and 0/1,
- optional uncertainty map is finite and geometry-matched.

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/validate_prediction_artifacts.py
```

Synthetic artifact self-test:

```bash
python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --synthetic-self-test
```

Observed:

```text
Synthetic artifact rows: 1
Synthetic artifact validation errors: 0
```

The self-test creates temporary NIfTI probability, target, binary, and uncertainty
maps under a temporary directory only.

## Guardrails

- This validator does not generate predictions or reliability labels.
- It validates NIfTI artifacts only.
- It does not replace metadata manifest validation.
- It does not validate split membership.
- It does not prove model performance, calibration, or uncertainty quality.
- It can be expensive on full OOF predictions; use `--max-rows` for bounded
  smoke validation before full validation.

## Required Future Command

After OOF prediction generation exists:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest <prediction_manifest.csv> \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --check-files

python research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest <prediction_manifest.csv>
```

Reliability/error labels must not be generated until both validations pass.
