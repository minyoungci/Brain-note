# Stage 49 - Runner Overwrite Flag Forwarding

## Task

Align the consolidated post-split validation runner's `--allow-overwrite` flag
with the underlying tile-audit scripts.

## Research Question

If `run_post_split_validation.py --allow-overwrite` is explicitly used after
separate overwrite approval, do the child tile-budget and tile-grid commands
receive the same overwrite intent?

## Why This Matters

Stage 48 made tile-audit scripts refuse output collisions by default. Without
forwarding, the runner could say overwrite is allowed while child scripts still
refuse, making the post-approval command behavior inconsistent.

## What Changed

- `run_post_split_validation.py` now forwards `--allow-overwrite` to:
  - `audit_sliding_window_tile_budget.py`
  - `audit_tile_grid_dry_run.py`
- The runner dry-run self-test now verifies:
  - default tile-audit steps do not include `--allow-overwrite`,
  - explicit runner `--allow-overwrite` is forwarded to both tile-audit steps.

## Guardrails

- This does not approve overwriting.
- `--allow-overwrite` remains forbidden without separate explicit overwrite
  approval.
- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

Expected self-test output includes:

```text
Allow-overwrite forwarding: verified
```

## Interpretation

This is command-sequence hygiene. It is not approval to overwrite outputs and is
not segmentation performance evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
