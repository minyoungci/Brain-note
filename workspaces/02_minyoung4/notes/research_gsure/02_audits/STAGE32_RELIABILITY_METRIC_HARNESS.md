# Stage 32 - Reliability Metric Harness

## Task

Add a CPU-only metric harness for the G-SURE reliability/error-localization
contract.

## Research Question

Can future segmentation predictions be evaluated for error localization,
reliability calibration, and failure detection in a leakage-aware, reproducible
way?

## What Changed

- Added `research_gsure/02_audits/scripts/compute_reliability_metrics.py`.
- Connected the script to pre-split readiness checks.
- Linked the metric implementation from the reliability metric contract,
  experiment readiness checklist, and report template.

## What The Harness Computes

- Dice and low-Dice subject failure rate.
- ERR, FP, and FN AUROC/AUPRC from a risk map.
- SOFT_ERROR Spearman correlation.
- Top-k error capture at 0.5%, 1%, 2%, and 5% voxel review budgets.
- Reliability-error expected calibration error.
- QU-BraTS-style risk filtering summaries.
- Subject-level failure AUROC/AUPRC from mean, p95, and high-risk fraction
  scores.
- Overall, per-consortium, and lesion-size-bin sampled voxel summaries.

## Guardrails

- The script does not create official splits.
- The script does not run inference or training.
- The script does not generate predictions or reliability labels.
- Real use requires validated OOF predictions and validated reliability label
  manifests.
- `soft_error_map_path` may be used only as an oracle diagnostic upper-bound,
  not as a method prediction.

## Validation

Planned validation:

```bash
python -m py_compile \
  research_gsure/02_audits/scripts/compute_reliability_metrics.py \
  research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/compute_reliability_metrics.py --synthetic-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
git diff --check
```

## Current Status

Synthetic-ready only. No real prediction, reliability label, or metric output
exists yet.
