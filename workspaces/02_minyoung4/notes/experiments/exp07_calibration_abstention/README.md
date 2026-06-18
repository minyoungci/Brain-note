# exp07: Calibration and Abstention

Status: scaffold only.

## Objective

Add reliability evaluation and safe-failure behavior for the best-performing model.

## Prior-Work Gap

Most studies emphasize AUC. External deployment needs calibration, subgroup reliability,
and uncertainty-aware failure modes.

## Candidate Methods

- Temperature scaling using validation consortia only.
- Ensemble or MC dropout if compute allows.
- Selective prediction by confidence threshold.
- Conformal-style abstention analysis if validation size permits.

## Required Metrics

- ECE.
- Brier score.
- Reliability curve.
- Selective risk vs coverage.
- Sensitivity/specificity at fixed confidence thresholds.

## Inputs

- Predictions from exp02 and best main model.
- Subject-level labels and groups.

## Main Risk

Calibration may not improve raw AUC.
This experiment is a reliability contribution, not the main performance claim.

