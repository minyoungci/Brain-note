# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/source_balanced_dice_bce_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.879252
- delta mean Dice: -0.005025 (CI95 -0.008068, -0.002164)
- delta Dice <= 0.5 rate: 0.000618 (CI95 -0.005566, 0.006803)
- delta Dice <= 0.8 rate: 0.006184 (CI95 -0.003711, 0.015461)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.824113 |      -0.0197759   |          0.187192  |           0.206897  |      0.0197044  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.788035 |      -3.39512e-05 |          0.359551  |           0.353933  |     -0.00561798 |
| UPENN-GBM      | 611 |             0.923344 |              0.923345 |       1.00099e-06 |          0.0392799 |           0.0458265 |      0.00654664 |
| UTSW           | 625 |             0.886603 |              0.880034 |      -0.00656941  |          0.104     |           0.1088    |      0.0048     |
