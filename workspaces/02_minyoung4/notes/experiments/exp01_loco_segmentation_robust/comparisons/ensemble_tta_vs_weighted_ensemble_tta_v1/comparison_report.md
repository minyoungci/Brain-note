# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_weighted_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.891906
- delta mean Dice: -0.000869 (CI95 -0.001551, -0.000396)
- delta Dice <= 0.5 rate: 0.002474 (CI95 0.000618, 0.005566)
- delta Dice <= 0.8 rate: 0.001237 (CI95 -0.001237, 0.004329)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.862321 |      -0.00269168  |          0.152709  |           0.162562  |      0.00985222 |
| UCSD-PTGBM     | 178 |             0.816679 |              0.816987 |       0.000308507 |          0.275281  |           0.280899  |      0.00561798 |
| UPENN-GBM      | 611 |             0.927747 |              0.926252 |      -0.00149517  |          0.0310966 |           0.0294599 |     -0.00163666 |
| UTSW           | 625 |             0.889275 |              0.889275 |       0           |          0.1008    |           0.1008    |      0          |
