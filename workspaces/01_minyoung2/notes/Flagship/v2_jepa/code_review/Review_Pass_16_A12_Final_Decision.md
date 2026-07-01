# Review Pass 16: A12 Final Decision

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/runs/pilot_a12_s3ddense005_anatsum*_anat_seed*_gpu*_20260630/
Flagship/v2_jepa/results/source_probe/a12_s3ddense005_anatsum*_seed100_subset1800_crop96.json
Flagship/v2_jepa/results/downstream_probe/a12_s3ddense005_anatsum*_task1_task3_task5.json
```

## Question

Should JEPA experiments continue in the same direction after A12?

Short answer:

```text
No. Stop blind JEPA hyperparameter search.
```

## A12 Final Results

| Model | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC |
|---|---:|---:|---:|---:|
| A10 dense `0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 |
| A11 align `0.02` | 0.2130 | 0.6827 | 0.6929 | 0.8194 |
| A12 anatomy `0.05` | 0.0981 | 0.5673 | 0.6616 | 0.7118 |
| A12 anatomy `0.10` | 0.1685 | 0.4038 | 0.7038 | 0.6233 |
| Previous S3D+InfoNCE wg0.5 | 0.3105 | 0.7212 | 0.7924 | 0.9566 |

## Interpretation

A12 answered a specific question: can low-frequency anatomy targets recover brain-age without reopening source shortcuts?

The answer is partially yes:

- `anatsum=0.05` source-probe `0.0981`, safely under the `<=0.17` gate.
- `anatsum=0.10` source-probe `0.1685`, barely under the gate.
- `anatsum=0.10` improves brain-age to `0.7038`, above A10 and A2/A11-level.

But the balanced foundation-model gate fails:

- Task1 drops from A10 `0.8077` to `0.5673` / `0.4038`.
- Task5 drops from A10 `0.8976` to `0.7118` / `0.6233`.

So A12 does not produce a usable all-task representation. It moves along a trade-off curve:

```text
more anatomy-summary pressure
  -> better Brain Age
  -> source still controlled
  -> classification/phenotype signal degrades
```

## Decision

A12 is rejected as-is.

The current best JEPA research branch remains:

```text
A10 = A2 robust JEPA + masked S3D dense/local bottleneck distillation w=0.05
```

But A10 is not a final foundation replacement because brain-age remains weak.

## Recommendation

Do not keep running nearby JEPA weight sweeps:

- no more `global_align_weight` sweeps,
- no more `anatomy_summary_weight` sweeps,
- no more source-adversary weight-only sweeps.

The evidence from A5-A12 is consistent:

```text
global/age signal and source/protocol signal are coupled;
source-safe objectives tend to remove age/phenotype information;
generic global objectives recover age by reopening shortcut dimensions;
coarse anatomy summaries recover age but erase classification signal.
```

The next JEPA experiment is only justified if it is structurally different and has a pre-registered gate. Viable options:

1. Multi-head representation:
   - one dense/local anatomy head for source-robust features,
   - one global morphology head for age,
   - one phenotype head that is protected from over-regularization.
2. Atlas/tissue/ROI targets instead of coarse whole-crop summaries.
3. Source-held-out pretraining validation, not just post-hoc source-probe.
4. Compare against S3D+InfoNCE as the practical baseline, not just against previous JEPA branches.

Until one of those structural changes is implemented, the right operational choice is to stop JEPA exploration and treat A10/A12 as evidence, not as the final model.
