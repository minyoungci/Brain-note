# Review: B0 Clinical-Only

Experiment ID: `B0_clinical_only`

Files reviewed:

- `configs/b0_clinical_only.json`
- `scripts/run_clinical_shortcut_baseline.py`
- `tests/test_clinical_shortcut_baseline.py`
- `runs/B0_clinical_only/draft_cpu_loco_v3/`
- `reports/B0_clinical_only/README.md`

Reviewer role:

- leakage/reproducibility review by sub-agent;
- code-correctness review by sub-agent;
- integration by main agent.

## Summary

`B0_clinical_only` is implemented as a CPU-only draft baseline for IDH shortcut analysis.
It uses subject-level `eligible_T1_structural_idh`, excludes label conflicts, maps
`wildtype=0` and `mutant=1`, and evaluates logistic regression feature sets under
leave-one-consortium-out evaluation.

## Blocking Findings

Resolved:

- Initial `train_spec90_*` threshold logic did not guarantee train specificity when negative
  probabilities tied at the selected threshold.

Fix:

- `threshold_for_train_specificity()` now moves the threshold just above the selected negative
  probability with `np.nextafter(..., np.inf)`.
- Unit tests now cover threshold ties and end-to-end train-threshold reproduction.

Current blocking findings:

- None for draft CPU baseline use.

## Non-Blocking Findings

- The run is draft-level and not a final paper result.
- Reproducibility metadata records manifest hash and config, but not full environment lock,
  git commit, or dependency freeze.
- Final use still requires exp00 protocol approval.

## Leakage Status

Acceptable for draft.

- LOCO split excludes held-out dataset from training.
- Subject groups do not cross folds.
- Threshold selection uses train-fold predictions only.
- No imaging data, preprocessing, GPU training, or raw-data writes are used.

## Reproducibility Status

Acceptable for draft.

- Run ID: `draft_cpu_loco_v3`
- Output directory: `runs/B0_clinical_only/draft_cpu_loco_v3/`
- Source manifest SHA-256 is recorded in `run_metadata.json`.

## Required Fixes

None remaining before using this as a draft shortcut floor.

Approval for reported results: no. This remains draft until exp00 protocol approval and final
reproducibility metadata are locked.

