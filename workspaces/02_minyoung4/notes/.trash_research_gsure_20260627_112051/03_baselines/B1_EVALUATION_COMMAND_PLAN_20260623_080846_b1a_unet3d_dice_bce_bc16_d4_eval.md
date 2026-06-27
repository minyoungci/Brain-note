# B1 Post-OOF Evaluation Command Plan

This is a command plan only. It does not approve GPU inference or compute metrics.

## Gate

BLOCKED: missing prediction manifests; do not evaluate B1 yet.
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv

Run these commands only after all B1 held-out prediction manifests exist.
The correct order is metadata validation, artifact validation, then segmentation evaluation.

## Shared Settings

- split manifest: `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- predict timestamp: `20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict`
- metrics timestamp: `20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval`
- patch shape: `192,224,160`
- metrics directory: `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval_b1_eval_192x224x160`
- max artifact rows: `0` (`0` means all rows)
- max eval rows: `0` (`0` means all rows)

## Expected Prediction Rows

| heldout | expected rows | prediction manifest | exists |
|---|---:|---|---|
| MU-Glioma-Post | 203 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv` | `False` |
| UCSD-PTGBM | 178 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv` | `False` |
| UPENN-GBM | 611 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv` | `False` |
| UTSW | 622 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv` | `False` |

## Fold-Level Validation Commands

### heldout `MU-Glioma-Post`

Metadata/schema validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset MU-Glioma-Post \
  --check-files
```

Artifact/value/geometry validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv
```

### heldout `UCSD-PTGBM`

Metadata/schema validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --check-files
```

Artifact/value/geometry validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv
```

### heldout `UPENN-GBM`

Metadata/schema validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --check-files
```

Artifact/value/geometry validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv
```

### heldout `UTSW`

Metadata/schema validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --check-files
```

Artifact/value/geometry validation:

```bash
python \
  research_gsure/02_audits/scripts/validate_prediction_artifacts.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv
```

## Combined Segmentation Evaluation

This command combines all fold manifests into one OOF segmentation table.

```bash
python \
  research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv \
  --out-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval_b1_eval_192x224x160 \
  --output-prefix b1a_unet3d_dice_bce_bc16_d4_segmentation_metrics
```

## Post-Evaluation Validation

Run this CPU-only validator before variant ranking or promotion decisions:

```bash
python \
  research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py \
  --summary-json research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval_b1_eval_192x224x160/b1a_unet3d_dice_bce_bc16_d4_segmentation_metrics_summary.json \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --check-input-files
```

Do not feed metrics into the B1 variant leaderboard unless this validator reports `valid=true`.

## Required Interpretation

- Do not compare variants until all four fold manifests are evaluated.
- Use worst-consortium metrics as a guard, not only pooled mean Dice.
- Do not generate reliability labels if B1 segmentation is degenerate on any held-out consortium.
