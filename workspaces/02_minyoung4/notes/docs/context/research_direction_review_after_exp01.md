# Research Direction Review After exp01

Date: 2026-06-22

## Scope

This note reviews the completed exp01 segmentation sweep after GPU training was stopped.
It does not approve new GPU training and does not define a new locked research topic.

## Current Evidence

Completed task:

- 4-channel structural MRI whole-tumor segmentation.
- Leave-one-consortium-out evaluation.
- Subject-level held-out Dice.
- Cohort in completed predictions: 1617 subjects.

Current best artifact:

- `resunet_ds_tta_distill_ensemble_tta_all_v1`.
- Mean Dice: 0.892775.
- Delta vs standard Dice+BCE compact 3D U-Net: +0.008498.
- CI95 for delta: [+0.005960, +0.011038].
- Dice <= 0.8 rate: 0.100186.

Best artifact by fold:

| fold | n | standard Dice | best Dice | delta Dice |
|---|---:|---:|---:|---:|
| MU-Glioma-Post | 203 | 0.843889 | 0.865013 | +0.021124 |
| UCSD-PTGBM | 178 | 0.788069 | 0.816679 | +0.028610 |
| UPENN-GBM | 611 | 0.923344 | 0.927747 | +0.004404 |
| UTSW | 625 | 0.886603 | 0.889275 | +0.002672 |

## What Worked

- Residual SE 3D U-Net with deep supervision improved over the compact U-Net:
  +0.003108 mean Dice, CI95 [+0.000509, +0.005785].
- All-flip TTA improved inference over ResUNet-DS:
  +0.002253 over ResUNet-DS.
- A fixed 50:50 ensemble of ResUNet-DS and TTA-distilled ResUNet-DS under all-flip TTA
  produced the best completed result.
- The largest gains appeared in MU and UCSD, the harder held-out folds.

## What Failed

- Source balancing and small-lesion weighted focal Tversky degraded performance.
- Source-balanced Dice+BCE also degraded performance.
- Naive train-time flip consistency degraded ResUNet-DS.
- TTA self-distillation was not an overall winner as a standalone model.
- Ensemble-to-student compression did not preserve the two-model ensemble gain.
- Confidence-weighted teacher distillation did not clearly beat ResUNet-DS.
- Validation-selected ensemble weighting was worse than the fixed 50:50 ensemble.
- Adding a third confidence-distilled model did not improve the best artifact.

## Research Claim Assessment

The result is empirically positive but methodologically weak for an AI conference claim.

Defensible limited claim:

- TTA-distilled training can create a complementary model whose errors combine with a
  stronger ResUNet-DS backbone under cross-consortium evaluation.

Weak or unsafe claims:

- "Single-pass distillation solves the problem."
- "Consistency training transfers TTA gains."
- "Validation routing improves cross-consortium robustness."
- "This is a clean new segmentation architecture contribution."

Main reason:

- The best result depends on two models and all-flip TTA. That is a performance artifact
  with extra inference compute, not a clean training-method or architecture improvement.

## Why Continuing This Exact Direction Is Low Value

Generic segmentation tuning is now unlikely to produce a strong novelty story:

- The gains are small in already high-performing UPENN and UTSW folds.
- The meaningful gains are concentrated in harder MU and UCSD folds.
- Single-pass compression repeatedly failed.
- Additional generic losses would mostly test optimization details rather than a new idea.
- The current best method is expensive at inference and hard to sell as a fresh core method.

## Better Next Research Questions

Do not restart GPU training until one of these is selected and locked.

### Option A: Domain-Shift-Aware Segmentation Reliability

Question:

- Can we predict and reduce cross-consortium segmentation failure, especially UCSD/MU,
  using uncertainty, disagreement, and image-quality signals?

Why it fits the evidence:

- The best ensemble reduces low-Dice failures.
- The hardest sites benefit most.
- The method story can focus on reliability under dataset shift rather than raw Dice only.

Needed proof:

- Failure prediction AUC/AUPRC.
- Calibration of uncertainty against Dice failure.
- Risk-coverage curves.
- Held-out consortium evaluation.

Current CPU-only feasibility signal:

- Existing subject-level predictions already predict best-artifact Dice <= 0.8 with
  LOCO OOF AUC 0.923800 and AP 0.662324 using predicted-volume and model-disagreement
  summaries.
- This is not yet a method claim because the current predictions do not export voxel-level
  entropy, TTA variance, or spatial disagreement maps.
- It is strong enough to justify a locked reliability-method design if this direction is
  selected.

### Option B: Compute-Aware TTA/Ensemble Selection

Question:

- Can we keep most of the two-model all-flip TTA gain while adaptively using extra compute
  only for cases likely to fail?

Why it fits the evidence:

- Full ensemble-TTA works but is expensive.
- A cheap default model is close on easy cases.
- Hard cases may justify selective TTA or two-model inference.

Needed proof:

- Dice vs compute curve.
- Risk-triggered escalation policy trained without held-out leakage.
- Per-consortium robustness.

Current CPU-only feasibility signal:

- Starting from single-pass ResUNet-DS, escalating only the highest-risk 30% of subjects to
  the full two-model all-flip TTA artifact gives mean Dice 0.890601.
- That recovers 0.003216 Dice over ResUNet-DS, or 59.6717% of the full best-artifact gain,
  while avoiding full escalation for 70% of subjects.
- Escalating 50% gives mean Dice 0.891517 and recovers 76.6592% of the full gain.
- A stricter selective-compute prototype using only cheap single-pass ResUNet predicted
  volume found similar behavior:
  - 30% escalation: mean Dice 0.890627, 60.1458% of full gain.
  - 50% escalation: mean Dice 0.891517, 76.6592% of full gain.
- Cheap gain regression did not work well; failure-risk ranking was better than trying to
  directly predict positive gain.

### Option C: Segmentation as a Support Module, Not the Main Paper

Question:

- Use the best segmentation artifact as a lesion representation generator for a new
  downstream biological or clinical task.

Why it fits the evidence:

- The segmentation system is now a credible internal tool.
- The segmentation method itself is not yet a strong conference-level novelty.

Needed proof:

- A separate downstream task with locked outcome, cohort, split, and leakage audit.
- Segmentation-derived features or masks must add value beyond shortcuts.

## Stop/Go Rule

Current state:

- GPU training should remain stopped.
- exp01 should be preserved as a completed segmentation sweep and evidence base.
- Any new GPU run requires a new research question, outcome, split policy, metric, and
  command preview.

Do not run:

- another generic segmentation loss variant,
- another plain consistency loss,
- another unplanned distillation compression attempt,
- another all-fold GPU sweep without a locked claim.

Recommended next action:

- Lock one new research question, preferably Option A or B if staying within segmentation.
- If the broader goal is AI-conference novelty, treat exp01 as a support experiment rather
  than the central paper unless a reliability or compute-aware method is explicitly defined.
- Evidence for the feasibility of Option A/B is recorded in
  `experiments/exp01_loco_segmentation_robust/analysis/failure_risk_audit_v1/report.md`.
- Compute-aware policy details are recorded in
  `experiments/exp01_loco_segmentation_robust/analysis/selective_compute_policy_v1/report.md`.
