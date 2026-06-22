# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.888930
- delta mean Dice: -0.000709 (CI95 -0.002524, 0.001161)
- delta Dice <= 0.5 rate: 0.002474 (CI95 -0.002474, 0.007421)
- delta Dice <= 0.8 rate: -0.006184 (CI95 -0.014842, 0.001855)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.863941 |        0.00347723 |          0.167488  |           0.147783  |     -0.0197044  |
| UCSD-PTGBM     | 178 |             0.801969 |              0.817655 |        0.0156862  |          0.320225  |           0.275281  |     -0.0449438  |
| UPENN-GBM      | 611 |             0.929353 |              0.924921 |       -0.00443171 |          0.0327332 |           0.0343699 |      0.00163666 |
| UTSW           | 625 |             0.885258 |              0.88216  |       -0.00309808 |          0.112     |           0.1136    |      0.0016     |
