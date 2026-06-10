# Voxel-wise Feature Learning v1 — Baseline 00 Reproducibility Note

`baseline_00_manifest_contract` is the first no-training baseline. It validates the labeled PASS-only manifests and produces stable distribution plots.

Current result directory:

`/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_00_manifest_contract/`

Current stable outputs:

- `summary.json`
- `REPORT.md`
- `class_counts_mri.csv`
- `cohort_x_class_counts_mri.csv`
- `cohort_counts_mri.csv`
- `roi_counts.csv`
- `visuals/class_counts_mri.png`
- `visuals/cohort_x_class_counts_mri.png`
- `visuals/roi_counts.png`

The plot `cohort_x_class_counts_mri.png` was visually inspected for gross rendering problems: not blank/corrupt, labels and legend readable, bars plausible.

If rerunning B00, overwrite the same files and update `results/LATEST.json`; do not create timestamped duplicates unless the input manifest changes.
