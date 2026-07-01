# Review Pass 20: A16 Disentangled Pseudo-Tissue Morphology Head

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/train_morphology_head.py
Flagship/v2_jepa/code/eval_source_probe.py
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

## Reason For A16

A14/A15 showed that pseudo-tissue dense targets are useful but unsafe when applied to the shared JEPA representation:

```text
A14/A15:
  brain-age recovered
  Task5 improved
  Task1 failed
```

The failure suggests feature coupling, not a lack of morphology signal. A16 therefore separates the morphology signal from the shared feature:

```text
frozen A10 encoder
  + PseudoTissueMorphologyHead
  + evaluate feature spaces separately:
      shared
      morph
      shared_plus_morph
```

## Implementation

Added `PseudoTissueMorphologyHead`:

```text
local A10 feature map
  -> 1x1x1 conv trunk
  -> dense pseudo-tissue prediction head
  -> morphology vector from pooled embedding mean/std
```

Added `train_morphology_head.py`:

```text
load A10 checkpoint
freeze Brain-JEPA encoder
train only morphology head
target = pseudo_tissue_dense_target(view, foreground)
loss = SmoothL1(dense prediction, pseudo-tissue target)
```

Extended probe scripts:

```text
--morphology_head PATH
--feature_space morph
--feature_space shared_plus_morph
```

## Validation

Compile:

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
smoke_a16_morphology_head_gpu0
DONE
ckpt_step5.pt written
no ERROR
```

Probe smoke:

```text
eval_source_probe.py --feature_space morph
eval_source_probe.py --feature_space shared_plus_morph
.venv-train/bin/python eval_jepa_downstream_probe.py --feature_space shared_plus_morph --tasks task3_brainage --max_subj 12
```

All smoke paths completed. The first downstream smoke with system Python failed because `yucca` is not installed in that interpreter; rerunning through `.venv-train/bin/python` succeeded.

## Running Pilot

```text
Run: Flagship/v2_jepa/runs/pilot_a16_frozen_a10_pseudotissue_morph_g192e128_seed4500_gpu0_20260701
PID: 3605586
GPU: 0
Base: A10 dense=0.05
Steps: 10000
Checkpoint interval: 1000
```

Initial health:

```text
step=61
loss=0.00771
best_loss=0.00518
morph effective rank=10.00
no ERROR
```

## Step1000 Gate Result

| Feature | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| `morph` | 0.0759 | — | — | — | source-safe morphology space |
| `shared_plus_morph` | 0.0815 | 0.7981 | 0.6573 | 0.8854 | continue to 10k |
| A10 dense `0.05` reference | 0.0778 | 0.8077 | 0.6085 | 0.8976 | best JEPA research branch |
| A14 pseudo-tissue `0.05` | 0.1574 | 0.6346 | 0.7770 | 0.9201 | rejected |
| A15 pseudo-tissue `0.02` | 0.1648 | 0.4038 | 0.7591 | 0.9462 | rejected |

Interpretation:

```text
A16 fixed the A14/A15 Task1-collapse failure mode at the first gate.
```

The morphology head is source-safe and `shared_plus_morph` preserves the A10 Task1 signal while improving brain-age over A10. The improvement is not yet enough to replace the production S3D+InfoNCE model, and brain-age did not reach the preferred `>0.672` gate at step1000. Still, this is the first JEPA variant after A10 that improves brain-age without reopening source leakage or collapsing Task1.

Decision:

```text
Continue A16 to 10k.
Re-evaluate ckpt_step10000.pt with the same source/downstream gates.
```

## Final 10k Gate Result

| Feature | Source-probe | Task1 AUROC | Brain-age Pearson | Task5 AUROC | Decision |
|---|---:|---:|---:|---:|---|
| `morph` | 0.1259 | — | — | — | source leakage increased |
| `shared_plus_morph` | 0.1185 | 0.8077 | 0.7064 | 0.9201 | best balanced JEPA candidate so far |
| A10 dense `0.05` reference | 0.0778 | 0.8077 | 0.6085 | 0.8976 | stronger source robustness, weaker global biology |
| S3D+InfoNCE wg0.5 reference | 0.3105 | 0.7212 | 0.7924 | 0.9566 | production reference |

Final verdict:

```text
A16 is promoted over A10 as the best balanced JEPA research candidate.
It is not yet the final foundation replacement.
```

Why:

- It preserves A10 Task1 (`0.8077` vs `0.8077`).
- It improves brain-age substantially (`0.7064` vs `0.6085`).
- It improves Task5 (`0.9201` vs `0.8976`).
- It remains far less source-predictive than S3D (`0.1185` vs `0.3105`).
- But it is less source-robust than A10 (`0.1185` vs `0.0778`), so the next branch should add source-adversarial regularization or early-stop selection on the morphology head.

## Gate

At `ckpt_step1000.pt`, evaluate `morph` and `shared_plus_morph`:

```text
source <= 0.17 hard max, <= 0.10 preferred
Task1 >= 0.72 hard floor, >= 0.80 preferred
brain-age > 0.6085 minimum, > 0.672 preferred
Task5 >= 0.88 minimum
```

Decision:

```text
Promote only if shared_plus_morph preserves Task1 while improving brain-age.
Stop if the morphology head repeats the A14/A15 Task1 failure.
```
