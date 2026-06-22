# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_three_model_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892077
- candidate mean Dice: 0.892344
- delta mean Dice: 0.000268 (CI95 -0.001772, 0.002263)
- delta Dice <= 0.5 rate: 0.001237 (CI95 -0.003092, 0.005566)
- delta Dice <= 0.8 rate: -0.007421 (CI95 -0.015461, 0.000618)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.858086 |              0.865555 |        0.00746967 |          0.147783  |           0.157635  |      0.00985222 |
| UCSD-PTGBM     | 178 |             0.801795 |              0.81858  |        0.0167849  |          0.308989  |           0.252809  |     -0.0561798  |
| UPENN-GBM      | 611 |             0.931683 |              0.926483 |       -0.00520056 |          0.0360065 |           0.0294599 |     -0.00654664 |
| UTSW           | 625 |             0.89011  |              0.88868  |       -0.00142982 |          0.1024    |           0.1024    |      0          |
