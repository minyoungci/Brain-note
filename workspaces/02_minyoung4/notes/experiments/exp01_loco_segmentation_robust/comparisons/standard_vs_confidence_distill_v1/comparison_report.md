# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.887774
- delta mean Dice: 0.003497 (CI95 0.000801, 0.006272)
- delta Dice <= 0.5 rate: -0.003711 (CI95 -0.009895, 0.001855)
- delta Dice <= 0.8 rate: -0.003711 (CI95 -0.014224, 0.006184)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.858043 |       0.0141544   |          0.187192  |           0.17734   |     -0.00985222 |
| UCSD-PTGBM     | 178 |             0.788069 |              0.797452 |       0.00938348  |          0.359551  |           0.331461  |     -0.0280899  |
| UPENN-GBM      | 611 |             0.923344 |              0.925858 |       0.00251404  |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886603 |              0.885923 |      -0.000680251 |          0.104     |           0.1072    |      0.0032     |
