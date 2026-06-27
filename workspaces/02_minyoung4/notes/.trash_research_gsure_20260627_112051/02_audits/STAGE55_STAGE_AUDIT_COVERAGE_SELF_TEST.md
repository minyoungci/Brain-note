# Stage 55 - Stage Audit Coverage Self-Test

## Task

Add a negative-control self-test for Stage audit required-file coverage.

## Research Question

Can the pre-split readiness gate prove that it rejects a Stage audit note that
exists on disk but is missing from `REQUIRED_FILES`?

## Why This Matters

Stage 54 added dynamic Stage audit coverage checking. This Stage verifies that
the coverage check itself has a failure-mode test, so future changes cannot
silently weaken audit-trail protection.

## What Changed

`check_pre_split_readiness.py` now has:

```bash
--stage-audit-coverage-self-test
```

The self-test:

- reads current `research_gsure/02_audits/STAGE*.md` files,
- validates that all are covered by `REQUIRED_FILES`,
- removes one Stage entry from an in-memory required-file list,
- verifies that the missing Stage entry is rejected,
- runs as part of the full pre-split readiness command checks.

## Guardrails

- The self-test is read-only.
- It does not edit Stage notes.
- It does not create official split artifacts.
- It does not run GPU work, inference, preprocessing, training, or reliability
  label generation.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "Stage audit coverage self-test|--stage-audit-coverage-self-test|Removed-stage negative control|STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST|Stage 2-55" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE55_STAGE_AUDIT_COVERAGE_SELF_TEST.md
```

Expected self-test output includes:

```text
Stage audit coverage self-test: PASS
Removed-stage negative control: rejected
```

## Interpretation

This is audit-trail gate hardening. It is not segmentation performance,
reliability performance, or novelty evidence.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
