# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.889639
- delta mean Dice: 0.002253 (CI95 0.000740, 0.003781)
- delta Dice <= 0.5 rate: 0.001855 (CI95 -0.002474, 0.006184)
- delta Dice <= 0.8 rate: -0.002474 (CI95 -0.009895, 0.004947)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.860463 |        0.00485345 |          0.187192  |           0.167488  |     -0.0197044  |
| UCSD-PTGBM     | 178 |             0.793146 |              0.801969 |        0.00882285 |          0.331461  |           0.320225  |     -0.011236   |
| UPENN-GBM      | 611 |             0.92651  |              0.929353 |        0.00284349 |          0.0392799 |           0.0327332 |     -0.00654664 |
| UTSW           | 625 |             0.886297 |              0.885258 |       -0.00103903 |          0.1024    |           0.112     |      0.0096     |
