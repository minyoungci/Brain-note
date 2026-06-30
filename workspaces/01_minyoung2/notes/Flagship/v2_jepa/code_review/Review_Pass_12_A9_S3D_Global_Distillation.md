# Review Pass 12: A9 S3D-Global Distillation

Date: 2026-06-30 UTC

## Rationale

A8 showed a clean failure mode:

```text
factorized bio/src heads
  -> excellent source-probe on z_bio
  -> downstream biological signal collapsed
```

So the next experiment should not only remove nuisance information. It must also force the source-robust representation to keep biologically useful global information.

A9 adds a fixed global teacher from the best validated previous foundation:

```text
teacher = ResEnc + S3D-dense + InfoNCE-global wg0.5
checkpoint = experiments/phase_b/resenc_s3d_wg0.5/latest.pt
teacher step = 150000
teacher global dim = 320
```

## Objective

A9 keeps the A2 confound-robust JEPA mainline and adds S3D global distillation:

```text
A2 mainline:
  source-balanced sampling
  + second-crop JEPA
  + foreground crop
  + random block target mask
  + MRI style augmentation
  + source adversary

A9 addition:
  + frozen S3D wg0.5 teacher global vector
  + BYOL-style cosine alignment from JEPA global vector to S3D global vector
```

The training loss is:

```text
L = L_JEPA
  + L_variance
  + L_source_adv
  + w_s3d * L_S3D_distill
```

Where:

```text
L_S3D_distill = 2 - 2 * cosine(predictor(z_jepa_context), stopgrad(z_s3d_teacher_raw_target))
```

The teacher sees the raw target crop, not the independently style-augmented target crop. This is intentional: the distillation target should preserve anatomy/phenotype signal without teaching the student scanner-style noise.

## Implementation Review

Implemented in:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
```

New components:

- `GlobalDistillPredictor`: maps JEPA global vectors into the external teacher global space.
- `load_s3d_teacher`: loads and freezes the validated S3D+InfoNCE checkpoint.
- CLI options:
  - `--s3d_distill_weight`
  - `--s3d_distill_hidden`
  - `--s3d_distill_warmup`
  - `--s3d_distill_space shared|bio`
  - `--s3d_distill_target raw_target|styled_target`
  - `--s3d_distill_ckpt`

Checkpoint state now stores:

```text
s3d_distill
```

The frozen S3D teacher is not saved into the checkpoint.

## Validation

Static/code tests:

```text
python -m py_compile Flagship/v2_jepa/code/train_brain_jepa.py Flagship/v2_jepa/code/tests/test_brain_jepa.py
python -m unittest discover -s Flagship/v2_jepa/code/tests -p 'test_*.py'
```

Result:

```text
16 tests OK
```

GPU smoke:

```text
Flagship/v2_jepa/runs/smoke_a9_s3d_distill_gpu0
```

Smoke status:

| Field | Value |
|---|---:|
| step | 8 |
| S3D teacher step | 150000 |
| S3D teacher dim | 320 |
| `s3d_distill_loss` | 1.6148 |
| `s3d_distill_weight` | 0.05 |
| pred std | 0.0496 |
| pred rank | 59.68 |
| DONE | true |

## Launched Pilots

| GPU | PID | Run | Distill weight | Seed | Status |
|---|---:|---|---:|---:|---|
| 0 | 118223 | `pilot_a9_s3ddistill005_a2main_anat_seed3900_gpu0_20260630` | 0.05 | 3900 | DONE, no ERROR |
| 1 | 118332 | `pilot_a9_s3ddistill010_a2main_anat_seed3901_gpu1_20260630` | 0.10 | 3901 | DONE, no ERROR |

Initial health at ~step 1221:

| Run | Loss | JEPA | S3D distill | Source loss | Pred std | Pred rank | ERROR |
|---|---:|---:|---:|---:|---:|---:|---|
| A9 `w=0.05` | 3.6005 | 0.0088 | 0.6621 | 3.5586 | 0.1464 | 124.14 | false |
| A9 `w=0.10` | 3.6670 | 0.0033 | 0.8739 | 3.5763 | 0.1597 | 119.62 | false |

Final training health at step 20000:

| Run | Loss | S3D distill | Pred rank | DONE | ERROR |
|---|---:|---:|---:|---|---|
| A9 `w=0.05` | 3.6911 | 0.6935 | 174.08 | true | false |
| A9 `w=0.10` | 3.7098 | 0.5673 | 151.47 | true | false |

## Evaluation Results

| Model | Source-probe | Task1 AUROC | Task3 brain-age Pearson | Task5 AUROC |
|---|---:|---:|---:|---:|
| A2 mainline | 0.0846 mean | 0.6731 | 0.6720 | 0.8681 |
| A5 global-align `w=0.10` | 0.2574 | 0.8077 | 0.6996 | 0.8715 |
| A8 factorized `bio`, orth `0.05` | 0.0815 | 0.5481 | -0.0014 | 0.5868 |
| A9 S3D distill `w=0.05` | 0.2519 | 0.3750 | 0.7200 | 0.8229 |
| A9 S3D distill `w=0.10` | 0.1852 | 0.4135 | 0.4556 | 0.7413 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 |

## Findings

1. A9 `w=0.05` proves that explicit global biology preservation can work.

   Brain-age Pearson rose to `0.7200`, above A2 and A5. This directly answers the A8 failure: the JEPA branch can retain biological/global signal if a positive target forces it to.

2. A9 does not solve the full foundation trade-off.

   Source-probe rose to `0.2519` for `w=0.05` and `0.1852` for `w=0.10`, both above the source gate. Task1 also dropped sharply. The full S3D global vector transfers useful signal and nuisance/source signal together.

3. Stronger distillation was worse, not better.

   `w=0.10` lowered source-probe relative to `w=0.05`, but it also damaged brain-age and Task5. This suggests the interaction is not a simple monotonic weight trade-off.

4. A9 should not be promoted as-is.

   It is an informative ablation, not a candidate foundation checkpoint.

## Success Gate

A9 is useful only if it improves the A2/A5 trade-off:

| Gate | Required direction | A9 verdict |
|---|---|---|
| Source-probe | stay close to A2, ideally `<= 0.12`, acceptable `<= 0.17` | fail |
| Task1 infarct | recover toward A5/S3D, target `>= 0.67` | fail |
| Task3 brain age | exceed A2 `0.672`, target `>= 0.70` | pass for `w=0.05` |
| Task5 polymicrogyria | stay near A2/A5, target `>= 0.86` | fail |

Reference:

| Model | Source-probe | Task1 | Task3 | Task5 |
|---|---:|---:|---:|---:|
| A2 mainline | 0.0846 mean | 0.6731 | 0.6720 | 0.8681 |
| A5 global-align `w=0.10` | 0.2574 | 0.8077 | 0.6996 | 0.8715 |
| A8 factorized `bio` `w=0.05` | 0.0815 | 0.5481 | -0.0014 | 0.5868 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 |

## Decision

Reject A9 as implemented.

Next branch should not distill the unfiltered S3D global vector. It should either:

- distill from a source-filtered teacher projection, or
- preserve biology through dense/local anatomical targets, such as S3D-style reconstruction, tissue/ROI/atlas context prediction, or masked local feature reconstruction.
