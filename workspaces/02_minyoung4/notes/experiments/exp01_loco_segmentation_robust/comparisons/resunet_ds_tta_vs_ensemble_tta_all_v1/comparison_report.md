# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.892775
- delta mean Dice: 0.003136 (CI95 0.002044, 0.004342)
- delta Dice <= 0.5 rate: -0.003711 (CI95 -0.007421, -0.000618)
- delta Dice <= 0.8 rate: -0.011750 (CI95 -0.018553, -0.005566)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.865013 |        0.00454955 |          0.167488  |           0.152709  |     -0.0147783  |
| UCSD-PTGBM     | 178 |             0.801969 |              0.816679 |        0.0147101  |          0.320225  |           0.275281  |     -0.0449438  |
| UPENN-GBM      | 611 |             0.929353 |              0.927747 |       -0.00160581 |          0.0327332 |           0.0310966 |     -0.00163666 |
| UTSW           | 625 |             0.885258 |              0.889275 |        0.00401705 |          0.112     |           0.1008    |     -0.0112     |
