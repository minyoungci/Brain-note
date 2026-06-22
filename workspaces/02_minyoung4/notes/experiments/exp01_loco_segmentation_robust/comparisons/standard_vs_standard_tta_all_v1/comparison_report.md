# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.886454
- delta mean Dice: 0.002177 (CI95 0.000459, 0.003924)
- delta Dice <= 0.5 rate: -0.001237 (CI95 -0.004947, 0.002474)
- delta Dice <= 0.8 rate: -0.003092 (CI95 -0.011132, 0.004947)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.852068 |       0.00817952  |          0.187192  |           0.172414  |     -0.0147783  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.789879 |       0.00181085  |          0.359551  |           0.359551  |      0          |
| UPENN-GBM      | 611 |             0.923344 |              0.922977 |      -0.000367205 |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886603 |              0.889423 |       0.00281917  |          0.104     |           0.1024    |     -0.0016     |
