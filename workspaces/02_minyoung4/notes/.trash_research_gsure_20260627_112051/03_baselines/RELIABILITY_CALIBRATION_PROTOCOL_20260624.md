# Reliability Calibration Protocol - 2026-06-24

## Task

Lock the next no-loss-sweep experiment for G-SURE after the B1A/B1B
segmentation baselines.

## Research Question

Can deployable uncertainty scores predict segmentation failure beyond simple
predicted-volume controls, and how much of the apparent gain depends on
cross-consortium score calibration?

This is a gate for a reliability/calibration benchmark direction. It is not a
segmentation-loss tuning experiment, and it does not by itself establish a new
visual-grounding method.

## Why This Matters

The current B1 evidence shows:

- `dice_focal` is not a robust improvement over `dice_bce`.
- Train-only threshold calibration is more important than the loss variant.
- Predicted volume and probability separation already predict low-Dice failure.
- Raw B1B entropy is informative within MU and UCSD folds, but its pooled scale
  is not reliable across folds.

Therefore, the technical gap is not another global segmentation loss. The first
defensible contribution is a leakage-safe reliability benchmark/calibration
analysis under consortium shift while controlling for predicted volume.

## Hypothesis

Raw entropy contains subject-level failure signal within held-out folds, but
raw scores are not directly comparable across consortia. Train-only scale
calibration should be treated as an evaluation/calibration correction, not as a
new mechanism.

## Unit and Outcome

Unit of analysis:

```text
subject-level selected unit from the official LOCO manifest
```

Primary outcome:

```text
subject_failure_dice_le_0.8 = Dice(predicted whole-tumor mask, GT mask) <= 0.8
```

Primary metric:

```text
AUROC for subject_failure_dice_le_0.8
```

Secondary metrics:

- AUPRC for subject failure.
- Per-consortium AUROC/AUPRC.
- Lesion-size-bin stratified AUROC/AUPRC where class counts allow.
- Calibration curve/ECE for predicted failure probability if a supervised
  calibration model is fitted.

## Split Policy

Outer split:

```text
leave-one-consortium-out (LOCO)
```

Calibration/training rows:

```text
outer-train internal-val predictions only
```

Held-out rows:

```text
outer held-out consortium test predictions only
```

Forbidden:

- fitting thresholds or score calibration on held-out consortium labels,
- selecting features by held-out test AUROC,
- pooling raw scores across folds without a train-only calibration transform,
- treating GT-derived volume or pred/GT mismatch as deployable inputs.

## Eligible Inputs

A row is eligible only if:

- it comes from a validated prediction manifest,
- probability map and target mask pass shape/orientation checks,
- the prediction is full-volume assembled,
- `mask_used_for_tile_placement == 0`,
- threshold was selected from train/internal-val data only,
- target and probability maps are read in the same canonical orientation.

Use `nib.as_closest_canonical()` when recomputing metrics from NIfTI artifacts.

## Locked Baselines

### V0: Predicted-Volume Baseline

Deployable score:

```text
score = -log1p(pred_voxels)
```

Interpretation:

```text
smaller predicted tumor volume => higher failure risk
```

This is the mandatory baseline. A reliability method that does not beat V0 is
not a method contribution.

### U0: Raw Entropy Baseline

Primary raw uncertainty score:

```text
mean_entropy_pred_mask
```

Definition:

```text
entropy(P) = -P*log(P) - (1-P)*log(1-P)
mean_entropy_pred_mask = mean entropy over voxels where P >= threshold
```

Secondary raw uncertainty score:

```text
mean_entropy_all
```

Status:

```text
exploratory unless locked before remaining LOCO folds
```

Rationale:

`mean_entropy_all` performed well in the two-fold probe, but it was not the
primary score and may partly encode foreground extent or output-scale behavior.

### C0: Fold-Calibrated Entropy

Train-only transform:

```text
z_entropy = (entropy_score - median_train_score) / IQR_train_score
```

Fit `median_train_score` and `IQR_train_score` on outer-train internal-val rows
only. Apply the transform unchanged to the held-out fold.

Primary calibrated score:

```text
z_mean_entropy_pred_mask
```

Decision:

```text
C0 must beat V0 on pooled AUROC and not collapse on any held-out consortium.
```

Interpretation rule:

```text
C0 is a monotonic transform within a fold, so fold-level AUROC is identical to
U0. Any pooled improvement means cross-fold entropy scales were misaligned; it
does not prove a new model mechanism.
```

### C1: Supervised Failure-Calibrator

Inputs:

```text
z_mean_entropy_pred_mask
log1p(pred_voxels)
threshold_value
```

Model:

```text
LogisticRegression(class_weight="balanced", C=1.0, solver="liblinear")
```

Training labels:

```text
Dice<=0.8 labels from outer-train internal-val predictions only
```

Evaluation:

```text
held-out consortium test predictions only
```

Required controls:

- same logistic model with `log1p(pred_voxels)` only,
- same logistic model with `z_mean_entropy_pred_mask` only.

Decision:

```text
C1 combined must beat both single-feature controls.
```

This is a subject-level QC/reliability gate in the DeVries/QCResUNet baseline
family, not the full G-SURE voxel grounding method.

## TTA Status

TTA is not part of the current locked gate because no TTA prediction artifacts
exist yet.

TTA can be added only after the C0/C1 gate is evaluated on existing probability
maps. If added, it must satisfy:

- no held-out mask access,
- fixed transform set before inference,
- inverse-transform back to canonical space,
- same LOCO fold and threshold policy,
- comparison against V0, U0, C0, and C1.

## Current Evidence From Two Folds

Corrected canonical run:

```text
research_gsure/03_baselines/outputs/20260624_1035_uncertainty_vs_volume_gate_canonical/
```

Invalid run:

```text
research_gsure/03_baselines/outputs/20260624_1015_uncertainty_vs_volume_gate/
```

Do not use the invalid run. It loaded target masks without canonical orientation.

Two-fold B1B subject-failure AUROC:

| score | pooled AUROC | fold mean AUROC | fold min AUROC |
|---|---:|---:|---:|
| `primary_mean_entropy_pred_mask` | 0.699 | 0.832 | 0.819 |
| `mean_entropy_all` | 0.779 | 0.785 | 0.753 |
| `deployable_neg_pred_volume` | 0.735 | 0.738 | 0.720 |

Interpretation:

- Raw primary entropy fails pooled comparison against predicted volume.
- Fold-wise primary entropy beats predicted volume on both MU and UCSD.
- This supports a calibration-under-shift hypothesis, not a raw-uncertainty
  claim.

## Minimum Evidence Needed To Continue As A Method Direction

Before training any reliability head:

1. Implement a CPU-only C0/C1 evaluator.
2. Run it on B1A and B1B MU/UCSD calibrated predictions.
3. Extend to UPENN and UTSW only after B1 predictions exist for those folds.
4. Report V0, U0, C0, C1, and diagnostic-oracle controls separately.

Go condition:

```text
C0 or C1 beats predicted-volume-only V0 on pooled AUROC/AUPRC,
and does not underperform V0 on more than one held-out consortium.
```

No-go condition:

```text
V0 matches or beats C0/C1 on pooled and per-consortium metrics.
```

If no-go:

- stop reliability-method claims,
- pivot to benchmark/empirical paper framing:
  calibration drift, small-lesion failure, volume baseline strength, and
  leakage-safe LOCO evaluation.

## Negative Controls

Required:

- predicted volume only,
- lesion-size bin only where GT-derived bins are used as diagnostic controls,
- consortium-only diagnostic model,
- GT lesion volume as diagnostic oracle only,
- pred/GT volume mismatch as diagnostic oracle only.

## Reviewer Attack Points

Expected attacks:

- "The reliability model is just a lesion-size detector."
- "Entropy scale differs by site and is not calibrated."
- "The method was tuned on held-out folds."
- "Only two folds were used."
- "Subject-level failure prediction is not visual grounding."

Mitigations:

- V0 must be a required baseline.
- All calibration must be train/internal-val only.
- Report per-consortium metrics, not just pooled metrics.
- Treat MU/UCSD as preliminary until UPENN/UTSW are evaluated.
- Voxel-level ERR/FP/FN localization remains required for the full G-SURE
  grounding claim after this subject-level gate.

## Stop Rule

Stop segmentation loss sweeps now.

Do not start a reliability-head training run unless:

- C0/C1 has been implemented and evaluated CPU-only,
- predicted-volume controls are reported,
- the result shows incremental value beyond V0,
- Min approves the next GPU or long inference step.

## Status After CPU Gate Run - Corrected Interpretation

Run:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/
```

Decision artifact:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_decision.md
```

Two-fold B1B result:

| score | pooled AUROC | pooled AUPRC | delta AUROC vs V0 | 95% CI |
|---|---:|---:|---:|---:|
| V0 predicted volume | 0.735 | 0.671 | - | - |
| C0 z entropy | 0.822 | 0.813 | +0.087 | [0.014, 0.161] |
| C1 entropy+volume | 0.910 | 0.908 | +0.174 | [0.128, 0.223] |

Interpretation:

- B1B shows real subject-level uncertainty signal: raw entropy beats predicted
  volume within both MU and UCSD folds.
- C0 is not a new signal. It is a train-fitted monotonic scale normalization;
  within-fold AUROC equals raw entropy AUROC. Its pooled gain reflects correction
  of cross-fold score-scale mismatch.
- C1 is stronger but remains a subject-level supervised QC calibrator in the
  DeVries/QCResUNet baseline family, not the full visual grounding method.
- Four-consortium evidence is still missing. UPENN and UTSW B1B calibrated
  predictions are required before any four-site method claim.

Current fork recommendation:

```text
Benchmark/calibration paper first. Method paper only if future voxel-level
ERR/FP/FN localization beats QCResUNet-style baselines after UPENN/UTSW are
included.
```
