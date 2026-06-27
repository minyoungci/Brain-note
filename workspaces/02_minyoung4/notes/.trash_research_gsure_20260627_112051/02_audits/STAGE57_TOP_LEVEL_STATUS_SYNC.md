# Stage 57 - Top-Level Status Sync

## Task

Synchronize top-level G-SURE status documents with the current strengthened
pre-split readiness gate.

## Research Question

Do README and roadmap summaries tell Min the same current gate status that
`check_pre_split_readiness.py` actually enforces?

## Why This Matters

The top-level documents are the fastest way to understand the research state.
If they omit the strengthened preflight scope or required proxy baselines, the
workspace can look less prepared, or less conservative, than it actually is.

## What Changed

- `README.md` now states that pre-split readiness currently passes and lists the
  main self-test categories, including document-invariant and Stage audit
  coverage negative controls.
- `ROADMAP.md` now includes lesion-size, predicted-volume, and
  image-difficulty proxy baselines in Stage 5 minimum evidence.
- `ROADMAP.md` now records the strengthened negative-control self-test scope in
  the current-stage summary.
- `check_pre_split_readiness.py` now protects those README/ROADMAP status
  phrases with document invariants.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-57
  required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This syncs top-level status only; it does not add performance evidence.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --stage-audit-coverage-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "pre-split readiness gate currently passes|lesion-size, predicted-volume, and image-difficulty proxy baselines|Stage audit coverage negative-control self-tests|STAGE57_TOP_LEVEL_STATUS_SYNC|Stage 2-57" research_gsure/README.md research_gsure/ROADMAP.md research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE57_TOP_LEVEL_STATUS_SYNC.md
```

## Interpretation

This keeps the top-level research state aligned with the actual gate. It is not
segmentation performance evidence and not approval to create the official split.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
