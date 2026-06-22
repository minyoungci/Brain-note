# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/validation_routed_standard_focal_source_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.884277
- delta mean Dice: 0.000000 (CI95 -0.000817, 0.000808)
- delta Dice <= 0.5 rate: 0.000618 (CI95 0.000000, 0.001855)
- delta Dice <= 0.8 rate: 0.002474 (CI95 -0.001855, 0.006803)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.843889 |       0           |          0.187192  |           0.187192  |      0          |
| UCSD-PTGBM     | 178 |             0.788069 |              0.788069 |       0           |          0.359551  |           0.359551  |      0          |
| UPENN-GBM      | 611 |             0.923344 |              0.923345 |       1.00099e-06 |          0.0392799 |           0.0458265 |      0.00654664 |
| UTSW           | 625 |             0.886603 |              0.886603 |       0           |          0.104     |           0.104     |      0          |
