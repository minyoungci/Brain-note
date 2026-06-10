# F04 3D vs 2.5D ROI-Grounded VQA Diagnostic Note

Updated: 2026-06-03

## Question

Was the weak hippocampal/MTL performance caused by the 2.5D slab setup failing to capture 3D anatomical context?

## Evidence

Active 2.5D run:

- `results/f04_roi_evidence_encoder/20260603_035910_v6_image_only_matched_vqa_pilot`
- input: cached 2.5D slabs + question ID only
- test macro AUC: 0.732

Active 3D run:

- `results/f04_roi_evidence_encoder/20260603_053530_v6_3d_global_lowres_image_only_vqa_full64`
- input: low-resolution 3D T1w cache `[1, 64, 64, 64]` + question ID only
- test macro AUC: 0.835

Active fixed bilateral MTL-crop 3D run:

- `results/f04_roi_evidence_encoder/20260603_060012_v6_3d_mtl_bilateral_crop_image_only_vqa_full64`
- input: fixed MTL-crop 3D T1w cache `[1, 64, 64, 64]` + question ID only
- crop box on official 192x224x192 grid: `32:168,48:168,35:125`
- pooled all-row test AUC: 0.881
- mean question AUC: 0.903

Active pretrained frozen multi-view 3D run:

- `results/f04_roi_evidence_encoder/20260603_062606_v6_multiview_preinit_frozen_global_mtl_3d_image_only_vqa_full64`
- input: global 3D T1w cache + fixed MTL-crop 3D T1w cache + question ID only
- global branch initialized from the global 3D checkpoint
- MTL branch initialized from the fixed MTL-crop 3D checkpoint
- both image encoders frozen; fusion/head trained
- pooled all-row test AUC: 0.912
- pooled all-row balanced accuracy: 0.824

All runs use the same shortcut-resistant `cohort_dx_cdr_age_sex` matched QA benchmark. All image models exclude clinical fields, ROI values, ROI percentiles, evidence percentiles, and AEB features from model inputs.

## Result

| question | 2.5D AUC | global 3D AUC | MTL-crop 3D AUC | pretrained frozen multi-view AUC |
|---|---:|---:|---:|---:|
| low hippocampal volume | 0.658 | 0.729 | 0.866 | 0.877 |
| low hippocampus-to-ventricle ratio | 0.774 | 0.903 | 0.893 | 0.900 |
| MTL atrophy evidence | 0.633 | 0.686 | 0.878 | 0.884 |
| ventricle enlargement | 0.855 | 0.973 | 0.975 | 0.979 |
| pooled all test rows | 0.732 | 0.835 | 0.881 | 0.912 |

## Interpretation

The 3D result strongly supports that the previous 2.5D model was missing useful spatial context. The fixed MTL-crop result makes this stronger: once the model is forced to focus on the medial temporal region, hippocampal and MTL tasks improve sharply. Therefore, the fine anatomical evidence bottleneck is not simply "no image signal." It is a representation, view, and localization problem.

The global 3D model and MTL-crop model have complementary behavior, and staged multi-view fusion can use both:

- MTL-crop is much better for hippocampal volume and MTL atrophy evidence.
- Global 3D is slightly better for hippocampus-to-ventricle ratio, likely because the ratio needs both hippocampal and ventricular/global context.
- Ventricle performance is near saturated in both 3D settings.
- Naive end-to-end multi-view fusion fails, but pretrained frozen branch fusion improves the pooled AUC to 0.912.
- The frozen-fusion result is stable across three seeds, with pooled AUC mean 0.9113 and std 0.0006.
- Branch ablation supports anatomical routing: removing the MTL feature collapses hippocampal/MTL AUC by -0.591/-0.558.
- AJU leave-cohort-out screening does not show catastrophic cohort shortcut collapse: AJU LOCO pooled AUC 0.848 versus in-split AJU 0.851.
- Major-cohort LOCO screening is close to in-split performance: ADNI 0.922 vs 0.918, A4 0.939 vs 0.944, NACC 0.909 vs 0.903, OASIS 0.920 vs 0.924, AJU 0.848 vs 0.851.

## Current Diagnosis

Most likely:

1. 2.5D slabs lacked enough 3D context for small curved structures.
2. Global 3D context recovers part of the missing hippocampal/MTL signal.
3. Fixed MTL localization recovers substantially more hippocampal/MTL signal.
4. The best technical direction is not a single view but staged, question-conditioned multi-view 3D fusion.
5. Fusion must be staged or regularized; naive end-to-end fusion can degrade both AUC and calibration.
6. Major-cohort LOCO does not currently support a simple cohort-memorization explanation.

Less likely after this run:

- "The image contains no hippocampal/MTL signal."
- "Only clinical shortcut explains the task."

Still possible:

- ROI proxy labels are noisy for MTL/Scheltens-like constructs.
- Low-resolution global 3D is too coarse for the hippocampal head/body/tail, while the fixed crop may still be imperfectly aligned across cohorts.
- Cohort/scanner texture could still contribute; AJU LOCO is encouraging, but full leave-cohort-out checks are needed before publication.

## Next Experiment

Run publication-grade validation for pretrained frozen multi-view 3D VQA:

- same matched QA benchmark
- same forbidden input policy
- 3-5 repeated seeds
- cohort-stratified reporting
- leave-cohort-out validation
- val-calibrated threshold reporting in addition to AUC
- branch attribution/gating audit

Success criteria:

- pooled AUC remains above 0.90 across seeds
- hippocampal/MTL AUC remains above 0.87
- no cohort collapses toward chance
- branch attribution is anatomically plausible

If successful, the technical contribution becomes localization-aware, question-conditioned 3D ROI-grounded VQA for calibrated anatomical evidence extraction from T1w MRI.
