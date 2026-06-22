# exp01 Method and Ablation Report

## Locked Task

- Task: 4-channel structural MRI whole-tumor segmentation.
- Evaluation: leave-one-consortium-out (LOCO), subject-level held-out Dice.
- Unit: subject.
- Cohort size: 1617 subjects in completed exp01 predictions.
- Primary baseline: compact 3D U-Net with Dice+BCE.
- Current best artifact: `resunet_ds_tta_distill_ensemble_tta_all_v1`.

## Main Finding

The strongest completed artifact is a fixed 50:50 probability ensemble of ResUNet-DS and TTA-distilled ResUNet-DS, both evaluated with all-flip TTA.

| metric | value |
| --- | --- |
| mean Dice | 0.892775 |
| mean Dice CI95 | [0.886227, 0.898931] |
| median Dice | 0.935683 |
| Dice <= 0.8 rate | 0.100186 |
| delta vs standard | 0.008498 |
| delta vs standard CI95 | [0.005960, 0.011038] |
| delta low-Dice <=0.8 vs standard | -0.017934 |

## Ablation Summary

| comparison | baseline Dice | candidate Dice | delta Dice | CI95 | delta low<=0.8 | verdict |
| --- | --- | --- | --- | --- | --- | --- |
| ResUNet-DS vs standard | 0.884277 | 0.887385 | 0.003108 | [0.000509, 0.005785] | -0.003711 | positive architecture |
| ResUNet-DS TTA vs standard | 0.884277 | 0.889639 | 0.005362 | [0.002599, 0.007976] | -0.006184 | positive inference |
| Naive ResUNet flip consistency vs ResUNet-DS | 0.887385 | 0.883842 | -0.003543 | [-0.005933, -0.001208] | 0.000000 | no-go |
| TTA-distill training vs ResUNet-DS | 0.887385 | 0.885826 | -0.001559 | [-0.003975, 0.000881] | -0.004947 | no-go overall |
| Two-model ensemble-TTA vs standard | 0.884277 | 0.892775 | 0.008498 | [0.005960, 0.011038] | -0.017934 | current best |
| Ensemble student single-pass vs standard | 0.884277 | 0.885765 | 0.001488 | [-0.001390, 0.004324] | -0.002474 | no-go compression |
| Ensemble student TTA vs standard | 0.884277 | 0.892077 | 0.007800 | [0.005067, 0.010471] | -0.012369 | strong 1-model TTA |
| Validation-weighted ensemble vs two-model ensemble | 0.892775 | 0.891906 | -0.000869 | [-0.001551, -0.000396] | 0.001237 | no-go routing |
| Confidence-distill single-pass vs ResUNet-DS | 0.887385 | 0.887774 | 0.000389 | [-0.001428, 0.002163] | 0.000000 | no-go compression |
| Confidence-distill TTA vs ResUNet-DS TTA | 0.889639 | 0.890254 | 0.000616 | [-0.000852, 0.002120] | -0.006803 | neutral |
| Three-model ensemble vs two-model ensemble | 0.892775 | 0.892344 | -0.000431 | [-0.000940, 0.000089] | -0.001855 | no new best |

## Best Artifact Fold Deltas vs Standard

| fold | n | standard Dice | best Dice | delta Dice | delta low<=0.8 |
| --- | --- | --- | --- | --- | --- |
| MU-Glioma-Post | 203 | 0.843889 | 0.865013 | 0.021124 | -0.034483 |
| UCSD-PTGBM | 178 | 0.788069 | 0.816679 | 0.028610 | -0.084270 |
| UPENN-GBM | 611 | 0.923344 | 0.927747 | 0.004404 | -0.008183 |
| UTSW | 625 | 0.886603 | 0.889275 | 0.002672 | -0.003200 |

## Best Artifact Size-Bin Performance

| target size bin | n | mean Dice | median Dice | q10 | q90 |
| --- | --- | --- | --- | --- | --- |
| 0-100 | 11 | 0.060952 | 0.005676 | 0.000000 | 0.123537 |
| 101-500 | 29 | 0.536635 | 0.682616 | 0.010726 | 0.881251 |
| 501-1k | 78 | 0.750795 | 0.812198 | 0.467192 | 0.931867 |
| 1k-2.5k | 247 | 0.847683 | 0.892700 | 0.705968 | 0.944585 |
| 2.5k-5k | 414 | 0.900219 | 0.926211 | 0.819983 | 0.960619 |
| 5k-10k | 485 | 0.933648 | 0.946786 | 0.889859 | 0.969524 |
| >10k | 353 | 0.945991 | 0.955265 | 0.915280 | 0.971409 |

## No-Go Decisions

- Loss weighting/source balancing alone degraded mean Dice.
- Naive train-time flip consistency did not transfer TTA gains and hurt ResUNet-DS.
- TTA self-distillation helped harder MU/UCSD folds but was not an overall winner.
- Simple ensemble-to-student MSE distillation failed as a single-pass compression method.
- Confidence-weighted BCE+Dice distillation remained neutral versus ResUNet-DS.
- Validation-selected ensemble weighting did not beat the fixed 50:50 average.
- Adding confidence-distill as a third ensemble member did not beat the two-model ensemble.

## Defensible Claim

A conservative claim is not that we solved single-pass compression. The defensible claim is that TTA-distilled training creates a complementary model whose errors combine constructively with a stronger ResUNet-DS backbone under cross-consortium evaluation. The method contribution should be framed as a complementary TTA-distilled ensemble and robustness analysis, not as a standalone distillation success.

## Residual Risks

- The current best uses extra inference compute: two models times all-flip TTA.
- Single-pass novelty remains weak because compression attempts did not preserve the ensemble gain.
- UCSD remains the hardest fold; several methods trade UCSD gains for MU/UPENN/UTSW losses.
- A paper should avoid claiming validation routing or confidence-distill as the final method.

## Recommended Next Action

Lock `resunet_ds_tta_distill_ensemble_tta_all_v1` as the current performance artifact. If more experimentation is justified, it should target UCSD/domain-shift diagnostics or uncertainty-aware deployment analysis rather than another generic consistency or distillation loss.

## Sanity Checks Used By This Report

- Best-vs-standard n: 1617
- ResUNet-DS TTA delta over ResUNet-DS: 0.002253 from `resunet_ds_vs_resunet_ds_tta_all_v1`.
- Three-model ensemble did not improve the best: delta -0.000431, CI95 [-0.000940, 0.000089].
