# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_three_model_ensemble_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.892344
- delta mean Dice: 0.008067 (CI95 0.005448, 0.010681)
- delta Dice <= 0.5 rate: -0.003711 (CI95 -0.009276, 0.001855)
- delta Dice <= 0.8 rate: -0.019790 (CI95 -0.029685, -0.009895)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.865555 |        0.0216667  |          0.187192  |           0.157635  |     -0.0295567  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.81858  |        0.0305112  |          0.359551  |           0.252809  |     -0.106742   |
| UPENN-GBM      | 611 |             0.923344 |              0.926483 |        0.00313875 |          0.0392799 |           0.0294599 |     -0.00981997 |
| UTSW           | 625 |             0.886603 |              0.88868  |        0.0020768  |          0.104     |           0.1024    |     -0.0016     |
