# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.890254
- delta mean Dice: 0.000616 (CI95 -0.000852, 0.002120)
- delta Dice <= 0.5 rate: -0.001237 (CI95 -0.006184, 0.003108)
- delta Dice <= 0.8 rate: -0.006803 (CI95 -0.014842, 0.001237)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.855791 |       -0.00467232 |          0.167488  |           0.172414  |      0.00492611 |
| UCSD-PTGBM     | 178 |             0.801969 |              0.811482 |        0.00951332 |          0.320225  |           0.280899  |     -0.0393258  |
| UPENN-GBM      | 611 |             0.929353 |              0.926444 |       -0.00290895 |          0.0327332 |           0.0343699 |      0.00163666 |
| UTSW           | 625 |             0.885258 |              0.888503 |        0.00324454 |          0.112     |           0.1024    |     -0.0096     |
