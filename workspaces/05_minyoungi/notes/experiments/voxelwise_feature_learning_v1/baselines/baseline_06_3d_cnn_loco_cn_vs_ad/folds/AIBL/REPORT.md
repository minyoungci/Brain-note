# Baseline 06 — image-only 3D CNN LOCO CN vs AD

## Question

image-only 3D CNN CN vs AD 성능이 leave-one-cohort-out에서도 유지되는가, 그리고 결과가 명백한 leakage로 설명되지 않는가?

## Summary

- heldout cohorts: 1
- mean ROC-AUC: **0.8576**
- min ROC-AUC: **0.8576**
- max ROC-AUC: **0.8576**
- mean balanced accuracy: **0.7827**
- leakage audit pass: **True**

## Input policy

Only final_tensor voxel arrays are fed to the model. ROI features/masks, cohort/scanner metadata, age/sex, and diagnosis text are not model inputs.

## Artifacts

- metrics: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_06_3d_cnn_loco_cn_vs_ad_folds/AIBL/metrics_leave_one_cohort_out.csv`
- predictions: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_06_3d_cnn_loco_cn_vs_ad_folds/AIBL/predictions_leave_one_cohort_out.csv`
- leakage audit: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_06_3d_cnn_loco_cn_vs_ad_folds/AIBL/leakage_audit.json`
- summary: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_06_3d_cnn_loco_cn_vs_ad_folds/AIBL/summary.json`
