# ROI→3D Image Distillation v0 Latest Smoke

Updated: 2026-05-21

## Implemented

Script:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/run_roi_to_image_distill_v0.py
```

Planning source:

```text
/home/vlm/minyoungi/notes/context/ROI_TO_IMAGE_DISTILLATION_V0_PLAN.md
```

## Passed checks

### Schema-only

Run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_v0_20260521T102421Z
```

Result:

```text
full joined rows by split/label:
internal_test AD=204 CN=900 MCI=576
train         AD=950 CN=4200 MCI=2688
val           AD=204 CN=900 MCI=577

sample counts:
train 8/class, val 4/class, internal_test 4/class
n_roi=16
z_target_nan_count=0
status_target_nan_count=0
```

### CPU mini smoke

Run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_v0_20260521T102436Z
```

Config:

```text
device=cpu
downsample=16x20x16
train=2/class
val=1/class
internal_test=1/class
epochs=1
```

Internal-test smoke metrics:

```text
roi_z_mae=0.7258
roi_z_rmse=0.9026
roi_status_accuracy=0.1875
roi_status_macro_f1=0.1429
```

Interpretation: dataloader, image loading, ROI z/status target tensors, forward/backward, metrics, artifact writing all work.

### GPU mini smoke

Run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_v0_20260521T102511Z
```

Config:

```text
device=cuda:0
downsample=32x40x32
train=8/class
val=4/class
internal_test=4/class
batch_size=4
epochs=1
```

Internal-test smoke metrics:

```text
roi_z_mae=0.7927
roi_z_rmse=1.0300
roi_status_accuracy=0.4635
roi_status_macro_f1=0.3458
```

Interpretation: small GPU run completes. These metrics are schema/smoke only, not performance claims.

## Current status

ROI→image distillation v0 implementation is ready for the next controlled training smoke.

Recommended next run:

```text
cuda:0
train=80/class
val=40/class or 80/class
internal_test=40/class or 80/class
downsample=48x56x48 or 64x80x64 if memory stays safe
epochs=5
```

Before treating it as a representation baseline, add frozen embedding extraction + linear probe script.
