# Stage 61 - Approval Output Evidence Sync

## Task

Synchronize approval-facing G-SURE documents with the output evidence coverage
self-test added in Stage 60.

## Research Question

Do the official split approval packet, readiness checklist, post-approval
runbook, and preflight note describe the same output-evidence coverage check
that the executable pre-split readiness gate now runs?

## Why This Matters

Min should not approve official LOCO split creation from documents that omit a
current preflight check. Stage 60 made pre-split output artifact coverage
negative-control tested; this Stage makes that evidence visible in the approval
surface and protects it with document invariants.

## What Changed

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` now lists the output evidence coverage
  self-test and its removed-output negative control.
- `EXPERIMENT_READINESS_CHECKLIST.md` now includes output evidence coverage
  negative controls in the pre-split preflight row.
- `POST_APPROVAL_SPLIT_RUNBOOK.md` now expects `[OK] output evidence coverage
  self-test` in the observed preflight output.
- `STAGE24_PRE_SPLIT_PREFLIGHT.md` now documents that missing pre-split output
  required-file entries are rejected.
- `README.md` and `ROADMAP.md` now summarize output evidence coverage as part of
  the current strengthened pre-split gate.
- `check_pre_split_readiness.py` now has document invariants for these
  approval-facing phrases and includes this Stage note in `REQUIRED_FILES`.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-61
  coverage.

## Guardrails

- This does not create official split artifacts.
- This does not write to raw data.
- This does not run GPU work, preprocessing, inference, prediction generation,
  reliability label generation, or metric computation.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "output evidence coverage self-test: all current pre-split output artifacts|output evidence coverage negative controls|\\[OK\\] output evidence coverage self-test|STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC|Stage 2-61" research_gsure/README.md research_gsure/ROADMAP.md research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE61_APPROVAL_OUTPUT_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This is approval-gate hygiene. It improves traceability and prevents stale
approval documents, but it is not evidence of segmentation performance,
reliability performance, method novelty, or publishability.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
