# Stage 14 Split-Aware Tile Budget Preparation

## Scope

Prepare `audit_sliding_window_tile_budget.py` for official split manifests
without creating the official split.

## Goal Reminder

After official LOCO split creation, G-SURE needs an official held-out test tile
budget before GPU preview. That budget should be computed from
`loco_split_manifest.csv`, not inferred only from the subject-level draft.

## Change

`audit_sliding_window_tile_budget.py` now supports:

```text
--split-manifest <path>
--split-role test
```

The default subject-level mode remains available.

## Post-Approval Command

After official split creation, run:

```bash
python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --split-role test \
  --candidate-shapes 160x192x160,192x224x160 \
  --overlaps 0.50 \
  --output-prefix sliding_window_tile_budget_loco_test
```

Expected outputs:

```text
research_gsure/02_audits/outputs/sliding_window_tile_budget_loco_test.csv
research_gsure/02_audits/outputs/sliding_window_tile_budget_loco_test_by_dataset.csv
research_gsure/02_audits/outputs/sliding_window_tile_budget_loco_test_oof_estimate.csv
research_gsure/02_audits/outputs/sliding_window_tile_budget_loco_test_report.md
```

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py
```

Subject-mode regression:

```bash
python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py
```

Observed:

```text
Source mode: subject_manifest
Analysis rows: 1614
Detail rows: 9684
Dataset summary rows: 24
OOF estimate rows: 6
```

In-memory split-row logic check:

```text
detail_rows 2
tile_counts [4, 18]
split_fields [('A', 'test', 'A::s1'), ('B', 'test', 'B::s2')]
```

Official split manifest remained absent.

## Guardrails

- This stage did not create `loco_split_manifest.csv`.
- The split-manifest CLI path cannot be fully executed until Min approves split
  creation.
- Use `--split-role test` for OOF prediction budget. `train` and `all` are
  diagnostic only and should not define OOF cost.
