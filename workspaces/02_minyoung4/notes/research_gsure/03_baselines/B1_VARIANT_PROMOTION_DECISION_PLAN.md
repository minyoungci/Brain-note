# B1 Variant Promotion Decision Plan

This is a planning artifact only. It does not approve GPU training, inference,
or metric reporting.

## Purpose

After two or more B1 variants have complete OOF segmentation evaluation
summaries and a variant leaderboard, decide whether a non-baseline variant should
replace B1A as the current best segmentation baseline.

## Current Gate

Blocked.

No real B1A smoke output, full-fit checkpoints, OOF prediction manifests,
segmentation metrics, or variant leaderboard exists yet.

## Decision Tool

```text
research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py
```

CPU-only. It consumes the JSON leaderboard produced by:

```text
research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py
```

## Promotion Rule

Promote a candidate only if all are true:

- candidate is eligible for selection,
- candidate has all four consortium rows,
- candidate improves worst-consortium mean Dice over B1A by at least `0.01`,
- candidate does not increase overall `Dice <= 0.8` failure rate by more than
  `0.02`.

If the baseline itself is not eligible, stop and analyze the baseline failure
instead of promoting any variant.

## Template Command

Replace `<TS_LEADERBOARD>` after a real leaderboard exists.

```bash
python research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py \
  --leaderboard-json research_gsure/03_baselines/outputs/<TS_LEADERBOARD>_b1_variant_leaderboard/b1_variant_leaderboard.json \
  --baseline b1a_unet3d_dice_bce_bc16_d4 \
  --min-worst-dice-gain 0.01 \
  --max-failure-rate-increase 0.02 \
  --min-consortia 4 \
  --output-md research_gsure/03_baselines/outputs/<TS_LEADERBOARD>_b1_variant_leaderboard/b1_variant_promotion_decision.md \
  --output-json research_gsure/03_baselines/outputs/<TS_LEADERBOARD>_b1_variant_leaderboard/b1_variant_promotion_decision.json
```

## Interpretation Rules

- `promote_variant`: candidate becomes current best B1 segmentation baseline,
  subject to manual review of per-consortium failures.
- `keep_baseline`: B1A remains current best; only run more variants if they test
  a different failure mode.
- `baseline_only`: not enough evidence to choose; continue planned variants only
  after B1A has full OOF metrics.
- `stop_and_analyze`: baseline is invalid or degenerate; do not run more
  hyperparameter variants.

## Guardrail

Do not promote a model based on pooled mean Dice alone.
