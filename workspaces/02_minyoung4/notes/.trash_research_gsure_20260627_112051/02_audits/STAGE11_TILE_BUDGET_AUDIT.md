# Stage 11 Sliding-Window Tile Budget Audit

## Scope

CSV-only full-cohort draft estimate using `mask_shape` from the subject-level
cohort manifest. This audit does not create official splits, load images, run
model inference, measure GPU memory, or measure runtime.

## Goal Reminder

G-SURE needs assembled full-volume out-of-fold segmentation predictions before
any reliability/error labels can be trusted. Tile budget matters because it
controls how expensive that OOF prediction generation will be.

## Command

```bash
python research_gsure/02_audits/scripts/audit_sliding_window_tile_budget.py
```

Input:

```text
research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv
```

Outputs:

- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level.csv`
- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_by_dataset.csv`
- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_oof_estimate.csv`
- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_report.md`

## Observed Result

Execution result:

```text
Manifest rows: 1614
Detail rows: 9684
Dataset summary rows: 24
OOF estimate rows: 6
```

Shape distribution:

| dataset | shape | subjects |
|---|---|---:|
| MU-Glioma-Post | 240x240x155 | 203 |
| UCSD-PTGBM | 256x256x256 | 178 |
| UPENN-GBM | 240x240x155 | 611 |
| UTSW | 240x240x155 | 622 |

## OOF Tile Budget Estimate

Each subject is counted once as held-out prediction output, matching the intended
OOF LOCO prediction concept. This is still not an official split artifact.

| patch | overlap | OOF tiles | mean tiles/subject | total tile-voxels | relative tile-voxels vs `160x192x160@0.50` |
|---|---:|---:|---:|---:|---:|
| 160x192x160 | 0.25 | 7,168 | 4.44 | 35,232,153,600 | 0.801x |
| 160x192x160 | 0.50 | 8,948 | 5.54 | 43,981,209,600 | 1.000x |
| 192x224x160 | 0.25 | 7,168 | 4.44 | 49,325,015,040 | 1.122x |
| 192x224x160 | 0.50 | 7,880 | 4.88 | 54,224,486,400 | 1.233x |
| 224x224x160 | 0.25 | 7,168 | 4.44 | 57,545,850,880 | 1.308x |
| 224x224x160 | 0.50 | 7,880 | 4.88 | 63,261,900,800 | 1.438x |

UCSD is the tile-count driver:

| patch | overlap | UCSD tiles | non-UCSD tiles per subject |
|---|---:|---:|---:|
| 160x192x160 | 0.25 | 1,424 | 4 |
| 160x192x160 | 0.50 | 3,204 | 4 |
| 192x224x160 | 0.50 | 2,136 | 4 |
| 224x224x160 | 0.50 | 2,136 | 4 |

## Interpretation

- `160x192x160@0.50` remains the memory-conservative full-coverage candidate,
  but it has the highest tile count among the 50% overlap candidates because UCSD
  needs 18 tiles per subject.
- `192x224x160@0.50` reduces UCSD tile count from 18 to 12 and passed
  single-window bbox containment in the 80-subject sample, but its tile-voxel
  budget is 1.233x higher than `160x192x160@0.50`.
- `224x224x160@0.50` has the same tile count as `192x224x160@0.50` but a higher
  tile-voxel budget, so it should not be the first memory-risk candidate unless
  GPU preview shows substantial headroom.
- 0.25 overlap is cheaper, but lower overlap may affect blending and boundary
  stability; use it only as a speed/smoke variant until empirically justified.

## Pre-GPU Recommendation

Preview two candidates after official split and loader smoke:

1. `160x192x160`, overlap `0.50`
   - conservative patch memory,
   - full-volume coverage,
   - lower whole-lesion single-tile context.

2. `192x224x160`, overlap `0.50`
   - better whole-lesion single-tile context in the expanded sample,
   - fewer UCSD tiles,
   - higher patch memory and tile-voxel budget.

Do not preview `224x224x160` first unless the first two candidates clearly fit.

## Guardrails

- Tile budget is not GPU memory proof.
- Tile-voxel budget is only a rough compute proxy.
- This uses the subject-level cohort draft, not an official split manifest.
- Reliability labels still require assembled full-volume OOF prediction maps.

## Next Action

After Min approves official split creation:

1. Create official LOCO split.
2. Run post-split loader smoke.
3. Run a split-aware tile-budget report from the official split manifest using
   `audit_sliding_window_tile_budget.py --split-manifest ... --split-role test`.
4. Preview GPU memory/runtime for `160x192x160@0.50` and `192x224x160@0.50`.
