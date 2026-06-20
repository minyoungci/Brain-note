# P2.02 LOCO Segmentation Summary

Completed folds: 4

| run_id                                 | fold_dir                                                                                                | heldout_dataset   |   best_epoch |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:---------------------------------------|:--------------------------------------------------------------------------------------------------------|:------------------|-------------:|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| seg_unet3d_loco_mu_full_v2_validseg    | EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_mu_full_v2_validseg/outer_MU-Glioma-Post | MU-Glioma-Post    |           45 |         0.7 |   0.873774 |      202 |         0.807285 |           0.870614 |              0.884671 |           0.77925  |
| seg_unet3d_loco_ucsd_full_v2_validseg  | EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_ucsd_full_v2_validseg/outer_UCSD-PTGBM   | UCSD-PTGBM        |           36 |         0.8 |   0.874851 |      178 |         0.737953 |           0.807485 |              0.81367  |           0.703794 |
| seg_unet3d_loco_upenn_full_v2_validseg | EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_upenn_full_v2_validseg/outer_UPENN-GBM   | UPENN-GBM         |           43 |         0.3 |   0.846639 |      611 |         0.884677 |           0.90004  |              0.845195 |           0.932911 |
| seg_unet3d_loco_utsw_full_v2_validseg  | EXP_flag/P2_02_segmentation_loco_baseline/runs/seg_unet3d_loco_utsw_full_v2_validseg/outer_UTSW         | UTSW              |           40 |         0.5 |   0.861845 |      621 |         0.851068 |           0.894665 |              0.840168 |           0.888972 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.845830
- median Dice=0.888112
- q10/q25/q75/q90=0.732230 / 0.836842 / 0.916514 / 0.932910
