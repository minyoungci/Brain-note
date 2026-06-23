# Stage 58 - Post-Approval Runbook Preflight Scope

## Task

Synchronize the post-approval split runbook with the current strengthened
pre-split readiness output.

## Research Question

Does the runbook tell the operator what strengthened preflight evidence should
be visible before acting on official split approval?

## Why This Matters

The runbook is the first operational document after Min approves official split
creation. It should not only say to run preflight; it should identify the key
self-test outputs that prove the current gate is active.

## What Changed

- `POST_APPROVAL_SPLIT_RUNBOOK.md` now states that preflight output should
  include:
  - `[OK] document invariant self-test`,
  - `[OK] Stage audit coverage self-test`,
  - `Pre-split readiness: PASS`,
  - `Official split artifacts: absent`.
- `check_pre_split_readiness.py` now protects this runbook wording with a
  document invariant.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-58
  required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This updates operational documentation only.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "\\[OK\\] document invariant self-test|\\[OK\\] Stage audit coverage self-test|STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE|Stage 2-58" research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE58_POST_APPROVAL_RUNBOOK_PREFLIGHT_SCOPE.md
```

## Interpretation

This keeps the operational runbook aligned with the actual preflight gate. It is
not approval to create the official split.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
