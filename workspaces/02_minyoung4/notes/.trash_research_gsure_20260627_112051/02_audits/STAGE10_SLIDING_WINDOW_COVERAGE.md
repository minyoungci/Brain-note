# Stage 10 Sliding-Window Coverage Audit

## Scope

CSV-only audit using previously computed bbox outputs. This audit does not load
NIfTI files, create official splits, preprocess data, or run model inference.

## Goal Reminder

The first segmentation baseline must generate out-of-fold full-volume prediction
maps. Those maps later define segmentation error and reliability targets for
G-SURE. Therefore, center-crop-only inference is not acceptable.

## Command

```bash
python research_gsure/02_audits/scripts/audit_sliding_window_coverage.py
```

Input:

```text
research_gsure/02_audits/outputs/loader_transform_feasibility_quantile20.csv
```

Outputs:

- `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20.csv`
- `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20_summary.csv`
- `research_gsure/02_audits/outputs/sliding_window_coverage_quantile20_report.md`

## Observed Result

Execution result:

```text
Input bbox rows: 320
Unique subjects: 80
Detail rows: 480
Output prefix: sliding_window_coverage_quantile20
```

No full-volume coverage failures were found for tested patch sizes and overlaps.

## Key Findings

For `160x192x160` with 50% overlap:

| dataset | sampled subjects | full-volume coverage | bbox union coverage | single-window contains bbox | tiles per volume |
|---|---:|---:|---:|---:|---:|
| MU-Glioma-Post | 20 | 20 | 20 | 18 | 4 |
| UCSD-PTGBM | 20 | 20 | 20 | 19 | 18 |
| UPENN-GBM | 20 | 20 | 20 | 19 | 4 |
| UTSW | 20 | 20 | 20 | 19 | 4 |

Interpretation:

- Full-volume sliding-window inference fixes the center-crop failure mode.
- `160x192x160` with 50% overlap covers every voxel in the expanded 80-subject
  sample.
- Some lesions are split across tiles, so a single tile does not always contain
  the complete lesion bounding box.
- UCSD costs more inference tiles because its canonical volume is `256x256x256`
  rather than `240x240x155`.

For larger tested patches:

| patch | notable result |
|---|---|
| `192x224x160` with 50% overlap | single-window bbox containment passed 80 / 80, UCSD tile count 12 |
| `224x224x160` with 50% overlap | single-window bbox containment passed 80 / 80, UCSD tile count 12 |

## Baseline Implication

The first baseline should not be a fixed-center-crop model.

Two viable pre-GPU candidates remain:

1. `160x192x160` patch with sliding-window/full-volume inference.
   - Lower patch size.
   - More likely to fit GPU memory.
   - Does not guarantee whole-lesion context in one tile.

2. `192x224x160` or `224x224x160` patch with sliding-window/full-volume
   inference.
   - Better whole-lesion single-window containment in the expanded sample.
   - Higher memory risk.

Do not lock either path until GPU memory preview and post-split loader smoke are
reviewed.

## Guardrails

- Sliding-window coverage is not segmentation accuracy.
- Single-window bbox containment is not required for full-volume inference, but
  it matters if we claim the model sees the whole lesion context in one patch.
- Reliability labels must be generated from assembled full-volume OOF
  predictions, not from individual patch predictions alone.
- This audit is based on the 80-subject quantile sample, not the full cohort.

## Next Action

After official split approval:

1. Create the official LOCO split.
2. Run post-split loader smoke.
3. Implement a split-aware transform/inference dry-run that reports tile counts
   for each held-out fold.
4. Preview GPU memory/runtime before training.
