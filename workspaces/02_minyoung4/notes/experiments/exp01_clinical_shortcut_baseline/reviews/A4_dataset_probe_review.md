# Review: A4 Dataset Probe

Experiment ID: `A4_dataset_probe`

Files reviewed:

- `configs/b0_clinical_only.json`
- `scripts/run_clinical_shortcut_baseline.py`
- `tests/test_clinical_shortcut_baseline.py`
- `runs/A4_dataset_probe/draft_cpu_loco_v3/`
- `reports/A4_dataset_probe/README.md`

Reviewer role:

- leakage/reproducibility review by sub-agent;
- code-correctness review by sub-agent;
- integration by main agent.

## Summary

`A4_dataset_probe` is implemented as diagnostic-only. It is intentionally separated from
`B0_clinical_only` outputs and must not be used as an official baseline.

## Blocking Findings

Resolved:

- Shared output namespace was corrected so `A4_dataset_probe` metrics and predictions are written
  only under `runs/A4_dataset_probe/<run_id>/`.
- The shared fixed-specificity threshold bug was fixed in the runner.

Current blocking findings:

- None for diagnostic draft use.

## Non-Blocking Findings

- Pure dataset identity is not meaningful under LOCO because the held-out dataset category is
  unseen during training and one-hot encodes to all zeros.
- `age_sex_scanner_dataset_probe` is diagnostic-only and should not be promoted to an official
  model baseline.

## Leakage Status

Acceptable for diagnostic draft.

- The dataset probe is explicitly marked `diagnostic_only`.
- It is namespaced separately from B0 outputs.
- LOCO held-out groups remain isolated.

## Reproducibility Status

Acceptable for draft.

- Run ID: `draft_cpu_loco_v3`
- Output directory: `runs/A4_dataset_probe/draft_cpu_loco_v3/`

## Required Fixes

None remaining before using this as a diagnostic-only check.

Approval for reported results: no. This is diagnostic-only and not a reported baseline.

