# Baseline 03 Protocol — ROI summary logistic regression CN vs AD

## Baseline ID

`baseline_03_roi_summary_logreg_cn_vs_ad`

## Experiment question

CN vs AD를 고정했을 때, 5개 ROI의 mean-only feature보다 mean/std/median/quantile/voxel_count summary feature가 random subject-disjoint split과 leave-one-cohort-out 평가에서 성능과 일반화를 개선하는가?

## Data

- MRI manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_mri_manifest.csv`
- ROI-pair manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv`
- MRI manifest SHA256: `1b500b9c2c3d65c59f886e5ed807dad506eb96f2ef38913ac26e2fa1e86843ad`
- ROI-pair manifest SHA256: `dd61c3816e0a36fad60f42257c8bba0a57c524f47e0904e38af6e1b27073861f`

## Features

5 ROIs × 8 summary stats = 40 features.

ROIs: `['hippocampus', 'amygdala', 'thalamus', 'lateral_ventricle', 'parahippocampal_cortex']`

Stats: `['mean', 'std', 'median', 'q05', 'q25', 'q75', 'q95', 'voxel_count']`

## Model and training

`StandardScaler + LogisticRegression(max_iter=1000, class_weight="balanced", solver="liblinear", random_state=42)`

- Task: CN vs AD
- Positive class: AD
- Excluded class: MCI
- Random split: subject-disjoint GroupShuffleSplit test_size=0.2
- External check: leave-one-cohort-out

## Results

- Random split ROC-AUC: 0.9004
- Random split balanced accuracy: 0.8486
- LOCO mean ROC-AUC: 0.8732
- LOCO mean balanced accuracy: 0.7880

## Artifacts

See this baseline folder for `summary.json`, `REPORT.md`, `features.csv`, metrics/predictions CSVs, and `visuals/*.png`.
