# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.883842
- delta mean Dice: -0.000435 (CI95 -0.003360, 0.002374)
- delta Dice <= 0.5 rate: 0.003711 (CI95 -0.002474, 0.009276)
- delta Dice <= 0.8 rate: -0.003711 (CI95 -0.013605, 0.005566)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.845853 |        0.00196388 |          0.187192  |           0.182266  |     -0.00492611 |
| UCSD-PTGBM     | 178 |             0.788069 |              0.781448 |       -0.00662111 |          0.359551  |           0.337079  |     -0.0224719  |
| UPENN-GBM      | 611 |             0.923344 |              0.929679 |        0.00633488 |          0.0392799 |           0.0294599 |     -0.00981997 |
| UTSW           | 625 |             0.886603 |              0.880533 |       -0.00607097 |          0.104     |           0.112     |      0.008      |
