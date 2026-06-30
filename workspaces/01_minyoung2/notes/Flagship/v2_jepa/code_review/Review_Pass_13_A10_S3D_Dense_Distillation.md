# Review Pass 13: A10 S3D Dense/Local Distillation

Date: 2026-06-30 UTC

## Rationale

A9 showed that a positive biology-preserving target is useful, but unfiltered S3D global distillation copies nuisance/source information:

```text
A9 w=0.05:
  brain-age Pearson = 0.7200  # recovered biological/global signal
  source-probe      = 0.2519  # source shortcut returned
  Task1 AUROC       = 0.3750  # failed
```

A10 therefore moves the teacher signal from the global vector to the dense/local bottleneck feature map. The hypothesis is that local anatomical feature matching should preserve biology with less direct global source/cohort shortcut transfer.

## Objective

A10 keeps the A2 robust JEPA mainline:

```text
source-balanced sampling
+ second-crop JEPA
+ foreground crop
+ random block target mask
+ MRI style augmentation
+ source adversary
```

And adds masked dense feature distillation:

```text
teacher = frozen S3D+InfoNCE wg0.5
student = JEPA predictor output on masked target locations

L_S3D_dense = masked cosine distance(
    student predicted target latent map,
    stopgrad(S3D teacher bottleneck map on raw target crop)
)
```

Total loss:

```text
L = L_JEPA
  + L_variance
  + L_source_adv
  + w_dense * L_S3D_dense
```

## Implementation Review

Implemented in:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
```

New function:

```text
dense_feature_distill_loss(student, teacher, mask)
```

Design constraints:

- Compares 3D feature maps channel-wise at each spatial location.
- Uses cosine distance, avoiding scale matching issues.
- Uses the downsampled JEPA target mask by default, so only masked prediction targets contribute.
- Uses the raw target crop for the S3D teacher, avoiding scanner-style augmentation as a teacher signal.
- Does not add a trainable dense adapter for the first pilot; the default target-stage channel count is already 320, matching S3D bottleneck channels.

New CLI:

```text
--s3d_dense_distill_weight
--s3d_dense_distill_warmup
--s3d_dense_distill_target raw_target|styled_target
--s3d_dense_distill_masked_only
```

## Validation

Static/unit checks:

```text
python -m py_compile Flagship/v2_jepa/code/train_brain_jepa.py Flagship/v2_jepa/code/tests/test_brain_jepa.py
python -m unittest discover -s Flagship/v2_jepa/code/tests -p 'test_*.py'
```

Result:

```text
17 tests OK
```

GPU smoke:

```text
Flagship/v2_jepa/runs/smoke_a10_s3d_dense_gpu0
```

Smoke status:

| Field | Value |
|---|---:|
| step | 8 |
| S3D teacher step | 150000 |
| S3D teacher dim | 320 |
| `s3d_dense_distill_loss` | 1.9280 |
| `s3d_dense_distill_weight` | 0.05 |
| pred rank | 59.69 |
| DONE | true |

## Launched Pilots

| GPU | PID | Run | Dense weight | Seed | Status |
|---|---:|---|---:|---:|---|
| 0 | 1817801 | `pilot_a10_s3ddense002_a2main_anat_seed4000_gpu0_20260630` | 0.02 | 4000 | DONE, no ERROR |
| 1 | 1817803 | `pilot_a10_s3ddense005_a2main_anat_seed4001_gpu1_20260630` | 0.05 | 4001 | DONE, no ERROR |

Initial health around step 1200:

| Run | Step | Dense loss | Pred rank | ckpt1000 | ERROR |
|---|---:|---:|---:|---|---|
| A10 `w=0.02` | 1181 | 1.5634 | 105.99 | true | false |
| A10 `w=0.05` | 1201 | 1.5096 | 129.85 | true | false |

Final training health at step 20000:

| Run | Loss | Dense loss | Pred rank | DONE | ERROR |
|---|---:|---:|---:|---|---|
| A10 `w=0.02` | 3.8543 | 1.4349 | 147.13 | true | false |
| A10 `w=0.05` | 3.7443 | 1.5870 | 172.79 | true | false |

## Evaluation Results

| Model | Source-probe | Task1 AUROC | Task3 brain-age Pearson | Task5 AUROC |
|---|---:|---:|---:|---:|
| A2 mainline | 0.0846 mean | 0.6731 | 0.6720 | 0.8681 |
| A9 global S3D distill `w=0.05` | 0.2519 | 0.3750 | 0.7200 | 0.8229 |
| A10 dense S3D distill `w=0.02` | 0.0704 | 0.2981 | 0.4558 | 0.6059 |
| A10 dense S3D distill `w=0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 |

## Findings

1. A10 `w=0.05` is the best JEPA trade-off so far for source robustness plus Task1/Task5.

   It reaches source-probe `0.0778`, Task1 `0.8077`, and Task5 `0.8976`. This is the first branch that improves source robustness over A2 while matching or exceeding the best global-task classification probes.

2. Dense/local S3D distillation does not copy the global source shortcut.

   A9 global distillation raised source-probe to `0.2519`; A10 dense distillation reduced it to `0.0778`. This supports the hypothesis that biology preservation should be local/dense rather than unfiltered global.

3. Brain-age remains the missing axis.

   A10 `w=0.05` brain-age Pearson is `0.6085`, below A2 `0.6720` and A9 `0.7200`. The next branch should keep A10 dense `w=0.05` and add a small global-signal correction, while guarding source-probe.

4. A10 `w=0.02` is rejected.

   It has excellent source-probe, but Task1/Task3/Task5 all fail. The useful dense target strength is closer to `0.05`.

## Success Gate

A10 is promoted only if it improves the A2/A9 trade-off:

| Gate | Target |
|---|---|
| Source-probe | ideally near A2 (`~0.085`), acceptable `<= 0.17` |
| Task1 infarct | at least A2-like, target `>= 0.67` |
| Task3 brain age | improve over A2 `0.672`, target `>= 0.70` |
| Task5 polymicrogyria | stay near A2, target `>= 0.86` |

Reference:

| Model | Source-probe | Task1 | Task3 | Task5 |
|---|---:|---:|---:|---:|
| A2 mainline | 0.0846 mean | 0.6731 | 0.6720 | 0.8681 |
| A9 global S3D distill `w=0.05` | 0.2519 | 0.3750 | 0.7200 | 0.8229 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 |

## Evaluation Plan

A10 `w=0.05` is not a complete replacement because brain-age is still low, but it is the current best JEPA candidate. The next experiment should start from:

```text
A10 dense S3D distill w=0.05
+ weak global signal correction
+ source-probe gate must remain <= 0.17
```
