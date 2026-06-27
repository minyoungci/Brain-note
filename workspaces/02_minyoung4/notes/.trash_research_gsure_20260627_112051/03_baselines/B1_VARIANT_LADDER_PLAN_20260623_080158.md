# B1 Variant Ladder Plan

This is a planning artifact only. It does not approve GPU training, inference, or metric reporting.

## Research Claim Under Test

A scratch 3D segmentation baseline can be strengthened through controlled loss, architecture, and capacity variants while preserving LOCO generalization and worst-consortium selection guards.

## Decision Rule

- Do not compare variants until each candidate has all four LOCO prediction manifests and a combined segmentation evaluation summary.
- Select by worst-consortium mean Dice first, then overall mean Dice, then lower Dice<=0.8 failure rate.
- If any consortium degenerates, stop architecture search and analyze data/model failure before trying more hyperparameters.
- Every new architecture/capacity setting needs a bounded GPU4 smoke before full LOCO fit.

## Variant Registry

| order | variant | tier | architecture | loss | base channels | depth | status | purpose |
|---:|---|---|---|---|---:|---:|---|---|
| 1 | `b1a_unet3d_dice_bce_bc16_d4` | primary_baseline | unet3d | dice_bce | 16 | 4 | `next_after_gpu4_smoke_approval` | First scratch 3D U-Net LOCO segmentation baseline. |
| 2 | `b1b_unet3d_dice_focal_bc16_d4` | loss_variant | unet3d | dice_focal | 16 | 4 | `blocked_until_primary_baseline_oof_metrics` | Test whether focal loss improves small/uncertain lesion recall without false-positive collapse. |
| 3 | `b1c_unet3d_dice_tversky_bc16_d4` | loss_variant | unet3d | dice_tversky | 16 | 4 | `blocked_until_primary_baseline_oof_metrics` | Test asymmetric FP/FN tradeoff while holding architecture fixed. |
| 4 | `b1d_resunet3d_dice_bce_bc16_d4` | architecture_variant | resunet3d | dice_bce | 16 | 4 | `blocked_until_primary_baseline_oof_metrics` | Test residual blocks as the first structure change under the same loss/capacity scale. |
| 5 | `b1e_resunet3d_dice_focal_bc16_d4` | architecture_loss_combo | resunet3d | dice_focal | 16 | 4 | `blocked_until_primary_baseline_oof_metrics` | Test focal loss only if residual architecture is not worse by worst-consortium guard. |
| 6 | `b1f_unet3d_dice_bce_bc24_d4` | capacity_variant | unet3d | dice_bce | 24 | 4 | `blocked_until_primary_baseline_oof_metrics` | Test wider U-Net capacity after the loss/architecture signal is known. |

## Gate Summary

- evaluated variants supplied: `0`
- GPU binding for generated command plans: `4` only
- patch shape: `192,224,160`
- current workspace still requires explicit Min approval before any GPU smoke or full-fit execution.

## Command-Plan Generation Sequence

Generate and review these command plans. Do not execute generated GPU commands without a separate approval message.

### b1a_unet3d_dice_bce_bc16_d4

Unlock rule: Run first after bounded GPU4 smoke approval.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1a_unet3d_dice_bce_bc16_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_fit \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1a_unet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1a_unet3d_dice_bce_bc16_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_fit \
  --predict-timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_predict \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1a_unet3d_dice_bce_bc16_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_predict \
  --metrics-timestamp 20260623_080158_b1a_unet3d_dice_bce_bc16_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1a_unet3d_dice_bce_bc16_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1a_unet3d_dice_bce_bc16_d4_eval.md
```

### b1b_unet3d_dice_focal_bc16_d4

Unlock rule: Run only after B1A has complete OOF metrics.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1b_unet3d_dice_focal_bc16_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_fit \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1b_unet3d_dice_focal_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1b_unet3d_dice_focal_bc16_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_fit \
  --predict-timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_predict \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1b_unet3d_dice_focal_bc16_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_predict \
  --metrics-timestamp 20260623_080158_b1b_unet3d_dice_focal_bc16_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1b_unet3d_dice_focal_bc16_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1b_unet3d_dice_focal_bc16_d4_eval.md
```

### b1c_unet3d_dice_tversky_bc16_d4

Unlock rule: Run only after B1A has complete OOF metrics.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_tversky \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_fit \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_tversky \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_fit \
  --predict-timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_predict \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_tversky \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_predict \
  --metrics-timestamp 20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1c_unet3d_dice_tversky_bc16_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_eval.md
```

### b1d_resunet3d_dice_bce_bc16_d4

Unlock rule: Run after B1A and at least one loss variant are evaluated, unless B1A is degenerate.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_fit \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_fit \
  --predict-timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_predict \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_bce \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_predict \
  --metrics-timestamp 20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1d_resunet3d_dice_bce_bc16_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1d_resunet3d_dice_bce_bc16_d4_eval.md
```

### b1e_resunet3d_dice_focal_bc16_d4

Unlock rule: Run only if B1D is competitive with B1A on worst-consortium mean Dice.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_fit \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_fit \
  --predict-timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_predict \
  --patch-shape 192,224,160 \
  --architecture resunet3d \
  --loss dice_focal \
  --base-channels 16 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_predict \
  --metrics-timestamp 20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1e_resunet3d_dice_focal_bc16_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1e_resunet3d_dice_focal_bc16_d4_eval.md
```

### b1f_unet3d_dice_bce_bc24_d4

Unlock rule: Run only if B1A is not degenerate and GPU4 smoke passes for this wider model.

Smoke plan:

```bash
python research_gsure/03_baselines/scripts/plan_b1_smoke_command.py \
  --timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_smoke \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 24 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_SMOKE_COMMAND_PLAN_20260623_080158_b1f_unet3d_dice_bce_bc24_d4_smoke.md
```

Full-fit plan after smoke validator passes:

```bash
python research_gsure/03_baselines/scripts/plan_b1_fit_commands.py \
  --timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_fit \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 24 \
  --depth 4 \
  --gpu 4 \
  --smoke-summary research_gsure/03_baselines/outputs/20260623_080158_b1f_unet3d_dice_bce_bc24_d4_smoke_b1_smoke_UCSD-PTGBM_192x224x160/smoke_summary.json \
  --output-md research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080158_b1f_unet3d_dice_bce_bc24_d4_fit.md
```

Prediction plan after all fit checkpoints and fit summaries exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_predict_commands.py \
  --fit-timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_fit \
  --predict-timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_predict \
  --patch-shape 192,224,160 \
  --architecture unet3d \
  --loss dice_bce \
  --base-channels 24 \
  --depth 4 \
  --gpu 4 \
  --output-md research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080158_b1f_unet3d_dice_bce_bc24_d4_predict.md
```

Evaluation plan after prediction manifests exist:

```bash
python research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py \
  --predict-timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_predict \
  --metrics-timestamp 20260623_080158_b1f_unet3d_dice_bce_bc24_d4_eval \
  --patch-shape 192,224,160 \
  --output-prefix b1f_unet3d_dice_bce_bc24_d4_segmentation_metrics \
  --output-md research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080158_b1f_unet3d_dice_bce_bc24_d4_eval.md
```

## Leaderboard Command

Run only after at least two variants have complete evaluation summary JSON files.

```bash
python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py \
  --result b1a_unet3d_dice_bce_bc16_d4=research_gsure/03_baselines/outputs/20260623_080158_b1a_unet3d_dice_bce_bc16_d4_eval_b1_eval_192x224x160/b1a_unet3d_dice_bce_bc16_d4_segmentation_metrics_summary.json \
  --result b1b_unet3d_dice_focal_bc16_d4=research_gsure/03_baselines/outputs/20260623_080158_b1b_unet3d_dice_focal_bc16_d4_eval_b1_eval_192x224x160/b1b_unet3d_dice_focal_bc16_d4_segmentation_metrics_summary.json \
  --result b1c_unet3d_dice_tversky_bc16_d4=research_gsure/03_baselines/outputs/20260623_080158_b1c_unet3d_dice_tversky_bc16_d4_eval_b1_eval_192x224x160/b1c_unet3d_dice_tversky_bc16_d4_segmentation_metrics_summary.json \
  --out-dir research_gsure/03_baselines/outputs/20260623_080158_b1_variant_leaderboard \
  --output-prefix b1_variant_leaderboard
```

## Stop Rule

Do not proceed to G-SURE reliability heads until the selected segmentation baseline has complete OOF predictions, no degenerate consortium, and documented failure cases suitable for reliability labels.
