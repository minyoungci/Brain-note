# P2.05 Checkpoint Ensemble Summary

Completed folds: 4
TTA mode: single
Threshold grid: 0.20, 0.30, 0.40, 0.50, 0.60, 0.70, 0.80, 0.85, 0.90, 0.95

| run_id                            | fold_dir                                                                                                                                                                                                                                           | heldout_dataset   | members   |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:----------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------|:----------|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| p202_p203_ensemble_MU-Glioma-Post | /home/vlm/minyoung4/EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_mu_full_v2_validseg/outer_MU-Glioma-Post+/home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_mu_full_v1/outer_MU-Glioma-Post | MU-Glioma-Post    | p202,p203 |         0.7 |   0.872838 |      202 |         0.807345 |           0.872436 |              0.895267 |           0.774124 |
| p202_p203_ensemble_UCSD-PTGBM     | /home/vlm/minyoung4/EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_ucsd_full_v2_validseg/outer_UCSD-PTGBM+/home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_ucsd_full_v1/outer_UCSD-PTGBM     | UCSD-PTGBM        | p202,p203 |         0.7 |   0.880732 |      178 |         0.73093  |           0.808795 |              0.839786 |           0.695819 |
| p202_p203_ensemble_UPENN-GBM      | /home/vlm/minyoung4/EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_upenn_full_v2_validseg/outer_UPENN-GBM+/home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_upenn_full_v1/outer_UPENN-GBM     | UPENN-GBM         | p202,p203 |         0.4 |   0.847211 |      611 |         0.885184 |           0.899869 |              0.838001 |           0.942834 |
| p202_p203_ensemble_UTSW           | /home/vlm/minyoung4/EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_utsw_full_v2_validseg/outer_UTSW+/home/vlm/minyoung4/EXP_flag/P2_03_tail_robust_segmentation/runs/seg_tail_tversky_loco_utsw_full_v1/outer_UTSW                 | UTSW              | p202,p203 |         0.6 |   0.865984 |      621 |         0.857939 |           0.898073 |              0.846673 |           0.893262 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.847901
- median Dice=0.889555
- q10/q25/q75/q90=0.739686 / 0.841176 / 0.916756 / 0.933659
