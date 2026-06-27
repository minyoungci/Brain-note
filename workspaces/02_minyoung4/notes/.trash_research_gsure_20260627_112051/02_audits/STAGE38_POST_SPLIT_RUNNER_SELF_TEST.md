# Stage 38 - Post-Split Runner Self-Test

## Task

Add a CPU-only self-test for the consolidated post-split validation runner.

## Research Question

Can the pre-split gate detect if the post-split validation runner silently
regresses from all-consortium loader smoke to a single held-out consortium?

## Why This Matters

G-SURE depends on subject-level, consortium-heldout reliability evidence. If the
post-split gate only smokes one held-out consortium, fold-specific loader,
geometry, or path failures could survive until GPU work or prediction
generation.

## What Changed

- `run_post_split_validation.py` now supports:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test
```

- `check_pre_split_readiness.py` runs that self-test as part of command checks.

## Self-Test Assertions

The self-test verifies:

- default held-out dataset selection expands to four loader-smoke steps,
- the four default loader-smoke steps are:
  - `MU-Glioma-Post`
  - `UCSD-PTGBM`
  - `UPENN-GBM`
  - `UTSW`
- single-fold selection produces exactly one loader-smoke step,
- unknown held-out datasets are rejected,
- absent official split manifests are refused for run preconditions.

## Guardrails

- No official split artifacts are created.
- No image loading is performed.
- No GPU work is performed.
- No predictions, reliability labels, metrics, checkpoints, or preprocessing
  arrays are generated.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Expected self-test output includes:

```text
Post-split validation runner dry-run self-test: PASS
Default loader smoke steps: 4
Single-fold loader smoke steps: 1
Unknown heldout dataset: rejected
Absent official split manifest: refused
Allow-overwrite forwarding: verified
```

## Interpretation

This is a gate-integrity check only. It does not validate segmentation
performance, reliability metrics, novelty, or GPU feasibility.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval.
