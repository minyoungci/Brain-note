# Review Pass 21: A17 Source-Adversarial Morphology Head

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/train_morphology_head.py
Flagship/v2_jepa/results/source_probe/SUMMARY.md
Flagship/v2_jepa/results/downstream_probe/SUMMARY.md
Flagship/v2_jepa/runs/RUNNING_JEPA_PILOTS.md
```

## Reason For A17

A16 showed that pseudo-tissue morphology is a useful signal when separated from the shared JEPA encoder:

```text
A16 shared_plus_morph:
  source-probe = 0.1185
  Task1 AUROC = 0.8077
  brain-age r = 0.7064
  Task5 AUROC = 0.9201
```

The remaining issue was not downstream collapse, but a source-probe rise relative to A10 (`0.1185` vs `0.0778`). A17 therefore keeps the A10 encoder frozen and regularizes only the separate morphology vector with a weak source adversary.

## Implementation

`train_morphology_head.py` now supports:

```text
--source_adv_weight
--source_adv_hidden
--source_adv_warmup
```

Training objective:

```text
L = L_pseudo_tissue_morphology + lambda_source * GRL(source CE on morph vector)
```

The source adversary is applied to the morphology vector, not the frozen A10 shared encoder. This keeps A17 scoped: it tests whether the extra morphology feature can be made less source-predictive without rewriting the already validated A10 branch.

## Validation

Static/shape validation:

```text
python -m py_compile \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/train_morphology_head.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

Unit tests:

```text
python Flagship/v2_jepa/code/tests/test_brain_jepa.py
Ran 16 tests OK
```

GPU smoke:

```text
smoke_a17_morphology_head_adv_gpu0
DONE
ckpt_step5.pt written
no ERROR
```

## Final Gate Result

| Branch | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| A10 dense `0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 | source-robust baseline JEPA |
| A16 shared+morph | 0.1259 mean | 0.8077 | 0.7064 | 0.9201 | strong balance, source cost |
| A17 adv `0.05` | 0.1167 | 0.7500 | 0.7219 | 0.9427 | reject: Task1 weaker |
| A17 adv `0.10` | 0.1130 mean | 0.8654 | 0.7122 | 0.9080 | promote as best JEPA research branch |
| S3D+InfoNCE wg0.5 | 0.3105 | 0.7212 | 0.7924 | 0.9566 | production reference |

## Verdict

A17 `adv=0.10` is the best current JEPA research candidate:

- It improves source-probe over A16 (`0.1130` vs `0.1259` mean).
- It improves Task1 over A10, A16, and S3D in this frozen-probe gate.
- It improves brain-age over A10/A16 but remains below S3D.
- It keeps Task5 useful but remains below S3D and A16.

This is not yet a final foundation-model claim. The evidence still lacks source/site-held-out downstream validation, segmentation-transfer evidence, and explicit atlas/tissue/ROI or paired multimodal objectives.

## Next Gate

Do not continue blind A17 scalar sweeps. The next useful experiment is:

```text
A17 adv=0.10 vs S3D wg0.5
  under source/site-held-out downstream splits
  with the same frozen-probe protocol first
  then task-specific fine-tuning only if the held-out probe is credible
```

If A17 loses under source-held-out downstream splits, the next architecture should add richer brain-specific targets rather than only tuning the morphology adversary:

```text
atlas/ROI/tissue context prediction
paired T1/FLAIR/DWI consistency
source-held-out validation as the selection objective
```
