# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.885765
- delta mean Dice: -0.001620 (CI95 -0.003487, 0.000300)
- delta Dice <= 0.5 rate: 0.001237 (CI95 -0.003092, 0.005566)
- delta Dice <= 0.8 rate: 0.001237 (CI95 -0.006803, 0.009895)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.856072 |       0.000462409 |          0.187192  |           0.147783  |     -0.0394089  |
| UCSD-PTGBM     | 178 |             0.793146 |              0.784768 |      -0.00837803  |          0.331461  |           0.348315  |      0.0168539  |
| UPENN-GBM      | 611 |             0.92651  |              0.926761 |       0.000251461 |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886297 |              0.884095 |      -0.00220243  |          0.1024    |           0.1152    |      0.0128     |
