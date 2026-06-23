# Stage 48 - Tile Audit Overwrite Safety

## Task

Prevent sliding-window tile budget and tile-grid dry-run audit outputs from
silently overwriting existing artifacts.

## Research Question

Could manual post-split tile-audit commands overwrite previous gate evidence if
they reuse fixed output prefixes?

## Why This Matters

Tile budget and tile-grid dry-run outputs are part of the pre-GPU gate after
official split creation. Silent overwrites can hide stale or contradictory gate
evidence.

## What Changed

- `audit_sliding_window_tile_budget.py` now refuses expected output collisions
  by default.
- `audit_tile_grid_dry_run.py` now refuses expected output collisions by
  default.
- Both scripts accept `--allow-overwrite`, which remains forbidden without
  separate explicit overwrite approval.
- Both scripts expose `--overwrite-safety-self-test`.
- `run_post_split_validation.py` forwards `--allow-overwrite` to both tile-audit
  scripts when the runner flag is explicitly passed.
- `check_pre_split_readiness.py` runs both overwrite-safety self-tests.
- `POST_APPROVAL_SPLIT_RUNBOOK.md` now uses UTC timestamped prefixes for manual
  fallback tile-audit commands and recommends the consolidated runner first.

## Guardrails

- This does not create official split artifacts.
- Self-test temporary directories are removed automatically.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py --overwrite-safety-self-test
python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py --overwrite-safety-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This is gate-evidence hygiene. It does not prove segmentation performance, GPU
feasibility, or reliability generalization.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
