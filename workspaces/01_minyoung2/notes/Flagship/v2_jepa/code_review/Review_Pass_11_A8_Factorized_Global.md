# Review Pass 11: A8 Factorized Global JEPA

Date: 2026-06-30 UTC

## Scope

A8 tested whether source robustness and downstream biological signal can be separated by factorizing the global representation:

```text
shared JEPA context global
  -> z_bio: biological/global projection
  -> z_src: source/nuisance projection

loss = latent JEPA
     + BYOL-style global alignment on z_bio
     + source adversary on z_src
     + orthogonality(z_bio, z_src)
```

Two branches were trained:

| Run | Orth weight | Status |
|---|---:|---|
| `pilot_a8_factor_bioalign_srcadv_orth005_b8_seed3800_gpu0_20260630` | 0.05 | DONE, no ERROR |
| `pilot_a8_factor_bioalign_srcadv_orth010_b8_seed3801_gpu1_20260630` | 0.10 | DONE, no ERROR |

## Implementation Review

The implementation passed the required smoke checks before the pilot:

- `py_compile` passed for the training and evaluation scripts.
- Unit tests passed: 15 tests.
- GPU smoke training wrote factorized metrics and checkpoints.
- Source-probe smoke loaded `factor_heads` and evaluated `feature_space=bio`.
- Downstream smoke loaded `factor_heads` and evaluated `feature_space=bio`.

Checkpoint handling was verified to include:

```text
factor_heads
global_align_space
source_adv_space
factor_orth_weight
```

The eval scripts were updated to avoid silently falling back to the shared vector when `feature_space=bio` is requested.

## Training Health

Both A8 pilots reached step 20000 and wrote `DONE`.

Final training diagnostics:

| Run | Loss | Global align | Orth loss | Source acc | Shared rank | Bio rank | Src rank |
|---|---:|---:|---:|---:|---:|---:|---:|
| orth `0.05` | 3.5989 | 0.000052 | 0.003873 | 0.000 | 155.34 | 4.95 | 6.30 |
| orth `0.10` | 3.5992 | 0.000120 | 0.004063 | 0.000 | 152.38 | 6.25 | 5.95 |

The shared feature map did not collapse by rank, but the projected factor ranks were very low. This was an early warning that `z_bio` and `z_src` may be too compressed or over-regularized for downstream tasks.

## Evaluation Results

Source-probe on `z_bio`:

| Run | Source-probe acc | Chance | Verdict |
|---|---:|---:|---|
| orth `0.05` | 0.0815 | 0.0278 | passes source gate |
| orth `0.10` | 0.0833 | 0.0278 | passes source gate |

Downstream global probes on `z_bio`:

| Run | Task1 AUROC | Task3 Pearson | Task5 AUROC | Verdict |
|---|---:|---:|---:|---|
| orth `0.05` | 0.5481 | -0.0014 | 0.5868 | fails |
| orth `0.10` | 0.3942 | 0.1761 | 0.4080 | fails |

Reference points:

| Model | Source-probe | Task1 | Task3 | Task5 |
|---|---:|---:|---:|---:|
| A2 mainline | 0.0846 mean | 0.6731 | 0.6720 | 0.8681 |
| A5 `w=0.10` | 0.2574 | 0.8077 | 0.6996 | 0.8715 |
| S3D+InfoNCE wg0.5 | 0.3105 mean | 0.7212 | 0.7924 | 0.9566 |
| A8 orth `0.05` | 0.0815 | 0.5481 | -0.0014 | 0.5868 |
| A8 orth `0.10` | 0.0833 | 0.3942 | 0.1761 | 0.4080 |

## Findings

1. A8 is not a replacement foundation candidate.

   It satisfies the source-control criterion, but the downstream signal is too weak. The `z_bio` projection is source-invariant but not biologically useful enough.

2. Orthogonal factorized heads alone are under-constrained.

   The objective says what `z_bio` should not contain, but it does not sufficiently force `z_bio` to preserve anatomy, age, or disease-relevant global variation.

3. The low projected ranks are consistent with downstream collapse.

   Final `bio_rank` was only about `5-6`, while the shared feature-map rank stayed above `150`. This suggests the failure is in the factor projection/objective, not necessarily in the encoder backbone.

4. The next branch should not be another A8 hyperparameter sweep.

   Changing only `factor_orth_weight` is unlikely to fix the missing biology target. A useful next experiment must add a positive biology-preserving constraint.

## Decision

Reject A8 as implemented.

Do not launch more A8 variants until one of the following is added:

- dense/S3D-style reconstruction decoder,
- tissue/ROI/atlas context prediction,
- distillation from the existing S3D+InfoNCE wg0.5 global representation,
- or a supervised/weakly supervised biological proxy available only in pretraining data metadata and not confounded with source.

## Next Technical Direction

The strongest next design is a hybrid:

```text
A2 robust JEPA backbone
+ S3D-style dense anatomical decoder to preserve local biology
+ optional global distillation from S3D+InfoNCE wg0.5
+ source-balanced sampling and style augmentation
+ source probe and downstream probe as mandatory gates
```

This keeps the best A2 property, source robustness, while adding an explicit reason for the representation to retain anatomical and phenotype-relevant signal.
