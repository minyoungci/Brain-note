# Review Pass 29 - A22 Style-Invariant Morphology Head

Date: 2026-07-01 UTC

## Scope

Reviewed and launched A22 after A20/A21 failed to recover external brain-age utility.

A22 modifies the A16/A17 frozen pseudo-tissue morphology-head path:

```text
original crop -> pseudo-tissue target
style-augmented crop -> frozen A10 JEPA encoder -> morphology head

loss = pseudo-tissue reconstruction
     + source adversary on morphology vector
```

## Evidence For The Design

A20/A21 showed:

- source/global filtering can reduce source and scanner shortcuts;
- Task1 can remain strong;
- brain-age and external A4 age do not recover.

A16/A17 showed:

- pseudo-tissue morphology heads recover internal brain-age and Task5;
- morphology features still leak scanner/source externally.

A22 directly targets the remaining failure:

```text
morphology useful but scanner-style vulnerable
```

The new training objective forces the morphology readout to predict a style-light pseudo-tissue target from a style-perturbed encoder input.

## Code Changes Reviewed

File:

- `Flagship/v2_jepa/code/train_morphology_head.py`

Changes:

- Added `--style_aug_strength`.
- Imported and reused `mri_style_augment` from `train_brain_jepa.py`.
- Built `encoder_view = mri_style_augment(view, ...)` for the frozen encoder path.
- Kept pseudo-tissue target on the unaugmented `view`.
- Fixed gradient clipping to include all optimized parameters, including the source adversary.
- Logged `style_aug_strength` in `status.json`.

New watcher:

- `Flagship/v2_jepa/scripts/eval_morph_run_when_done.sh`

The watcher evaluates:

- `morph` source probe;
- `shared_plus_morph` source probe;
- `shared_plus_morph` downstream Task1/Task3/Task5;
- protocol-group Task1/Task5;
- external A4/AIBL/AJU gate.

## Validation

Compile:

```bash
python -m py_compile \
  Flagship/v2_jepa/code/train_morphology_head.py \
  Flagship/v2_jepa/code/train_brain_jepa.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  Flagship/v2_jepa/code/eval_external_foundation_probe.py
```

Watcher syntax:

```bash
bash -n Flagship/v2_jepa/scripts/eval_morph_run_when_done.sh
```

GPU smoke:

```bash
CUDA_VISIBLE_DEVICES=0 .venv-train/bin/python \
  Flagship/v2_jepa/code/train_morphology_head.py \
  --out Flagship/v2_jepa/runs/smoke_a22_style_morph_gpu0_20260701 \
  --device cuda \
  --seed 5400 \
  --steps 3 \
  --batch 2 \
  --subset 64 \
  --workers 0 \
  --min_per_source 2 \
  --style_aug_strength 0.75 \
  --source_adv_weight 0.05 \
  --source_adv_warmup 1 \
  --ckpt_every 3 \
  --status_every 1 \
  --resume 0
```

Smoke result:

```text
step=1 loss=3.73860 rank=1.00
step=2 loss=3.74585 rank=1.00
step=3 loss=3.64744 rank=1.00
```

The smoke completed with finite loss, checkpoint write, DONE file, and no ERROR.

## Running Pilots

| Run | GPU | Style aug | Source adv | Step at health check | Source acc | Morph rank | Status |
|---|---:|---:|---:|---:|---:|---:|---|
| `pilot_a22_style050_morphadv010_seed5400_gpu0_20260701` | 0 | 0.5 | 0.10 | 201 | 0.0000 | 8.03 | healthy |
| `pilot_a22_style100_morphadv010_seed5401_gpu1_20260701` | 1 | 1.0 | 0.10 | 201 | 0.1250 | 10.64 | healthy |

## Decision Rule

Promote A22 only if it improves the actual failure axis:

```text
external A4 age r improves over A20/A21/A17
and scanner/cohort leakage remains clearly below S3D
and internal Task1 does not collapse.
```

Reject if:

```text
external A4 age remains near zero/negative,
or scanner leakage remains A17-like,
or Task1 collapses like A14/A15/A18/A19.
```

## Residual Risk

- Style augmentation may suppress intensity information that pseudo-tissue bins depend on, weakening morphology utility.
- If both style strengths fail, the next step should not be a strength sweep; it should use explicit anatomical coordinates/atlas-style ROI context or external-label-free morphometric summaries with deterministic nuisance residualization.
