# Figure Plan

The figures in `Flagship` should explain the foundation model itself. They should not be organized around FOMO downstream task performance.

## Figure 1: Foundation Model Overview

Purpose:

- Show the single-checkpoint architecture.
- Make clear that one shared ResEnc backbone feeds both dense and global branches.

Panels:

1. input 3D brain MRI crop
2. 3D block masking
3. shared ResEnc encoder
4. Branch A: S3D-style dense masked-conv MAE
5. Branch B: InfoNCE global contrastive path
6. total loss
7. single checkpoint output

Message:

```text
The model is designed as a foundation representation, not as a downstream task-specific network.
```

Existing asset:

```text
experiments/phase_b/resenc_s3d_full/pipeline.png
docs/figures/arch_resenc_s3d_infonce.png
```

## Figure 2: Anti-Leakage S3D Dense Branch

Purpose:

- Explain why ordinary skip-connected MAE leaks masked information.
- Explain why skip-free MAE harms decoder transfer.
- Explain how re-mask/submanifold-style dense approximation keeps skips usable without leakage.

Panels:

1. naive skip MAE: masked input but clean skip leakage
2. skip-free MAE: no leakage but no high-resolution decoder transfer
3. proposed re-mask branch: skip enabled, hidden voxels zeroed after each stage
4. leakage verification result

Evidence needed:

- anti-leakage reconstruction sanity result
- masked-region information cannot pass via skip features

## Figure 3: Dense-Global Objective Balance

Purpose:

- Show why dense-only and global-only are insufficient.
- Show the `wg0.5` balanced checkpoint conceptually.

Panels:

1. dense-only representation: spatially useful but global weak
2. global-only representation: better cls/reg but can weaken dense transfer
3. balanced branch: shared backbone with weighted losses
4. schematic Pareto trade-off

Evidence needed:

- pure / wg0.5 / full comparison table or plot
- metrics should be described as representation diagnostics, not challenge optimization

## Figure 4: CNN Global Collapse and InfoNCE Fix

Purpose:

- Present the global branch novelty.
- Explain why DINO/Sinkhorn collapsed and InfoNCE did not.

Panels:

1. DINO/Sinkhorn uniform/collapsed prototype behavior
2. InfoNCE in-batch negatives
3. representation variance/effective rank over training
4. global metric improvement summary

Evidence needed:

- projection variance or entropy
- effective rank
- nearest-neighbor distribution or prototype occupancy
- internal global evaluation result if needed

## Figure 5: Pretraining Diagnostics Dashboard

Purpose:

- Show that the model is technically well-behaved during pretraining.

Panels:

1. dense loss curve
2. global loss curve
3. KoLeo / representation spread
4. gradient/objective interaction if available
5. leakage test value

Message:

```text
The architecture is not only a combination of modules; it addresses concrete failure modes observed during development.
```

## Figure 6: Optional External Validation Overview

Use only later.

Purpose:

- Secondary support that foundation features transfer.

Important:

- This should not become Figure 1.
- External downstream results support the foundation story but do not define it.

## Figure 7: Brain-JEPA 3D Multimodal Candidate

Use for the next Flagship foundation-model direction.

Purpose:

- Show how the current S3D+InfoNCE model could be extended or replaced by a JEPA-style latent predictive objective.
- Make the difference between voxel reconstruction and latent prediction visually clear.

Panels:

1. multimodal 3D MRI inputs with modality dropout
2. context encoder receiving visible context blocks/modalities
3. EMA target encoder receiving target blocks/views
4. JEPA predictor with target position and modality embeddings
5. local dense target loss and global target loss
6. anti-collapse diagnostics: variance/effective rank/KoLeo

Message:

```text
Brain-JEPA predicts anatomical latent targets across 3D spatial views and MRI contrasts, instead of reconstructing raw voxel intensities.
```

Relationship to current model:

```text
S3D+InfoNCE = current selected foundation model
Brain-JEPA = next Flagship candidate to test stronger representation-level pretraining
```
