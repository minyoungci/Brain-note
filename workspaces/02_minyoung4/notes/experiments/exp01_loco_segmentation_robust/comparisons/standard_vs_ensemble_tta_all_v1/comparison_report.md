# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.892775
- delta mean Dice: 0.008498 (CI95 0.005960, 0.011038)
- delta Dice <= 0.5 rate: -0.005566 (CI95 -0.011750, 0.000000)
- delta Dice <= 0.8 rate: -0.017934 (CI95 -0.027829, -0.008658)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.865013 |        0.0211242  |          0.187192  |           0.152709  |     -0.0344828  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.816679 |        0.02861    |          0.359551  |           0.275281  |     -0.0842697  |
| UPENN-GBM      | 611 |             0.923344 |              0.927747 |        0.0044035  |          0.0392799 |           0.0310966 |     -0.00818331 |
| UTSW           | 625 |             0.886603 |              0.889275 |        0.00267197 |          0.104     |           0.1008    |     -0.0032     |
