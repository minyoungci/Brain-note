# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.888930
- delta mean Dice: 0.001545 (CI95 -0.000887, 0.003941)
- delta Dice <= 0.5 rate: 0.004329 (CI95 -0.001237, 0.010513)
- delta Dice <= 0.8 rate: -0.008658 (CI95 -0.017934, 0.000618)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.863941 |        0.00833068 |          0.187192  |           0.147783  |     -0.0394089  |
| UCSD-PTGBM     | 178 |             0.793146 |              0.817655 |        0.024509   |          0.331461  |           0.275281  |     -0.0561798  |
| UPENN-GBM      | 611 |             0.92651  |              0.924921 |       -0.00158822 |          0.0392799 |           0.0343699 |     -0.00490998 |
| UTSW           | 625 |             0.886297 |              0.88216  |       -0.00413712 |          0.1024    |           0.1136    |      0.0112     |
