# Uncertainty and QC Baseline Requirements

## Scope

This document defines the required uncertainty and quality-control baselines for
G-SURE after a first segmentation model produces valid full-volume OOF
predictions.

This document does not approve:

- official split creation,
- GPU training,
- inference,
- prediction generation,
- reliability label generation.

## Research Goal Reminder

G-SURE must demonstrate reliability/error localization beyond standard
uncertainty and segmentation QC. Otherwise the contribution is not a method
paper.

## Required Inputs

Every uncertainty/QC baseline starts from validated OOF segmentation artifacts:

```text
P = full-volume probability map
B = binary prediction from pre-declared threshold
GT = selected_mask > 0, used for metric/label generation only
X = 4-channel MRI in canonical full-volume space
```

Eligibility:

- prediction manifest validator passes,
- prediction artifact validator passes,
- `full_volume_assembled == 1`,
- `mask_used_for_tile_placement == 0`,
- prediction row is held-out/test for its LOCO fold.

Leakage-safe QC training labels are scheduled in:

```text
research_gsure/01_protocol/INNER_OOF_QC_LABEL_SCHEDULE_DRAFT.md
```

## Required Baseline Families

### U0: Probability-Derived Confidence / Entropy

Purpose:

- measure how much reliability is already captured by the segmentation
  probability map.

Inputs:

- `P`.

Required maps:

```text
confidence = abs(P - 0.5) * 2
uncertainty = 1 - confidence
entropy = -P*log(P) - (1-P)*log(1-P)
```

Required reports:

- voxel-level ERR AUROC/AUPRC,
- FP and FN localization AUROC/AUPRC separately,
- top-k error capture,
- uncertainty-error calibration curve.

### U1: Test-Time Augmentation Uncertainty

Purpose:

- standard epistemic/aleatoric proxy without a second trainable QC model.

Inputs:

- multiple full-volume predictions after approved test-time augmentations.

Required maps:

- mean probability,
- variance,
- vote disagreement,
- entropy of mean probability.

Guardrails:

- TTA transforms must be image-only and invertible back to canonical space.
- No held-out masks may be used for tile placement, transform selection, or
  threshold tuning.

### U2: Ensemble / Repeated-Seed Disagreement

Purpose:

- strong uncertainty baseline when compute allows.

Inputs:

- validated OOF predictions from multiple independently trained segmentation
  models or seeds.

Required maps:

- ensemble mean probability,
- variance/disagreement,
- pairwise mask disagreement summary.

Guardrails:

- each ensemble member must obey the same official split and artifact contract,
- ensemble selection may not use held-out test Dice.

### Q1: DeVries-Style Subject-Level Quality Predictor

Purpose:

- test whether subject-level segmentation failure is already predictable from
  standard image/prediction/uncertainty inputs.

Inputs:

- `X`,
- `P` or `B`,
- one or more uncertainty maps from U0/U1/U2.

Outputs:

- predicted subject-level quality score,
- predicted failure probability for `Dice <= 0.8`.

Training labels:

- Dice/quality labels generated from train-consortia inner-OOF predictions, or
  another explicitly approved train-only protocol.

Forbidden:

- training Q1 on outer held-out consortium labels,
- training Q1 on in-sample predictions from the segmentation model's own
  training rows,
- choosing the low-Dice threshold after held-out inspection.

Metrics:

- MAE for Dice prediction,
- Pearson/Spearman correlation with true Dice,
- AUROC/AUPRC for `Dice <= 0.8`,
- per-consortium calibration.

### Q2: QCResUNet-Style Subject-Level QC + Voxel Error-Map Predictor

Purpose:

- direct baseline for the strongest prior-work threat.

Inputs:

- `X`,
- `P` or `B`,
- optional uncertainty maps.

Outputs:

- subject-level predicted Dice or quality,
- voxel-level predicted error probability map,
- optional FP/FN-specific error maps if implemented.

Training labels:

- voxel error maps and subject quality labels generated from train-consortia
  inner-OOF predictions.

Required evaluation:

- subject-level Dice prediction MAE/correlation,
- `Dice <= 0.8` detection AUROC/AUPRC,
- voxel-level ERR AUROC/AUPRC,
- FP and FN localization AUROC/AUPRC,
- error-map Dice at a train-chosen threshold if thresholded maps are reported,
- per-consortium and lesion-size-stratified metrics.

Guardrails:

- A QCResUNet-style baseline must not be trained only on synthetic corruptions
  unless that limitation is explicitly reported.
- Real OOF baseline errors are preferred because QCResUNet reviewers identified
  synthetic/generated errors as a potential clinical-validity weakness.

### Q3: Reliability Head Without Grounding Constraint

Purpose:

- test whether an extra head alone explains any G-SURE gain.

Inputs:

- segmentation backbone features,
- OOF reliability/error labels for eligible training rows.

Outputs:

- segmentation probability map,
- reliability/error map.

Required comparison:

- Q3 versus Q2 and G-SURE on the same OOF-derived targets.

## QU-BraTS-Style Uncertainty Evaluation Adaptation

For the first binary whole-lesion task, use one uncertainty map associated with
`selected_mask > 0`.

Required curve family:

1. sweep uncertainty thresholds,
2. filter out voxels above the uncertainty threshold,
3. compute Dice on remaining voxels,
4. compute filtered true-positive ratio,
5. compute filtered true-negative ratio,
6. summarize area under the curves.

Purpose:

- reward uncertainty on wrong voxels,
- penalize marking too much correct tissue as uncertain.

This is a reliability metric, not a segmentation accuracy replacement.

## Reporting Minimum

Metric definitions are locked in:

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
```

For every method that emits an uncertainty or reliability map:

- Dice and Dice failure rate from the underlying segmentation,
- voxel ERR AUROC/AUPRC,
- voxel FP AUROC/AUPRC,
- voxel FN AUROC/AUPRC,
- top-k error capture,
- reliability-error calibration,
- QU-BraTS-style uncertainty filtering curve,
- subject-level failure AUROC/AUPRC,
- per-consortium metrics,
- lesion-size-stratified metrics.

## Implementation Order After Official Split

1. Train B1 segmentation baseline after GPU approval.
2. Write full-volume OOF predictions.
3. Validate prediction metadata and artifacts.
4. Generate first reliability/error labels.
5. Compute B0 predicted-volume, simple morphology, and image-difficulty proxy
   controls.
6. Compute U0 probability-derived uncertainty.
7. Add U1 TTA uncertainty if feasible.
8. Add U2 ensemble/repeated-seed disagreement if compute allows.
9. Train Q1 subject-level quality predictor using leakage-safe labels.
10. Train Q2 QCResUNet-style error-map predictor using leakage-safe labels.
11. Train Q3 reliability head.
12. Only then evaluate whether G-SURE has a real method gap.

## Stop Rules

Stop or pivot away from method work if:

- B1 segmentation is degenerate on any held-out consortium,
- U0/U1/U2 already localize errors well enough that G-SURE adds no value,
- Q1/Q2 solve the subject-level and voxel-level reliability tasks,
- reliability maps mostly track lesion size or boundary distance only,
- reliability or QC performance is already explained by predicted volume or
  image-difficulty proxies,
- QC training would require leakage-prone labels,
- full-volume OOF prediction artifacts cannot be validated.
