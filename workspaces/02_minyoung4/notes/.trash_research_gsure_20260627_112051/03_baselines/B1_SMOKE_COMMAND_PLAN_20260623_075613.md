# B1 Smoke Command Plan

This is a command plan only. It does not approve GPU execution.

## Gate

- overall: `READY_FOR_MIN_APPROVAL`
- preview: `PASSED`
- split: `PASSED`
- output: `PASSED`

## Shared Settings

- GPU: `4` only
- split manifest: `research_gsure/02_audits/outputs/loco_split_manifest.csv`
- preview summary: `research_gsure/03_baselines/outputs/20260623_064056_b1_gpu_preview_ucsd_192x224x160/preview_summary.json`
- heldout fold: `UCSD-PTGBM`
- patch shape: `192,224,160`
- architecture: `unet3d`
- loss: `dice_bce`
- epochs: `3`
- steps per epoch: `16`
- max train rows: `32`
- max validation rows: `2`
- output dir: `research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160`
- output root: `research_gsure/03_baselines/outputs`

## Evidence

- preview max reserved MiB: `5474.0`
- preview tile count: `12`
- outer train rows: `1436`
- internal fit rows: `1292`
- internal validation rows: `144`
- held-out test rows not used by smoke: `178`

## Pre-Launch Check

Run immediately before execution:

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

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
  --output-dir research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160
```

## Expected Runtime

- Roughly 15-40 minutes on one B200.
- Runtime depends on NIfTI I/O and full-volume validation.

## Memory Risk

- Low to moderate on B200 based on preview peak reserved memory.
- bf16 only; fp16 is not used.
- GPU 4 may still be occupied by other processes at launch time, so check `nvidia-smi` immediately before running.

## Files Written

Allowed:

- `research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160/training_log.jsonl`
- `research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json`
- `research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160/checkpoint_last.pt`

Forbidden:

- OOF prediction maps
- held-out test prediction maps
- reliability labels
- writes under `/home/vlm/data/raw/`

## Post-Run Validation

```bash
python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py \
  --smoke-dir research_gsure/03_baselines/outputs/20260623_075613_b1_smoke_UCSD-PTGBM_192x224x160
```

Do not proceed to full LOCO fit until the validator exits with code 0.
