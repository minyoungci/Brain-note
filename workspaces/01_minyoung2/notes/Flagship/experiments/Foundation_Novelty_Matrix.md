# Foundation Novelty Matrix

This matrix is for proving technical novelty of the foundation model itself. It is not a downstream challenge optimization plan.

## Claim A: Anti-Leakage Dense Pretraining

Question:

```text
Does the S3D-style re-mask path prevent skip leakage while preserving useful dense decoder pathways?
```

Required evidence:

| Experiment | Metric | Status |
|---|---|---|
| naive skip MAE leakage check | hidden-region leakage / recon shortcut | missing or needs formalization |
| skip-free MAE vs S3D-style | dense feature/decoder diagnostics | partial |
| re-mask anti-leakage unit test | recon difference under hidden-region perturbation | existing note, needs paper-ready figure |
| dense branch feature visualization | feature activation around mask boundaries | missing |

## Claim B: Dense-Global Balance

Question:

```text
Does a balanced dense-global objective produce a better foundation representation than dense-only or global-heavy training?
```

Required evidence:

| Variant | What It Tests | Status |
|---|---|---|
| pure dense | local/dense bias | done, summarize |
| wg0.5 | balanced objective | done, selected |
| full global | global-heavy trade-off | done, summarize |
| no-global | whether dense alone collapses global capability | partial |

Paper-ready output:

- radar plot or Pareto plot
- table with normalized diagnostic metrics

## Claim C: InfoNCE Prevents CNN Global Collapse

Question:

```text
Why was InfoNCE needed instead of DINO/Sinkhorn-style global self-distillation?
```

Required evidence:

| Experiment | Metric | Status |
|---|---|---|
| DINO/Sinkhorn run | prototype occupancy, variance, effective rank | existing notes, needs aggregation |
| InfoNCE run | same diagnostics | existing |
| global vector quality | cls/reg probe or linear diagnostic | existing |

Paper-ready output:

- collapse diagnostic plot
- short table with variance/effective-rank/prototype entropy

## Claim D: ResEnc Is the Correct Backbone for Dense Brain MRI Foundation Learning

Question:

```text
Why not ViT-only?
```

Required evidence:

| Comparison | Metric | Status |
|---|---|---|
| ResEnc vs ViT-iBOT | dense representation usefulness | existing internal evidence |
| ResEnc vs ViT global | regression/global diagnostic | existing mixed evidence |
| qualitative feature locality | activation/attention/feature-map visualization | missing |

Important:

- Do not overclaim that ViT is bad.
- Claim only that ResEnc better matches our dense decoder-transfer goal.

## Claim E: Single Checkpoint, Multiple Representations

Question:

```text
Does the model expose both dense and global representations from one shared checkpoint?
```

Required evidence:

- architecture figure
- extraction paths:
  - encoder stage features
  - decoder/dense features
  - SimPool global vector
- checkpoint structure table

This claim is mostly architectural and should be figure/table driven.

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
