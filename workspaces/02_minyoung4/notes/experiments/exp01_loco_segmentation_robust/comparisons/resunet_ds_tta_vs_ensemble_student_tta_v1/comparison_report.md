# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.892077
- delta mean Dice: 0.002438 (CI95 0.000792, 0.004210)
- delta Dice <= 0.5 rate: -0.003092 (CI95 -0.007421, 0.001237)
- delta Dice <= 0.8 rate: -0.006184 (CI95 -0.014224, 0.001855)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.858086 |       -0.00237765 |          0.167488  |           0.147783  |     -0.0197044  |
| UCSD-PTGBM     | 178 |             0.801969 |              0.801795 |       -0.00017355 |          0.320225  |           0.308989  |     -0.011236   |
| UPENN-GBM      | 611 |             0.929353 |              0.931683 |        0.00233    |          0.0327332 |           0.0360065 |      0.00327332 |
| UTSW           | 625 |             0.885258 |              0.89011  |        0.0048517  |          0.112     |           0.1024    |     -0.0096     |
