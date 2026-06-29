# Review Pass 4: Loss Landscape / Objective Geometry

Date: 2026-06-28

## Purpose

The user asked whether Flagship can support technically novel experiments around mathematical loss landscape and related objective geometry.

This pass reviews the added analysis utilities:

- `Flagship/v2_jepa/code/analysis/loss_landscape.py`
- `Flagship/v2_jepa/code/analysis/objective_geometry.py`
- `Flagship/v2_jepa/code/tests/test_loss_geometry.py`

## Implemented Capabilities

### Loss Landscape

- filter-normalized random parameter directions
- temporary perturbation with exact restoration
- 2D grid evaluation around a checkpoint
- local sharpness estimate relative to center

### Objective Geometry

- flattened gradients with zero-fill for unused parameters
- gradient cosine matrix between loss terms
- named objective geometry report
- Hessian-vector product
- Hutchinson Hessian trace estimate
- top Hessian eigenvalue approximation

## Critical Review Findings

### Finding 1: Brain-JEPA loss terms were detached in output

Risk:

- gradient geometry analysis would be impossible for `latent_loss` and `variance_loss`.

Fix:

- changed `BrainJEPAOutput.latent_loss` and `variance_loss` to retain gradients.
- smoke/reporting code detaches only when printing values.

### Finding 2: Landscape comparisons can be misleading

Risk:

- sharpness is parameterization-dependent and should not be compared casually across architectures.

Mitigation:

- documented guardrail in `Plan_E_Loss_Landscape_and_Objective_Geometry.md`.
- utilities use filter-normalized directions.
- comparisons must use matched architecture/data/objective scale.

### Finding 3: Hessian utilities are expensive

Risk:

- full-scale use can be slow or memory-heavy.

Mitigation:

- functions are generic but not called in training loop.
- tests use tiny models.
- real runs should sample small parameter subsets or short diagnostic windows.

## Verification

Commands:

```bash
python -m py_compile Flagship/v2_jepa/code/brain_jepa/*.py Flagship/v2_jepa/code/analysis/*.py Flagship/v2_jepa/code/smoke_brain_jepa.py Flagship/v2_jepa/code/tests/test_brain_jepa.py Flagship/v2_jepa/code/tests/test_loss_geometry.py
python -m unittest Flagship.v2_jepa.code.tests.test_brain_jepa Flagship.v2_jepa.code.tests.test_loss_geometry
python Flagship/v2_jepa/code/smoke_brain_jepa.py
```

Results:

```text
py_compile: passed
unittest: Ran 9 tests, OK
CUDA smoke: passed
```

Additional synthetic Brain-JEPA objective geometry smoke:

```text
names=('latent', 'variance')
cosine finite 2x2
norms nonzero
landscape shape=(3,3)
sharpness finite
```

## Verdict

The code now supports foundation-level mathematical diagnostics suitable for a Flagship novelty package.

It is not a proof by itself. The next step is to run these diagnostics on matched S3D, InfoNCE, Brain-JEPA, and hybrid pilot checkpoints.
