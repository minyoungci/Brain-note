# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.887385
- delta mean Dice: 0.003108 (CI95 0.000509, 0.005785)
- delta Dice <= 0.5 rate: -0.003711 (CI95 -0.009895, 0.002474)
- delta Dice <= 0.8 rate: -0.003711 (CI95 -0.014224, 0.006184)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.85561  |       0.0117212   |          0.187192  |           0.187192  |       0         |
| UCSD-PTGBM     | 178 |             0.788069 |              0.793146 |       0.00507703  |          0.359551  |           0.331461  |      -0.0280899 |
| UPENN-GBM      | 611 |             0.923344 |              0.92651  |       0.00316583  |          0.0392799 |           0.0392799 |       0         |
| UTSW           | 625 |             0.886603 |              0.886297 |      -0.000306049 |          0.104     |           0.1024    |      -0.0016    |
