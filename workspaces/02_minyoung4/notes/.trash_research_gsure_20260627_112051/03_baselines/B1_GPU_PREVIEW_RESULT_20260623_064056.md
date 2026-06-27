# B1 GPU Preview Result — 2026-06-23 06:40 UTC

## Scope

This was the approved bounded GPU preview for the scratch B1 segmentation path.

It was not a segmentation performance experiment. The run did not write
checkpoints, OOF prediction maps, reliability labels, or publication tables.

## Command Context

Working directory:

```text
/home/vlm/minyoung4
```

GPU:

```text
CUDA_VISIBLE_DEVICES=4
```

Model:

```text
scratch 3D U-Net, base_channels=16, depth=4
```

Fold:

```text
heldout_dataset=UCSD-PTGBM
```

Bound:

```text
epochs=1, steps_per_epoch=2, max_train_rows=4, max_infer_rows=1
```

AMP:

```text
bf16
```

## Results

| candidate | status | peak allocated MiB | peak reserved MiB | train loss | train seconds | held-out tiles | output shape |
|---|---|---:|---:|---:|---:|---:|---|
| `160x192x160@0.50` | PASS | 2940.91 | 3934.00 | 0.8685 | 11.48 | 18 | `256x256x256` |
| `192x224x160@0.50` | PASS | 4083.90 | 5474.00 | 0.8701 | 11.15 | 12 | `256x256x256` |

## Written Artifacts

- `research_gsure/03_baselines/outputs/20260623_064056_b1_gpu_preview_ucsd_160x192x160/preview_summary.json`
- `research_gsure/03_baselines/outputs/20260623_064056_b1_gpu_preview_ucsd_192x224x160/preview_summary.json`

## Interpretation

- Both candidate patch sizes fit easily on B200 GPU 4 for the bounded preview.
- Both candidates completed scratch forward/backward with bf16.
- Both candidates assembled a full-volume UCSD held-out probability map with
  output shape equal to the canonical input shape.
- The larger `192x224x160` candidate used about 1.39x peak allocated memory
  relative to `160x192x160`, reduced the sampled UCSD tile count from 18 to 12,
  and remained low risk on this GPU.

## Recommendation

Use `192x224x160@0.50` for the first B1 smoke training command on B200 if the
goal is stronger spatial context with acceptable memory risk.

Keep `160x192x160@0.50` as the fallback if full training runtime or memory grows
unexpectedly once checkpointing, validation cadence, or larger batch settings are
introduced.

## Remaining Limits

- This preview does not measure Dice.
- This preview does not prove learning quality.
- This preview used only one held-out UCSD inference case.
- The next stage must be a separately approved smoke training run with explicit
  checkpoint/log policy.
