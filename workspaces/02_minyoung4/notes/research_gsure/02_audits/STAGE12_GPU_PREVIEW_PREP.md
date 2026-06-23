# Stage 12 GPU Preview Preparation

## Scope

Prepare the first segmentation-baseline GPU preview contract without running GPU,
creating official splits, preprocessing data, or launching training.

## Goal Reminder

G-SURE needs full-volume out-of-fold segmentation predictions before reliability
labels can exist. GPU preview is only a feasibility gate for that pipeline.

## Inputs Reviewed

- `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`
- `research_gsure/02_audits/outputs/sliding_window_tile_budget_subject_level_oof_estimate.csv`
- `research_gsure/02_audits/outputs/patch_memory_proxy.csv`

## CPU-Only Proxy Result

Patch tensor proxy, batch size 1:

| patch | patch voxels | min train tensor proxy MiB | relative |
|---|---:|---:|---:|
| `160x192x160` | 4,915,200 | 65.62 | 1.000x |
| `192x224x160` | 6,881,280 | 91.88 | 1.400x |
| `224x224x160` | 8,028,160 | 107.19 | 1.633x |

OOF tile-voxel budget:

| candidate | total tile-voxels | relative |
|---|---:|---:|
| `160x192x160@0.50` | 43,981,209,600 | 1.000x |
| `192x224x160@0.50` | 54,224,486,400 | 1.233x |
| `224x224x160@0.50` | 63,261,900,800 | 1.438x |

## Decision

The first GPU preview should compare only:

1. `160x192x160@0.50`
2. `192x224x160@0.50`

`224x224x160` is deferred because it has the same UCSD tile count as
`192x224x160` but a higher tile-voxel and patch-memory proxy.

## Contract

The required execution contract is documented in:

```text
research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md
```

## Guardrails

- This stage did not run GPU.
- This stage did not create official split files.
- CPU proxy values are not actual memory measurements.
- Preview must not use Dice as a selection criterion.
- Center-crop-only inference remains disallowed.

## Next Action

After official split approval:

1. Create official LOCO split.
2. Run post-split loader smoke.
3. Run split-aware tile budget from official split.
4. Present GPU command preview for the two candidate patch sizes.
