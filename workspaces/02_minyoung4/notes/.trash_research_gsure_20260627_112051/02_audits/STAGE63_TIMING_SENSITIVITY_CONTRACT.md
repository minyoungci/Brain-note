# Stage 63 - Timing Sensitivity Contract

## Task

Convert the Stage 62 timing-warning recommendation into an explicit reporting
contract for later segmentation and reliability results.

## Research Question

If the first official split keeps MU/UCSD timing-warning rows, what minimum
sensitivity analyses are required before any final G-SURE claim?

## Why This Matters

Stage 62 showed that excluding all timing-warning rows would reduce UCSD from
178 to 115 subjects. Keeping all rows preserves the held-out consortium test,
but it creates a reviewer-facing obligation: primary results must not hide
whether gains depend on timing-warning or post-treatment-like rows.

## What Changed

- Added `TIMING_WARNING_SENSITIVITY_CONTRACT.md`.
- Required timing groups:
  - no warning,
  - MU missing days from diagnosis,
  - UCSD missing acquisition-to-initial-event offset,
  - UCSD scan more than 1y after initial event.
- Required later sensitivity views:
  - primary keep-all result,
  - no-warning subset,
  - UCSD no-warning subset,
  - UCSD `scan >1y` high-risk subgroup if sample size is sufficient,
  - warning versus no-warning rows within each consortium where sample size is
    sufficient.
- Updated `RELIABILITY_METRIC_CONTRACT.md` so timing sensitivity is part of the
  required reporting contract.
- Updated `EXPERIMENT_READINESS_CHECKLIST.md` so the timing-warning sensitivity
  contract is visible before GPU work.
- Updated `check_pre_split_readiness.py` required files and document invariants.
- Updated Stage35 to record Stage 2-63 coverage.

## Guardrails

- This does not create official split artifacts.
- This does not write to raw data.
- This does not run GPU work, preprocessing, inference, prediction generation,
  reliability label generation, or metric computation.

## Interpretation

This narrows the risk introduced by a keep-all primary split. It does not prove
the final model will be robust to timing heterogeneity; it makes that check
mandatory before final claims.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
