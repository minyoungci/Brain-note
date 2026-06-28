# Plan E: Loss Landscape and Objective Geometry

## Purpose

This plan is for technical novelty in `Flagship`.

The goal is not to optimize a downstream task. The goal is to make the foundation objective scientifically analyzable:

```text
How do S3D, InfoNCE, and Brain-JEPA objectives shape the optimization landscape,
representation geometry, and collapse behavior of a 3D brain MRI foundation model?
```

## Why This Can Add Novelty

Most medical foundation model papers report downstream metrics. A stronger methods paper can also show:

- whether an objective creates sharper or flatter minima
- whether dense and global objectives produce aligned or conflicting gradients
- whether collapse is visible in representation spectrum before downstream evaluation
- whether latent prediction avoids voxel-reconstruction shortcuts
- whether multimodal latent prediction improves modality-invariant geometry

## Relevant Method Families

Use these as conceptual anchors:

- I-JEPA / V-JEPA: latent target prediction instead of pixel/voxel reconstruction
- VICReg / Barlow Twins: variance/covariance-based collapse control
- DINO / BYOL-style teacher-student learning: EMA target networks
- SAM / sharpness analysis: flatness and robustness of minima
- Loss landscape visualization: filter-normalized 2D directions

## Proposed Technical Variants

### Variant 1: Geometry-Regularized Brain-JEPA

```text
L = L_JEPA_local + w_global L_JEPA_global
    + lambda_var L_variance
    + lambda_cov L_covariance
    + lambda_koleo L_KoLeo
```

Hypothesis:

```text
Latent prediction plus explicit variance/covariance constraints prevents collapse
without requiring negative pairs.
```

### Variant 2: Hybrid JEPA-InfoNCE

```text
L = L_JEPA_local + w_global L_InfoNCE_global + lambda_var L_variance
```

Hypothesis:

```text
Local JEPA preserves dense anatomical structure, while InfoNCE stabilizes global CNN representations.
```

### Variant 3: Dense-Global Gradient Orthogonalization

Instead of claiming generic PCGrad, measure first:

```text
cos(grad_dense, grad_global)
cos(grad_jepa_local, grad_global)
cos(grad_crossmodal, grad_intramodal)
```

Possible intervention:

```text
If conflict is systematic, project only the smaller auxiliary gradient away from the main dense-local gradient.
```

Hypothesis:

```text
The useful novelty is not "always use gradient surgery"; it is identifying when local and global SSL gradients conflict in 3D MRI.
```

### Variant 4: Cross-Modal Latent Alignment Without Synthesis

```text
FLAIR context -> T2/T1 latent target
DWI context   -> ADC latent target
```

Hypothesis:

```text
Predicting latent targets across modalities learns anatomy-invariant representations
without forcing raw intensity synthesis.
```

### Variant 5: Landscape-Aware Checkpoint Selection

Current checkpoint selection uses downstream proxy metrics. Flagship can add foundation-only diagnostics:

```text
effective rank
feature variance
Hessian trace
top Hessian eigenvalue
2D loss landscape anisotropy
gradient cosine matrix
```

Hypothesis:

```text
Stable foundation checkpoints should show non-collapsed representations and lower sharpness under matched loss.
```

## Experiments To Run

### E1: 2D Filter-Normalized Loss Landscape

Compare:

- S3D dense branch
- InfoNCE global branch
- Brain-JEPA local branch
- hybrid JEPA+InfoNCE

Output:

- contour plot
- sharpness around checkpoint
- landscape anisotropy

### E2: Hessian Trace and Top Eigenvalue

Compare objective variants with identical architecture.

Metrics:

- Hutchinson Hessian trace estimate
- top Hessian eigenvalue by power iteration
- gradient norm

### E3: Gradient Interaction Matrix

For each mini-batch:

```text
gradient cosine between objective terms
```

Terms:

- dense reconstruction
- local JEPA
- global InfoNCE
- variance/covariance/KoLeo
- cross-modal JEPA

Output:

- heatmap
- fraction of negative cosine steps
- mean magnitude ratio

### E4: Collapse Geometry

Monitor:

- feature std mean/min
- effective rank
- covariance off-diagonal
- nearest-neighbor concentration
- global vector norm distribution

### E5: Multimodal Latent Geometry

Monitor:

- same-subject cross-modal cosine
- different-subject cross-modal cosine
- modality classification leakage
- CKA between modality-specific stems/stages

## Paper Figures

Potential flagship figures:

1. loss landscape contour: S3D vs JEPA vs hybrid
2. gradient cosine matrix across objectives
3. effective-rank/collapse trajectory
4. Hessian sharpness comparison
5. cross-modal latent alignment plot

## Implementation Location

```text
Flagship/code/analysis/loss_landscape.py
Flagship/code/analysis/objective_geometry.py
Flagship/code/tests/test_loss_geometry.py
```

## Guardrail

Loss landscape analysis is expensive and can be misleading if run casually.

Rules:

- use identical model architecture
- use identical mini-batches
- report scale and direction normalization
- do not compare sharpness across different parameterizations without caveats
- use this as foundation-level evidence, not as a replacement for downstream validation
