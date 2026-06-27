# Reliability Calibration Gate Decision - Corrected Interpretation

Scope: CPU-only, existing B1A/B1B calibrated MU and UCSD probability maps.

This gate evaluates whether train-only reliability calibration beats the
deployable predicted-volume baseline for detecting subject-level segmentation
failure (`Dice <= 0.8`).

Correction:

```text
C0 is not a new within-fold signal. It is a monotonic train-fitted scale
normalization. Within each fold, C0 AUROC equals raw entropy AUROC. Its pooled
gain reflects correction of cross-fold entropy-scale mismatch.
```

## Primary Result

| model | score | pooled AUROC | pooled AUPRC | delta AUROC vs V0 | 95% CI |
|---|---:|---:|---:|---:|---:|
| B1A | V0 predicted volume | 0.736 | 0.658 | - | - |
| B1A | C0 z entropy | 0.748 | 0.694 | +0.013 | [-0.072, 0.098] |
| B1A | C1 entropy+volume | 0.920 | 0.912 | +0.185 | [0.143, 0.229] |
| B1B | V0 predicted volume | 0.735 | 0.671 | - | - |
| B1B | C0 z entropy | 0.822 | 0.813 | +0.087 | [0.014, 0.161] |
| B1B | C1 entropy+volume | 0.910 | 0.908 | +0.174 | [0.128, 0.223] |

Bootstrap: 5,000 fold-stratified subject-level resamples.

## Interpretation

- B1B shows real subject-level uncertainty signal: raw entropy beats predicted
  volume within both MU and UCSD folds.
- Raw entropy fails when pooled without calibration because MU and UCSD entropy
  scores live on different scales.
- C0 restores pooled comparability by train-fitted fold-wise scale
  normalization. This is a required evaluation/calibration step, not a standalone
  method contribution.
- C1 entropy+volume is much stronger, but it is a supervised subject-level QC
  predictor in the DeVries/QCResUNet baseline family. It is not a full visual
  grounding method.
- The result supports continuing reliability/QC evaluation, but not a method
  claim yet.
- This does not yet prove a four-consortium method claim because UPENN and UTSW
  folds are still missing.

## Decision

Recommended fork: benchmark/calibration first.

Conditional method fork only if later evidence shows voxel-level ERR/FP/FN
localization beating QCResUNet-style baselines.

Stop segmentation-loss sweeps.

Next required evidence:

1. Generate/evaluate B1B calibrated predictions for UPENN and UTSW.
2. Re-run this C0/C1 gate on all four LOCO folds.
3. Add voxel-level ERR/FP/FN localization metrics and compare against
   QCResUNet-style baselines before claiming visual grounding.
4. Keep V0 predicted volume, C1 volume-only, and diagnostic GT controls in every
   table.
