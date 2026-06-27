# Stage 31: Reliability Metric Contract

## Task

Define the metric contract for G-SURE reliability/error-localization results.

## Research Question

What metrics are required before claiming that a method improves visual
grounding or reliability beyond Dice-only segmentation?

## Added Artifact

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
```

## Key Requirements

The metric contract requires:

- Dice and Dice failure rate,
- voxel-level ERR AUROC/AUPRC,
- voxel-level FP AUROC/AUPRC,
- voxel-level FN AUROC/AUPRC,
- top-k error capture at fixed review budgets,
- reliability-error calibration,
- QU-BraTS-style uncertainty filtering curves,
- subject-level `Dice <= 0.8` detection,
- per-consortium and lesion-size-stratified reporting.

## Why This Matters

Aggregate ERR metrics can hide failure modes:

- a method may only highlight boundaries,
- FP localization may fail while FN localization works,
- subject failure detection may be solved by lesion size,
- pooled metrics may improve while a held-out consortium collapses.

Therefore FP/FN separation, calibration, top-k review budget, and
consortium-stratified reporting are mandatory.

## Linked Files

Updated:

```text
research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md
research_gsure/03_baselines/BASELINE_CONTRACT.md
research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md
research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md
research_gsure/05_reports/REPORT_TEMPLATE.md
```

## Current Status

This is a contract only. No predictions, reliability labels, metric outputs, or
research claims exist.

## Validation Required

Run:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "RELIABILITY_METRIC_CONTRACT|top-k|QU-BraTS|FP AUPRC|FN AUPRC|calibration" research_gsure SCRATCHPAD.md
git diff --check
```

## Remaining Gate

Official split creation, GPU training, prediction generation, metric
computation, and reliability label generation remain approval-gated.
