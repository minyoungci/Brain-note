# G-SURE Research Workspace

G-SURE = Grounded Segmentation Uncertainty and Reliability Estimation.

This workspace is for a fresh research direction centered on 3D glioma MRI
segmentation as a visual grounding problem, not as another Dice-only
segmentation tuning project.

## Core Thesis

Glioma segmentation models should not only predict a tumor mask; they should
also localize where the prediction is visually grounded and where it is likely
to fail under cross-consortium shift.

## Data Premise

The dataset strength is:

- multi-consortium 4-channel structural MRI,
- near-complete tumor segmentation masks,
- subject-level clinical/scanner metadata,
- enough cross-site heterogeneity to test generalization.

## Directory Map

```text
research_gsure/
  00_context/      dataset assumptions, prior-work notes, decision logs
  01_protocol/     official task/cohort/split/metric protocol drafts
  02_audits/       required data audits before modeling
  03_baselines/    baseline contracts and expected outputs
  04_method/       G-SURE method design and ablation plan
  05_reports/      result/report templates after experiments
```

## Current Status

Pre-modeling audits are past the official split gate. Mask inventory,
mask value/geometry audit, target-mapping review, subject-level cohort drafting,
LOCO split-readiness audit, official LOCO split creation, official split
artifact checking, all-consortium bounded loader smoke, and official-split tile
budget/grid dry-run have been completed.

The official split manifest exists and was validated:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
```

Reliability label generation and reliability metric computation are
synthetic-ready only; no real predictions, reliability labels, metrics,
preprocessing cache, GPU training, or raw data mutation has been performed in
this workspace.

## Immediate Gate

Before any GPU job:

1. Lock/review the first segmentation baseline command.
2. Preview the GPU command, expected outputs, and stop criteria.
3. Run GPU only after separate explicit approval.

The next gate is first-baseline GPU command preview and approval, not G-SURE
method training.
