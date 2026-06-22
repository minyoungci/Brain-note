# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_weighted_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.891906
- delta mean Dice: 0.007629 (CI95 0.004949, 0.010257)
- delta Dice <= 0.5 rate: -0.003092 (CI95 -0.009276, 0.002474)
- delta Dice <= 0.8 rate: -0.016698 (CI95 -0.026592, -0.007421)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.862321 |        0.0184325  |          0.187192  |           0.162562  |     -0.0246305  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.816987 |        0.0289185  |          0.359551  |           0.280899  |     -0.0786517  |
| UPENN-GBM      | 611 |             0.923344 |              0.926252 |        0.00290833 |          0.0392799 |           0.0294599 |     -0.00981997 |
| UTSW           | 625 |             0.886603 |              0.889275 |        0.00267197 |          0.104     |           0.1008    |     -0.0032     |
