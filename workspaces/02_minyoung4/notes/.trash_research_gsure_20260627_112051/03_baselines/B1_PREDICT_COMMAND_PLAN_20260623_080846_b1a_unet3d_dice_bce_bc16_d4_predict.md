# B1 Held-Out Prediction Command Plan

This is a command plan only. It does not approve GPU inference.

## Gate

BLOCKED: missing or invalid fit artifacts; do not execute predict commands yet.
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160/checkpoint_last.pt
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160/fit_summary.json
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160/checkpoint_last.pt
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160/fit_summary.json
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160/checkpoint_last.pt
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160/fit_summary.json
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160/checkpoint_last.pt
- research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160/fit_summary.json

Do not execute these commands until the corresponding B1 fit checkpoints and fit summaries pass
`validate_b1_fit_results.py`.
After each command, run the listed validator command before generating reliability labels.

## Shared Settings

- split manifest: `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- GPU: `4`
- fit timestamp: `20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit`
- predict timestamp: `20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict`
- patch shape: `192,224,160`
- architecture: `unet3d`
- loss: `dice_bce`
- model prefix: `b1_unet3d_dice_bce_bc16_d4_seed_20260623`
- max infer rows: `0` (`0` means all held-out test rows)

## Expected Prediction Rows

| heldout | expected rows | checkpoint | fit summary | output dir |
|---|---:|---|---|---|
| MU-Glioma-Post | 203 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160/checkpoint_last.pt` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160/fit_summary.json` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160` |
| UCSD-PTGBM | 178 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160/checkpoint_last.pt` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160/fit_summary.json` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160` |
| UPENN-GBM | 611 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160/checkpoint_last.pt` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160/fit_summary.json` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160` |
| UTSW | 622 | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160/checkpoint_last.pt` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160/fit_summary.json` | `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160` |

## Commands

### heldout `MU-Glioma-Post`

Predict:

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset MU-Glioma-Post \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --max-infer-rows 0 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --checkpoint-path research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160/checkpoint_last.pt \
  --experiment-id B1_plain_3d_unet_loco \
  --model-id b1_unet3d_dice_bce_bc16_d4_seed_20260623_MU-Glioma-Post \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160
```

Validate:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_MU-Glioma-Post_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset MU-Glioma-Post \
  --check-files
```

### heldout `UCSD-PTGBM`

Predict:

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --max-infer-rows 0 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --checkpoint-path research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160/checkpoint_last.pt \
  --experiment-id B1_plain_3d_unet_loco \
  --model-id b1_unet3d_dice_bce_bc16_d4_seed_20260623_UCSD-PTGBM \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160
```

Validate:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UCSD-PTGBM_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --check-files
```

### heldout `UPENN-GBM`

Predict:

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --max-infer-rows 0 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --checkpoint-path research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160/checkpoint_last.pt \
  --experiment-id B1_plain_3d_unet_loco \
  --model-id b1_unet3d_dice_bce_bc16_d4_seed_20260623_UPENN-GBM \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160
```

Validate:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UPENN-GBM_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --check-files
```

### heldout `UTSW`

Predict:

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode predict \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --max-infer-rows 0 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --checkpoint-path research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160/checkpoint_last.pt \
  --experiment-id B1_plain_3d_unet_loco \
  --model-id b1_unet3d_dice_bce_bc16_d4_seed_20260623_UTSW \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160
```

Validate:

```bash
python \
  research_gsure/02_audits/scripts/validate_oof_prediction_manifest.py \
  --prediction-manifest research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict_b1_predict_UTSW_192x224x160/prediction_manifest.csv \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --check-files
```
