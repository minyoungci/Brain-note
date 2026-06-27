# Threshold-Free and Size-Control Decision - 2026-06-24

Scope: CPU-only E2/E3 analysis from existing MU+UCSD B1A/B1B subject-level
reliability scores.

Input:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_test_scores.csv
```

No GPU training, inference, NIfTI loading, or new model fitting beyond existing
score columns was performed.

## Decision

This analysis supports the benchmark/calibration framing, not a new method
claim.

The current MU+UCSD evidence survives basic Dice-threshold and continuous-Dice
checks, and it confirms that raw entropy has a major site-scale problem.
Predicted volume is a real shortcut, but it does not fully explain the
uncertainty/QC signal.

Four-fold UPENN/UTSW reproduction is still required before any
four-consortium benchmark conclusion.

## Key Findings

### F1. Dice-Cutoff Sensitivity Does Not Kill the Finding

B1B pooled AUROC across failure cutoffs:

| Dice cutoff | V0 volume | U0 raw entropy | C0 calibrated entropy | C1 entropy+volume |
| ---: | ---: | ---: | ---: | ---: |
| 0.70 | 0.764 | 0.711 | 0.837 | 0.909 |
| 0.75 | 0.758 | 0.713 | 0.831 | 0.907 |
| 0.80 | 0.735 | 0.699 | 0.822 | 0.910 |
| 0.85 | 0.693 | 0.643 | 0.842 | 0.914 |
| 0.90 | 0.678 | 0.624 | 0.902 | 0.954 |

Interpretation:

- C0 stays above V0 across the tested cutoffs.
- C1 stays strongest across the tested cutoffs.
- U0 raw entropy remains unstable in pooled evaluation, consistent with the
  scale-mismatch finding.

### F2. Continuous Dice Association Supports the Same Direction

B1B pooled Spearman correlation with continuous Dice error (`1 - Dice`):

| score | Spearman |
| --- | ---: |
| V0 predicted volume | 0.433 |
| U0 raw entropy | 0.360 |
| C0 calibrated entropy | 0.681 |
| C1 entropy+volume | 0.823 |

Interpretation:

- The result is not only an artifact of the `Dice <= 0.8` threshold.
- This is still subject-level QC evidence, not voxel-level grounding.

### F3. Site-Scale Confounding Is Real

B1B score separability for fold/site (`UCSD` vs `MU`):

| score | site AUC abs | MU median | UCSD median |
| --- | ---: | ---: | ---: |
| V0 predicted volume | 0.591 | -11.016 | -10.747 |
| U0 raw entropy | 0.962 | 0.099 | 0.182 |
| C0 calibrated entropy | 0.612 | 0.703 | 0.413 |
| C1 entropy+volume | 0.525 | 0.615 | 0.568 |

Interpretation:

- Raw entropy almost acts as a site indicator in the two-fold pooled data.
- This directly supports the claim that naive pooled uncertainty evaluation is
  distorted by cross-site score scale mismatch.
- C0 reduces site separability but is still only a calibration correction.

### F4. Lesion Size Is a Major Failure Mode, But Not the Whole Story

B1B pooled GT-size diagnostic strata:

| GT size bin | failure rate | V0 AUROC | C0 AUROC | C1 AUROC |
| --- | ---: | ---: | ---: | ---: |
| small | 0.630 | 0.603 | 0.880 | 0.920 |
| mid | 0.386 | 0.801 | 0.880 | 0.918 |
| large | 0.315 | 0.771 | 0.765 | 0.883 |

Interpretation:

- Small lesions are structurally hard: failure prevalence is highest in the
  small GT-size stratum.
- V0 is not enough in the small-lesion stratum.
- C0 is strong in small/mid strata but does not beat V0 in the large stratum.
- C1 remains strong in all three strata, but C1 is a supervised QC baseline.
- GT-size stratification is diagnostic only and cannot be used as a deployable
  input.

## What This Rules Out

- Do not argue that the reliability result is only a fixed `Dice <= 0.8`
  artifact.
- Do not argue that raw pooled entropy can be compared naively across sites.
- Do not treat predicted volume as a negligible baseline.
- Do not present C1 as a new grounding method.

## What This Does Not Rule Out

- The finding may still fail on UPENN/UTSW.
- Stronger segmenters or TTA/ensemble uncertainty may change the ranking.
- Site/annotation effects may be more complex in the four-fold setting.
- Voxel-level visual grounding remains untested.

## Next Action

1. Keep benchmark/calibration as the default paper direction.
2. Use these results to mark R5/R6/R7 as two-fold completed in the outline.
3. Request explicit GPU approval only for the load-bearing four-fold B1B
   reproduction on UPENN/UTSW.
