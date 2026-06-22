# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/validation_routed_resunet_ds_tta_distill_val_mean_v1`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.884913
- delta mean Dice: -0.002472 (CI95 -0.004099, -0.000982)
- delta Dice <= 0.5 rate: 0.004947 (CI95 0.001237, 0.009276)
- delta Dice <= 0.8 rate: 0.004947 (CI95 0.000000, 0.010513)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.85561  |        0          |          0.187192  |           0.187192  |          0      |
| UCSD-PTGBM     | 178 |             0.793146 |              0.793146 |        0          |          0.331461  |           0.331461  |          0      |
| UPENN-GBM      | 611 |             0.92651  |              0.92651  |        0          |          0.0392799 |           0.0392799 |          0      |
| UTSW           | 625 |             0.886297 |              0.879901 |       -0.00639639 |          0.1024    |           0.1152    |          0.0128 |
