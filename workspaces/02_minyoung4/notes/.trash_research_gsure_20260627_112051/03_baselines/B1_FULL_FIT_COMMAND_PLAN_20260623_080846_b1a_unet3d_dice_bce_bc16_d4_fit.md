# B1 Full-Fit Command Plan

This is a command plan only. It does not approve GPU execution.

## Gate

BLOCKED: smoke summary does not exist: research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json

Do not execute these commands until the B1 smoke output has passed
`validate_b1_smoke_result.py`.

## Shared Settings

- split manifest: `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- GPU: `4`
- patch shape: `192,224,160`
- architecture: `unet3d`
- loss: `dice_bce`
- overlap: `0.50`
- epochs: `50`
- steps per epoch: `250`
- max train rows: `0` (`0` means all fit rows)
- max validation rows: `8`
- seed: `20260623`

## Fold Counts

| heldout | train rows | internal fit | internal val | heldout test |
|---|---:|---:|---:|---:|
| MU-Glioma-Post | 1411 | 1270 | 141 | 203 |
| UCSD-PTGBM | 1436 | 1292 | 144 | 178 |
| UPENN-GBM | 1003 | 903 | 100 | 611 |
| UTSW | 992 | 893 | 99 | 622 |

## Commands

### heldout `MU-Glioma-Post`

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset MU-Glioma-Post \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --epochs 50 \
  --steps-per-epoch 250 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --validate-every 5 \
  --foreground-prob 0.67 \
  --lr 1e-4 \
  --weight-decay 1e-4 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_MU-Glioma-Post_192x224x160
```

### heldout `UCSD-PTGBM`

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --epochs 50 \
  --steps-per-epoch 250 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --validate-every 5 \
  --foreground-prob 0.67 \
  --lr 1e-4 \
  --weight-decay 1e-4 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UCSD-PTGBM_192x224x160
```

### heldout `UPENN-GBM`

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --epochs 50 \
  --steps-per-epoch 250 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --validate-every 5 \
  --foreground-prob 0.67 \
  --lr 1e-4 \
  --weight-decay 1e-4 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UPENN-GBM_192x224x160
```

### heldout `UTSW`

```bash
CUDA_VISIBLE_DEVICES=4 \
  python \
  research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UTSW \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --epochs 50 \
  --steps-per-epoch 250 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --validate-every 5 \
  --foreground-prob 0.67 \
  --lr 1e-4 \
  --weight-decay 1e-4 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit_b1_fit_UTSW_192x224x160
```

## Post-Run Validation

Run this CPU-only validator after all four fit commands finish and before any prediction command:

```bash
python research_gsure/03_baselines/scripts/validate_b1_fit_results.py \
  --run-prefix 20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit \
  --patch-shape 192,224,160
```

Do not proceed to held-out prediction unless `all_valid` is true.
