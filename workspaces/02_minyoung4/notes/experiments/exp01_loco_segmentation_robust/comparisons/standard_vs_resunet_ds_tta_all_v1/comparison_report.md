# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.889639
- delta mean Dice: 0.005362 (CI95 0.002599, 0.007976)
- delta Dice <= 0.5 rate: -0.001855 (CI95 -0.007421, 0.003711)
- delta Dice <= 0.8 rate: -0.006184 (CI95 -0.016698, 0.004329)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.860463 |        0.0165747  |          0.187192  |           0.167488  |     -0.0197044  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.801969 |        0.0138999  |          0.359551  |           0.320225  |     -0.0393258  |
| UPENN-GBM      | 611 |             0.923344 |              0.929353 |        0.00600931 |          0.0392799 |           0.0327332 |     -0.00654664 |
| UTSW           | 625 |             0.886603 |              0.885258 |       -0.00134508 |          0.104     |           0.112     |      0.008      |
