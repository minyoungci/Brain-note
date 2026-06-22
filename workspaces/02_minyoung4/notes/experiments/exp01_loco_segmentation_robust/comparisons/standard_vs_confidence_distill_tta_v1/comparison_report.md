# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.890254
- delta mean Dice: 0.005977 (CI95 0.003389, 0.008572)
- delta Dice <= 0.5 rate: -0.003092 (CI95 -0.009276, 0.002474)
- delta Dice <= 0.8 rate: -0.012987 (CI95 -0.022882, -0.003092)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.855791 |        0.0119023  |          0.187192  |           0.172414  |     -0.0147783  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.811482 |        0.0234132  |          0.359551  |           0.280899  |     -0.0786517  |
| UPENN-GBM      | 611 |             0.923344 |              0.926444 |        0.00310037 |          0.0392799 |           0.0343699 |     -0.00490998 |
| UTSW           | 625 |             0.886603 |              0.888503 |        0.00189945 |          0.104     |           0.1024    |     -0.0016     |
