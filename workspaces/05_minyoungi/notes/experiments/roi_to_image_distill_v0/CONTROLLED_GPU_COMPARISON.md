# ROI→Image Distillation v0 Controlled GPU Comparison

Run: `/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_v0_20260521T102941Z`

## Setup

```text
Distillation loss: ROI z MSE + 0.25 * ROI status CE
Diagnosis labels: not used in distillation, only frozen linear probe
Device: cuda:0
Downsample: 48x56x48
Train/val/internal_test: 80/class each
Epochs: 5
```

## ROI teacher imitation

Training loss decreased through epoch 5, but eval-mode final ROI metrics worsened after epoch 5. Best observed validation ROI metrics occurred at epoch 4:

```text
val roi_z_mae epoch4 = 0.7287
val roi_z_rmse epoch4 = 0.9575
val roi_status_accuracy epoch4 = 0.6669
val roi_status_macro_f1 epoch4 = 0.3298
```

Caution: final eval after epoch 5 degraded, likely due small-run instability / BatchNorm running-stat sensitivity / overfit. Treat this as controlled smoke, not finalized baseline.

## Frozen embedding diagnosis probe: internal_test

```text
balanced_accuracy = 0.4458
macro_f1          = 0.4432
CN recall         = 0.4000
MCI recall        = 0.3625
AD recall         = 0.5750
confusion         = [[32, 29, 19], [28, 29, 23], [17, 17, 46]]
```

## Image-only tiny CNN seed-repeat baseline

Mean across 3 seeds:

```text
balanced_accuracy = 0.4028
macro_f1          = 0.3429
CN recall         = 0.0750
MCI recall        = 0.6542
AD recall         = 0.4792
min pred_CN count = 0
mean pred_MCI rate= 0.6069
```

## Improvement check

Compared with image-only tiny CNN seed mean:

```text
balanced_accuracy: 0.4028 -> 0.4458  Δ=+0.0431
macro_f1:          0.3429 -> 0.4432  Δ=+0.1002
CN recall:         0.0750 -> 0.4000  Δ=+0.3250
MCI recall:        0.6542 -> 0.3625  Δ=-0.2917
AD recall:         0.4792 -> 0.5750  Δ=+0.0958
```

## Interpretation

ROI-distilled frozen embedding improved balanced accuracy and macro F1 over the tiny image-only CNN mean, and it restored non-zero CN prediction/recall. However MCI recall dropped versus the MCI-biased image-only CNN. This is a better-balanced representation probe, not a solved classifier.

Main result:

```text
ROI distillation appears to reduce the previous MCI-collapse/CN-boundary failure.
The representation is still weak and unstable; MCI remains hard.
```

## Next recommended fix

1. Add validation-checkpoint selection instead of always using the last epoch.
2. Replace BatchNorm3d or evaluate GroupNorm/InstanceNorm for small balanced batches.
3. Run 3 seeds with the same 80/class setup after checkpoint selection is fixed.
4. Then test 64x80x64 if runtime/memory acceptable.
