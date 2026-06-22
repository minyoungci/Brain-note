# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.885826
- delta mean Dice: 0.001549 (CI95 -0.001405, 0.004473)
- delta Dice <= 0.5 rate: 0.002474 (CI95 -0.003711, 0.008658)
- delta Dice <= 0.8 rate: -0.008658 (CI95 -0.018553, 0.000618)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.862448 |        0.0185592  |          0.187192  |           0.162562  |     -0.0246305  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.799125 |        0.0110568  |          0.359551  |           0.292135  |     -0.0674157  |
| UPENN-GBM      | 611 |             0.923344 |              0.924913 |        0.00156891 |          0.0392799 |           0.0327332 |     -0.00654664 |
| UTSW           | 625 |             0.886603 |              0.879901 |       -0.00670244 |          0.104     |           0.1152    |      0.0112     |
