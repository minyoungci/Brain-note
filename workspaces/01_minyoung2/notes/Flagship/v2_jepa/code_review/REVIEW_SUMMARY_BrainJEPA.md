# Brain-JEPA Code Review Summary

Date: 2026-06-28 / reorganized: 2026-06-29
Scope: `Flagship/v2_jepa/` only.

## What Was Built

Created a code-only Brain-JEPA 3D multimodal prototype under:

```text
Flagship/v2_jepa/code/brain_jepa/
```

The code implements:

- 3D block masking
- modality-specific ResEnc stems
- shared ResEnc encoder stages
- context encoder + EMA target encoder
- 3D JEPA predictor
- masked latent target loss
- collapse diagnostics
- unit tests
- CUDA smoke test

Loss landscape/objective geometry utilities now live in:

```text
Flagship/v2_jepa/code/analysis/
```

## Validation Summary

```bash
python -m unittest Flagship.v2_jepa.code.tests.test_brain_jepa
python -m unittest Flagship.v2_jepa.code.tests.test_loss_geometry
python Flagship/v2_jepa/code/smoke_brain_jepa.py
```

Passed before the v1/v2 split and should be rerun after any path changes.

## Review Passes

1. Static/API review: fixed target-stage validation, modality order, variance guard.
2. Shape/gradient/EMA review: verified finite loss, matching latent shapes, target no-grad, nonzero gradients.
3. Scope/integration review: verified code is isolated from challenge submission paths.
4. Loss landscape/objective geometry review: verified differentiable loss terms, gradient cosine, Hessian utilities, and 2D landscape smoke.
5. A0 training launch review: verified real-data Brain-JEPA pilot training, checkpointing, status logging, and collapse diagnostics.
6. A2 confound-robustness review: added source-balanced sampling, foreground crop, MRI style augmentation, source adversary, and source-probe evaluation. Promoted A2 random-mask/style as the current confound-robust JEPA branch.
7. A4 weak global InfoNCE review: added global InfoNCE hybrid and rejected it after source-probe/downstream gates.
8. A5 global alignment review: added BYOL-style positive-only global alignment, found partial downstream recovery but unacceptable source leakage.
9. A6 stronger GRL review: increasing source adversary weight did not reduce post-hoc source leakage and damaged downstream classification.
10. A7 larger source head review: larger source head + batch 8 reduced source-probe but also removed downstream global signal.
11. A8 factorized global review: `bio/src` projection heads reduced `bio` source-probe to A2 levels, but downstream Task1/3/5 collapsed, so factorized heads alone are rejected.
12. A9 S3D-global distillation review: added a frozen S3D+InfoNCE wg0.5 global teacher. It recovered brain-age for `w=0.05`, but source leakage and Task1 failed, so unfiltered S3D global distillation is rejected.
13. A10 S3D dense/local distillation review: masked S3D bottleneck distillation `w=0.05` achieved source-probe `0.0778`, Task1 `0.8077`, and Task5 `0.8976`, but brain-age remained weak at `0.6085`.
14. A11 weak global correction review: adding weak EMA global alignment to A10 partially recovered brain-age (`0.6929` at `w=0.02`) but raised source-probe to `0.2130` and degraded Task1/Task5; `w=0.05` raised source-probe to `0.2481` and collapsed Task1.
15. A12 anatomy-summary target review: added a low-frequency anatomy summary prediction head to A10, validated with unit tests and GPU smoke, and launched two 20k pilots with anatomy-summary weights `0.05` and `0.10`.

## Current Status

This is now a working pilot training system, not only a scaffold.

Completed:

- real MRI dataset/dataloader
- multi-view crop sampler
- checkpointing
- AMP training loop
- source-balanced sampling
- post-hoc source-probe
- downstream frozen global probe for Task1/3/5

Still missing before a paper-scale Brain-JEPA claim:

- explicit atlas/tissue/ROI anatomy-aware targets
- true paired multimodal T1/FLAIR/DWI consistency
- source/site-held-out downstream benchmark
- scaling-law/data-quality ablations
- segmentation-transfer evidence for JEPA

## Boundary

This summary intentionally does not cover S3D-VistaAdapter. Decoder replacement experiments belong to `Flagship/v1_evidence/`.

## Current Verdict

```text
Best validated production foundation remains:
  ResEnc + S3D-dense + InfoNCE-global wg0.5

Best JEPA research branch remains:
  A10 = A2 robust JEPA + masked S3D dense/local bottleneck distillation w=0.05

Rejected:
  A4 weak global InfoNCE hybrid
  A5 global alignment as-is
  A6 stronger GRL as-is
  A7 shared-vector larger-head GRL as-is
  A8 factorized bio/src heads as-is
  A9 unfiltered S3D-global distillation as-is
  A10 dense w=0.02
  A11 weak global correction as-is

Active next direction:
  A12 is running: A10 dense w=0.05 + low-frequency anatomy summary prediction.
  Evaluate A12 with the same source-probe and Task1/3/5 downstream gates after
  ckpt_step20000.pt. Do not promote it unless source-probe stays <=0.17 and
  brain-age improves without Task1/Task5 collapse.
```
