# Review Pass 27 — A20 Source-Filtered Global Adapter

Date: 2026-07-01 UTC

Reviewed files:

- `Flagship/v2_jepa/code/train_global_filter_head.py`
- `Flagship/v2_jepa/code/eval_external_foundation_probe.py`
- `Flagship/v2_jepa/code/eval_source_probe.py`
- `Flagship/v2_jepa/code/eval_jepa_downstream_probe.py`

## Purpose

A17 external gate showed that the current JEPA morphology branch does not solve the actual external confound problem:

- A10 shared JEPA lowers external shortcut recoverability but loses age/global signal.
- S3D preserves global signal but leaks cohort/source information.
- A17 morphology increases A4 scanner-vendor recoverability.

A20 is therefore implemented as a low-cost frozen-adapter gate:

```text
frozen A10 JEPA global -> source-filtered adapter -> S3D global target
                         + GRL source adversary
                         + variance floor
```

The existing production foundation checkpoint is not modified.

## Verification

Syntax:

```text
python -m py_compile \
  Flagship/v2_jepa/code/train_global_filter_head.py \
  Flagship/v2_jepa/code/eval_external_foundation_probe.py \
  Flagship/v2_jepa/code/eval_source_probe.py \
  Flagship/v2_jepa/code/eval_jepa_downstream_probe.py
```

Smoke training:

```text
train_global_filter_head.py --steps 5 --batch 4 --subset 144 --workers 0
```

Observed:

```text
step=1 loss=5.46811 cos=0.001 rank=2.51
step=5 loss=4.98384 cos=0.471 rank=2.29
```

Smoke eval:

- external gate loaded `--feature_space filtered` from A20 smoke checkpoint.
- source probe loaded `--feature_space filtered` from A20 smoke checkpoint.
- downstream probe loaded `--feature_space filtered` through `.venv-train`, because system Python lacks `yucca`.

## Code Findings

### Cache provenance

`eval_external_foundation_probe.py` already had a cache fingerprint fix from Review Pass 26. A20 extends that fingerprint with:

```text
jepa_ckpt | morphology_head | global_filter_head | ordered record identity
```

This prevents accidentally reusing A17 features for A20, or one A20 head for another.

### Evaluation path

A20 feature spaces added:

```text
filtered
shared_plus_filtered
```

Supported in:

- source probe;
- downstream Task1/3/5 probe;
- external A4/AIBL/AJU gate.

### Scope boundary

This is intentionally not a full JEPA pretraining objective yet. It is a gate. If A20 adapter fails source/downstream/external criteria, there is no reason to pay for a long end-to-end A20 pretraining run.

## Active Runs

```text
pilot_a20_globalfilter_adv005_seed5200_gpu0_20260701
pilot_a20_globalfilter_adv010_seed5201_gpu1_20260701
```

Initial detached launch succeeded with `setsid`; a plain `nohup` launch exited before creating run directories in this environment.

## Verdict

A20 code is ready for pilot completion and gate evaluation.

Promotion criterion:

- recover useful age/global signal over A10 shared;
- keep external cohort/scanner recoverability below S3D and not worse than A17;
- pass source-probe guardrail before any claim of confound robustness.
