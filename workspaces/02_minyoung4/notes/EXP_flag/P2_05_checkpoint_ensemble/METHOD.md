# P2.05 Validation-Calibrated Checkpoint Ensemble

## Purpose

P2.04 showed that scalar loss rebalancing did not generalize: mean Dice dropped and UTSW/small-lesion performance worsened. P2.05 is a low-cost exploratory probe before another long training run.

The hypothesis is that P2.02 and P2.03 learned complementary behavior:

- P2.02: stronger mean Dice and precision
- P2.03: better catastrophic-tail reduction and recall

P2.05 averages checkpoint probabilities from P2.02 and P2.03, optionally with simple flip TTA, then selects a threshold on the validation split only. Test labels are used only once for the final report.

## Status

This is exploratory because the decision to try an ensemble was made after observing P2.03/P2.04 results. If positive, it should motivate a clean confirmatory rerun or a proper method such as uncertainty-aware tail correction, objective distillation, or validation-calibrated ensemble distillation.

## Result

Run: `reports/p202_p203_tta_single_v1/`

Comparison vs P2.02: `reports/compare_vs_p202_p202_p203_tta_single_v1/`

- mean Dice: 0.845830 -> 0.847901
- paired delta Dice: +0.002071, CI95 [+0.000767, +0.003392]
- Dice <=0.8 rate delta: -0.008065, CI95 [-0.014888, -0.001241]
- Dice <=0.5 rate delta: -0.002481, CI95 [-0.006824, +0.001241]

Fold behavior:

- UTSW improved clearly: +0.006870 Dice, CI95 [+0.004977, +0.009137]
- UPENN improved low-Dice <=0.8 count/rate
- UCSD still degraded: -0.007023 Dice, CI95 [-0.015298, +0.000156]
- MU was essentially neutral

Interpretation: the ensemble is the first run with a statistically positive mean-Dice improvement over P2.02, but the novelty is not enough as a final conference method. Treat it as evidence that P2.02/P2.03 complementary errors exist. The next method should distill this complementarity into a single model or add uncertainty/tail-aware correction, while explicitly addressing UCSD transfer.

## Contract

- Same valid-seg cohort and LOCO split as P2.02/P2.03
- Same compact 3D U-Net checkpoint architecture
- Inputs: four structural MRI channels
- Models: P2.02 baseline checkpoint + P2.03 tail checkpoint per held-out fold
- Probability fusion: arithmetic mean of sigmoid probability maps
- Threshold: validation-only grid
- Evaluation: paired subject-level comparison vs P2.02

No training or raw data mutation is performed.
