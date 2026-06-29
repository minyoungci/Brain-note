## Candidate F: Brain-JEPA 3D Multimodal

Question:

```text
Can the current reconstruction-based dense branch be extended or replaced by a 3D multimodal JEPA objective that predicts latent anatomical targets instead of voxel intensities?
```

Why it matters:

- current S3D branch still uses masked-voxel MSE
- voxel reconstruction may overfit intensity/protocol details
- multimodal MRI may benefit from latent cross-modal prediction instead of raw modality synthesis

Minimal pilot matrix:

| Pilot | Objective | Success Metric | Risk |
|---|---|---|---|
| single-modal local JEPA | context blocks predict EMA target block embeddings | no collapse, decreasing latent loss | local features too coarse |
| dense multi-stage JEPA | predict stage-2/3/4 targets | spatial feature quality | memory cost |
| cross-modal JEPA | modality A context predicts modality B latent target | modality-invariant anatomy | modality collapse |
| JEPA + InfoNCE hybrid | local JEPA + global InfoNCE | global stability | objective conflict |

Paper-ready output:

- architecture diagram
- loss diagram
- collapse diagnostics
- comparison table against S3D+InfoNCE
