# ViT ROI→Image Distillation v1 Comparison

Run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_vit_v1_20260521T104956Z
```

## What changed from CNN distill v0

```text
Student: small 3D ViT, patch size 8x8x8, embed_dim 128, depth 4, heads 4
Norm: GroupNorm patch stem + Transformer LayerNorm; no BatchNorm3d
Checkpoint: best validation loss restored before final/probe
Loss:
  SmoothL1 ROI z
  + 0.2 ROI vector correlation loss
  + 0.25 class-weighted ROI status CE
  + 0.5 RKD distance loss between image embedding and ROI z-vector geometry
```

Diagnosis labels were not used in distillation loss; they were used only for frozen logistic probe.

## ROI teacher imitation

Internal test:

```text
CNN distill v0:
  roi_z_mae           = 1.4075
  roi_z_rmse          = 1.6665
  status_accuracy     = 0.2086
  status_macro_f1     = 0.1992

ViT distill v1:
  roi_z_mae           = 0.7323
  roi_z_rmse          = 0.9477
  status_accuracy     = 0.4833
  status_macro_f1     = 0.4546
```

Observation: ViT+new loss is much more stable for ROI teacher imitation than the prior CNN last-epoch evaluation.

## Frozen CN/MCI/AD linear probe: internal_test

```text
Image-only tiny CNN seed mean:
  balanced_accuracy = 0.4028
  macro_f1          = 0.3429
  CN/MCI/AD recall  = 0.0750 / 0.6542 / 0.4792

CNN ROI-distill v0:
  balanced_accuracy = 0.4458
  macro_f1          = 0.4432
  CN/MCI/AD recall  = 0.4000 / 0.3625 / 0.5750
  confusion          = [[32, 29, 19], [28, 29, 23], [17, 17, 46]]

ViT ROI-distill v1:
  balanced_accuracy = 0.3917
  macro_f1          = 0.3913
  CN/MCI/AD recall  = 0.4875 / 0.3625 / 0.3250
  confusion          = [[39, 28, 13], [37, 29, 14], [19, 35, 26]]
```

## Interpretation

ViT+GroupNorm+SmoothL1+Corr+RKD improved ROI teacher imitation stability, but did **not** improve downstream CN/MCI/AD frozen-probe performance in this first controlled run.

Compared with CNN ROI-distill v0:

```text
balanced_accuracy: 0.4458 -> 0.3917  Δ=-0.0542
macro_f1:          0.4432 -> 0.3913  Δ=-0.0519
CN recall:         0.4000 -> 0.4875  Δ=+0.0875
MCI recall:        0.3625 -> 0.3625  Δ=+0.0000
AD recall:         0.5750 -> 0.3250  Δ=-0.2500
```

Main conclusion:

```text
The proposed ViT/loss package improves anatomical ROI imitation metrics,
but the resulting frozen embedding is not yet better for diagnosis probing.
This suggests ROI imitation alone is not sufficient; the representation may be
learning ROI targets without organizing the diagnosis-relevant latent space well.
```

## Recommended next steps

1. Do not discard ViT: keep it as ROI-imitation-stable branch.
2. Add a low-weight diagnosis-free but class-probe-friendly objective, e.g. ROI-similarity contrastive with larger batch or memory bank.
3. Add ROI-only teacher embedding projection alignment: predict a learned ROI-teacher embedding, not only 16 z/status heads.
4. Run CNN with the same improved losses/GroupNorm to isolate whether the drop is architecture vs loss.
5. Run 3 seeds only after choosing between:
   - CNN+GroupNorm+new losses
   - ViT+new losses
   - hybrid Conv stem + Transformer blocks
