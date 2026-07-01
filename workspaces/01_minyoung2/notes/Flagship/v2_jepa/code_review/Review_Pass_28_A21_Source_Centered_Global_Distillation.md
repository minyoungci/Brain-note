# Review Pass 28 - A21 Source-Centered Global Distillation

Date: 2026-07-01 UTC

## Scope

Reviewed and smoke-tested the A21 extension to `train_global_filter_head.py`.

A21 keeps the frozen A10 Brain-JEPA encoder and the same global adapter gate used by A20, but changes the distillation target:

```text
A20 target = raw S3D global vector

A21 target = S3D global
           - EMA source centroid
           + EMA global centroid
```

This directly tests whether the A20 failure comes from asking the adapter to preserve a raw S3D global space whose dominant directions include source/cohort offsets.

## Pass 1 - Static Code Review

Files inspected:

- `Flagship/v2_jepa/code/train_global_filter_head.py`
- `Flagship/v2_jepa/code/eval_external_foundation_probe.py`
- `Flagship/v2_jepa/code/eval_source_probe.py`
- `Flagship/v2_jepa/code/eval_jepa_downstream_probe.py`
- `Flagship/v2_jepa/scripts/eval_a20_run_when_done.sh`

Checks:

- The new `teacher_target` mode preserves the same adapter output dimensionality as A20, so existing `filtered` evaluation paths remain compatible.
- Checkpoints keep `head_cfg.kind = source_filtered_global`, so the external/downstream/source evaluators can load A21 heads without modification.
- Source centroids and global centroids are checkpointed and restored, so interrupted A21 runs can resume without silently changing the teacher target distribution.
- The target is built before centroid update, preventing the current sample from immediately subtracting itself out on first observation.
- For unseen sources, the target falls back to the current global centroid or batch mean, avoiding invalid zero-centering at the beginning of training.

## Pass 2 - Compile and Smoke Test

Compile:

```bash
python -m py_compile Flagship/v2_jepa/code/train_global_filter_head.py
```

Smoke command:

```bash
CUDA_VISIBLE_DEVICES=2 .venv-train/bin/python \
  Flagship/v2_jepa/code/train_global_filter_head.py \
  --out Flagship/v2_jepa/runs/smoke_a21_source_centered_global_gpu2_v2_20260701 \
  --device cuda \
  --seed 5300 \
  --steps 2 \
  --batch 2 \
  --subset 64 \
  --workers 0 \
  --min_per_source 2 \
  --source_adv_weight 0.02 \
  --source_adv_warmup 1 \
  --teacher_target source_centered_ema \
  --centroid_momentum 0.2 \
  --ckpt_every 2 \
  --status_every 1 \
  --resume 0
```

Result:

```text
step=1 loss=5.70245 cos_raw=-0.049 cos_target=-0.049 rank=10.14
step=2 loss=5.46025 cos_raw=0.132 cos_target=0.132 rank=1.00
```

The first smoke run caught a logging bug (`cos` variable renamed to `cos_raw`/`cos_target`). The bug was fixed and the second smoke completed with finite loss, checkpoint write, DONE file, and no ERROR.

## Pass 3 - Launch Configuration Review

Running pilots:

| Run | GPU | Teacher target | Source adv | Centroid momentum | Steps | Status |
|---|---:|---|---:|---:|---:|---|
| `pilot_a21_srcctr_adv002_seed5300_gpu2_20260701` | 2 | source-centered EMA S3D global | 0.02 | 0.02 | 10000 | running |
| `pilot_a21_srcctr_adv005_seed5301_gpu3_20260701` | 3 | source-centered EMA S3D global | 0.05 | 0.02 | 10000 | running |

Early health:

| Run | Step | Loss | Cos raw | Cos target | Source acc | Sources seen |
|---|---:|---:|---:|---:|---:|---:|
| A21 adv 0.02 | 101 | 4.2369 | 0.6189 | 0.6143 | 0.0625 | 36 |
| A21 adv 0.05 | 51 | 4.3396 | 0.6586 | 0.6618 | 0.0000 | 36 |

Both runs have automatic completion watchers attached via `eval_a20_run_when_done.sh`, using tags:

- `a21_srcctr_adv002_step10000`
- `a21_srcctr_adv005_step10000`

The evaluator name is historical, but it is generic for `filtered` global heads and is compatible with A21.

## Remaining Risks

- A21 is still a frozen-adapter gate, not full JEPA pretraining. A positive result supports promoting the target into the main objective; a negative result does not disprove all source-centered JEPA designs.
- Source centering may remove cohort/site offsets but could also remove genuine between-cohort biological variation. The external A4 age gate is therefore decisive.
- Current centroid estimates are based on online random crops. If A21 is promising but noisy, a deterministic precomputed centroid table should replace the online EMA before any full-scale run.

## Decision Rule

Promote A21 only if it improves over A20 on external utility while preserving confound suppression:

```text
Promote if:
  A4 scanner/cohort remains close to A20
  and A4 age r / Task1 utility improves materially over A20

Reject if:
  A4 age r remains near zero or negative
  or Task1/protocol utility collapses
```
