# Stage 47 - Split Builder Write Safety

## Task

Make the official LOCO split builder refuse to write outputs when split
validation errors are present.

## Research Question

Could `build_loco_split_manifest.py --write` create official split artifacts
even after detecting split validation errors?

## Why This Matters

The official split manifest defines all later loader smoke, GPU preview,
out-of-fold prediction, and reliability evaluation. If invalid split rows are
written, downstream checks may run on a fundamentally invalid experiment split.

## What Changed

- `build_loco_split_manifest.py` now refuses to write outputs when
  `validate_summary(...)` returns errors.
- The refusal happens before writing any official split CSV/report.
- The script now supports:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py \
  --write-safety-self-test
```

- `check_pre_split_readiness.py` runs that self-test as part of command checks.

## Self-Test

The self-test:

- reads the current subject-level manifest,
- corrupts one row in memory to create a duplicate `dataset::subject_id`,
- confirms validation errors are detected,
- attempts to write into a temporary directory under the audit outputs folder,
- confirms the write is refused,
- confirms no official split artifacts are written.

## Guardrails

- This does not create official split artifacts.
- Temporary self-test files are removed automatically.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write-safety-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Expected self-test output includes:

```text
Split builder write-safety self-test: PASS
Corrupted split validation errors: detected
Invalid write attempt: refused
Official artifacts written: 0
```

## Interpretation

This hardens the split gate. It does not approve official split creation and is
not segmentation performance evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
