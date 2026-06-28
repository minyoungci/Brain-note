# Review Pass 2: Shape / Gradient / EMA Review

Date: 2026-06-28

## Checks

### Unit Tests

Command:

```bash
python -m unittest Flagship.code.tests.test_brain_jepa
```

Result:

```text
Ran 5 tests
OK
```

Covered:

- block mask shape and approximate ratio
- visible + target mask complementarity
- target mask downsampling to feature grid
- forward/backward finite loss
- context encoder receives gradients
- predictor receives gradients
- EMA target encoder receives no gradients
- masked latent loss rejects empty masks
- feature statistics return collapse diagnostics
- invalid target stage is rejected

### CUDA Smoke

Command:

```bash
python Flagship/code/smoke_brain_jepa.py
```

Result:

```text
device: cuda
pred_shape:   [2, 32, 8, 8, 8]
target_shape: [2, 32, 8, 8, 8]
mask_shape:   [2, 1, 8, 8, 8]
target_has_grad: false
grad_norm: > 0
loss: finite
```

### CPU Smoke

Command:

```bash
CUDA_VISIBLE_DEVICES='' python Flagship/code/smoke_brain_jepa.py
```

Result:

```text
device: cpu
pred_shape:   [2, 32, 8, 8, 8]
target_shape: [2, 32, 8, 8, 8]
mask_shape:   [2, 1, 8, 8, 8]
target_has_grad: false
grad_norm: > 0
loss: finite
```

## Parameter Sanity

Synthetic pilot config:

```text
context_encoder: 60864 params
target_encoder:  60864 params
predictor:        8352 params
target_trainable: 0 params
```

Interpretation:

- the target encoder is correctly frozen and updated only through EMA.
- the pilot is small enough for rapid code-level tests.

## Residual Risks

- no real dataloader yet
- no multi-view crop sampler yet
- no positional target embedding yet
- no distributed/mixed-precision training loop yet

These are acceptable because the user requested code-only build and rigorous code review, not full training.
