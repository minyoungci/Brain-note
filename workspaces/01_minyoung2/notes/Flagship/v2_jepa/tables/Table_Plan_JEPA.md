## Table 7: Current S3D+InfoNCE vs Brain-JEPA Candidate

Columns:

```text
Axis | Current S3D+InfoNCE | Brain-JEPA 3D Multimodal | Expected Benefit | Main Risk
```

Rows:

- target type: voxel MSE vs latent target prediction
- dense locality: decoder reconstruction vs local target embeddings
- global representation: InfoNCE vs global JEPA/InfoNCE hybrid
- multimodal learning: input fusion vs cross-modal latent prediction
- collapse control: InfoNCE/KoLeo vs EMA+variance/KoLeo/optional InfoNCE
- paper novelty: anti-leakage dense branch vs 3D multimodal latent predictive learning
