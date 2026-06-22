# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.883842
- delta mean Dice: -0.003543 (CI95 -0.005933, -0.001208)
- delta Dice <= 0.5 rate: 0.007421 (CI95 0.001237, 0.013605)
- delta Dice <= 0.8 rate: 0.000000 (CI95 -0.008658, 0.008658)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.845853 |       -0.00975733 |          0.187192  |           0.182266  |     -0.00492611 |
| UCSD-PTGBM     | 178 |             0.793146 |              0.781448 |       -0.0116981  |          0.331461  |           0.337079  |      0.00561798 |
| UPENN-GBM      | 611 |             0.92651  |              0.929679 |        0.00316905 |          0.0392799 |           0.0294599 |     -0.00981997 |
| UTSW           | 625 |             0.886297 |              0.880533 |       -0.00576492 |          0.1024    |           0.112     |      0.0096     |
