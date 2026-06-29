# Project Brief

## Working Titles

1. **A Dense-Global 3D Brain MRI Foundation Model with Anti-Leakage Dense Pretraining**
2. **Anti-Leakage Dense Pretraining and Contrastive Global Learning for Single-Checkpoint Brain MRI Transfer**
3. **S3D-Style Dense Reconstruction and InfoNCE Global Learning for 3D Brain MRI Foundation Models**

## Problem

3D brain MRI foundation pretraining has several technical failure modes:

- masked reconstruction with U-Net skips can leak hidden voxel information
- skip-free reconstruction can remove the very dense pathways needed for segmentation-style representation
- CNN global self-distillation can collapse without contrastive negatives
- dense and global objectives can compete for capacity if not balanced

The target scientific question is whether our architecture solves these foundation-level problems in a single checkpoint.

Downstream task performance can support the story later, but it is not the organizing principle of `Flagship`.

## Model

Current selected foundation model:

```text
ResEnc backbone
+ S3D-style dense masked-conv MAE branch
+ InfoNCE global contrastive branch
+ KoLeo regularization
= single SSL checkpoint
```

Key design choices:

- ResEnc instead of ViT because segmentation transfer needs dense spatial inductive bias.
- S3D-style re-mask/submanifold approximation to allow skip connections without masked-region leakage.
- InfoNCE-global to prevent CNN global representation collapse observed with DINO/Sinkhorn-style global objectives.
- `wg0.5` chosen as the local-global compromise.

## Current Evidence Sources

Source summaries:

- `experiments/phase_b/downstream_all/SUMMARY.md`
- `experiments/phase_b/downstream_runs/COMPARISON.md`
- `experiments/phase_b/resenc_s3d_full/pipeline_explanation_ko.md`

Current internal downstream summary:

```text
Task1 infarct cls: pretrained AUROC 0.942 vs scratch 0.596
Task3 brain age:   pretrained r 0.947 vs scratch 0.910
Task4 trigeminal:  pretrained Dice 0.413 / NSD 0.786 vs scratch 0.164 / 0.344
Task5 polymicro:   pretrained AUROC 0.986 vs scratch 0.997
Task6 embedding:   frozen AUROC 0.817
Task2 meningioma:  weak; best known Dice around 0.159 after high-recall tuning
```

Important caveat:

These downstream results are not the primary Flagship artifact. They are secondary evidence and should not drive the figure/table package.

## Core Claim Candidates

### Claim 1: Architecture

S3D-style anti-leakage dense pretraining restores decoder/skip transfer that skip-free MAE loses.

Required evidence:

- skip-free MAE vs S3D-style dense
- dense-only vs global-only vs wg0.5
- leakage test / reconstruction sanity
- segmentation transfer under matched protocols

### Claim 2: Dense-Global Balance

The best single checkpoint is not pure dense or pure global; it is the balanced dense-global checkpoint.

Required evidence:

- pure / wg0.5 / full comparison across segmentation, cls, reg, embedding
- show trade-off, not only winner

### Claim 3: Fine-Tuning Protocol

In few-shot segmentation, full fine-tuning can erase the foundation prior; frozen or low-LR encoder protocols may be required.

Required evidence:

- Task2 R4 frozen/low-LR experiments
- pretrained vs scratch under identical protocols
- per-case failure analysis

### Claim 4: Single-Checkpoint Foundation Design

The model exposes dense and global representations from the same shared ResEnc checkpoint.

Required evidence:

- architecture figure
- checkpoint/module table
- representation extraction paths
- dense/global branch diagnostics

## Current Publication Readiness

Foundation methods paper:

- Feasible if the figure/table packet clearly proves the anti-leakage, collapse-prevention, and dense-global balance claims.

Medical AI / imaging conference:

- Feasible if ablation story is clean and downstream support is used only as validation.

Top general AI conference:

- Requires stronger novelty, larger-scale comparison, and more complete theoretical/empirical framing.
