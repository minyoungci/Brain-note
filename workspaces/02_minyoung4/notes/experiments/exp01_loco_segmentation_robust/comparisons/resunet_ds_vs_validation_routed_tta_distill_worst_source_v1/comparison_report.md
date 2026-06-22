# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/validation_routed_resunet_ds_tta_distill_worst_source_v1`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.884310
- delta mean Dice: -0.003076 (CI95 -0.004792, -0.001479)
- delta Dice <= 0.5 rate: 0.004329 (CI95 0.000618, 0.008658)
- delta Dice <= 0.8 rate: 0.002474 (CI95 -0.003711, 0.009276)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.85561  |        0          |          0.187192  |           0.187192  |      0          |
| UCSD-PTGBM     | 178 |             0.793146 |              0.793146 |        0          |          0.331461  |           0.331461  |      0          |
| UPENN-GBM      | 611 |             0.92651  |              0.924913 |       -0.00159692 |          0.0392799 |           0.0327332 |     -0.00654664 |
| UTSW           | 625 |             0.886297 |              0.879901 |       -0.00639639 |          0.1024    |           0.1152    |      0.0128     |
