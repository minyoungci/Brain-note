# Reliability and Error-Localization Metric Contract

## Scope

This document defines the required evaluation metrics for G-SURE reliability,
uncertainty, QC, and grounding experiments.

This document does not approve:

- official split creation,
- GPU training,
- inference,
- prediction generation,
- reliability label generation.

## Research Goal Reminder

G-SURE is not a Dice-only segmentation study. A method is useful only if it
localizes actual segmentation errors and predicts segmentation failure under
held-out consortium shift better than standard uncertainty and QC baselines.

## Eligibility

Metrics may be reported only on predictions that satisfy:

- official split membership,
- full-volume assembled prediction,
- OOF or held-out prediction status,
- prediction metadata validator pass,
- prediction artifact validator pass,
- label manifest validator pass when reliability labels are used.

The current metric implementation harness is:

```text
research_gsure/02_audits/scripts/compute_reliability_metrics.py
```

It is CPU-only and currently validated only by a synthetic self-test. Running it
on real outputs requires validated OOF predictions and validated reliability
label manifests.

Predictions that are in-sample, patch-only, center-crop-only, missing
provenance, or generated with mask-based test-time tile placement are not
eligible for headline metrics.

## Core Definitions

For each subject:

```text
GT = selected_mask > 0
P  = full-volume probability map in [0, 1]
B  = P >= predeclared threshold
R  = reliability / uncertainty / error-risk map, higher means more likely error
```

Primary error maps:

```text
FN  = (GT == 1) and (B == 0)
FP  = (GT == 0) and (B == 1)
ERR = FN or FP
SOFT_ERROR = abs(GT.astype(float) - P)
```

If a method emits confidence instead of risk, convert it before evaluation:

```text
R = 1 - confidence
```

## Required Segmentation Metrics

Report for every segmentation-producing method:

- Dice,
- Dice by consortium,
- Dice by lesion-size bin,
- `Dice <= 0.8` subject failure rate,
- predicted volume and predicted/GT volume ratio,
- optional HD95 or surface Dice only if implementation is reviewed.

Dice is necessary but not sufficient for the G-SURE claim.

## Required Voxel-Level Reliability Metrics

Report for every method that emits `R`:

1. ERR AUROC.
2. ERR AUPRC.
3. FP AUROC.
4. FP AUPRC.
5. FN AUROC.
6. FN AUPRC.
7. SOFT_ERROR Spearman correlation, if `R` is continuous.

Hard rule:

```text
FP and FN must be reported separately.
```

Rationale: a reliability map that only highlights uncertain boundaries can look
reasonable on aggregate ERR while failing to localize false positives or false
negatives.

## Top-K Error Capture

For each subject and for pooled held-out rows, sort voxels by descending `R`.

Report:

- error capture at top 0.5%, 1%, 2%, and 5% voxels,
- FP capture at the same budgets,
- FN capture at the same budgets,
- captured error voxels per 1,000 reviewed voxels.

These metrics simulate limited manual review budget. They must not be tuned on
held-out test performance.

## Reliability-Error Calibration

Bin voxels or sampled voxels by predicted risk `R`.

Required reporting:

- observed ERR rate per risk bin,
- expected calibration error for ERR,
- reliability diagram by consortium,
- calibration slope/intercept if a calibration model is fitted.

Any calibration model must be fitted using train-consortia predictions only.
Held-out consortium labels may not be used for calibration fitting.

## QU-BraTS-Style Filtering Curve

For the binary whole-lesion target, adapt the BraTS uncertainty evaluation:

1. Sweep risk thresholds from permissive to strict.
2. Filter out voxels with high `R`.
3. Compute Dice on remaining, unfiltered voxels.
4. Compute filtered true-positive ratio.
5. Compute filtered true-negative ratio.
6. Summarize the area under:
   - Dice-vs-threshold curve,
   - filtered-TP ratio curve,
   - filtered-TN ratio curve.

Required interpretation:

- High Dice after filtering is not enough.
- A method is penalized if it filters too many correct tumor or background
  voxels.

## Subject-Level Failure Detection

Define:

```text
subject_failure_dice_le_0.8 = Dice(B, GT) <= 0.8
```

For every subject-level score derived from `R`, uncertainty, QC model, lesion
size, or predicted volume, report:

- AUROC,
- AUPRC,
- sensitivity at fixed specificity if predeclared,
- calibration by consortium,
- per-consortium failure rate.

Required naive baselines:

- GT lesion volume, diagnostic only and not available at test-time,
- predicted lesion volume,
- predicted/GT volume ratio, diagnostic only,
- lesion-size bin,
- consortium-only diagnostic model, if used only to audit shortcut risk.

## Region-Level Metrics

Region metrics are secondary but useful for error analysis.

Report when implemented:

- connected-component overlap between high-risk regions and FP components,
- connected-component overlap between high-risk regions and FN components,
- boundary-band enrichment, with radius fixed before evaluation,
- high-risk component count per subject.

Boundary maps are not primary unless a separate boundary policy is approved.

## Stratification Requirements

All headline tables must include:

- overall pooled OOF result,
- per-consortium result,
- lesion-size bins,
- timing-warning subgroup where available, following
  `research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md`,
- scanner/source subgroup where sample size allows.

Small strata must report row counts and may be marked exploratory.

## Timing-Warning Sensitivity

Because the first official split is expected to keep all 1,614 subject rows,
including MU/UCSD timing-warning rows, final claims require sensitivity analysis.

Required timing views:

- primary keep-all result,
- no-warning subset,
- UCSD no-warning subset,
- UCSD `scan >1y` high-risk subgroup if sample size is sufficient,
- warning versus no-warning rows within each consortium where sample size is
  sufficient.

The controlling contract is:

```text
research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md
```

Do not claim timing robustness if subgroup counts or no-warning sensitivity
metrics are missing.

## No-Go Rules

Do not proceed to G-SURE method claims if:

- B1 segmentation is degenerate on any held-out consortium,
- ERR AUPRC is near the error prevalence and top-k capture is weak,
- FP or FN localization collapses even when aggregate ERR looks acceptable,
- subject failure detection is solved by lesion size or predicted volume,
- Q1/Q2 QC baselines match or beat the proposed method on both subject and voxel
  metrics,
- calibration is fitted on held-out consortium labels,
- method gains appear only in pooled metrics while worst-consortium performance
  collapses.

## Reporting Minimum

Every result section must report:

- prediction manifest path,
- reliability label manifest path, if used,
- eligible row count,
- excluded row count and reason,
- metric implementation version or script path,
- threshold policy,
- whether metrics are pooled subject-level, pooled voxel-level, or
  consortium-stratified.

If `soft_error_map_path` is used as `R`, it is an oracle diagnostic upper-bound
only and must not be reported as a model's reliability prediction.

## Current Status

Metric code exists as a synthetic-ready harness only. No real segmentation
predictions, reliability labels, metric outputs, or claims exist yet.
