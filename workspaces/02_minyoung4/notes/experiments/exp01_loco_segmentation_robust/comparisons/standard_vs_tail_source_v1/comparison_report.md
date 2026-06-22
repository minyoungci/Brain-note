# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.878937
- delta mean Dice: -0.005340 (CI95 -0.007761, -0.002890)
- delta Dice <= 0.5 rate: 0.001237 (CI95 -0.003711, 0.006803)
- delta Dice <= 0.8 rate: 0.007421 (CI95 -0.002474, 0.017934)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.828145 |      -0.0157434   |          0.187192  |           0.231527  |       0.044335  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.788884 |       0.000815671 |          0.359551  |           0.314607  |      -0.0449438 |
| UPENN-GBM      | 611 |             0.923344 |              0.915052 |      -0.00829226  |          0.0392799 |           0.0572831 |       0.0180033 |
| UTSW           | 625 |             0.886603 |              0.885776 |      -0.000827222 |          0.104     |           0.104     |       0         |
