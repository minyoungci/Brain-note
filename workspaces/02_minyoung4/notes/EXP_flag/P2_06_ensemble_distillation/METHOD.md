# P2.06 Tail-Aware Ensemble Distillation

## Purpose

P2.05 showed a real but weak-novelty performance gain from averaging P2.02 and P2.03 checkpoints. P2.06 turns that observation into a single-model training method:

- P2.02 teacher: precision/mean-Dice anchor
- P2.03 teacher: recall/tail-failure anchor
- Student: one compact 3D U-Net at inference, no ensemble and no TTA

## Method

The student is trained with both hard mask supervision and a soft ensemble teacher:

```text
L = lambda_hard * L_hard(mask)
  + lambda_soft * w_size * BCEWithLogits(student, mean(P2.02, P2.03))
```

The soft term is weighted by teacher disagreement, so examples/voxels where the precision teacher and tail teacher diverge receive more transfer pressure. Small-target subjects receive a moderate sample weight.

## Fixed Contract

- Cohort: same valid-seg N=1612 as P2.02/P2.03
- Split: same consortium LOCO split and subject-level validation policy
- Teachers: held-out fold matched P2.02 and P2.03 checkpoints only
- Student input: 4 structural MRI channels
- Inference: single student checkpoint, no teacher, no TTA
- Threshold: validation-only grid, then fixed for held-out test

## Run Settings

```text
student model: compact 3D U-Net base_ch=24
epochs: 50
hard loss: dice_bce
lambda_hard: 1.0
lambda_soft: 0.45
teacher_disagreement_weight: 2.0
distill_size_ref_voxels: 2500
distill_size_weight_exp: 0.30
distill_size_weight_clip: 3.0
thresholds: 0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.85,0.90,0.95
```

## Success Criteria

P2.06 should be judged against P2.02 and P2.05.

- vs P2.02: preserve or improve P2.05's positive mean-Dice delta and low-Dice <=0.8 reduction.
- vs P2.05: close the ensemble gap with a single model.
- UCSD must be reported separately; current evidence shows UCSD transfer is the main unresolved weakness.
