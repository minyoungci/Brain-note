# Review Pass 18: A13 Final Decision

Date: 2026-07-01 UTC

Scope:

```text
Flagship/v2_jepa/code/train_anatomy_head.py
Flagship/v2_jepa/code/eval_source_probe.py
Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
Flagship/v2_jepa/runs/pilot_a13_frozen_a10_anathead_g4b8_seed4300_gpu0_20260701/
Flagship/v2_jepa/results/source_probe/a13_step1000_*.json
Flagship/v2_jepa/results/downstream_probe/a13_step1000_*.json
```

## Pre-Run Validation

Compile and unit tests passed before launch:

```bash
python -m py_compile \
  Flagship/v2_jepa/code/train_anatomy_head.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py \
  Flagship/v2_jepa/code/train_brain_jepa.py

python Flagship/v2_jepa/code/tests/test_brain_jepa.py
```

Result:

```text
Ran 14 tests
OK
```

The run used the audited A10 base checkpoint:

```text
Flagship/v2_jepa/runs/pilot_a10_s3ddense005_a2main_anat_seed4001_gpu1_20260630/ckpt_step20000.pt
```

## Training Health

A13 was launched as a head-only run:

```text
freeze A10 JEPA encoder
train AnatomySummaryPredictor only
grid=4, bins=8, hidden=512
```

The run produced checkpoints:

```text
ckpt_step1000.pt
ckpt_step2000.pt
ckpt_step3000.pt
latest.pt
```

It was stopped early after the step1000 evaluation gate failed. Last observed status:

```text
step=4641
loss=0.0152
best_loss=0.0109
effective_rank=6.73
std_mean=0.0123
```

No `ERROR.json` was observed. The early stop was a decision stop, not a crash.

## Source Gate

The step1000 head passed source robustness:

| Feature | Source-probe acc | Gate |
|---|---:|---|
| `anatsum` | 0.0722 | pass |
| `shared_plus_anatsum` | 0.0852 | pass |

This confirms that the frozen-head design does not re-open the A11/A9-style source shortcut.

## Downstream Gate

The same step1000 head failed the replacement gate:

| Feature | Task1 AUROC | Task3 brain-age Pearson | Task5 AUROC |
|---|---:|---:|---:|
| `anatsum` | 0.5096 | 0.4885 | 0.7031 |
| `shared_plus_anatsum` | 0.7212 | 0.5846 | 0.8837 |
| A10 reference | 0.8077 | 0.6085 | 0.8976 |
| S3D wg0.5 reference | 0.7212 | 0.7924 | 0.9566 |

`shared_plus_anatsum` preserves source robustness and avoids the severe A12 Task5 collapse, but it does not improve brain-age and it lowers Task1 relative to A10.

## Verdict

Reject A13 as a foundation candidate.

The result is still informative:

- A12's failure was not only caused by backpropagating into the shared encoder.
- A separate anatomy-summary head can be source-safe.
- The low-frequency anatomy-summary target is too weak/coarse to recover robust global biology.

Next JEPA architecture work should not continue this exact target. The next valid structural direction must use richer anatomical supervision, such as atlas/tissue/ROI context targets, or source-held-out validation that selects representations by generalization rather than by source adversarial training alone.
