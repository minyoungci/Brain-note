# P2.02 LOCO Segmentation Summary

Completed folds: 4

| run_id                         | fold_dir                                                                                                       | heldout_dataset   |   best_epoch |   threshold |   val_dice |   test_n |   test_dice_mean |   test_dice_median |   test_precision_mean |   test_recall_mean |
|:-------------------------------|:---------------------------------------------------------------------------------------------------------------|:------------------|-------------:|------------:|-----------:|---------:|-----------------:|-------------------:|----------------------:|-------------------:|
| seg_distill_loco_mu_full_v1    | /home/vlm/minyoung4/EXP_flag/P2_06_ensemble_distillation/runs/seg_distill_loco_mu_full_v1/outer_MU-Glioma-Post | MU-Glioma-Post    |           49 |         0.5 |   0.875982 |      202 |         0.812054 |           0.878442 |              0.889405 |           0.787889 |
| seg_distill_loco_ucsd_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_06_ensemble_distillation/runs/seg_distill_loco_ucsd_full_v1/outer_UCSD-PTGBM   | UCSD-PTGBM        |           36 |         0.8 |   0.884538 |      178 |         0.720898 |           0.797864 |              0.817895 |           0.692344 |
| seg_distill_loco_upenn_full_v1 | /home/vlm/minyoung4/EXP_flag/P2_06_ensemble_distillation/runs/seg_distill_loco_upenn_full_v1/outer_UPENN-GBM   | UPENN-GBM         |           30 |         0.2 |   0.849589 |      611 |         0.888106 |           0.904876 |              0.860222 |           0.923021 |
| seg_distill_loco_utsw_full_v1  | /home/vlm/minyoung4/EXP_flag/P2_06_ensemble_distillation/runs/seg_distill_loco_utsw_full_v1/outer_UTSW         | UTSW              |           40 |         0.5 |   0.861934 |      621 |         0.85352  |           0.897009 |              0.846092 |           0.884501 |

## Subject-Level Aggregate

- n=1612
- mean Dice=0.846789
- median Dice=0.892013
- q10/q25/q75/q90=0.729271 / 0.840920 / 0.919316 / 0.933747
