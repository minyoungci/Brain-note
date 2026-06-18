# exp01: Clinical Shortcut Baseline

Status: CPU draft implementation added. No image model, preprocessing, GPU job, or final
reported result has been created.

## Objective

Measure how much IDH prediction can be explained by non-image shortcuts such as age,
sex, scanner vendor, field strength, and consortium.

Image models must beat this baseline under leave-one-consortium-out evaluation.

## Prior-Work Motivation

Several prior works use age or clinical variables to improve IDH prediction.
In this dataset, IDH mutant rate differs strongly by consortium, so a clinical/site baseline
is required to detect shortcut-driven performance.

## Candidate Models

- Logistic regression.
- Ablations:
  - age only;
  - age + sex;
  - age + sex + scanner;
  - age + sex + scanner + consortium diagnostics only.

Implemented now:

- `age_only`
- `age_sex`
- `age_sex_scanner`
- `dataset_probe` diagnostic-only
- `age_sex_scanner_dataset_probe` diagnostic-only

## Inputs

- Subject-level table derived from `docs/context/research_cohort_membership.csv`.
- Labels from harmonized IDH fields.
- Covariates: age, sex, scanner vendor, field strength, dataset.

## Split Policy

- Subject-isolated.
- Leave-one-consortium-out.
- No held-out consortium used for hyperparameter selection.

## Metrics

- AUC, AUPRC, balanced accuracy, MCC.
- Sensitivity at fixed specificity.
- ECE and Brier score.
- Per-consortium confusion matrix.

## Expected Artifacts

- `configs/b0_clinical_only.json`
- `scripts/run_clinical_shortcut_baseline.py`
- `tests/test_clinical_shortcut_baseline.py`
- `runs/B0_clinical_only/` for run-local outputs only.
- `runs/A4_dataset_probe/` for diagnostic dataset-identity probe outputs only.
- `reports/B0_clinical_only/` for aggregate shortcut baseline tables.
- `reports/A4_dataset_probe/` for diagnostic dataset-identity probe tables.
- `reviews/B0_clinical_only_review.md` and `reviews/A4_dataset_probe_review.md`.

## Run Command

```bash
python experiments/exp01_clinical_shortcut_baseline/scripts/run_clinical_shortcut_baseline.py
```

This writes draft outputs to:

```text
experiments/exp01_clinical_shortcut_baseline/runs/B0_clinical_only/draft_cpu_loco_v2/
experiments/exp01_clinical_shortcut_baseline/runs/A4_dataset_probe/draft_cpu_loco_v2/
```

## Main Risk

The model may appear strong by learning age/site priors.
That is not a failure; it defines the shortcut floor that image models must exceed.
