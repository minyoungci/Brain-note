# Gate05b primary/stress cohort split policy

Date: 2026-05-28
Workspace: `/home/vlm/minyoungi`
Experiment family: `experiments/voxelwise_feature_learning_v1`

## Decision

Gate05b cohort reporting is split into two tiers:

1. **Primary development/evaluation cohorts**
   - `ADNI`
   - `AIBL`
   - `KDRC`

2. **Stress-test / unresolved external cohort**
   - `NACC`

This is not permission to hide NACC. NACC remains mandatory as a stress-test readout and must be reported separately whenever Gate05b claims are made.

## Rationale

Observed Gate05b evidence shows consistent or useful ROI-cosine benefit outside NACC, but NACC regresses under the same objective:

- ADNI: `gate05b_b1_global_roi_cos` improves over b0 on direct AUC, frozen AUC, frozen bACC, and predicted ROI probe AUC.
- KDRC: `gate05b_b1_global_roi_cos` strongly improves over b0 and clears fold-specific Baseline06 AUC.
- AIBL: `gate05b_b1_global_roi_cos` improves AUC slightly but bACC is weaker, so it is a primary cohort but not a clean pass.
- NACC: `gate05b_b1_global_roi_cos` regresses versus b0 on direct/frozen/predROI readouts. ROI-cos/CE sweep did not fix the frozen representation regression.

Therefore NACC should not be mixed into a single primary mean that obscures the failure mode, but it also must not be discarded to make the result look cleaner.

## Reporting rule

Every Gate05b report must include:

- Primary mean across `ADNI`, `AIBL`, `KDRC`.
- Stress-test NACC result as a separate block.
- Fold-specific comparison against Baseline06.
- Explicit label from the Gate05b pass/fail scheme.

Forbidden reporting pattern:

- “Mean over all available cohorts” as the only headline metric.
- Dropping NACC without naming it.
- Claiming representation-readiness when NACC is failing unless the claim scope explicitly excludes NACC and explains why.

## Current claim label

Current Gate05b b1 status:

- **Primary cohorts:** promising but not fully clean because AIBL bACC weakens.
- **Stress NACC:** unresolved regression.
- Overall label: **image-baseline-partial-pass with NACC regression**.
- Not `representation-readiness-pass`.
- Not `vlm-scaling-ready`.

## Immediate next action

Proceed with split-based summary artifacts using existing runs, then run/implement a NACC row-level failure audit before b2 ROI phrase/SigLIP expansion.

Minimum NACC audit requirements:

- b0 vs b1 row-level disagreement.
- Baseline06-correct / b1-wrong overlap if predictions are available.
- Teacher-S confident AD but student miss rows.
- ROI prediction cosine/error by correct vs wrong.
- Class distribution and any available age/sex/scanner/site metadata audit.
- Determine whether NACC is data/label/cohort-shift problem or objective-induced representation failure.
