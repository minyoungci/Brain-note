# B1 GPU Preview Approval Packet

## Research Purpose

Answer one bounded question:

```text
Can the scratch B1 segmentation path run with bf16 on GPU and assemble a
full-volume held-out prediction without writing checkpoints or OOF maps?
```

This is not segmentation performance evidence and must not be used for model
selection by held-out Dice.

## Pre-Task Definition

Task:
- Run a bounded B1 scratch 3D U-Net GPU preview after Min approval.

Research question:
- Is the loader/model/inference path feasible enough to proceed to B1 smoke
  training?

Why this matters:
- G-SURE needs full-volume OOF segmentation maps before reliability labels can be
  generated.

Hypothesis:
- On a B200 GPU, both candidate patch sizes can run bf16 forward/backward and one
  held-out full-volume sliding-window assembly.

Outcome:
- Preview summary JSON per candidate, including memory and output-shape checks.

Input / exposure:
- 4-channel MRI `[T1, T1ce, T2, FLAIR]`.

Unit of analysis:
- subject-level selected imaging unit from the official LOCO split manifest.

Cohort / filters:
- official split manifest only:
  `research_gsure/02_audits/outputs/loco_split_manifest.csv`.

Label source and semantics:
- `selected_mask > 0`, binary whole-lesion target.

Split policy:
- held-out fold `UCSD-PTGBM`; train rows are the other consortia, test rows are
  UCSD only.

Primary metric:
- preview has no performance metric; it checks runtime, memory, geometry, and
  assembly.

Baseline:
- scratch 3D U-Net, Dice+BCE, AdamW.

Leakage risks:
- no held-out masks for crop/tile placement;
- no checkpoint or OOF prediction map is written;
- split leakage groups are validated by the script.

Shortcut/confounding risks:
- not assessed in preview; this is a segmentation data-flow check only.

Files to inspect:
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`

Files to change:
- none during preview, except timestamped summary outputs.

Expected artifact:
- `preview_summary.json` for each candidate.

Validation:
- forward/backward train patch pass;
- full-volume shape-based sliding-window assembly;
- output probability shape equals canonical input shape.

Compute scope:
- one GPU, bounded rows, one epoch, two train steps per candidate.

Unclear assumptions:
- preview runtime may vary with shared server load.

Needs Min approval:
- yes, before executing either GPU command.

## Current GPU State

Observed with `nvidia-smi --query-gpu=index,name,memory.total,memory.used --format=csv,noheader`
on 2026-06-23 06:35 UTC:

```text
0, NVIDIA B200, 183359 MiB, 0 MiB
1, NVIDIA B200, 183359 MiB, 30958 MiB
2, NVIDIA B200, 183359 MiB, 0 MiB
3, NVIDIA B200, 183359 MiB, 0 MiB
4, NVIDIA B200, 183359 MiB, 0 MiB
5, NVIDIA B200, 183359 MiB, 171176 MiB
6, NVIDIA B200, 183359 MiB, 111434 MiB
7, NVIDIA B200, 183359 MiB, 73376 MiB
```

Recommended GPU:
- GPU 4 only. Use one GPU only.

## Command Preview

Working directory:

```bash
/home/vlm/minyoung4
```

Candidate A:

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode preview \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --patch-shape 160,192,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --base-channels 16 \
  --depth 4 \
  --epochs 1 \
  --steps-per-epoch 2 \
  --max-train-rows 4 \
  --max-infer-rows 1 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_063510_b1_gpu_preview_ucsd_160x192x160
```

Candidate B:

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode preview \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --base-channels 16 \
  --depth 4 \
  --epochs 1 \
  --steps-per-epoch 2 \
  --max-train-rows 4 \
  --max-infer-rows 1 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_063510_b1_gpu_preview_ucsd_192x224x160
```

## Expected Runtime

- Candidate A: roughly 5-15 minutes.
- Candidate B: roughly 5-20 minutes.

The estimate is intentionally conservative because it includes NIfTI I/O and one
full-volume UCSD sliding-window assembly.

## Memory Risk

- GPU: one B200.
- AMP: bf16 only; no fp16.
- Batch size: 1.
- Risk: moderate for Candidate B due larger activations, but expected to fit on
  B200 under this bounded preview.

## Files Written

Allowed:

- `research_gsure/03_baselines/outputs/20260623_063510_b1_gpu_preview_ucsd_160x192x160/preview_summary.json`
- `research_gsure/03_baselines/outputs/20260623_063510_b1_gpu_preview_ucsd_192x224x160/preview_summary.json`

Forbidden:

- checkpoints,
- OOF prediction maps,
- reliability labels,
- publication tables,
- writes under `/home/vlm/data/raw/`.

## How To Stop

- Foreground shell: press `Ctrl-C`.
- If detached by mistake, find the PID with `nvidia-smi` and stop that process.

## Stop Criteria

Stop immediately if:

- OOM occurs,
- geometry check fails,
- output shape differs from canonical input shape,
- the command attempts to write checkpoints or OOF maps,
- held-out masks are used for crop/tile placement.

## Post-Preview Decision

Choose patch size by:

- successful forward/backward,
- successful full-volume assembly,
- peak memory,
- runtime.

Do not choose by held-out Dice in this preview.
