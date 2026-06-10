# image_only_smoke_v0 latest completed run

Updated: 2026-05-21

Latest completed run:

```text
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z
```

## Configuration

```text
workspace: /home/vlm/minyoungi only
input: T1w preprocessed image + brain mask for non-brain zeroing
excluded inputs: captions, ROI scalar features, CDR, biomarkers, cohort/site/scanner, PET-derived fields
split: subject_disjoint_split_v0
sample: train 240/class, val 80/class, internal_test 80/class
model: tiny 3D CNN
downsample_shape: (32, 40, 32)
device: cuda:7
epochs: 8
elapsed_seconds: 1279.064
```

## Final metrics

```text
train:         balanced_accuracy=0.5097, macro_f1=0.5085, accuracy=0.5097
val:           balanced_accuracy=0.4208, macro_f1=0.4132, accuracy=0.4208
internal_test: balanced_accuracy=0.3875, macro_f1=0.3743, accuracy=0.3875
```

Internal-test confusion matrix, rows=true cols=pred, labels=`CN, MCI, AD`:

```text
[[18, 58, 4], [19, 52, 9], [3, 54, 23]]
```

## Interpretation

This is the latest scaled image-only smoke run. It remains a small controlled baseline, not final VLM evidence. Compare against the earlier 80/class smoke and ROI-feature-only probe.

## Artifacts

```text
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/REPORT.md
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/metrics.json
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/predictions.csv
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/sampled_rows.csv
/home/vlm/minyoungi/experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/model.pt
```
