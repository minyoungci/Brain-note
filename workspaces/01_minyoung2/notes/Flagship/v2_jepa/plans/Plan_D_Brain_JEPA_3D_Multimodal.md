# Plan D: Brain-JEPA 3D Multimodal Foundation Model

## Purpose

This plan is a `Flagship` foundation-model candidate, independent of FOMO downstream submission work.

The goal is to test whether the current `ResEnc + S3D dense reconstruction + InfoNCE global` design can be extended or replaced by a JEPA-style latent predictive objective for 3D multimodal brain MRI.

## Short Answer

Yes, this is technically feasible and scientifically interesting.

But it should be treated as a **new foundation pretraining direction**, not as a small patch to the current checkpoint.

Current model:

```text
masked voxel input -> ResEnc -> dense decoder reconstructs masked voxels
                         -> SimPool/global InfoNCE
```

Brain-JEPA model:

```text
context views/modalities -> context encoder -> predictor -> latent target embeddings
full/target views        -> EMA target encoder -> target embeddings
loss = latent prediction loss, not voxel reconstruction loss
```

The key shift is:

```text
from predicting intensities
        to predicting anatomical/semantic latent representations
```

## Why JEPA Fits Flagship

JEPA is a foundation-level idea. It directly changes the pretraining principle, so it belongs in `Flagship`, not `Challenge_Submission`.

It can strengthen technical novelty because it addresses a weakness of reconstruction-based SSL:

- voxel MSE may overemphasize low-level intensity and texture
- MRI modality intensity varies strongly by scanner/protocol
- reconstructing one modality from another may encourage contrast synthesis rather than semantic anatomy
- latent prediction can focus on anatomy/structure instead of exact voxel values

## Existing Research Context

Relevant references:

- I-JEPA: predicts target block representations from context block representations, without reconstructing pixels.
- V-JEPA: extends the same idea to video/temporal visual representation learning.
- Recent medical imaging work has started comparing MAE-style reconstruction and JEPA-style predictive representation learning for MRI disease detection.

Interpretation for us:

```text
JEPA is not brand-new as a general SSL idea, but 3D multimodal brain MRI JEPA with dense-local and global anatomical targets can still be a strong Flagship direction.
```

## Proposed Architecture: Brain-JEPA 3D Multimodal

### Components

```text
Input:
  3D brain MRI volumes, potentially multiple modalities
  examples: T1, T2, FLAIR, DWI, ADC, SWI/T2*

Context encoder:
  ResEnc backbone, initialized from scratch or current wg0.5
  sees visible 3D context blocks and selected modalities

Target encoder:
  EMA copy of context encoder
  sees target blocks/views, usually less corrupted or full target region
  stop-gradient target embeddings

Predictor:
  lightweight 3D feature predictor
  maps context features + positional/modality tokens -> target latent embeddings

Loss:
  latent prediction loss between predicted target embedding and EMA target embedding
  optional variance/covariance/KoLeo/InfoNCE term to avoid collapse
```

### Suggested Diagram

```text
                          ┌──────────────────────────────┐
        context view(s) -> │ context ResEnc encoder       │
        masked blocks      │ visible anatomy + modality   │
                          └──────────────┬───────────────┘
                                         │ context tokens/features
                                         v
                          ┌──────────────────────────────┐
                          │ 3D JEPA predictor            │
                          │ + target position embedding  │
                          │ + modality embedding         │
                          └──────────────┬───────────────┘
                                         │ predicted target latent
                                         v
                              latent JEPA loss
                                         ^
                                         │ stop-grad target latent
                          ┌──────────────┴───────────────┐
        target view(s)  -> │ EMA target ResEnc encoder    │
        target blocks      │ no decoder, no voxel recon   │
                          └──────────────────────────────┘
```

## Multimodal Design Options

### Option 1: Modality-Specific Stem + Shared ResEnc

```text
modality-specific Conv3d stem
-> shared ResEnc stages
-> shared latent space
```

Pros:

- parameter efficient
- encourages modality-invariant anatomical representation
- easy to support missing modalities

Cons:

- modality-specific low-level signal may be underfit

Best initial choice.

### Option 2: Shared Stem + Modality Token

```text
single Conv3d stem
+ learned modality embedding
-> shared ResEnc
```

Pros:

- simplest
- closest to current model

Cons:

- may be weak for very different modalities such as DWI/ADC/SWI

### Option 3: Separate Encoders + Late Fusion

```text
modality-specific encoder
-> fusion predictor / shared latent target
```

Pros:

- powerful for multimodal MRI

Cons:

- expensive
- harder to prove single-checkpoint compactness
- higher overfitting/engineering risk

Use later only if Option 1 fails.

## JEPA Task Types

### 1. Intra-Modal Spatial JEPA

Predict latent embeddings of hidden 3D target blocks from visible blocks in the same modality.

```text
FLAIR context -> FLAIR target latent
T1 context    -> T1 target latent
```

This replaces voxel MAE with latent anatomical prediction.

### 2. Cross-Modal JEPA

Predict target latent representation in one modality from context in another modality.

```text
T1 context    -> FLAIR target latent
FLAIR context -> T2 target latent
DWI context   -> ADC target latent
```

Important:

The model predicts **latent embeddings**, not raw target intensities. This avoids turning the task into modality synthesis.

### 3. Multi-View 3D JEPA

Use two or more crops/views of the same subject.

```text
global context crop -> local target blocks
local high-res crop -> global anatomical target
same anatomy at different voxel sizes -> shared latent target
```

This is where the DINO-style multi-view idea can be reused, but the loss is JEPA-style latent prediction.

### 4. Dense-Local + Global JEPA

Predict both:

- local target block embeddings for segmentation-friendly dense representation
- global target embedding for classification/regression-friendly representation

```text
L = L_local_jepa + w_global * L_global_jepa + anti-collapse regularizer
```

## Why This Could Be Stronger Than Current S3D+InfoNCE

Current S3D branch is still reconstruction-based:

```text
masked voxel MSE
```

Brain-JEPA would be representation-based:

```text
predict target latent representation
```

Potential advantages:

1. less intensity/protocol overfitting
2. better semantic/anatomical abstraction
3. natural multimodal learning without raw cross-modal synthesis
4. no need for dense reconstruction head as the main pretraining target
5. can keep dense local targets for segmentation while learning global targets for cls/reg

## Main Risks

### Risk 1: Collapse

JEPA can collapse if the predictor and EMA target are not stabilized.

Mitigation:

- EMA target encoder
- predictor bottleneck
- variance/covariance regularization
- KoLeo
- optional InfoNCE-global retained from current model
- monitor effective rank and feature variance

### Risk 2: Segmentation Locality Loss

Pure global JEPA may learn semantic but spatially coarse features.

Mitigation:

- predict local 3D target block embeddings
- use multi-scale stage targets
- keep high-resolution ResEnc stage features
- evaluate dense feature locality before downstream tasks

### Risk 3: Multimodal Missingness

Clinical MRI modalities are inconsistent.

Mitigation:

- random modality dropout
- modality-specific stem
- missing-modality masks/tokens
- train all single-modality and multi-modality contexts

### Risk 4: Too Large a Search Space

Brain-JEPA can become a major project.

Mitigation:

Start with a small pilot:

```text
single-modality 3D JEPA on T1/FLAIR
crop 96^3
ResEnc same as current
local target blocks from EMA target encoder
compare against current S3D wg0.5 diagnostics
```

## Minimal Pilot

### Pilot A: Single-Modality 3D Brain-JEPA

Goal:

- prove JEPA objective trains stably on our 3D ResEnc backbone.

Setup:

```text
input: one modality/crop
context mask: visible 3D blocks
latent target: EMA target encoder stage-5/block embeddings
loss: cosine or smooth L1 in normalized latent space
regularizer: KoLeo or VICReg-style variance/covariance
```

Success metrics:

- no collapse
- effective rank stable
- feature variance nonzero
- local target prediction loss decreases
- global probe not worse than current dense-only baseline

### Pilot B: Dense-Local JEPA

Goal:

- preserve segmentation-friendly spatial features.

Setup:

```text
predict stage-2/stage-3/stage-4 local targets
not only bottleneck/global targets
```

Success metrics:

- local feature maps remain spatially informative
- no obvious smoothing/collapse

### Pilot C: Multimodal JEPA

Goal:

- learn anatomy-invariant representation across MRI contrasts.

Setup:

```text
context: one modality
latent target: another modality same subject/space
modality dropout
modality-specific stems
```

Success metrics:

- cross-modal latent alignment improves
- modality classifier cannot trivially dominate representation
- downstream-like probes are robust to missing modalities

## Relationship To Current Foundation Model

Brain-JEPA should be framed as either:

### Extension

```text
ResEnc + S3D dense + InfoNCE global + JEPA latent prediction
```

or:

### Replacement

```text
ResEnc + local/global JEPA + anti-collapse regularizer
```

Recommended order:

1. implement JEPA as an additional branch first
2. compare to current S3D+InfoNCE
3. only remove voxel reconstruction if JEPA is stable and better in diagnostics

## Paper Positioning

If successful, Brain-JEPA 3D Multimodal can become a stronger `Flagship` paper than the current S3D+InfoNCE alone.

Potential title:

```text
Brain-JEPA: Multimodal 3D Joint-Embedding Predictive Pretraining for Brain MRI Foundation Models
```

Core novelty:

```text
A dense-local and global JEPA formulation for 3D multimodal brain MRI that predicts anatomical latent targets across spatial views and MRI contrasts.
```

## Immediate Next Step

Do not train full-scale immediately.

First create:

1. architecture figure
2. loss diagram
3. collapse-monitoring diagnostics
4. minimal pilot script plan
5. comparison table against current S3D+InfoNCE
