# exp02: Res3DNet Proxy Baseline

Status: scaffold only. No GPU job has been run.

## Objective

Implement a strong segmentation-free 3D CNN baseline inspired by Res3DNet.
This is the main image baseline, but success is not defined as simply exceeding the
`B0_clinical_only` AUC. Because whole-brain 3D CNNs can learn brain age, this experiment must
quantify whether image features add IDH-specific value beyond age and clinical shortcuts.

## Prior-Work Target

Res3DNet reports strong external IDH performance using whole-brain 4-channel MRI
without explicit tumor segmentation at inference.

## Model Contract

- Input channels: T1, T1ce/T1post, T2, FLAIR.
- Backbone: residual I3D-style 3D CNN or local proxy.
- No segmentation mask required at inference.
- Subject-level prediction.
- Explicitly report that image-only predictions may encode brain age.

## Training Contract

- Class imbalance handling is train-only.
- Augmentation is train-only.
- Normalization statistics are train-only or per-volume.
- Validation and held-out consortium are never used for training transforms.

## Required Comparisons

- 3D ResNet baseline.
- Res3DNet-style proxy.
- B0 clinical-only predictions from `exp01`.
- Image-only vs clinical-only vs image-plus-clinical where allowed.
- Optional original-code reference if feasible.

Stable IDs:

- `B1_3d_resnet_image_only`
- `B2_res3dnet_proxy`

## Metrics

- LOCO mean AUC.
- Worst-consortium AUC and MCC.
- AUPRC for mutant class.
- Calibration metrics.
- Incremental value over `B0_clinical_only`.
- Age-stratified AUC/AUPRC/MCC, with special attention to `40_59` and `60_69`.
- Age-residualized or clinical-adjusted analysis.
- Age-matched sensitivity analysis if sample size permits.
- Bootstrap confidence intervals for primary comparisons.

## Required Confound Diagnostics

- Compare image-only predictions with age-only predictions by subject.
- Report performance inside age strata, not only pooled LOCO.
- Check whether model confidence tracks age more strongly than tumor-region evidence.
- Report whether the model improves on middle-age subjects where age is less deterministic.
- Treat `70_plus` as a special stratum because the current draft has 0 mutants.

## Revised Success Criteria

Go condition:

- Image model shows paired incremental value over clinical-only under LOCO.
- Primary confirmatory age-control test is positive: full-cohort out-of-fold
  clinical-adjusted or residualized image-score test fit without held-out leakage.
- Supportive `40_59` analysis improves when pooled across subjects scored in their
  own held-out fold.
- It improves middle-age performance without collapsing worst-consortium metrics.
- It does not rely only on apparent brain-age signal.

No-go condition:

- Image-only AUC improves but age-stratified/incremental value is absent.
- Gains disappear after age adjustment.
- Predictions are mainly explained by age or scanner/site proxies.

## Locked Pre-GPU Gates

Before any GPU image run:

- resolve `experiments/exp00_protocol_and_leakage_gate/age_semantics_audit.md`;
- lock scan-age versus diagnosis-age policy per consortium;
- lock subject-level imaging-unit selection policy before interpreting image results;
  `draft_first_lexical` is smoke-only, while `earliest_numeric` is an explicit diagnostic
  policy and still does not prove pre-treatment semantics;
- run 4-channel geometry checks (shape, affine, voxel spacing) before training;
- use explicit bf16 autocast for CUDA/B200 runs unless a run is deliberately CPU-only;
- lock a strong unconstrained baseline regimen (capacity, resolution, epochs, train-only
  augmentation) before treating any NO-GO as evidence that image signal is absent;
- define paired bootstrap CI for delta AUC, delta AUPRC, and delta Brier versus `age_sex`;
- define the bootstrap unit as subject-level paired resampling of out-of-fold predictions;
- treat `age_sex` as the clean clinical baseline;
- require `p_age_only` LOCO OOF predictions for brain-age shortcut diagnostics;
- treat `age_sex_scanner` as sensitivity/diagnostic unless scanner use is explicitly approved;
- pre-specify full-cohort clinical-adjusted/residualized image-score testing as the
  primary confirmatory age-control endpoint;
- pre-specify `40_59` pooled out-of-fold stratified performance as supportive and
  `60_69` as exploratory;
- exclude folds with zero positives from fold-level stratum AUC and report them as undefined;
- treat `70_plus` as specificity/calibration-only because draft B0 has 0 mutants there;
- define the train-only residual/clinical-adjusted image-score test;
- define correlation diagnostics between image logits, age, and age-only logits.

## Expected Artifacts

- implementation code only after exp00 protocol approval;
- smoke test for loader shape `[B, C, D, H, W]`;
- metrics script with subject-level aggregation;
- `runs/B1_3d_resnet_image_only/`;
- `runs/B2_res3dnet_proxy/`;
- `reports/B1_3d_resnet_image_only/`;
- `reports/B2_res3dnet_proxy/`;
- `reviews/B1_3d_resnet_image_only_review.md`;
- `reviews/B2_res3dnet_proxy_review.md`.

## Main Risk

If this baseline is weak, downstream novelty claims become inflated.
The implementation should be conservative and strong enough to be a real competitor.

The second major risk is the opposite: if the image baseline is strong only because it learns
brain age, then pooled AUC will overstate IDH-specific imaging value.
