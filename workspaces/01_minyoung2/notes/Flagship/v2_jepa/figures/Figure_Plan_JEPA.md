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
