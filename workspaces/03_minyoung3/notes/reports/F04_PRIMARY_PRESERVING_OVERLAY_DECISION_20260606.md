# F04 Primary-Preserving Overlay Decision

Updated: 2026-06-06

## Goal

Recent representation controls recovered uncertain rows versus fixed 2.5D but
regressed primary-correct far-boundary rows. We therefore tested a conservative
post-hoc overlay:

- start from the primary 3D validation-selected three-zone decision;
- keep the primary answer/far-boundary score;
- allow a candidate model only to convert a primary far decision into
  `uncertain`;
- select thresholds on validation with a far-negative/far-positive regression
  penalty.

This is a decision-surface audit, not a new image encoder.

## Input Policy

Allowed:

- primary image-model score;
- candidate image-model score;
- validation labels for threshold selection only.

Forbidden as model inputs:

- clinical fields;
- scanner/acquisition metadata;
- raw consortium;
- ROI values;
- evidence percentiles;
- AEB features.

Evidence percentiles and three-zone labels are used only for target definition
and audit, as in prior three-zone evaluations.

## Runs

| candidate | overlay audit |
|---|---|
| style consistency | `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_styleconsistency_audit` |
| DSBN vendor | `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_dsbn_vendor_audit` |
| DSBN vendor+field | `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_dsbn_vendorfieldfallback_audit` |
| DINOv2 shallow | `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_famous_ssl_dinov2_audit` |
| BN reset TTA | `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_bn_tta_recalib_reset_audit` |
| BN momentum TTA | `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_bn_tta_momentum010_full_audit` |

Script:

- `scripts/run_f04_v6_primary_preserving_overlay_audit.py`

## Test Metrics

| candidate | n | overlay zone-bacc | primary zone-bacc | tri-view zone-bacc | overlay uncertain recall | primary uncertain recall | overlay far-negative recall | primary far-negative recall | overlay far-positive recall | primary far-positive recall |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| style consistency | 340 | 0.638 | 0.643 | 0.645 | 0.553 | 0.543 | 0.669 | 0.676 | 0.692 | 0.712 |
| DSBN vendor | 340 | 0.630 | 0.643 | 0.645 | 0.617 | 0.543 | 0.620 | 0.676 | 0.654 | 0.712 |
| DSBN vendor+field | 340 | 0.627 | 0.643 | 0.645 | 0.585 | 0.543 | 0.641 | 0.676 | 0.654 | 0.712 |
| DINOv2 shallow | 162 | 0.615 | 0.623 | 0.648 | 0.604 | 0.604 | 0.694 | 0.694 | 0.548 | 0.571 |
| BN reset TTA | 340 | 0.645 | 0.643 | 0.645 | 0.574 | 0.543 | 0.669 | 0.676 | 0.692 | 0.712 |
| BN momentum TTA | 340 | 0.638 | 0.643 | 0.645 | 0.553 | 0.543 | 0.669 | 0.676 | 0.692 | 0.712 |

## Bootstrap Versus Primary

| candidate | delta zone-bacc 95% CI | delta uncertain recall 95% CI | delta far-negative recall 95% CI | delta far-positive recall 95% CI |
|---|---:|---:|---:|---:|
| style consistency | -0.018 to +0.007 | 0.000 to +0.036 | -0.023 to 0.000 | -0.047 to 0.000 |
| DSBN vendor | -0.041 to +0.014 | +0.025 to +0.123 | -0.093 to -0.022 | -0.113 to -0.011 |
| DSBN vendor+field | -0.041 to +0.006 | +0.010 to +0.084 | -0.066 to -0.008 | -0.113 to -0.011 |
| DINOv2 shallow | -0.024 to 0.000 | 0.000 to 0.000 | 0.000 to 0.000 | -0.071 to 0.000 |
| BN reset TTA | -0.013 to +0.018 | 0.000 to +0.071 | -0.023 to 0.000 | -0.047 to 0.000 |
| BN momentum TTA | -0.018 to +0.007 | 0.000 to +0.036 | -0.023 to 0.000 | -0.047 to 0.000 |

## Decision

No overlay candidate passes the new method gate.

- DSBN overlays improve uncertain recall but significantly regress both
  far-negative and far-positive recall.
- BN reset is the closest point estimate, but its zone-bacc CI crosses zero and
  far-boundary recall still trends downward.
- DINOv2 does not add useful uncertainty signal.
- Conservative post-hoc score geometry is not enough to create publishable
  method novelty over the primary 3D model.

The result strengthens the current interpretation: the remaining problem is
not thresholding alone. A new method must improve representation or uncertainty
estimation while explicitly preserving primary far-boundary correctness.
