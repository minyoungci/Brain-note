# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.885826
- delta mean Dice: -0.003812 (CI95 -0.005958, -0.001663)
- delta Dice <= 0.5 rate: 0.004329 (CI95 -0.001237, 0.009895)
- delta Dice <= 0.8 rate: -0.002474 (CI95 -0.011132, 0.006184)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.862448 |        0.00198452 |          0.167488  |           0.162562  |     -0.00492611 |
| UCSD-PTGBM     | 178 |             0.801969 |              0.799125 |       -0.00284309 |          0.320225  |           0.292135  |     -0.0280899  |
| UPENN-GBM      | 611 |             0.929353 |              0.924913 |       -0.00444041 |          0.0327332 |           0.0327332 |      0          |
| UTSW           | 625 |             0.885258 |              0.879901 |       -0.00535736 |          0.112     |           0.1152    |      0.0032     |
