# Stage 64 - Pre-Approval Decision Brief

## Task

Add a short pre-approval decision brief for official LOCO split creation.

## Research Question

Can Min review the immediate split decision without confusing it with GPU
training, prediction generation, reliability labels, or performance claims?

## Why This Matters

The G-SURE pre-split preparation now has many protocol and audit documents. The
approval packet remains authoritative, but a short decision brief reduces the
risk of approving the wrong action or assuming split approval also authorizes
training.

## What Changed

- Added `PRE_APPROVAL_DECISION_BRIEF.md`.
- The brief states the exact split policy and approval phrase.
- The brief lists the three official split files that approval would create.
- The brief summarizes current evidence:
  - 1,614 selected subjects,
  - 0 subject overlap,
  - 0 secondary-unit leakage,
  - official split artifacts absent,
  - full pre-split readiness PASS.
- The brief repeats that official split approval does not authorize GPU
  training, inference, OOF predictions, reliability labels, method training, or
  claims.
- The brief requires post-split CPU validation before any GPU command is
  prepared.
- `check_pre_split_readiness.py` now requires this brief and protects selected
  guardrail phrases with document invariants.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-64
  coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run `--write`.
- This does not run GPU work, inference, preprocessing, prediction generation,
  reliability label generation, or metric computation.

## Interpretation

This is approval-surface hardening. It does not add new data evidence or model
evidence. It makes the next approval gate more explicit.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
