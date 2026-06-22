# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.888930
- delta mean Dice: 0.004653 (CI95 0.001918, 0.007449)
- delta Dice <= 0.5 rate: 0.000618 (CI95 -0.005566, 0.006803)
- delta Dice <= 0.8 rate: -0.012369 (CI95 -0.022263, -0.002474)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.863941 |        0.0200519  |          0.187192  |           0.147783  |     -0.0394089  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.817655 |        0.029586   |          0.359551  |           0.275281  |     -0.0842697  |
| UPENN-GBM      | 611 |             0.923344 |              0.924921 |        0.00157761 |          0.0392799 |           0.0343699 |     -0.00490998 |
| UTSW           | 625 |             0.886603 |              0.88216  |       -0.00444317 |          0.104     |           0.1136    |      0.0096     |
