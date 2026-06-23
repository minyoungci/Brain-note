# Post-Approval Split Runbook

## Scope

This runbook starts only after Min explicitly approves official LOCO split
creation. It is not authorization to run the commands by itself.

## Step 0. Confirm Gate

Before running anything, confirm:

```text
Min approved official LOCO split creation for the subject-level G-SURE cohort.
```

Before approval is acted on, the pre-split readiness preflight should pass:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

The observed preflight output should include:

```text
[OK] document invariant self-test
[OK] Stage audit coverage self-test
[OK] output evidence coverage self-test
Pre-split readiness: PASS
Official split artifacts: absent
```

Also confirm the official split file does not already exist:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --expect-missing
```

Confirm the official split checker logic against in-memory generated rows:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --dry-run-self-test
```

The split builder refuses to overwrite existing official split outputs unless
`--force` is provided. Do not use `--force` without a separate explicit overwrite
approval.

The split builder must also refuse to write any split outputs if validation
errors are present, even when `--write` is passed. The pre-split readiness
preflight runs a write-safety self-test for this behavior.

## Step 1. Create Official Split

Command:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write
```

Expected output:

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
Wrote official split outputs to: research_gsure/02_audits/outputs
```

Expected files:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
research_gsure/02_audits/outputs/loco_split_summary.csv
research_gsure/02_audits/outputs/loco_split_audit_report.md
```

## Step 2. Inspect Split Summary

Run the official split artifact checker:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py
```

Commands:

```bash
sed -n '1,120p' research_gsure/02_audits/outputs/loco_split_summary.csv
sed -n '1,180p' research_gsure/02_audits/outputs/loco_split_audit_report.md
```

Hard failures:

- subject overlap > 0,
- duplicate train/test subjects,
- missing MRI/mask paths,
- unexpected fold counts,
- missing lesion-burden summary fields,
- lesion-burden summary values that do not match the split manifest.
- timing-warning summary values that do not match the split manifest,
- any validation-error split write.

## Step 2.5. Run Consolidated Post-Split Validation

Preferred command after Step 2 passes:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

Before official split creation, only preview the sequence:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --preview
```

The runner does not create the official split and does not run GPU work. In
`--run` mode it refuses to proceed if the official split manifest is absent.
It executes the official split checker, all-consortium bounded loader smoke,
split-aware tile budget, and split-aware tile-grid dry-run in order.

The tile-audit outputs use a UTC timestamp tag by default so previous audit
artifacts are not overwritten.

Manual tile-audit commands are fallback/debug commands. Prefer the consolidated
runner above. If manual commands are required, use a unique UTC tag and do not
pass `--allow-overwrite` unless Min gives separate explicit overwrite approval.

## Step 3. Run Post-Split Loader Smoke

Command:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

The runner performs all-fold bounded loader smoke before tile budget/grid
checks. This is CPU-only and reads bounded samples. It must not write
preprocessed data.

Hard failures:

- manifest missing,
- no selected rows,
- any MRI/mask load failure,
- channel/mask shape mismatch,
- channel/mask affine mismatch,
- channel/mask orientation mismatch,
- channel/mask voxel-spacing mismatch,
- non-finite values,
- empty binary target.

## Step 4. Recompute Official-Split Tile Budget

After the official split exists, recompute a split-aware tile budget from the
official test rows:

```bash
RUN_TAG=$(date -u +%Y%m%d_%H%M%S)
python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --split-role test \
  --candidate-shapes 160x192x160,192x224x160 \
  --overlaps 0.50 \
  --output-prefix ${RUN_TAG}_sliding_window_tile_budget_loco_test
```

Required candidates:

```text
160x192x160 overlap 0.50
192x224x160 overlap 0.50
```

## Step 5. Run Official-Split Tile Grid Dry-Run

Run the shape-based full-volume tile-grid dry-run on official held-out test rows:

```bash
RUN_TAG=$(date -u +%Y%m%d_%H%M%S)
python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --split-role test \
  --candidate-shapes 160x192x160,192x224x160 \
  --overlaps 0.50 \
  --output-prefix ${RUN_TAG}_tile_grid_dry_run_loco_test \
  --fail-on-coverage-hole
```

Hard failures:

- any coverage failure,
- unexpected row count,
- tile counts that contradict the split-aware tile budget,
- command writes outside `research_gsure/02_audits/outputs`.

## Step 6. Prepare GPU Command Preview

Do not run GPU yet. Prepare a command preview satisfying:

```text
research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md
```

The preview must include:

- command,
- working directory,
- expected runtime,
- GPU(s),
- memory risk,
- files to be written,
- output directory,
- how to stop,
- validation expected.

## Stop Rules

Stop and report before GPU if:

- official split validation fails,
- loader smoke fails,
- lesion-burden summary validation fails,
- split-aware tile budget contradicts the current draft-cohort estimate,
- split-aware tile-grid dry-run has any coverage failure,
- any output path would overwrite an existing artifact,
- any manual tile-audit command uses a non-unique output prefix or
  `--allow-overwrite` without separate explicit approval,
- any command would write outside `/home/vlm/minyoung4`.
