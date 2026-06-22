# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_loco_full_v1_sharedcache`
- n: 1617
- baseline mean Dice: 0.892775
- candidate mean Dice: 0.887774
- delta mean Dice: -0.005001 (CI95 -0.006488, -0.003496)
- delta Dice <= 0.5 rate: 0.001855 (CI95 -0.002474, 0.006803)
- delta Dice <= 0.8 rate: 0.014224 (CI95 0.006184, 0.022263)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.865013 |              0.858043 |       -0.00696982 |          0.152709  |           0.17734   |      0.0246305  |
| UCSD-PTGBM     | 178 |             0.816679 |              0.797452 |       -0.0192265  |          0.275281  |           0.331461  |      0.0561798  |
| UPENN-GBM      | 611 |             0.927747 |              0.925858 |       -0.00188946 |          0.0310966 |           0.0376432 |      0.00654664 |
| UTSW           | 625 |             0.889275 |              0.885923 |       -0.00335222 |          0.1008    |           0.1072    |      0.0064     |
