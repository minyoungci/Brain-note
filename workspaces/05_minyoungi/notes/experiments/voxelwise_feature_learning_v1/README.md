# Voxel-wise Feature Learning v1

Goal: run controlled baseline-to-VLM experiments from the PASS-only, labeled voxel-wise ROI dataset without scattering duplicate result files.

## Layered directory policy

```text
configs/    # small JSON configs; one stable file per baseline/model version
scripts/    # reusable scripts only; no one-off notebooks
results/    # one directory per experiment ID, plus LATEST.json pointer
baselines/  # Min-approved baseline snapshots copied from results/ with protocol docs
docs/       # Korean/English experiment notes, result schema, and decision logs
registry/   # machine-readable experiment index snapshots
```

## Current canonical input

- Latest labeled pointer: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/LATEST_LABELED_PASS_ONLY_MANIFEST.json`
- Recommended ROI-pair manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv`
- Recommended MRI manifest: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_mri_manifest.csv`

## Current completed baselines

- `baselines/baseline_02_roi_mean_logreg_cn_vs_ad/` — Min-approved baseline snapshot: 5 ROI mean voxel features + CN vs AD logistic regression; ROC-AUC 0.7018.
- `results/baseline_00_manifest_contract/` — manifest contract + class/cohort/ROI visualizations.
- Baseline registry: `baselines/BASELINE_INDEX.json`
- Latest result pointer: `results/LATEST.json`

## Duplication rule

Do not create timestamped copies for every small rerun. For a named baseline, update the same run directory and `results/LATEST.json`; create a new run directory only when the method, data split, or objective changes.
