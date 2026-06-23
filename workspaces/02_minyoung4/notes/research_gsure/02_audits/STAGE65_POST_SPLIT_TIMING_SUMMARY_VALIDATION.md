# Stage 65 - Post-Split Timing Summary Validation

## Task

Harden the official split artifact checker so timing-warning summary fields are
validated against the official split manifest.

## Research Question

After official split creation, can the post-split checker detect a corrupted
timing-warning summary instead of only validating subject counts and lesion
burden?

## Why This Matters

Stage 62 and Stage 63 made MU/UCSD timing warnings part of the approval and
reporting contract. The split builder already writes
`test_selection_warning_rows` and `train_selection_warning_rows`, but the
post-split checker must verify those fields match the manifest before GPU work
is prepared.

## What Changed

- `check_official_split_artifacts.py` now validates:
  - `test_selection_warning_rows`,
  - `train_selection_warning_rows`.
- The dry-run self-test now includes a timing-warning mismatch negative control.
- Successful checker output now reports timing-warning summary fields as
  validated.
- `POST_APPROVAL_SPLIT_RUNBOOK.md` now treats timing-warning summary mismatch as
  a hard failure.
- `STAGE26_POST_SPLIT_VALIDATION_RUNNER.md` now records timing-warning summary
  validation as part of the official split checker.
- `check_pre_split_readiness.py` now protects these guardrails with document
  invariants and includes this Stage note in `REQUIRED_FILES`.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-65
  coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run `--write`.
- This does not run GPU work, preprocessing, inference, prediction generation,
  reliability label generation, or metric computation.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_official_split_artifacts.py
python research_gsure/02_audits/scripts/check_official_split_artifacts.py --dry-run-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This is post-split validation hardening. It does not prove that timing warnings
are harmless. It ensures that official split summaries cannot silently misreport
timing-warning counts.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
