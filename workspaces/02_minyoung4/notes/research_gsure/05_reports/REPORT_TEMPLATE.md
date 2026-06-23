# G-SURE Report Template

## Executive Summary

- Official cohort:
- Split policy:
- OOF prediction manifest:
- Reliability label manifest:
- Metric contract:
- Metric implementation:
- Best segmentation baseline:
- Best reliability method:
- Main conclusion:

## Cohort

| dataset | subjects | units | usable masks | exclusions |
| --- | ---: | ---: | ---: | --- |

## Segmentation Performance

| method | mean Dice | Dice CI | low-Dice <=0.8 | MU | UCSD | UPENN | UTSW |
| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: |

## Reliability / Grounding Performance

| method | ERR AUROC | ERR AUPRC | FP AUPRC | FN AUPRC | subject failure AUROC | top-1% ERR capture | calibration ECE |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |

## QU-BraTS-Style Filtering

| method | Dice-filter AUC | filtered-TP penalty | filtered-TN penalty | interpretation |
| --- | ---: | ---: | ---: | --- |

## Prediction / Label Provenance

- Prediction contract:
- Full-volume assembly policy:
- Prediction manifest validation:
- Prediction artifact validation:
- Threshold policy:
- Error label definitions:
- Boundary label policy:
- Metric contract:
- Metric command:
- Label generation command:
- Label validation command:
- Excluded prediction rows:
- Leakage checks:

## Ablations

| ablation | Dice delta | grounding delta | conclusion |
| --- | ---: | ---: | --- |

## Failure Analysis

- Hard folds:
- Hard lesion-size bins:
- Common FP patterns:
- Common FN patterns:
- Scanner/source-specific failure modes:

## No-Go / Go Decision

- Continue:
- Pivot:
- Required next validation:
