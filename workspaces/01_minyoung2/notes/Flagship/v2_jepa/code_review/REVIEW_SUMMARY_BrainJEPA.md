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
16. A12 final decision review: A12 passed the source gate (`0.0981` / `0.1685`) and recovered brain-age in the `0.10` branch (`0.7038`), but Task1 and Task5 degraded sharply, so A12 is rejected as-is.
17. A13 frozen multi-head design review: added standalone anatomy-head training, `anatsum`, and `shared_plus_anatsum` evaluation without updating the A10 encoder.
18. A13 final decision review: A13 passed source-probe (`0.0722` / `0.0852`) but failed downstream replacement gates (`shared+anatsum`: Task1 `0.7212`, brain-age `0.5846`, Task5 `0.8837`), so it was stopped early and rejected as-is.
19. A14/A15 pseudo-tissue dense review: added dense pseudo-tissue targets, validated by unit tests/GPU smoke, and stopped both pilots after the step1000 gate. A14/A15 recovered brain-age and Task5, but Task1 failed, so this direction is rejected as a shared-representation objective.
20. A16 disentangled morphology-head review: added frozen-A10 pseudo-tissue morphology head training plus `morph`/`shared_plus_morph` source and downstream evaluation paths. Compile, 16 unit tests, GPU smoke, source-probe smoke, and downstream-probe smoke passed. Final 10k `shared_plus_morph` reached source `0.1185`, Task1 `0.8077`, brain-age `0.7064`, and Task5 `0.9201`, so A16 becomes the best balanced JEPA research candidate so far.
21. A17 source-adversarial morphology-head refinement: extended `train_morphology_head.py` with optional source adversary on the morphology vector. Compile/unit/smoke passed. Final 10k `adv=0.10` is promoted as the best JEPA research branch: source mean seeds 100/101/102 `0.1130`, Task1 `0.8654`, brain-age `0.7122`, Task5 `0.9080`.
22. Protocol-group downstream gate review: added protocol/FOV/resolution group-heldout probing to both JEPA and S3D global-probe scripts. A17 remains viable but no longer has a clear Task1/Task5 win under protocol-group holdout (`A17`: `0.8173`/`0.8976`; S3D: `0.8269`/`0.9010`).
23. A18 paired-modality JEPA review: added same-subject/session same-shape paired modality data loading and launched T1-FLAIR/T1-T2 cross-modality JEPA pilots with A10 S3D dense distillation and source adversary. Compile, 17 tests, and GPU smoke passed. Step5000 gates showed source robustness and brain-age recovery, but protocol-group Task1 failed; both pilots were stopped.
24. A19 disentangled auxiliary-modality review: added anatomy/pathology/nuisance branch heads, routed paired-modality alignment only to the anatomy branch, kept base JEPA same-modality, extended source/downstream probes with A19 feature spaces, passed compile/18 tests/GPU smoke/eval smoke, and launched T1-FLAIR/T1-T2 pilots. Step5000 source behavior improved, especially for T1-T2, but both branches failed Task1 (`0.4712`) and were stopped.

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
- protocol/FOV group-heldout downstream probe for Task1/5
- paired T1-FLAIR and T1-T2 cross-modality JEPA pilot training
- A19 disentangled anatomy/pathology/nuisance auxiliary branch training

Still missing before a paper-scale Brain-JEPA claim:

- explicit atlas/tissue/ROI anatomy-aware targets
- DWI-scale paired consistency; current same-shape DWI pairs are sparse
- true source/site-held-out downstream benchmark
- scaling-law/data-quality ablations
- segmentation-transfer evidence for JEPA
- external-data validation with actual site/scanner metadata

## Boundary

This summary intentionally does not cover S3D-VistaAdapter. Decoder replacement experiments belong to `Flagship/v1_evidence/`.

## Current Verdict

```text
Best validated production foundation remains:
  ResEnc + S3D-dense + InfoNCE-global wg0.5

Best JEPA research branch is now:
  A17 adv=0.10 = frozen A10 shared encoder
                 + separate pseudo-tissue morphology head
                 + weak morphology-source adversary
                 + shared_plus_morph features

Rejected:
  A4 weak global InfoNCE hybrid
  A5 global alignment as-is
  A6 stronger GRL as-is
  A7 shared-vector larger-head GRL as-is
  A8 factorized bio/src heads as-is
  A9 unfiltered S3D-global distillation as-is
  A10 dense w=0.02
  A11 weak global correction as-is
  A12 anatomy-summary correction as-is
  A13 frozen anatomy-head correction as-is
  A14/A15 pseudo-tissue dense correction as-is

Active next direction:
  A17 adv=0.10 remains the best completed confound-aware JEPA candidate so far,
  but it is still not a final foundation-model claim. A18 paired-modality JEPA
  passed source-probe and improved brain-age at step5000, but failed
  protocol-group Task1 and was stopped. A19 implemented the resulting
  structural fix, but still failed Task1 at step5000. The next step should not
  continue anatomy/modality-only pretraining branches. Either promote A17 as
  the best JEPA research candidate for stronger source/site-heldout validation,
  or add a genuinely pathology-preserving SSL signal before launching A20.
```
