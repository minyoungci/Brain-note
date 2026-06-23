# Stage 20 OOF Prediction Manifest Validator

## Scope

Add a metadata-only validator for future OOF prediction manifests. This stage did
not create official split files, generate predictions, load NIfTI files, run
inference, run GPU, preprocess data, or train a model.

## Goal Reminder

G-SURE reliability labels are valid only if their source predictions are
full-volume, held-out/out-of-fold, provenance-recorded, and shape-validated. A
validator makes that requirement enforceable before reliability labels are
generated.

## Added Script

```text
research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py
```

The validator checks:

- required prediction manifest columns,
- duplicate `prediction_id`,
- duplicate `experiment_id/model_id/fold_id/leakage_group_id` primary rows,
- `split_role == test`,
- `dataset == heldout_dataset`,
- `full_volume_assembled == 1`,
- `mask_used_for_tile_placement == 0`,
- shape equality across canonical/probability/target shapes,
- positive tile count,
- threshold in `[0, 1]`,
- threshold source not derived from held-out test metrics,
- optional split-manifest membership consistency.

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py
```

Synthetic self-test:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --synthetic-self-test
```

Observed:

```text
Synthetic rows: 1
Synthetic validation errors: 0
```

Schema print smoke:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --print-schema
```

## Guardrails

- The validator is metadata-only.
- It does not prove probability maps exist unless `--check-files` is used.
- It does not inspect NIfTI geometry or probability value ranges.
- It cannot run on real predictions until prediction-writing code exists.
- It does not replace split validation or post-split loader smoke.

## Next Action

After OOF prediction generation exists, run:

```bash
python research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest <prediction_manifest.csv> \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --check-files
```

Reliability/error labels must not be generated until this validation passes.
