# Review Pass 1: Static/API Review

Date: 2026-06-28

## Scope

Reviewed files:

- `Flagship/code/brain_jepa/config.py`
- `Flagship/code/brain_jepa/masking.py`
- `Flagship/code/brain_jepa/losses.py`
- `Flagship/code/brain_jepa/model.py`
- `Flagship/code/smoke_brain_jepa.py`
- `Flagship/code/tests/test_brain_jepa.py`

## Findings

### Finding 1: `target_stage` range was not validated

Risk:

- invalid positive or negative stage index could fail later inside model construction or silently select the wrong feature scale.

Fix:

- added explicit range validation in `BrainJEPAConfig.__post_init__`.
- added unit test `test_config_rejects_invalid_target_stage`.

### Finding 2: modality fusion used sorted input keys

Risk:

- mean fusion is order-invariant today, but future non-commutative fusion or modality embeddings would become inconsistent with config order.

Fix:

- changed fusion order to follow `cfg.modalities`, using only available modalities.

### Finding 3: variance guard default was too weak

Risk:

- `min_feature_std=1e-4` was effectively inactive because std uses an epsilon floor.

Fix:

- changed default `min_feature_std` to `0.1`.
- kept `variance_weight=0.0` by default so this is a diagnostic unless explicitly enabled.

## Commands

```bash
python -m py_compile Flagship/code/brain_jepa/*.py Flagship/code/smoke_brain_jepa.py Flagship/code/tests/test_brain_jepa.py
```

Result: passed.
