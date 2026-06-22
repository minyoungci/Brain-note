# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.885765
- delta mean Dice: 0.001488 (CI95 -0.001390, 0.004324)
- delta Dice <= 0.5 rate: -0.002474 (CI95 -0.008658, 0.003711)
- delta Dice <= 0.8 rate: -0.002474 (CI95 -0.012987, 0.007421)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.856072 |        0.0121836  |          0.187192  |           0.147783  |     -0.0394089  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.784768 |       -0.003301   |          0.359551  |           0.348315  |     -0.011236   |
| UPENN-GBM      | 611 |             0.923344 |              0.926761 |        0.00341729 |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886603 |              0.884095 |       -0.00250847 |          0.104     |           0.1152    |      0.0112     |
