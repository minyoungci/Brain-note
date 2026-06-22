# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_three_model_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.892344
- delta mean Dice: -0.000431 (CI95 -0.000940, 0.000089)
- delta Dice <= 0.5 rate: 0.001855 (CI95 0.000000, 0.004329)
- delta Dice <= 0.8 rate: -0.001855 (CI95 -0.005566, 0.001855)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.865555 |       0.000542463 |          0.152709  |           0.157635  |      0.00492611 |
| UCSD-PTGBM     | 178 |             0.816679 |              0.81858  |       0.00190118  |          0.275281  |           0.252809  |     -0.0224719  |
| UPENN-GBM      | 611 |             0.927747 |              0.926483 |      -0.00126475  |          0.0310966 |           0.0294599 |     -0.00163666 |
| UTSW           | 625 |             0.889275 |              0.88868  |      -0.000595166 |          0.1008    |           0.1024    |      0.0016     |
