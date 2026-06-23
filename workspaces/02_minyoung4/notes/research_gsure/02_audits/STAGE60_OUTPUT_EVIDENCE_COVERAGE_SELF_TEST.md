# Stage 60 - Output Evidence Coverage Self-Test

## Task

Add a negative-control self-test for pre-split output artifact required-file
coverage.

## Research Question

Can the pre-split readiness gate prove that it rejects an existing audit output
artifact that is missing from `REQUIRED_FILES`?

## Why This Matters

Stage 59 added the current pre-split output artifacts to required-file coverage.
This Stage verifies that the output coverage check itself has a failure-mode
test, so future changes cannot silently weaken evidence-artifact protection.

## What Changed

`check_pre_split_readiness.py` now has:

```bash
--output-evidence-coverage-self-test
```

The self-test:

- reads current `research_gsure/02_audits/outputs/*` files,
- excludes official split artifacts, which remain forbidden before approval,
- validates that all current pre-split output artifacts are covered by
  `REQUIRED_FILES`,
- removes one output artifact from an in-memory required-file list,
- verifies that the missing output artifact is rejected,
- runs as part of the full pre-split readiness command checks.

## Guardrails

- The self-test is read-only.
- It does not edit output artifacts.
- It does not create official split artifacts.
- It does not run GPU work, inference, preprocessing, training, or reliability
  label generation.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --output-evidence-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "Output evidence coverage self-test|--output-evidence-coverage-self-test|Removed-output negative control|STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST|Stage 2-60" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE60_OUTPUT_EVIDENCE_COVERAGE_SELF_TEST.md
```

Expected self-test output includes:

```text
Output evidence coverage self-test: PASS
Removed-output negative control: rejected
```

## Interpretation

This is evidence-artifact gate hardening. It is not segmentation performance,
reliability performance, or novelty evidence.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
