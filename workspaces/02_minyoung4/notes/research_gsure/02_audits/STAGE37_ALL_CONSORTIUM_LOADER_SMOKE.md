# Stage 37 - All-Consortium Loader Smoke

## Task

Strengthen post-split validation so bounded loader smoke runs for every held-out
consortium by default.

## Research Question

Can the post-split gate catch fold-specific loader/geometry failures before GPU
preview, instead of smoking only one held-out consortium?

## What Changed

- `run_post_split_validation.py` now defaults `--heldout-dataset` to `all`.
- The runner expands `all` to:
  - `MU-Glioma-Post`
  - `UCSD-PTGBM`
  - `UPENN-GBM`
  - `UTSW`
- Single-fold smoke remains available by passing `--heldout-dataset`.
- Approval packet, post-approval runbook, and loader smoke contract now state
  that all held-out consortia are smoked by default.
- Stage 38 adds a runner dry-run self-test so this all-consortium default is
  checked automatically by preflight.

## Guardrails

- The runner still does not create official split artifacts.
- The runner still refuses `--run` when official split artifacts are absent.
- The smoke is CPU-only and bounded by `--max-smoke-rows`.
- No preprocessing arrays, predictions, labels, metrics, checkpoints, or GPU
  work are created by this change.

## Current Status

Preview-ready only. The official split is still absent, so `--run` remains
blocked until explicit split approval and split creation.
