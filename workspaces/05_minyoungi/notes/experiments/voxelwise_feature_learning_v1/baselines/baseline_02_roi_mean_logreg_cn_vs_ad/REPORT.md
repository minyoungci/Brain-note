# Baseline 02 — ROI mean voxel feature logistic regression CN vs AD

## 목적

가장 단순한 ROI scalar baseline: 각 MRI의 5개 ROI mask 안에서 z-scored voxel intensity 평균을 계산하고, 이 5차원 feature로 CN vs AD logistic regression을 평가한다.

## 입력

- MRI manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_mri_manifest.csv`
- ROI-pair manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv`
- class filter: CN vs AD only; MCI excluded
- split: subject-disjoint `GroupShuffleSplit(test_size=0.2, random_state=42)`
- positive class: AD

## 결과

- feature rows total: 7010
- feature rows ok: 7010
- feature extraction errors: 0
- train rows: 5574
- test rows: 1436
- train subject groups: 3127
- test subject groups: 782
- train class counts: `{'CN': 4536, 'AD': 1038}`
- test class counts: `{'CN': 1180, 'AD': 256}`
- test ROC-AUC: **0.7018**
- test balanced accuracy: **0.6806**
- test accuracy: **0.7013**
- test average precision for AD: **0.3825**
- confusion matrix labels: `[CN, AD]`
- confusion matrix: `[[841, 339], [90, 166]]`

## 산출물

- features: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/features.csv`
- predictions: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/predictions.csv`
- summary: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/summary.json`
- visuals: `['/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/visuals/roi_mean_by_class.png', '/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/visuals/roc_curve_cn_vs_ad.png', '/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/visuals/logreg_coefficients.png']`

## 해석 주의

이 baseline은 representation learning이 아니라 ROI 평균 intensity sanity-check이다. 이미지가 brain-wise z-score 되어 있어 absolute intensity interpretation은 제한적이다. 그래도 CN vs AD가 어느 정도 분리되는지 확인하는 가장 작은 하한선으로 사용한다.
