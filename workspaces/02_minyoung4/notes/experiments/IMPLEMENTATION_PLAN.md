# Implementation Plan

Created: 2026-06-18

This plan converts the experiment ladder into an implementation sequence.
It intentionally starts with gates and baselines before novelty models.

## Phase 0: Protocol Lock

Directory: `exp00_protocol_and_leakage_gate`

Tasks:

- Write `protocol.md`.
- Write `label_policy.md`.
- Write `split_policy.md`.
- Write `preprocessing_policy.md`.
- Write `mask_policy.md`.
- Write `leakage_checklist.md`.
- After Min approval, implement manifest/split validators.

Exit criteria:

- Cohort, label, split, metrics, preprocessing, and mask policy are explicit.
- Full audit/preprocessing/training commands are approved before execution.

## Phase 1: Shortcut and Baseline Floor

Directories:

- `exp01_clinical_shortcut_baseline`
- `exp02_res3dnet_proxy_baseline`

Tasks:

- Implement clinical-only shortcut baseline.
- Implement subject-level metric harness.
- Implement 3D ResNet and Res3DNet proxy.
- Review loader shape convention `[B, C, D, H, W]`.

Exit criteria:

- Image models are compared against clinical-only shortcuts using incremental-value criteria,
  not only absolute AUC.
- Age-stratified and age-adjusted diagnostics are implemented before image-model claims.
- `B1_3d_resnet_image_only` and `B2_res3dnet_proxy` are reported separately.
- Res3DNet proxy is strong enough to be a real baseline.

Required before exp02 is treated as interpretable:

- lock whether the official supervised cohort is 1,457 or conflict-excluded 1,444;
- resolve `exp00_protocol_and_leakage_gate/age_semantics_audit.md` as a hard blocker
  before exp02 image modeling;
- add bootstrap confidence intervals for exp01/exp02 comparisons;
- define subject-level paired bootstrap over out-of-fold predictions;
- define age-stratified reporting with pooled `40_59` supportive analysis and
  exploratory `60_69` analysis, marking zero-positive fold AUC as undefined;
- define full-cohort age-residualized or clinical-adjusted comparison against B0 as the
  primary confirmatory age-control endpoint.
- make exp02 success conjunctive: paired LOCO incremental value over clinical-only plus
  positive primary clinical-adjusted age-control confirmation.

## Phase 2: Novelty Modules

Directories:

- `exp03_modality_dropout_fusion`
- `exp04_tumor_context_mask_dropout`
- `exp05_domain_generalization_loco`
- `exp06_clinical_prompt_conditioning`

Tasks:

- Add modality dropout/late fusion.
- Add tumor/context tokens with mask dropout.
- Add domain generalization losses.
- Add age/sex prompt conditioning with prompt-shuffle controls.

Exit criteria:

- Each module beats its direct baseline under LOCO or is rejected.
- Ablations identify which component actually helps.

## Phase 3: Reliability

Directory: `exp07_calibration_abstention`

Tasks:

- Apply temperature scaling using validation consortia only.
- Report ECE, Brier, reliability curves, and selective risk/coverage.

Exit criteria:

- Reliability improves without test-consortium tuning.

## Implementation Rule

One experiment is implemented and reviewed at a time.
Do not start GPU training until the relevant experiment has:

- approved protocol;
- loader/split smoke tests;
- sub-agent code review;
- command preview;
- Min approval.
