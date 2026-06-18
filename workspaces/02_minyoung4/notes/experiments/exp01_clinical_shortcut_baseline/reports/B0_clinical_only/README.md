# B0 Clinical-Only Draft Report

Run ID: `draft_cpu_loco_v3`

Status: draft CPU baseline. Not a final paper result.

## Result Summary

The clinical-only shortcut baseline is already strong under leave-one-consortium-out evaluation.

| Model | LOCO AUC mean | LOCO AUC min | AUPRC mean | Balanced accuracy mean | MCC mean | Brier mean | ECE mean |
|---|---:|---:|---:|---:|---:|---:|---:|
| age_only | 0.890952 | 0.820216 | 0.508610 | 0.813413 | 0.467960 | 0.135887 | 0.198652 |
| age_sex | 0.889770 | 0.820602 | 0.504028 | 0.812306 | 0.463722 | 0.136200 | 0.198059 |
| age_sex_scanner | 0.887845 | 0.820602 | 0.497853 | 0.818635 | 0.484546 | 0.129018 | 0.177650 |

## Interpretation

Age alone is a very strong shortcut for IDH in this cohort. Later image-based experiments must
not be judged only by whether they exceed this AUC under the same LOCO protocol. A whole-brain
3D CNN can learn brain age from anatomy, so image-only performance above `0.89` can still be
brain-age confounding rather than IDH-specific tumor signal.

The official clinical baseline should remain `age_sex_scanner` only if scanner variables are
approved for the intended claim. Otherwise, `age_only` and `age_sex` should be treated as the
cleaner shortcut floor, and scanner/site variables should remain diagnostic/reporting axes.

## Age Confounding Finding

| age_bin | subjects | mutant | wildtype | mutant_pct |
|---|---:|---:|---:|---:|
| `lt_40` | 191 | 126 | 65 | 65.9686 |
| `40_59` | 491 | 92 | 399 | 18.7373 |
| `60_69` | 434 | 17 | 417 | 3.9171 |
| `70_plus` | 328 | 0 | 328 | 0.0000 |

This means the next image experiment must test incremental imaging value within or beyond age,
not just absolute AUC. The most important target range is likely `40_59` and `60_69`, where age
does not trivially determine all labels but positives still exist.

## Reporting Caveats

- Run cohort is 1,444 subjects, not 1,457, because 13 subjects with label-conflict audit flags
  are excluded by the conservative label policy.
- LOCO summary is an unweighted fold mean; UCSD and UPENN have few mutant cases, so calibration
  and AUPRC are noisy.
- Bootstrap confidence intervals are not yet implemented.
- Age definition across datasets still needs raw-source verification before final reporting.
- LOCO group-overlap checks are necessary but not sufficient: because `leakage_group_id` includes
  dataset prefix, dataset-heldout splits structurally avoid group overlap.

## Revised Success Criterion for Image Models

Do not use:

```text
image_model_auc > age_only_auc
```

as the main success criterion.

Use:

```text
image + clinical > clinical alone
```

plus age-stratified, age-residualized, and age-matched sensitivity analyses where feasible.

## Age-Stratified Diagnostic From Saved Predictions

Read-only follow-up check of `age_only` predictions shows the pooled AUC is largely driven by
cross-age separation:

| age_bin | age_only within-bin AUC | interpretation |
|---|---:|---|
| `lt_40` | approx. 0.573 | weak within-bin discrimination |
| `40_59` | approx. 0.747 | primary age-stratified target for image incremental value |
| `60_69` | approx. 0.457 | exploratory only; only 17 mutants |
| `70_plus` | undefined | 0 mutants; use as specificity/calibration stratum, not AUC |

Therefore, exp02 should not use pooled AUC as the sole success criterion.

## Source Outputs

- `experiments/exp01_clinical_shortcut_baseline/runs/B0_clinical_only/draft_cpu_loco_v3/metrics_summary.csv`
- `experiments/exp01_clinical_shortcut_baseline/runs/B0_clinical_only/draft_cpu_loco_v3/metrics_by_fold.csv`
- `experiments/exp01_clinical_shortcut_baseline/runs/B0_clinical_only/draft_cpu_loco_v3/predictions.csv`
