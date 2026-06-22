# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.885826
- delta mean Dice: -0.001559 (CI95 -0.003975, 0.000881)
- delta Dice <= 0.5 rate: 0.006184 (CI95 0.000000, 0.012369)
- delta Dice <= 0.8 rate: -0.004947 (CI95 -0.014224, 0.004329)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.862448 |        0.00683797 |          0.187192  |           0.162562  |     -0.0246305  |
| UCSD-PTGBM     | 178 |             0.793146 |              0.799125 |        0.00597976 |          0.331461  |           0.292135  |     -0.0393258  |
| UPENN-GBM      | 611 |             0.92651  |              0.924913 |       -0.00159692 |          0.0392799 |           0.0327332 |     -0.00654664 |
| UTSW           | 625 |             0.886297 |              0.879901 |       -0.00639639 |          0.1024    |           0.1152    |      0.0128     |
