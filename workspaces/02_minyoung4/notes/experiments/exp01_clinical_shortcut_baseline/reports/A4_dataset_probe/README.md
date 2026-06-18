# A4 Dataset-Probe Draft Report

Run ID: `draft_cpu_loco_v3`

Status: diagnostic-only. Not an official model baseline.

## Result Summary

| Model | Diagnostic only | LOCO AUC mean | LOCO AUC min | AUPRC mean | MCC mean |
|---|---:|---:|---:|---:|---:|
| dataset_probe | true | 0.500000 | 0.500000 | 0.142036 | 0.000000 |
| age_sex_scanner_dataset_probe | true | 0.889788 | 0.820602 | 0.511625 | 0.500133 |

## Interpretation

Pure dataset identity is not meaningful as a LOCO predictor because the held-out dataset category
is unseen during training and is encoded as all zeros by the one-hot encoder. This diagnostic is
kept to make that behavior explicit.

The combined `age_sex_scanner_dataset_probe` result is diagnostic-only. It should not be used as
an official baseline because dataset identity can act as a label-prior shortcut in non-LOCO
settings.

## Source Outputs

- `experiments/exp01_clinical_shortcut_baseline/runs/A4_dataset_probe/draft_cpu_loco_v3/metrics_summary.csv`
- `experiments/exp01_clinical_shortcut_baseline/runs/A4_dataset_probe/draft_cpu_loco_v3/metrics_by_fold.csv`
- `experiments/exp01_clinical_shortcut_baseline/runs/A4_dataset_probe/draft_cpu_loco_v3/predictions.csv`

