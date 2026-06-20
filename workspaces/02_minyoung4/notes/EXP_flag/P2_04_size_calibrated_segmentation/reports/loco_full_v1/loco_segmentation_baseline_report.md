# P2.02 LOCO Segmentation Summary

Completed folds: 4

| run_id                          | fold_dir                                                                                                               | heldout_dataset   |   best_epoch |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:--------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:------------------|-------------:|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| seg_size_cal_loco_mu_full_v1    | /home/vlm/minyoung4/EXP_flag/P2_04_size_calibrated_segmentation/runs/seg_size_cal_loco_mu_full_v1/outer_MU-Glioma-Post | MU-Glioma-Post    |           41 |         0.6 |   0.871368 |      202 |         0.805279 |           0.868298 |              0.879343 |           0.785606 |
| seg_size_cal_loco_ucsd_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_04_size_calibrated_segmentation/runs/seg_size_cal_loco_ucsd_full_v1/outer_UCSD-PTGBM   | UCSD-PTGBM        |           36 |         0.8 |   0.871324 |      178 |         0.735951 |           0.811007 |              0.817091 |           0.701631 |
| seg_size_cal_loco_upenn_full_v1 | /home/vlm/minyoung4/EXP_flag/P2_04_size_calibrated_segmentation/runs/seg_size_cal_loco_upenn_full_v1/outer_UPENN-GBM   | UPENN-GBM         |           30 |         0.2 |   0.845862 |      611 |         0.885105 |           0.904316 |              0.854512 |           0.924405 |
| seg_size_cal_loco_utsw_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_04_size_calibrated_segmentation/runs/seg_size_cal_loco_utsw_full_v1/outer_UTSW         | UTSW              |           29 |         0.6 |   0.85633  |      621 |         0.838604 |           0.888486 |              0.829785 |           0.878128 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.840718
- median Dice=0.888485
- q10/q25/q75/q90=0.720268 / 0.831360 / 0.916858 / 0.931473
