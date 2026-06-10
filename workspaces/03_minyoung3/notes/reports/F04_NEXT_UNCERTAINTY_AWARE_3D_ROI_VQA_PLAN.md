# F04 Next Plan: Uncertainty-Aware 3D ROI-Grounded VQA

Updated: 2026-06-07

## 2026-06-07 Addendum: Current Direction

The prior uncertainty-aware plan remains useful as historical evidence, but it is no longer the best next experimental direction.

Current result after the raw-visible audits:

- Adjusted normative residual QA is the main bottleneck. Some labels, especially hippocampus-to-ventricle ratio far-positive rows, are not well aligned with raw image-visible anatomy.
- Raw-visible ROI-VQA is learnable from images. Raw-visible-trained 3D global+MTL models beat raw-visible-trained fixed 2.5D models on AJU, OASIS, and NACC held-out tests.
- Cross-cohort seed stability is positive: across AJU/OASIS/NACC, 3D beats 2.5D in every evaluated seed by AUC and validation-locked calibrated balanced accuracy. The minimum cohort seed delta is AUC `+0.159` and calibrated bacc `+0.146`.
- AJU is now audited with strict 2.5D LOCO baselines, not only the earlier all-train 2.5D baseline. This makes the AJU 3D advantage stronger rather than weaker.
- Recall-side claims are not symmetric, especially in OASIS and NACC. The robust claim is ranking and validation-locked operating performance, not uniform positive/negative recall superiority.

Current next experiment:

1. Treat raw-visible 3D ROI-aware VQA as the primary image-signal task.
2. Keep adjusted normative evidence as an audit/clinical interpretation layer, not as the main raw image-visible answer target.
3. Stress-test raw-visible 3D with larger external validation, seed stability, calibration stability, and question/ROI-specific error analysis.
4. Compare the image-task result against the morphometry CN/AD bar as a guardrail: morphometry + simple normalization reaches about `0.91` LOCO AUC, so disease-classification novelty cannot be claimed unless image methods approach that bar under comparable held-out protocols.

Input policy remains unchanged: model inputs are image tensors plus question ID only. ROI values, evidence percentiles, diagnosis, CDR, cohort/scanner, age/sex, and morphometry are target construction, stratification, provenance, or audit fields only.

## Current Research Task

We are studying image-only 3D ROI-grounded VQA from T1w MRI. The model receives
3D image tensors and a question ID. It must answer whether an anatomical ROI
evidence statement is supported. Clinical variables, cohort identity, ROI
values, evidence percentiles, and AEB features are not model inputs.

## Current Data

Authoritative manifest:

- `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`
- rows: 13,022
- subjects: 7,231
- final QC: all PASS
- N4 tensor/mask paths: 13,022 / 13,022 available
- complete Global CDR: 13,022 / 13,022
- complete core bilateral ROI fields for the current session questions

Matched VQA benchmark:

- `results/f04_roi_evidence_encoder/20260603_050611_3d_roi_grounded_vqa_design/matched_session_qa_with_3d_paths.csv`
- rows: 19,236
- sessions: 9,278
- subjects: 5,601
- split protocol: `cohort_dx_cdr_age_sex`
- subject and session split overlap: 0
- test positive rate: 0.5 for each question

Current realignment artifact:

- `results/f04_roi_evidence_encoder/20260603_101405_current_state_realignment`
- `results/f04_roi_evidence_encoder/20260604_050339_v6_manifest_result_realignment_and_next_design`

Latest corrected realignment:

- Official manifest remains ready: 13,022 rows, 7,231 subjects, all final QC PASS, and 13,022/13,022 N4 tensor/mask paths.
- Matched 3D ROI-grounded VQA benchmark: 19,236 QA rows, 9,278 sessions via `join_key`, 5,601 subjects via `subject_global_id`.
- Split leakage audit using `subject_global_id` and `join_key`: subject overlap 0 and session overlap 0 for train/val/test pairs.
- tau=0.03 hard-head frozen global+MTL fusion LOCO repeat aggregate is now stored in `tau003_loco_aggregate_by_consortium.csv`.

## Input and Output

Allowed model input:

- global 64x64x64 3D T1w tensor cache
- fixed bilateral MTL-crop 64x64x64 3D T1w tensor cache
- question ID / question embedding

Forbidden model input:

- consortium/cohort
- diagnosis, CDR, CDR-SB
- age, sex
- FreeSurfer ROI values
- ROI or evidence percentiles
- AEB features

Output:

- binary answer probability for each ROI-grounded question
- evaluation by pooled AUC, balanced accuracy, question-level AUC, cohort LOCO AUC, and calibration/boundary audits

## What We Learned

2.5D is insufficient for fine MTL anatomy:

- 2.5D pooled AUC: 0.732
- global 3D pooled AUC: 0.835
- fixed MTL crop 3D pooled AUC: 0.881

Naive fusion is not enough:

- random-init global+MTL fusion underperformed the local crop
- frozen pretrained global+MTL fusion improved pooled AUC to about 0.911
- branch ablation showed that the MTL branch is essential for hippocampal and MTL questions

Soft labels are the current technical signal:

- hard boundary exclusion failed
- tau 0.03 soft-label local pretraining improved ranking
- tau 0.05 improved in-split fusion further
- tau 0.05 also improved AJU hippocampal LOCO AUC

But tau 0.05 is not universally robust:

- ADNI/A4 pooled LOCO improved over tau 0.03
- AJU hippocampal improved over tau 0.03
- OASIS pooled, hippocampal, and MTL LOCO worsened
- AJU MTL also worsened versus tau 0.03

## Critical Interpretation

The novelty should not be phrased as "we found tau 0.05." That would be weak
and likely overfit. The stronger claim is:

Boundary-aware soft targets improve 3D ROI-grounded VQA by respecting
uncertainty near normative ROI cutoffs, but the uncertainty scale must be
controlled by ROI/question and validated under cohort holdout.

This converts the current empirical finding into a method:

1. ROI-grounded question-conditioned 3D global/local fusion.
2. Local ROI encoder pretraining with cutoff-distance soft labels.
3. Locked uncertainty selection using validation plus leave-cohort-out stress tests.

## Next Experiment 1: Question-Specific Soft-Label Temperature

Goal:

- Test whether one global tau is too blunt.
- Use a separate tau per question family: hippocampal, hippocampus-to-ventricle, MTL, ventricle.

Candidate grid:

- tau candidates: 0.03 and 0.05 only for now.
- Select tau per question using validation macro AUC with an OASIS penalty term.

Expected output:

- one local checkpoint per question-specific tau configuration
- frozen fusion result
- repeat seeds
- major-cohort LOCO

Success criterion:

- match or exceed tau 0.03 pooled LOCO in OASIS
- preserve tau 0.05 AJU hippocampal gain
- no drop greater than 0.01 AUC in any major pooled LOCO cohort versus primary frozen fusion

Execution update:

- run: `results/f04_roi_evidence_encoder/20260603_103343_v6_3d_mtl_crop_softlabel_qhybrid_hipmtl003_ratiovent005_image_only_vqa_full64`
- tau map:
  - hippocampal volume: 0.03
  - MTL atrophy evidence: 0.03
  - hippocampus-to-ventricle ratio: 0.05
  - ventricle enlargement: 0.05
- rationale: preserve the more conservative tau 0.03 for the OASIS-sensitive hippocampal/MTL questions, while allowing wider uncertainty for ratio/ventricle questions.

Result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc at 0.5 |
|---|---:|---:|---:|---:|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| soft-label MTL tau=0.03 | 0.905 | 0.878 | 0.879 | 0.639 |
| soft-label MTL tau=0.05 | 0.908 | 0.882 | 0.897 | 0.712 |
| question-specific hybrid | 0.874 | 0.836 | 0.854 | 0.802 |

Decision:

- Negative/mixed result. The hybrid improves fixed-threshold balanced accuracy,
  but AUC/ranking falls below the current fixed MTL crop and far below both
  soft-label single-temperature models.
- Do not promote this checkpoint to fusion/LOCO. The result suggests that
  naively mixing temperatures by question changes score calibration but damages
  the local representation ranking.

## Updated Calibration and Boundary Audit

The calibration/boundary audit was refreshed with tau 0.05, boundary-weighted
loss, and question-specific hybrid controls.

- audit: `results/f04_roi_evidence_encoder/20260603_103745_v6_calibration_boundary_audit`
- script: `scripts/run_f04_v6_calibration_boundary_audit.py`

Fixed-threshold comparison:

| model | pooled AUC | hippocampal AUC | MTL AUC | pooled bacc |
|---|---:|---:|---:|---:|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 |
| global 3D | 0.835 | 0.729 | 0.686 | 0.743 |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| boundary-weighted MTL | 0.862 | 0.866 | 0.867 | 0.562 |
| question-specific hybrid MTL | 0.874 | 0.836 | 0.854 | 0.802 |
| soft-label MTL tau=0.03 | 0.905 | 0.878 | 0.879 | 0.639 |
| soft-label MTL tau=0.05 | 0.908 | 0.882 | 0.897 | 0.712 |
| frozen fusion tau=0.03 | 0.917 | 0.889 | 0.897 | 0.824 |
| frozen fusion tau=0.05 | 0.920 | 0.892 | 0.906 | 0.831 |

Validation-threshold calibration shows the distinction between calibration and
ranking:

- boundary-weighted MTL recovers bacc to 0.772 only with an extreme threshold
  near 0.99, confirming score collapse.
- question-specific hybrid has high fixed bacc but lower AUC, so it is a
  calibration-biased model rather than a better representation.
- soft-label tau 0.05 local reaches validation-threshold bacc 0.822 and remains
  the best local AUC model.

AJU hippocampal comparison:

| model | AJU hippocampal AUC | fixed bacc | validation-threshold bacc |
|---|---:|---:|---:|
| 2.5D slab | 0.562 | 0.521 | 0.552 |
| current fixed MTL crop | 0.768 | 0.646 | 0.677 |
| soft-label MTL tau=0.05 | 0.805 | 0.635 | 0.708 |
| boundary-weighted MTL | 0.746 | 0.500 | 0.677 |
| question-specific hybrid MTL | 0.734 | 0.583 | 0.563 |
| frozen fusion tau=0.03 | 0.813 | 0.729 | 0.771 |
| frozen fusion tau=0.05 | 0.813 | 0.698 | 0.708 |

Scientific interpretation:

- 3D and local MTL views clearly outperform 2.5D, so the problem is not simply
  "no image signal."
- Soft labels improve ranking; hard boundary filtering and boundary weighting
  mainly distort calibration.
- The remaining bottleneck is cutoff-near, cohort-sensitive local anatomy,
  especially AJU/OASIS boundary regions.
- The next credible method should learn uncertainty in a smoother way than
  fixed per-question tau. Candidate directions are learned temperature,
  monotonic calibration head, or teacher-student distillation from ROI
  percentile distance.

## Fusion-Head Soft-Target Follow-Up

Question:

- The previous positive result used soft-label local MTL pretraining, but the
  final frozen fusion/head was still trained with hard binary labels.
- We tested whether applying train-only soft targets to the fusion/head stage
  improves ranking or reduces the tau 0.05 OASIS tradeoff.

Implementation:

- script updated: `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- new options:
  - `--soft-label-train-tau`
  - `--soft-label-train-tau-by-question-json`
- model input remains global 3D tensor + MTL crop tensor + question ID only.
- evidence percentile is used only to create train targets; validation/test
  labels remain binary.

Runs:

- tau 0.03 fusion-head soft: `results/f04_roi_evidence_encoder/20260603_104253_v6_multiview_preinit_frozen_global_mtlsoft_tau003_fusionhead_soft003_full64`
- tau 0.05 fusion-head soft: `results/f04_roi_evidence_encoder/20260603_104633_v6_multiview_preinit_frozen_global_mtlsoft_tau005_fusionhead_soft005_full64`
- tau 0.05 soft-head AJU LOCO: `results/f04_roi_evidence_encoder/20260603_105008_v6_multiview_preinit_frozen_global_mtlsoft_tau005_fusionhead_soft005_loco_AJU_screening`
- tau 0.05 soft-head OASIS LOCO: `results/f04_roi_evidence_encoder/20260603_105008_v6_multiview_preinit_frozen_global_mtlsoft_tau005_fusionhead_soft005_loco_OASIS_screening`
- refreshed audit: `results/f04_roi_evidence_encoder/20260603_105348_v6_calibration_boundary_audit`

In-split result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc |
|---|---:|---:|---:|---:|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| fusion tau 0.03 hard-head | 0.917 | 0.889 | 0.897 | 0.824 |
| fusion tau 0.03 soft-head | 0.917 | 0.889 | 0.897 | 0.823 |
| fusion tau 0.05 hard-head | 0.920 | 0.892 | 0.906 | 0.831 |
| fusion tau 0.05 soft-head | 0.916 | 0.892 | 0.905 | 0.827 |

AJU/OASIS LOCO diagnostic:

| model | cohort | pooled AUC | hippocampal AUC | MTL AUC | pooled bacc |
|---|---|---:|---:|---:|---:|
| primary hard MTL fusion | AJU | 0.848 | 0.756 | 0.818 | 0.750 |
| tau 0.03 hard-head | AJU | 0.879 | 0.808 | 0.858 | 0.785 |
| tau 0.05 hard-head | AJU | 0.866 | 0.813 | 0.837 | 0.776 |
| tau 0.05 soft-head | AJU | 0.871 | 0.810 | 0.849 | 0.750 |
| primary hard MTL fusion | OASIS | 0.920 | 0.924 | 0.872 | 0.838 |
| tau 0.03 hard-head | OASIS | 0.927 | 0.921 | 0.891 | 0.848 |
| tau 0.05 hard-head | OASIS | 0.914 | 0.872 | 0.861 | 0.838 |
| tau 0.05 soft-head | OASIS | 0.907 | 0.870 | 0.856 | 0.810 |

Decision:

- Negative result. Fusion-head soft targets do not improve in-split AUC over
  hard-head training.
- They also do not solve the tau 0.05 OASIS tradeoff; OASIS pooled AUC drops
  further from 0.914 to 0.907.
- Keep soft-labeling at the local MTL representation-pretraining stage, not the
  final fusion/head stage.

## Signed Evidence-Distance Auxiliary Distillation

Question:

- Soft labels help local MTL representation learning.
- We tested whether a more explicit continuous teacher, the signed distance from
  the ROI evidence cutoff, improves the local encoder.

Implementation:

- script updated: `scripts/run_f04_v6_3d_image_only_matched_vqa.py`
- new options:
  - `--aux-signed-distance-loss-weight`
  - `--aux-signed-distance-scale`
- auxiliary target:
  - signed positive evidence margin from the question cutoff
  - transformed with `tanh(signed_distance / scale)`
  - SmoothL1 auxiliary loss
- model input remains image tensor + question ID only.
- evidence percentile is used only as a train teacher; validation/test labels
  remain binary.

Runs:

- aux weight 0.10: `results/f04_roi_evidence_encoder/20260603_105840_v6_3d_mtl_crop_softlabel_tau005_auxdist_w010_s010_image_only_vqa_full64`
- aux weight 0.02: `results/f04_roi_evidence_encoder/20260603_110312_v6_3d_mtl_crop_softlabel_tau005_auxdist_w002_s010_image_only_vqa_full64`
- refreshed audit: `results/f04_roi_evidence_encoder/20260603_110658_v6_calibration_boundary_audit`

Result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc |
|---|---:|---:|---:|---:|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| soft-label MTL tau=0.05 | 0.908 | 0.882 | 0.897 | 0.712 |
| aux-distance weight 0.10 | 0.871 | 0.870 | 0.875 | 0.718 |
| aux-distance weight 0.02 | 0.887 | 0.860 | 0.886 | 0.653 |
| frozen fusion tau=0.05 | 0.920 | 0.892 | 0.906 | 0.831 |

Decision:

- Negative/mixed result. Both auxiliary-distance settings remain far above the
  2.5D slab baseline, confirming image signal, but neither beats the existing
  soft-label local encoder.
- Auxiliary signed-distance prediction appears to compete with the binary
  anatomical ranking objective rather than improving it.
- Do not promote these checkpoints to frozen fusion.
- The most defensible current method remains: soft-label local MTL
  representation pretraining followed by hard-label frozen global/local fusion.

## Next Experiment 2: Boundary-Weighted Loss Instead of Soft Target Only

Goal:

- Keep binary labels but reduce overconfidence near cutoff.
- This tests whether score smoothing or example weighting is the real mechanism.

Method:

- BCE target remains binary.
- Weight is lower near the cutoff and normal far from the cutoff.
- Evidence percentile is used only to compute train loss weight, not model input.

Expected output:

- local MTL weighted-loss checkpoint
- frozen fusion result
- comparison against tau 0.03 and tau 0.05

Success criterion:

- improve calibration without sacrificing local ranking
- avoid OASIS degradation seen in tau 0.05

Execution update:

- run: `results/f04_roi_evidence_encoder/20260603_102904_v6_3d_mtl_crop_boundary_weight005_min025_image_only_vqa_full64`
- method: binary BCE target, train-only boundary loss weight with margin 0.05 and minimum weight 0.25
- train examples: 13,854, validation/test unchanged
- model input: image tensor + question ID only

Result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc at 0.5 |
|---|---:|---:|---:|---:|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| soft-label MTL tau=0.03 | 0.905 | 0.878 | 0.879 | 0.639 |
| soft-label MTL tau=0.05 | 0.908 | 0.882 | 0.897 | 0.712 |
| boundary-weighted MTL | 0.862 | 0.866 | 0.867 | 0.562 |

Decision:

- Negative result. The method remains better than 2.5D, but it is worse than
  the current fixed MTL crop and much worse than soft-label local pretraining.
- The score distribution is compressed around the decision threshold, producing
  poor balanced accuracy.
- Do not promote this checkpoint to fusion/LOCO. The failure suggests that
  uncertainty should change the target distribution, not merely downweight
  cutoff-adjacent examples under a hard binary target.

## Next Experiment 3: Locked Candidate Evaluation

Only after choosing one candidate:

- rerun 5 seeds in-split
- rerun LOCO for ADNI, A4, NACC, OASIS, AJU
- run calibration/boundary audit including the final candidate
- freeze all hyperparameters before final test reporting

## Immediate Decision

Do not lock tau 0.05 as final. Use tau 0.03 as the conservative soft-label
candidate and tau 0.05 as evidence that uncertainty scale matters. The next
implementation should be question-specific or validation-locked
uncertainty-aware local pretraining, not another unconstrained sweep.

## OASIS LOCO Repeat Robustness Check

Question:

- Tau 0.05 improves in-split performance and AJU hippocampal signal, but the
  single-seed OASIS LOCO result is worse than tau 0.03.
- Because OASIS test size is small, this must be repeated before deciding that
  tau 0.05 has a real OASIS generalization tradeoff.

Interruption note:

- Four OASIS repeat jobs were started around `20260603_111126`, but the runtime
  environment changed while they were running.
- The following directories are incomplete and must not be used for metrics:
  - `results/f04_roi_evidence_encoder/20260603_111126_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_OASIS_seed20260604_screening`
  - `results/f04_roi_evidence_encoder/20260603_111126_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_OASIS_seed20260605_screening`
  - `results/f04_roi_evidence_encoder/20260603_111126_v6_multiview_preinit_frozen_global_mtlsoft_tau005_loco_OASIS_seed20260604_screening`
  - `results/f04_roi_evidence_encoder/20260603_111126_v6_multiview_preinit_frozen_global_mtlsoft_tau005_loco_OASIS_seed20260605_screening`
- They contain config/example files only and no `summary.json` or
  `metrics_by_question.csv`.
- They are excluded from the current aggregate. Re-run with a fresh timestamp
  before making a final OASIS tau selection.

### OASIS LOCO Repeat Result

Completed rerun aggregate:

- audit: `results/f04_roi_evidence_encoder/20260604_020107_v6_OASIS_LOCO_tau003_tau005_repeat_audit`
- completed tau 0.03 reruns:
  - `20260604_020106_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_OASIS_seed20260604_rerun`
  - `20260604_020107_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_OASIS_seed20260605_rerun`
- completed tau 0.05 reruns:
  - `20260604_020107_v6_multiview_preinit_frozen_global_mtlsoft_tau005_loco_OASIS_seed20260604_rerun`
  - `20260604_020106_v6_multiview_preinit_frozen_global_mtlsoft_tau005_loco_OASIS_seed20260605_rerun`

OASIS 3-seed LOCO AUC:

| model | pooled AUC mean | hippocampal AUC mean | MTL AUC mean | pooled bacc mean |
|---|---:|---:|---:|---:|
| primary hard MTL fusion | 0.920 | 0.924 | 0.872 | 0.838 |
| soft-label fusion tau 0.03 | 0.924 | 0.917 | 0.883 | 0.843 |
| soft-label fusion tau 0.05 | 0.912 | 0.869 | 0.857 | 0.835 |

Delta AUC:

| comparison | pooled | hippocampal | MTL |
|---|---:|---:|---:|
| tau 0.03 minus primary | +0.004 | -0.006 | +0.011 |
| tau 0.05 minus primary | -0.008 | -0.054 | -0.015 |
| tau 0.05 minus tau 0.03 | -0.012 | -0.048 | -0.026 |

2.5D OASIS in-split context:

| model | pooled AUC | hippocampal AUC | MTL AUC |
|---|---:|---:|---:|
| 2.5D slab OASIS subset | 0.826 | 0.773 | 0.726 |
| soft-label fusion tau 0.03 OASIS LOCO | 0.924 | 0.917 | 0.883 |
| soft-label fusion tau 0.05 OASIS LOCO | 0.912 | 0.869 | 0.857 |

Decision:

- The OASIS tau 0.05 degradation is reproducible across seeds, not a single-seed artifact.
- Tau 0.03 is the conservative cross-cohort candidate.
- Tau 0.05 remains useful as an AJU-hippocampal stress-test variant, but should not be the final locked model unless the paper claim is explicitly AJU-focused.
- The main paper candidate should be tau 0.03 hard-head frozen fusion, with tau 0.05 reported as a tradeoff/ablation.



## Experiment: 3D Multiview Occlusion and 2.5D Failure Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_053400_v6_3d_multiview_tau003_occlusion_2p5d_failure_audit`
- script: `scripts/run_f04_v6_3d_multiview_occlusion_audit.py`

Result:

| test | result |
|---|---:|
| baseline 3D AUC | 0.917 |
| zero global branch AUC | 0.732 |
| zero MTL branch AUC | 0.581 |
| 3D AUC on identical QA rows | 0.917 |
| 2.5D AUC on identical QA rows | 0.732 |
| 3D-only-correct rows at threshold 0.5 | 596 |
| 2.5D-only-correct rows at threshold 0.5 | 188 |

Question-level interpretation:

- Hippocampal volume: zero-MTL AUC drop 0.169 versus zero-global drop 0.038.
- MTL atrophy: zero-MTL AUC drop 0.233 versus zero-global drop 0.020.
- Hippocampus-to-ventricle and ventricle tasks show smaller AUC drops under branch zeroing, so occlusion mainly shifts calibration/margins for those tasks.
- 2.5D-to-3D gains are largest for MTL atrophy and hippocampal volume, matching the hypothesis that 2.5D loses local 3D anatomical signal.

Problems and limitations:

- Whole-branch zeroing is a distribution-shift perturbation. Treat AUC drop as ranking-dependence evidence; fixed-threshold balanced accuracy can collapse from calibration shift.
- MTL grid occlusion is currently in cache-grid coordinates. It needs visual overlay/montage before making anatomical-location claims.
- AJU hippocampal remains the main weak held-out case; this audit supports MTL dependence but does not solve AJU-specific errors.

Decision:

- The current evidence supports framing the method as 3D ROI-aware VQA rather than generic 3D classification.
- Next experiment should generate top damaging MTL-grid visual overlays and selected case montages for 3D-only-correct and both-wrong examples.


Case-level follow-up completed:

- `results/f04_roi_evidence_encoder/20260604_053400_v6_3d_multiview_tau003_occlusion_2p5d_failure_audit/case_review`
- AJU hippocampal: 96 rows; 3D AUC 0.813 vs 2.5D AUC 0.562.
- Failure classes: both correct 39, 3D-only correct 31, both wrong 15, 2.5D-only correct 11.
- 2.5D slab join sanity: prefix match rate 1.0, so the 2.5D comparison rows are session-aligned through `image_only_slab_examples.csv`.
- Error diagnosis: many both-wrong cases are near-boundary false negatives, but at least one far-from-cutoff false positive suggests a stronger representation/QC failure.

Decision update:

- Keep tau=0.03 3D multiview as primary.
- Do not treat AJU hippocampal as solved; it remains the key hard-case analysis section.
- Next experiment should be manual/automated QC of selected far-from-cutoff errors before another model variant.


Hard failure QC/context audit completed:

- `results/f04_roi_evidence_encoder/20260604_053400_v6_3d_multiview_tau003_occlusion_2p5d_failure_audit/case_review/hard_failure_qc_context.csv`
- `results/f04_roi_evidence_encoder/20260604_053400_v6_3d_multiview_tau003_occlusion_2p5d_failure_audit/case_review/hard_failure_qc_context_summary.csv`
- AJU hippocampal error cases: n=26, QC-flagged n=0, evidence/source percentile mismatch max=0, mean boundary distance 0.057. Scanner counts: GE 24, PHILIPS 1, SIEMENS 1.
- Far-from-cutoff both-wrong cases: n=29, QC-flagged n=0, evidence/source percentile mismatch max=0, mean boundary distance 0.386.

Interpretation update:

- These hard failures are not explained by simple manifest join errors or recorded QC failure.
- AJU hippocampal residual errors are strongly GE-heavy, so the next model-side hypothesis should be scanner/style robustness or harmonization, not another blind fusion architecture.
- Far-from-cutoff both-wrong cases remain the cleanest set for manual visual review and potential failure-mode figure.


## Experiment: 3D Style Perturbation and Robust Style-Augmented Unfreeze

Runs:

- primary perturbation audit: `results/f04_roi_evidence_encoder/20260604_053400_v6_3d_multiview_tau003_occlusion_2p5d_failure_audit/case_review/style_perturbation_audit`
- head-only style augmentation: `results/f04_roi_evidence_encoder/20260604_095250_v6_multiview_preinit_frozen_global_mtlsoft_tau003_styleaug_mtlcontrast_smooth_probe_full64`
- staged low-LR unfreeze style augmentation: `results/f04_roi_evidence_encoder/20260604_100254_v6_multiview_preinit_tau003_styleaug_staged_unfreeze_lr5e5_probe_full64`
- repeat seed aggregate: `results/f04_roi_evidence_encoder/20260604_100254_v6_multiview_preinit_tau003_styleaug_staged_unfreeze_lr5e5_probe_full64/repeat_seed_aggregate`
- robustness comparison: `results/f04_roi_evidence_encoder/20260604_100254_v6_multiview_preinit_tau003_styleaug_staged_unfreeze_lr5e5_probe_full64/robustness_comparison`

Clean test AUC:

| model | pooled | hippocampal | MTL |
|---|---:|---:|---:|
| primary tau=0.03 frozen fusion | 0.917 | 0.889 | 0.897 |
| head-only style augmentation | 0.914 | 0.889 | 0.893 |
| staged style-aug unfreeze seed 20260603 | 0.919 | 0.898 | 0.904 |

Three-seed aggregate:

| question | primary mean±sd | staged style-aug mean±sd | mean delta |
|---|---:|---:|---:|
| pooled | 0.9176±0.0017 | 0.9191±0.0002 | +0.0015 |
| hippocampal volume | 0.8902±0.0014 | 0.8967±0.0009 | +0.0065 |
| MTL atrophy | 0.8973±0.0008 | 0.9042±0.0018 | +0.0069 |
| hippocampus/ventricle ratio | 0.8987±0.0002 | 0.8942±0.0012 | -0.0045 |
| ventricle enlargement | 0.9777±0.0002 | 0.9753±0.0004 | -0.0025 |

Perturbation robustness:

| scope | perturbation | primary AUC | staged AUC | primary flip | staged flip |
|---|---|---:|---:|---:|---:|
| all | MTL smooth3 | 0.709 | 0.903 | 0.333 | 0.099 |
| all | both smooth3 | 0.735 | 0.894 | 0.444 | 0.111 |
| all | MTL contrast down 0.8 | 0.815 | 0.918 | 0.241 | 0.066 |
| AJU hippocampal GE | MTL smooth3 | 0.690 | 0.740 | 0.630 | 0.136 |
| AJU hippocampal GE | both smooth3 | 0.671 | 0.719 | 0.630 | 0.173 |

Decision:

- Head-only style augmentation is not sufficient: it improves robustness but lowers clean AUC.
- Staged low-LR encoder unfreezing with branch-specific train-only style augmentation is the current most promising technical candidate.
- The gain is not uniform: hippocampal and MTL tasks improve, while ratio/ventricle tasks slightly decline.
- Do not claim final novelty yet. The next required check is LOCO validation, especially AJU and OASIS, plus repeat-seed LOCO if the first pass is positive.


## Experiment: AJU LOCO Check for Staged Style-Aug Unfreeze

Run:

- `results/f04_roi_evidence_encoder/20260604_102539_v6_multiview_preinit_tau003_styleaug_staged_unfreeze_lr5e5_loco_AJU_screening`
- comparison: `results/f04_roi_evidence_encoder/20260604_102539_v6_multiview_preinit_tau003_styleaug_staged_unfreeze_lr5e5_loco_AJU_screening/loco_comparison`

Result:

| question | primary tau=0.03 frozen | staged style-aug | delta |
|---|---:|---:|---:|
| pooled | 0.879 | 0.865 | -0.014 |
| hippocampal volume | 0.808 | 0.797 | -0.011 |
| hippocampus/ventricle ratio | 0.924 | 0.915 | -0.009 |
| MTL atrophy | 0.858 | 0.835 | -0.023 |
| ventricle enlargement | 0.940 | 0.931 | -0.010 |

Interpretation:

- This is a negative held-out-cohort result.
- The staged style-aug method improves in-split mean AUC and deterministic perturbation robustness, but does not improve AJU generalization when AJU is excluded from train/val.
- This suggests the augmentation is learning invariance to simple intensity/blur perturbations, not true cohort/scanner domain generalization.
- Keep tau=0.03 frozen fusion as the conservative primary until a candidate beats it under AJU LOCO.

Next method hypothesis:

- Test consistency/domain-robust training that constrains clean and perturbed predictions while preserving frozen-primary behavior, rather than simply unfreezing encoders under augmentation.
- Candidate design: primary frozen teacher + train-time perturbation consistency on global/MTL views + small supervised loss, with AJU/OASIS LOCO as the promotion gate.


## Experiment: AJU LOCO Clean-vs-Perturbed Consistency Controls

Runs:

- staged consistency w5: `results/f04_roi_evidence_encoder/20260604_103744_v6_multiview_preinit_tau003_styleconsistency_w5_staged_unfreeze_lr5e5_loco_AJU_screening`
- frozen consistency w5: `results/f04_roi_evidence_encoder/20260604_104421_v6_multiview_preinit_tau003_styleconsistency_w5_frozen_loco_AJU_screening`
- frozen consistency w1: `results/f04_roi_evidence_encoder/20260604_104935_v6_multiview_preinit_tau003_styleconsistency_w1_frozen_loco_AJU_screening`
- comparison: `results/f04_roi_evidence_encoder/20260604_104935_v6_multiview_preinit_tau003_styleconsistency_w1_frozen_loco_AJU_screening/consistency_loco_comparison`

AJU LOCO AUC:

| question | 2.5D context | primary tau=0.03 | style-aug unfreeze | consistency w5 frozen | consistency w1 frozen |
|---|---:|---:|---:|---:|---:|
| pooled | 0.684 | 0.879 | 0.865 | 0.868 | 0.871 |
| hippocampal volume | 0.562 | 0.808 | 0.797 | 0.790 | 0.802 |
| MTL atrophy | 0.588 | 0.858 | 0.835 | 0.847 | 0.855 |

Interpretation:

- 3D still clearly beats the fixed 2.5D context on AJU, so the problem is not that 3D lacks signal.
- Generic perturbation robustness and clean-vs-perturbed consistency do not improve AJU held-out generalization.
- The staged consistency w5 run selected epoch 4, before consistency/unfreeze started, so its tie with primary is not a positive result.
- The current failure mode is more likely cohort/scanner-domain mismatch or cohort-specific anatomy/preprocessing distribution, not just local intensity/blur fragility.

Decision:

- Keep tau=0.03 frozen fusion as conservative primary.
- Treat style augmentation and clean-vs-perturbed consistency as documented negative controls.
- Next experiment should explicitly use scanner/cohort-aware validation or domain-invariant representation constraints, with AJU LOCO as the first gate.


## Audit: AJU LOCO Domain Gap

Run:

- `results/f04_roi_evidence_encoder/20260604_105848_v6_loco_domain_gap_audit_AJU`
- script: `scripts/run_f04_v6_loco_domain_gap_audit.py`

Key findings:

| comparison | observation |
|---|---|
| GE coverage | AJU test is GE-dominant, but nonheldout train/val also has substantial GE coverage |
| hippocampal GE evidence tail | AJU test q90 0.556 vs nonheldout train/val GE q90 0.782 |
| MTL GE evidence tail | AJU test q90 0.497 vs nonheldout train/val GE q90 0.798 |
| 2.5D context | AJU fixed 2.5D context remains much lower than 3D, especially hippocampal and MTL questions |

Interpretation:

- AJU failure is not explained by complete lack of GE scanner exposure.
- The more plausible failure mode is cohort+scanner+anatomical distribution shift: AJU GE examples occupy a different evidence-percentile distribution than nonheldout GE examples.
- Generic perturbation/consistency objectives are too weak because they simulate style changes but do not align cohort-specific anatomical distributions.

Next experiment proposal:

- Try domain-stratified or scanner/cohort-balanced sampling/loss only if it preserves the image-only input policy.
- Promotion gate remains AJU LOCO pooled and hippocampal/MTL AUC versus tau=0.03 frozen fusion.


## Experiment: AJU LOCO Cohort-Balanced Sampler

Run:

- `results/f04_roi_evidence_encoder/20260604_110310_v6_multiview_preinit_tau003_frozen_cohort_question_label_balanced_loco_AJU_screening`
- comparison: `results/f04_roi_evidence_encoder/20260604_110310_v6_multiview_preinit_tau003_frozen_cohort_question_label_balanced_loco_AJU_screening/balanced_sampler_loco_comparison`

AJU LOCO AUC:

| question | primary tau=0.03 | balanced sampler | delta |
|---|---:|---:|---:|
| pooled | 0.879 | 0.870 | -0.009 |
| hippocampal volume | 0.808 | 0.809 | +0.000 |
| hippocampus/ventricle ratio | 0.924 | 0.922 | -0.002 |
| MTL atrophy | 0.858 | 0.860 | +0.002 |
| ventricle enlargement | 0.940 | 0.944 | +0.004 |

Decision:

- Mixed/negative. Cohort/question/label balancing gives tiny hippocampal/MTL gains but loses pooled AUC.
- It does not solve AJU held-out generalization.
- Further work should focus on explaining AJU-specific anatomical distribution shift or designing a method with task-specific tradeoff control.


## Audit: AJU LOCO Error Structure and Validation-Selected Blends

Runs:

- error structure: `results/f04_roi_evidence_encoder/20260604_111215_v6_aju_loco_error_structure_audit`
- validation-selected global blend: `results/f04_roi_evidence_encoder/20260604_111439_v6_aju_loco_validation_blend_audit`
- question-specific selection: `results/f04_roi_evidence_encoder/20260604_111439_v6_aju_loco_validation_blend_audit/question_specific_selection`

AJU LOCO AUC:

| model | pooled | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|
| 2.5D context | 0.684 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary | 0.879 | 0.808 | 0.924 | 0.858 | 0.940 |
| balanced sampler | 0.870 | 0.809 | 0.922 | 0.860 | 0.944 |
| validation-selected blend | 0.875 | 0.806 | 0.922 | 0.861 | 0.942 |
| question-specific selection | 0.875 | 0.809 | 0.924 | 0.860 | 0.944 |

Error structure:

- Primary wrong but 2.5D correct: hippocampal 11, MTL 9.
- All 3D candidates wrong: hippocampal 23, MTL 14.
- All models including 2.5D wrong: hippocampal 13, MTL 6.
- Balanced sampler fixes some MTL primary errors but introduces enough other errors that pooled AJU AUC remains lower.

Decision:

- Validation-selected ensembling/selection does not beat primary tau=0.03 frozen fusion under AJU LOCO.
- 3D remains much stronger than 2.5D, so the bottleneck is not absence of 3D image signal.
- Remaining effort should focus on all-3D-wrong AJU cases: visual/QC morphology review and task-specific failure characterization before more model variants.


## Audit: AJU All-3D-Wrong Visual/QC Morphology

Run:

- `results/f04_roi_evidence_encoder/20260604_112228_v6_aju_all3d_wrong_visual_qc_audit`
- script: `scripts/run_f04_v6_aju_all3d_wrong_visual_qc_audit.py`

Scope:

- all-3D-wrong AJU rows: 57
- viewed groups: hippocampal false negative, hippocampal false positive, MTL false negative
- montage layout: five full-volume axial 2.5D-like slices plus orthogonal MTL crop views
- green contour: brain mask boundary
- audit-only context: evidence percentile, boundary distance, scanner, diagnosis, age, sex, 2.5D/3D candidate scores

QC summary:

| group | load ok | mean crop mask frac | mean crop std | evidence mean | boundary distance mean |
|---|---:|---:|---:|---:|---:|
| hippocampal false negative | 1.000 | 0.642 | 0.973 | 0.051 | 0.049 |
| hippocampal false positive | 1.000 | 0.663 | 0.974 | 0.171 | 0.071 |
| MTL false negative | 1.000 | 0.661 | 0.976 | 0.088 | 0.012 |
| MTL false positive | 1.000 | 0.651 | 0.981 | 0.174 | 0.074 |

Visual interpretation:

- The generated montages are readable and do not show a systematic crop, load, or mask failure.
- Hippocampal false negatives include many cutoff-near samples, so they are plausibly label-boundary/uncertainty failures rather than pure image corruption.
- MTL false negatives are especially close to the cutoff, with mean boundary distance 0.012.
- The remaining far-from-boundary false positives/false negatives should be treated as representation blind spots, not as an argument that 3D lacks signal.

Decision:

- Do not spend the next cycle rebuilding the same fixed MTL crop or generic perturbation augmentation.
- The next credible method needs to separate two failure regimes:
  - cutoff-near cases: uncertainty-aware supervision/calibration should reduce overconfident wrong decisions.
  - far-from-boundary cases: representation learning must improve local anatomical discrimination.

Immediate next experiment design:

- Train a two-head 3D ROI VQA model with the same image-only input policy.
- Head 1 predicts the binary answer.
- Head 2 predicts boundary proximity or uncertainty bin from train-only evidence distance.
- At inference, use Head 2 only to calibrate or temper Head 1, not to expose ROI values.
- Promotion gate: beat tau=0.03 frozen fusion on AJU LOCO pooled and hippocampal/MTL AUC, while keeping OASIS LOCO from regressing.


## Experiment: AJU LOCO Uncertainty-Auxiliary Heads

Runs:

- `results/f04_roi_evidence_encoder/20260604_113742_v6_multiview_preinit_tau003_uncertainty_aux_w02_frozen_loco_AJU_screening`
- `results/f04_roi_evidence_encoder/20260604_114239_v6_multiview_preinit_tau003_uncertainty_aux_w005_frozen_loco_AJU_screening`
- `results/f04_roi_evidence_encoder/20260604_114656_v6_multiview_preinit_tau003_uncertainty_aux_w005_staged_unfreeze_lr5e5_loco_AJU_screening`

AJU LOCO AUC:

| model | pooled | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|
| 2.5D context | 0.684 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary tau=0.03 | 0.879 | 0.808 | 0.924 | 0.858 | 0.940 |
| uncertainty aux w0.20 frozen | 0.875 | 0.806 | 0.913 | 0.858 | 0.941 |
| uncertainty aux w0.05 frozen | 0.873 | 0.805 | 0.918 | 0.860 | 0.943 |
| uncertainty aux w0.05 staged unfreeze | 0.867 | 0.797 | 0.922 | 0.838 | 0.937 |

Decision:

- Negative/mixed. The independent uncertainty-proximity head does not beat the primary tau=0.03 frozen model under AJU LOCO.
- Validation-selected uncertainty tempering does not fix the issue. The selected alpha is 0.0 or very small, and test AUC does not improve.
- Staged unfreeze improves validation AUC but worsens held-out AJU, matching the earlier pattern that validation gains do not necessarily transfer to AJU.
- Conclusion: predicting cutoff proximity as a parallel auxiliary task is not sufficient. It does not change the answer ranking in the right way.


## Experiment: Boundary-Aware Pairwise Ranking

Runs:

- `results/f04_roi_evidence_encoder/20260604_115502_v6_multiview_preinit_tau003_boundary_ranking_w01_frozen_loco_AJU_screening`
- `results/f04_roi_evidence_encoder/20260604_115857_v6_multiview_preinit_tau003_boundary_ranking_w002_frozen_loco_AJU_screening`
- calibration audit: `results/f04_roi_evidence_encoder/20260604_115857_v6_multiview_preinit_tau003_boundary_ranking_w002_frozen_loco_AJU_screening/questionwise_calibration_audit`

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| primary tau=0.03 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| boundary ranking w0.10 | 0.872 | 0.884 | 0.809 | 0.928 | 0.855 | 0.944 |
| boundary ranking w0.02 | 0.876 | 0.886 | 0.810 | 0.928 | 0.862 | 0.944 |

Interpretation:

- Boundary ranking w0.02 improves all four question-level AUCs, including hippocampal and MTL.
- It still loses pooled all-row AUC and balanced accuracy, so it cannot be promoted as the primary model.
- Question-wise validation Platt calibration does not recover pooled all-row AUC; it lowers pooled AUC for both primary and boundary-ranking models.
- The ranking loss quickly becomes near zero, suggesting far-from-boundary positive/negative ordering is already mostly solved. The remaining bottleneck is cross-question score scale plus near-boundary/AJU-specific morphology.

Decision:

- Keep tau=0.03 frozen fusion as the conservative primary.
- Retain boundary-ranking w0.02 as a scientifically interesting candidate because it improves macro question AUC, but mark it as not promoted due to pooled AJU loss.
- Next direction should not be another global auxiliary loss. It should target question-specific calibration or high-resolution ROI-local representation while keeping LOCO as the gate.


## Experiment: Question-Specific Answer Heads

Runs:

- affine head: `results/f04_roi_evidence_encoder/20260604_125531_v6_multiview_preinit_tau003_question_affine_frozen_loco_AJU_screening`
- independent head: `results/f04_roi_evidence_encoder/20260604_125839_v6_multiview_preinit_tau003_question_head_frozen_loco_AJU_screening`
- comparison report: `results/f04_roi_evidence_encoder/20260604_125839_v6_multiview_preinit_tau003_question_head_frozen_loco_AJU_screening/QUESTION_SPECIFIC_HEAD_AJU_LOCO_REPORT.md`

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary tau=0.03 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| boundary ranking w0.02 | 0.876 | 0.886 | 0.810 | 0.928 | 0.862 | 0.944 |
| question affine | 0.872 | 0.881 | 0.807 | 0.921 | 0.850 | 0.946 |
| question head | 0.867 | 0.880 | 0.799 | 0.926 | 0.852 | 0.942 |

Decision:

- Negative. Question-specific affine/head structures do not beat the primary tau=0.03 model under AJU LOCO.
- Affine improves threshold balanced accuracy but loses AUC, so it is mainly calibration/threshold movement rather than a better ranking model.
- Independent per-question heads add flexibility but appear less stable under held-out AJU.
- Boundary-ranking w0.02 remains the only candidate with macro-question AUC improvement, but it still misses pooled all-row promotion.

Next scientific interpretation:

- The remaining problem is not simply shared-head interference.
- Current fixed global+MTL crop representation is already strong for far-from-boundary ordering.
- The unresolved gap is likely in ROI-local morphology detail, especially hippocampal/MTL near-boundary and AJU-domain cases.
- The next credible experiment should change the image representation itself, not just the final head: for example a higher-resolution MTL/hippocampal local branch or ROI-centered crop derived from mask/atlas geometry, with 2.5D and primary tau=0.03 as fixed comparators.


## Experiment: Higher-Resolution Fixed MTL Crop

Artifacts:

- cache smoke: `results/f04_roi_evidence_encoder/20260604_130535_v6_3d_mtl_bilateral_crop_cache_smoke90_80`
- full MTL80 cache: `results/f04_roi_evidence_encoder/20260604_130651_v6_3d_mtl_bilateral_crop_cache_full80`
- in-split local MTL80: `results/f04_roi_evidence_encoder/20260604_132342_v6_3d_mtl_bilateral_crop_softlabel_tau003_image_only_vqa_full80`
- MTL80 fusion AJU LOCO: `results/f04_roi_evidence_encoder/20260604_133001_v6_multiview_preinit_frozen_global_mtl80soft_tau003_loco_AJU_screening`
- MTL80 local AJU LOCO lr2e-3: `results/f04_roi_evidence_encoder/20260604_133653_v6_3d_mtl80_softlabel_tau003_loco_AJU_screening`
- MTL80 local AJU LOCO lr1e-3: `results/f04_roi_evidence_encoder/20260604_134224_v6_3d_mtl80_softlabel_tau003_lr1e3_loco_AJU_screening`

Cache:

- crop box: `32:168,48:168,35:125`
- shape: `9278 x 1 x 80 x 80 x 80`
- size: about 8.9GB
- failures: 0
- subject/session split overlap: 0

In-split local AUC:

| model | pooled | hippocampal | ratio | MTL | ventricle | pooled bacc |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D | 0.732 | 0.658 | 0.774 | 0.633 | 0.855 | 0.663 |
| MTL64 tau=0.03 | 0.905 | 0.878 | 0.886 | 0.879 | 0.972 | 0.639 |
| MTL80 tau=0.03 | 0.905 | 0.883 | 0.893 | 0.894 | 0.979 | 0.768 |

AJU LOCO AUC:

| model | pooled | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|
| 2.5D AJU context | 0.684 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary tau=0.03 fusion | 0.879 | 0.808 | 0.924 | 0.858 | 0.940 |
| MTL80 fusion | 0.867 | 0.788 | 0.922 | 0.820 | 0.944 |
| MTL80 local lr2e-3 | 0.783 | 0.744 | 0.905 | 0.803 | 0.946 |
| MTL80 local lr1e-3 | 0.851 | 0.777 | 0.880 | 0.822 | 0.935 |

Decision:

- Mixed/negative. MTL80 improves in-split local question AUC and balanced accuracy over MTL64, but it does not beat the primary under AJU LOCO.
- Lower LR improves MTL80 local AJU LOCO substantially, so optimization instability is real.
- Even after lower LR, MTL80 local remains below primary on pooled, hippocampal, ratio, and MTL AUC.
- MTL80 fusion is also below primary, especially hippocampal and MTL, so higher fixed-crop resolution alone does not solve AJU domain shift.
- The next representation direction should not be "larger fixed crop" alone. It should add domain-stable local pretraining, better normalization, or a more anatomically targeted ROI-local crop before fusion.


## Experiment: MTL80 Domain-Stable Normalization

Runs:

- BatchNorm reference lr1e-3: `results/f04_roi_evidence_encoder/20260604_134224_v6_3d_mtl80_softlabel_tau003_lr1e3_loco_AJU_screening`
- InstanceNorm: `results/f04_roi_evidence_encoder/20260604_135506_v6_3d_mtl80_instance_norm_tau003_lr1e3_loco_AJU_screening`
- GroupNorm: `results/f04_roi_evidence_encoder/20260604_135829_v6_3d_mtl80_group_norm_tau003_lr1e3_loco_AJU_screening`
- comparison report: `results/f04_roi_evidence_encoder/20260604_135829_v6_3d_mtl80_group_norm_tau003_lr1e3_loco_AJU_screening/MTL80_NORMALIZATION_AJU_LOCO_AUDIT.md`

AJU LOCO AUC:

| model | pooled | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|
| 2.5D AJU context | 0.684 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary tau=0.03 fusion | 0.879 | 0.808 | 0.924 | 0.858 | 0.940 |
| MTL80 BatchNorm lr1e-3 | 0.851 | 0.777 | 0.880 | 0.822 | 0.935 |
| MTL80 InstanceNorm lr1e-3 | 0.775 | 0.667 | 0.890 | 0.650 | 0.943 |
| MTL80 GroupNorm lr1e-3 | 0.735 | 0.579 | 0.851 | 0.549 | 0.922 |

Decision:

- Negative. Replacing BatchNorm with InstanceNorm or GroupNorm does not improve AJU domain robustness.
- InstanceNorm/GroupNorm substantially weaken hippocampal and MTL anatomical signal.
- Normalization-only style invariance is too blunt for this task. It removes useful local contrast/shape cues along with scanner/style variation.
- The next domain-stable representation attempt should preserve anatomical contrast while reducing domain shift, for example controlled style augmentation/distillation or ROI-focused pretraining rather than replacing all normalization layers.


## Experiment: MTL80 Style-Augmented Local Representation and Fusion

Runs:

- MTL80 local strong style augmentation: `results/f04_roi_evidence_encoder/20260604_140815_v6_3d_mtl80_batchnorm_styleaug_tau003_lr1e3_loco_AJU_screening`
- MTL80 local mild style augmentation: `results/f04_roi_evidence_encoder/20260604_141553_v6_3d_mtl80_batchnorm_mildstyleaug_tau003_lr1e3_loco_AJU_screening`
- global64 plus MTL80 mild-style frozen fusion: `results/f04_roi_evidence_encoder/20260604_142245_v6_multiview_preinit_frozen_global_mtl80_mildstyleaug_tau003_loco_AJU_screening`
- global64 plus MTL80 strong-style frozen fusion: `results/f04_roi_evidence_encoder/20260604_142722_v6_multiview_preinit_frozen_global_mtl80_styleaug_tau003_loco_AJU_screening`
- comparison report: `results/f04_roi_evidence_encoder/20260604_143030_v6_mtl80_styleaug_fusion_audit/MTL80_STYLEAUG_FUSION_AJU_LOCO_AUDIT.md`

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary fusion G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| fusion G64+MTL80 no augmentation | 0.867 | 0.869 | 0.788 | 0.922 | 0.820 | 0.944 |
| fusion G64+MTL80 mild style | 0.865 | 0.875 | 0.803 | 0.916 | 0.840 | 0.942 |
| fusion G64+MTL80 strong style | 0.871 | 0.872 | 0.793 | 0.921 | 0.830 | 0.945 |
| MTL80 local no augmentation | 0.851 | 0.853 | 0.777 | 0.880 | 0.822 | 0.935 |
| MTL80 local mild style | 0.840 | 0.859 | 0.797 | 0.871 | 0.841 | 0.926 |
| MTL80 local strong style | 0.822 | 0.862 | 0.807 | 0.879 | 0.835 | 0.928 |

Decision:

- Mixed negative. MTL80 train-only style augmentation improves hippocampal/MTL local ranking, but it does not beat the primary G64+MTL64 model under held-out AJU.
- Frozen fusion preserves part of the MTL gain but still fails promotion. The best MTL80 style fusion pooled AUC is 0.871 versus primary 0.879.
- The failure mode is not simple lack of intensity robustness. The issue is that local ROI gains trade off against ratio/ventricle behavior and cross-question score alignment.

Next scientific interpretation:

- Generic style augmentation is not enough for novelty.
- A plausible technical contribution must be more anatomically constrained: ROI-targeted local representation, anatomy-preserving domain adaptation, or teacher-guided fusion that keeps global/ratio/ventricle behavior while improving hippocampal/MTL.


## Experiment: ROI-Union Final-Grid Subject-Specific Crop

Runs:

- smoke cache: `results/f04_roi_evidence_encoder/20260604_154809_v6_3d_roiunion_mtl_vent_finalgrid_maskcrop_cache_smoke90_80`
- full cache: `results/f04_roi_evidence_encoder/20260604_154914_v6_3d_roiunion_mtl_vent_finalgrid_maskcrop_cache_full80`
- local AJU LOCO: `results/f04_roi_evidence_encoder/20260604_163309_v6_3d_roiunion_mtl_vent_finalgrid_tau003_lr1e3_loco_AJU_screening`
- comparison report: `results/f04_roi_evidence_encoder/20260604_163309_v6_3d_roiunion_mtl_vent_finalgrid_tau003_lr1e3_loco_AJU_screening/ROI_UNION_FINALGRID_CROP_AJU_LOCO_AUDIT.md`

Cache:

- final tensor grid ROI masks: `roi_transfer_option_b_candidate_v0/roi_masks_final_tensor_grid_option_b_candidate`
- ROI union: hippocampus, parahippocampal cortex, entorhinal cortex, lateral ventricle, inferior lateral ventricle
- output shape: `9278 x 1 x 80 x 80 x 80`
- crop source counts: `mask_union: 9278`
- failures: 0
- subject/session split overlap: 0

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary fusion G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| MTL80 fixed local lr1e-3 | 0.851 | 0.853 | 0.777 | 0.880 | 0.822 | 0.935 |
| MTL80 fixed local mild style | 0.840 | 0.859 | 0.797 | 0.871 | 0.841 | 0.926 |
| ROI-union final-grid local | 0.814 | 0.813 | 0.717 | 0.881 | 0.713 | 0.942 |

Decision:

- Negative. Tight subject-specific ROI bbox resampling is not a useful primary representation for atrophy/volume VQA.
- The likely failure mode is scale normalization: resampling every ROI-union bounding box to 80³ removes absolute hippocampal/MTL size cues.
- This result changes the next direction: do not use tight variable-size bbox crops as the main image representation.

Next scientific interpretation:

- ROI localization is useful, but it must preserve scale and coordinate context.
- More credible next experiments are fixed-grid ROI masks or distance maps as auxiliary channels/attention priors, fixed crop plus mask-guided pooling, or fixed-scale ROI-centered crops where physical crop size is constant across subjects.


## Experiment: ROI-Union Fixed-Center Crop

Runs:

- smoke cache: `results/f04_roi_evidence_encoder/20260604_164317_v6_3d_roiunion_mtl_vent_finalgrid_fixedcenter_cache_smoke90_80`
- full cache: `results/f04_roi_evidence_encoder/20260604_164419_v6_3d_roiunion_mtl_vent_finalgrid_fixedcenter_cache_full80`
- local AJU LOCO: `results/f04_roi_evidence_encoder/20260604_172254_v6_3d_roiunion_mtl_vent_finalgrid_fixedcenter_tau003_lr1e3_loco_AJU_screening`
- fusion AJU LOCO: `results/f04_roi_evidence_encoder/20260604_172913_v6_multiview_preinit_frozen_global_roiunion_fixedcenter_tau003_loco_AJU_screening`
- local report: `results/f04_roi_evidence_encoder/20260604_172254_v6_3d_roiunion_mtl_vent_finalgrid_fixedcenter_tau003_lr1e3_loco_AJU_screening/ROI_UNION_FIXEDCENTER_CROP_AJU_LOCO_AUDIT.md`

Cache:

- final tensor grid ROI masks: `roi_transfer_option_b_candidate_v0/roi_masks_final_tensor_grid_option_b_candidate`
- ROI union: hippocampus, parahippocampal cortex, entorhinal cortex, lateral ventricle, inferior lateral ventricle
- crop mode: `fixed_center`
- fixed physical crop size: `136 x 120 x 90`, matching the fixed MTL80 crop
- output shape: `9278 x 1 x 80 x 80 x 80`
- crop source counts: `mask_center_fixed: 9278`
- failures: 0
- subject/session split overlap: 0

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary fusion G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| fusion G64+MTL80 fixed | 0.867 | 0.869 | 0.788 | 0.922 | 0.820 | 0.944 |
| fusion G64+ROI fixed-center | 0.834 | 0.857 | 0.773 | 0.918 | 0.781 | 0.957 |
| MTL80 fixed local lr1e-3 | 0.851 | 0.853 | 0.777 | 0.880 | 0.822 | 0.935 |
| ROI fixed-center local | 0.791 | 0.847 | 0.756 | 0.890 | 0.787 | 0.953 |

Decision:

- Negative. Fixed-size recentering preserves physical scale and is better than tight bbox on macro question AUC, but it still underperforms the fixed MTL80 crop and primary fusion.
- Fusion with global64 recovers some pooled calibration but remains far below primary and fixed MTL80 fusion.
- Ventricle improves, but hippocampal and MTL degrade; this is the wrong tradeoff for the target ROI-grounded VQA contribution.

Next scientific interpretation:

- The fixed anatomical coordinate frame is valuable. Subject-specific recentering weakens hippocampal/MTL generalization even when physical scale is preserved.
- Do not continue ROI recentering as a primary branch.
- The next credible direction should keep the fixed coordinate crop and add ROI-aware regularization/pooling inside that crop, or use teacher-guided fusion to preserve the primary model's coordinate behavior while improving hard hippocampal/MTL cases.


## Experiment: Population ROI Prior Reweighting

Runs:

- population-prior cache: `results/f04_roi_evidence_encoder/20260604_173950_v6_3d_mtl80_population_roi_prior_gain05_full`
- local AJU LOCO: `results/f04_roi_evidence_encoder/20260604_174840_v6_3d_mtl80_population_roi_prior_gain05_tau003_lr1e3_loco_AJU_screening`
- report: `results/f04_roi_evidence_encoder/20260604_174840_v6_3d_mtl80_population_roi_prior_gain05_tau003_lr1e3_loco_AJU_screening/POPULATION_ROI_PRIOR_AJU_LOCO_AUDIT.md`

Design:

- Start from the fixed MTL80 crop cache.
- Compute a constant population ROI prior from non-AJU train sessions only.
- ROI masks are final-grid masks for hippocampus, parahippocampal cortex, entorhinal cortex, lateral ventricle, and inferior lateral ventricle.
- Reweight the T1w tensor as `x_prior = x * (1 + 0.5 * population_prior)`.
- Subject-specific ROI masks are not model inputs.

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary fusion G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| MTL80 fixed local lr1e-3 | 0.851 | 0.853 | 0.777 | 0.880 | 0.822 | 0.935 |
| MTL80 fixed local mild style | 0.840 | 0.859 | 0.797 | 0.871 | 0.841 | 0.926 |
| ROI fixed-center local | 0.791 | 0.847 | 0.756 | 0.890 | 0.787 | 0.953 |
| MTL80 population prior gain 0.5 | 0.818 | 0.826 | 0.738 | 0.869 | 0.783 | 0.913 |

Decision:

- Negative. Constant population ROI prior reweighting is below fixed MTL80 local on pooled, hippocampal, MTL, and ventricle AUC.
- The method avoids subject-specific mask leakage but still appears to distort useful T1w context.
- Do not continue preprocessing-only ROI emphasis as the main direction.

Next scientific interpretation:

- ROI-aware work needs to be architectural or objective-based, not just crop/reweight preprocessing.
- The strongest next candidate is fixed-coordinate feature learning with explicit preservation of primary-model behavior, e.g. teacher-guided fusion/distillation or mask-guided pooling used only inside a fixed crop with leakage controls.


## Experiment: Tri-View Multi-Scale Fixed-Coordinate ROI Fusion

Runs:

- seed 20260603: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening`
- seed 20260604: `results/f04_roi_evidence_encoder/20260604_180641_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_seed20260604_loco_AJU_screening`
- seed 20260605: `results/f04_roi_evidence_encoder/20260604_180641_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_seed20260605_loco_AJU_screening`
- repeat/blend audit: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/repeat_seed_and_blend_audit`
- report: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/TRIVIEW_MULTISCALE_ROI_FUSION_AJU_LOCO_AUDIT.md`

Design:

- Preserve the primary global64 + fixed MTL64 coordinate frame.
- Add MTL80 as a third high-resolution fixed-coordinate branch rather than replacing MTL64.
- Frozen single-view encoders; train only tri-view fusion/head on non-AJU train.
- Inputs remain image tensors plus question ID only.

AJU LOCO AUC, single seed 20260603:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| G64+MTL80 fixed | 0.867 | 0.869 | 0.788 | 0.922 | 0.820 | 0.944 |
| G64+ROI fixed-center | 0.834 | 0.857 | 0.773 | 0.918 | 0.781 | 0.957 |
| tri-view G64+MTL64+MTL80 | 0.877 | 0.884 | 0.808 | 0.923 | 0.864 | 0.939 |

3-seed aggregate:

| model | pooled all-row mean AUC | macro question mean AUC |
|---|---:|---:|
| primary G64+MTL64 | 0.8789 | 0.8826 |
| tri-view G64+MTL64+MTL80 | 0.8796 | 0.8867 |
| validation-selected primary+tri-view blend | 0.8817 | 0.8875 |

Decision:

- Active candidate. This is the first recent direction with a reproducible positive signal after multiple negative preprocessing/crop/prior experiments.
- The gain is modest and should not be overclaimed.
- The plausible technical story is multi-scale fixed-coordinate ROI fusion: MTL80 contains useful high-resolution hippocampal/MTL detail, but only helps when added to the primary coordinate-preserving global64+MTL64 representation.

Next required checks:

- Repeat on non-AJU LOCO cohorts, especially OASIS/NACC, before promotion.
- Audit hard-case transitions versus primary and 2.5D.
- Confirm that the gain is not only validation-weight calibration by checking question-level and all-row AUC jointly.

Follow-up LOCO results:

| held-out cohort | primary pooled | tri-view pooled | primary hippocampal | tri-view hippocampal | primary MTL | tri-view MTL | interpretation |
|---|---:|---:|---:|---:|---:|---:|---|
| AJU | 0.879 | 0.880 mean | 0.808 | 0.815 mean | 0.858 | 0.867 mean | small positive across 3 seeds |
| OASIS | 0.927 | 0.932 | 0.921 | 0.938 | 0.891 | 0.904 | positive |
| NACC | 0.912 | 0.912 | 0.914 | 0.916 | 0.897 | 0.898 | neutral/mixed |

Updated decision:

- Tri-view is the current active candidate.
- It is stronger than all preprocessing-only ROI attempts and has a plausible technical story.
- It is not yet a final method claim because NACC is neutral/mixed and the gains are modest.
- The next evaluation should be hard-case transition analysis and remaining LOCO cohorts before any paper-level claim.


## Experiment: Tri-View Hard-Case Transition and Boundary-Ranking Follow-Up

Runs:

- tri-view hard-case audit: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/hard_case_transition_audit`
- boundary-ranking tri-view AJU LOCO: `results/f04_roi_evidence_encoder/20260604_183914_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_boundaryrank_w002_loco_AJU_screening`
- boundary-ranking hard-case audit: `results/f04_roi_evidence_encoder/20260604_183914_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_boundaryrank_w002_loco_AJU_screening/hard_case_transition_audit`

Design:

- Use identical AJU test `qa_id` rows from the fixed 2.5D context audit.
- Compare fixed 2.5D context, primary G64+MTL64, tri-view, and boundary-ranking tri-view.
- Boundary-ranking is train-only: within each question, confident far-from-boundary positive examples are pushed above confident negative examples. Boundary distance is not a model input.

AJU LOCO AUC:

| model | pooled all-row | macro question mean | hippocampal | ratio | MTL | ventricle |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D fixed context | 0.684 | 0.688 | 0.562 | 0.833 | 0.588 | 0.769 |
| primary G64+MTL64 | 0.879 | 0.883 | 0.808 | 0.924 | 0.858 | 0.940 |
| tri-view single seed | 0.877 | 0.884 | 0.808 | 0.923 | 0.864 | 0.939 |
| tri-view 3-seed mean | 0.882 row-level mean score audit | 0.887 | 0.812 | 0.921 | 0.867 | 0.940 |
| boundary-ranking tri-view w0.02 | 0.877 | 0.886 | 0.809 | 0.924 | 0.865 | 0.945 |
| validation-selected primary+boundary-rank blend | 0.880 | - | - | - | - | - |

Hard-case transition:

| candidate | 2.5D+primary wrong -> candidate correct | 2.5D wrong+primary correct -> candidate wrong | decision |
|---|---:|---:|---|
| tri-view 3-seed mean | 9 | 8 | small complementary signal |
| boundary-ranking tri-view w0.02 | 10 | 10 | no net hard-case improvement |

Decision:

- Boundary-ranking does not solve the problem. It slightly improves MTL/ventricle ranking but does not beat the pooled primary model and does not improve the hard-case gain/loss balance.
- The failure pattern is concentrated in cutoff-near AJU MCI/CDR 0.5 rows, especially hippocampal and MTL questions. These are not obvious crop/QC failures.
- The next method should not be another global auxiliary loss. A stronger technical direction is an uncertainty-aware fusion/gating model that preserves the primary branch when tri-view is uncertain, or a continuous evidence-distance representation objective evaluated with locked validation selection.

Immediate next experiment:

- Build a validation-locked selective fusion/gating audit first, not a new deep model.
- Inputs to the gate for audit can only be validation-derived model scores or uncertainty summaries, never clinical/scanner/diagnosis fields.
- Required test: improve primary on AJU pooled AUC and reduce hard-case regressions below gains; then repeat on OASIS/NACC.


## Experiment: Validation-Locked Selective Fusion/Gating Audit

Runs:

- AJU: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/selective_fusion_gate_audit`
- OASIS: `results/f04_roi_evidence_encoder/20260604_181410_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_OASIS_screening/selective_fusion_gate_audit`
- NACC: `results/f04_roi_evidence_encoder/20260604_182055_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_NACC_screening/selective_fusion_gate_audit`
- cross-LOCO report: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/SELECTIVE_FUSION_CROSS_LOCO_STATUS_REPORT.md`

Design:

- Candidate selectors are selected on nonheldout validation only.
- Allowed selector inputs: primary image-model score, tri-view image-model score mean, score confidence/disagreement, tri-view seed standard deviation when available, and question ID for questionwise score blending.
- Forbidden selector inputs: clinical fields, scanner/cohort labels, diagnosis/CDR/CDR-SB, age/sex, ROI numeric values, evidence percentiles, subject-specific masks, 2.5D scores, and held-out test metrics.

Held-out test result:

| held-out | selected selector | primary weight | primary pooled AUC | tri-view pooled AUC | selected pooled AUC | hard-case gain | hard-case regression | 2.5D pooled AUC |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| AJU | global score blend | 0.08 | 0.8789 | 0.8818 | 0.8830 | 8 | 7 | 0.6841 |
| OASIS | global score blend | 0.00 | 0.9274 | 0.9315 | 0.9315 | 4 | 2 | unavailable |
| NACC | global score blend | 0.09 | 0.9123 | 0.9123 | 0.9123 | 12 | 3 | unavailable |

Decision:

- Positive as a score-complementarity audit, not as a method novelty.
- The selector consistently chooses a global blend or tri-view-only blend; confidence/disagreement switching does not win validation.
- Therefore the current uncertainty summaries cannot reliably decide case-by-case when tri-view should override primary.
- The next technical experiment should make uncertainty/actionability part of representation learning, not add more post-hoc score gates.

Next candidate direction:

- Train a continuous evidence-distance representation head or ordinal/ranking objective that predicts signed distance to the reference threshold from images while preserving binary VQA performance.
- Evaluation gates: primary pooled AUC, macro question AUC, 2.5D comparison where aligned context exists, hard-case gain/regression, and cross-LOCO consistency.


## Experiment: Tri-View Signed Evidence-Distance Auxiliary Regression

Run:

- AJU: `results/f04_roi_evidence_encoder/20260604_190346_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_auxdist_w002_loco_AJU_screening`
- report: `results/f04_roi_evidence_encoder/20260604_190346_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_auxdist_w002_loco_AJU_screening/AUX_SIGNED_DISTANCE_AJU_LOCO_AUDIT.md`

Design:

- Add a train-time auxiliary SmoothL1 head on tri-view fusion features.
- Target: `tanh(signed_evidence_distance / 0.10)`.
- Loss weight: 0.02.
- Model inputs remain image tensors plus question ID only; evidence distance is a train-time target and audit field, not an input.

AJU result:

| model | pooled all-row | hippocampal | ratio | MTL | ventricle | balanced accuracy |
|---|---:|---:|---:|---:|---:|---:|
| fixed 2.5D context | 0.684 | 0.562 | 0.833 | 0.588 | 0.769 | 0.597 |
| primary G64+MTL64 | 0.879 | 0.808 | 0.924 | 0.858 | 0.940 | 0.785 |
| tri-view aux-distance w0.02 | 0.880 | 0.816 | 0.926 | 0.861 | 0.946 | 0.759 |
| tri-view aux-distance w0.02, validation threshold | 0.880 | - | - | - | - | 0.800 |
| validation-selected primary+aux question blend | 0.880 | - | - | - | - | - |

Auxiliary-head sanity:

- Validation Spearman versus signed-distance target: 0.844 macro all rows.
- AJU test Spearman versus signed-distance target: 0.775 macro all rows.
- AJU test aux-head AUC: 0.878, close to answer-score AUC 0.880.

Decision:

- Mixed negative. The auxiliary head learns a meaningful continuous distance signal and slightly improves rank AUC.
- Fixed-threshold correctness is poor, but validation-locked thresholding recovers balanced accuracy from 0.759 to 0.800.
- The remaining failure is hard-case regression: validation-thresholded aux-distance gives 2.5D+primary wrong -> aux correct = 8 rows, but 2.5D wrong+primary correct -> aux wrong = 6 rows. Validation-thresholded primary is cleaner at 5 / 1.
- Validation-selected primary+aux blending still has negative hard-case balance at 3 / 8.
- Do not expand this exact setting to OASIS/NACC as a promoted candidate.

Next implication:

- Continuous evidence learning is useful for ranking, but it must be coupled with a constraint that preserves primary-correct cutoff-near positives.
- The next experiment should explicitly add primary-preservation or monotonic calibration constraints, while keeping hard-case regression as a promotion gate.


## Experiment: Primary-Preservation Distillation Controls

Runs:

- aux-distance + teacher preservation: `results/f04_roi_evidence_encoder/20260604_192041_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_auxdist_w002_teacherpos_w010_loco_AJU_screening`
- teacher preservation only: `results/f04_roi_evidence_encoder/20260604_192807_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_teacherpos_w010_loco_AJU_screening`
- report: `results/f04_roi_evidence_encoder/20260604_192041_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_auxdist_w002_teacherpos_w010_loco_AJU_screening/PRIMARY_PRESERVATION_AJU_LOCO_AUDIT.md`

Design:

- Teacher: primary G64+MTL64 image-only model from AJU LOCO.
- Train-time mask: `boundary_distance <= 0.10`, `answer_label == 1`, and primary teacher prediction correct.
- Masked rows: 5,406 non-AJU train rows.
- Loss: `MSE(sigmoid(student_logit), primary_teacher_score)`, weight 0.10.
- Teacher scores are train-only targets, not inference inputs.

AJU result:

| model | pooled AUC | bacc fixed 0.5 | bacc validation threshold | 2.5D+primary wrong -> correct | 2.5D wrong+primary correct -> wrong |
|---|---:|---:|---:|---:|---:|
| primary | 0.8789 | 0.7853 | 0.7971 | 5 | 1 |
| aux-distance w0.02 | 0.8797 | 0.7588 | 0.8000 | 8 | 6 |
| aux-distance + teacher preservation | 0.8769 | 0.7618 | 0.7853 | 8 | 9 |
| teacher preservation only | 0.8733 | 0.7500 | 0.7912 | 10 | 8 |

Decision:

- Negative. Primary preservation in this form does not solve hard-case regression.
- It improves or preserves nonheldout validation behavior but worsens held-out AJU transfer.
- The likely issue is that non-AJU train rows where primary is correct do not define a reliable preservation target for AJU MCI/CDR 0.5 cutoff-near positives.

Updated next implication:

- Do not continue simple primary-teacher distillation.
- The next defensible path is conservative inference-time fallback or validation-locked calibration, not train-time imitation of primary scores.
- Any new method must be judged by hard-case gain/regression against fixed 2.5D context and primary, not only AUC.


## Experiment: Regression-Penalized Conservative Fallback

Runs:

- AJU: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/regression_penalized_fallback_audit`
- OASIS: `results/f04_roi_evidence_encoder/20260604_181410_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_OASIS_screening/regression_penalized_fallback_audit`
- NACC: `results/f04_roi_evidence_encoder/20260604_182055_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_NACC_screening/regression_penalized_fallback_audit`
- cross-LOCO report: `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/REGRESSION_PENALIZED_FALLBACK_CROSS_LOCO_REPORT.md`

Design:

- Select primary/candidate rule on nonheldout validation only.
- Candidate rules: primary only, candidate only, global score blend, and conservative fallback switch.
- Rule inputs: primary score, tri-view score, confidence, disagreement, and tri-view seed standard deviation.
- Forbidden inputs: clinical fields, scanner/cohort labels, diagnosis/CDR, age/sex, ROI values, evidence percentiles, 2.5D scores, and held-out labels.
- Validation objective includes AUC, balanced accuracy, and net gain versus primary.

Held-out result:

| held-out | selected rule | primary AUC | selected AUC | selected bacc | hard-case gain | hard-case regression | 2.5D AUC |
|---|---|---:|---:|---:|---:|---:|---:|
| AJU | candidate only | 0.8789 | 0.8818 | 0.7853 | 9 | 8 | 0.6841 |
| OASIS | global blend, primary 0.03 | 0.9274 | 0.9312 | 0.8571 | 4 | 2 | unavailable |
| NACC | global blend, primary 0.57 | 0.9123 | 0.9140 | 0.8531 | 6 | 0 | unavailable |

Decision:

- Conservative fallback switch does not win validation in any cohort.
- Score blending remains useful and cross-LOCO-consistent, but this is not a case-wise uncertainty method.
- Do not claim fallback/uncertainty switching as novelty.
- Tri-view remains the representation candidate; the next novelty must come from representation learning, task formulation, or stronger external validation rather than post-hoc switching.


## Experiment: Subject-Level Bootstrap Significance Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_180047_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_loco_AJU_screening/bootstrap_significance_audit`
- script: `scripts/run_f04_v6_triview_bootstrap_significance_audit.py`

Design:

- 2000 bootstrap replicates.
- Resampling unit: `subject_global_id`, not QA row.
- All QA rows for a sampled subject are retained, preserving within-subject QA correlation.
- Paired deltas compare each candidate against primary 3D on identical rows.
- Clinical/scanner/cohort/ROI/evidence fields are not model inputs or rule-selection inputs.

Pooled result:

| cohort | comparison | AUC delta vs primary | 95% CI | interpretation |
|---|---:|---:|---|---|
| AJU | 2.5D context | -0.1947 | [-0.2585, -0.1351] | 3D clearly beats aligned 2.5D |
| AJU | tri-view | +0.0030 | [-0.0122, +0.0172] | positive point estimate, not secure |
| OASIS | tri-view | +0.0041 | [-0.0035, +0.0135] | positive point estimate, not secure |
| NACC | tri-view | +0.0000 | [-0.0114, +0.0120] | essentially tied |

Decision:

- Strong evidence: 3D ROI-aware VQA is materially better than the aligned 2.5D context model on AJU.
- Weak evidence: tri-view multi-scale fusion is not yet a statistically strong improvement over the primary 3D model.
- The paper claim should not center on a tiny tri-view AUC gain unless the next model produces a larger, cross-cohort-stable delta.

Updated next experiment:

- Stop post-hoc score switching and simple teacher imitation for now.
- Build a representation-level method that changes what image evidence is learned, not only how scores are combined.
- The most defensible next candidate is ROI-token/region pooling inside fixed-coordinate 3D volumes:
  - input remains global64 + fixed MTL crop, optionally MTL80;
  - add fixed anatomical subregion tokens or attention pooling over predefined hippocampal, temporal, and ventricle neighborhoods;
  - question embedding gates ROI tokens before fusion;
  - no subject-specific mask, ROI values, evidence percentile, scanner, cohort, or clinical fields as input.
- Promotion gate:
  - subject-bootstrap pooled AUC delta versus primary should be positive with CI mostly above 0 in at least AJU and OASIS;
  - NACC should not regress beyond -0.005 pooled AUC;
  - AJU hard-case gain/regression against 2.5D+primary should be meaningfully positive, not approximately 1:1.


## Experiment: Fixed-Coordinate ROI-Token Pooling

Runs:

- concat token fusion: `results/f04_roi_evidence_encoder/20260604_200056_v6_triview_roi_token_pooling_preinit_frozen_loco_AJU_screening`
- residual adapter: `results/f04_roi_evidence_encoder/20260604_201152_v6_triview_roi_token_residual_adapter_preinit_frozen_loco_AJU_screening`

Design:

- Fixed normalized encoder feature-map bins over MTL64 and MTL80 branches.
- Six deterministic region tokens are shared across all subjects.
- Question embedding gates region tokens.
- No subject-specific mask, ROI value, evidence percentile, scanner/cohort, clinical field, AEB feature, diagnosis, CDR, age, or sex is used as model input.

AJU result:

| model | pooled AUC | hippocampal | ratio | MTL | ventricle | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| fixed 2.5D context | 0.6841 | 0.5621 | 0.8331 | 0.5880 | 0.7686 | 0.5971 | - | - |
| primary G64+MTL64 | 0.8789 | 0.8082 | 0.9238 | 0.8580 | 0.9404 | 0.7853 | - | - |
| tri-view G64+MTL64+MTL80 | 0.8770 | 0.8077 | 0.9231 | 0.8640 | 0.9395 | 0.7882 | 9 | 8 |
| ROI-token concat | 0.8687 | 0.7943 | 0.9038 | 0.8540 | 0.9561 | 0.7765 | 5 | 10 |
| ROI-token residual adapter | 0.8743 | 0.8099 | 0.9188 | 0.8664 | 0.9385 | 0.7882 | 10 | 9 |

Decision:

- Concat token fusion is negative. It improves ventricle AUC but damages fine MTL/hippocampal and pooled ranking.
- Residual adapter is a better diagnostic: it preserves baseline behavior better and improves hippocampal/MTL AUC and hard-case gain, but pooled AUC remains below primary and original tri-view.
- Do not promote fixed coarse ROI-token pooling.

Scientific diagnosis:

- The failure is not that T1w has no signal: 3D remains far above aligned 2.5D.
- The failure is that six coarse fixed bins are too blunt and can distort ranking, especially ratio and pooled all-row AUC.
- A stronger next method must learn spatial attention or local contrastive representations under fixed-coordinate guardrails rather than concatenating manually defined bins.

Next candidate:

- ROI-local contrastive pretraining on fixed MTL crops:
  - positives: same session under mild intensity/geometric augmentation or neighboring fixed subregions from the same anatomical crop;
  - negatives: different subjects within the same train split and question/cohort-balanced minibatches;
  - no clinical/ROI/evidence fields as contrastive inputs;
  - downstream: frozen encoder + question-conditioned VQA head under AJU LOCO.
- Required gate:
  - must beat primary pooled AUC or at least improve hippocampal/MTL while not regressing ratio/ventricle enough to lower pooled AUC;
  - must retain clear 2.5D superiority and improve hard-case gain/regression beyond approximately 1:1.


## Experiment: Generic MTL64 Contrastive Pretraining

Runs:

- pretrain: `results/f04_roi_evidence_encoder/20260604_203027_v6_mtl64_contrastive_pretrain_loco_AJU`
- downstream: `results/f04_roi_evidence_encoder/20260604_203424_v6_triview_mtl64_contrastive_preinit_frozen_loco_AJU_screening`
- script: `scripts/run_f04_v6_mtl_contrastive_pretrain.py`

Design:

- SimCLR-style two-view contrastive learning on fixed MTL64 crop tensors.
- AJU excluded from pretraining train/val.
- No question ID, answer label, ROI value, evidence percentile, clinical field, scanner/cohort label as model input.
- Downstream replaces supervised soft-label MTL64 encoder with contrastive MTL64 encoder while keeping supervised global64 and supervised MTL80.

Result:

| model | pooled AUC | hippocampal | ratio | MTL | ventricle | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| fixed 2.5D context | 0.6841 | 0.5621 | 0.8331 | 0.5880 | 0.7686 | 0.5971 | - | - |
| primary G64+MTL64 | 0.8789 | 0.8082 | 0.9238 | 0.8580 | 0.9404 | 0.7853 | - | - |
| tri-view supervised MTL64+MTL80 | 0.8770 | 0.8077 | 0.9231 | 0.8640 | 0.9395 | 0.7882 | 9 | 8 |
| contrastive MTL64 + supervised MTL80 | 0.8599 | 0.7799 | 0.9175 | 0.8288 | 0.9473 | 0.7618 | 10 | 21 |

Decision:

- Negative. Generic contrastive pretraining does not preserve the ROI cutoff-sensitive fine anatomy signal.
- It improves ventricle AUC slightly but hurts hippocampal and MTL atrophy, which are the main target failures.
- Hard-case regression is unacceptable: 21 rows where 2.5D failed, primary succeeded, and the contrastive candidate failed.

Updated implication:

- Do not use generic SimCLR-style instance discrimination as the novelty path.
- If contrastive learning is revisited, it must be anatomy/evidence-aware at the target or sampling level while still not using ROI/evidence fields as inference inputs.
- The next more defensible direction is not broader SSL, but supervised image-only representation learning with explicit preservation of cutoff-sensitive local ranking:
  - local pair/ranking losses only within train rows and question families;
  - strong promotion gate against 2.5D+primary hard-case regressions;
  - bootstrap CI before any cross-cohort claim.


## Experiment: MTL64 Soft-Label + Signed-Distance Local Pretraining

Runs:

- local pretrain: `results/f04_roi_evidence_encoder/20260604_204406_v6_mtl64_softlabel_tau003_auxdist_w002_loco_AJU_screening`
- downstream: `results/f04_roi_evidence_encoder/20260604_204738_v6_triview_mtl64_auxdist_preinit_frozen_loco_AJU_screening`

Design:

- Local MTL64 encoder trained with tau=0.03 soft labels plus train-only signed-distance auxiliary regression.
- Auxiliary target: `tanh(signed_evidence_distance / 0.10)`.
- Auxiliary weight: 0.02.
- AJU excluded from train/val.
- Evidence distance is a train-only target, not an inference input.

Result:

| model | pooled AUC | hippocampal | ratio | MTL | ventricle | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| fixed 2.5D context | 0.6841 | 0.5621 | 0.8331 | 0.5880 | 0.7686 | 0.5971 | - | - |
| primary G64+MTL64 | 0.8789 | 0.8082 | 0.9238 | 0.8580 | 0.9404 | 0.7853 | - | - |
| tri-view supervised MTL64+MTL80 | 0.8770 | 0.8077 | 0.9231 | 0.8640 | 0.9395 | 0.7882 | 9 | 8 |
| contrastive MTL64 + supervised MTL80 | 0.8599 | 0.7799 | 0.9175 | 0.8288 | 0.9473 | 0.7618 | 10 | 21 |
| aux-distance MTL64 + supervised MTL80 | 0.8691 | 0.7865 | 0.9219 | 0.8312 | 0.9414 | 0.7824 | 7 | 20 |

Decision:

- Negative. It is better than generic contrastive pretraining but still below primary and original tri-view.
- The auxiliary distance target improves some boundary/ratio behavior but does not preserve cohort-transferable hippocampal/MTL morphology.
- Hard-case regression remains too high.

Updated implication:

- Simple local auxiliary objectives are not enough.
- Repeated failure pattern:
  - ventricle/ratio or boundary-bin improvements can appear;
  - hippocampal/MTL AUC and 2.5D+primary hard-case regression degrade;
  - validation gains do not reliably transfer to AJU.
- Before another model variant, run a consolidated failure-structure audit across all candidate branches to identify which question/error bins are consistently harmed.


## Experiment: ROI-Token Residual With Primary Preservation

Run:

- `results/f04_roi_evidence_encoder/20260604_205748_v6_triview_roi_token_residual_primarypreserve_allcorrect_w005_loco_AJU_screening`

Design:

- Start from the original tri-view checkpoint.
- Freeze encoders, question embedding, and base fusion head.
- Train only zero-initialized fixed ROI-token residual adapter.
- Add train-only primary teacher preservation on non-AJU rows where the primary teacher is correct.
- Masked train rows: 10,342 / 11,528.
- Teacher score is not an inference input.

Result:

| model | pooled AUC | hippocampal | ratio | MTL | ventricle | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| primary G64+MTL64 | 0.8789 | 0.8082 | 0.9238 | 0.8580 | 0.9404 | 0.7853 | - | - |
| ROI-token residual adapter | 0.8743 | 0.8099 | 0.9188 | 0.8664 | 0.9385 | 0.7882 | 10 | 9 |
| residual + primary preservation | 0.8757 | 0.8090 | 0.9238 | 0.8560 | 0.9395 | 0.7559 | 3 | 14 |

Decision:

- Negative. Primary preservation suppresses useful recovery and still fails to protect primary-correct AJU transfer.
- It slightly improves pooled AUC over residual-only but sharply lowers balanced accuracy and hard-case gain.
- This confirms that global teacher imitation is too blunt.


## Consolidated AJU Failure-Structure Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_205100_v6_aju_candidate_failure_structure_audit`
- script: `scripts/run_f04_v6_aju_candidate_failure_structure_audit.py`

Scope:

- 8 AJU LOCO candidate runs.
- Compares pooled AUC, balanced accuracy, hippocampal/MTL delta versus primary, and hard-case gain/regression versus fixed 2.5D + primary.
- Post-hoc audit only; no model selection.

Key result:

- Only `fusion_auxdist` slightly exceeds primary pooled AUC, but it has poor balanced accuracy and hard-case net -10.
- Original tri-view, boundary ranking, and ROI residual are closest to acceptable, but their pooled AUC remains below primary and hard-case net is only 0 or +1.
- Local replacement methods are clearly negative:
  - generic contrastive MTL64: hard gain/regression 10/21
  - aux-distance MTL64: hard gain/regression 7/20

Decision:

- The current family of fixes is exhausted for AJU.
- The repeated failure is not 2.5D versus 3D; 3D is clearly better.
- The real bottleneck is preserving hippocampal/MTL ranking while recovering a small number of 2.5D+primary failures.
- Next work should switch from new architecture tweaks to targeted case analysis: inspect hard-gain and hard-loss images, boundary bins, and scanner/QC patterns, then design a narrower hypothesis.

## Implementation Note: ROI-Token Smoke Sampling

During the first ROI-token smoke run, `--limit-examples 384` was applied before AJU LOCO filtering. Because the limited test sample did not contain AJU rows, the run correctly failed with `test=0`. This was a smoke-sampling issue, not a model failure. The incomplete smoke output was removed to avoid confusing active results. Full-data 1-epoch smoke should be used for AJU LOCO checks unless the sampling logic is revised to stratify by held-out consortium after filtering.

Resolution:

- `scripts/run_f04_v6_triview_3d_image_only_matched_vqa.py` now applies `--limit-examples` after LOCO train/val/test filtering.
- The limited smoke subset is stratified by `question_id` and `answer_label`.
- Verification smoke with `--limit-examples 120` produced train/val/test 40/40/40 rows and every split/question had positive rate 0.5.

## Implementation Note: Contrastive Pretraining AMP Loss

The first MTL64 contrastive smoke run failed because the NT-Xent diagonal mask used `-1e9` under CUDA autocast half precision, which overflows fp16. This is an implementation issue in the loss numerics, not a data/model signal. The loss should compute the similarity matrix in float32 before applying the diagonal mask. The incomplete smoke output was removed.

Resolution:

- `nt_xent_loss` now casts the similarity matrix to float32 before masking.
- Smoke pretraining with 128 sessions completed successfully.
- The smoke checkpoint loaded into the tri-view MTL64 branch with 28 encoder tensors and 0 missing/unexpected encoder keys.
- The smoke output directory was removed so only the full pretrain/downstream runs remain.

## Post-Hoc Case Analysis: AJU Hard Gain/Loss

Run:

- `results/f04_roi_evidence_encoder/20260604_210000_v6_aju_hard_gain_loss_case_analysis`
- script: `scripts/run_f04_v6_aju_hard_gain_loss_case_analysis.py`

Scope:

- Uses the original tri-view hard-case transition audit.
- Aligns QA rows with official 3D image paths and QC metadata.
- Creates hard-gain and hard-loss tables plus montage figures comparing fixed 2.5D axial context, full axial slices, and fixed MTL orthogonal views.
- This is post-hoc interpretation only. Clinical/scanner/QC/evidence fields are not used for model input or selection.

Result:

| item | count |
|---|---:|
| aligned AJU rows | 340 |
| hard gain: 2.5D and primary fail, tri-view succeeds | 9 |
| hard loss: 2.5D fails, primary succeeds, tri-view fails | 8 |
| hard net | +1 |

Key findings:

- Hard gains and hard losses are concentrated in `normqa_low_hippocampal_volume` and `normqa_mtl_atrophy_evidence`.
- There are no hard transitions for the ratio or ventricle questions in this audit.
- Most cases are AJU MCI with Global CDR 0.5.
- Boundary bins `<=.02`, `.02-.05`, and `.05-.10` dominate the informative transitions.
- The montage review does not support a simple "3D cannot see the ROI" explanation; the limiting problem is cutoff-near hippocampal/MTL ranking and calibration.

Decision:

- Do not run more broad SSL or generic adapter variants before resolving the hard-case regression mechanism.
- The next model hypothesis must explicitly explain why it should recover hippocampal/MTL boundary cases without regressing primary-correct AJU cases.

## Experiment: Boundary-Near Primary Preservation Residual Adapter

Run:

- `results/f04_roi_evidence_encoder/20260604_211404_v6_triview_roi_token_residual_boundarypreserve_m010_w002_loco_AJU_screening`

Design:

- Start from the original tri-view checkpoint.
- Freeze encoders, question embedding, and base fusion head.
- Train only the fixed ROI-token residual adapter.
- Use primary teacher score as a train-only auxiliary target only on non-AJU rows where the primary teacher is correct and `boundary_distance <= 0.10`.
- Teacher loss weight: 0.02.
- Masked train rows: 5,970 / 11,528.
- Teacher score is not an inference input.

Result:

| model | pooled AUC | hippocampal | ratio | MTL | ventricle | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| primary G64+MTL64 | 0.8789 | 0.8082 | 0.9238 | 0.8580 | 0.9404 | 0.7853 | - | - |
| original tri-view | 0.8770 | 0.8077 | 0.9231 | 0.8640 | 0.9395 | 0.7882 | 9 | 8 |
| residual + boundary preservation | 0.8751 | 0.8064 | 0.9238 | 0.8564 | 0.9395 | 0.7618 | 4 | 14 |

Decision:

- Negative. Narrow boundary-near primary preservation also fails AJU transfer.
- It reduces hard-gain recovery and increases hard regression, despite good nonheldout validation AUC.
- This closes the teacher-preservation adapter direction for now.

## Updated Consolidated AJU Failure-Structure Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_205100_v6_aju_candidate_failure_structure_audit`
- script: `scripts/run_f04_v6_aju_candidate_failure_structure_audit.py`

Scope:

- 9 AJU LOCO candidates.
- Includes original tri-view, boundary ranking, aux-distance fusion, ROI-token variants, generic contrastive MTL64, local aux-distance MTL64, global primary preservation, and boundary-near primary preservation.

Updated conclusion:

- No candidate cleanly beats the primary tau=0.03 frozen fusion under AJU LOCO.
- The closest technical candidate remains original tri-view, but its AUC delta is small and bootstrap CI versus primary crosses zero.
- Teacher preservation is not a solution: global preservation gives hard gain/regression 3/14 and boundary-near preservation gives 4/14.
- The next credible experiment should be a diagnostic separation:
  - ranking: compare score ordering within hippocampal/MTL boundary bins;
  - calibration: evaluate validation-locked thresholds and reliability curves by question;
  - label boundary: inspect whether near-cutoff ROI labels are too noisy for binary VQA and should be evaluated with ordinal/uncertainty-aware targets.

## Diagnostic: AJU Hippocampal/MTL Boundary Ranking vs Calibration

Run:

- `results/f04_roi_evidence_encoder/20260604_212300_v6_aju_hipmtl_boundary_ranking_calibration_diagnostic`
- script: `scripts/run_f04_v6_aju_hipmtl_boundary_diagnostic.py`

Scope:

- AJU hippocampal and MTL rows only: 196 rows.
- Compares fixed 2.5D, primary tau=0.03, original tri-view, and boundary-preservation residual.
- Reports AUC, score gap, bacc@0.5, brier, 5-bin ECE, and hard-transition score deltas by boundary bin.
- Post-hoc only; no model input or selection changes.

Key result:

| model | hip/MTL AUC | bacc@0.5 | brier | score gap |
|---|---:|---:|---:|---:|
| 2.5D | 0.572 | 0.526 | 0.245 | 0.036 |
| primary | 0.834 | 0.750 | 0.169 | 0.364 |
| original tri-view | 0.840 | 0.750 | 0.169 | 0.408 |
| boundary preservation | 0.833 | 0.714 | 0.186 | 0.411 |

Interpretation:

- 3D is clearly carrying useful hippocampal/MTL signal versus 2.5D.
- Original tri-view is not globally worse for hip/MTL ranking; it slightly improves AUC and score separation.
- Boundary-preservation worsens bacc and brier, confirming it is not a useful fix.
- The closest cutoff bins are the real problem. In `<=.02` and `.02-.05`, ranking can invert even for the primary model. This points to binary label-boundary ambiguity or noisy normative cutoffs, not simply architecture failure.

Next experiment implication:

- Do not run another broad architecture or SSL variant yet.
- The next technical novelty should be framed as uncertainty-aware ROI-grounded VQA:
  - train/evaluate hard labels far from the cutoff;
  - use soft/ordinal targets or abstention/uncertain class near the cutoff;
  - report separate far-boundary accuracy and near-boundary calibration;
  - preserve the image-only inference policy.

## Diagnostic: AJU Uncertainty-Aware Abstention

Run:

- `results/f04_roi_evidence_encoder/20260604_213000_v6_aju_uncertainty_abstention_audit`
- script: `scripts/run_f04_v6_aju_uncertainty_abstention_audit.py`

Scope:

- Fixed 2.5D context, primary 3D, original tri-view, primary/tri-view blend, and boundary-preservation residual.
- Two abstention modes:
  - oracle boundary abstention: use label metadata only to remove near-cutoff rows from hard binary evaluation;
  - score-confidence abstention: use only model score distance from 0.5.

Key all-question result:

| policy | coverage | 2.5D AUC | primary AUC | tri-view AUC | tri-view bacc |
|---|---:|---:|---:|---:|---:|
| no abstention | 1.000 | 0.684 | 0.879 | 0.882 | 0.785 |
| oracle boundary >0.05 | 0.765 | 0.713 | 0.935 | 0.937 | 0.852 |
| oracle boundary >0.10 | 0.459 | 0.690 | 0.953 | 0.970 | 0.878 |

Key hip/MTL result:

| policy | coverage | 2.5D AUC | primary AUC | tri-view AUC |
|---|---:|---:|---:|---:|
| no abstention | 1.000 | 0.572 | 0.834 | 0.840 |
| oracle boundary >0.05 | 0.704 | 0.631 | 0.934 | 0.930 |
| oracle boundary >0.10 | 0.311 | undefined single-class | undefined single-class | undefined single-class |

Interpretation:

- Near-cutoff rows dominate the apparent failure. Removing only `boundary_distance <= 0.05` raises all-question primary/tri-view AUC to about 0.935/0.937 and hip/MTL AUC to about 0.934/0.930.
- This strengthens the claim that the image signal exists, but the hard binary target is not stable near normative cutoffs.
- Score-confidence abstention improves kept-row metrics but only partly captures near-boundary rows and errors, so confidence alone is not enough for a strong uncertainty claim.

## Diagnostic: Uncertainty Auxiliary Head

Run:

- `results/f04_roi_evidence_encoder/20260604_214000_v6_uncertainty_aux_head_audit`
- script: `scripts/run_f04_v6_uncertainty_aux_head_audit.py`

Scope:

- Existing uncertainty auxiliary runs:
  - `unc_aux_w02_frozen`
  - `unc_aux_w005_frozen`
  - `unc_aux_w005_unfreeze`
- Evaluates whether the image/question-conditioned uncertainty head predicts held-out AJU boundary-near rows.

Boundary detection result:

| run | target | all AUC | hip/MTL AUC |
|---|---|---:|---:|
| unc_aux_w02_frozen | boundary <=0.05 | 0.731 | 0.741 |
| unc_aux_w005_frozen | boundary <=0.05 | 0.740 | 0.753 |
| unc_aux_w005_unfreeze | boundary <=0.05 | 0.721 | 0.698 |
| unc_aux_w005_frozen | boundary <=0.10 | 0.861 | 0.775 |

Answer-model result in the consolidated failure audit:

| model | pooled AUC | bacc | hard gain | hard regression |
|---|---:|---:|---:|---:|
| primary | 0.879 | 0.785 | - | - |
| unc_aux_w02_frozen | 0.875 | 0.785 | 1 | 1 |
| unc_aux_w005_frozen | 0.873 | 0.785 | 1 | 0 |
| unc_aux_w005_unfreeze | 0.867 | 0.765 | 1 | 6 |

Decision:

- Mixed/negative as an answer model. The uncertainty head learns nontrivial boundary proximity, but adding it as a simple auxiliary loss does not improve AJU answer AUC over primary.
- The useful signal is methodological: near-cutoff uncertainty is partially visible from images, but current head/abstention design is not strong enough to claim robust uncertainty-aware VQA.
- Next implementation should create a true three-zone evaluation/task:
  - far-negative / uncertain-near-cutoff / far-positive;
  - binary answer evaluated only on far rows;
  - separate uncertainty detection on near rows;
  - 2.5D, primary 3D, and tri-view all reported under the same coverage.

## Three-Zone Dataset Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_215000_v6_three_zone_roi_vqa_dataset_audit`
- script: `scripts/run_f04_v6_three_zone_roi_vqa_dataset_audit.py`

Primary artifact:

- `three_zone_session_qa_margin005_with_3d_paths.csv`

Margin comparison:

| margin | uncertain rate | far coverage | far positive rate |
|---:|---:|---:|---:|
| 0.02 | 0.095 | 0.905 | 0.475 |
| 0.05 | 0.240 | 0.760 | 0.417 |
| 0.10 | 0.602 | 0.398 | 0.000 |

Decision:

- Margin 0.05 is the practical three-zone candidate.
- Margin 0.10 is too aggressive for the current percentile rule because far rows become almost entirely negative.
- Margin 0.05 keeps enough train/val/test far rows and has zero subject/session split overlap.

## Experiment: Three-Zone Answer-Masked Training

Run:

- `results/f04_roi_evidence_encoder/20260604_214241_v6_multiview_preinit_tau003_threezone_answermask005_uncaux005_frozen_loco_AJU_screening`
- audit: `THREEZONE_ANSWER_MASK_AJU_LOCO_AUDIT.md`

Design:

- AJU LOCO.
- Frozen global + MTL tau=0.03 encoders.
- `boundary_distance <= 0.05` train rows receive zero answer BCE weight.
- Near-cutoff train rows are learned only through the uncertainty auxiliary target.
- Train answer-loss zero rows: 2,782 / 11,528.

Result:

| metric | value |
|---|---:|
| raw pooled AUC | 0.8585 |
| raw pooled bacc | 0.7735 |
| raw hippocampal AUC | 0.8016 |
| raw MTL AUC | 0.8444 |
| hard gain/regression | 1 / 5 |
| all-question far AUC at boundary >0.05 | 0.9385 |
| hip/MTL far AUC at boundary >0.05 | 0.9228 |

Decision:

- Mixed/negative. The method improves all-question far-boundary evaluation slightly, but it hurts all-row answer ranking and does not beat primary on the key hip/MTL far-boundary ranking.
- This supports three-zone evaluation as a defensible reporting framework, but not this simple answer-masking training method as the final technical contribution.
- The next model-side idea must improve hip/MTL far-boundary ranking specifically, not just uncertainty detection or all-question far performance.

## Diagnostic: Validation-Locked Three-Zone Decision

Run:

- `results/f04_roi_evidence_encoder/20260604_220000_v6_validation_locked_threezone_decision_audit`
- script: `scripts/run_f04_v6_validation_locked_threezone_decision_audit.py`

Design:

- Target zones use margin 0.05:
  - `far_negative`
  - `uncertain_near_cutoff`
  - `far_positive`
- Thresholds are selected only on validation rows.
- Held-out AJU test is evaluated once.
- 2.5D uses score-confidence as the uncertainty signal.
- 3D models are evaluated with score-confidence; uncertainty-head models are also evaluated with learned uncertainty scores.

AJU all-question result:

| model | uncertainty signal | zone bacc | uncertain recall | far AUC |
|---|---|---:|---:|---:|
| 2.5D | score confidence | 0.436 | 0.000 | 0.756 |
| primary | score confidence | 0.643 | 0.543 | 0.948 |
| original tri-view | score confidence | 0.645 | 0.766 | 0.946 |
| uncertainty aux | score confidence | 0.632 | 0.543 | 0.946 |
| uncertainty aux | learned uncertainty | 0.617 | 0.362 | 0.946 |
| three-zone answer-mask | score confidence | 0.621 | 0.670 | 0.939 |
| three-zone answer-mask | learned uncertainty | 0.631 | 0.532 | 0.939 |

AJU hip/MTL result:

| model | uncertainty signal | zone bacc | uncertain recall | far AUC |
|---|---|---:|---:|---:|
| 2.5D | score confidence | 0.378 | 0.000 | 0.631 |
| primary | score confidence | 0.635 | 0.655 | 0.934 |
| original tri-view | score confidence | 0.668 | 0.845 | 0.930 |
| uncertainty aux | score confidence | 0.639 | 0.655 | 0.932 |
| uncertainty aux | learned uncertainty | 0.613 | 0.138 | 0.932 |
| three-zone answer-mask | score confidence | 0.606 | 0.724 | 0.923 |
| three-zone answer-mask | learned uncertainty | 0.637 | 0.379 | 0.923 |

Decision:

- Positive as an evaluation/task design result, not as a new trained answer model.
- 2.5D score-confidence cannot meaningfully identify uncertain near-cutoff rows; validation selects nearly no abstention and AJU uncertain recall is 0.
- 3D score geometry is much more informative. Original tri-view score-confidence gives the best hip/MTL three-zone bacc and uncertain recall.
- Learned uncertainty heads are not yet better than score-confidence. The technical contribution should not claim that the current uncertainty head solves uncertainty.
- A defensible next paper framing is: 3D ROI-aware VQA should be evaluated as a three-zone anatomical reasoning task; near-cutoff uncertainty is a first-class output, and 3D models outperform 2.5D in both far-boundary answering and uncertain-row identification.

## Diagnostic: In-Split Three-Zone Decision

Run:

- `results/f04_roi_evidence_encoder/20260604_221000_v6_insplit_validation_locked_threezone_decision_audit`
- script: `scripts/run_f04_v6_insplit_threezone_decision_audit.py`

Scope:

- Full matched test split, not only AJU.
- Models:
  - 2.5D context
  - global 3D
  - MTL crop 3D
  - fusion tau=0.03
  - fusion tau=0.05
- Thresholds selected on validation predictions only.
- Test target zones use margin 0.05.

Main result:

| model | all zone bacc | hip/MTL zone bacc | all uncertain recall | hip/MTL uncertain recall | all far AUC | hip/MTL far AUC |
|---|---:|---:|---:|---:|---:|---:|
| 2.5D | 0.464 | 0.417 | 0.002 | 0.000 | 0.778 | 0.677 |
| global 3D | 0.520 | 0.457 | 0.061 | 0.092 | 0.878 | 0.755 |
| MTL crop 3D | 0.585 | 0.566 | 0.339 | 0.379 | 0.938 | 0.938 |
| fusion tau=0.03 | 0.687 | 0.669 | 0.662 | 0.679 | 0.969 | 0.960 |
| fusion tau=0.05 | 0.678 | 0.661 | 0.570 | 0.563 | 0.965 | 0.953 |

Interpretation:

- The AJU three-zone finding generalizes to the full matched test split.
- 2.5D score-confidence almost never predicts the uncertain class.
- 3D global improves far-boundary answering but still weakly identifies uncertain rows.
- Local MTL crop substantially improves uncertainty identification.
- Global+MTL fusion is the strongest general three-zone model.

## Bootstrap: In-Split Three-Zone 3D vs 2.5D

Run:

- `results/f04_roi_evidence_encoder/20260604_222000_v6_insplit_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_insplit_threezone_bootstrap_audit.py`

Design:

- 2,000 subject-level paired bootstrap replicates.
- Thresholds imported from the validation-locked in-split three-zone audit.
- Deltas are model minus 2.5D.

Key result:

| scope | model | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---:|---:|---:|
| all | fusion tau=0.03 | +0.196 to +0.250 | +0.609 to +0.709 | +0.161 to +0.224 |
| all | fusion tau=0.05 | +0.189 to +0.241 | +0.521 to +0.616 | +0.158 to +0.221 |
| hip/MTL | fusion tau=0.03 | +0.213 to +0.289 | +0.608 to +0.746 | +0.232 to +0.335 |
| hip/MTL | fusion tau=0.05 | +0.207 to +0.282 | +0.494 to +0.628 | +0.225 to +0.329 |

Decision:

- Strong positive evidence for the three-zone evaluation framing.
- Unlike the model-tweak experiments, this result is stable and directly clarifies why 2.5D fails: it cannot identify the near-cutoff uncertainty zone and has much lower far-boundary AUC.
- This should become a central result table in the manuscript draft.

Implementation note:

- The first bootstrap implementation used row index concatenation inside every replicate and was too slow. It was stopped after about four minutes and replaced with subject-level sampling weights. The final script preserves subject-level paired bootstrap semantics and completed successfully.

## Bootstrap: Secondary Three-Zone Comparisons

Run:

- `results/f04_roi_evidence_encoder/20260604_223000_v6_threezone_secondary_bootstrap_audit`
- script: `scripts/run_f04_v6_threezone_secondary_bootstrap_audit.py`

Design:

- 2,000 subject-level paired bootstrap replicates.
- AJU LOCO thresholds are imported from the AJU validation-locked three-zone audit.
- In-split thresholds are imported from the in-split validation-locked three-zone audit.
- Boundary/evidence fields define evaluation targets only; model inputs remain image tensors plus question ID.

AJU LOCO versus 2.5D:

| scope | model | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---:|---:|---:|
| all | primary | +0.148 to +0.270 | +0.429 to +0.663 | +0.124 to +0.274 |
| all | original tri-view | +0.146 to +0.273 | +0.648 to +0.869 | +0.126 to +0.262 |
| hip/MTL | primary | +0.180 to +0.341 | +0.519 to +0.792 | +0.186 to +0.432 |
| hip/MTL | original tri-view | +0.210 to +0.369 | +0.729 to +0.943 | +0.184 to +0.422 |

AJU LOCO versus primary 3D:

| scope | model | delta zone bacc 95% CI | delta far AUC 95% CI | decision |
|---|---|---:|---:|---|
| all | original tri-view | -0.044 to +0.050 | -0.016 to +0.009 | not statistically secure |
| hip/MTL | original tri-view | -0.025 to +0.091 | -0.028 to +0.018 | not statistically secure |
| all | uncertainty aux w0.05 | -0.041 to +0.018 | -0.007 to +0.003 | not promoted |
| all | three-zone answer-mask | -0.070 to +0.026 | -0.020 to -0.001 | not promoted |

In-split fusion versus 3D branches:

| scope | comparison | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---:|---:|---:|
| all | fusion tau=0.03 vs global 3D | +0.140 to +0.196 | +0.543 to +0.657 | +0.072 to +0.113 |
| all | fusion tau=0.03 vs MTL crop 3D | +0.075 to +0.129 | +0.257 to +0.389 | +0.021 to +0.043 |
| hip/MTL | fusion tau=0.03 vs global 3D | +0.171 to +0.252 | +0.497 to +0.665 | +0.160 to +0.249 |
| hip/MTL | fusion tau=0.03 vs MTL crop 3D | +0.068 to +0.140 | +0.212 to +0.388 | +0.009 to +0.035 |
| all | fusion tau=0.03 vs fusion tau=0.05 | -0.009 to +0.026 | +0.053 to +0.133 | -0.002 to +0.009 |

Decision:

- This strengthens the central scientific claim: 3D ROI-aware VQA should be evaluated as a three-zone task, because 2.5D fails both far-boundary ranking and near-cutoff uncertainty identification.
- The global+local 3D fusion contribution is supported: fusion tau=0.03 significantly beats global-only and MTL-only branches, especially for hip/MTL rows.
- The current learned uncertainty head and answer-masked training are not promotable. They either tie primary or reduce far-boundary AUC.
- Tau=0.03 versus tau=0.05 is not a strong novelty claim; tau=0.03 mainly improves uncertain recall, while CI for zone bacc/far AUC overlaps zero.

Next experiment decision:

- Stop broad architecture/SSL tweaks unless they directly test a falsifiable three-zone hypothesis.
- Keep primary 3D, fixed 2.5D, global-only, MTL-only, and fusion tau=0.03 as the required comparator set.
- The next useful experiment is a validation-locked three-zone fusion/uncertainty head that explicitly learns the three-zone target while preserving far-boundary answer ranking, not another binary answer-only head.

## Experiment: Direct Three-Zone CE Auxiliary

Run:

- `results/f04_roi_evidence_encoder/20260604_223044_v6_multiview_preinit_tau003_threezone_ce_w010_frozen_loco_AJU_screening`
- audit: `threezone_ce_direct_head_audit/THREEZONE_CE_DIRECT_HEAD_AUDIT.md`
- script changes: `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- audit script: `scripts/run_f04_v6_threezone_ce_direct_head_audit.py`

Design:

- AJU LOCO.
- Frozen global64 + MTL64 encoders.
- Binary answer BCE remains active for all train rows.
- Auxiliary three-zone CE weight: 0.10.
- Three-zone target: far-negative / near-cutoff uncertain / far-positive at margin 0.05.
- Model inputs remain image tensors plus question ID only.

Result:

| metric | value |
|---|---:|
| best val macro AUC | 0.9176 |
| AJU binary pooled AUC | 0.8639 |
| AJU binary bacc | 0.7941 |
| direct-head all zone bacc | 0.6561 |
| direct-head hip/MTL zone bacc | 0.6526 |
| direct-head all uncertain recall | 0.4894 |
| direct-head hip/MTL uncertain recall | 0.4310 |
| direct-head all far AUC | 0.9380 |
| direct-head hip/MTL far AUC | 0.9298 |

Comparison:

- Versus 2.5D: clearly better for three-zone decisions and far AUC.
- Versus primary 3D: all-question zone bacc is slightly higher, but far AUC is lower.
- Versus original tri-view: hip/MTL zone bacc and uncertain recall are lower.
- Score-confidence thresholding on this run over-abstains; direct argmax is more balanced.

Decision:

- Mixed/negative. The direct three-zone head is a useful uncertainty branch but not a promoted model because it damages far-boundary answer ranking.
- This falsifies the simplest version of "add a three-zone CE head" as a novelty claim.
- The next model-side attempt must explicitly constrain the auxiliary branch not to move the binary answer boundary, for example by freezing the primary binary head and training only a residual three-zone head, or by using stop-gradient features from the primary fusion representation.

## Experiment: Primary-Frozen Three-Zone Head

Runs:

- unweighted: `results/f04_roi_evidence_encoder/20260604_224333_v6_primary_frozen_threezone_head_margin005_loco_AJU`
- uncertain-weighted: `results/f04_roi_evidence_encoder/20260604_224750_v6_primary_frozen_threezone_head_margin005_uncw2_loco_AJU`
- bootstrap: `results/f04_roi_evidence_encoder/20260604_225200_v6_primary_frozen_threezone_head_bootstrap_audit`
- train/eval script: `scripts/run_f04_v6_primary_frozen_threezone_head.py`
- bootstrap script: `scripts/run_f04_v6_primary_frozen_threezone_head_bootstrap.py`

Design:

- Load the primary 3D AJU LOCO checkpoint.
- Freeze encoders, question embedding, and binary answer head.
- Train only a new direct three-zone head.
- Binary answer score is therefore preserved from primary.
- Model inputs remain global 3D tensor, fixed MTL 3D tensor, and question ID.
- Weighted run uses CE class weights `[1, 2, 1]` for far-negative / uncertain / far-positive.

Point result:

| run | all zone bacc | hip/MTL zone bacc | all uncertain recall | hip/MTL uncertain recall | all far AUC | hip/MTL far AUC |
|---|---:|---:|---:|---:|---:|---:|
| unweighted frozen head | 0.638 | 0.620 | 0.404 | 0.276 | 0.948 | 0.934 |
| weighted frozen head | 0.667 | 0.680 | 0.734 | 0.672 | 0.948 | 0.934 |
| primary score-confidence | 0.643 | 0.635 | 0.543 | 0.655 | 0.948 | 0.934 |
| original tri-view score-confidence | 0.645 | 0.668 | 0.766 | 0.845 | 0.946 | 0.930 |
| 2.5D score-confidence | 0.436 | 0.378 | 0.000 | 0.000 | 0.756 | 0.631 |

Bootstrap result for weighted frozen head:

| comparison | scope | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---:|---:|---:|
| vs 2.5D | all | +0.168 to +0.298 | +0.639 to +0.828 | +0.124 to +0.273 |
| vs 2.5D | hip/MTL | +0.220 to +0.388 | +0.540 to +0.792 | +0.187 to +0.426 |
| vs primary | all | -0.028 to +0.076 | +0.092 to +0.295 | -0.003 to +0.002 |
| vs primary | hip/MTL | +0.009 to +0.082 | -0.041 to +0.077 | -0.003 to +0.003 |
| vs original tri-view | all | -0.032 to +0.080 | -0.144 to +0.086 | -0.009 to +0.015 |
| vs original tri-view | hip/MTL | -0.041 to +0.070 | -0.274 to -0.083 | -0.016 to +0.026 |

Decision:

- Positive as an active candidate/control, not yet final promoted novelty.
- The weighted frozen head solves the previous direct-CE failure mode: it preserves far-boundary answer AUC because the binary head is frozen.
- It significantly improves hip/MTL three-zone bacc over primary, which is the first positive candidate result in the boundary-aware uncertainty direction.
- It does not significantly beat original tri-view, and hip/MTL uncertain recall is lower than tri-view.
- Next high-value experiment: apply the same primary-preserving/direct-three-zone-head idea to the tri-view representation or a fused primary+tri-view feature, then test whether it keeps tri-view uncertain recall while preserving primary/tri-view far AUC.

## Experiment: Tri-View-Frozen Three-Zone Head

Runs:

- weighted tri-view frozen head: `results/f04_roi_evidence_encoder/20260604_230047_v6_triview_frozen_threezone_head_margin005_uncw2_loco_AJU`
- bootstrap: `results/f04_roi_evidence_encoder/20260604_231000_v6_triview_frozen_threezone_head_bootstrap_audit`
- train/eval script: `scripts/run_f04_v6_triview_frozen_threezone_head.py`
- bootstrap script: `scripts/run_f04_v6_triview_frozen_threezone_head_bootstrap.py`

Design:

- Load original tri-view AJU LOCO checkpoint.
- Freeze global64 + MTL64 + MTL80 encoders, question embedding, and binary answer head.
- Train only a new direct three-zone head.
- Class weights `[1, 2, 1]`.
- Binary answer score is preserved from the single frozen tri-view checkpoint.

Point result:

| run | all zone bacc | hip/MTL zone bacc | all uncertain recall | hip/MTL uncertain recall | all far AUC | hip/MTL far AUC |
|---|---:|---:|---:|---:|---:|---:|
| tri-view frozen weighted head | 0.673 | 0.667 | 0.734 | 0.655 | 0.942 | 0.930 |
| primary frozen weighted head | 0.667 | 0.680 | 0.734 | 0.672 | 0.948 | 0.934 |
| original tri-view score-confidence | 0.645 | 0.668 | 0.766 | 0.845 | 0.946 | 0.930 |
| primary score-confidence | 0.643 | 0.635 | 0.543 | 0.655 | 0.948 | 0.934 |
| 2.5D score-confidence | 0.436 | 0.378 | 0.000 | 0.000 | 0.756 | 0.631 |

Bootstrap result for tri-view frozen weighted head:

| comparison | scope | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---:|---:|---:|
| vs 2.5D | all | +0.172 to +0.306 | +0.635 to +0.833 | +0.119 to +0.260 |
| vs 2.5D | hip/MTL | +0.204 to +0.379 | +0.500 to +0.789 | +0.183 to +0.423 |
| vs primary | all | -0.041 to +0.095 | +0.056 to +0.320 | -0.023 to +0.008 |
| vs primary | hip/MTL | -0.034 to +0.100 | -0.143 to +0.130 | -0.026 to +0.018 |
| vs original tri-view | all | -0.025 to +0.088 | -0.151 to +0.086 | -0.015 to +0.006 |
| vs original tri-view | hip/MTL | -0.049 to +0.048 | -0.300 to -0.086 | -0.004 to +0.004 |
| vs primary frozen weighted | all | -0.040 to +0.049 | -0.093 to +0.084 | -0.022 to +0.007 |
| vs primary frozen weighted | hip/MTL | -0.079 to +0.052 | -0.154 to +0.109 | -0.027 to +0.018 |

Decision:

- Mixed/negative as a novelty candidate.
- It strongly beats 2.5D, but that was already established.
- It does not significantly beat primary, original tri-view, or the primary-frozen weighted head.
- Hip/MTL uncertain recall is significantly lower than original tri-view.
- The stronger current candidate remains the primary-frozen weighted three-zone head, because it improves hip/MTL zone bacc versus primary while preserving primary far AUC.
- The next method should not simply add a direct head to tri-view features. The validation-locked combination hypothesis was tested next and did not produce a promotable method improvement.

## Diagnostic: Validation-Locked Three-Zone Combo

Run:

- `results/f04_roi_evidence_encoder/20260604_232000_v6_threezone_validation_locked_combo_audit`
- script: `scripts/run_f04_v6_threezone_validation_locked_combo_audit.py`

Design:

- Post-hoc only; no new training.
- Candidate decisions combine:
  - primary-frozen weighted direct three-zone head;
  - original tri-view score-confidence.
- Global and question-wise selectors are chosen on non-AJU validation rows only.
- AJU is evaluated once.
- Far AUC in combo rows uses the preserved primary-frozen answer score; the audit primarily evaluates three-zone decision rules.

Validation selection:

```json
{
  "global_selected_candidate": "pred_pf_direct",
  "questionwise_selected_candidates": {
    "normqa_low_hippocampal_volume": "pred_pf_direct",
    "normqa_low_hippocampus_to_ventricle_ratio": "pred_intersection_uncertain_pf_answer",
    "normqa_mtl_atrophy_evidence": "pred_union_uncertain_pf_answer",
    "normqa_ventricle_enlargement": "pred_pf_direct"
  }
}
```

AJU point result:

| rule | all zone bacc | hip/MTL zone bacc | all uncertain recall | hip/MTL uncertain recall |
|---|---:|---:|---:|---:|
| primary-frozen direct | 0.667 | 0.680 | 0.734 | 0.672 |
| tri-view score-confidence | 0.664 | 0.670 | 0.713 | 0.793 |
| global selected | 0.667 | 0.680 | 0.734 | 0.672 |
| question-wise selected | 0.662 | 0.665 | 0.713 | 0.776 |

Bootstrap result:

| comparison | scope | delta zone bacc 95% CI | delta uncertain recall 95% CI |
|---|---|---:|---:|
| global selected vs 2.5D | all | +0.168 to +0.298 | +0.639 to +0.828 |
| global selected vs primary | hip/MTL | +0.008 to +0.083 | -0.039 to +0.079 |
| global selected vs original tri-view | hip/MTL | -0.045 to +0.069 | -0.269 to -0.083 |
| question-wise selected vs original tri-view | hip/MTL | -0.048 to +0.041 | -0.137 to -0.016 |

Decision:

- Negative as a method improvement.
- Validation did not find a useful global combo; it selected primary-frozen direct unchanged.
- Question-wise selection increased hip/MTL uncertain recall relative to primary-frozen direct but reduced zone bacc and still remained significantly below original tri-view uncertain recall.
- The current evidence says the publishable result is the three-zone task framing and 3D-vs-2.5D superiority, not a post-hoc combo method.

## Current Claim Synthesis

Run:

- `results/f04_roi_evidence_encoder/20260604_233000_v6_research_claim_synthesis`
- script: `scripts/run_f04_v6_research_claim_synthesis.py`

Decision:

- Supported main claim 1: ROI-grounded 3D VQA should be evaluated as a three-zone task: far-negative, near-cutoff uncertain, and far-positive.
- Supported main claim 2: 3D models strongly outperform fixed 2.5D context for near-cutoff uncertainty and far-boundary answering.
- Supported method component: global+local 3D fusion tau=0.03 beats global-only and MTL-only branches under the three-zone protocol.
- Active candidate/control: primary-frozen weighted three-zone head. It improves hip/MTL zone bacc versus primary while preserving far AUC, but it does not significantly beat original tri-view.
- Closed promotion paths: generic SSL, direct three-zone CE, answer masking, simple uncertainty heads, tri-view frozen direct heads, and simple validation-locked post-hoc selectors.

Next actions:

- First, prepare manuscript-grade result table and figure for the three-zone task framing.
- Second, external-LOCO three-zone audit for OASIS/NACC has now been completed and strengthens the 3D-vs-2.5D claim.
- Third, only start a new model-novelty experiment if the mechanism explicitly targets tri-view-level hip/MTL uncertain recall while preserving far-boundary AUC.

### External Check: Primary-Frozen Weighted Three-Zone Head

Runs:

- OASIS head:
  `results/f04_roi_evidence_encoder/20260606_122733_v6_primary_frozen_threezone_head_margin005_uncw2_loco_OASIS/`
- OASIS bootstrap:
  `results/f04_roi_evidence_encoder/20260606_123044_v6_external_primary_frozen_threezone_head_bootstrap_OASIS/`
- NACC head:
  `results/f04_roi_evidence_encoder/20260606_123157_v6_primary_frozen_threezone_head_margin005_uncw2_loco_NACC/`
- NACC bootstrap:
  `results/f04_roi_evidence_encoder/20260606_123501_v6_external_primary_frozen_threezone_head_bootstrap_NACC/`
- OASIS transition:
  `results/f04_roi_evidence_encoder/20260606_124341_v6_external_primary_frozen_transition_audit_OASIS/`
- NACC transition:
  `results/f04_roi_evidence_encoder/20260606_124342_v6_external_primary_frozen_transition_audit_NACC/`

Implementation note:

- The first OASIS attempt failed because `MultiViewVolumeQADataset` now returns
  ratio-residual target fields in addition to the original fields.
- `scripts/run_f04_v6_primary_frozen_threezone_head.py` was patched to unpack
  batches by stable positions: global tensor, MTL tensor, question index,
  `threezone_target`, and final `idx`.
- The failed partial output `20260606_122601_*OASIS` was removed.

Result:

| cohort | model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---|---:|---:|---:|---:|
| OASIS | 2.5D | 0.514 | 0.000 | 0.912 | 0.869 |
| OASIS | primary 3D | 0.645 | 0.396 | 0.789 | 0.966 |
| OASIS | tri-view 3D | 0.649 | 0.509 | 0.737 | 0.968 |
| OASIS | primary-frozen head | 0.664 | 0.528 | 0.614 | 0.967 |
| NACC | 2.5D | 0.481 | 0.000 | 0.842 | 0.842 |
| NACC | primary 3D | 0.648 | 0.324 | 0.851 | 0.968 |
| NACC | tri-view 3D | 0.683 | 0.618 | 0.683 | 0.968 |
| NACC | primary-frozen head | 0.645 | 0.632 | 0.535 | 0.968 |

Bootstrap interpretation:

- OASIS versus fixed 2.5D:
  - zone-bacc CI `+0.045` to `+0.244`;
  - far-AUC CI `+0.041` to `+0.178`.
- OASIS versus primary:
  - zone-bacc CI `-0.077` to `+0.109`;
  - far-positive recall CI `-0.352` to `-0.050`.
- NACC versus fixed 2.5D:
  - zone-bacc CI `+0.090` to `+0.244`;
  - far-AUC CI `+0.075` to `+0.189`.
- NACC versus primary:
  - zone-bacc CI `-0.054` to `+0.052`;
  - far-positive recall CI `-0.398` to `-0.228`.
- NACC versus tri-view:
  - zone-bacc CI `-0.081` to `+0.004`;
  - far-positive recall CI `-0.240` to `-0.060`.

Transition diagnosis:

- OASIS versus fixed 2.5D:
  - overall gain/regression/net `54/21/+33`;
  - uncertain net `+28`;
  - far-negative net `+22`;
  - far-positive net `-17`.
- OASIS versus primary:
  - overall `27/20/+7`;
  - uncertain net `+7`;
  - far-negative net `+10`;
  - far-positive net `-10`.
- NACC versus fixed 2.5D:
  - overall `87/50/+37`;
  - uncertain net `+43`;
  - far-negative net `+25`;
  - far-positive net `-31`.
- NACC versus primary:
  - overall `23/34/-11`;
  - uncertain net `+21`;
  - far-negative net `0`;
  - far-positive net `-32`.

Decision:

- The primary-frozen weighted head externally confirms the broad 3D-over-2.5D
  result.
- It should not be promoted as method novelty.
- Its high uncertain recall is obtained by over-abstaining far-positive rows,
  especially in NACC ratio/vent rows.
- The stronger conclusion is now negative: even an answer-score-preserving
  uncertainty branch does not solve the far-positive/uncertain tradeoff under
  external LOCO.

### External Primary-Preserving Frozen-Head Overlay Closure

Runs:

- OASIS overlay:
  `results/f04_roi_evidence_encoder/20260606_125152_v6_external_primary_frozen_overlay_audit_OASIS/`
- NACC overlay:
  `results/f04_roi_evidence_encoder/20260606_125152_v6_external_primary_frozen_overlay_audit_NACC/`
- script:
  `scripts/run_f04_v6_external_primary_frozen_overlay_audit.py`

Design:

- Post-hoc validation-locked decision audit.
- The overlay starts from the primary 3D three-zone decision and keeps the
  primary answer score.
- The direct frozen-head candidate can only promote a primary far-boundary
  decision to uncertain when the validation-selected candidate uncertain
  probability is high.
- Clinical, scanner, ROI, evidence percentile, and CDR fields are not model
  inputs; they are labels or audit stratifiers only.

Result:

| cohort | model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---|---:|---:|---:|---:|
| OASIS | primary 3D | 0.645 | 0.396 | 0.789 | 0.966 |
| OASIS | direct frozen head | 0.664 | 0.528 | 0.614 | 0.967 |
| OASIS | primary-preserving overlay | 0.667 | 0.472 | 0.789 | 0.966 |
| NACC | primary 3D | 0.648 | 0.324 | 0.851 | 0.968 |
| NACC | direct frozen head | 0.645 | 0.632 | 0.535 | 0.968 |
| NACC | primary-preserving overlay | 0.644 | 0.353 | 0.812 | 0.968 |

Bootstrap interpretation:

- OASIS overlay versus fixed 2.5D:
  - zone-bacc CI `+0.078` to `+0.223`;
  - far-AUC CI `+0.039` to `+0.177`.
- OASIS overlay versus primary:
  - zone-bacc CI `+0.000` to `+0.046`;
  - uncertain recall CI `+0.018` to `+0.147`;
  - far-positive recall delta `0.000`.
- NACC overlay versus fixed 2.5D:
  - zone-bacc CI `+0.102` to `+0.229`;
  - far-AUC CI `+0.076` to `+0.190`.
- NACC overlay versus primary:
  - zone-bacc CI `-0.021` to `+0.016`;
  - uncertain recall CI `0.000` to `+0.075`;
  - far-positive recall CI `-0.079` to `-0.009`.

Transition diagnosis:

- OASIS versus primary: gain/regression/net `4/1/+3`; gains are uncertain
  rows and far-positive is preserved.
- NACC versus primary: gain/regression/net `2/4/-2`; all primary regressions
  are far-positive rows.

Decision:

- The overlay fixes the worst direct-head far-positive collapse on OASIS, but
  it does not reproduce on NACC.
- Therefore the primary-frozen uncertainty-head family remains a negative
  method-control family, not a promotable technical contribution.
- This result raises the bar for the next model experiment: it must be a
  representation-level change, not another post-hoc uncertainty gate.

## Manuscript Asset Pack

Run:

- `results/f04_roi_evidence_encoder/20260604_234000_v6_threezone_manuscript_assets`
- script: `scripts/run_f04_v6_threezone_manuscript_assets.py`

Contents:

- `main_threezone_results_table.md/.csv`: internal matched-test and AJU held-out LOCO 2.5D-vs-3D comparison.
- `external_loco_threezone_results_table.md/.csv`: OASIS/NACC held-out LOCO 2.5D-vs-3D comparison.
- `figure_1_threezone_3d_vs_2p5d.png/.svg`: bar figure for zone bacc, near-cutoff uncertain recall, and far-boundary AUC.
- `figure_2_delta_zone_bacc_ci_vs_2p5d.png/.svg`: subject-level bootstrap CI figure for 3D gains over fixed 2.5D.

Use:

- This pack is suitable for the current main result story: three-zone ROI-VQA task framing and 3D superiority over fixed 2.5D context.
- It should not be used to claim that the current uncertainty head is final method novelty.

## External LOCO Three-Zone Audit

Run:

- `results/f04_roi_evidence_encoder/20260604_235000_v6_external_loco_threezone_audit`
- script: `scripts/run_f04_v6_external_loco_threezone_audit.py`

Design:

- Cohorts: OASIS and NACC held-out LOCO.
- Models: fixed 2.5D context, primary 3D, tri-view 3D.
- Thresholds: selected on validation rows only for each model; held-out cohort test rows are evaluated once.
- Alignment: predictions are joined by `qa_id`; target zones use evidence percentile and boundary distance only for evaluation.

Main result:

| cohort | scope | comparison | delta zone bacc 95% CI | delta uncertain recall 95% CI | delta far AUC 95% CI |
|---|---|---|---:|---:|---:|
| OASIS | all | primary vs 2.5D | +0.064 to +0.195 | +0.245 to +0.544 | +0.037 to +0.170 |
| OASIS | all | tri-view vs 2.5D | +0.051 to +0.216 | +0.362 to +0.661 | +0.040 to +0.172 |
| NACC | all | primary vs 2.5D | +0.101 to +0.231 | +0.191 to +0.460 | +0.073 to +0.189 |
| NACC | all | tri-view vs 2.5D | +0.124 to +0.278 | +0.435 to +0.786 | +0.071 to +0.191 |

Decision:

- External LOCO evidence supports the main three-zone 3D-vs-2.5D claim.
- Tri-view improves uncertain recall over primary, but zone bacc and far AUC comparisons versus primary are not robust enough for a standalone method novelty claim.

## External LOCO Error Structure Audit

Run:

- `results/f04_roi_evidence_encoder/20260605_000000_v6_external_loco_error_structure_audit`
- script: `scripts/run_f04_v6_external_loco_error_structure_audit.py`

Design:

- Post-hoc diagnostic only.
- Uses `aligned_external_loco_threezone_predictions.csv` from the external LOCO three-zone audit.
- Compares fixed 2.5D, primary 3D, and tri-view 3D by `qa_id`.
- Evidence percentile, boundary distance, true zone, question, and cohort are audit-only fields.

Main transition result:

| cohort | model | 2.5D wrong -> 3D correct | 2.5D correct -> 3D wrong | both wrong | uncertain rate among both-wrong |
|---|---|---:|---:|---:|---:|
| NACC | primary | 67 | 19 | 77 | 0.597 |
| NACC | tri-view | 87 | 39 | 57 | 0.456 |
| OASIS | primary | 46 | 20 | 49 | 0.653 |
| OASIS | tri-view | 46 | 22 | 49 | 0.531 |

Decision:

- The 3D-vs-2.5D improvement mechanism is now interpretable: 2.5D has zero uncertain recall, while 3D recovers a substantial portion of near-cutoff uncertain rows.
- Remaining external failures are not random; both-wrong rows are enriched for true uncertain near-cutoff examples.
- Tri-view increases uncertain recall, especially on NACC, but also creates more 2.5D-correct -> 3D-wrong regressions and more far-positive-to-uncertain errors. This is a representation/uncertainty sensitivity signal, not enough for standalone method novelty.
- The next model-side experiment must explicitly control this tradeoff: improve uncertain recall without sacrificing far-positive recall or far-boundary AUC.

## Far-Positive Guardrail Three-Zone Audit

Run:

- `results/f04_roi_evidence_encoder/20260605_001000_v6_far_positive_guardrail_threezone_audit`
- script: `scripts/run_f04_v6_far_positive_guardrail_threezone_audit.py`

Design:

- Post-hoc validation-locked threshold audit across AJU, OASIS, and NACC.
- Policies:
  - `score_only_no_uncertain`: binary score-only reference.
  - `max_zone_bacc`: unconstrained validation-selected uncertainty threshold.
  - `fp_guard_95pct_score_only_recall`: preserves at least 95% of validation score-only far-positive recall.
  - `fp_guard_90pct_score_only_recall`: preserves at least 90% of validation score-only far-positive recall.
- Transition counts are computed after `qa_id` alignment; a positional-array prototype was discarded after it failed to match the external LOCO audit counts.

Key result:

| cohort | model | policy | zone bacc | uncertain recall | far-positive recall |
|---|---|---|---:|---:|---:|
| AJU | tri-view | max-zone-bacc | 0.662 | 0.713 | 0.654 |
| AJU | tri-view | 90% FP guardrail | 0.637 | 0.415 | 0.750 |
| OASIS | tri-view | max-zone-bacc | 0.649 | 0.509 | 0.737 |
| OASIS | tri-view | 90% FP guardrail | 0.642 | 0.208 | 0.860 |
| NACC | tri-view | max-zone-bacc | 0.683 | 0.618 | 0.683 |
| NACC | tri-view | 90% FP guardrail | 0.673 | 0.309 | 0.881 |

Decision:

- Far-positive recall can be restored by conservative thresholds, but this discards a large part of the near-cutoff uncertain recall.
- The current score-confidence signal does not cleanly separate boundary-near uncertainty from true far-positive atrophy evidence.
- Simple threshold selectors are therefore closed as a promotion path.
- A new method-side experiment is only justified if it has a mechanism for disentangling near-cutoff uncertainty from confident far-positive evidence while preserving far-boundary AUC.

## Asymmetric Interval Three-Zone Audit

Run:

- `results/f04_roi_evidence_encoder/20260605_002000_v6_asymmetric_interval_threezone_audit`
- script: `scripts/run_f04_v6_asymmetric_interval_threezone_audit.py`

Design:

- Post-hoc validation-locked interval audit across AJU, OASIS, and NACC.
- No new model is trained.
- Decision rule:
  - `score < low`: far-negative.
  - `low <= score < high`: uncertain near cutoff.
  - `score >= high`: far-positive.
- Policies:
  - `score_only_no_uncertain`
  - `asymmetric_max_zone_bacc`
  - `asymmetric_fp_guard_95pct_score_only_recall`
  - `asymmetric_fp_guard_90pct_score_only_recall`
- Evidence percentile and boundary distance are used only to define evaluation targets and audit strata, not as model inputs.

Key result:

| cohort | model | policy | zone bacc | uncertain recall | far-positive recall |
|---|---|---|---:|---:|---:|
| AJU | tri-view | asymmetric max-zone-bacc | 0.647 | 0.787 | 0.519 |
| AJU | tri-view | 90% FP guardrail | 0.628 | 0.511 | 0.740 |
| OASIS | tri-view | asymmetric max-zone-bacc | 0.671 | 0.415 | 0.737 |
| OASIS | tri-view | 90% FP guardrail | 0.642 | 0.208 | 0.860 |
| NACC | tri-view | asymmetric max-zone-bacc | 0.684 | 0.603 | 0.693 |
| NACC | tri-view | 90% FP guardrail | 0.665 | 0.338 | 0.901 |

Transition result versus fixed 2.5D:

| cohort | model | policy | gain | regression | far-positive -> uncertain | uncertain recovered |
|---|---|---|---:|---:|---:|---:|
| AJU | tri-view | asymmetric max-zone-bacc | 102 | 48 | 47 | 74 |
| AJU | tri-view | 90% FP guardrail | 84 | 33 | 24 | 48 |
| OASIS | tri-view | asymmetric max-zone-bacc | 51 | 16 | 12 | 22 |
| OASIS | tri-view | 90% FP guardrail | 40 | 9 | 5 | 11 |
| NACC | tri-view | asymmetric max-zone-bacc | 86 | 37 | 27 | 41 |
| NACC | tri-view | 90% FP guardrail | 73 | 21 | 6 | 23 |

Decision:

- Asymmetric intervals show that decision geometry contributes to the failure: unconstrained intervals recover more uncertain rows than score-only binary prediction.
- However, preserving far-positive recall still removes a large fraction of uncertain-row recovery.
- This closes score-interval policies as a method-novelty path.
- The next experiment should train a model/head with two separated signals: answer evidence polarity and boundary-near uncertainty. The success criterion must include far-positive recall or far-boundary AUC preservation, not only zone bacc.

## Primary-Frozen Boundary Head Experiment

Run:

- incomplete partial run: `results/f04_roi_evidence_encoder/20260605_002044_v6_primary_frozen_boundary_head_margin005_posw2_loco_AJU`
- completed run: `results/f04_roi_evidence_encoder/20260606_071215_v6_primary_frozen_boundary_head_margin005_posw2_loco_AJU`
- bootstrap audit: `results/f04_roi_evidence_encoder/20260606_072000_v6_primary_frozen_boundary_head_bootstrap_audit`
- scripts:
  - `scripts/run_f04_v6_primary_frozen_boundary_head.py`
  - `scripts/run_f04_v6_primary_frozen_boundary_head_bootstrap.py`

Design:

- Controlled test of the proposed separation.
- Load the primary 3D AJU LOCO checkpoint.
- Freeze the global/MTL encoders, question embedding, and binary answer head.
- Train only the uncertainty head to predict `boundary_distance <= 0.05`.
- Three-zone decision:
  - frozen answer score decides far-negative versus far-positive polarity.
  - boundary head decides whether to override as uncertain near cutoff.
- Model input remains image tensor plus question ID only.
- Evidence percentile and boundary distance are train-time target/audit fields, not model inputs.

AJU test result:

| policy | scope | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---|---:|---:|---:|---:|
| score only | all | 0.585 | 0.000 | 0.875 | 0.948 |
| boundary head 0.5 | all | 0.671 | 0.734 | 0.490 | 0.948 |
| boundary max-zone-bacc | all | 0.649 | 0.585 | 0.538 | 0.948 |
| boundary 90% FP guardrail | all | 0.620 | 0.223 | 0.769 | 0.948 |
| boundary head 0.5 | hip/MTL | 0.693 | 0.638 | 0.677 | 0.934 |

2.5D transition result:

| policy | gain | regression | net gain | uncertain recovered | far-positive -> uncertain |
|---|---:|---:|---:|---:|---:|
| score only | 63 | 11 | +52 | 0 | 0 |
| boundary head 0.5 | 109 | 41 | +68 | 69 | 45 |
| boundary max-zone-bacc | 100 | 36 | +64 | 55 | 40 |
| boundary 90% FP guardrail | 78 | 18 | +60 | 21 | 11 |

Bootstrap result:

| comparison | scope | delta zone bacc 95% CI | decision |
|---|---|---:|---|
| boundary 0.5 vs 2.5D | all | +0.168 to +0.300 | strong positive |
| boundary 0.5 vs 2.5D | hip/MTL | +0.232 to +0.397 | strong positive |
| boundary 0.5 vs primary | hip/MTL | +0.003 to +0.112 | positive but narrow |
| boundary 0.5 vs original tri-view | all | -0.032 to +0.087 | not significant |
| boundary 0.5 vs primary-frozen weighted | all | -0.033 to +0.038 | not significant |

Decision:

- The boundary head is a useful controlled diagnostic: it confirms that separating answer polarity from boundary uncertainty can recover near-cutoff rows without changing the answer score.
- It strongly reinforces the 3D-vs-2.5D three-zone task claim.
- It is not yet a standalone method novelty because it does not significantly beat original tri-view or primary-frozen weighted direct head, and the all-question operating points still trade off far-positive recall.
- The next model-side step should not be another threshold sweep. It should improve the boundary representation itself, likely by adding hard far-positive preservation during boundary-head training or by learning a question-specific boundary gate with explicit far-positive regularization.

## Far-Positive-Preserving Boundary Head Variant

Run:

- completed run: `results/f04_roi_evidence_encoder/20260606_072612_v6_primary_frozen_boundary_head_margin005_posw2_fpneg2_loco_AJU`
- bootstrap audit: `results/f04_roi_evidence_encoder/20260606_073000_v6_primary_frozen_boundary_head_fpneg2_bootstrap_audit`

Design:

- Same frozen-primary polarity/boundary separation setup.
- Boundary positive weight remains 2.0.
- Far-positive rows receive negative boundary loss weight 2.0.
- Goal: reduce far-positive-to-uncertain errors without losing all near-cutoff uncertain recovery.

Key AJU result:

| model/policy | zone bacc | uncertain recall | far-positive recall | far-positive -> uncertain | uncertain recovered |
|---|---:|---:|---:|---:|---:|
| posw2 boundary 0.5 | 0.671 | 0.734 | 0.490 | 45 | 69 |
| posw2 max-zone-bacc | 0.649 | 0.585 | 0.538 | 40 | 55 |
| fpneg2 boundary 0.5 | 0.607 | 0.202 | 0.731 | 15 | 19 |
| fpneg2 max-zone-bacc | 0.652 | 0.660 | 0.558 | 39 | 62 |
| fpneg2 90% FP guardrail | 0.609 | 0.234 | 0.721 | 16 | 22 |

Bootstrap result:

| comparison | scope | delta zone bacc 95% CI | decision |
|---|---|---:|---|
| fpneg2 max-zone-bacc vs 2.5D | all | +0.150 to +0.280 | strong positive |
| fpneg2 max-zone-bacc vs 2.5D | hip/MTL | +0.173 to +0.357 | strong positive |
| fpneg2 max-zone-bacc vs primary | all | -0.051 to +0.069 | not significant |
| fpneg2 max-zone-bacc vs original tri-view | all | -0.052 to +0.064 | not significant |
| fpneg2 max-zone-bacc vs primary-frozen weighted | all | -0.047 to +0.014 | not significant |

Decision:

- Far-positive preservation weighting is directionally useful: it reduces far-positive over-abstention at conservative thresholds and slightly improves the max-zone-bacc uncertain/far-positive balance.
- It still does not produce a promotable method because it fails to beat existing 3D controls with bootstrap support.
- The next real method step should not be more scalar loss weighting. The likely bottleneck is question- and ROI-specific boundary separability. A credible next experiment would use question-specific boundary gates or a calibrated two-dimensional decision surface using boundary score plus answer score, with validation-locked far-positive constraints.

## Boundary-Answer 2D Decision Surface Audit

Run:

- decision audit: `results/f04_roi_evidence_encoder/20260606_074000_v6_boundary_answer_2d_decision_audit`
- bootstrap audit: `results/f04_roi_evidence_encoder/20260606_075000_v6_boundary_answer_2d_bootstrap_audit`
- scripts:
  - `scripts/run_f04_v6_boundary_answer_2d_decision_audit.py`
  - `scripts/run_f04_v6_boundary_answer_2d_bootstrap.py`

Design:

- Post-hoc validation-locked decision surface.
- No model retraining.
- Uses two image-model scores:
  - frozen answer score for evidence polarity.
  - boundary uncertainty score for near-cutoff uncertainty.
- Decision rule:
  - uncertain iff `boundary_score >= b_threshold` and `answer_score_uncertainty >= u_threshold`
  - otherwise use answer score polarity for far-negative/far-positive.
- Global thresholds and question-wise thresholds are selected on validation only.

Key AJU result:

| run/policy | zone bacc | uncertain recall | far-positive recall | far-positive -> uncertain | uncertain recovered |
|---|---:|---:|---:|---:|---:|
| posw2 boundary-only max | 0.649 | 0.585 | 0.538 | 40 | 55 |
| posw2 global 2D max | 0.668 | 0.564 | 0.615 | 32 | 53 |
| posw2 global 2D 90% FP guard | 0.652 | 0.383 | 0.750 | 18 | 36 |
| fpneg2 global 2D max | 0.661 | 0.628 | 0.615 | 33 | 59 |
| fpneg2 global 2D 90% FP guard | 0.653 | 0.479 | 0.712 | 23 | 45 |

Bootstrap result:

| comparison | scope | delta zone bacc 95% CI | decision |
|---|---|---:|---|
| posw2 global 2D max vs 2.5D | all | +0.161 to +0.300 | strong positive |
| posw2 global 2D max vs primary | all | -0.044 to +0.089 | not significant |
| posw2 global 2D max vs original tri-view | all | -0.042 to +0.087 | not significant |
| posw2 global 2D max vs primary-frozen weighted | all | -0.038 to +0.038 | not significant |
| fpneg2 global 2D max vs 2.5D | all | +0.162 to +0.289 | strong positive |
| fpneg2 global 2D max vs primary/original tri-view/primary-frozen weighted | all | CIs cross zero | not significant |

Decision:

- The 2D surface confirms part of the failure is decision geometry: answer confidence suppresses some boundary-head far-positive over-abstention.
- It still does not beat existing 3D controls with bootstrap support.
- The next model-side experiment should improve the boundary representation rather than only changing inference geometry. The most plausible next step is question-specific boundary representation training with explicit far-positive preservation and a locked 2D decision surface as the evaluation rule.

## Questionwise Boundary Head Audit

Run:

- completed run: `results/f04_roi_evidence_encoder/20260606_075609_v6_primary_frozen_questionwise_boundary_head_margin005_posw2_fpneg2_loco_AJU`
- bootstrap audit: `results/f04_roi_evidence_encoder/20260606_081000_v6_primary_frozen_questionwise_boundary_head_bootstrap_audit`
- script: `scripts/run_f04_v6_primary_frozen_questionwise_boundary_head.py`

Design:

- Freeze the primary 3D global+MTL encoder, question embedding, and shared binary answer head.
- Train one boundary uncertainty head per question/ROI.
- Keep model inputs restricted to image tensors plus question ID.
- Use evidence percentile, boundary distance, and three-zone labels only as targets/audit fields.
- Use far-positive negative loss weight 2.0 to discourage over-abstaining true far-positive rows.

Key AJU result:

| policy/scope | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| max-zone-bacc / all | 0.655 | 0.734 | 0.500 | 0.948 |
| max-zone-bacc / hip-MTL | 0.632 | 0.655 | 0.597 | 0.935 |
| 90% FP guardrail / all | 0.620 | 0.255 | 0.731 | 0.948 |

Bootstrap result:

| comparison | scope | delta zone bacc 95% CI | decision |
|---|---|---:|---|
| questionwise max-zone-bacc vs 2.5D | all | +0.156 to +0.284 | strong positive |
| questionwise max-zone-bacc vs 2.5D | hip/MTL | +0.167 to +0.341 | strong positive |
| questionwise max-zone-bacc vs primary | all | -0.056 to +0.079 | not significant |
| questionwise max-zone-bacc vs original tri-view | all | -0.043 to +0.062 | not significant |
| questionwise max-zone-bacc vs primary-frozen weighted | all | -0.052 to +0.027 | not significant |

Decision:

- Question-specific boundary gates learn near-cutoff uncertainty, but they do not solve the far-positive uncertainty tradeoff.
- The run reinforces the robust 3D-vs-2.5D three-zone claim, but it is not a promotable method novelty.
- More boundary-head variants are low priority unless they add a genuinely new representation constraint. The next useful model experiment should target representation learning for boundary-sensitive 3D morphology while preserving primary far-boundary polarity, or move to manuscript-quality task framing and external validation rather than another scalar gate.

## Representation Robustness Update: Morphometry Bar and Style-Consistency Negative Result

External modeling reference:

- playbook: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md`
- #9 result: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/09_modeling_path_comparison/RESULTS.md`
- morphometry + simple norm LOCO bar: train-z `0.910`, ICV `0.909`

New representation run:

- candidate run: `results/f04_roi_evidence_encoder/20260606_080834_v6_multiview_preinit_unfreeze_styleconsistency_boundaryrank_loco_AJU`
- three-zone/bootstrap audit: `results/f04_roi_evidence_encoder/20260606_081819_v6_unfreeze_styleconsistency_boundaryrank_threezone_bootstrap_audit`
- candidate style audit: `results/f04_roi_evidence_encoder/20260606_082500_v6_unfreeze_styleconsistency_boundaryrank_style_perturbation_audit/case_review/style_perturbation_audit`
- fair primary style audit: `results/f04_roi_evidence_encoder/20260606_082800_v6_primary_loco_style_perturbation_audit/case_review/style_perturbation_audit`
- consolidated report: `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`

Result:

| model | AJU binary AUC | AJU bacc | three-zone zone bacc | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.684 | 0.597 | 0.436 | 0.756 |
| primary 3D | 0.879 | 0.785 | 0.643 | 0.948 |
| original tri-view | 0.877 | 0.788 | 0.645 | 0.946 |
| unfreeze+style consistency+boundary rank | 0.853 | 0.741 | 0.646 | 0.932 |
| morphometry simple norm external bar | 0.910 | n/a | n/a | n/a |

Bootstrap:

| comparison | all-question delta zone-bacc 95% CI | decision |
|---|---:|---|
| candidate vs fixed 2.5D | +0.155 to +0.271 | positive |
| candidate vs primary | -0.056 to +0.060 | not significant |
| candidate vs original tri-view | -0.049 to +0.052 | not significant |

Style audit:

- The candidate lowers average perturbation flip rate relative to primary, including AJU hippocampal GE rows.
- However, baseline AJU AUC drops from primary `0.879` to candidate `0.853`, and far AUC drops from `0.948` to `0.932`.
- Interpretation: train-time perturbation consistency likely suppresses useful morphology/ranking signal while making outputs less sensitive. This is an erase-style failure, not a successful acquisition-conditioned representation.

Decision:

- Stop scalar augmentation/consistency/boundary-ranking sweeps in this form.
- Image-model claims must now be judged against both the fixed 2.5D lower bound and the morphometry simple-norm `0.91` bar.
- The next image experiment should be one of the playbook-backed untested levers only:
  - acquisition-conditioned normalization such as DSBN keyed by vendor/field/voxel, not raw consortium;
  - foundation/pretrained 3D encoder features plus linear/shallow LOCO probe;
  - test-time BN/TENT-style adaptation with the same validation-locked three-zone and morphometry-bar reporting.

## DSBN Follow-Up Result

Runs:

- vendor DSBN: `results/f04_roi_evidence_encoder/20260606_083311_v6_multiview_dsbn_vendor_loco_AJU`
- vendor DSBN three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_083903_v6_dsbn_vendor_threezone_bootstrap_audit`
- vendor+field fallback DSBN: `results/f04_roi_evidence_encoder/20260606_084015_v6_multiview_dsbn_vendorfieldfallback_loco_AJU`
- vendor+field fallback three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_084533_v6_dsbn_vendorfieldfallback_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_multiview_dsbn_acq_loco.py`

Result:

| model | AJU AUC | AJU bacc | three-zone zone bacc | far AUC |
|---|---:|---:|---:|---:|
| primary 3D | 0.879 | 0.785 | 0.643 | 0.948 |
| original tri-view | 0.877 | 0.788 | 0.645 | 0.946 |
| DSBN vendor | 0.848 | 0.756 | 0.585 | 0.921 |
| DSBN vendor+field fallback | 0.820 | 0.729 | 0.570 | 0.906 |
| fixed 2.5D | 0.684 | 0.597 | 0.436 | 0.756 |
| morphometry simple-norm bar | 0.910 | n/a | n/a | n/a |

Bootstrap:

- DSBN vendor vs primary: zone-bacc CI `-0.119` to `-0.002`; far-AUC CI `-0.051` to `-0.009`.
- DSBN vendor vs original tri-view: zone-bacc CI `-0.117` to `-0.010`; far-AUC CI `-0.050` to `-0.002`.
- DSBN vendor+field fallback is even weaker.

Decision:

- DSBN is feasible and respects the input guardrail, but the tested acquisition-conditioned BN variants are negative.
- Vendor+field fallback likely fragments already small domain groups and destabilizes BN statistics.
- Stop DSBN variants unless a substantially different implementation is proposed, such as foundation features with domain-conditioned shallow heads or test-time BN adaptation.
- The remaining image-side experiment worth running is foundation/pretrained 3D feature extraction plus a shallow LOCO probe. If that cannot beat the 0.91 morphometry bar, image work should be framed as ROI-grounded VQA/task evaluation rather than classifier superiority.

## Famous SSL Feature Probe Result

Runs:

- source feature run: `results/f04_roi_evidence_encoder/20260602_025316_famous_ssl_dinov2_transformers_full_v1`
- shallow LOCO probe: `results/f04_roi_evidence_encoder/20260606_085423_v6_famous_ssl_dinov2_shallow_probe_loco_AJU`
- three-zone/bootstrap audit: `results/f04_roi_evidence_encoder/20260606_085627_v6_famous_ssl_dinov2_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_famous_ssl_feature_probe.py`

Design:

- Reuse frozen `facebook/dinov2-small` adjacent-slice SSL session features.
- Train a shallow logistic probe on SSL features plus question ID only.
- Exclude AJU from train/validation and test only AJU.
- Align features to VQA rows by canonical tensor-session path because the old SSL export and current VQA manifest do not share a direct `join_key`.
- Keep forbidden inputs out of the model: scanner/acquisition, raw consortium, diagnosis/CDR, age/sex, ROI values, ROI percentiles, evidence percentiles, and AEB features.

Result:

| model | AJU AUC | AJU bacc | three-zone zone bacc | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D subset | n/a | n/a | 0.472 | 0.822 |
| primary 3D subset | n/a | n/a | 0.623 | 0.930 |
| original tri-view subset | n/a | n/a | 0.648 | 0.913 |
| DINOv2 shallow probe | 0.616 | 0.555 | 0.381 | 0.684 |
| morphometry simple-norm bar | 0.910 | n/a | n/a | n/a |

Question-level DINOv2 AJU AUC:

- hippocampal volume: `0.535`
- hippocampus-to-ventricle ratio: `0.829`
- MTL atrophy: `0.366`
- ventricle enlargement: `0.795`

Bootstrap:

- DINOv2 vs primary: zone-bacc CI `-0.375` to `-0.116`; far-AUC CI `-0.412` to `-0.096`.
- DINOv2 vs original tri-view: zone-bacc CI `-0.407` to `-0.123`; far-AUC CI `-0.390` to `-0.080`.
- DINOv2 vs fixed 2.5D: zone-bacc CI crosses zero, while far-AUC CI is negative.

Decision:

- Negative control. Famous 2D SSL features are not a solution for the current image-signal bottleneck.
- The failure is anatomically informative: hippocampal and MTL rows collapse, while ratio/ventricle rows remain easier. This matches the broader finding that cutoff-sensitive medial temporal morphology needs real 3D local representation.
- Do not continue generic 2D SSL feature probes.
- A foundation-feature follow-up is only justified if it uses genuine 3D medical-volume pretraining and is tested under the same AJU LOCO, three-zone bootstrap, and morphometry 0.91 bar.

## Immediate Next Decision

The model-side search space is now narrow:

1. Continue only with a genuine 3D medical foundation encoder after license/input-channel/protocol vetting, or a substantially different pre-registered TENT-style protocol.
2. Otherwise stop adding representation variants and shift effort to manuscript-grade framing: ROI-grounded three-zone VQA, 3D-over-2.5D evidence, global+local fusion, and explicit negative controls against generic SSL/DSBN/TTA/threshold-only methods.
3. Any new model must preserve primary far-boundary AUC before it can be considered useful; improving uncertain recall by erasing far-positive or hippocampal/MTL ranking is not acceptable.

## BN Test-Time Adaptation Result

Runs:

- source-mode loader check: `results/f04_roi_evidence_encoder/20260606_090454_v6_multiview_bn_tta_source_smoke_loco_AJU`
- BN reset recalibration: `results/f04_roi_evidence_encoder/20260606_090524_v6_multiview_bn_tta_recalib_reset_loco_AJU`
- BN reset three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_090558_v6_bn_tta_recalib_reset_threezone_bootstrap_audit`
- BN momentum adaptation: `results/f04_roi_evidence_encoder/20260606_090524_v6_multiview_bn_tta_momentum010_loco_AJU`
- BN momentum three-zone/bootstrap: `results/f04_roi_evidence_encoder/20260606_090557_v6_bn_tta_momentum010_threezone_bootstrap_audit`
- script: `scripts/run_f04_v6_multiview_bn_tta_loco.py`

Design:

- Reload the primary AJU LOCO multiview 3D checkpoint.
- Use label-free split-wise BN adaptation.
- Validation split: BN statistics adapted on non-AJU validation images before writing validation predictions.
- Test split: BN statistics adapted on AJU test images before writing test predictions.
- Adaptation inputs are only global 3D tensor, MTL-crop 3D tensor, and question ID.
- Labels, clinical fields, scanner/acquisition metadata, raw consortium, ROI values, evidence percentiles, and AEB features are not used for adaptation.

Result:

| model | AJU AUC | AJU bacc | three-zone zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|---:|---:|
| fixed 2.5D | 0.684 | 0.597 | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.879 | 0.785 | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.877 | 0.788 | 0.645 | 0.766 | 0.635 | 0.946 |
| BN reset TTA | 0.878 | 0.791 | 0.624 | 0.649 | 0.644 | 0.945 |
| BN momentum TTA | 0.878 | 0.791 | 0.625 | 0.702 | 0.625 | 0.947 |
| morphometry simple-norm bar | 0.910 | n/a | n/a | n/a | n/a | n/a |

Bootstrap:

- BN reset vs primary: zone-bacc CI `-0.052` to `+0.012`; far-AUC CI `-0.008` to `+0.001`.
- BN reset vs original tri-view: zone-bacc CI `-0.064` to `+0.019`; far-AUC CI `-0.014` to `+0.011`.
- BN momentum vs primary: zone-bacc CI `-0.057` to `+0.018`; far-AUC CI `-0.004` to `+0.002`.
- BN momentum vs original tri-view: zone-bacc CI `-0.056` to `+0.017`; far-AUC CI `-0.011` to `+0.014`.

Decision:

- Negative diagnostic. Label-free BN TTA does not beat primary or original tri-view.
- The source-mode smoke exactly reproduces the primary checkpoint, so the comparison is implementation-aligned.
- Simple target-domain BN statistics are not the main bottleneck.
- The remaining failure is more likely cutoff-sensitive 3D medial temporal representation/ranking, not a generic scanner-statistics normalization issue.
- Do not continue simple BN-stat variants.

## 3D Foundation Model Availability Check

Report:

- `reports/F04_3D_FOUNDATION_MODEL_AVAILABILITY_NOTE_20260606.md`

Finding:

- Local cache contains 2D DINOv2 and project-specific 3D ROI-VQA checkpoints, but no drop-in 3D brain MRI foundation checkpoint.
- BrainSegFounder is the most anatomically relevant external candidate because it provides UK Biobank brain MRI SSL weights, but the model card uses a T1+T2 SSLHead configuration and lists a UK Biobank MTA license; it needs license and T1-only adaptation review before use.
- OpenMind/PrimusM is methodologically relevant, but its model card warns that the checkpoints are not recommended as-is for feature extraction and should use downstream adaptation frameworks.
- MONAI SwinUNETR SSL is important historical precedent, but the original pretraining was CT, not brain T1w MRI.

Decision:

- Do not run an opportunistic external 3D foundation probe in the current experiment stream.
- A future foundation experiment must pre-register checkpoint, license basis, input adaptation, feature layer, pooling rule, and evaluation protocol before touching AJU test predictions.

## Representation Control Transition Synthesis

Runs:

- synthesis: `results/f04_roi_evidence_encoder/20260606_091614_v6_representation_control_transition_synthesis`
- transition audits:
  - `results/f04_roi_evidence_encoder/20260606_091447_v6_unfreeze_styleconsistency_boundaryrank_transition_audit`
  - `results/f04_roi_evidence_encoder/20260606_091447_v6_dsbn_vendor_transition_audit`
  - `results/f04_roi_evidence_encoder/20260606_091447_v6_dsbn_vendorfieldfallback_transition_audit`
  - `results/f04_roi_evidence_encoder/20260606_091505_v6_famous_ssl_dinov2_transition_audit`
  - `results/f04_roi_evidence_encoder/20260606_091505_v6_bn_tta_recalib_reset_transition_audit`
  - `results/f04_roi_evidence_encoder/20260606_091505_v6_bn_tta_momentum010_transition_audit`

Main finding:

- Versus fixed 2.5D, style consistency, DSBN, and BN TTA all produce positive net gains because they recover many uncertain rows.
- Versus primary 3D, the same candidates regress far-boundary rows:
  - style consistency: uncertain `+9`, far-positive `-15`;
  - DSBN vendor: uncertain `+13`, far-negative `-31`, far-positive `-10`;
  - DSBN vendor+field: uncertain `+7`, far-negative `-27`, far-positive `-11`;
  - BN reset: uncertain `+10`, far-negative `-14`, far-positive `-7`;
  - BN momentum: uncertain `+15`, far-negative `-18`, far-positive `-9`.
- DINOv2 is not a near-miss: uncertain `-27` and far-positive `-11` versus primary on its matched subset.

Decision:

- Do not treat uncertain-row recovery alone as method novelty. It is easy to increase uncertain recall by sacrificing primary-correct far-boundary decisions.
- The next method must be evaluated with an explicit two-part gate:
  1. uncertain-row net gain versus primary must be positive;
  2. far-positive and far-negative net regression versus primary must be near zero or statistically non-negative.
- If no method satisfies both, stop model iteration and frame the manuscript around the validated task/evaluation and 3D-vs-2.5D evidence.

## Primary-Preserving Overlay Audit

Report:

- `reports/F04_PRIMARY_PRESERVING_OVERLAY_DECISION_20260606.md`

Runs:

- `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_styleconsistency_audit`
- `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_dsbn_vendor_audit`
- `results/f04_roi_evidence_encoder/20260606_092210_v6_overlay_dsbn_vendorfieldfallback_audit`
- `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_famous_ssl_dinov2_audit`
- `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_bn_tta_recalib_reset_audit`
- `results/f04_roi_evidence_encoder/20260606_092242_v6_overlay_bn_tta_momentum010_full_audit`

Design:

- Start from the primary 3D validation-selected three-zone decision.
- Keep primary answer/far-boundary score.
- Let a candidate only add an uncertain prediction when primary and candidate score uncertainty thresholds are satisfied.
- Select thresholds on validation with far-negative/far-positive regression penalty.

Result:

- No overlay candidate significantly beats primary.
- BN reset is closest: zone-bacc `0.645` versus primary `0.643`, but the primary-comparison CI is `-0.013` to `+0.018`.
- DSBN overlays improve uncertain recall, but significantly regress far-negative and far-positive recall.
- DINOv2 adds no useful uncertain signal.

Decision:

- Conservative post-hoc score geometry does not solve the method-novelty problem.
- The remaining bottleneck is representation/uncertainty estimation itself, not simply validation thresholding or candidate-primary score fusion.

## Score-Only Meta Three-Zone Audit

Report:

- `reports/F04_SCORE_META_THREEZONE_DECISION_20260606.md`

Run:

- `results/f04_roi_evidence_encoder/20260606_093026_v6_score_meta_threezone_audit_v2`

Design:

- Train a shallow multinomial logistic regression on non-AJU validation rows.
- Use only image-model scores, score-confidence transforms, clipped logits, and question ID one-hot indicators.
- Use GroupKFold by subject for C selection.
- Evaluate AJU once.

Result:

| model | zone-bacc | uncertain recall | far-negative recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.739 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.676 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.535 | 0.635 | 0.946 |
| score-only meta | 0.665 | 0.660 | 0.739 | 0.596 | 0.938 |

Bootstrap versus primary:

- zone-bacc CI `-0.025` to `+0.067`;
- uncertain recall CI `+0.022` to `+0.209`;
- far-negative recall CI `+0.007` to `+0.122`;
- far-positive recall CI `-0.191` to `-0.049`;
- far AUC CI `-0.024` to `+0.001`.

Decision:

- Score-level information is not empty, but it still fails the method gate.
- The meta-classifier improves uncertain and far-negative recall while significantly sacrificing far-positive recall.
- This closes simple score-fusion/meta-classifier directions as publishable method novelty.
- A future method must preserve far-positive evidence explicitly, not merely learn a better post-hoc score boundary.

Follow-up case audit:

- `results/f04_roi_evidence_encoder/20260606_093621_v6_score_meta_farpos_regression_case_audit_v2`

Finding:

- far-positive regressions versus primary: `13`
- uncertain gains versus primary: `14`
- the far-positive regression is concentrated in the hippocampus-to-ventricle
  ratio question: `10/13` far-positive regressions
- all selected audit images loaded successfully and both montage figures were
  generated, so this is not explained by obvious missing-image/QC failure

Updated interpretation:

- The ratio question is the clearest current bottleneck. It needs a method that
  distinguishes true far-positive ratio evidence from near-cutoff uncertainty,
  not a generic uncertainty expansion.
- The next model-side experiment should be ratio-preserving by design: freeze
  or regularize the primary far-positive score on validation-defined confident
  ratio positives while allowing uncertainty recovery only near the cutoff.
- Success gate for the next experiment:
  - improve uncertain recall or zone-bacc versus primary;
  - preserve far-positive recall for the ratio question within a near-zero
    regression margin;
  - keep far AUC close to primary AJU `0.948`;
  - remain clearly above fixed 2.5D, but do not use 2.5D alone as the promotion
    criterion.

Validation-locked ratio-preserve score audit:

- run: `results/f04_roi_evidence_encoder/20260606_094309_v6_score_meta_ratio_preserve_audit`
- selected non-AJU validation threshold: primary score `>= 0.655610`
- AJU point metrics:
  - primary: zone-bacc `0.643`, uncertain `0.543`, far-positive `0.712`, far AUC `0.948`
  - score-meta: zone-bacc `0.665`, uncertain `0.660`, far-positive `0.596`, far AUC `0.938`
  - ratio-preserve score-meta: zone-bacc `0.672`, uncertain `0.574`, far-positive `0.702`, far AUC `0.939`
- bootstrap versus primary for ratio-preserve score-meta:
  - zone-bacc CI `-0.008` to `+0.065`
  - uncertain recall CI `-0.057` to `+0.117`
  - far-positive recall CI `-0.054` to `+0.032`

Decision:

- This is a useful diagnostic but not a publishable method.
- Ratio far-positive recall can be restored by a conservative gate, but the
  near-cutoff uncertain gain mostly disappears and statistical superiority over
  primary/original tri-view is not established.
- Stop adding score-only policies. The next experiment should be a model-side
  ratio-preserving boundary learner: keep the primary answer path frozen, train
  a boundary/uncertainty branch with explicit ratio far-positive negative
  constraints, and require question-level ratio far-positive preservation in
  validation selection.

Model-side ratio-preserving boundary learner:

- run: `results/f04_roi_evidence_encoder/20260606_094654_v6_primary_frozen_questionwise_boundary_head_margin005_posw2_fpneg2_ratiofp3_loco_AJU`
- bootstrap: `results/f04_roi_evidence_encoder/20260606_095000_v6_questionwise_boundary_ratiofp3_bootstrap_audit`
- design:
  - primary 3D answer path frozen;
  - one boundary uncertainty head per question;
  - global far-positive negative weight `2.0`;
  - extra ratio far-positive negative weight `3.0`;
  - model inputs remain global 3D tensor, MTL 3D tensor, and question ID only.

AJU point result:

- all-question max-zone-bacc: `0.661`, uncertain `0.681`, far-positive `0.625`, far AUC `0.948`
- ratio/vent max-zone-bacc: `0.714`, uncertain `0.667`, far-positive `0.643`
- hip/MTL max-zone-bacc: `0.614`

Bootstrap result:

- all-question versus primary:
  - zone-bacc CI `-0.042` to `+0.077`
  - far-positive recall CI `-0.188` to `+0.010`
- all-question versus original tri-view:
  - zone-bacc CI `-0.033` to `+0.062`
- ratio/vent versus original tri-view:
  - zone-bacc CI `+0.033` to `+0.185`
- ratio/vent versus primary:
  - zone-bacc CI `-0.011` to `+0.152`
  - far-positive recall CI `-0.333` to `-0.020`

Decision:

- This confirms the ratio/vent uncertainty subproblem is learnable, but also
  confirms the core failure: improving uncertain recall still sacrifices
  primary far-positive recall.
- Do not promote this as method novelty.
- The next credible model experiment should not add more boundary gates. It
  should change the representation objective so far-positive ratio evidence is
  preserved before the boundary decision layer, for example via a pairwise
  ranking/distillation loss on confident far-positive ratio rows plus a
  near-cutoff uncertainty objective. If that still fails, stop model iteration
  and frame the paper around the validated 3D ROI-aware three-zone task and
  3D-vs-2.5D evidence.

Representation-side ratio ranking plus uncertainty auxiliary:

- run: `results/f04_roi_evidence_encoder/20260606_095828_v6_multiview_preinit_ratio_rank_uncaux_unfreeze_loco_AJU`
- three-zone bootstrap: `results/f04_roi_evidence_encoder/20260606_100400_v6_ratio_rank_uncaux_unfreeze_threezone_bootstrap_audit`
- transition audit: `results/f04_roi_evidence_encoder/20260606_100523_v6_ratio_rank_uncaux_unfreeze_transition_audit`

Design:

- initialize from the same global 3D and MTL tau0.03 checkpoints used by the
  primary soft-label fusion path;
- freeze encoders initially, then unfreeze at epoch 3 with LR `5e-5`;
- add train-only near-cutoff uncertainty auxiliary weight `0.02`;
- add train-only ratio-specific pairwise ranking loss weight `0.05`, margin
  `0.40`, and boundary-distance anchor `>=0.05`;
- balance train sampling by `question_id` and `answer_label`;
- model inputs remain image tensors plus question ID only.

AJU binary result:

- pooled AUC/bacc: `0.866 / 0.765`, below primary `0.879 / 0.785`
- question AUCs:
  - hippocampal `0.794`
  - ratio `0.912`
  - MTL `0.833`
  - ventricle `0.938`

Three-zone result:

- candidate zone-bacc/far-AUC: `0.634 / 0.944`
- primary zone-bacc/far-AUC: `0.643 / 0.948`
- original tri-view zone-bacc/far-AUC: `0.645 / 0.946`
- fixed 2.5D zone-bacc/far-AUC: `0.436 / 0.756`

Bootstrap:

- versus fixed 2.5D:
  - zone-bacc CI `+0.139` to `+0.256`
  - far-AUC CI `+0.121` to `+0.264`
- versus primary:
  - zone-bacc CI `-0.065` to `+0.045`
  - far-positive recall CI `-0.276` to `-0.116`
- versus original tri-view:
  - zone-bacc CI `-0.059` to `+0.035`
  - far-positive recall CI `-0.195` to `-0.055`

Transition structure versus primary:

- uncertain net gain: `+22`
- far-negative net gain: `-10`
- far-positive net gain: `-20`

Case visual/QC audit:

- run: `results/f04_roi_evidence_encoder/20260606_100919_v6_ratio_rank_uncaux_unfreeze_farpos_case_visual_qc_audit`
- primary far-positive regressions: `20`
- candidate uncertain gains: `25`
- far-positive regression by question:
  - ratio `10`
  - hippocampal `5`
  - ventricle `3`
  - MTL `2`
- selected image/QC stats:
  - `24/24` selected cases load successfully;
  - crop mask coverage and z-scored brain/crop intensity statistics are within
    expected ranges;
  - no obvious missing-image, mask, or intensity-normalization failure explains
    the regression.

Decision:

- Negative representation control.
- It confirms that ratio/near-cutoff uncertainty can be pushed, but the same
  fundamental tradeoff remains: uncertain recovery is bought by far-boundary,
  especially far-positive, regression.
- Do not run more variants that only reweight boundary/ranking/gate losses.
- The next scientifically honest step is to stop broad model iteration and
  consolidate the paper around the stronger supported claim: 3D ROI-aware
  three-zone VQA and 3D-vs-2.5D evidence, with morphometry `0.91` as the
  external classifier bar. A future method-novelty attempt would need a new
  mechanism, not another uncertainty/ranking weight, and should be preregistered
  before touching AJU again.

Latest decision synthesis:

- `results/f04_roi_evidence_encoder/20260606_101632_v6_latest_decision_synthesis/F04_LATEST_DECISION_SYNTHESIS.md`

Latest manuscript-facing asset package:

- `results/f04_roi_evidence_encoder/20260607_073337_v6_latest_threezone_manuscript_assets/`
- generated by `scripts/run_f04_v6_latest_manuscript_assets.py`
- includes:
  - `core_threezone_results_table.csv/.md`
  - `method_gate_vs_primary_table.csv/.md`
  - `morphometry_bar_table.csv/.md`
  - `negative_control_ledger.csv/.md`
  - `figure_1_core_threezone_3d_vs_2p5d.png/.svg`
  - `figure_2_method_gate_vs_primary.png/.svg`
  - `figure_3_claim_and_negative_control_matrix.png/.svg`
- use this package as the current paper/slide entry point. It supports the
  three-zone task/evaluation and 3D-vs-2.5D claim, while explicitly documenting
  why current uncertainty/ranking/gate, residual, ROI-union, ROI-token, and
  external primary-frozen uncertainty-head variants should not be promoted as
  method novelty.

Latest stratified 2.5D-vs-3D evidence audit:

- `results/f04_roi_evidence_encoder/20260606_103747_v6_stratified_threezone_2p5d_vs_3d_evidence_audit/`
- generated by `scripts/run_f04_v6_stratified_threezone_evidence_audit.py`
- main finding:
  - 3D is positive versus fixed 2.5D at the main evaluation level: AJU primary
    delta zone accuracy `+0.168`, external primary `+0.140`, internal
    global+MTL fusion `+0.173`;
  - cohort/scanner strata are mostly positive for promoted 3D models, arguing
    against a simple cohort/scanner artifact;
  - weak strata remain concentrated in far-positive or close-to-cutoff
    hippocampal/hippocampus-to-ventricle ratio rows, where 3D can regress
    versus 2.5D.
- interpretation:
  - this strengthens the task/evaluation claim but narrows the model claim;
  - do not claim 3D is uniformly better for every anatomical state;
  - any future method novelty must preserve far-positive ratio/hippocampal
    correctness while improving near-cutoff uncertainty.

2.5D rescue feasibility audit:

- `results/f04_roi_evidence_encoder/20260606_104400_v6_2p5d_rescue_feasibility_audit/`
- generated by `scripts/run_f04_v6_2p5d_rescue_feasibility_audit.py`
- main finding:
  - oracle 2.5D/3D complementarity is substantial, e.g. AJU tri-view oracle
    zone-bacc `0.780` vs 3D `0.645`, and internal global+MTL oracle
    `0.792` vs 3D `0.687`;
  - simple confidence-gated 2.5D override is weak even under test sweep:
    best all-question gains are only about `+0.000` to `+0.009` zone-bacc;
  - every all-question decision row is
    `complementarity_signal_but_naive_gate_insufficient`.
- interpretation:
  - fixed 2.5D contains some complementary far-boundary signal, but it is not
    separable by a naive score-confidence gate;
  - do not promote 2.5D rescue as method novelty;
  - only a genuinely new validation-locked learned complementarity mechanism
    would justify another experiment in this branch.

Validation-locked learned 2.5D/3D complementarity audit:

- `results/f04_roi_evidence_encoder/20260606_105105_v6_validation_locked_2p5d_3d_complementarity_audit/`
- generated by
  `scripts/run_f04_v6_validation_locked_2p5d_3d_complementarity_audit.py`
- design:
  - trains a multinomial logistic three-zone combiner on validation rows only;
  - C is selected by subject-grouped validation folds;
  - held-out test rows are evaluated once;
  - predictors are fixed 2.5D score, 3D score, score-confidence transforms,
    score differences, and question ID only;
  - clinical variables, scanner/acquisition metadata, raw cohort identity, ROI
    values, evidence percentiles, CDR, and AEB features remain forbidden as
    model predictors.
- main finding:
  - learned complementarity does not pass the method gate in any tested case;
  - AJU primary point zone-bacc improves from `0.643` to `0.659`, but
    far-positive recall drops by `-0.135` and bootstrap zone-bacc CI is
    `-0.033` to `+0.062`;
  - AJU tri-view point zone-bacc improves from `0.645` to `0.653`, but
    far-positive recall drops by `-0.125` and bootstrap zone-bacc CI is
    `-0.049` to `+0.065`;
  - internal fusion gains only `+0.002` zone-bacc and loses uncertain recall by
    `-0.088`;
  - OASIS/NACC point results are mixed and all zone-bacc CIs cross zero.
- interpretation:
  - the oracle 2.5D/3D complementarity signal is real but is not cleanly
    separable by shallow score-level learning;
  - this closes the current 2.5D score-rescue branch;
  - any future method-novelty attempt should change the image representation or
    anatomical boundary evidence itself, not add another score-level gate.

AJU representation-family scan:

- `results/f04_roi_evidence_encoder/20260606_110735_v6_aju_representation_family_scan/`
- generated by `scripts/run_f04_v6_aju_representation_family_scan.py`
- design:
  - re-evaluates 63 completed AJU LOCO image candidates plus fixed 2.5D,
    primary 3D, and original tri-view controls;
  - uses one binary and three-zone protocol;
  - uses score-confidence policies for binary-score runs and native three-zone
    policies for direct three-zone/boundary-head runs;
  - clinical, scanner, ROI, and evidence fields are target/audit-only.
- controls:
  - fixed 2.5D zone-bacc `0.436`;
  - primary 3D zone-bacc `0.643`;
  - original tri-view zone-bacc `0.662`.
- best point run:
  - `20260604_190346_v6_triview_preinit_frozen_global_mtl64_mtl80_tau003_auxdist_w002_loco_AJU_screening`;
  - zone-bacc `0.680`;
  - uncertain recall `0.734`;
  - far-positive recall `0.596`.
- family scan decision:
  - no completed image candidate passes the point gate versus both primary and
    original tri-view while preserving far-positive recall;
  - no run was skipped after schema normalization;
  - therefore there is no overlooked existing AJU LOCO representation candidate
    to promote.

Family-scan top candidate bootstrap:

- `results/f04_roi_evidence_encoder/20260606_110621_v6_family_scan_top_auxdist_bootstrap/`
- generated by `scripts/run_f04_v6_candidate_threezone_bootstrap_audit.py`
- main finding:
  - versus fixed 2.5D: zone-bacc CI `+0.186` to `+0.301`, far-AUC CI
    `+0.127` to `+0.261`;
  - versus original tri-view: zone-bacc CI `+0.002` to `+0.071`, but
    far-positive recall CI `-0.084` to `+0.000`;
  - versus primary: zone-bacc CI `-0.013` to `+0.087`, and far-positive recall
    CI `-0.202` to `-0.031`.
- interpretation:
  - the top point candidate still recovers uncertain rows by sacrificing
    primary far-positive correctness;
  - this confirms the completed representation-family search is not enough for
    method novelty;
  - next work should be paper consolidation or a preregistered genuinely new
    representation mechanism.

AJU row-level representation solvability audit:

- `results/f04_roi_evidence_encoder/20260606_111310_v6_aju_representation_solvability_audit/`
- generated by `scripts/run_f04_v6_aju_representation_solvability_audit.py`
- main finding:
  - only `11/340` AJU rows are missed by every completed image candidate;
  - `56/340` rows have at least one candidate correct while fixed 2.5D,
    primary 3D, and original tri-view are all wrong;
  - any-candidate oracle accuracy by true zone is high: far-negative `0.986`,
    uncertain `0.989`, far-positive `0.923`;
  - however candidate majority/consensus accuracy is much lower, showing that
    signal is fragmented across representation variants;
  - the weakest shared stratum is hippocampus-to-ventricle ratio far-positive:
    n `23`, any-candidate oracle `0.739`, candidate-majority accuracy `0.217`.
- interpretation:
  - image signal is not completely absent;
  - the current problem is not solved by more of the same representation
    variants because the correct signal is not stable across runs;
  - ratio far-positive preservation remains the key failure mode.

Family-score selector audit:

- `results/f04_roi_evidence_encoder/20260606_111935_v6_family_score_selector_audit/`
- generated by `scripts/run_f04_v6_family_score_selector_audit.py`
- leakage correction:
  - first attempted selector used a full fixed-2.5D validation base and would
    have included AJU validation rows;
  - that run was removed;
  - final selector uses non-AJU validation rows only: ADNI `1190`, A4 `412`,
    NACC `318`, OASIS `202`, AIBL `194`, KDRC `138`;
  - AJU test remains `340` rows.
- main finding:
  - selector point zone-bacc `0.689`, uncertain recall `0.713`, far-positive
    recall `0.587`;
  - versus fixed 2.5D: zone-bacc CI `+0.190` to `+0.312`, far-AUC CI
    `+0.120` to `+0.264`;
  - versus original tri-view: zone-bacc CI `-0.017` to `+0.072`, far-positive
    recall CI `-0.153` to `+0.010`;
  - versus primary: zone-bacc CI `-0.008` to `+0.102`, far-positive recall CI
    `-0.211` to `-0.040`.
- interpretation:
  - fragmented family signal is partly selectable from image-model scores, but
    not in a promotable way;
  - primary far-positive recall is still significantly sacrificed;
  - this closes broad score-selector rescue as well as pairwise 2.5D/3D rescue.

Current stop rules:

- Do not promote image model disease-classification superiority unless it
  approaches or exceeds the morphometry `0.91` bar.
- Do not run more boundary/ranking/gate reweight variants without a genuinely
  new preregistered mechanism.
- Do not run additional 2.5D/3D score-combiner rescue variants unless the new
  mechanism is preregistered and changes representation learning, not merely
  score calibration or thresholding.
- Do not rerun existing AJU LOCO representation-family variants as if they were
  new evidence; the family scan found no promotable missed candidate.
- Do not promote broad score-stack selectors; the leakage-corrected family
  selector still significantly loses primary far-positive recall.
- Keep fixed 2.5D as the explicit lower-bound baseline, but use primary 3D and
  original tri-view as method gates.

## Latest Failure Mechanism: Ratio Normative Residual

New audits:

- `results/f04_roi_evidence_encoder/20260606_112442_v6_ratio_farpositive_failure_mechanism_audit/`
- `results/f04_roi_evidence_encoder/20260606_112752_v6_ratio_normative_raw_discordance_audit/`

Finding:

- The weakest shared AJU stratum is `normqa_low_hippocampus_to_ventricle_ratio`
  far-positive: n `23`.
- `6/23` rows are missed by every completed image candidate.
- Fixed 2.5D rescues `0/6` of those all-candidates-wrong rows.
- All-candidates-wrong rows have adjusted percentile median `0.018`, but raw
  global hippocampus-to-ventricle ratio percentile median `0.706`.
- In ratio far-positive rows, candidate solvability is weakly related to the
  adjusted percentile itself, but strongly related to raw visible geometry:
  Spearman `0.173` for adjusted percentile versus `-0.906` for raw global ratio
  percentile and `-0.894` for raw-adjusted discordance.

Interpretation:

- This is not simply "2.5D cannot see enough" or "3D needs one more gate."
- The model is image-only, so it can directly see raw anatomy. The QA label,
  however, is based on adjusted normative percentile evidence. In some AJU
  ratio-positive cases, the adjusted residual is severe while the raw global
  ratio is not visually low.
- Therefore the remaining hard cases may require learning the normative
  residual component from image context, age/sex/ICV-like visual correlates, or
  acquisition/population structure. But clinical/scanner/ROI/evidence variables
  must remain target/audit-only unless an acquisition-conditioned experiment is
  explicitly preregistered.

Next credible experiment:

- Build a residual-decomposition audit/model target for ratio questions:
  separate raw visible ratio severity from adjusted normative residual severity.
- First test feasibility with frozen 3D embeddings only:
  1. predict raw global ratio percentile bin from image features;
  2. predict adjusted percentile bin from the same image features;
  3. predict residual discordance bin `raw_percentile - adjusted_percentile`;
  4. evaluate by held-out AJU and non-AJU validation, with fixed 2.5D as a
     lower-bound comparator.
- Only if the residual target is learnable should we design a new model-side
  method, such as residual-aware 3D ROI-VQA with two heads:
  visible anatomy head plus normative residual head.

Execution update:

- run: `results/f04_roi_evidence_encoder/20260606_113419_v6_ratio_residual_learnability_audit/`
- script: `scripts/run_f04_v6_ratio_residual_learnability_audit.py`
- train/selection: non-AJU validation rows only, n `574`, subjects `372`
- test: AJU only, n `80`, subjects `68`
- leakage audit: subject overlap `0`, QA overlap `0`
- predictors: existing image-only model scores/probabilities only; no clinical,
  scanner, cohort, ROI, evidence, CDR, or AEB predictors.

Result:

| target | best feature set | AJU AUC | AJU bacc |
|---|---|---:|---:|
| raw global ratio low10 | all 3D family scores | 0.977 | 0.813 |
| adjusted percentile low10 | primary + original 3D scores | 0.924 | 0.825 |
| adjusted-low but raw-not-low10 discordance | all 3D family scores | 0.895 | 0.811 |
| raw-adjusted residual gap >=0.25 | all image scores plus 2.5D | 0.936 | 0.850 |

Interpretation update:

- The residual/discordance target is learnable from image-model outputs under
  non-AJU to AJU holdout.
- This does not yet prove a publishable method because the best probe uses a
  large family of prior image-model scores.
- It does justify a new model-side experiment: a single residual-aware 3D
  ROI-VQA architecture that explicitly decomposes visible anatomy and normative
  residual evidence during training, while still taking only image tensors plus
  question ID at inference.

Decision gate:

- If adjusted residual is not learnable from image-only features, then the
  ratio far-positive failure should be framed as a limitation of image-only
  ROI-grounded VQA labels derived from normative clinical morphometry, not as a
  failure of the 3D architecture.
- If it is learnable, that becomes a stronger technical novelty candidate than
  another boundary/ranking/gate reweighting experiment.
- The current feasibility audit supports the second branch. Next model training
  should therefore be residual-aware, not another generic boundary/ranking/gate
  variant.

## Residual-Aware Model Attempt

Implementation:

- script extended: `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- added train-only ratio residual auxiliary targets derived from:
  - adjusted hippocampus-to-ventricle percentile;
  - raw global hippocampus-to-ventricle ratio percentile from the official
    manifest;
  - target kind `adjusted_low_raw_not_low10`.
- added a residual head and zero-initialized residual-to-answer adapter.
- model inputs remain global 3D tensor, MTL 3D tensor, and question ID only.
  Raw ROI geometry and adjusted percentiles are target-only and never predictors.

Runs:

- `results/f04_roi_evidence_encoder/20260606_114439_v6_multiview_preinit_frozen_global_mtlsoft_tau003_ratioresid_adjrawnotlow10_w010_adapter_loco_AJU/`
- `results/f04_roi_evidence_encoder/20260606_114816_v6_ratio_residual_adapter_w010_threezone_bootstrap_audit/`
- `results/f04_roi_evidence_encoder/20260606_114933_v6_ratio_residual_adapter_w010_transition_audit/`
- `results/f04_roi_evidence_encoder/20260606_115045_v6_multiview_preinit_frozen_global_mtlsoft_tau003_ratioresid_adjrawnotlow10_w003_adapter_loco_AJU/`
- `results/f04_roi_evidence_encoder/20260606_115338_v6_ratio_residual_adapter_w003_threezone_bootstrap_audit/`
- `results/f04_roi_evidence_encoder/20260606_115450_v6_ratio_residual_adapter_w003_transition_audit/`

Result:

| model | pooled AUC | pooled bacc | zone bacc | uncertain recall | far-positive recall | primary far-positive delta CI |
|---|---:|---:|---:|---:|---:|---:|
| primary 3D | 0.879 | 0.785 | 0.643 | 0.543 | 0.712 | reference |
| residual adapter w0.10 | 0.882 | 0.771 | 0.678 | 0.670 | 0.567 | -0.213 to -0.082 |
| residual adapter w0.03 | 0.878 | 0.791 | 0.644 | 0.670 | 0.615 | -0.154 to -0.046 |

Transition diagnosis:

- w0.10 versus primary:
  - uncertain net gain `+12`;
  - far-negative net gain `+17`;
  - far-positive net `-15`;
  - primary regressions concentrate in ratio far-positive: `9` rows.
- w0.03 versus primary:
  - uncertain net gain `+12`;
  - far-negative net `-4`;
  - far-positive net `-10`;
  - primary regressions still concentrate in ratio far-positive: `7` rows.

Decision:

- Residual information is real, but the unconstrained residual-to-answer adapter
  is not promotable.
- The failure is the same pattern seen in earlier candidates: near-cutoff
  uncertain recovery is bought by losing primary far-positive correctness.
- Do not continue by simply sweeping residual weights. A next residual-aware
  model would need an explicit preservation constraint, such as primary-teacher
  preservation for far-positive rows or a monotonic calibration design that can
  use residual evidence without lowering established far-positive decisions.

Preservation follow-up:

- primary-preserving overlay:
  `results/f04_roi_evidence_encoder/20260606_115931_v6_ratio_residual_adapter_w003_primary_preserving_overlay_audit/`
- monotonic residual overlay:
  `results/f04_roi_evidence_encoder/20260606_120327_v6_ratio_residual_adapter_w010_monotonic_overlay_audit/`
- script:
  `scripts/run_f04_v6_ratio_residual_monotonic_overlay_audit.py`

Result:

| audit | zone bacc | uncertain recall | far-positive recall | primary zone-bacc delta CI |
|---|---:|---:|---:|---:|
| primary 3D reference | 0.638 | 0.553 | 0.692 | reference |
| primary-preserving overlay w0.03 | 0.638 | 0.553 | 0.692 | -0.018 to +0.007 |
| monotonic residual overlay w0.10 | 0.638 | 0.543 | 0.702 | -0.011 to +0.009 |

Updated decision:

- Primary-preserving overlays prevent the large far-positive damage seen in the
  unconstrained residual adapters.
- They do not create a significant gain over primary 3D.
- The residual branch is therefore useful as a failure-mechanism diagnostic,
  but not yet a method contribution.
- The next publishable path should not be another post-hoc residual decision
  surface. It should either:
  1. consolidate the current evidence as a three-zone 3D ROI-VQA task/evaluation
     paper with transparent negative controls; or
  2. introduce a genuinely new representation mechanism that changes the image
     features themselves while preserving primary far-positive decisions.

## ROI-Union / Mask-Derived Crop Closure

Follow-up audit:

- strongest ROI-union model:
  `results/f04_roi_evidence_encoder/20260604_172913_v6_multiview_preinit_frozen_global_roiunion_fixedcenter_tau003_loco_AJU_screening/`
- bootstrap audit:
  `results/f04_roi_evidence_encoder/20260606_121008_v6_roiunion_fixedcenter_fusion_threezone_bootstrap_audit/`
- transition audit:
  `results/f04_roi_evidence_encoder/20260606_121049_v6_roiunion_fixedcenter_fusion_transition_audit/`

Result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| ROI-union fixed-center fusion | 0.581 | 0.617 | 0.625 | 0.908 |

Bootstrap interpretation:

- ROI-union versus fixed 2.5D remains positive:
  - all-question zone-bacc CI `+0.079` to `+0.217`;
  - all-question far-AUC CI `+0.091` to `+0.222`.
- ROI-union versus primary is negative/mixed:
  - all-question zone-bacc CI `-0.128` to `+0.001`;
  - all-question far-AUC CI `-0.075` to `-0.008`.
- Hip/MTL is clearly worse than primary:
  - zone-bacc CI `-0.230` to `-0.032`;
  - far-AUC CI `-0.126` to `-0.004`.
- Ratio/vent shows higher uncertain recall but loses primary far-positive
  recall:
  - far-positive recall CI `-0.389` to `-0.109`.

Transition structure versus primary:

- overall net gain `-27`;
- uncertain net `+7`;
- far-negative net `-25`;
- far-positive net `-9`;
- question-level net gains only appear in ventricle `+4`; hippocampal `-12`,
  ratio `-2`, and MTL `-17` are negative.

Decision:

- Mask-derived ROI-union/fixed-center localization is closed as a main novelty
  direction.
- The result supports the broad 3D-over-2.5D task claim, but not a new model
  claim over primary 3D.
- Likely mechanism: subject-specific ROI crops remove absolute scale and
  population-context cues needed for cutoff-sensitive normative anatomy. Fixed
  MTL context remains better than mask-derived subject-specific ROI cropping.
- Do not spend more experiments on tighter ROI masks, ROI-union cache variants,
  or subject-specific bbox resampling unless a new hypothesis explicitly
  preserves absolute scale and primary far-boundary ranking.

## ROI-Token Residual Three-Zone Closure

Follow-up audits:

- candidate run:
  `results/f04_roi_evidence_encoder/20260604_201152_v6_triview_roi_token_residual_adapter_preinit_frozen_loco_AJU_screening/`
- bootstrap audit:
  `results/f04_roi_evidence_encoder/20260606_121507_v6_roi_token_residual_adapter_threezone_bootstrap_audit/`
- transition audit:
  `results/f04_roi_evidence_encoder/20260606_121550_v6_roi_token_residual_adapter_transition_audit/`
- primary-preserving overlay:
  `results/f04_roi_evidence_encoder/20260606_121640_v6_roi_token_residual_adapter_primary_preserving_overlay_audit/`

Result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| ROI-token residual | 0.635 | 0.830 | 0.548 | 0.942 |
| primary-preserving ROI-token overlay | 0.644 | 0.585 | 0.692 | 0.948 |

Bootstrap interpretation:

- ROI-token residual versus fixed 2.5D remains strongly positive:
  - all-question zone-bacc CI `+0.137` to `+0.262`;
  - all-question far-AUC CI `+0.122` to `+0.259`.
- ROI-token residual versus primary is not promotable:
  - all-question zone-bacc CI `-0.061` to `+0.047`;
  - far-positive recall CI `-0.258` to `-0.064`.
- The ratio/vent stratum is the clearest failure:
  - far-positive recall CI versus primary `-0.512` to `-0.200`.
- The primary-preserving overlay prevents the large far-positive collapse but
  gives no significant gain over primary:
  - zone-bacc CI `-0.017` to `+0.019`;
  - transition net versus primary `-1`.

Transition structure versus primary for the unconstrained ROI-token residual:

- overall net gain `-11`;
- uncertain net `+27`;
- far-negative net `-21`;
- far-positive net `-17`;
- question-level net: hippocampal `0`, ratio `-10`, MTL `-2`,
  ventricle `+1`.

Decision:

- Fixed coarse ROI-token pooling is closed as a near-term method novelty.
- It is useful diagnostically because it proves uncertainty-sensitive image
  evidence exists, but it recovers uncertainty by sacrificing far-boundary
  polarity.
- Another fixed-bin or score-overlay variant is low value unless it changes the
  representation learning objective and explicitly preserves primary
  far-positive/far-negative behavior.

## Morphometry-Distillation Auxiliary Experiment

Code extension:

- `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- new options:
  - `--morphometry-aux-weight`
  - `--morphometry-aux-columns`

Design:

- Frozen global+MTL tau0.03 primary-style model.
- AJU held out by LOCO.
- Model inputs remain global 3D tensor, fixed MTL 3D tensor, and question ID.
- ROI percentile fields are used only as train-only auxiliary targets:
  hippocampal volume, MTL volume, ventricle-to-brain, and hippocampus-to-
  ventricle percentiles.
- Clinical, scanner, ROI, evidence percentile, CDR, and AEB fields remain
  forbidden as model inputs.

Runs:

- w0.05 run:
  `results/f04_roi_evidence_encoder/20260606_130604_v6_multiview_preinit_frozen_global_mtlsoft_tau003_morphaux005_loco_AJU/`
- w0.05 bootstrap:
  `results/f04_roi_evidence_encoder/20260606_130927_v6_morphometry_aux_w005_threezone_bootstrap_audit/`
- w0.05 transition:
  `results/f04_roi_evidence_encoder/20260606_131026_v6_morphometry_aux_w005_transition_audit/`
- w0.01 run:
  `results/f04_roi_evidence_encoder/20260606_131109_v6_multiview_preinit_frozen_global_mtlsoft_tau003_morphaux001_loco_AJU/`
- w0.01 bootstrap:
  `results/f04_roi_evidence_encoder/20260606_131415_v6_morphometry_aux_w001_threezone_bootstrap_audit/`
- w0.01 transition:
  `results/f04_roi_evidence_encoder/20260606_131515_v6_morphometry_aux_w001_transition_audit/`
- w0.01 + boundary-rank run:
  `results/f04_roi_evidence_encoder/20260606_131558_v6_multiview_preinit_frozen_global_mtlsoft_tau003_morphaux001_boundaryrank002_loco_AJU/`
- w0.01 + boundary-rank bootstrap:
  `results/f04_roi_evidence_encoder/20260606_131915_v6_morphometry_aux_w001_boundaryrank002_threezone_bootstrap_audit/`
- w0.01 + boundary-rank transition:
  `results/f04_roi_evidence_encoder/20260606_132031_v6_morphometry_aux_w001_boundaryrank002_transition_audit/`
- w0.01 + far-positive BCE weight 1.1 run:
  `results/f04_roi_evidence_encoder/20260606_133412_v6_multiview_preinit_frozen_global_mtlsoft_tau003_morphaux001_farposw11_loco_AJU/`
- w0.01 + far-positive BCE weight 1.1 bootstrap:
  `results/f04_roi_evidence_encoder/20260606_133708_v6_morphometry_aux_w001_farposw11_threezone_bootstrap_audit/`
- w0.01 + far-positive BCE weight 1.1 transition:
  `results/f04_roi_evidence_encoder/20260606_133805_v6_morphometry_aux_w001_farposw11_transition_audit/`
- w0.01 + far-positive BCE weight 1.5 run:
  `results/f04_roi_evidence_encoder/20260606_132924_v6_multiview_preinit_frozen_global_mtlsoft_tau003_morphaux001_farposw15_loco_AJU/`
- w0.01 + far-positive BCE weight 1.5 bootstrap:
  `results/f04_roi_evidence_encoder/20260606_133231_v6_morphometry_aux_w001_farposw15_threezone_bootstrap_audit/`
- w0.01 + far-positive BCE weight 1.5 transition:
  `results/f04_roi_evidence_encoder/20260606_133334_v6_morphometry_aux_w001_farposw15_transition_audit/`
- w0.01 + primary teacher far-positive preservation run:
  `results/f04_roi_evidence_encoder/20260606_134930_v6_primaryinit_morphaux001_teacherfp_w010_loco_AJU/`
- w0.01 + primary teacher far-positive preservation bootstrap:
  `results/f04_roi_evidence_encoder/20260606_135326_v6_morphometry_aux_w001_teacherfp_w010_threezone_bootstrap_audit/`
- w0.01 + primary teacher far-positive preservation transition:
  `results/f04_roi_evidence_encoder/20260606_135409_v6_morphometry_aux_w001_teacherfp_w010_transition_audit/`
- frozen-primary morphometry probe run:
  `results/f04_roi_evidence_encoder/20260606_135621_v6_primary_frozen_morphometry_probe_loco_AJU/`
- frozen-primary morphometry probe bootstrap:
  `results/f04_roi_evidence_encoder/20260606_135950_v6_primary_frozen_morphometry_probe_threezone_bootstrap_audit/`
- frozen-primary morphometry probe transition:
  `results/f04_roi_evidence_encoder/20260606_140033_v6_primary_frozen_morphometry_probe_transition_audit/`

Auxiliary target learnability on AJU test:

| target | w0.01 Spearman | w0.01 MAE |
|---|---:|---:|
| hippocampal volume percentile | 0.655 | 0.172 |
| MTL volume percentile | 0.763 | 0.146 |
| ventricle-to-brain percentile | 0.877 | 0.111 |
| hippocampus-to-ventricle percentile | 0.618 | 0.144 |

Three-zone result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| original tri-view | 0.645 | 0.766 | 0.635 | 0.946 |
| morphometry aux w0.05 | 0.621 | 0.702 | 0.606 | 0.945 |
| morphometry aux w0.01 | 0.676 | 0.532 | 0.673 | 0.946 |
| morphometry aux w0.01 + boundary rank | 0.637 | 0.723 | 0.548 | 0.945 |
| morphometry aux w0.01 + FP weight 1.1 | 0.620 | 0.766 | 0.587 | 0.945 |
| morphometry aux w0.01 + FP weight 1.5 | 0.620 | 0.755 | 0.596 | 0.943 |
| morphometry aux w0.01 + teacher FP preserve | 0.601 | 0.702 | 0.587 | 0.947 |
| frozen-primary morphometry probe | 0.626 | 0.574 | 0.692 | 0.948 |

Bootstrap interpretation:

- w0.05 versus primary:
  - zone-bacc CI `-0.064` to `+0.019`;
  - far-positive recall CI `-0.173` to `-0.049`.
- w0.01 versus primary:
  - zone-bacc CI `-0.006` to `+0.071`;
  - far-positive recall CI `-0.077` to `-0.009`;
  - hip/MTL-only zone-bacc CI `+0.015` to `+0.112`.
- w0.01 + boundary ranking versus primary:
  - zone-bacc CI `-0.055` to `+0.043`;
  - uncertain recall CI `+0.091` to `+0.271`;
  - far-positive recall CI `-0.247` to `-0.089`.
- w0.01 + far-positive BCE weight 1.1 versus primary:
  - zone-bacc CI `-0.068` to `+0.023`;
  - uncertain recall CI `+0.132` to `+0.313`;
  - far-positive recall CI `-0.198` to `-0.061`.
- w0.01 + far-positive BCE weight 1.5 versus primary:
  - zone-bacc CI `-0.071` to `+0.021`;
  - far-positive recall CI `-0.185` to `-0.057`;
  - far-AUC CI `-0.012` to `-0.000`.
- w0.01 + primary teacher far-positive preservation versus primary:
  - zone-bacc CI `-0.086` to `-0.002`;
  - uncertain recall CI `+0.085` to `+0.232`;
  - far-positive recall CI `-0.195` to `-0.066`.
- frozen-primary morphometry probe versus primary:
  - zone-bacc CI `-0.038` to `+0.006`;
  - uncertain recall CI `-0.011` to `+0.080`;
  - far-positive recall CI `-0.047` to `0.000`;
  - far-AUC CI `-0.002` to `+0.002`.

Transition diagnosis versus primary:

| model | gain/regression/net | far-negative net | uncertain net | far-positive net |
|---|---:|---:|---:|---:|
| morphometry aux w0.05 | 16/29/-13 | -17 | +15 | -11 |
| morphometry aux w0.01 | 28/12/+16 | +21 | -1 | -4 |
| morphometry aux w0.01 + boundary rank | 22/27/-5 | -5 | +17 | -17 |
| morphometry aux w0.01 + FP weight 1.1 | 21/37/-16 | -24 | +20 | -12 |
| morphometry aux w0.01 + FP weight 1.5 | 21/37/-16 | -24 | +20 | -12 |
| morphometry aux w0.01 + teacher FP preserve | 15/36/-21 | -23 | +15 | -13 |
| frozen-primary morphometry probe | 4/12/-8 | -9 | +3 | -2 |

Decision:

- Morphometry-distillation is the first representation-level direction that
  shows a plausible positive mechanism: the auxiliary head learns held-out AJU
  ROI percentiles, and the low-weight run improves far-negative and hip/MTL
  zone-bacc structure.
- It is not yet promotable because the all-question primary comparison still
  fails the far-positive preservation gate.
- The boundary-ranking follow-up is negative; it increases uncertain recall
  but worsens far-positive recall.
- The far-positive BCE weighting follow-up is also negative. Both mild and
  stronger weighting move the validation-locked decision toward uncertain
  predictions and worsen far-positive recall.
- Primary-teacher far-positive preservation is negative. It improves neither
  the method gate nor held-out far-positive preservation, so simple train-row
  teacher imitation is also closed for this branch.
- The frozen-primary morphometry probe is positive as a diagnostic, not as a
  new answer method. With only `morphometry_aux_head` trainable, the held-out
  AJU ROI percentile Spearman is hippocampal `0.655`, MTL `0.771`,
  ventricle `0.881`, and ratio `0.629`, while far-AUC is unchanged versus
  primary. This shows that the primary 3D representation contains anatomy
  signal; the failure mechanism is answer-boundary perturbation during joint
  auxiliary training.
- The next morphometry-distillation experiment should therefore decouple
  representation probing from answer decision updates. Any method that updates
  the answer path must have a stronger structural non-inferiority constraint
  than scalar BCE reweighting, boundary ranking, or far-positive teacher MSE.

Updated gate for any next image model:

- It must beat fixed 2.5D by the existing large margin, but that is no longer
  enough.
- It must be non-inferior to primary 3D on:
  - all-question zone-bacc;
  - far-positive recall;
  - far-negative recall;
  - far-AUC.
- Uncertain recall improvements are only useful if both far-boundary recalls
  are preserved within bootstrap uncertainty.

## Decoupled Predicted-Morphometry Rule VQA Experiment

Rationale:

- The frozen-primary morphometry probe shows that primary 3D features contain
  ROI percentile signal.
- Joint morphometry auxiliary training perturbs the answer decision boundary.
- We therefore tested a decoupled path: predict ROI percentiles from the frozen
  image representation, then answer VQA questions by applying the question's
  positive rule to the predicted percentile.

Code:

- `scripts/run_f04_v6_predicted_morphometry_rule_vqa_audit.py`
- `scripts/run_f04_v6_candidate_asymmetric_interval_audit.py`

Input policy:

- Probe model inputs: global 3D T1w tensor, fixed bilateral MTL 3D tensor, and
  question ID.
- Rule VQA inputs: image-derived predicted ROI percentile and question positive
  rule.
- True ROI values, true ROI percentiles, evidence percentiles, clinical fields,
  scanner/cohort metadata, CDR, age/sex, and AEB features are not model inputs.

Runs:

- predicted-morphometry rule candidate:
  `results/f04_roi_evidence_encoder/20260606_140855_v6_predicted_morphometry_rule_vqa_loco_AJU/`
- symmetric validation-locked three-zone bootstrap:
  `results/f04_roi_evidence_encoder/20260606_140944_v6_predicted_morphometry_rule_vqa_threezone_bootstrap_audit/`
- transition audit:
  `results/f04_roi_evidence_encoder/20260606_141028_v6_predicted_morphometry_rule_vqa_transition_audit/`
- asymmetric interval bootstrap:
  `results/f04_roi_evidence_encoder/20260606_141359_v6_predicted_morphometry_rule_vqa_asymmetric_interval_bootstrap_audit/`

Binary AJU result:

| model | pooled AUC | bacc | hippocampal AUC | ratio AUC | MTL AUC | ventricle AUC |
|---|---:|---:|---:|---:|---:|---:|
| predicted morphometry rule | 0.863 | 0.709 | 0.794 | 0.910 | 0.844 | 0.947 |
| primary 3D reference | 0.879 | 0.785 | 0.808 | 0.924 | 0.858 | 0.940 |
| fixed 2.5D reference | 0.684 | 0.597 | 0.562 | 0.833 | 0.588 | 0.769 |

Symmetric three-zone result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| predicted morphometry rule | 0.628 | 0.553 | 0.452 | 0.933 |

Symmetric bootstrap interpretation:

- versus fixed 2.5D:
  - zone-bacc CI `+0.125` to `+0.258`;
  - far-AUC CI `+0.116` to `+0.248`.
- versus primary:
  - zone-bacc CI `-0.088` to `+0.051`;
  - far-positive recall CI `-0.358` to `-0.165`;
  - far-AUC CI `-0.029` to `-0.003`.

Asymmetric interval result:

| policy | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| score only | 0.540 | 0.000 | 0.683 | 0.933 |
| asymmetric max-zone | 0.664 | 0.713 | 0.548 | 0.933 |
| asymmetric 90% FP guard | 0.648 | 0.596 | 0.615 | 0.933 |
| asymmetric 95% FP guard | 0.632 | 0.511 | 0.654 | 0.933 |

Asymmetric bootstrap versus primary:

- max-zone:
  - zone-bacc CI `-0.035` to `+0.075`;
  - far-positive recall CI `-0.253` to `-0.084`;
  - far-AUC CI `-0.028` to `-0.003`.
- 90% far-positive guard:
  - zone-bacc CI `-0.044` to `+0.054`;
  - far-positive recall CI `-0.167` to `-0.042`;
  - far-AUC CI `-0.028` to `-0.003`.

Decision:

- The decoupled predicted-morphometry rule score is a useful diagnostic and
  beats fixed 2.5D clearly.
- It is not promotable as an answer method because primary far-positive recall
  and far-AUC are significantly worse.
- Asymmetric intervals improve the point operating point but do not solve the
  underlying positive-margin problem.
- The next credible method must improve predicted ROI percentile calibration
  and positive-margin fidelity, especially ratio/ventricle far-positive rows,
  before converting predicted morphometry into VQA answers.

## Predicted-Morphometry Calibration Follow-Up

Question:

- Is the predicted-morphometry rule failure mostly a calibration problem?
- We tested validation-only calibration from image-predicted ROI percentiles to
  true ROI percentiles, then reapplied the same rule-based VQA conversion on
  held-out AJU.

Runs:

- affine-calibrated rule candidate:
  `results/f04_roi_evidence_encoder/20260606_142151_v6_predicted_morphometry_rule_vqa_affinecal_loco_AJU/`
- affine-calibrated bootstrap:
  `results/f04_roi_evidence_encoder/20260606_142236_v6_predicted_morphometry_rule_vqa_affinecal_threezone_bootstrap_audit/`
- affine-calibrated transition:
  `results/f04_roi_evidence_encoder/20260606_142319_v6_predicted_morphometry_rule_vqa_affinecal_transition_audit/`
- affine-calibrated asymmetric interval:
  `results/f04_roi_evidence_encoder/20260606_142320_v6_predicted_morphometry_rule_vqa_affinecal_asymmetric_interval_bootstrap_audit/`
- isotonic-calibrated rule candidate:
  `results/f04_roi_evidence_encoder/20260606_142151_v6_predicted_morphometry_rule_vqa_isotoniccal_loco_AJU/`
- isotonic-calibrated bootstrap:
  `results/f04_roi_evidence_encoder/20260606_142236_v6_predicted_morphometry_rule_vqa_isotoniccal_threezone_bootstrap_audit/`

Binary AJU result:

| model | pooled AUC | bacc |
|---|---:|---:|
| raw predicted morphometry rule | 0.863 | 0.709 |
| affine-calibrated rule | 0.870 | 0.721 |
| isotonic-calibrated rule | 0.864 | 0.706 |
| primary 3D reference | 0.879 | 0.785 |
| fixed 2.5D reference | 0.684 | 0.597 |

Standard three-zone result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| affine-calibrated rule | 0.599 | 0.287 | 0.567 | 0.936 |
| isotonic-calibrated rule | 0.605 | 0.436 | 0.442 | 0.935 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |

Bootstrap interpretation:

- affine versus fixed 2.5D:
  - zone-bacc CI `+0.094` to `+0.234`;
  - far-AUC CI `+0.120` to `+0.249`.
- affine versus primary:
  - zone-bacc CI `-0.125` to `+0.032`;
  - far-positive recall CI `-0.229` to `-0.074`;
  - far-AUC CI `-0.026` to `-0.002`.
- affine asymmetric max-zone versus primary:
  - zone-bacc CI `-0.035` to `+0.072`;
  - far-positive recall CI `-0.204` to `-0.060`;
  - far-AUC CI `-0.025` to `-0.001`.
- isotonic versus primary:
  - zone-bacc CI `-0.124` to `+0.041`;
  - far-positive recall CI `-0.358` to `-0.183`;
  - far-AUC CI `-0.026` to `-0.002`.

Decision:

- Calibration helps but is not enough.
- Affine calibration improves binary AUC/bacc and reduces raw-rule
  far-positive loss, but still fails the primary non-inferiority gate.
- Isotonic calibration appears to overfit non-AJU validation and transfers
  worse to AJU.
- Asymmetric interval selection after affine calibration improves point
  zone-bacc but still significantly loses primary far-positive recall and
  far-AUC.
- The next useful experiment should target ROI percentile prediction itself,
  not only post-hoc calibration. A plausible direction is question/ROI-specific
  margin-aware ROI percentile regression that explicitly penalizes errors
  around the 0.10 and 0.90 decision cutoffs while keeping the answer path
  frozen for evaluation.

## Positive-Margin Weighted ROI Regression Follow-Up

Question:

- Can we improve image-predicted ROI percentile fidelity in VQA-positive margin
  regions while keeping the primary answer path frozen?
- This directly tests whether the predicted-morphometry rule failure is caused
  by weak rank preservation near the low hippocampal/MTL/ratio and high
  ventricle abnormality margins.

Code:

- `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- new options:
  - `--morphometry-positive-margin-weight`
  - `--morphometry-positive-margin`
- `scripts/run_f04_v6_predicted_morphometry_rule_vqa_audit.py`
- `scripts/run_f04_v6_candidate_asymmetric_interval_audit.py`

Input policy:

- Model inputs remain image tensors plus question ID only.
- The weighted ROI percentile targets are train targets for the auxiliary
  morphometry head, not inference inputs.
- True ROI, evidence fields, clinical variables, scanner/cohort fields, CDR,
  age/sex, and AEB features are not answer-model inputs.

Runs:

- positive-margin frozen-primary morphometry probe:
  `results/f04_roi_evidence_encoder/20260606_143358_v6_primary_frozen_morphometry_posmargin_w4_m010_loco_AJU/`
- positive-margin predicted-morphometry rule candidate:
  `results/f04_roi_evidence_encoder/20260606_143731_v6_posmargin_predicted_morphometry_rule_vqa_loco_AJU/`
- symmetric validation-locked three-zone bootstrap:
  `results/f04_roi_evidence_encoder/20260606_143811_v6_posmargin_predicted_morphometry_rule_vqa_threezone_bootstrap_audit/`
- transition audit:
  `results/f04_roi_evidence_encoder/20260606_143855_v6_posmargin_predicted_morphometry_rule_vqa_transition_audit/`
- affine-calibrated positive-margin rule candidate:
  `results/f04_roi_evidence_encoder/20260606_143731_v6_posmargin_predicted_morphometry_rule_vqa_affinecal_loco_AJU/`
- affine-calibrated bootstrap:
  `results/f04_roi_evidence_encoder/20260606_143811_v6_posmargin_predicted_morphometry_rule_vqa_affinecal_threezone_bootstrap_audit/`
- asymmetric interval bootstrap:
  `results/f04_roi_evidence_encoder/20260606_143856_v6_posmargin_predicted_morphometry_rule_vqa_asymmetric_interval_bootstrap_audit/`

Binary AJU result:

| model | pooled AUC | bacc |
|---|---:|---:|
| raw predicted morphometry rule | 0.863 | 0.709 |
| affine-calibrated rule | 0.870 | 0.721 |
| positive-margin rule | 0.859 | 0.774 |
| positive-margin affine rule | 0.865 | 0.718 |
| primary 3D reference | 0.879 | 0.785 |
| fixed 2.5D reference | 0.684 | 0.597 |

Positive-margin probe result:

| ROI target | Spearman | MAE |
|---|---:|---:|
| hippocampal percentile | 0.651 | 0.130 |
| MTL percentile | 0.767 | 0.131 |
| ventricle percentile | 0.882 | 0.109 |
| hippocampus-to-ventricle ratio percentile | 0.625 | 0.127 |

Standard three-zone result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| positive-margin predicted morphometry rule | 0.631 | 0.734 | 0.433 | 0.931 |

Bootstrap interpretation:

- positive-margin rule versus fixed 2.5D:
  - zone-bacc CI `+0.130` to `+0.257`;
  - far-AUC CI `+0.114` to `+0.245`.
- positive-margin rule versus primary:
  - zone-bacc CI `-0.071` to `+0.043`;
  - uncertain recall CI `+0.061` to `+0.326`;
  - far-positive recall CI `-0.379` to `-0.178`;
  - far-AUC CI `-0.032` to `-0.005`.
- positive-margin affine rule versus primary:
  - zone-bacc CI `-0.158` to `+0.003`;
  - far-positive recall CI `-0.343` to `-0.147`;
  - far-AUC CI `-0.034` to `-0.007`.

Asymmetric interval interpretation:

- score-only policy increases far-positive recall over primary, but uncertain
  recall is `0.000` and zone-bacc is significantly lower than primary.
- asymmetric max-zone recovers uncertain recall but still significantly loses
  primary far-positive recall and far-AUC:
  - zone-bacc CI `-0.038` to `+0.061`;
  - uncertain recall CI `+0.104` to `+0.303`;
  - far-positive recall CI `-0.244` to `-0.078`;
  - far-AUC CI `-0.031` to `-0.004`.
- 95% far-positive guard approximately preserves far-positive recall, but
  far-AUC remains significantly worse:
  - zone-bacc CI `-0.064` to `+0.030`;
  - far-positive recall CI `-0.035` to `+0.098`;
  - far-AUC CI `-0.032` to `-0.005`.

Decision:

- Positive-margin weighting changes the operating point but does not solve the
  core rank-preserving ROI margin problem.
- It clearly beats fixed 2.5D, which supports the image-signal claim.
- It is not promotable over the current primary 3D reference because the
  simultaneous uncertain/far-positive tradeoff is worse and far-AUC remains
  significantly below primary.
- Do not continue with more threshold-only variants of this family unless the
  ROI percentile ranking itself improves first.

## Positive-Focus Pairwise ROI Rank Follow-Up

Question:

- Can direct pairwise rank supervision on the image-predicted ROI percentiles
  recover the missing positive-margin ranking that MSE and positive-margin MSE
  did not solve?
- This tests the current bottleneck most directly while keeping the primary
  answer path frozen.

Code:

- `scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py`
- new options:
  - `--morphometry-rank-loss-weight`
  - `--morphometry-rank-min-delta`
  - `--morphometry-rank-margin`
  - `--morphometry-rank-focus`
  - `--morphometry-rank-positive-margin`
- `scripts/run_f04_v6_predicted_morphometry_rule_vqa_audit.py`
- `scripts/run_f04_v6_candidate_threezone_bootstrap_audit.py`
- `scripts/run_f04_v6_candidate_threezone_transition_audit.py`
- `scripts/run_f04_v6_candidate_asymmetric_interval_audit.py`

Input policy:

- Model inputs remain global 3D T1w tensor, fixed bilateral MTL 3D tensor, and
  question ID.
- ROI percentiles are target-only auxiliary labels.
- Clinical fields, scanner/cohort metadata, evidence values, true ROI
  percentiles, CDR/CDR-SB, age/sex, and AEB features are not model inputs.

Implementation note:

- The first bounded smoke with `--limit-examples 512` failed because the bounded
  prefix contained no AJU test rows after `--test-consortium AJU` filtering.
- That failed smoke output was removed and replaced by the full-manifest
  one-epoch smoke:
  `results/f04_roi_evidence_encoder/20260606_145053_v6_primary_frozen_morphrank_posfocus_smoke1ep/`
- This is a data-slicing smoke-test issue, not a model failure; future bounded
  smoke tests should sample stratified rows or avoid consortium filtering.

Runs:

- positive-focus rank frozen-primary morphometry probe:
  `results/f04_roi_evidence_encoder/20260606_145217_v6_primary_frozen_morphrank_posfocus_w005_loco_AJU/`
- rule VQA conversion:
  `results/f04_roi_evidence_encoder/20260606_145609_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_loco_AJU/`
- symmetric validation-locked three-zone bootstrap:
  `results/f04_roi_evidence_encoder/20260606_145701_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_threezone_bootstrap_audit/`
- transition audit:
  `results/f04_roi_evidence_encoder/20260606_145821_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_transition_audit/`
- asymmetric interval bootstrap:
  `results/f04_roi_evidence_encoder/20260606_145835_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_asymmetric_interval_bootstrap_audit/`
- affine-calibrated rule:
  `results/f04_roi_evidence_encoder/20260606_150121_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_affinecal_loco_AJU/`
- affine-calibrated bootstrap:
  `results/f04_roi_evidence_encoder/20260606_150126_v6_morphrank_posfocus_predicted_morphometry_rule_vqa_affinecal_threezone_bootstrap_audit/`

Probe result:

| ROI target | Spearman | MAE |
|---|---:|---:|
| hippocampal percentile | 0.658 | 0.138 |
| MTL percentile | 0.772 | 0.129 |
| ventricle percentile | 0.882 | 0.113 |
| hippocampus-to-ventricle ratio percentile | 0.629 | 0.142 |

Binary AJU result:

| model | pooled AUC | bacc |
|---|---:|---:|
| positive-focus rank rule | 0.858 | 0.729 |
| positive-focus rank affine rule | 0.866 | 0.724 |
| primary 3D reference | 0.879 | 0.785 |
| fixed 2.5D reference | 0.684 | 0.597 |

Standard three-zone result:

| model | zone bacc | uncertain recall | far-positive recall | far AUC |
|---|---:|---:|---:|---:|
| fixed 2.5D | 0.436 | 0.000 | 0.567 | 0.756 |
| primary 3D | 0.643 | 0.543 | 0.712 | 0.948 |
| positive-focus rank rule | 0.667 | 0.617 | 0.519 | 0.931 |
| positive-focus rank affine rule | 0.608 | 0.319 | 0.567 | 0.932 |

Bootstrap interpretation:

- positive-focus rank rule versus fixed 2.5D:
  - zone-bacc CI `+0.171` to `+0.293`;
  - far-AUC CI `+0.115` to `+0.246`.
- positive-focus rank rule versus primary:
  - zone-bacc CI `-0.041` to `+0.084`;
  - uncertain recall CI `-0.080` to `+0.220`;
  - far-positive recall CI `-0.269` to `-0.116`;
  - far-AUC CI `-0.032` to `-0.006`.
- positive-focus rank affine rule versus primary:
  - zone-bacc CI `-0.115` to `+0.040`;
  - far-positive recall CI `-0.229` to `-0.074`;
  - far-AUC CI `-0.030` to `-0.005`.

Transition interpretation versus primary:

| true zone | candidate gain | candidate regression | net |
|---|---:|---:|---:|
| far-negative | 27 | 0 | +27 |
| uncertain | 21 | 14 | +7 |
| far-positive | 0 | 20 | -20 |
| overall | 48 | 34 | +14 |

Asymmetric interval interpretation:

- max-zone policy:
  - zone-bacc `0.662`;
  - uncertain recall `0.777`;
  - far-positive recall `0.519`;
  - versus primary far-positive CI `-0.278` to `-0.117`;
  - versus primary far-AUC CI `-0.031` to `-0.005`.
- 90% far-positive guard:
  - zone-bacc `0.651`;
  - uncertain recall `0.628`;
  - far-positive recall `0.635`;
  - versus primary far-positive CI `-0.148` to `-0.020`;
  - versus primary far-AUC CI `-0.031` to `-0.005`.
- 95% far-positive guard:
  - zone-bacc `0.632`;
  - uncertain recall `0.553`;
  - far-positive recall `0.654`;
  - versus primary far-positive CI `-0.130` to `0.000`;
  - versus primary far-AUC CI `-0.031` to `-0.005`.

Decision:

- Pairwise rank supervision is more targeted than MSE weighting, but it still
  does not solve the primary comparison.
- The method strongly beats fixed 2.5D, reinforcing that 3D image signal is
  present.
- It is not promotable as a new method because the apparent point zone-bacc
  improvement comes from far-negative and uncertain rows while primary
  far-positive recall and far-AUC remain significantly worse.
- Validation-only affine calibration improves binary AUC but worsens the
  three-zone behavior.
- The next credible direction should not be another score threshold or
  head-only ROI-rank variant. It should address why adjusted normative
  positive-margin labels are weakly represented in image-only anatomy, possibly
  by explicitly modeling normative residuals with allowed covariates outside
  the image-only VQA claim, or by narrowing the VQA claim to image-visible ROI
  evidence rather than adjusted residual evidence.

## Raw-Visible ROI Label Audit

Question:

- Do existing image-only model scores align better with raw image-visible ROI
  anatomy than with the current adjusted/normative QA evidence labels?
- This separates representation failure from target-visibility failure.

Code:

- `scripts/run_f04_v6_raw_visible_roi_label_audit.py`

Input policy:

- No model training.
- Existing image-only 2.5D, primary 3D, and tri-view 3D scores are reused.
- Raw ROI values from the official manifest are used only to construct audit
  labels.
- Clinical fields, scanner/cohort fields, CDR/CDR-SB, age/sex, and AEB
  features are not model inputs.

Raw-visible label definition:

| question | raw-visible proxy |
|---|---|
| hippocampal volume | bilateral hippocampal volume global percentile |
| MTL atrophy | hippocampus + amygdala + entorhinal + parahippocampal bilateral sum global percentile |
| ventricle enlargement | lateral + inferior lateral ventricle volume divided by `fs_BrainSegVol`, global percentile |
| hippocampus-to-ventricle ratio | bilateral hippocampal volume divided by lateral + inferior lateral ventricle volume, global percentile |

Run:

- `results/f04_roi_evidence_encoder/20260606_151211_v6_raw_visible_roi_label_audit_AJU/`

Implementation issue:

- The first audit attempt failed because the bootstrap merge accidentally
  dropped the model score column.
- Failed partial output
  `results/f04_roi_evidence_encoder/20260606_151127_v6_raw_visible_roi_label_audit_AJU/`
  was removed.
- The script was fixed and rerun successfully.
- During bootstrap, sklearn emitted warnings when a subject-level bootstrap
  resample lacked one true class. This mostly affects very small raw-visible
  ratio/vent far strata; binary AUC and all-question far-AUC are the more
  reliable readouts for this audit.

Label discordance:

| question | adjusted positive rate | raw-visible positive rate | binary discordance | adjusted positive / raw negative |
|---|---:|---:|---:|---:|
| hippocampal volume | 0.500 | 0.115 | 0.385 | 37 |
| hippocampus-to-ventricle ratio | 0.500 | 0.075 | 0.425 | 34 |
| MTL atrophy | 0.500 | 0.190 | 0.310 | 31 |
| ventricle enlargement | 0.500 | 0.188 | 0.313 | 20 |

Key point:

- Raw-visible positives are a strict subset of adjusted positives in AJU.
- There were no raw-positive / adjusted-negative rows.
- Therefore the current QA benchmark is balanced for adjusted/normative labels,
  not for raw-visible anatomy labels.

All-question AJU metrics:

| model | label | binary AUC | zone bacc | far-positive recall | far AUC |
|---|---|---:|---:|---:|---:|
| fixed 2.5D | adjusted | 0.684 | 0.437 | 0.548 | 0.756 |
| fixed 2.5D | raw-visible | 0.794 | 0.520 | 0.700 | 0.817 |
| primary 3D | adjusted | 0.879 | 0.643 | 0.712 | 0.948 |
| primary 3D | raw-visible | 0.961 | 0.438 | 0.700 | 0.980 |
| tri-view 3D | adjusted | 0.877 | 0.662 | 0.654 | 0.944 |
| tri-view 3D | raw-visible | 0.968 | 0.446 | 0.700 | 0.982 |

Raw-visible 3D versus 2.5D bootstrap:

- primary 3D versus fixed 2.5D:
  - binary AUC delta `+0.166`, CI `+0.093` to `+0.257`;
  - far-AUC delta `+0.163`, CI `+0.073` to `+0.283`;
  - zone-bacc delta `-0.082`, CI `-0.212` to `+0.072`.
- tri-view 3D versus fixed 2.5D:
  - binary AUC delta `+0.174`, CI `+0.093` to `+0.266`;
  - far-AUC delta `+0.165`, CI `+0.060` to `+0.300`;
  - zone-bacc delta `-0.074`, CI `-0.209` to `+0.088`.

Decision:

- This is a positive diagnostic for image signal and label visibility.
- Image scores align substantially better with raw-visible anatomy labels than
  with adjusted/normative labels.
- 3D still clearly beats fixed 2.5D for raw-visible binary/far ranking.
- The raw-visible zone-bacc drop is not evidence against 3D; it is a benchmark
  construction issue because the current AJU rows are not balanced for
  raw-visible positives and near-boundary zones.
- The next valid experiment is to construct a newly matched raw-visible
  ROI-VQA benchmark with balanced positives/negatives and explicit near-cutoff
  rows, then rerun 2.5D versus 3D under that benchmark.

## Raw-Visible Balanced Subset Audit

Question:

- Does the raw-visible 3D-over-2.5D ranking survive class balancing within the
  available AJU rows?
- Can we separate ranking quality from operating-threshold calibration?

Code:

- `scripts/run_f04_v6_raw_visible_balanced_subset_audit.py`

Run:

- `results/f04_roi_evidence_encoder/20260607_061409_v6_raw_visible_balanced_subset_audit_AJU/`

Input policy:

- No model training.
- Existing image-only 2.5D, primary 3D, and tri-view 3D scores are reused.
- Raw-visible labels are audit-only.
- Clinical/scanner/CDR/age/sex/AEB are not model inputs.

Implementation issues:

- The script creation was interrupted once before the file was created.
- The first execution failed because the same `qa_id` can belong to both
  random-negative and hard-negative subsets; merge validation was corrected
  from `many_to_one` to `many_to_many`.
- One intermediate successful run had blank test-threshold upper-bound metrics
  because the best-threshold initialization used `NaN`; this was fixed and the
  final run above supersedes it.

Subset construction:

- `random_negative`: all raw-visible positives plus equal-count random
  raw-visible negatives per question.
- `hard_negative`: all raw-visible positives plus equal-count raw-visible
  negatives closest to the cutoff per question.
- Each subset has `96` QA rows:
  - hippocampal: `11` positive + `11` negative;
  - ratio: `6` positive + `6` negative;
  - MTL: `19` positive + `19` negative;
  - ventricle: `12` positive + `12` negative.

Metrics:

| subset | model | AUC | bacc@0.5 | positive recall@0.5 | negative recall@0.5 |
|---|---|---:|---:|---:|---:|
| random negative | fixed 2.5D | 0.781 | 0.740 | 0.792 | 0.688 |
| random negative | primary 3D | 0.966 | 0.823 | 1.000 | 0.646 |
| random negative | tri-view 3D | 0.973 | 0.812 | 1.000 | 0.625 |
| hard negative | fixed 2.5D | 0.674 | 0.677 | 0.792 | 0.562 |
| hard negative | primary 3D | 0.872 | 0.542 | 1.000 | 0.083 |
| hard negative | tri-view 3D | 0.864 | 0.552 | 1.000 | 0.104 |

Bootstrap versus fixed 2.5D:

- random-negative subset:
  - primary 3D AUC delta `+0.185`, CI `+0.084` to `+0.318`;
  - tri-view 3D AUC delta `+0.192`, CI `+0.092` to `+0.321`.
- hard-negative subset:
  - primary 3D AUC delta `+0.197`, CI `+0.084` to `+0.323`;
  - tri-view 3D AUC delta `+0.189`, CI `+0.073` to `+0.334`.
- hard-negative bacc@0.5 is worse for 3D:
  - primary delta `-0.135`, CI `-0.249` to `-0.000`;
  - tri-view delta `-0.125`, CI `-0.237` to `-0.006`.

Threshold diagnostic:

| subset | model | upper-bound threshold | upper-bound bacc | positive recall | negative recall |
|---|---|---:|---:|---:|---:|
| hard negative | fixed 2.5D | 0.505 | 0.677 | 0.771 | 0.583 |
| hard negative | primary 3D | 0.922 | 0.792 | 0.833 | 0.750 |
| hard negative | tri-view 3D | 0.982 | 0.812 | 0.750 | 0.875 |
| random negative | fixed 2.5D | 0.498 | 0.740 | 0.792 | 0.688 |
| random negative | primary 3D | 0.861 | 0.906 | 0.938 | 0.875 |
| random negative | tri-view 3D | 0.902 | 0.938 | 0.958 | 0.917 |

Decision:

- This is a positive small-subset diagnostic, not a final benchmark.
- 3D raw-visible ranking survives balanced subset construction and remains
  significantly above fixed 2.5D by AUC.
- The hard-negative bacc@0.5 failure shows that raw-visible labels need
  validation-locked threshold calibration; the adjusted-QA score scale is too
  high for raw-visible hard negatives.
- The next experiment should construct a larger train/val/test raw-visible
  VQA benchmark, then calibrate thresholds on non-AJU validation before testing
  AJU or external cohorts.

## Raw-Visible Validation-Locked Binary Calibration Audit

Question:

- Is the hard-negative 3D failure at threshold 0.5 a true representation
  failure, or an operating-point mismatch caused by reusing adjusted-QA score
  thresholds for raw-visible labels?
- Can thresholds selected on validation data excluding AJU transfer to AJU
  balanced raw-visible subsets?

Code:

- `scripts/run_f04_v6_raw_visible_val_locked_binary_calibration_audit.py`

Run:

- `results/f04_roi_evidence_encoder/20260607_062549_v6_raw_visible_val_locked_binary_calibration_audit_AJU/`

Input policy:

- No model training.
- Existing image-only 2.5D, primary 3D, and tri-view 3D scores are reused.
- Thresholds are selected only on validation rows excluding AJU.
- Raw-visible labels are audit-only.
- Clinical/scanner/CDR/age/sex/AEB are not model inputs.

Implementation issue:

- The first execution failed because the baseline prediction column was renamed
  into an existing prediction-column name, creating a duplicate-column
  dataframe for sklearn metrics.
- The failed partial output
  `20260607_062458_v6_raw_visible_val_locked_binary_calibration_audit_AJU/`
  was removed, the script was fixed, and the successful run above supersedes
  it.

Validation-selected global thresholds:

| model | threshold | validation bacc |
|---|---:|---:|
| fixed 2.5D | 0.592 | 0.726 |
| primary 3D | 0.862 | 0.875 |
| tri-view 3D | 0.936 | 0.858 |

AJU calibrated metrics:

| subset | calibration | model | AUC | bacc | positive recall | negative recall |
|---|---|---|---:|---:|---:|---:|
| hard negative | global | fixed 2.5D | 0.674 | 0.562 | 0.438 | 0.688 |
| hard negative | global | primary 3D | 0.872 | 0.740 | 0.917 | 0.562 |
| hard negative | global | tri-view 3D | 0.864 | 0.760 | 0.917 | 0.604 |
| random negative | global | fixed 2.5D | 0.781 | 0.635 | 0.438 | 0.833 |
| random negative | global | primary 3D | 0.966 | 0.896 | 0.917 | 0.875 |
| random negative | global | tri-view 3D | 0.973 | 0.917 | 0.917 | 0.917 |

Bootstrap versus fixed 2.5D:

- hard-negative global calibration:
  - primary bacc delta `+0.177`, CI `+0.046` to `+0.324`;
  - tri-view bacc delta `+0.198`, CI `+0.056` to `+0.358`.
- random-negative global calibration:
  - primary bacc delta `+0.260`, CI `+0.134` to `+0.396`;
  - tri-view bacc delta `+0.281`, CI `+0.153` to `+0.429`.
- hard-negative questionwise calibration is weaker:
  - primary bacc delta `+0.104`, CI `-0.022` to `+0.245`;
  - tri-view bacc delta `+0.115`, CI `-0.004` to `+0.247`.

Decision:

- Positive calibration diagnostic.
- The hard-negative 3D failure at threshold 0.5 is largely an operating-point
  mismatch, not absence of raw-visible image signal.
- Global validation-locked raw-visible calibration should be the primary
  operating policy in the next benchmark.
- Questionwise calibration is not ready as a claim because the available
  question-level raw-visible positives are too small, especially ratio rows.

## Raw-Visible ROI-VQA Benchmark and AJU Evaluation

Question:

- If we construct a raw-visible ROI-VQA benchmark directly, with balanced
  raw-visible labels and clinical-stratum-matched negative selection where
  possible, does 3D still beat fixed 2.5D under validation-locked calibration?
- Does this reveal a benchmark/data limitation before training a new
  raw-visible model?

Code:

- `scripts/run_f04_v6_raw_visible_benchmark_and_aju_eval.py`

Run:

- `results/f04_roi_evidence_encoder/20260607_063856_v6_raw_visible_benchmark_and_aju_eval/`

Input policy:

- No model training.
- Existing image-only 2.5D, primary 3D, and tri-view 3D scores are reused.
- Raw ROI values define raw-visible labels only.
- Clinical variables are used only for negative-selection matching/audit, not
  as model inputs.
- Thresholds are selected on validation rows excluding AJU.

Benchmark construction:

- For every split/cohort/question group:
  - keep all raw-visible positives;
  - select the same number of raw-visible negatives;
  - first select negatives within the existing `match_stratum`;
  - if exact stratum negatives are insufficient, fill from the same
    split/cohort/question using a mixed hard/random policy.
- Generated rows:
  - total benchmark rows: `6150`;
  - AJU test rows: `96`;
  - AJU test positives: `48`;
  - AJU test negatives: `48`.
- Split leakage:
  - subject overlap train/val/test: `0`;
  - join-key/session overlap train/val/test: `0`.

AJU test metrics:

| model | AUC | calibrated bacc | positive recall | negative recall | bacc@0.5 |
|---|---:|---:|---:|---:|---:|
| fixed 2.5D | 0.693 | 0.646 | 0.625 | 0.667 | 0.688 |
| primary 3D | 0.936 | 0.844 | 0.917 | 0.771 | 0.729 |
| tri-view 3D | 0.931 | 0.823 | 0.771 | 0.875 | 0.729 |

Bootstrap versus fixed 2.5D:

- primary 3D:
  - AUC delta `+0.243`, CI `+0.136` to `+0.373`;
  - calibrated bacc delta `+0.198`, CI `+0.074` to `+0.334`.
- tri-view 3D:
  - AUC delta `+0.239`, CI `+0.126` to `+0.368`;
  - calibrated bacc delta `+0.177`, CI `+0.052` to `+0.325`.

Question-level issue:

- Primary 3D is strong on every AJU question, including ratio bacc `0.917`.
- Tri-view has a ratio-specific calibrated failure:
  - ratio bacc `0.500`;
  - positive recall `0.167`;
  - negative recall `0.833`.
- This ratio result is unstable because AJU ratio has only `6` positive and
  `6` negative rows.

Matching caveat:

- AJU test groups are exactly matched under the current selection.
- Some non-AJU validation groups need fallback negatives; the maximum fallback
  fraction is `0.526` for AIBL validation ratio.
- This should be treated as a shortcut-risk audit signal for future training,
  not as a reason to reject the AJU 3D-vs-2.5D result.

Decision:

- Positive benchmark diagnostic.
- The new raw-visible benchmark confirms that 3D raw image scores carry more
  usable raw-visible ROI signal than fixed 2.5D under validation-locked
  calibration.
- This still does not prove a trained raw-visible VQA method. It proves that
  training such a model is now justified.
- Next experiment should train primary 3D and fixed 2.5D models directly on
  `raw_visible_benchmark_rows.csv`, then evaluate AJU and external LOCO
  cohorts with the same global validation-locked calibration policy.

## Raw-Visible Trained 2.5D Versus 3D AJU

Question:

- After training directly on the raw-visible benchmark, does 3D still beat a
  raw-visible-trained 2.5D baseline?
- Does the 2.5D failure persist when it is no longer evaluated only with
  adjusted-QA-trained scores?

Training manifest:

- `results/f04_roi_evidence_encoder/20260607_064600_v6_raw_visible_training_manifest/`
- Manifest:
  `raw_visible_training_manifest_for_image_models.csv`

Training runs:

- 2.5D:
  `results/f04_roi_evidence_encoder/20260607_064640_v6_2p5d_raw_visible_training_baseline/`
- 3D:
  `results/f04_roi_evidence_encoder/20260607_064746_v6_3d_raw_visible_preinit_frozen_tau003_loco_AJU/`

Comparison audit:

- `scripts/run_f04_v6_raw_visible_trained_model_comparison.py`
- `results/f04_roi_evidence_encoder/20260607_065034_v6_raw_visible_trained_model_comparison_AJU/`

Input policy:

- Both models are trained from image tensors plus question ID only.
- Raw ROI values are labels only.
- Clinical/scanner/CDR/age/sex are not model inputs.
- 3D excludes AJU from train/val and evaluates AJU as held-out test.
- Thresholds are selected on validation rows excluding AJU.

Validation:

| model | best validation result |
|---|---:|
| raw-visible 2.5D | macro AUC 0.725 |
| raw-visible 3D LOCO-AJU | macro AUC 0.932 |

AJU test metrics:

| model | AUC | calibrated bacc | positive recall | negative recall | bacc@0.5 |
|---|---:|---:|---:|---:|---:|
| raw-visible 2.5D | 0.593 | 0.531 | 0.333 | 0.729 | 0.490 |
| raw-visible 3D LOCO-AJU | 0.934 | 0.812 | 0.729 | 0.896 | 0.792 |

Bootstrap 3D versus 2.5D:

- AUC delta `+0.340`, CI `+0.207` to `+0.496`.
- Calibrated bacc delta `+0.281`, CI `+0.178` to `+0.391`.
- Positive recall delta `+0.396`, CI `+0.227` to `+0.574`.
- Negative recall delta `+0.167`, CI `+0.019` to `+0.321`.

Question-level 3D AUC:

- hippocampal: `0.901`;
- ratio: `0.944`;
- MTL: `0.920`;
- ventricle: `0.972`.

Diagnosis:

- This is the strongest result so far for the raw-visible track.
- 2.5D does not merely suffer from using adjusted-QA-trained scores; even when
  trained on raw-visible labels, it transfers poorly to AJU.
- 3D handles both positive and negative AJU raw-visible cases better under
  validation-locked calibration.
- Remaining limitation is sample size: AJU test has only `96` rows, and ratio
  has only `6` positive and `6` negative rows.

Decision:

- Positive trained-model result.
- The next gate is external LOCO replication, not another AJU-only reweighting
  variant.
- If OASIS/NACC external raw-visible LOCO also holds, the paper direction
  should become 3D ROI-aware raw-visible VQA with explicit separation from
  adjusted normative residual reasoning.

## External Raw-Visible Trained LOCO Replication

Question:

- Does the raw-visible-trained 3D advantage over raw-visible-trained 2.5D
  replicate beyond AJU?
- Are the external gains symmetric across positive and negative recall, or are
  they mostly operating-point/ranking gains?

OASIS runs:

- 2.5D:
  `results/f04_roi_evidence_encoder/20260607_065748_v6_2p5d_raw_visible_loco_OASIS/`
- 3D:
  `results/f04_roi_evidence_encoder/20260607_072446_v6_3d_raw_visible_preinit_frozen_tau003_loco_OASIS/`
- comparison:
  `results/f04_roi_evidence_encoder/20260607_072624_v6_raw_visible_trained_model_comparison_OASIS/`

OASIS metrics:

| model | n | AUC | calibrated bacc | positive recall | negative recall |
|---|---:|---:|---:|---:|---:|
| raw-visible 2.5D | 60 | 0.700 | 0.650 | 0.933 | 0.367 |
| raw-visible 3D | 60 | 0.957 | 0.833 | 0.800 | 0.867 |

OASIS 3D versus 2.5D bootstrap:

- AUC delta `+0.257`, CI `+0.100` to `+0.414`.
- Calibrated bacc delta `+0.183`, CI `+0.037` to `+0.321`.
- Positive recall delta `-0.133`, CI `-0.321` to `+0.053`.
- Negative recall delta `+0.500`, CI `+0.250` to `+0.714`.

OASIS diagnosis:

- Positive external replication for AUC and calibrated bacc.
- 3D primarily fixes 2.5D's negative-recall collapse.
- Do not claim symmetric recall superiority because 2.5D has higher point
  positive recall.
- Test set is small: `60` rows.

NACC runs:

- 2.5D:
  `results/f04_roi_evidence_encoder/20260607_072739_v6_2p5d_raw_visible_loco_NACC/`
- 3D:
  `results/f04_roi_evidence_encoder/20260607_072843_v6_3d_raw_visible_preinit_frozen_tau003_loco_NACC/`
- comparison:
  `results/f04_roi_evidence_encoder/20260607_073012_v6_raw_visible_trained_model_comparison_NACC/`

NACC metrics:

| model | n | AUC | calibrated bacc | positive recall | negative recall |
|---|---:|---:|---:|---:|---:|
| raw-visible 2.5D | 96 | 0.714 | 0.667 | 0.625 | 0.708 |
| raw-visible 3D | 96 | 0.898 | 0.812 | 0.875 | 0.750 |

NACC 3D versus 2.5D bootstrap:

- AUC delta `+0.184`, CI `+0.082` to `+0.285`.
- Calibrated bacc delta `+0.146`, CI `+0.041` to `+0.249`.
- Positive recall delta `+0.250`, CI `+0.086` to `+0.417`.
- Negative recall delta `+0.042`, CI `-0.128` to `+0.209`.

NACC diagnosis:

- Positive external replication for AUC and calibrated bacc.
- 3D improves positive recall robustly.
- Negative-recall delta is not significant; do not claim standalone negative
  recall superiority.
- Test set remains modest: `96` rows.

Implementation note:

- The OASIS/NACC comparison runs were generated before the comparison script
  was cleaned up to write generic filenames, so their metric files are named
  `aju_test_*` even though the evaluations are OASIS/NACC.
- The script now writes generic `test_*` files as well as the legacy alias for
  future runs.

Decision:

- External LOCO gate is positive for the main claim: 3D raw-visible ROI-VQA
  beats 2.5D by AUC and validation-locked calibrated bacc across AJU, OASIS,
  and NACC.
- Remaining scientific risk is not signal absence. It is small external test
  size, recall asymmetry, and benchmark construction/matching choices.
- Next work should consolidate the result into a preregistered evaluation table
  and then test stability across seeds or train policies, not return to
  adjusted-residual reweighting.
