# UPENN B1B Fit Validation Result - 2026-06-24

## Scope

Held-out fold:

```text
UPENN-GBM
```

Run type:

```text
B1B scratch 3D U-Net fit only
```

No held-out test predictions were written in this step.

## Command

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode fit \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UPENN-GBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_focal \
  --epochs 20 \
  --steps-per-epoch 64 \
  --validate-every 2 \
  --max-train-rows 0 \
  --max-val-rows 8 \
  --val-fraction 0.10 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64
```

## Validation Command

```bash
python research_gsure/03_baselines/scripts/validate_b1_fit_results.py \
  --fit-dir research_gsure/03_baselines/outputs/20260624_100756_b1b_unet3d_dice_focal_bc16_d4_fitprobe_UPENN-GBM_192x224x160_spe64 \
  --heldout UPENN-GBM \
  --expected-loss dice_focal \
  --expected-epochs 20 \
  --expected-steps-per-epoch 64 \
  --expected-validation-every 2 \
  --expected-base-channels 16 \
  --expected-depth 4 \
  --patch-shape 192,224,160
```

Validator result:

```text
all_valid = true
valid_fold_count = 1
validation_events = 10
forbidden_artifact_count = 0
```

## Result

| item | value |
| --- | ---: |
| fit rows used | 903 |
| internal-val rows used | 8 |
| held-out UPENN rows not used for validation | 611 |
| first train loss | 0.537342 |
| final train loss | 0.473160 |
| loss delta | -0.064182 |
| final internal-val mean Dice at 0.5 | 0.698171 |
| final internal-val min Dice at 0.5 | 0.146033 |
| final internal-val max Dice at 0.5 | 0.912800 |
| shape mismatch count | 0 |
| max allocated GPU memory MiB | 4084.50 |
| max reserved GPU memory MiB | 5474.00 |

## Interpretation

The fit completed and passed artifact validation. The run is ready for the next
pipeline step: outer-train internal-val prediction for threshold/calibration
selection.

This does not yet provide UPENN held-out segmentation performance. Held-out
prediction, threshold selection, and reliability evaluation remain outstanding.
