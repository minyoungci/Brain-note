# Paired LOCO Comparison

- baseline: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_ensemble_student_tta_all_v1`
- candidate: `/home/vlm/minyoung4/experiments/exp01_loco_segmentation_robust/runs/resunet_ds_confidence_distill_tta_all_v1`
- n: 1617
- baseline mean Dice: 0.892077
- candidate mean Dice: 0.890254
- delta mean Dice: -0.001823 (CI95 -0.003886, 0.000129)
- delta Dice <= 0.5 rate: 0.001855 (CI95 -0.002474, 0.006184)
- delta Dice <= 0.8 rate: -0.000618 (CI95 -0.009276, 0.008040)

## Fold Deltas

| fold           |   n |   baseline_mean_dice |   candidate_mean_dice |   delta_mean_dice |   baseline_low_0_8 |   candidate_low_0_8 |   delta_low_0_8 |
|:---------------|----:|---------------------:|----------------------:|------------------:|-------------------:|--------------------:|----------------:|
| MU-Glioma-Post | 203 |             0.858086 |              0.855791 |       -0.00229467 |          0.147783  |           0.172414  |      0.0246305  |
| UCSD-PTGBM     | 178 |             0.801795 |              0.811482 |        0.00968687 |          0.308989  |           0.280899  |     -0.0280899  |
| UPENN-GBM      | 611 |             0.931683 |              0.926444 |       -0.00523895 |          0.0360065 |           0.0343699 |     -0.00163666 |
| UTSW           | 625 |             0.89011  |              0.888503 |       -0.00160717 |          0.1024    |           0.1024    |      0          |
