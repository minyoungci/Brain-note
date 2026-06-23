# Stage 18 Tile Grid Dry-Run

## Scope

CPU-only shape-based dry-run of sliding-window tile placement for the first GPU
preview candidate patches. This stage did not create official split files, load
NIfTI files, preprocess data, run inference, run GPU, or train a model.

## Goal Reminder

G-SURE requires assembled full-volume out-of-fold segmentation predictions.
Tile placement must therefore cover the entire canonical volume using image
shape and configured patch/overlap only. It must not depend on held-out lesion
masks or lesion bounding boxes.

## Command

```bash
python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py \
  --candidate-shapes 160x192x160,192x224x160 \
  --overlaps 0.50 \
  --fail-on-coverage-hole
```

## Outputs

- `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level.csv`
- `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level_summary.csv`
- `research_gsure/02_audits/outputs/tile_grid_dry_run_subject_level_report.md`

## Observed Result

```text
Source mode: subject_manifest
Input rows: 1614
Detail rows: 3228
Summary rows: 8
Coverage failures: 0
```

## Summary

| dataset | patch | overlap | subjects | coverage pass | coverage fail | median tiles | total tiles |
|---|---|---:|---:|---:|---:|---:|---:|
| MU-Glioma-Post | `160x192x160` | 0.50 | 203 | 203 | 0 | 4 | 812 |
| MU-Glioma-Post | `192x224x160` | 0.50 | 203 | 203 | 0 | 4 | 812 |
| UCSD-PTGBM | `160x192x160` | 0.50 | 178 | 178 | 0 | 18 | 3,204 |
| UCSD-PTGBM | `192x224x160` | 0.50 | 178 | 178 | 0 | 12 | 2,136 |
| UPENN-GBM | `160x192x160` | 0.50 | 611 | 611 | 0 | 4 | 2,444 |
| UPENN-GBM | `192x224x160` | 0.50 | 611 | 611 | 0 | 4 | 2,444 |
| UTSW | `160x192x160` | 0.50 | 622 | 622 | 0 | 4 | 2,488 |
| UTSW | `192x224x160` | 0.50 | 622 | 622 | 0 | 4 | 2,488 |

## Interpretation

Both first-preview candidates have shape-based full-volume coverage for every
subject-level draft cohort row. UCSD remains the tile-count driver:

- `160x192x160@0.50`: 18 tiles per UCSD subject.
- `192x224x160@0.50`: 12 tiles per UCSD subject.

This supports keeping both candidates for GPU preview. It does not select a
winner and does not prove memory feasibility or segmentation quality.

## Guardrails

- This dry-run uses manifest shapes only.
- It does not validate loader canonicalization on every NIfTI file.
- It does not validate blending quality for overlapping tiles.
- It does not replace post-split smoke or split-aware tile-grid dry-run after
  official split creation.
- Reliability labels still require actual assembled full-volume OOF prediction
  maps.

## Next Action

After official split approval, rerun the same dry-run using:

```bash
python research_gsure/02_audits/scripts/audit_tile_grid_dry_run.py \
  --split-manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --split-role test \
  --candidate-shapes 160x192x160,192x224x160 \
  --overlaps 0.50 \
  --output-prefix tile_grid_dry_run_loco_test \
  --fail-on-coverage-hole
```
