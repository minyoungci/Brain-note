# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/unet_flip_consistency_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.884277
- candidate mean Dice: 0.882868
- delta mean Dice: -0.001409 (CI95 -0.004078, 0.001082)
- delta Dice <= 0.5 rate: 0.000000 (CI95 -0.005566, 0.004947)
- delta Dice <= 0.8 rate: 0.001855 (CI95 -0.008040, 0.011132)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.843889 |              0.841659 |       -0.00223018 |          0.187192  |           0.20197   |      0.0147783  |
| UCSD-PTGBM     | 178 |             0.788069 |              0.772607 |       -0.0154618  |          0.359551  |           0.337079  |     -0.0224719  |
| UPENN-GBM      | 611 |             0.923344 |              0.927325 |        0.00398123 |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886603 |              0.884193 |       -0.00241044 |          0.104     |           0.112     |      0.008      |
