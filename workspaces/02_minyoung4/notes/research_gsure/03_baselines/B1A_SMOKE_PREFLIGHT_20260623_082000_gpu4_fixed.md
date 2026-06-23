# B1A Smoke Preflight

This preflight is CPU-only. It does not approve or launch GPU training.

- run prefix: `20260623_080846_b1a_unet3d_dice_bce_bc16_d4`
- status: `READY_FOR_MIN_APPROVAL`
- valid: `True`
- plan chain valid: `True`
- smoke plan: `research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke.md`
- smoke output dir: `research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160`
- requires Min approval before execution: `True`

## GPU 4

- name: `NVIDIA B200`
- memory used MiB: `28568`
- memory total MiB: `183359`
- utilization percent: `99`

## Command Preview

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
  --output-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160
```

## Post-Run Validation

```bash
python research_gsure/03_baselines/scripts/validate_b1_smoke_result.py --smoke-dir research_gsure/03_baselines/outputs/20260623_080846_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160
```

Do not proceed to full LOCO fit until the post-run validator exits with code 0.
