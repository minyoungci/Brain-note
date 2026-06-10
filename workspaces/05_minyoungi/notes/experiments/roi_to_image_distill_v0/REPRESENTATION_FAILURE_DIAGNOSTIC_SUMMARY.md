# Representation Learning Failure Diagnostic Summary

Generated: 2026-05-21

## Question

Why is current 3D MRI representation learning not translating into stronger CN/MCI/AD frozen-probe performance?

## Immediate diagnostic: ROI teacher ceiling on the same sampled rows

Artifact:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_FAILURE_DIAGNOSTIC_ROI_CEILING.json
```

Same rows as ViT v1 controlled run:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/runs/roi_to_image_distill_vit_v1_20260521T104956Z/sampled_rows.csv
```

### ROI z-only logistic probe, internal_test

```text
balanced_accuracy = 0.5292
macro_f1          = 0.5255
CN recall         = 0.5875
MCI recall        = 0.3250
AD recall         = 0.6750
confusion         = [[47,28,5],[37,26,17],[14,12,54]]
```

### ROI status one-hot probe, internal_test

```text
balanced_accuracy = 0.5167
macro_f1          = 0.5127
CN recall         = 0.6500
MCI recall        = 0.3000
AD recall         = 0.6000
```

### ViT frozen embedding probe, internal_test

```text
balanced_accuracy = 0.3917
macro_f1          = 0.3913
CN recall         = 0.4875
MCI recall        = 0.3625
AD recall         = 0.3250
```

## Interpretation

The ROI teacher itself contains a moderate CN/AD diagnosis signal on the identical rows. The ViT student learned ROI imitation metrics better than prior CNN v0, but its embedding did not preserve the teacher's diagnosis-relevant geometry.

Therefore the current bottleneck is not simply "ROI teacher has no signal". More likely:

1. Student embedding/head mismatch: ROI heads can predict targets while CLS embedding is not organized for diagnosis.
2. Loss focuses on target prediction, not linear-separable embedding geometry.
3. 16 ROI targets are incomplete/too compressed for MCI; ROI teacher ceiling itself has low MCI recall.
4. Architecture/data regime issue: small ViT may overfit train embedding geometry and generalize poorly.
5. Cohort/age confounding and MCI heterogeneity remain untested for the new runs.

## Next diagnostic experiments

1. Freeze image encoder and train probe on both CLS embedding and predicted ROI z/status heads. If predicted ROI heads perform like ROI teacher but CLS does not, the problem is embedding-head decoupling.
2. Run CNN+GroupNorm+SmoothL1+Corr+weighted CE+RKD to isolate architecture vs loss.
3. Add teacher embedding alignment: train ROI-teacher MLP then align image embedding to teacher latent, not only ROI z/status outputs.
4. Add per-ROI correlation and predicted-vs-true ROI scatter to identify which ROIs are learned.
5. Run cohort/age-bin audits on the frozen probe predictions.
