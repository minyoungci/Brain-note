# Brain-JEPA Prototype Code

This directory contains code-only Flagship prototypes. It is not connected to
FOMO challenge submission, SIF building, or downstream task optimization.

## Package

```text
Flagship/code/brain_jepa/
├── config.py       # typed pilot config
├── masking.py      # 3D block masks and mask downsampling
├── losses.py       # latent JEPA loss and variance guard
├── diagnostics.py  # collapse diagnostics
└── model.py        # context/EMA-target Brain-JEPA prototype
Flagship/code/analysis/
├── loss_landscape.py       # 2D filter-normalized landscape utilities
└── objective_geometry.py   # gradient cosine, Hessian trace/eigenvalue utilities
```

## Smoke Test

```bash
python Flagship/code/smoke_brain_jepa.py
```

The smoke test performs one synthetic forward/backward/optimizer/EMA step and
checks that the target encoder receives no gradients.

CPU-only check:

```bash
CUDA_VISIBLE_DEVICES='' python Flagship/code/smoke_brain_jepa.py
```

## Unit Tests

```bash
python -m unittest Flagship.code.tests.test_brain_jepa
python -m unittest Flagship.code.tests.test_loss_geometry
```

## Current Scope

Implemented:

- modality-specific stems
- shared ResEnc stages
- context encoder and EMA target encoder
- 3D convolutional JEPA predictor
- voxel block masking with target-mask downsampling
- masked latent prediction loss
- variance/collapse diagnostic helper
- loss landscape utilities
- objective gradient/Hessian geometry utilities

Not implemented yet:

- real MRI dataloader
- multi-view crop sampler
- positional target embeddings
- cross-modal target scheduling
- DDP/AMP training loop
- checkpoint save/resume

Those are deliberately excluded until the prototype passes code review and the
Flagship figure/table story is stable.

## Objective Geometry Smoke

The analysis utilities can evaluate:

- pairwise gradient cosine between objective terms
- Hessian-vector products
- Hutchinson Hessian trace estimate
- top Hessian eigenvalue approximation
- 2D filter-normalized local loss landscape

These are foundation-objective diagnostics. They should be used to compare
S3D, InfoNCE, Brain-JEPA, and future hybrid losses under matched model/data
conditions.
