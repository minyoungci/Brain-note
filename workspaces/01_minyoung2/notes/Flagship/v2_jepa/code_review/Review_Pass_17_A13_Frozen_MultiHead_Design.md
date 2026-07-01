# Review Pass 17: A13 Frozen Multi-Head Design

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/train_anatomy_head.py
Flagship/v2_jepa/code/eval_source_probe.py
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
Flagship/v2_jepa/runs/smoke_a13_frozen_anat_head_gpu0/
```

## Motivation

A12 showed that backpropagating anatomy-summary loss into the JEPA encoder can recover some brain-age signal, but it damages Task1/Task5. The likely issue is over-regularizing the shared global representation.

A13 therefore changes the structure:

```text
freeze A10 JEPA encoder
  -> keep A10 shared global vector unchanged
  -> train only a separate anatomy-summary head
  -> evaluate shared, anatomy-only, and shared+anatomy features
```

This tests a multi-head foundation representation without damaging the current best JEPA backbone.

## Implementation

Added:

```text
Flagship/v2_jepa/code/train_anatomy_head.py
```

The script:

- loads an existing Brain-JEPA checkpoint,
- freezes the full encoder,
- trains only `AnatomySummaryPredictor`,
- predicts the same low-frequency anatomy summary target used by A12,
- saves a standalone head checkpoint containing `head`, `head_cfg`, `base_ckpt`, and RNG state.

Extended:

```text
Flagship/v2_jepa/code/eval_source_probe.py
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
```

New feature spaces:

```text
anatsum
shared_plus_anatsum
```

## Validation

Compile and tests:

```bash
python -m py_compile \
  Flagship/v2_jepa/code/train_anatomy_head.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/tests/test_brain_jepa.py

python Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

Result:

```text
Ran 14 tests
OK
```

GPU smoke:

```bash
CUDA_VISIBLE_DEVICES=0 python Flagship/v2_jepa/code/train_anatomy_head.py \
  --ckpt Flagship/v2_jepa/runs/pilot_a10_s3ddense005_a2main_anat_seed4001_gpu1_20260630/ckpt_step20000.pt \
  --out Flagship/v2_jepa/runs/smoke_a13_frozen_anat_head_gpu0 \
  --steps 5 --batch 4 --crop 64 --subset 128 \
  --hidden 128 --grid 2 --bins 5
```

Smoke result:

```text
step=5
loss=0.0328
ckpt_step5.pt=True
ERROR=False
DONE=True
```

Feature smoke:

```bash
CUDA_VISIBLE_DEVICES=0 python Flagship/v2_jepa/code/eval_source_probe.py \
  --ckpt Flagship/v2_jepa/runs/pilot_a10_s3ddense005_a2main_anat_seed4001_gpu1_20260630/ckpt_step20000.pt \
  --anatomy_head Flagship/v2_jepa/runs/smoke_a13_frozen_anat_head_gpu0/ckpt_step5.pt \
  --feature_space shared_plus_anatsum \
  --subset 72 --crop 64 --epochs 2
```

Feature smoke result:

```text
dim=341
source test acc=0.0278
```

## Gate

A13 is only useful if:

- `shared_plus_anatsum` keeps source-probe `<=0.17`,
- Brain Age improves over A10 `0.6085`,
- Task1/Task5 stay close to A10 because the base encoder is frozen.

If `shared_plus_anatsum` still hurts Task1/Task5 or source-probe, then the issue is not only encoder over-regularization; the anatomy summary itself is not the right auxiliary representation.
