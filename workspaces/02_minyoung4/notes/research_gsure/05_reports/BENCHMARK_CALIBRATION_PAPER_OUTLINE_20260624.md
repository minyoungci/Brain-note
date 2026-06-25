# Benchmark/Calibration Paper Outline - 2026-06-24

## Status

This document locks the current G-SURE direction as a benchmark/calibration
paper, not a new segmentation architecture or visual-grounding method paper.

Literature status: not reverified in this session. Prior-work names and
threats should be checked again before any manuscript claim.

## One-Sentence Claim

Glioma segmentation reliability evaluation under consortium shift is
systematically distorted by cross-site uncertainty scale mismatch and
predicted-volume shortcuts; a leakage-safe LOCO benchmark with train-only
calibration and shortcut controls gives a more defensible estimate of
deployable failure prediction.

## What This Paper Is

- Benchmark/protocol contribution.
- Empirical calibration and shortcut-control analysis.
- Leakage-safe reliability evaluation for multi-consortium glioma segmentation.

## What This Paper Is Not

- Not a new segmentation loss paper.
- Not a new visual-grounding method paper.
- Not a claim that C0 is a new model mechanism.
- Not a claim that C1 is beyond QCResUNet/DeVries-style subject-level QC.
- Not a four-consortium conclusion until UPENN and UTSW are completed.

## Current Evidence Snapshot

### Official LOCO Cohort

Source:

```text
research_gsure/02_audits/outputs/loco_split_summary.csv
research_gsure/02_audits/outputs/loco_split_audit_report.md
```

| heldout consortium | train subjects | test subjects | total subjects | subject overlap | missing paths |
| --- | ---: | ---: | ---: | ---: | ---: |
| MU-Glioma-Post | 1411 | 203 | 1614 | 0 | 0 |
| UCSD-PTGBM | 1436 | 178 | 1614 | 0 | 0 |
| UPENN-GBM | 1003 | 611 | 1614 | 0 | 0 |
| UTSW | 992 | 622 | 1614 | 0 | 0 |

Timing warnings remain present for MU, UCSD, and some train folds; these must
be treated as cohort caveats, not ignored.

### Current Reliability Evidence

Source:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/
```

Current evidence is two-fold only: MU and UCSD.

Evidence hygiene:

- `research_gsure/03_baselines/outputs/20260624_1205_threshold_size_controls_synthetic/`
  is a script self-test fixture from `synthetic_scores.csv`, not a research
  result. Do not cite its C0 AUC, site diagnostics, or tables as evidence.
- The locked two-fold control evidence comes from
  `research_gsure/03_baselines/outputs/20260624_1210_threshold_size_controls/`.
- All current reliability claims must be worded as MU+UCSD two-fold evidence
  until UPENN and UTSW prediction/evaluation are completed.

| model | score | scope | AUROC | AUPRC | interpretation |
| --- | --- | --- | ---: | ---: | --- |
| B1B | V0 predicted volume | pooled MU+UCSD | 0.735 | 0.671 | deployable shortcut baseline |
| B1B | U0 raw entropy | pooled MU+UCSD | 0.699 | 0.689 | misleading pooled scale |
| B1B | C0 z entropy | pooled MU+UCSD | 0.822 | 0.813 | cross-fold scale correction |
| B1B | C1 entropy+volume | pooled MU+UCSD | 0.910 | 0.908 | supervised subject-level QC baseline |

Fold-level correction:

| B1B fold | V0 predicted volume AUROC | U0 raw entropy AUROC | C0 z entropy AUROC |
| --- | ---: | ---: | ---: |
| MU | 0.720 | 0.819 | 0.819 |
| UCSD | 0.756 | 0.845 | 0.845 |

Interpretation:

- C0 equals U0 within each fold because it is monotonic inside a fold.
- C0 pooled gain means raw entropy scales are misaligned across folds.
- C1 is strong, but it is a supervised subject-level QC baseline.

Locked MU+UCSD two-fold controls:

| result id | control | key two-fold observation | interpretation boundary |
| --- | --- | --- | --- |
| R5 | site/confound control | B1B raw entropy site AUC abs 0.962; C0 0.612; C1 0.525 | raw pooled entropy is site-scale sensitive |
| R6 | lesion-size strata | small/mid/large V0 vs C0 vs C1 AUROC: 0.603/0.880/0.920, 0.801/0.880/0.918, 0.771/0.765/0.883 | lesion size is a major failure mode, but not the full explanation |
| R7 | threshold-free robustness | Spearman with `1 - Dice`: V0 0.433, U0 0.360, C0 0.681, C1 0.823 | the Dice <= 0.8 result is not only a threshold artifact |

## Research Design Note

### Research Claim

Reliability evaluation for glioma segmentation under consortium shift requires
both train-only score-scale calibration and explicit predicted-volume shortcut
controls; otherwise uncertainty performance can be under- or over-estimated.

### Minimum Evidence Needed

- Four-fold LOCO reliability table over V0, U0, C0, and C1.
- Fold-level and pooled AUROC/AUPRC with subject-level bootstrap intervals.
- Demonstration that raw entropy can be informative within folds but distorted
  by pooled cross-site score scale mismatch.
- Demonstration that predicted volume is a strong deployable shortcut baseline.
- Sensitivity analysis for the Dice failure threshold.

### Negative Control

- GT-derived oracle variables must be diagnostic only and excluded from
  deployable claims.
- Volume-only models must be reported beside every uncertainty/QC score.
- Site/confound checks must test whether reliability scores mainly encode
  consortium or annotation source.

### Positive Control

- C1 entropy+volume is a positive subject-level QC control. It is expected to
  perform strongly and should be framed as a ceiling-style QC baseline, not as
  the paper's new method.

### Baseline Model

- B1B scratch 3D U-Net `dice_focal`, train-only threshold calibration.
- B1A `dice_bce` remains a supporting baseline, not the headline model.

### Naive Baseline

- V0 predicted-volume baseline:

```text
score = -log1p(predicted tumor voxels)
```

### Strong Baseline

- C1 logistic failure calibrator using train-only internal-val rows:

```text
z_mean_entropy_pred_mask + log1p(pred_voxels) + threshold_value
```

### Ablation Plan

- V0 predicted volume only.
- U0 raw entropy.
- C0 fold-calibrated entropy.
- C1 entropy only.
- C1 volume only.
- C1 entropy plus volume.
- Optional TTA/ensemble uncertainty only if the additional GPU cost is approved.

### Expected Failure Mode

- The finding may collapse on UPENN/UTSW.
- C1 may remain strong while entropy alone becomes fold-specific.
- The result may be explained mostly by lesion size or site/annotation source.
- A reviewer may argue the contribution is obvious unless the naive-vs-corrected
  evaluation delta is clearly quantified.

### Reviewer Attack Points

- "This is just QCResUNet/DeVries-style quality control."
- "The reliability score is only a lesion-size detector."
- "Pooled calibration is trivial."
- "Two held-out folds are underpowered."
- "A small U-Net is not enough to support a benchmark conclusion."
- "Dice <= 0.8 is an arbitrary failure label."
- "The longitudinal/post-treatment cohorts may have different semantics."

### Decision Rule

Proceed with the benchmark/calibration paper only if four-fold LOCO reproduces
the main qualitative findings:

- V0 is non-trivial.
- U0 is informative within folds for at least the main segmenter.
- C0 changes pooled comparability without changing within-fold ranks.
- C1 improves over volume-only and entropy-only controls.

### Stop Rule

Stop making a reliability benchmark claim if UPENN/UTSW show that:

- entropy does not add signal within folds,
- C0 pooled behavior is unstable or sign-flipped without a clear scale reason,
- C1 improvement over volume-only disappears,
- site or annotation source dominates the reliability scores.

Pre-registered four-fold break checks:

- C2 check: within-fold entropy must remain competitive with the predicted-volume
  baseline. If UPENN/UTSW show entropy below volume without a clear explanation,
  the scale-calibration claim weakens.
- C3 check: if predicted-volume AUROC is about 0.70 or higher and entropy/QC
  scores do not add stable signal beyond it, the result should be treated as a
  volume-shortcut finding rather than an uncertainty/calibration finding.

## Contributions

### C1. Leakage-Safe Benchmark

A four-consortium subject-level failure-detection benchmark for glioma
segmentation reliability with LOCO splits, full-volume prediction contracts,
and deployable-vs-oracle input separation.

### C2. Scale-Mismatch Finding

Raw uncertainty scores can carry within-site failure signal but fail under naive
pooled evaluation because cross-consortium score scales differ. Train-only
fold calibration is an evaluation correction, not a new model mechanism.

### C3. Shortcut-Control Finding

Predicted tumor volume alone is a strong deployable failure predictor. Any
reliability claim must beat and report this baseline, otherwise it may be
mostly a lesion-size shortcut.

## Paper Outline

### 1. Introduction

- Segmentation failures matter under deployment shift.
- Dice-only reporting hides silent failures.
- Reliability evaluation itself is fragile under consortium shift.
- This paper focuses on fair measurement and calibration, not architecture.

### 2. Related Work

- Segmentation quality control and failure prediction.
- Uncertainty estimation for medical image segmentation.
- QU-BraTS-style evaluation and filtering.
- Calibration under distribution shift.
- Glioma segmentation benchmarks.

Literature status: prior-work names in
`research_gsure/00_context/20260623_gsure_prior_work_matrix.md` must be
rechecked before final manuscript text.

### 3. Benchmark Definition

- Cohort and consortium composition.
- Subject-level unit policy.
- LOCO split policy.
- Segmentation target and mask taxonomy.
- Failure outcome definitions.
- Deployable vs diagnostic/oracle inputs.
- Leakage guards.

### 4. Reliability Scores and Controls

- V0 predicted-volume baseline.
- U0 raw entropy.
- C0 fold-calibrated entropy.
- C1 supervised subject-level QC calibrator.
- Optional TTA/ensemble baselines if approved.
- Diagnostic GT-volume/oracle controls only for interpretation.

### 5. Main Findings

- F1: raw entropy can beat predicted volume within folds.
- F2: naive pooled raw entropy can understate the uncertainty signal because
  fold scales differ.
- F3: train-only fold calibration restores pooled comparability but is not a
  new mechanism.
- F4: predicted volume is a strong shortcut baseline and must be controlled.
- F5: threshold calibration drifts across consortia.
- F6: small-lesion and post-treatment cases remain key failure modes.

### 6. Limitations

- Current evidence is only two-fold until UPENN/UTSW complete.
- Subject-level QC does not prove voxel-level visual grounding.
- B1B is a small scratch U-Net; a stronger segmenter may be needed for broader
  benchmark claims.
- Dice threshold choices need sensitivity analysis.
- Timing warnings and post-treatment semantics must remain visible.

### 7. Conclusion

Fair reliability evaluation under consortium shift requires train-only
calibration and shortcut controls. The benchmark should prevent overstating
uncertainty methods that merely exploit lesion volume or fold-specific score
scale.

## Result Checklist

| id | table/figure | status | reviewer attack handled |
| --- | --- | --- | --- |
| R1 | Cohort and LOCO split table | done | contamination/leakage |
| R2 | Main V0/U0/C0/C1 AUROC/AUPRC across 4 folds | 2/4 folds | generality and power |
| R3 | Scale-mismatch figure: U0 per-fold vs U0 pooled vs C0 pooled | 2/4 folds | "calibration is trivial" |
| R4 | Volume-shortcut control with bootstrap delta vs V0 | 2/4 folds | "reliability is lesion size" |
| R5 | Site/confound control | 2/4 folds done | "site or annotation dominates" |
| R6 | Lesion-size-stratified failure and AUROC | 2/4 folds done | size-driven failure |
| R7 | Threshold-free robustness and Dice-threshold sensitivity | 2/4 folds done | arbitrary Dice cutoff |
| R8 | Calibration-under-shift: thresholds, reliability diagram, ECE | partial | calibration claim support |
| R9 | Reproducibility and deterministic training/inference summary | partial | reproducibility |
| R10 | TTA or ensemble uncertainty baseline | outstanding optional GPU | "just uncertainty estimation" |
| R11 | Stronger segmenter replication, e.g. SegResNet or nnU-Net-style baseline | optional GPU | small-backbone limitation |
| R12 | Voxel-level ERR/FP/FN localization vs QC baselines | deferred method fork | visual-grounding claim |

## Remaining Experiments

### E1. Complete Four-Fold B1B

Purpose:

```text
Move the current MU+UCSD result to full four-consortium LOCO.
```

Compute:

```text
GPU required for UPENN/UTSW fit and inference; approval required.
```

Loads:

- R2.
- R3.
- R4.
- R5.

### E2. Threshold-Free and Calibration Analyses

Purpose:

```text
Test whether the failure-detection result depends on Dice <= 0.8.
```

Compute:

```text
CPU only, using existing prediction score artifacts.
```

Loads:

- R7.
- R8.

Current status:

```text
Completed for MU+UCSD two-fold evidence in
research_gsure/03_baselines/outputs/20260624_1210_threshold_size_controls/
```

Key result:

```text
B1B C0 and C1 remain above V0 across Dice cutoffs 0.70, 0.75, 0.80, 0.85, and 0.90.
Continuous-Dice association is also stronger for C0/C1 than V0.
```

### E3. Site and Lesion-Size Controls

Purpose:

```text
Quantify whether failure scores are mainly consortium/source/lesion-size proxies.
```

Compute:

```text
CPU first; no new model training.
```

Loads:

- R5.
- R6.

Current status:

```text
Completed for MU+UCSD two-fold evidence in
research_gsure/03_baselines/outputs/20260624_1210_threshold_size_controls/
```

Key result:

```text
Raw B1B entropy strongly separates MU vs UCSD (site AUC abs 0.962), confirming
cross-site score-scale mismatch. GT-size diagnostics show small lesions have the
highest failure prevalence, but C0/C1 retain signal beyond V0 in small/mid
strata. C0 does not beat V0 in the large GT-size stratum.
```

### E4. TTA/Ensemble Uncertainty Baseline

Purpose:

```text
Defend against the claim that the benchmark omitted standard uncertainty
baselines.
```

Compute:

```text
Optional GPU inference; approval required.
```

Loads:

- R10.

### E5. Stronger Segmenter Replication

Purpose:

```text
Test whether the evaluation findings survive beyond the small B1B U-Net.
```

Compute:

```text
Optional GPU training/inference; approval required.
```

Loads:

- R11.

## Method Fork Gate

Do not claim a new visual-grounding method from the current subject-level QC
results.

The method fork can reopen only if:

1. Four-fold LOCO reproduces the subject-level reliability findings.
2. Voxel-level ERR/FP/FN localization beats QCResUNet-style baselines.
3. The gain is not explained by predicted volume, site, or annotation source.

Until then, the default direction is benchmark/calibration.

## Next Action

The CPU-only MU+UCSD E2/E3 controls are locked as two-fold evidence. Next,
request explicit GPU approval for UPENN/UTSW B1B prediction/evaluation if the
paper still needs four-fold completion as the load-bearing evidence.
