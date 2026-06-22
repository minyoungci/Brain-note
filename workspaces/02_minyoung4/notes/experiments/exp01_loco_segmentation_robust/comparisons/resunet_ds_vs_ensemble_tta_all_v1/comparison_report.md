# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.892775
- delta mean Dice: 0.005390 (CI95 0.003579, 0.007194)
- delta Dice <= 0.5 rate: -0.001855 (CI95 -0.006803, 0.003092)
- delta Dice <= 0.8 rate: -0.014224 (CI95 -0.022263, -0.006184)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.865013 |        0.009403   |          0.187192  |           0.152709  |     -0.0344828  |
| UCSD-PTGBM     | 178 |             0.793146 |              0.816679 |        0.023533   |          0.331461  |           0.275281  |     -0.0561798  |
| UPENN-GBM      | 611 |             0.92651  |              0.927747 |        0.00123767 |          0.0392799 |           0.0310966 |     -0.00818331 |
| UTSW           | 625 |             0.886297 |              0.889275 |        0.00297801 |          0.1024    |           0.1008    |     -0.0016     |
