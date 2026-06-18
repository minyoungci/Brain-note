# B0 Clinical-Only Shortcut Baseline

Status: implemented as CPU/draft baseline. No image preprocessing, split artifact finalization,
or GPU training is performed by this experiment.

## Why This Experiment Comes First

Prior IDH studies often add age, location, scanner-derived context, or clinical text to improve
performance. In our cohort, IDH mutant rate differs strongly by consortium, so an image model
can look strong by learning site/scanner/age priors.

This experiment identifies the shortcut floor and the main confounding risk. It should not be
used as a simple rule that later 3D MRI models only need to exceed. A 3D CNN can learn brain age
from whole-brain anatomy, so image-only AUC above this baseline does not by itself prove
IDH-specific tumor imaging signal.

## Updated Design Compared With Prior Work

- Uses leave-one-consortium-out evaluation from the start.
- Keeps dataset identity diagnostic-only, not part of the official clinical baseline.
- Reports calibration and threshold-independent metrics, not only AUC.
- Uses train-only threshold selection for the fixed-specificity operating point.
- Writes subject-level predictions for downstream error analysis.

## Key Finding From `draft_cpu_loco_v3`

Age alone is already highly predictive under LOCO:

- `age_only` mean AUC: `0.890952`
- `age_sex` mean AUC: `0.889770`
- `age_sex_scanner` mean AUC: `0.887845`

The age-bin label distribution explains why:

| age_bin | subjects | mutant | wildtype | mutant_pct |
|---|---:|---:|---:|---:|
| `lt_40` | 191 | 126 | 65 | 65.9686 |
| `40_59` | 491 | 92 | 399 | 18.7373 |
| `60_69` | 434 | 17 | 417 | 3.9171 |
| `70_plus` | 328 | 0 | 328 | 0.0000 |

Interpretation:

- The result is biologically plausible, not a code bug.
- It is also a severe confound for whole-brain image models.
- `age_sex_scanner` being slightly below `age_only` suggests scanner variables add little robust
  LOCO signal here and may act as site-overfit noise.

## Consequence for Image Experiments

Future image models must report more than pooled or LOCO AUC. Required analyses:

- incremental value over `B0_clinical_only`;
- age-stratified metrics, especially the `40_59` and `60_69` middle-age range;
- clinical-adjusted or age-residualized analysis;
- age-matched sensitivity analysis if sample size permits;
- explicit warning that image-only models may learn brain age rather than IDH-specific tumor signal.

## Stable IDs

- `B0_clinical_only`: age/sex/scanner clinical shortcut baseline.
- `A4_dataset_probe`: diagnostic dataset-identity probe only.

## Inputs

```text
docs/context/research_cohort_membership.csv
```

Required columns:

- `dataset`
- `subject_id`
- `leakage_group_id`
- `eligible_T1_structural_idh`
- `idh_subject`
- `any_subject_label_conflict_audit`
- `age_years_subject`
- `sex_subject`
- `scanner_vendor_bin`
- `field_strength_bin`

## Outputs

Default run outputs go under:

```text
experiments/exp01_clinical_shortcut_baseline/runs/<stable_id>/<run_id>/
```

Each run contains:

- `label_audit.csv`
- `fold_audit.csv`
- `metrics_by_fold.csv`
- `metrics_summary.csv`
- `predictions.csv`
- `run_metadata.json`

## Official-Use Rule

This CPU baseline can be used for development and shortcut diagnosis.
It is not a final paper result until exp00 protocol approval and code review are recorded.
