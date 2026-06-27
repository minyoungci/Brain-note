# Stage 56 - Approval Stage Coverage Evidence Sync

## Task

Synchronize approval-facing documents with the Stage audit coverage self-test.

## Research Question

Does the official split approval packet describe the same Stage audit coverage
evidence that `check_pre_split_readiness.py` now runs?

## Why This Matters

Stage 55 added a negative-control self-test for Stage audit coverage. Min should
see that evidence in the approval packet before approving official split
creation.

## What Changed

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` now lists the Stage audit coverage
  self-test as required preflight evidence.
- `EXPERIMENT_READINESS_CHECKLIST.md` now states that pre-split preflight checks
  Stage audit coverage negative controls.
- `STAGE24_PRE_SPLIT_PREFLIGHT.md` now records that Stage audit coverage
  self-test rejects missing Stage required-file entries.
- `check_pre_split_readiness.py` now protects those approval/checklist phrases
  with document invariants.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-56
  required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This synchronizes documentation with existing CPU-only gate behavior.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "Stage audit coverage self-test: all current Stage audit notes are covered|Stage audit coverage negative controls|missing Stage required-file entries|STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC|Stage 2-56" research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE56_APPROVAL_STAGE_COVERAGE_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This keeps the approval evidence aligned with the actual preflight gate. It is
not segmentation performance evidence and not approval to create the official
split.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
