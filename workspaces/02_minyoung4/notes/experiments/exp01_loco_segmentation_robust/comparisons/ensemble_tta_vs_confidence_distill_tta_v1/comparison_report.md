# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.890254
- delta mean Dice: -0.002521 (CI95 -0.003665, -0.001373)
- delta Dice <= 0.5 rate: 0.002474 (CI95 -0.001237, 0.006803)
- delta Dice <= 0.8 rate: 0.004947 (CI95 -0.001855, 0.011750)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.855791 |      -0.00922187  |          0.152709  |           0.172414  |      0.0197044  |
| UCSD-PTGBM     | 178 |             0.816679 |              0.811482 |      -0.00519682  |          0.275281  |           0.280899  |      0.00561798 |
| UPENN-GBM      | 611 |             0.927747 |              0.926444 |      -0.00130313  |          0.0310966 |           0.0343699 |      0.00327332 |
| UTSW           | 625 |             0.889275 |              0.888503 |      -0.000772512 |          0.1008    |           0.1024    |      0.0016     |
