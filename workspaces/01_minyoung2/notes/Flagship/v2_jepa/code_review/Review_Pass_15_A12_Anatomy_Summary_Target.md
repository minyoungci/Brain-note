# Review Pass 15: A12 Anatomy-Summary Target

Date: 2026-06-30 UTC

Scope:

```text
Flagship/v2_jepa/code/train_brain_jepa.py
Flagship/v2_jepa/code/tests/test_brain_jepa.py
Flagship/v2_jepa/runs/smoke_a12_anatomy_summary_gpu0/
Flagship/v2_jepa/runs/pilot_a12_s3ddense005_anatsum*_anat_seed*_gpu*_20260630/
```

## Motivation

A11 showed that generic EMA global alignment is not a good fix for weak JEPA brain-age performance:

| Model | Source-probe | Task1 AUROC | Brain-age r | Task5 AUROC |
|---|---:|---:|---:|---:|
| A10 dense `0.05` | 0.0778 | 0.8077 | 0.6085 | 0.8976 |
| A11 dense+align `0.02` | 0.2130 | 0.6827 | 0.6929 | 0.8194 |
| A11 dense+align `0.05` | 0.2481 | 0.2596 | 0.6786 | 0.9062 |

The new A12 hypothesis is:

```text
Do not align global vectors directly.
Instead, make the global vector predict low-frequency anatomy summaries
from the raw target crop.
```

This is meant to preserve age-relevant global morphology and tissue information while avoiding the shortcut-heavy global teacher/alignment paths that failed in A5/A9/A11.

## Implementation Reviewed

Added:

```text
AnatomySummaryPredictor
anatomy_summary_dim
anatomy_summary_target
anatomy_summary_prediction_loss
```

The target vector contains:

- coarse foreground occupancy grid,
- regional foreground intensity mean,
- soft foreground intensity histogram.

For default `grid=4`, `bins=8`, the target dimension is:

```text
2 * 4^3 + 8 = 136
```

The loss is:

```text
SmoothL1(AnatomySummaryPredictor(context_global), anatomy_summary_target(raw_target_crop))
```

The target uses the raw target crop before style augmentation, while the context path still sees independently style-augmented masked input. This makes the target more anatomy-oriented than scanner-style-oriented.

## Code Review Checks

Checked failure modes:

- shape mismatch between predictor output and target vector,
- empty foreground producing NaN histograms,
- missing checkpoint state when resuming with `--anatomy_summary_weight`,
- optimizer missing anatomy-summary head parameters,
- status/checkpoint not logging the new loss,
- old training paths changed when `--anatomy_summary_weight=0`.

The implementation stores `anatomy_summary` in checkpoints and restores it when requested.

## Validation

Commands run:

```bash
python -m py_compile \
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
CUDA_VISIBLE_DEVICES=0 python Flagship/v2_jepa/code/train_brain_jepa.py \
  --out Flagship/v2_jepa/runs/smoke_a12_anatomy_summary_gpu0 \
  --steps 5 --batch 2 --crop 64 --subset 64 \
  --s3d_dense_distill_weight 0.05 \
  --anatomy_summary_weight 0.05 \
  --anatomy_summary_grid 2 \
  --anatomy_summary_bins 5
```

Smoke status:

```text
step=5
s3d_dense_distill_loss=1.7727
anatomy_summary_loss=0.1422
anatomy_summary_weight=0.05
ckpt_step5.pt=True
ERROR=False
```

## Active Pilots

| GPU | Main PID | Run | Anatomy-summary weight | Status |
|---|---:|---|---:|---|
| 0 | 1100364 | `pilot_a12_s3ddense005_anatsum005_anat_seed4200_gpu0_20260630` | 0.05 | running |
| 1 | 1100383 | `pilot_a12_s3ddense005_anatsum010_anat_seed4201_gpu1_20260630` | 0.10 | running |

Initial 1k health:

| Run | Step | Loss | Dense loss | Anatomy loss | Pred rank | ckpt1000 | ERROR |
|---|---:|---:|---:|---:|---:|---|---|
| A12 `anatsum=0.05` | 1061 | 3.7482 | 1.5081 | 0.0243 | 116.31 | true | false |
| A12 `anatsum=0.10` | 1061 | 3.7259 | 1.5509 | 0.0218 | 90.42 | true | false |

## Gate

A12 is only useful if it satisfies both sides:

- source-probe remains `<=0.17`, ideally close to A10 `0.0778`;
- brain-age improves above A10 `0.6085`;
- Task1 and Task5 do not collapse relative to A10.

If A12 fails source-probe like A11, the next direction should use stronger source-held-out objective selection or explicitly source-normalized anatomy targets. If A12 improves brain-age while keeping source-probe low, it becomes the next JEPA candidate.
