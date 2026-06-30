# Review Pass 14: A11 Weak Global Correction

Date: 2026-06-30 UTC

Scope:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/results/source_probe/
Flagship/v2_jepa/results/downstream_probe/
Flagship/v2_jepa/runs/pilot_a11_dense005_galign*_anat_seed*_gpu*_20260630/
```

## Question

A10 is the best source-robust JEPA branch so far, but its brain-age signal is weak:

```text
A10 dense w=0.05:
  source-probe = 0.0778
  Task1 AUROC = 0.8077
  Task3 brain-age r = 0.6085
  Task5 AUROC = 0.8976
```

A11 tests whether a weak EMA global alignment term can recover brain-age while preserving the A10 source gate.

## Implementation Reviewed

A11 used the existing training code path:

```text
JEPA latent loss
+ source-balanced sampling
+ source adversary
+ MRI style augmentation
+ masked S3D dense/local bottleneck distillation w=0.05
+ weak BYOL-style EMA global alignment
```

The two tested branches were:

| Run | Dense weight | Global-align weight | Steps | Status |
|---|---:|---:|---:|---|
| `pilot_a11_dense005_galign002_anat_seed4100_gpu0_20260630` | 0.05 | 0.02 | 20000 | DONE, no ERROR |
| `pilot_a11_dense005_galign005_anat_seed4101_gpu1_20260630` | 0.05 | 0.05 | 20000 | DONE, no ERROR |

## Health Checks

Both runs wrote `ckpt_step20000.pt`, `DONE`, and no `ERROR.json`.

Final status:

| Run | Loss | JEPA | Dense loss | Global-align loss | Source loss | Pred std | Pred rank |
|---|---:|---:|---:|---:|---:|---:|---:|
| A11 `align=0.02` | 3.7573 | 0.0121 | 1.5962 | 0.0589 | 3.6643 | 0.1693 | 178.45 |
| A11 `align=0.05` | 3.6382 | 0.0050 | 1.5862 | 0.0171 | 3.5530 | 0.1449 | 174.27 |

There is no training-collapse evidence. The failure is representational, not a runtime or numerical failure.

## Final Evaluation

| Model | Source-probe | Task1 AUROC | Task3 brain-age r | Task5 AUROC |
|---|---:|---:|---:|---:|
| A10 dense `0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 |
| A11 dense+align `0.02` | 0.2130 | 0.6827 | 0.6929 | 0.8194 |
| A11 dense+align `0.05` | 0.2481 | 0.2596 | 0.6786 | 0.9062 |
| Previous S3D+InfoNCE wg0.5 | 0.3105 | 0.7212 | 0.7924 | 0.9566 |

Gate verdict:

- Source-probe gate `<=0.17`: failed by both A11 branches.
- Task1 preservation: failed by both branches; severe collapse for `align=0.05`.
- Brain-age recovery: partial, but still below S3D and not enough to justify the source leakage.
- Task5 preservation: mixed; `align=0.05` improves over A10, but this branch collapses Task1 and source robustness.

## Interpretation

A11 confirms the central trade-off observed in A5 and A9:

```text
generic global alignment
  -> recovers some global/age variance
  -> also reopens source, scanner, protocol, or cohort shortcut directions
```

This matters for brain-age specifically. Brain-age is not purely anatomical in the available probe setting; it is likely entangled with acquisition protocol, scanner/source, field of view, resolution, and cohort composition. A confound-robust JEPA objective suppresses those directions, so brain-age falls. Adding generic global alignment brings part of the age signal back, but also brings the nuisance signal back.

Therefore, A11 should not be promoted even though `align=0.02` improves brain-age from `0.6085` to `0.6929`.

## Decision

A11 is rejected.

The next architecture should not add more generic global alignment. It should add a more constrained biological/global target that is less source/protocol-entangled:

1. Tissue/ROI context prediction.
2. Atlas-zone consistency across views.
3. Anatomy-aware global summaries, such as regional volume or morphology targets.
4. Source-held-out validation as a first-class training/evaluation gate.

Current best JEPA research branch remains:

```text
A10 dense w=0.05
```

But A10 is not final because brain-age remains weak.
