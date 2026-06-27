# Stage 36 - Preflight Document Invariants

## Task

Add semantic document guardrails to the pre-split readiness preflight.

## Research Question

Can a critical gate phrase disappear from a required document while the file
still exists and the preflight passes?

## What Changed

`check_pre_split_readiness.py` now checks selected document invariants:

- README still says no official split/GPU/raw mutation has happened.
- Official split approval packet still contains the exact approval wording.
- Official split approval packet still contains the approved decision tuple:
  primary cohort artifact, subject-unit selection policy, binary target, LOCO
  split policy, and subject-level split unit.
- Official split approval packet still separates split approval from GPU
  training and reliability label generation.
- Post-approval runbook still blocks `--force` without separate approval.
- Stage 24 still states preflight PASS is not GPU approval.
- B1 GPU preview template still states no GPU preview command is approved.
- Reliability metric contract still marks `soft_error_map_path` as oracle
  diagnostic only.
- Literature scout still records the targeted 2024-2026 update as non-exhaustive
  and blocks unsupported "first/novel/SOTA/robust/clinically useful" claims.
- Prior-work matrix still records QCResUNet as a 2025 Medical Image Analysis /
  PubMed direct novelty threat.
- Readiness and baseline contracts still require lesion-size, predicted-volume,
  and image-difficulty proxy controls before G-SURE method claims.
- Baseline contract still keeps ground-truth lesion size as oracle diagnostic
  only, not a deployable QC input.
- `check_pre_split_readiness.py --document-invariant-self-test` now verifies
  that the current documents satisfy all selected invariants and that missing
  invariant text is rejected.

## Scope

These are not full document validators. They are guardrails for the phrases that
would materially change the research gate if accidentally removed.

## Current Status

No official split artifacts were created. The next gate remains explicit
approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
