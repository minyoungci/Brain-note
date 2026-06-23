# Stage 46 - Readiness Checklist Preflight Scope

## Task

Synchronize the experiment readiness checklist with the current strengthened
pre-split readiness scope.

## Research Question

Could the readiness checklist understate what the current preflight actually
checks, causing Min to review stale readiness evidence before official split
approval?

## Why This Matters

The checklist is a high-level entry point for the G-SURE evidence chain. After
adding direction-contamination checks and subject-manifest semantic negative
controls, the checklist needed to reflect that current scope.

## What Changed

- `EXPERIMENT_READINESS_CHECKLIST.md` now states that the pre-split preflight
  checks:
  - active-direction contamination,
  - subject-manifest semantics and negative controls,
  - absence of official split artifacts,
  - dry-runs,
  - validator self-tests.
- `check_pre_split_readiness.py` now guards that checklist phrase as a document
  invariant.

## Guardrails

- This does not approve official split creation.
- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This keeps the top-level readiness checklist aligned with the real preflight
coverage. It is not segmentation performance evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
