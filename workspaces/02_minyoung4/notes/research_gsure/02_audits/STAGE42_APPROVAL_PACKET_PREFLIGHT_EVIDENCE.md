# Stage 42 - Approval Packet Preflight Evidence

## Task

Refresh the official split approval packet so it states the current CPU-only
preflight evidence that must pass before split creation is acted on.

## Research Question

Could Min approve the official split from a packet that locks the right decision
tuple but omits newer gate evidence, such as subject-manifest semantic negative
controls and post-split runner self-tests?

## Why This Matters

The approval packet is the document Min uses to decide whether crossing the
official split gate is justified. It should expose the current evidence chain,
not only the older split-builder dry-run.

## What Changed

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` now explicitly lists the pre-split
  readiness command.
- The packet now states that preflight evidence includes:
  - direction contamination self-test with clean active docs and 3 rejected
    injected stale-direction terms,
  - subject manifest semantic self-test with 8 rejected negative controls,
  - official split builder dry-run,
  - official split artifacts absent check,
  - official split checker dry-run self-test,
  - post-split validation runner preview,
  - post-split validation runner dry-run self-test,
  - OOF, inner-OOF, prediction artifact, reliability label, and reliability
    metric synthetic self-tests.
- `check_pre_split_readiness.py` now guards approval-packet evidence phrases
  as document invariants.

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

The approval packet now better reflects the current readiness evidence. This is
approval-context hygiene, not segmentation performance evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
