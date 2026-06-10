# F04 Image Representation vs Morphometry Bar

Updated: 2026-06-06

## External Modeling Bar

The harmonization/playbook results in `/home/vlm/minyoungi/roi_qc/experiments/harmonization/` are now treated as a hard modeling reference:

- Official modeling entry point: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md`
- #5/#9 evidence: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/09_modeling_path_comparison/RESULTS.md`
- CN/AD LOCO feature-space winner: morphometry + simple normalization.
- RF mean held-cohort AUC: train-z `0.910`, ICV `0.909`.
- Site-shift cost is approximately zero under the corrected within-cohort baseline.
- ComBat is not a reliable cross-cohort generalization booster because RF and LogReg disagree in direction.

Practical consequence: image methods should not be promoted on “beats fixed 2.5D” alone. For disease-classification claims, the image method must approach or exceed the `0.91` morphometry + simple norm LOCO bar, or the paper must frame a different contribution such as ROI-grounded three-zone VQA/task design.

## Current Representation Experiment

Run:

- candidate: `results/f04_roi_evidence_encoder/20260606_080834_v6_multiview_preinit_unfreeze_styleconsistency_boundaryrank_loco_AJU`
- candidate three-zone/bootstrap audit: `results/f04_roi_evidence_encoder/20260606_081819_v6_unfreeze_styleconsistency_boundaryrank_threezone_bootstrap_audit`
- candidate style audit: `results/f04_roi_evidence_encoder/20260606_082500_v6_unfreeze_styleconsistency_boundaryrank_style_perturbation_audit/case_review/style_perturbation_audit`
- fair primary style audit: `results/f04_roi_evidence_encoder/20260606_082800_v6_primary_loco_style_perturbation_audit/case_review/style_perturbation_audit`

Design:

- Start from global64 + MTL64 pretrained encoders.
- Stage-unfreeze encoders at epoch 3 with LR `1e-4`.
- Add train-only intensity/blur perturbation consistency and supervised augmented BCE.
- Add train-only confident far-boundary pairwise ranking loss.
- Model inputs remain image tensors plus question ID only.

## Binary AJU Result

| model | pooled AUC | bacc | hip AUC | MTL AUC | vent AUC |
|---|---:|---:|---:|---:|---:|
| fixed 2.5D context | 0.684 | 0.597 | 0.562 | 0.588 | 0.769 |
| primary 3D | 0.879 | 0.785 | 0.808 | 0.858 | 0.940 |
| candidate | 0.853 | 0.741 | 0.790 | 0.836 | 0.921 |
| morphometry simple-norm CN/AD bar | 0.910 | n/a | n/a | n/a | n/a |

Decision: negative. The candidate remains above fixed 2.5D but falls below primary 3D and below the external morphometry modeling bar.

## Three-Zone Result

Validation-locked score-confidence thresholds:

| model | all zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| candidate | 0.646 | 0.638 | 0.567 | 0.932 |

Subject-level bootstrap:

| comparison | all-question delta zone-bacc 95% CI | conclusion |
|---|---:|---|
| candidate vs fixed 2.5D | +0.155 to +0.271 | positive |
| candidate vs primary | -0.056 to +0.060 | not significant |
| candidate vs original tri-view | -0.049 to +0.052 | not significant |

Decision: diagnostic only. The candidate confirms the 3D-vs-2.5D task claim but does not improve the 3D method.

## Style Perturbation Finding

The style audit loader was updated to load older shared-head checkpoints with `strict=False` while requiring all encoder, question-embedding, and shared answer-head tensors. Missing unused auxiliary heads are recorded in `summary.json`.

Fair primary-vs-candidate style comparison:

- Candidate average flip-rate change versus primary across all perturbations: lower by about `0.155` on all AJU rows.
- Candidate average flip-rate change versus primary in AJU hippocampal GE: lower by about `0.151`.
- But candidate baseline AJU AUC is lower: `0.853` vs primary `0.879`.
- Candidate far AUC in three-zone audit is lower: `0.932` vs primary `0.948`.

Interpretation: perturbation consistency reduced superficial sensitivity, but it likely suppressed useful morphology/ranking signal. This is an “erase” failure, not a successful acquisition-conditioned representation.

## Decision

Do not continue scalar augmentation/consistency/ranking sweeps in this form. They improve some robustness diagnostics but fail the core performance and far-boundary ranking tests.

Next experiments should only proceed if they implement one of the playbook-backed levers:

1. Acquisition-conditioned normalization, such as DSBN keyed by vendor/field/voxel features rather than raw consortium.
2. Foundation/pretrained image features plus a linear or shallow probe under LOCO.
3. Test-time adaptation/BN adaptation evaluated against the same primary, 2.5D, and morphometry bars.

The image contribution should be framed cautiously: current strongest publishable path is ROI-grounded three-zone VQA/task/evaluation plus 3D-over-2.5D evidence, not a disease-classification claim over morphometry.

## DSBN Feasibility Check

Matched ROI-VQA manifest already contains `acq_scanner` and `acq_field_strength`, so scanner/field conditioning can be built without joining clinical labels into the model input path.

For AJU-held LOCO with AJU excluded from train/val:

- non-AJU train/val acquisition keys: `GE__3.0`, `PHILIPS__3.0`, `SIEMENS__3.0`, `SIEMENS__1.5`, `MISSING__MISSING`, `Other__3.0`
- AJU test keys: `GE__3.0`, `GE__MISSING`, `MISSING__3.0`, `PHILIPS__3.0`, `SIEMENS__3.0`
- unseen AJU keys: `GE__MISSING`, `MISSING__3.0`

Implication:

- DSBN keyed exactly by `scanner__field_strength` is feasible for the major AJU keys but needs an explicit fallback for unseen or missing acquisition keys.
- A conservative first DSBN experiment should map rare/unseen keys to vendor-level or `UNKNOWN` fallback rather than raw consortium.
- The report must separate acquisition-conditioned normalization from forbidden clinical/cohort shortcut use.

## DSBN Experiment Result

Runs:

- vendor DSBN: `results/f04_roi_evidence_encoder/20260606_083311_v6_multiview_dsbn_vendor_loco_AJU`
- vendor DSBN three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_083903_v6_dsbn_vendor_threezone_bootstrap_audit`
- vendor+field fallback DSBN: `results/f04_roi_evidence_encoder/20260606_084015_v6_multiview_dsbn_vendorfieldfallback_loco_AJU`
- vendor+field fallback three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_084533_v6_dsbn_vendorfieldfallback_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_multiview_dsbn_acq_loco.py`

Design:

- DSBN key is acquisition metadata only, not raw consortium.
- Vendor mode keys: `GE`, `SIEMENS`, `PHILIPS`, `MISSING`, `OTHER`.
- Vendor+field fallback mode uses `vendor__field` when field is known and falls back to vendor when missing.
- Pretrained conv weights are loaded from the global and MTL single-view checkpoints.
- Convolution weights are frozen in the first DSBN pass; DSBN, question embedding, and fusion/head are trained.
- Forbidden inputs remain excluded: raw consortium, diagnosis/CDR, age/sex, ROI values, evidence percentiles, and AEB features.

Binary AJU result:

| model | pooled AUC | bacc | hip AUC | ratio AUC | MTL AUC | vent AUC |
|---|---:|---:|---:|---:|---:|---:|
| primary 3D | 0.879 | 0.785 | 0.808 | 0.924 | 0.858 | 0.940 |
| DSBN vendor | 0.848 | 0.756 | 0.786 | 0.894 | 0.848 | 0.927 |
| DSBN vendor+field fallback | 0.820 | 0.729 | 0.766 | 0.900 | 0.765 | 0.935 |
| morphometry simple-norm external bar | 0.910 | n/a | n/a | n/a | n/a | n/a |

Three-zone AJU result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| DSBN vendor | 0.585 | 0.681 | 0.615 | 0.921 |
| DSBN vendor+field fallback | 0.570 | 0.617 | 0.606 | 0.906 |

Subject-level bootstrap:

| comparison | all-question delta zone-bacc 95% CI | all-question delta far AUC 95% CI | decision |
|---|---:|---:|---|
| DSBN vendor vs fixed 2.5D | +0.085 to +0.211 | +0.096 to +0.240 | positive versus lower bound |
| DSBN vendor vs primary | -0.119 to -0.002 | -0.051 to -0.009 | significantly worse |
| DSBN vendor vs original tri-view | -0.117 to -0.010 | -0.050 to -0.002 | significantly worse |
| DSBN vendor+field vs fixed 2.5D | +0.073 to +0.198 | +0.083 to +0.224 | positive versus lower bound |
| DSBN vendor+field vs primary | -0.139 to -0.004 | -0.072 to -0.017 | significantly worse |
| DSBN vendor+field vs original tri-view | -0.132 to -0.022 | -0.072 to -0.013 | significantly worse |

Decision:

- Acquisition-conditioned BN is feasible and leakage-safe under the current implementation, but the tested DSBN variants are negative.
- Vendor-level DSBN increases uncertain recall relative to primary but damages far-negative recall and far-boundary ranking.
- Vendor+field fallback is worse than vendor-only, likely because domain groups become smaller and BN statistics are less stable.
- Do not promote DSBN as the method contribution in its current form.
- Remaining image-side lever is foundation/pretrained feature extraction with a shallow LOCO probe; otherwise the paper should emphasize ROI-grounded VQA/task/evaluation and 3D-over-2.5D rather than image classifier superiority.

## Famous SSL DINOv2 Shallow Probe Result

Runs:

- source feature run: `results/f04_roi_evidence_encoder/20260602_025316_famous_ssl_dinov2_transformers_full_v1`
- shallow LOCO probe: `results/f04_roi_evidence_encoder/20260606_085423_v6_famous_ssl_dinov2_shallow_probe_loco_AJU`
- three-zone/bootstrap audit: `results/f04_roi_evidence_encoder/20260606_085627_v6_famous_ssl_dinov2_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_famous_ssl_feature_probe.py`

Design:

- Frozen `facebook/dinov2-small` session features were reused from the previous famous SSL export.
- Input mode is adjacent-slice RGB / 2D SSL, not a true 3D medical foundation encoder.
- Shallow probe inputs are only DINOv2 feature vector plus question ID.
- Forbidden inputs remain excluded: scanner/acquisition, raw consortium, diagnosis/CDR, age/sex, ROI values, ROI percentiles, evidence percentiles, and AEB features.
- The current VQA manifest and SSL feature table had no direct `join_key` overlap, so rows were aligned by canonical image-session path derived from tensor paths. This is session-level path alignment, not subject-only matching.

Coverage and binary AJU result:

| item | value |
|---|---:|
| train examples | 8,407 |
| validation examples | 1,833 |
| AJU test examples | 162 |
| AJU test QA-row coverage before AJU filtering | 0.736 |
| best validation macro AUC | 0.676 |
| AJU macro AUC | 0.616 |
| AJU macro bacc | 0.555 |

Question-level AJU AUC:

| question | AUC | bacc |
|---|---:|---:|
| hippocampal volume | 0.535 | 0.474 |
| hippocampus-to-ventricle ratio | 0.829 | 0.676 |
| MTL atrophy | 0.366 | 0.435 |
| ventricle enlargement | 0.795 | 0.698 |

Three-zone subset comparison on the same 162 AJU rows:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.472 | 0.000 | 0.595 | 0.822 |
| primary 3D | 0.623 | 0.604 | 0.571 | 0.930 |
| original tri-view | 0.648 | 0.813 | 0.548 | 0.913 |
| DINOv2 shallow probe | 0.381 | 0.042 | 0.310 | 0.684 |

Subject-level bootstrap on the same 162 AJU rows:

| comparison | all-question delta zone-bacc 95% CI | all-question delta far AUC 95% CI | decision |
|---|---:|---:|---|
| DINOv2 vs fixed 2.5D | -0.195 to +0.013 | -0.284 to -0.015 | not positive; far AUC worse |
| DINOv2 vs primary | -0.375 to -0.116 | -0.412 to -0.096 | significantly worse |
| DINOv2 vs original tri-view | -0.407 to -0.123 | -0.390 to -0.080 | significantly worse |

Decision:

- Famous 2D SSL features do not solve the image-signal problem in this ROI-grounded VQA setting.
- The poor MTL and hippocampal AUCs suggest that adjacent-slice natural-image SSL features miss cutoff-sensitive 3D medial temporal morphology.
- This result is a negative/control baseline, not a promoted method.
- If foundation features are revisited, they must be genuine 3D medical-volume features and evaluated with the same LOCO, three-zone, and morphometry-bar protocol.

## Label-Free BN TTA Result

Runs:

- source-mode loader check: `results/f04_roi_evidence_encoder/20260606_090454_v6_multiview_bn_tta_source_smoke_loco_AJU`
- BN reset recalibration: `results/f04_roi_evidence_encoder/20260606_090524_v6_multiview_bn_tta_recalib_reset_loco_AJU`
- BN reset three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_090558_v6_bn_tta_recalib_reset_threezone_bootstrap_audit`
- BN momentum adaptation: `results/f04_roi_evidence_encoder/20260606_090524_v6_multiview_bn_tta_momentum010_loco_AJU`
- BN momentum three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_090557_v6_bn_tta_momentum010_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_multiview_bn_tta_loco.py`

Design:

- Load the primary 3D global+MTL tau=0.03 AJU LOCO checkpoint.
- Adapt only BatchNorm running statistics using unlabeled split images and question IDs.
- Validation predictions are adapted on non-AJU validation images; AJU test predictions are adapted on AJU test images.
- No labels, clinical fields, scanner/acquisition fields, raw consortium, ROI values, evidence percentiles, or AEB features are used for adaptation.
- This is a transductive label-free TTA diagnostic, not the same protocol as the non-adaptive primary model.

Binary AJU result:

| model | pooled AUC | bacc | hip AUC | ratio AUC | MTL AUC | vent AUC |
|---|---:|---:|---:|---:|---:|---:|
| primary 3D | 0.879 | 0.785 | 0.808 | 0.924 | 0.858 | 0.940 |
| BN reset TTA | 0.878 | 0.791 | 0.808 | 0.919 | 0.854 | 0.940 |
| BN momentum TTA | 0.878 | 0.791 | 0.810 | 0.922 | 0.857 | 0.939 |
| morphometry simple-norm external bar | 0.910 | n/a | n/a | n/a | n/a | n/a |

Three-zone AJU result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| BN reset TTA | 0.624 | 0.649 | 0.644 | 0.945 |
| BN momentum TTA | 0.625 | 0.702 | 0.625 | 0.947 |

Subject-level bootstrap:

| comparison | all-question delta zone-bacc 95% CI | all-question delta far AUC 95% CI | decision |
|---|---:|---:|---|
| BN reset vs fixed 2.5D | +0.129 to +0.246 | +0.126 to +0.263 | positive versus lower bound |
| BN reset vs primary | -0.052 to +0.012 | -0.008 to +0.001 | not improved |
| BN reset vs original tri-view | -0.064 to +0.019 | -0.014 to +0.011 | not improved |
| BN momentum vs fixed 2.5D | +0.129 to +0.249 | +0.127 to +0.266 | positive versus lower bound |
| BN momentum vs primary | -0.057 to +0.018 | -0.004 to +0.002 | not improved |
| BN momentum vs original tri-view | -0.056 to +0.017 | -0.011 to +0.014 | not improved |

Decision:

- BN TTA is leakage-safe under the implemented label-free adaptation guardrail, but it is not a promotable method result.
- The source-mode smoke run exactly reproduces the primary AJU AUC/bacc, so the comparison is implementation-aligned.
- BN adaptation slightly improves fixed-threshold balanced accuracy and uncertain recall, but it does not improve AUC or far-boundary ranking over primary.
- The primary failure is therefore not mainly a BatchNorm target-domain statistics problem.
- Stop simple BN TTA variants unless moving to a substantially different, pre-registered TENT-style protocol with explicit far-positive preservation; even then it must clear the primary, tri-view, and morphometry bars.

## Representation Control Transition Synthesis

Runs:

- synthesis: `results/f04_roi_evidence_encoder/20260606_091614_v6_representation_control_transition_synthesis`
- script: `scripts/run_f04_v6_representation_control_transition_synthesis.py`
- reusable transition audit script: `scripts/run_f04_v6_candidate_threezone_transition_audit.py`

Included candidates:

- style consistency + boundary ranking
- DSBN vendor
- DSBN vendor+field fallback
- DINOv2 shallow probe
- BN reset TTA
- BN momentum TTA

Overall transition pattern:

| candidate | vs fixed 2.5D net gain | vs primary net gain | vs original tri-view net gain |
|---|---:|---:|---:|
| style consistency | +59 | +2 | +9 |
| DSBN vendor | +29 | -28 | -21 |
| DSBN vendor+field | +26 | -31 | -24 |
| DINOv2 | -12 | -31 | -32 |
| BN reset TTA | +46 | -11 | -4 |
| BN momentum TTA | +45 | -12 | -5 |

Primary-comparison failure mode by true zone:

| candidate | uncertain net gain | far-positive net gain | far-negative net gain |
|---|---:|---:|---:|
| style consistency | +9 | -15 | +8 |
| DSBN vendor | +13 | -10 | -31 |
| DSBN vendor+field | +7 | -11 | -27 |
| DINOv2 | -27 | -11 | +7 |
| BN reset TTA | +10 | -7 | -14 |
| BN momentum TTA | +15 | -9 | -18 |

Decision:

- The 3D-over-2.5D claim is further strengthened: all 3D-like candidates except DINOv2 recover many uncertain rows that fixed 2.5D never predicts.
- The repeated reason candidates fail as method novelty is now clear: they recover uncertain rows by sacrificing primary-correct far-boundary rows.
- DSBN mainly damages far-negative correctness; style consistency and BN TTA mainly damage far-positive correctness; DINOv2 fails both uncertain recovery and far-positive correctness.
- A useful next method cannot be another threshold, BN-stat, or generic invariance variant. It must preserve primary far-boundary polarity while adding boundary-sensitive uncertainty.
