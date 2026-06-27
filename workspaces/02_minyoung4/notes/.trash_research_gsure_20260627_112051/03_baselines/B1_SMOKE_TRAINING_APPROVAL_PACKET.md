# B1 Smoke Training Approval Packet

## Research Purpose

Run the first bounded scratch B1 segmentation training job after the successful
GPU preview.

This is still a smoke experiment, not a final baseline. It should answer:

```text
Can scratch B1 train for a few epochs, write safe logs/checkpoint, and validate
full-volume assembly on train-consortia validation rows without touching held-out
test predictions?
```

## Pre-Task Definition

Task:
- Run bounded B1 scratch 3D U-Net smoke training on GPU 4.

Research question:
- Does the official LOCO B1 training path execute beyond preview and produce
  meaningful training/validation artifacts safely?

Why this matters:
- Full B1 OOF training should not start until checkpointing, logging, and
  validation assembly have been smoke-tested.

Hypothesis:
- `192x224x160@0.50` will run safely on B200 GPU 4 based on preview memory
  evidence.

Outcome:
- `training_log.jsonl`, `smoke_summary.json`, and `checkpoint_last.pt`.
- `smoke_summary.json` must include finite-loss checks, validation Dice summary,
  validation shape checks, and an explicit `decision.smoke_passed` field.

Input / exposure:
- Four MRI channels `[T1, T1ce, T2, FLAIR]`.

Unit of analysis:
- subject-level selected imaging unit.

Cohort / filters:
- official LOCO split manifest:
  `research_gsure/02_audits/outputs/loco_split_manifest.csv`.

Label source and semantics:
- `selected_mask > 0`, binary whole-lesion target.

Split policy:
- outer held-out fold: `UCSD-PTGBM`.
- fit rows: deterministic subset of the outer train rows.
- validation rows: deterministic split of outer train rows only.
- held-out UCSD test rows are not used for validation, early stopping, or
  prediction output in this smoke run.

Primary metric:
- smoke-level train loss trajectory and internal validation full-volume Dice.

Baseline:
- scratch 3D U-Net, Dice+BCE, AdamW.

Leakage risks:
- held-out test rows must not be used for validation;
- no OOF prediction maps are written;
- no reliability labels are written;
- checkpoint is a smoke checkpoint only.

Shortcut/confounding risks:
- not evaluated in smoke training; this is execution readiness before baseline
  performance experiments.

Files to inspect:
- `research_gsure/03_baselines/scripts/train_b1_segmentation.py`
- `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- `research_gsure/03_baselines/B1_GPU_PREVIEW_RESULT_20260623_064056.md`

Files to change:
- none during execution except timestamped smoke outputs.

Expected artifact:
- timestamped smoke output directory under `research_gsure/03_baselines/outputs/`.

Validation:
- train loss log exists;
- train losses are finite;
- internal validation rows assemble full-volume outputs;
- internal validation output shapes match canonical input shapes;
- internal validation Dice values are finite;
- checkpoint exists and is not overwritten;
- held-out test predictions are absent.
- `validate_b1_smoke_result.py` passes on the smoke output directory.

Compute scope:
- one GPU, short bounded run.

Unclear assumptions:
- train loss may not monotonically decrease in a very short smoke run.
- internal validation Dice is only a sanity signal, not publishable evidence.

Needs Min approval:
- yes, before executing the smoke training command.

## Evidence From GPU Preview

Preview on GPU 4 passed for both candidates.

Recommended candidate:

```text
192x224x160@0.50
```

Preview peak memory for this candidate:

```text
allocated 4083.90 MiB, reserved 5474.00 MiB
```

## Internal Split Check

For `heldout_dataset=UCSD-PTGBM`, deterministic internal split with seed
`20260623` produced:

```text
outer_train=1436
fit=1292
internal_val=144
heldout_test=178
fit_val_overlap=0
val_test_overlap=0
fit_test_overlap=0
```

The smoke command below uses bounded subsets from those fit/validation rows.

## Current GPU State

Observed on 2026-06-23 06:45 UTC:

```text
0, NVIDIA B200, 183359 MiB, 0 MiB
1, NVIDIA B200, 183359 MiB, 30958 MiB
2, NVIDIA B200, 183359 MiB, 0 MiB
3, NVIDIA B200, 183359 MiB, 0 MiB
4, NVIDIA B200, 183359 MiB, 0 MiB
5, NVIDIA B200, 183359 MiB, 171176 MiB
6, NVIDIA B200, 183359 MiB, 78080 MiB
7, NVIDIA B200, 183359 MiB, 41024 MiB
```

Use GPU 4 only.

## Command Preview

Working directory:

```bash
/home/vlm/minyoung4
```

Command:

```bash
CUDA_VISIBLE_DEVICES=4 python research_gsure/03_baselines/scripts/train_b1_segmentation.py \
  --mode smoke \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --patch-shape 192,224,160 \
  --overlap 0.50 \
  --batch-size 1 \
  --architecture unet3d \
  --base-channels 16 \
  --depth 4 \
  --loss dice_bce \
  --epochs 3 \
  --steps-per-epoch 16 \
  --max-train-rows 32 \
  --max-val-rows 2 \
  --val-fraction 0.10 \
  --validate-every 1 \
  --foreground-prob 0.67 \
  --lr 1e-4 \
  --weight-decay 1e-4 \
  --num-workers 0 \
  --device cuda \
  --amp-dtype bf16 \
  --seed 20260623 \
  --output-dir research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160
```

## Expected Runtime

- Roughly 15-40 minutes on one B200.
- Runtime is dominated by repeated NIfTI loading and full-volume validation.

## Expected Memory Risk

- Low to moderate on B200.
- Preview peak reserved memory for the same patch was 5474 MiB.
- Smoke training may use somewhat more due checkpoint/logging overhead but should
  remain far below B200 capacity.

## Files Written

Allowed:

- `research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160/training_log.jsonl`
- `research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160/smoke_summary.json`
- `research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160/checkpoint_last.pt`

Forbidden:

- OOF prediction maps,
- held-out test prediction maps,
- reliability labels,
- publication tables,
- writes under `/home/vlm/data/raw/`.

## Stop Criteria

Stop if:

- OOM occurs,
- validation output shape differs from input shape,
- any output path would overwrite an existing file,
- held-out test predictions are written,
- train loss is NaN/inf,
- geometry check fails.

## Post-Smoke Decision

After the smoke command completes, run:

```bash
python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py \
  --smoke-dir research_gsure/03_baselines/outputs/20260623_064541_b1_smoke_ucsd_192x224x160
```

If smoke passes:

- move to B1.2 full OOF training plan for all four LOCO folds, still scratch.
- Use `decision.smoke_passed == true`, finite losses, and matching validation
  output shapes as the execution-readiness gate.
- Require the validator command above to exit with code 0.

If smoke fails:

- classify failure as code/runtime/data/modeling before changing architecture.
