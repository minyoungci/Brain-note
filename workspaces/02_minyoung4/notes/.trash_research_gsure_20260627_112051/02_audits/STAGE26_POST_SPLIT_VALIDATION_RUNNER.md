# Stage 26: Post-Split Validation Runner

## Task

Prepare a single CPU-only entry point for validation after official LOCO split
creation.

## Research Question

After the official subject-level LOCO split exists, can we mechanically verify
that split artifacts, loader smoke, and full-volume tile-grid assumptions are
valid before any GPU training or prediction generation?

## Why This Matters

G-SURE depends on reliability/error labels derived from out-of-fold segmentation
predictions. If the official split, loader, or full-volume inference grid is
wrong, all later reliability labels become untrustworthy.

## Scope

The runner is:

- CPU-only,
- preview-only by default,
- refusal-based when official split artifacts are missing,
- limited to post-split validation commands,
- not allowed to create the official split,
- not allowed to run GPU work,
- not allowed to run inference or generate prediction/reliability labels.

## Added Artifact

```text
research_gsure/02_audits/scripts/run_post_split_validation.py
```

## Default Preview Command

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --preview
```

Preview mode reports:

- working directory,
- whether `loco_split_manifest.csv` exists,
- the command sequence,
- expected tile-audit output paths,
- whether those paths already exist.

It does not fail only because the official split is absent.

## Dry-Run Self-Test

The runner also has a CPU-only internal self-test:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test
```

This checks that:

- default held-out dataset selection expands to all four consortia,
- single-fold selection remains available,
- unknown held-out datasets are rejected,
- `--run` preconditions still refuse absent official split artifacts.

The self-test writes no official split files and does not run loader smoke.

## Post-Approval Run Command

Use this only after explicit official LOCO split approval and split creation:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

The run sequence is:

1. official split artifact checker,
2. post-split loader smoke on bounded samples from all held-out consortia,
3. split-aware sliding-window tile budget,
4. split-aware tile-grid dry-run with coverage-hole failure enabled.

The official split artifact checker must validate both lesion-burden summary
fields and timing-warning summary fields against the split manifest.

## Output Safety

Tile-audit outputs use a UTC timestamp tag by default:

```text
YYYYMMDD_HHMMSS_sliding_window_tile_budget_loco_test.*
YYYYMMDD_HHMMSS_tile_grid_dry_run_loco_test.*
```

The runner refuses to overwrite expected outputs unless `--allow-overwrite` is
explicitly passed.

When `--allow-overwrite` is explicitly passed to the runner, the flag is also
forwarded to the underlying tile-budget and tile-grid audit scripts. Without
that flag, neither the runner nor the tile-audit scripts should allow output
collisions.

## Validation

Required validation for this stage:

```bash
python -m py_compile research_gsure/02_audits/scripts/run_post_split_validation.py
python research_gsure/02_audits/scripts/run_post_split_validation.py --dry-run-self-test
python research_gsure/02_audits/scripts/run_post_split_validation.py --preview
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This stage improves experimental hygiene. It is not evidence that segmentation
will work, that G-SURE is novel, or that GPU memory is sufficient. It only makes
the post-split validation gate reproducible.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval.
