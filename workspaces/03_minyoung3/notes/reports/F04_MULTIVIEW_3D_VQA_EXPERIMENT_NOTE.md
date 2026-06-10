# F04 Multi-View 3D ROI-Grounded VQA Experiment Note

Updated: 2026-06-03

## Question

Can global 3D context and fixed MTL-local 3D context be combined to improve image-only ROI-grounded anatomical VQA from T1w MRI?

## Benchmark

All experiments use the shortcut-resistant `cohort_dx_cdr_age_sex` matched session QA benchmark:

- QA rows: 19,236
- test rows: 2,538
- test positive rate: 0.5 for each question
- subject split overlap: 0
- session `join_key` split overlap: 0

Model inputs remain image tensors plus question ID only. Clinical fields, cohort, diagnosis/CDR/CDR-SB, age/sex, ROI values, ROI percentiles, evidence percentiles, and AEB features are not model inputs.

## Result Summary

| model | pooled AUC | pooled balanced accuracy | interpretation |
|---|---:|---:|---|
| 2.5D image-only | 0.732 | 0.663 | slab baseline; insufficient for fine MTL signal |
| global 3D | 0.835 | 0.743 | better spatial context |
| fixed MTL-crop 3D | 0.881 | 0.776 | strong local hippocampal/MTL signal |
| naive end-to-end global+MTL multi-view | 0.850 | 0.638 | optimization/fusion failure |
| pretrained frozen global+MTL multi-view | 0.912 | 0.824 | current best result |

## Current Best Run

- `results/f04_roi_evidence_encoder/20260603_062606_v6_multiview_preinit_frozen_global_mtl_3d_image_only_vqa_full64`
- global branch initialized from `20260603_053530_v6_3d_global_lowres_image_only_vqa_full64/checkpoint_best.pt`
- MTL branch initialized from `20260603_060012_v6_3d_mtl_bilateral_crop_image_only_vqa_full64/checkpoint_best.pt`
- both encoders frozen
- fusion/head trained with question conditioning
- best epoch: 7
- test pooled AUC: 0.9117
- test pooled balanced accuracy: 0.8243

Question-level AUC:

| question | AUC |
|---|---:|
| low hippocampal volume | 0.877 |
| low hippocampus-to-ventricle ratio | 0.900 |
| MTL atrophy evidence | 0.884 |
| ventricle enlargement | 0.979 |

## Repeat Seed

Three pretrained frozen-fusion seeds were run:

| seed | pooled AUC | pooled balanced accuracy |
|---:|---:|---:|
| 20260603 | 0.9117 | 0.8243 |
| 20260604 | 0.9106 | 0.8219 |
| 20260605 | 0.9117 | 0.8255 |

Pooled AUC mean is 0.9113 with std 0.0006. This suggests the fusion/head stage is stable, but more seeds are still needed before final claims.

## Cohort/Scanner Audit

Current best run pooled cohort AUC:

| cohort | pooled AUC | note |
|---|---:|---|
| A4 | 0.944 | strong |
| ADNI | 0.918 | strong |
| AIBL | 0.895 | small test count |
| AJU | 0.851 | weakest large-ish cohort |
| KDRC | 0.857 | small test count |
| NACC | 0.903 | strong |
| OASIS | 0.924 | strong |

This is encouraging but not enough for publication. AJU/KDRC require closer inspection, and leave-cohort-out validation is still needed.

## Threshold Calibration

Validation-calibrated thresholds were computed for the current best run:

- pooled test balanced accuracy at threshold 0.5: 0.824
- pooled test balanced accuracy with validation-selected threshold: 0.827

The result is therefore primarily an AUC/ranking and representation gain, not merely a threshold tuning artifact.

## Branch Ablation

Branch ablation was run on the current best model:

- `results/f04_roi_evidence_encoder/20260603_064129_v6_multiview_preinit_frozen_branch_ablation_test`

The ablation zeroes encoder feature vectors at inference time:

| question | full AUC | zero global feature AUC | zero MTL feature AUC | key implication |
|---|---:|---:|---:|---|
| low hippocampal volume | 0.877 | 0.796 | 0.286 | MTL branch is essential |
| low hippocampus-to-ventricle ratio | 0.900 | 0.883 | 0.899 | ranking is robust, likely because both trained branches encode some ratio-relevant burden |
| MTL atrophy evidence | 0.884 | 0.830 | 0.325 | MTL branch is essential |
| ventricle enlargement | 0.979 | 0.955 | 0.966 | ranking remains high, but calibration shifts |
| pooled all test rows | 0.912 | 0.763 | 0.505 | full model requires both branches overall |

This supports the anatomical routing hypothesis: hippocampal and MTL questions rely heavily on the MTL-local branch, while ventricular/ranking evidence is more distributed.

## AJU Leave-Cohort-Out Screening

AJU was the weakest larger cohort in the in-split cohort audit, so an AJU holdout screening was run:

- `results/f04_roi_evidence_encoder/20260603_065058_v6_multiview_preinit_frozen_loco_AJU_screening`
- train/val: AJU excluded
- test: AJU only
- test rows: 340
- subject/session overlap: 0

| question | AJU LOCO AUC | in-split AJU AUC | delta |
|---|---:|---:|---:|
| low hippocampal volume | 0.756 | 0.757 | -0.002 |
| low hippocampus-to-ventricle ratio | 0.918 | 0.923 | -0.006 |
| MTL atrophy evidence | 0.818 | 0.822 | -0.004 |
| ventricle enlargement | 0.939 | 0.940 | -0.001 |
| pooled all AJU test rows | 0.848 | 0.851 | -0.003 |

This suggests the AJU weakness is not primarily caused by seeing AJU during train/validation. The residual problem is anatomical: AJU hippocampal evidence remains weak even under LOCO.

AJU hippocampal failure audit:

- `results/f04_roi_evidence_encoder/20260603_071430_AJU_hippocampal_failure_audit`
- hippocampal rows: 96
- AUC: 0.756
- threshold 0.5 errors: 31
- label 0 median hippocampal percentile: 0.250
- label 1 median hippocampal percentile: 0.032

There is real ROI percentile separation, but model scores overlap. This points to a hard local generalization problem rather than a complete label construction failure.

AJU visual audit:

- `results/f04_roi_evidence_encoder/20260603_072007_AJU_hippocampal_visual_audit_2p5d_vs_mtl3d_v2`
- figures compare five 2.5D-like axial slices with three orthogonal MTL-crop views per case
- false negative examples have low hippocampal percentiles but are not always visually obvious on axial strips alone
- this supports keeping the 3D MTL-local view and motivates visual/ROI alignment checks before adding model complexity

AJU hippocampal crop QC audit:

- `results/f04_roi_evidence_encoder/20260603_075634_hippocampal_crop_qc_audit_primary_frozen_fusion_v2`
- hippocampal test rows: 704; AJU rows: 96
- crop box: `32:168,48:168,35:125`
- AJU error rate at threshold 0.5: 0.323
- AJU mean crop mask fraction: 0.643, higher than ADNI 0.616, A4 0.611, NACC 0.601, and OASIS 0.603
- AJU label-positive hippocampal atrophy cases are the hardest: label 1 error rate 0.479 versus label 0 error rate 0.167

This does not support a simple crop/mask coverage failure explanation. The AJU bottleneck is more likely subtle local anatomy, image contrast/intensity distribution, threshold-boundary label noise, or insufficient local hippocampal feature discrimination.

## Local Crop and Intensity-Robustness Follow-Up

After the AJU crop QC audit, three local-view follow-ups were run:

- tight hippocampal/MTL crop cache: `results/f04_roi_evidence_encoder/20260603_081351_v6_3d_mtl_tight_crop_cache_full64`
- tight crop single-view VQA: `results/f04_roi_evidence_encoder/20260603_082924_v6_3d_mtl_tight_crop_image_only_vqa_full64`
- wide MTL crop cache: `results/f04_roi_evidence_encoder/20260603_083311_v6_3d_mtl_wide_crop_cache_full64`
- wide crop single-view VQA: `results/f04_roi_evidence_encoder/20260603_084914_v6_3d_mtl_wide_crop_image_only_vqa_full64`
- current fixed MTL crop with intensity augmentation: `results/f04_roi_evidence_encoder/20260603_085756_v6_3d_mtl_crop_intensity_aug_image_only_vqa_full64`
- integrated comparison audit: `results/f04_roi_evidence_encoder/20260603_090208_v6_local_crop_comparison_audit`

Comparison against 2.5D and existing 3D baselines:

| model | pooled AUC | hippocampal AUC | MTL AUC | balanced accuracy at 0.5 | interpretation |
|---|---:|---:|---:|---:|---|
| 2.5D slab | 0.732 | 0.658 | 0.633 | 0.663 | weak fine anatomy baseline |
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 | best single local view |
| tight crop | 0.878 | 0.847 | 0.867 | 0.526 | ranking signal remains, but calibration collapses |
| wide crop | 0.859 | 0.780 | 0.764 | 0.539 | context expansion loses local discrimination |
| MTL intensity augmentation | 0.873 | 0.848 | 0.857 | 0.779 | calibration improves slightly, AUC worsens |
| frozen global+MTL fusion | 0.912 | 0.877 | 0.884 | 0.824 | current primary model |

AJU hippocampal detail:

| model | AJU hippocampal AUC | AJU hippocampal balanced accuracy at 0.5 |
|---|---:|---:|
| 2.5D slab | 0.562 | 0.521 |
| current fixed MTL crop | 0.768 | 0.646 |
| tight crop | 0.719 | 0.521 |
| wide crop | 0.680 | 0.500 |
| MTL intensity augmentation | 0.746 | 0.688 |
| frozen global+MTL fusion | 0.757 | 0.677 |

The tight and wide crop experiments are negative for novelty: neither improves hippocampal/MTL AUC over the current fixed MTL crop. Intensity augmentation is mixed: it improves threshold-0.5 calibration and AJU hippocampal balanced accuracy, but reduces AUC/ranking. Therefore, these variants should not replace the current primary frozen fusion model. The next credible direction is not simple crop geometry, but either calibrated decision modeling, domain-robust representation learning with preserved AUC, or label-boundary analysis for AJU hippocampal positives.

## Calibration and Label-Boundary Audit

A post-hoc calibration/boundary audit was added:

- script: `scripts/run_f04_v6_calibration_boundary_audit.py`
- active audit: `results/f04_roi_evidence_encoder/20260603_091940_v6_calibration_boundary_audit`
- scope: 2.5D slab, global 3D, current MTL crop, tight/wide crop, MTL intensity augmentation, MTL boundary-filter training, frozen fusion
- audit-only fields: cohort, scanner, clinical fields, ROI/evidence percentiles
- model inputs remain unchanged: image tensor(s) plus question ID only

Key calibration result:

| model | fixed bacc | validation-threshold bacc | AUC |
|---|---:|---:|---:|
| 2.5D slab | 0.663 | 0.672 | 0.732 |
| current fixed MTL crop | 0.776 | 0.794 | 0.881 |
| MTL intensity augmentation | 0.779 | 0.787 | 0.873 |
| MTL boundary-filter training | 0.531 | 0.792 | 0.886 |
| frozen fusion | 0.824 | 0.827 | 0.912 |

Boundary-filter training:

- run: `results/f04_roi_evidence_encoder/20260603_091622_v6_3d_mtl_crop_boundary_filter005_image_only_vqa_full64`
- train-only exclusion: `boundary_distance <= 0.05`
- train examples: 13,854 -> 10,536
- validation/test unchanged
- pooled all-row AUC: 0.886
- hippocampal AUC: 0.843 versus current MTL crop 0.866
- MTL AUC: 0.854 versus current MTL crop 0.878
- balanced accuracy at 0.5: 0.531, indicating severe score compression/calibration failure

AJU hippocampal threshold transfer:

| model | AUC | bacc at 0.5 | bacc with validation question threshold |
|---|---:|---:|---:|
| 2.5D slab | 0.562 | 0.521 | 0.552 |
| current fixed MTL crop | 0.768 | 0.646 | 0.677 |
| MTL intensity augmentation | 0.746 | 0.688 | 0.688 |
| MTL boundary-filter training | 0.750 | 0.510 | 0.688 |
| frozen fusion | 0.757 | 0.677 | 0.667 |

This separates calibration and ranking. Calibration can recover balanced accuracy for boundary-filter and crop-variant models, but it cannot fix AUC/ranking. The AJU hippocampal bottleneck is therefore not merely a global threshold problem.

AJU hippocampal boundary bins show a specific failure pattern:

- in `0.05-0.10`, current MTL crop and frozen fusion are relatively strong
- in `<=0.02` and `0.02-0.05`, current MTL/fusion are unstable
- this supports label-boundary/domain difficulty near the normative cutoff, not simple lack of 3D signal

## Boundary-Aware Soft-Label Local Encoder

Hard boundary exclusion was negative, so a train-only soft-label experiment was run on the current fixed MTL crop:

- local soft-label run: `results/f04_roi_evidence_encoder/20260603_092527_v6_3d_mtl_crop_softlabel_tau003_image_only_vqa_full64`
- soft-label rule: sigmoid of signed evidence-percentile distance from the question cutoff
- temperature: `tau=0.03`
- train target only; validation/test labels remain the original binary QA labels
- model inputs remain image tensor plus question ID only

Single-view result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc at 0.5 | val-threshold bacc |
|---|---:|---:|---:|---:|---:|
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 | 0.794 |
| hard boundary-filter MTL | 0.886 | 0.843 | 0.854 | 0.531 | 0.792 |
| soft-label MTL tau=0.03 | 0.905 | 0.878 | 0.879 | 0.639 | 0.820 |

The soft-label local encoder is poorly calibrated as a standalone classifier, but it substantially improves ranking. This is the first local-representation experiment that improves the key hippocampal signal without changing model inputs.

## Soft-Label Local Encoder Fusion

The soft-label MTL checkpoint was then used as the frozen local branch in the global+MTL fusion model:

- main run: `results/f04_roi_evidence_encoder/20260603_092918_v6_multiview_preinit_frozen_global_mtlsoft_tau003_3d_image_only_vqa_full64`
- repeat seed 20260604: `results/f04_roi_evidence_encoder/20260603_093716_v6_multiview_preinit_frozen_global_mtlsoft_tau003_seed20260604_full64`
- repeat seed 20260605: `results/f04_roi_evidence_encoder/20260603_093716_v6_multiview_preinit_frozen_global_mtlsoft_tau003_seed20260605_full64`
- AJU LOCO seed 20260603: `results/f04_roi_evidence_encoder/20260603_093319_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_AJU_screening`
- AJU LOCO seed 20260604: `results/f04_roi_evidence_encoder/20260603_094109_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_AJU_seed20260604_screening`

Three-seed in-split comparison:

| model | pooled AUC mean | hippocampal AUC mean | MTL AUC mean | bacc mean |
|---|---:|---:|---:|---:|
| primary frozen fusion | 0.9113 | 0.8762 | 0.8827 | 0.8239 |
| soft-label MTL frozen fusion | 0.9177 | 0.8902 | 0.8973 | 0.8270 |

Mean AUC delta versus primary frozen fusion:

| question | delta AUC |
|---|---:|
| pooled all rows | +0.0063 |
| low hippocampal volume | +0.0139 |
| hippocampus-to-ventricle ratio | +0.0001 |
| MTL atrophy evidence | +0.0146 |
| ventricle enlargement | -0.0009 |

AJU LOCO comparison:

| model | pooled AUC | hippocampal AUC | MTL AUC | pooled bacc |
|---|---:|---:|---:|---:|
| primary frozen fusion AJU LOCO | 0.848 | 0.756 | 0.818 | 0.750 |
| soft-label fusion AJU LOCO mean, 2 seeds | 0.873 | 0.804 | 0.854 | 0.779 |

Major-cohort LOCO was then extended:

| cohort | primary frozen fusion pooled AUC | soft-label fusion pooled AUC | delta |
|---|---:|---:|---:|
| ADNI | 0.922 | 0.923 | +0.001 |
| A4 | 0.939 | 0.940 | +0.001 |
| NACC | 0.909 | 0.912 | +0.003 |
| OASIS | 0.920 | 0.927 | +0.007 |
| AJU | 0.848 | 0.873 | +0.025 |

Hippocampal LOCO is more mixed:

| cohort | hippocampal AUC delta, soft minus primary |
|---|---:|
| A4 | +0.0137 |
| AJU | +0.0486 |
| ADNI | -0.0010 |
| NACC | -0.0138 |
| OASIS | -0.0021 |

This is the strongest result so far for pooled and AJU-specific generalization. It improves the exact weak point, AJU hippocampal/MTL generalization, while preserving the image-only input policy. However, hippocampal gains are not uniform across all cohorts, so the final claim should be: boundary-aware soft-label local pretraining improves pooled ROI-grounded VQA and weak-cohort AJU generalization, with cohort-specific hippocampal tradeoffs requiring final locked validation.

## Soft-Label Temperature Follow-Up: tau=0.05

The soft-label temperature was then widened from `tau=0.03` to `tau=0.05`.
This keeps the same model inputs and only changes train-label smoothing for the
local MTL pretraining target. Validation/test labels remain binary.

Artifacts:

- current-state realignment: `results/f04_roi_evidence_encoder/20260603_101405_current_state_realignment`
- local MTL tau=0.05: `results/f04_roi_evidence_encoder/20260603_095533_v6_3d_mtl_crop_softlabel_tau005_image_only_vqa_full64`
- frozen fusion tau=0.05: `results/f04_roi_evidence_encoder/20260603_095940_v6_multiview_preinit_frozen_global_mtlsoft_tau005_3d_image_only_vqa_full64`
- AJU LOCO tau=0.05 seeds: `20260603_101036_*`, `20260603_101531_*seed20260604*`, `20260603_101531_*seed20260605*`
- major-cohort LOCO tau=0.05: `20260603_101941_*loco_ADNI/A4/NACC/OASIS*`

In-split 3-seed result:

| model | pooled AUC mean | hippocampal AUC mean | MTL AUC mean | pooled bacc mean |
|---|---:|---:|---:|---:|
| primary frozen fusion | 0.9113 | 0.8762 | 0.8827 | 0.8239 |
| soft-label fusion tau=0.03 | 0.9177 | 0.8902 | 0.8973 | 0.8270 |
| soft-label fusion tau=0.05 | 0.9199 | 0.8910 | 0.9042 | 0.8335 |

AJU LOCO repeat result:

| model | seeds | pooled AUC mean | hippocampal AUC mean | MTL AUC mean |
|---|---:|---:|---:|---:|
| primary frozen fusion | 1 | 0.848 | 0.756 | 0.818 |
| soft-label fusion tau=0.03 | 2 | 0.873 | 0.804 | 0.854 |
| soft-label fusion tau=0.05 | 3 | 0.875 | 0.813 | 0.845 |

Major-cohort LOCO pooled AUC, single seed:

| held-out cohort | primary frozen fusion | tau=0.03 | tau=0.05 | tau=0.05 minus primary | tau=0.05 minus tau=0.03 |
|---|---:|---:|---:|---:|---:|
| ADNI | 0.922 | 0.923 | 0.926 | +0.004 | +0.003 |
| A4 | 0.939 | 0.940 | 0.945 | +0.006 | +0.005 |
| NACC | 0.909 | 0.912 | 0.911 | +0.001 | -0.002 |
| OASIS | 0.920 | 0.927 | 0.914 | -0.007 | -0.014 |
| AJU | 0.848 | 0.879 | 0.866 | +0.018 | -0.013 |

Selected question-level deltas show the tradeoff:

| held-out cohort | question | tau=0.05 minus primary AUC | tau=0.05 minus tau=0.03 AUC |
|---|---|---:|---:|
| AJU | low hippocampal volume | +0.057 | +0.004 |
| ADNI | MTL atrophy evidence | +0.024 | +0.010 |
| A4 | MTL atrophy evidence | +0.019 | +0.021 |
| OASIS | low hippocampal volume | -0.052 | -0.050 |
| OASIS | MTL atrophy evidence | -0.011 | -0.030 |

Decision: tau=0.05 is not a universally better final model. It strengthens the
in-split benchmark, ADNI/A4 LOCO, and AJU hippocampal ranking, but it hurts
OASIS and weakens AJU MTL compared with tau=0.03. The technical signal is still
useful: boundary-aware soft labels are real, but the temperature controls a
cohort/ROI robustness tradeoff. The next publishable direction should not be
"tau=0.05 beats tau=0.03"; it should be a principled uncertainty-aware
ROI-local pretraining objective with locked temperature selection or
question-specific uncertainty calibration.

## Major-Cohort LOCO Screening

LOCO was extended to major cohorts:

| held-out cohort | LOCO pooled AUC | in-split cohort AUC | delta |
|---|---:|---:|---:|
| ADNI | 0.922 | 0.918 | +0.004 |
| A4 | 0.939 | 0.944 | -0.005 |
| NACC | 0.909 | 0.903 | +0.006 |
| OASIS | 0.920 | 0.924 | -0.004 |
| AJU | 0.848 | 0.851 | -0.003 |

The major-cohort LOCO pattern is stronger than the earlier cohort-stratified audit. Held-out performance is close to in-split performance across these cohorts, which argues against the model depending on simple cohort identity or scanner texture. This does not eliminate all shortcut risk, but it makes the current image-signal claim substantially more credible.

## Staged Unfreeze Follow-Up

A low-LR freeze-then-unfreeze run was tested:

- `results/f04_roi_evidence_encoder/20260603_072240_v6_multiview_preinit_freeze_then_unfreeze_epoch4_lr1e4_full64`
- epochs 1-3: pretrained encoders frozen, fusion/head trained
- epoch 4 onward: both encoders unfrozen with LR 1e-4

| model | pooled AUC | pooled balanced accuracy |
|---|---:|---:|
| freeze-then-unfreeze | 0.915 | 0.834 |
| pretrained frozen fusion | 0.912 | 0.824 |
| 2.5D image-only | 0.732 | 0.663 |

This is promising because hippocampal AUC improves from 0.877 to 0.887 and MTL AUC improves from 0.884 to 0.891. Ventricle AUC decreases slightly from 0.979 to 0.975. Treat this as a candidate upgrade, not the primary result, until repeated seeds and LOCO checks confirm it.

Three staged-unfreeze seeds were then run:

| model | pooled AUC mean | pooled AUC std | pooled balanced accuracy mean |
|---|---:|---:|---:|
| freeze-then-unfreeze | 0.9142 | 0.0010 | 0.8294 |
| pretrained frozen fusion | 0.9113 | 0.0006 | 0.8239 |

Mean delta versus frozen fusion:

| question | delta AUC |
|---|---:|
| low hippocampal volume | +0.0096 |
| low hippocampus-to-ventricle ratio | +0.0002 |
| MTL atrophy evidence | +0.0071 |
| ventricle enlargement | -0.0031 |
| pooled all rows | +0.0029 |

The repeated result supports staged unfreeze as a real but modest in-distribution improvement, especially for hippocampal and MTL evidence.

However, AJU LOCO was worse under staged unfreeze:

| question | staged unfreeze AJU LOCO AUC | frozen fusion AJU LOCO AUC | delta |
|---|---:|---:|---:|
| low hippocampal volume | 0.747 | 0.756 | -0.008 |
| low hippocampus-to-ventricle ratio | 0.908 | 0.918 | -0.009 |
| MTL atrophy evidence | 0.802 | 0.818 | -0.016 |
| ventricle enlargement | 0.932 | 0.939 | -0.008 |
| pooled all AJU rows | 0.835 | 0.848 | -0.013 |

This is a meaningful negative finding. Staged unfreeze improves the matched in-distribution benchmark but weakens the most fragile held-out cohort. Therefore, frozen fusion remains the conservative primary model for generalization claims.

## Diagnosis

The core finding is not just that 3D is better than 2.5D. The stronger finding is:

1. Global 3D recovers spatial context.
2. Fixed MTL-crop 3D recovers hippocampal/MTL-local signal.
3. Naive end-to-end fusion can destroy useful local signal.
4. Staged pretrained frozen fusion preserves branch-specific signal and improves the final VQA task.
5. Branch ablation shows that the MTL branch is not decorative; removing it collapses hippocampal and MTL AUC.

This supports a technical contribution around staged, localization-aware, question-conditioned 3D ROI-grounded VQA.

## Risks

- The encoders were selected from previous validation runs on the same benchmark; this is valid for screening but needs a locked validation protocol for final reporting.
- Cohort/scanner shortcut is reduced by matched labels but not fully eliminated.
- Leave-cohort-out across all cohorts is still required; AJU screening is encouraging but not sufficient.
- Current labels are calibrated FreeSurfer ROI evidence labels, not direct clinical diagnosis labels.

## Next Experiments

1. Keep pretrained frozen fusion as the primary generalization model.
2. Keep soft-label MTL frozen fusion as the primary technical candidate, not final locked result yet.
3. Treat staged unfreeze, tight/wide crop, intensity augmentation, and hard boundary filtering as negative or mixed controls.
4. Do not simply maximize in-split AUC with `tau`; tau=0.05 improves in-split and AJU hippocampal AUC but hurts OASIS. Temperature must be selected by locked validation or made question-specific.
5. For final reporting, separate pooled ROI-grounded VQA, hippocampal-only VQA, MTL-only VQA, and weak-cohort AJU generalization claims.
