# P2.03 Threshold Re-scan Summary

Completed folds: 4
Threshold grid: 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.85, 0.90, 0.95

| run_id                              | fold_dir                                                                                           | heldout_dataset   | checkpoint                  |   old_best_epoch |   old_threshold |   old_val_dice |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:------------------------------------|:---------------------------------------------------------------------------------------------------|:------------------|:----------------------------|-----------------:|----------------:|---------------:|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| seg_tail_tversky_loco_mu_full_v1    | EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_mu_full_v1/outer_MU-Glioma-Post | MU-Glioma-Post    | checkpoint_best_val_dice.pt |               31 |             0.8 |       0.869586 |        0.95 |   0.872126 |      202 |         0.814389 |           0.871903 |              0.872252 |           0.793444 |
| seg_tail_tversky_loco_ucsd_full_v1  | EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_ucsd_full_v1/outer_UCSD-PTGBM   | UCSD-PTGBM        | checkpoint_best_val_dice.pt |               43 |             0.8 |       0.879864 |        0.95 |   0.881458 |      178 |         0.729109 |           0.803008 |              0.780537 |           0.723462 |
| seg_tail_tversky_loco_upenn_full_v1 | EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_upenn_full_v1/outer_UPENN-GBM   | UPENN-GBM         | checkpoint_best_val_dice.pt |               30 |             0.8 |       0.838242 |        0.8  |   0.83825  |      611 |         0.884744 |           0.902761 |              0.851532 |           0.927531 |
| seg_tail_tversky_loco_utsw_full_v1  | EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_utsw_full_v1/outer_UTSW         | UTSW              | checkpoint_best_val_dice.pt |               41 |             0.8 |       0.858425 |        0.95 |   0.861162 |      621 |         0.855614 |           0.897843 |              0.848634 |           0.885251 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.847521
- median Dice=0.889796
- q10/q25/q75/q90=0.733602 / 0.835221 / 0.918159 / 0.933204
