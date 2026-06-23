# GPU Preview Contract

## Scope

This is the required contract before any GPU training or long inference job for
the first segmentation baseline.

No command in this document is approved to run yet. GPU execution still requires
Min approval after command preview.

## Goal Reminder

The first GPU work is not a research result. It is a feasibility preview for
producing full-volume out-of-fold segmentation predictions, which are required
before G-SURE reliability/error labels can be generated.

## Required Pre-Conditions

Before GPU preview:

1. Official LOCO split manifest exists.
2. Official split audit passes.
3. Post-split CPU loader smoke passes.
4. Loader canonicalizes MRI/mask orientation consistently.
5. Test-time path reconstructs full-volume predictions via sliding-window or
   equivalent full-coverage inference.
6. Output paths are reviewed and must not overwrite previous artifacts.

## Candidate Patches

Preview exactly these first:

| candidate | reason |
|---|---|
| `160x192x160`, overlap `0.50` | memory-conservative full-coverage candidate |
| `192x224x160`, overlap `0.50` | better sampled whole-lesion single-tile context with higher memory risk |

Do not preview `224x224x160` first unless both candidates above clearly fit.

## CPU Proxy Evidence

From `STAGE11_TILE_BUDGET_AUDIT.md`:

| candidate | OOF tiles | tile-voxel budget | relative tile-voxels |
|---|---:|---:|---:|
| `160x192x160@0.50` | 8,948 | 43,981,209,600 | 1.000x |
| `192x224x160@0.50` | 7,880 | 54,224,486,400 | 1.233x |

From `patch_memory_proxy.csv`, batch size 1:

| patch | bf16 input MiB | min train tensor proxy MiB | relative train proxy |
|---|---:|---:|---:|
| `160x192x160` | 37.50 | 65.62 | 1.000x |
| `192x224x160` | 52.50 | 91.88 | 1.400x |
| `224x224x160` | 61.25 | 107.19 | 1.633x |

These are lower-bound tensor proxies only. They do not include model activations,
optimizer state, framework overhead, caching, sliding-window buffers, or I/O.

## Preview Must Measure

For each candidate:

- patch shape,
- overlap,
- batch size,
- AMP dtype (`bf16` if available; no fp16),
- peak allocated GPU memory,
- peak reserved GPU memory,
- forward pass success,
- backward pass success for train preview,
- one small validation/inference sliding-window assembly success,
- tile count for sampled rows,
- wall-clock time for a bounded sample,
- output tensor shape,
- whether full-volume output shape matches input canonical shape.

## Stop Criteria

Stop the preview immediately if:

- any candidate causes OOM,
- any loader row has shape/orientation mismatch,
- any target is empty unexpectedly,
- output shape does not match canonical input volume,
- center-crop-only inference is used,
- any output path would overwrite existing artifacts.

## Selection Rule

Prefer `160x192x160@0.50` if:

- it fits comfortably,
- full-volume assembly works,
- runtime is acceptable,
- there is no evidence that missing whole-lesion single-tile context is
  destabilizing the preview.

Prefer `192x224x160@0.50` only if:

- it fits comfortably,
- runtime is acceptable,
- the larger patch is needed for stable whole-lesion context.

Do not select based on Dice during preview. This stage is about feasibility and
safe data flow, not model performance.

## Required Command Preview Fields

Before execution, the command preview must include:

```text
Command:
Working directory:
GPU(s):
Expected runtime:
Expected peak memory risk:
Input manifest:
Held-out fold or sample:
Patch shape:
Overlap:
Batch size:
AMP dtype:
Output directory:
Files to be written:
How to stop:
Validation expected:
```

The command preview should be filled using:

```text
research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md
```

## Post-Preview Required Artifacts

After an approved preview:

- command log,
- memory summary,
- loader/inference shape summary,
- failure log if any,
- recommendation for first B1 smoke training command,
- SCRATCHPAD entry with actual result and interpretation.
