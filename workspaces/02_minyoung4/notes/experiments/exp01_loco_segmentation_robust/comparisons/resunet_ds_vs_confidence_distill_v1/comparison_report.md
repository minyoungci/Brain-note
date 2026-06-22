# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.887385
- candidate mean Dice: 0.887774
- delta mean Dice: 0.000389 (CI95 -0.001428, 0.002163)
- delta Dice <= 0.5 rate: 0.000000 (CI95 -0.004947, 0.004947)
- delta Dice <= 0.8 rate: 0.000000 (CI95 -0.009276, 0.008658)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.85561  |              0.858043 |       0.00243318  |          0.187192  |           0.17734   |     -0.00985222 |
| UCSD-PTGBM     | 178 |             0.793146 |              0.797452 |       0.00430644  |          0.331461  |           0.331461  |      0          |
| UPENN-GBM      | 611 |             0.92651  |              0.925858 |      -0.000651791 |          0.0392799 |           0.0376432 |     -0.00163666 |
| UTSW           | 625 |             0.886297 |              0.885923 |      -0.000374201 |          0.1024    |           0.1072    |      0.0048     |
