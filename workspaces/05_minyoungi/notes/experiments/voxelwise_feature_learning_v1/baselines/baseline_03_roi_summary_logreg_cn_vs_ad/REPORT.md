# Baseline 03 — ROI summary logistic regression CN vs AD

## 실험 질문

CN vs AD를 고정했을 때, 5개 ROI의 mean-only feature보다 mean/std/median/quantile/voxel_count summary feature가 random subject-disjoint split과 leave-one-cohort-out 평가에서 성능과 일반화를 개선하는가?

## 입력/모델

- class: CN vs AD, MCI excluded
- features: 5 ROIs × 8 summary stats = 40 features
- model: StandardScaler + LogisticRegression(class_weight=balanced, solver=liblinear)
- evaluation 1: subject-disjoint random split
- evaluation 2: leave-one-cohort-out

## Random split 결과

- n_train: 5574
- n_test: 1436
- ROC-AUC: **0.9004**
- balanced accuracy: **0.8486**
- accuracy: **0.8642**
- AP(AD): **0.7598**
- confusion matrix `[CN, AD]`: `[[1030, 150], [45, 211]]`

## Leave-one-cohort-out 요약

- evaluated cohorts: 6
- mean ROC-AUC: **0.8732**
- min ROC-AUC: **0.8139**
- max ROC-AUC: **0.9364**
- mean balanced accuracy: **0.7880**

## 산출물

- features: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
- random metrics: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/metrics_random_split.csv`
- random predictions: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/predictions_random_split.csv`
- LOCO metrics: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/metrics_leave_one_cohort_out.csv`
- LOCO predictions: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/predictions_leave_one_cohort_out.csv`

## 주의

이 baseline은 handcrafted ROI scalar baseline이며 representation learning이 아니다. Random split 향상만으로는 일반화라고 해석하지 않고, leave-one-cohort-out 결과를 같이 봐야 한다.
