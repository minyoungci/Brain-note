# Experiment Matrix

## RQ1: Does S3D-style anti-leakage dense pretraining help segmentation transfer?

| Experiment | Compare | Required Output |
|---|---|---|
| S3D vs skip-free MAE | Dice/NSD on seg tasks | mean, CI, delta over scratch |
| S3D vs dense-only | local transfer | segmentation + cls/reg trade-off |
| leakage sanity | recon difference masked vs visible | prove no skip leakage |

Source paths:

- `experiments/phase_b/s3d_final/`
- `experiments/phase_b/resenc_s3d_full/pipeline_explanation_ko.md`

## RQ2: What is the best dense-global balance?

| Variant | Role |
|---|---|
| pure / wg0 | dense-only |
| wg0.5 | proposed balance |
| full / wg1 | global-heavy |

Metrics:

- Task1 AUROC
- Task3 Pearson/MAE
- Task4 Dice/NSD
- Task5 AUROC
- Task6 linear probe
- Task2 diagnostic result

Current summary:

```text
wg0.5 is currently the selected checkpoint because it avoids collapse on global tasks
while retaining positive segmentation transfer.
```

## RQ3: Does fine-tuning protocol determine few-shot segmentation success?

| Protocol | Encoder | Decoder | Status |
|---|---|---|---|
| full-FT transfer decoder | train | train | already used in seg_v2/v3 |
| frozen encoder + transferred decoder | frozen | train | missing, high priority |
| frozen encoder + fresh decoder | frozen | train | missing |
| very-low-LR encoder + transferred decoder | very low LR | train | missing |
| scratch matched | random | train | required control |

## RQ4: Does the model generalize to independent consortium data?

Required design:

- no subject/site overlap with foundation pretraining
- label-efficient splits
- site-held-out validation if possible
- task-specific metrics with bootstrap CI

## RQ5: Which failures are systematic?

Required outputs:

- per-case predictions
- lesion volume and Dice correlation
- modality availability
- scanner/site subgroup
- qualitative figures for false negatives and false positives
