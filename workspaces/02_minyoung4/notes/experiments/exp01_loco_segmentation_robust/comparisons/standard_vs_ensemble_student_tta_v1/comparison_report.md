# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.892077
- delta mean Dice: 0.007800 (CI95 0.005067, 0.010471)
- delta Dice <= 0.5 rate: -0.004947 (CI95 -0.010513, 0.000618)
- delta Dice <= 0.8 rate: -0.012369 (CI95 -0.022882, -0.002474)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.858086 |        0.014197   |          0.187192  |           0.147783  |     -0.0394089  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.801795 |        0.0137263  |          0.359551  |           0.308989  |     -0.0505618  |
| UPENN-GBM      | 611 |             0.923344 |              0.931683 |        0.00833932 |          0.0392799 |           0.0360065 |     -0.00327332 |
| UTSW           | 625 |             0.886603 |              0.89011  |        0.00350662 |          0.104     |           0.1024    |     -0.0016     |
