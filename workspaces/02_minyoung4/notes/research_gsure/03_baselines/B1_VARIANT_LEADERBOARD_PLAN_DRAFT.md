# B1 Variant Leaderboard Plan

This is a planning artifact only. It does not approve GPU training, inference,
or metric reporting.

## Purpose

After B1 OOF segmentation evaluation exists for multiple variants, rank them
with a worst-consortium guard instead of choosing by pooled mean Dice alone.

## Required Inputs

Each variant must first produce a validated segmentation evaluation summary JSON
from:

```text
research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py
```

The summary must include:

- `overall`
- all four `dataset=...` consortium rows
- `selection_guard`

## Selection Rule

Rank eligible variants by:

1. higher worst-consortium mean Dice,
2. higher overall mean Dice,
3. lower overall `Dice <= 0.8` failure rate.

Do not select a variant that is missing a consortium row unless the comparison is
explicitly marked exploratory.

## Example Command

Replace timestamps and variant names with real evaluated outputs.

```bash
python research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py \
  --result unet3d_dice_bce=research_gsure/03_baselines/outputs/<TS_A>_b1_eval_192x224x160/b1_segmentation_metrics_summary.json \
  --result resunet3d_dice_bce=research_gsure/03_baselines/outputs/<TS_B>_b1_eval_192x224x160/b1_segmentation_metrics_summary.json \
  --result unet3d_dice_focal=research_gsure/03_baselines/outputs/<TS_C>_b1_eval_192x224x160/b1_segmentation_metrics_summary.json \
  --out-dir research_gsure/03_baselines/outputs/<TS_LEADERBOARD>_b1_variant_leaderboard \
  --output-prefix b1_variant_leaderboard
```

## Current Gate

Blocked. No smoke checkpoint, full-fit checkpoints, OOF prediction manifests, or
real segmentation evaluation summaries exist yet.

