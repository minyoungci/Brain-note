# Molecular Ceiling Probe Final Audit

Updated: 2026-06-20

## Scope

This note summarizes the completed LOCO + nested-OOF ceiling probes for glioma molecular
prediction. The question was whether 3D MRI image models add subject-level value beyond a
clinical age/sex baseline, under held-out-consortium evaluation.

This is a decision memo, not a method claim.

## Protocol

- Unit: subject (`dataset::subject_id`).
- Split: leave-one-consortium-out (LOCO).
- Combiner: train-only logistic `age + sex + image_score`.
- Training-subject image scores: nested OOF only.
- Test-subject image scores: outer OOF only.
- Primary endpoint: full-cohort clinical-adjusted `dAUC = AUC(image+age_sex) - AUC(age_sex)`.
- GO criterion: full-cohort dAUC 95% CI lower bound > 0, with dAUPRC/dBrier directionally consistent.

## Completed Results

| target | model | subjects | result | dAUC | 95% CI | note |
|---|---:|---:|---|---:|---|---|
| IDH | B2 whole-brain Res3DNet proxy | 1444 | NO-GO | -0.0405 | [-0.0505, -0.0310] | age/sex baseline dominates |
| IDH | B3 lesion-ROI/mask-input oracle | 1421 | NO-GO | -0.0370 | [-0.0497, -0.0248] | even oracle lesion ROI failed |
| MGMT | B2 whole-brain Res3DNet proxy | 815 | NO-GO | -0.0057 | [-0.0267, 0.0153] | no adjusted image value |
| MGMT | B3 lesion-ROI/mask-input oracle | 800 | NO-GO | -0.0131 | [-0.0391, 0.0127] | segmentation subset, still no value |

## Validation Evidence

### MGMT B3

- Full nested OOF:
  `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B3_lesion_roi_resnet_proxy/ceiling_probe_mgmt_b3_nested_v1/image_oof_long.csv`
- Report:
  `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B3_lesion_roi_resnet_proxy/ceiling_probe_mgmt_b3_nested_v1/ceiling_probe/report.md`
- Clinical subset: 800/815 subjects after requiring validated segmentation availability.
- OOF rows: 3200 = 800 outer test + 2400 nested train.
- Unique UIDs: 800.
- Missing `p_img`: 0.
- Missing `y_true`: 0.
- Duplicate `(uid, outer_fold, role, score_type)`: 0.
- Fold-internal train/test UID overlap: 0 for all four outer folds.

## Interpretation

The problem is not primarily a code-execution issue. The pipeline ran through GPU outer folds,
nested OOF generation, leakage-safe combiner fitting, and bootstrap reporting.

The blocking scientific result is that neither IDH nor MGMT showed positive cross-consortium
clinical-adjusted imaging value. This is especially damaging because the B3 probes used
segmentation-dependent lesion ROI/mask inputs, which are stronger than the intended mask-free
deployment setting. A constrained method such as CTEC should not be expected to exceed a failed
oracle-style lesion probe on the same task.

## Decision

Do not promote IDH or MGMT molecular prediction as the main ACCV-tier performance-improvement
claim under the current LOCO protocol.

Allowed follow-up framings:

- Negative benchmark / confound audit: existing MRI molecular-prediction claims may not survive
  strict consortium-held-out and clinical-adjusted evaluation.
- Representation/pretraining method: use tumor segmentation and multi-consortium MRI for a method
  whose downstream endpoint is not IDH/MGMT molecular prediction unless a new positive ceiling
  is first demonstrated.
- New downstream target: only proceed after a fresh ceiling probe shows positive adjusted image
  value before method development.

Not allowed without new evidence:

- Claiming CTEC improves IDH or MGMT prediction.
- Claiming lesion grounding improves molecular prediction performance.
- Reporting pooled/random-split molecular AUC as the headline result.
