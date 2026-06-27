# G-SURE Method Sketch

## Method Hypothesis

Segmentation models fail in visually localizable ways. A model trained to
predict both the tumor mask and its likely error regions can provide more useful
and more grounded outputs than a Dice-only model.

## Model Outputs

For input MRI volume `x`, model `f` predicts:

```text
p_seg(x)   = tumor probability map
p_fail(x)  = voxel-level reliability/failure probability map
p_ground(x)= optional evidence/grounding map
```

## Supervision

Segmentation loss:

```text
L_seg = Dice/BCE or Dice/Focal/Tversky variant
```

Reliability loss:

```text
L_rel = BCE/Focal loss against error-region labels
```

Grounding loss candidates:

```text
L_boundary = encourage high reliability near ambiguous tumor boundary
L_bg       = penalize high evidence in irrelevant far-background regions
L_cf       = counterfactual consistency under lesion/background perturbations
```

## Error Labels

Candidate error labels:

```text
FN = GT mask and predicted background
FP = predicted tumor and GT background
Boundary band = dilation(GT) - erosion(GT)
Hard region = FN union FP union ambiguous boundary
```

Important:

- If error labels are used to train a second-stage model, they must be generated
  from out-of-fold baseline predictions, not in-sample predictions.
- Prediction and reliability-label artifacts must follow
  `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`.
- The first reliability-label policy is defined in
  `research_gsure/01_protocol/RELIABILITY_LABEL_POLICY_DRAFT.md`.

## Candidate Training Stages

Stage 0: Data audit.

Stage 1: Train or reuse a plain segmentation baseline.

Stage 2: Generate out-of-fold baseline predictions and error maps.

Stage 3: Train reliability head / G-SURE model.

Stage 4: Evaluate on held-out consortium.

Stage 5: Ablate grounding losses and pseudo-label sources.

## Key Ablations

- segmentation only,
- segmentation + scalar uncertainty,
- segmentation + reliability head,
- reliability head without boundary labels,
- reliability head without counterfactual constraints,
- TTA pseudo-labels versus ensemble pseudo-labels,
- mask allowed at training only versus mask allowed at inference.

## Expected Contribution

The intended contribution is not a new Dice SOTA claim. It is:

- a grounded reliability task for 3D glioma segmentation,
- a model that localizes segmentation uncertainty/error,
- a cross-consortium evaluation protocol beyond Dice,
- evidence that grounding quality matters under domain shift.
