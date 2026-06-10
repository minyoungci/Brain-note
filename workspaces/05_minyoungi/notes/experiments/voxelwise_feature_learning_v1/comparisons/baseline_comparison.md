# Baseline comparison — voxelwise_feature_learning_v1

Note: for `baseline_07_roi_quality_text_status_probe_v0`, `test_roc_auc` means multiclass macro OvR AUC, and `loco_mean_test_roc_auc` means LOCO mean macro OvR AUC. Baseline07 is a shortcut gate, not VLM/image-model evidence.

## baseline_02_roi_mean_logreg_cn_vs_ad

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad`
- class_filter: `CN+AD`
- feature_definition: mean(final_tensor voxels where candidate ROI mask > 0), one feature per ROI
- model: StandardScaler + LogisticRegression(class_weight=balanced, solver=liblinear)
- split: `subject-disjoint GroupShuffleSplit`
- n_train / n_test: `5574` / `1436`
- test_roc_auc: `0.7017578125000001`
- test_balanced_accuracy: `0.6805746822033898`
- test_accuracy: `0.7012534818941504`
- loco_mean_test_roc_auc: ``
- validation_pass: `True`

## baseline_03_roi_summary_logreg_cn_vs_ad

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_03_roi_summary_logreg_cn_vs_ad`
- class_filter: `CN+AD`
- feature_definition: mean/std/median/q05/q25/q75/q95/voxel_count for final_tensor voxels where candidate ROI mask > 0, per ROI
- model: StandardScaler + LogisticRegression(class_weight=balanced, solver=liblinear)
- split: `random_subject_disjoint + leave_one_cohort_out`
- n_train / n_test: `5574` / `1436`
- test_roc_auc: `0.9003773834745763`
- test_balanced_accuracy: `0.8485500529661016`
- test_accuracy: `0.8642061281337048`
- loco_mean_test_roc_auc: `0.8732361148638139`
- validation_pass: `True`

## baseline_04_roi_summary_ablation_logreg_cn_vs_ad

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_04_roi_summary_ablation_logreg_cn_vs_ad`
- class_filter: `CN+AD`
- feature_definition: ROI/stat ablation over baseline_03 ROI summary features
- model: StandardScaler + LogisticRegression(class_weight=balanced, solver=liblinear)
- split: `random_subject_disjoint + leave_one_cohort_out`
- n_train / n_test: `5574` / `1436`
- test_roc_auc: `0.9003806938559321`
- test_balanced_accuracy: `0.8485500529661016`
- test_accuracy: `0.8642061281337048`
- loco_mean_test_roc_auc: `0.8732361148638139`
- validation_pass: `True`

## baseline_05_3d_cnn_cn_vs_ad_smoke

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_05_3d_cnn_cn_vs_ad_smoke`
- class_filter: `CN+AD`
- feature_definition: image-only final_tensor T1w 3D CNN
- model: Small3DCNN(width=32, downsample=2)
- split: `random_subject_disjoint`
- n_train / n_test: `5574` / `1436`
- test_roc_auc: `0.8906498278601694`
- test_balanced_accuracy: `0.831448622881356`
- test_accuracy: `0.8788300835654597`
- loco_mean_test_roc_auc: ``
- validation_pass: `True`

## baseline_06_3d_cnn_loco_cn_vs_ad

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_06_3d_cnn_loco_cn_vs_ad`
- class_filter: `CN+AD`
- feature_definition: image-only final_tensor T1w 3D CNN leave-one-cohort-out
- model: Small3DCNN(width=32, downsample=2)
- split: `leave_one_cohort_out`
- n_train / n_test: `varies_by_fold` / `7010`
- test_roc_auc: `0.8087245622529112`
- test_balanced_accuracy: `0.7146486159506916`
- test_accuracy: `0.7056222728404448`
- loco_mean_test_roc_auc: `0.8087245622529112`
- validation_pass: `True`

## baseline_07_roi_quality_text_status_probe_v0

- baseline_dir: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_07_roi_quality_text_status_probe_v0`
- class_filter: `CN+MCI+AD`
- feature_definition: ROI quality/mask status + ROI text v1 severity one-hot shortcut features; best LOCO bACC feature set registered
- model: StandardScaler + LogisticRegression(class_weight=balanced); dummy most-frequent comparator
- split: `subject_disjoint_internal_test + leave_one_cohort_out`
- n_train / n_test: `7838` / `1680`
- test_roc_auc: `0.7211561021383338`
- test_balanced_accuracy: `0.5494212962962964`
- test_accuracy: `0.5720238095238095`
- loco_mean_test_roc_auc: `0.7027496889209459`
- validation_pass: `True`
