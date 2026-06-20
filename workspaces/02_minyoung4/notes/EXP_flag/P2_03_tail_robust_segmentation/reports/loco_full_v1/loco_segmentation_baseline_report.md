# P2.02 LOCO Segmentation Summary

Completed folds: 4

| run_id                              | fold_dir                                                                                                               | heldout_dataset   |   best_epoch |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:------------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:------------------|-------------:|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| seg_tail_tversky_loco_mu_full_v1    | /home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_mu_full_v1/outer_MU-Glioma-Post | MU-Glioma-Post    |           31 |         0.8 |   0.869586 |      202 |         0.819777 |           0.877291 |              0.853537 |           0.819632 |
| seg_tail_tversky_loco_ucsd_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_ucsd_full_v1/outer_UCSD-PTGBM   | UCSD-PTGBM        |           43 |         0.8 |   0.879864 |      178 |         0.730335 |           0.801341 |              0.761128 |           0.74326  |
| seg_tail_tversky_loco_upenn_full_v1 | /home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_upenn_full_v1/outer_UPENN-GBM   | UPENN-GBM         |           30 |         0.8 |   0.838242 |      611 |         0.884745 |           0.902761 |              0.851532 |           0.927531 |
| seg_tail_tversky_loco_utsw_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_utsw_full_v1/outer_UTSW         | UTSW              |           41 |         0.8 |   0.858425 |      621 |         0.852811 |           0.894488 |              0.825296 |           0.905963 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.847251
- median Dice=0.889419
- q10/q25/q75/q90=0.734940 / 0.836366 / 0.918092 / 0.932879
