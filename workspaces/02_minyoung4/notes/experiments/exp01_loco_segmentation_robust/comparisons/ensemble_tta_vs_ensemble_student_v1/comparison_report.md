# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.885765
- delta mean Dice: -0.007010 (CI95 -0.009016, -0.005096)
- delta Dice <= 0.5 rate: 0.003092 (CI95 -0.001855, 0.008040)
- delta Dice <= 0.8 rate: 0.015461 (CI95 0.007421, 0.024119)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.856072 |      -0.0089406   |          0.152709  |           0.147783  |     -0.00492611 |
| UCSD-PTGBM     | 178 |             0.816679 |              0.784768 |      -0.031911    |          0.275281  |           0.348315  |      0.0730337  |
| UPENN-GBM      | 611 |             0.927747 |              0.926761 |      -0.000986209 |          0.0310966 |           0.0376432 |      0.00654664 |
| UTSW           | 625 |             0.889275 |              0.884095 |      -0.00518044  |          0.1008    |           0.1152    |      0.0144     |
