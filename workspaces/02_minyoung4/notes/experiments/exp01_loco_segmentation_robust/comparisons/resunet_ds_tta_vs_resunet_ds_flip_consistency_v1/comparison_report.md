# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.889639
- candidate mean Dice: 0.883842
- delta mean Dice: -0.005797 (CI95 -0.007952, -0.003794)
- delta Dice <= 0.5 rate: 0.005566 (CI95 0.000000, 0.011132)
- delta Dice <= 0.8 rate: 0.002474 (CI95 -0.005566, 0.010513)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.860463 |              0.845853 |       -0.0146108  |          0.167488  |           0.182266  |      0.0147783  |
| UCSD-PTGBM     | 178 |             0.801969 |              0.781448 |       -0.020521   |          0.320225  |           0.337079  |      0.0168539  |
| UPENN-GBM      | 611 |             0.929353 |              0.929679 |        0.00032556 |          0.0327332 |           0.0294599 |     -0.00327332 |
| UTSW           | 625 |             0.885258 |              0.880533 |       -0.00472589 |          0.112     |           0.112     |      0          |
