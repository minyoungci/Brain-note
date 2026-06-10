# Baseline 04 — ROI summary ablation logistic regression CN vs AD

## 실험 질문

baseline_03의 CN vs AD 성능 향상이 ROI volume(voxel_count), ROI intensity distribution, 또는 특정 anatomical ROI 중 무엇에 주로 의해 설명되는가?

## 핵심 결과

- Best random ROC-AUC: **0.9004** — `all_roi_all_summary`
- Full summary random ROC-AUC: **0.9004**
- Intensity-only random ROC-AUC: **0.8655**
- Voxel-count-only random ROC-AUC: **0.8913**
- Best single ROI random ROC-AUC: **0.8640** — `single_roi_amygdala_all_summary`
- Best single ROI LOCO mean ROC-AUC: **0.8373** — `single_roi_hippocampus_all_summary`

## Top feature sets by random ROC-AUC

| feature_set_id                                     | category                    |   n_features |   random_test_roc_auc |   random_test_balanced_accuracy |   loco_mean_test_roc_auc |   loco_mean_test_balanced_accuracy |
|:---------------------------------------------------|:----------------------------|-------------:|----------------------:|--------------------------------:|-------------------------:|-----------------------------------:|
| all_roi_all_summary                                | full_reference              |           40 |              0.900381 |                        0.84855  |                 0.873236 |                           0.788004 |
| all_roi_voxel_count_only                           | stat_ablation               |            5 |              0.891261 |                        0.82351  |                 0.87108  |                           0.803508 |
| all_roi_intensity_only_no_voxel_count              | stat_ablation               |           35 |              0.865529 |                        0.810302 |                 0.847861 |                           0.755708 |
| single_roi_amygdala_all_summary                    | single_roi_all_summary      |            8 |              0.86398  |                        0.791803 |                 0.824882 |                           0.752208 |
| single_roi_amygdala_voxel_count_only               | single_roi_voxel_count_only |            1 |              0.861328 |                        0.774153 |                 0.818291 |                           0.746643 |
| single_roi_hippocampus_all_summary                 | single_roi_all_summary      |            8 |              0.845034 |                        0.780767 |                 0.837281 |                           0.772432 |
| single_roi_parahippocampal_cortex_all_summary      | single_roi_all_summary      |            8 |              0.834501 |                        0.77408  |                 0.808986 |                           0.73145  |
| single_roi_hippocampus_voxel_count_only            | single_roi_voxel_count_only |            1 |              0.830333 |                        0.767704 |                 0.827652 |                           0.757367 |
| all_roi_q05_only                                   | single_stat_all_roi         |            5 |              0.807332 |                        0.728939 |                 0.817412 |                           0.747797 |
| single_roi_parahippocampal_cortex_voxel_count_only | single_roi_voxel_count_only |            1 |              0.794581 |                        0.729899 |                 0.764525 |                           0.691645 |
| single_roi_lateral_ventricle_all_summary           | single_roi_all_summary      |            8 |              0.791479 |                        0.729952 |                 0.799067 |                           0.724025 |
| single_roi_lateral_ventricle_intensity_only        | single_roi_intensity_only   |            7 |              0.786891 |                        0.728019 |                 0.791019 |                           0.712063 |

## ROI별 결과

| feature_set_id                                     | category                    |   n_features |   random_test_roc_auc |   random_test_balanced_accuracy |   loco_mean_test_roc_auc |   loco_mean_test_balanced_accuracy |
|:---------------------------------------------------|:----------------------------|-------------:|----------------------:|--------------------------------:|-------------------------:|-----------------------------------:|
| single_roi_amygdala_all_summary                    | single_roi_all_summary      |            8 |              0.86398  |                        0.791803 |                 0.824882 |                           0.752208 |
| single_roi_amygdala_voxel_count_only               | single_roi_voxel_count_only |            1 |              0.861328 |                        0.774153 |                 0.818291 |                           0.746643 |
| single_roi_hippocampus_all_summary                 | single_roi_all_summary      |            8 |              0.845034 |                        0.780767 |                 0.837281 |                           0.772432 |
| single_roi_parahippocampal_cortex_all_summary      | single_roi_all_summary      |            8 |              0.834501 |                        0.77408  |                 0.808986 |                           0.73145  |
| single_roi_hippocampus_voxel_count_only            | single_roi_voxel_count_only |            1 |              0.830333 |                        0.767704 |                 0.827652 |                           0.757367 |
| single_roi_parahippocampal_cortex_voxel_count_only | single_roi_voxel_count_only |            1 |              0.794581 |                        0.729899 |                 0.764525 |                           0.691645 |
| single_roi_lateral_ventricle_all_summary           | single_roi_all_summary      |            8 |              0.791479 |                        0.729952 |                 0.799067 |                           0.724025 |
| single_roi_lateral_ventricle_intensity_only        | single_roi_intensity_only   |            7 |              0.786891 |                        0.728019 |                 0.791019 |                           0.712063 |
| single_roi_parahippocampal_cortex_intensity_only   | single_roi_intensity_only   |            7 |              0.781134 |                        0.708766 |                 0.767206 |                           0.695872 |
| single_roi_hippocampus_intensity_only              | single_roi_intensity_only   |            7 |              0.751483 |                        0.715784 |                 0.743695 |                           0.673189 |
| single_roi_lateral_ventricle_voxel_count_only      | single_roi_voxel_count_only |            1 |              0.730148 |                        0.673696 |                 0.753367 |                           0.683221 |
| single_roi_amygdala_intensity_only                 | single_roi_intensity_only   |            7 |              0.6678   |                        0.641406 |                 0.677468 |                           0.645347 |
| single_roi_thalamus_all_summary                    | single_roi_all_summary      |            8 |              0.662179 |                        0.611196 |                 0.673707 |                           0.619657 |
| single_roi_thalamus_voxel_count_only               | single_roi_voxel_count_only |            1 |              0.638283 |                        0.57886  |                 0.656863 |                           0.596442 |
| single_roi_thalamus_intensity_only                 | single_roi_intensity_only   |            7 |              0.636811 |                        0.586275 |                 0.616001 |                           0.557885 |

## 산출물

- metrics: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_04_roi_summary_ablation_logreg_cn_vs_ad/metrics_ablation.csv`
- LOCO per cohort: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_04_roi_summary_ablation_logreg_cn_vs_ad/metrics_loco_by_feature_set.csv`
- random predictions: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_04_roi_summary_ablation_logreg_cn_vs_ad/predictions_random_split.csv`
- summary: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_04_roi_summary_ablation_logreg_cn_vs_ad/summary.json`
- visuals: `visuals/*.png`

## 해석 주의

이 실험은 handcrafted ROI scalar baseline의 shortcut/ablation gate다. 3D CNN/VLM의 성능이 아니며, voxel_count는 final tensor grid에서 ROI mask size/volume proxy로 해석해야 한다.
