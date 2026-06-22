# Paired LOCO Comparison

- baseline: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.892077
- delta mean Dice: -0.000698 (CI95 -0.002478, 0.001103)
- delta Dice <= 0.5 rate: 0.000618 (CI95 -0.003711, 0.004947)
- delta Dice <= 0.8 rate: 0.005566 (CI95 -0.002474, 0.013605)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.858086 |      -0.00692721  |          0.152709  |           0.147783  |     -0.00492611 |
| UCSD-PTGBM     | 178 |             0.816679 |              0.801795 |      -0.0148837   |          0.275281  |           0.308989  |      0.0337079  |
| UPENN-GBM      | 611 |             0.927747 |              0.931683 |       0.00393582  |          0.0310966 |           0.0360065 |      0.00490998 |
| UTSW           | 625 |             0.889275 |              0.89011  |       0.000834656 |          0.1008    |           0.1024    |      0.0016     |
