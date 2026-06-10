# F04 Score-Only Meta Three-Zone Decision

Updated: 2026-06-06

## Goal

After primary-preserving overlays failed, we tested whether the existing
image-model score manifold contains enough information for a shallow
validation-trained three-zone decision model.

This is a post-hoc diagnostic, not a new image encoder.

## Input Policy

Predictors:

- fixed 2.5D score;
- primary 3D score;
- original tri-view score;
- style-consistency candidate score;
- DSBN vendor score;
- DSBN vendor-field score;
- BN reset TTA score;
- BN momentum TTA score;
- score uncertainty transforms;
- clipped score logits;
- question ID one-hot indicators.

Forbidden predictors:

- clinical fields;
- scanner/acquisition metadata;
- raw consortium;
- ROI values;
- evidence percentiles;
- AEB features.

Evidence percentiles are used only to define the three-zone target.

## Run

- active run: `results/f04_roi_evidence_encoder/20260606_093026_v6_score_meta_threezone_audit_v2`
- script: `scripts/run_f04_v6_score_meta_threezone_audit.py`
- selected validation GroupKFold C: `0.003`
- validation rows: `2,454`
- AJU test rows: `340`

## AJU Test Result

| model | zone-bacc | uncertain recall | far-negative recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.739 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.676 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.535 | 0.635 | 0.946 |
| score-only meta | 0.665 | 0.660 | 0.739 | 0.596 | 0.938 |

## Bootstrap Versus Primary

| metric | delta point | 95% CI | interpretation |
|---|---:|---:|---|
| zone-bacc | +0.022 | -0.025 to +0.067 | not significant |
| uncertain recall | +0.117 | +0.022 to +0.209 | positive |
| far-negative recall | +0.063 | +0.007 to +0.122 | positive |
| far-positive recall | -0.115 | -0.191 to -0.049 | significantly worse |
| far AUC | -0.010 | -0.024 to +0.001 | not improved |

Transition counts versus primary:

- candidate gain: `28`
- candidate regression: `20`
- net gain: `+8`

## Decision

The score-only meta-classifier does not pass the method gate.

It confirms that existing image-model scores contain some uncertainty
information: uncertain recall improves, and the point estimate of zone-bacc is
higher. However, the improvement is obtained by sacrificing primary
far-positive correctness. The bootstrap CI for zone-bacc crosses zero, and
far-positive recall is significantly worse.

This closes the simple score-level decision-surface direction. The remaining
technical bottleneck is representation or uncertainty estimation that preserves
far-positive evidence while identifying near-boundary uncertainty.

## Case Audit

Follow-up run:

- `results/f04_roi_evidence_encoder/20260606_093621_v6_score_meta_farpos_regression_case_audit_v2`

The post-hoc case audit confirms that this is not a generic file/QC failure.
All selected cases loaded successfully and the generated montage figures are
non-empty.

Key counts:

- rows: `340`
- subjects: `124`
- far-positive regressions versus primary: `13`
- uncertain gains versus primary: `14`
- gains versus fixed 2.5D: `98`
- regressions versus fixed 2.5D: `33`

The far-positive regression pattern is question-specific:

| question | far-positive regressions vs primary | uncertain gains vs primary |
|---|---:|---:|
| low hippocampal volume | 0 | 1 |
| low hippocampus-to-ventricle ratio | 10 | 6 |
| MTL atrophy evidence | 0 | 4 |
| ventricle enlargement | 3 | 3 |

Interpretation:

- Score-meta improves near-cutoff uncertainty recognition, but it over-routes
  true far-positive cases into uncertainty, especially for the
  hippocampus-to-ventricle ratio question.
- A publishable method cannot be a generic score fusion. It must preserve
  ratio far-positive evidence while still recovering uncertain rows.

## Ratio-Preserve Follow-Up

Run:

- `results/f04_roi_evidence_encoder/20260606_094309_v6_score_meta_ratio_preserve_audit`
- script: `scripts/run_f04_v6_score_meta_ratio_preserve_audit.py`

Design:

- Retrain the same validation-only score-meta model.
- Select a primary-score override threshold on non-AJU validation rows only.
- Apply the gate only to `normqa_low_hippocampus_to_ventricle_ratio` rows where
  score-meta predicts uncertain but primary is confidently far-positive.
- Evaluate AJU once.

Selected threshold:

- primary score `>= 0.655610`

AJU result:

| model | zone-bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| score-only meta | 0.665 | 0.660 | 0.596 | 0.938 |
| score-meta ratio-preserve | 0.672 | 0.574 | 0.702 | 0.939 |

Bootstrap versus primary for score-meta ratio-preserve:

- zone-bacc CI `-0.008` to `+0.065`
- uncertain recall CI `-0.057` to `+0.117`
- far-positive recall CI `-0.054` to `+0.032`
- far AUC CI `-0.025` to `+0.007`

Question-level effect:

- ratio far-positive recall recovers from score-meta `0.217` to `0.696`
  versus primary `0.652`;
- ratio uncertain recall falls from score-meta `0.632` to `0.211` versus
  primary `0.316`.

Decision:

- The ratio-preserve gate confirms the failure is localized and partially
  recoverable, but it does not clear the method gate.
- Simple score policies now look exhausted: they can trade uncertainty recall
  and far-positive preservation, but do not produce a statistically defensible
  improvement over primary/original tri-view.
- The next credible experiment must move the preservation mechanism into the
  representation or uncertainty training stage.
