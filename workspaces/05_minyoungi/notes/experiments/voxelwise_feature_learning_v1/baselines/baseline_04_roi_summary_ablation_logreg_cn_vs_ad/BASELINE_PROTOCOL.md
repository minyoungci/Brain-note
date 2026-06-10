# Baseline 04 Protocol — ROI/stat ablation logistic regression CN vs AD

## Baseline ID

`baseline_04_roi_summary_ablation_logreg_cn_vs_ad`

## Experiment question

baseline_03의 CN vs AD 성능 향상이 ROI volume(voxel_count), ROI intensity distribution, 또는 특정 anatomical ROI 중 무엇에 주로 의해 설명되는가?

## Data/features

- Source run: `baseline_03_roi_summary_logreg_cn_vs_ad`
- Source features: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
- Rows used: 7010
- Classes: CN vs AD, MCI excluded

## Model/evaluation

`StandardScaler + LogisticRegression(max_iter=1000, class_weight="balanced", solver="liblinear", random_state=42)`

- Random split: same subject-disjoint GroupShuffleSplit protocol as baseline_03
- External check: leave-one-cohort-out
- Number of feature sets: 25

## Key results

- Best random ROC-AUC: 0.9004 — `all_roi_all_summary`
- Full summary random ROC-AUC: 0.9004
- Intensity-only random ROC-AUC: 0.8655
- Voxel-count-only random ROC-AUC: 0.8913
- Best single ROI: `single_roi_amygdala_all_summary` random ROC-AUC 0.8640

## Artifacts

See this baseline folder for `summary.json`, `REPORT.md`, `metrics_ablation.csv`, `metrics_loco_by_feature_set.csv`, `predictions_random_split.csv`, and `visuals/*.png`.
