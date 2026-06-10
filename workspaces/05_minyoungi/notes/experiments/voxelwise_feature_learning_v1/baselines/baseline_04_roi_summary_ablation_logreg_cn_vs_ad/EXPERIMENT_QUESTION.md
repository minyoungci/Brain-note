# Experiment question — baseline_04_roi_summary_ablation_logreg_cn_vs_ad

## Question

baseline_03의 CN vs AD 성능 향상이 ROI volume(voxel_count), ROI intensity distribution, 또는 특정 anatomical ROI 중 무엇에 주로 의해 설명되는가?

## Design

- Source features: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
- Same CN/AD rows and baseline_03 feature extraction.
- Same subject-disjoint GroupShuffleSplit random_state/test_size.
- Same leave-one-cohort-out external check.
- Feature subsets: full summary, intensity-only, voxel_count-only, stat-family-only, and ROI-by-ROI subsets.

## Decision rule

- If `all_roi_voxel_count_only` is close to full baseline_03, the apparent signal is mainly ROI volume/mask size.
- If `all_roi_intensity_only_no_voxel_count` stays strong, voxel intensity distribution contributes beyond volume.
- Single-ROI results identify which anatomical ROI dominates before moving to image-only 3D CNN.
