# F04 Next Experiment Plan: AJU-Robust Hippocampal 3D ROI-Grounded VQA

Updated: 2026-06-03

## Current Research Question

Can a T1w MRI image-only model answer ROI-grounded anatomical VQA questions by using real image signal rather than clinical/cohort shortcuts?

The current strongest technical direction is localization-aware 3D VQA: combine global 3D context with a local MTL/hippocampal 3D view, conditioned by question ID.

## Manifest Recheck

Authoritative manifest:

- `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`

Directly rechecked on 2026-06-03:

| item | result |
|---|---:|
| rows | 13,022 |
| subjects | 7,231 |
| columns | 101 |
| `final_qc_status` | 13,022 / 13,022 PASS |
| `final_tensor_n4_path` | 13,022 / 13,022 non-null and exists |
| `final_mask_n4_path` | 13,022 / 13,022 non-null and exists |
| `clin_age` | 12,840 / 13,022 |
| `clin_sex` | 12,883 / 13,022 |
| `clin_dx_label` | 12,583 / 13,022 |
| `cdr_global` | 13,022 / 13,022 |
| `cdrsb` | 12,017 / 13,022 |
| core bilateral ROI fields | 13,022 / 13,022 |

Cohort counts:

| cohort | rows |
|---|---:|
| ADNI | 4,742 |
| NACC | 1,866 |
| A4 | 1,811 |
| OASIS | 1,420 |
| AJU | 1,287 |
| AIBL | 987 |
| KDRC | 909 |

Available information should be separated as follows:

| use | fields |
|---|---|
| model input | N4 T1w image tensor cache, question ID |
| preprocessing/QC | brain mask, fixed crop box, N4 grid/intensity QC, cache index |
| label construction/audit only | ROI values, ROI percentiles, evidence percentiles |
| matching/audit only | cohort, diagnosis, Global CDR, CDR-SB, age, sex, scanner |
| forbidden model input | clinical fields, cohort, scanner, ROI values, ROI percentiles, evidence percentiles, AEB features |

## Previous Result Summary

Primary matched benchmark:

- `cohort_dx_cdr_age_sex`
- model input policy: image tensor(s) + question ID only
- subject split overlap: 0
- session `join_key` split overlap: 0

| model | pooled AUC | balanced accuracy | interpretation |
|---|---:|---:|---|
| 2.5D image-only | 0.732 | 0.663 | weak fine MTL signal |
| global 3D | 0.835 | 0.743 | 3D context helps |
| fixed MTL-crop 3D | 0.881 | 0.776 | local MTL/hippocampal signal is real |
| naive global+MTL fusion | 0.850 | 0.638 | random-init fusion failure |
| pretrained frozen global+MTL fusion | 0.912 | 0.824 | current primary model |
| staged unfreeze global+MTL fusion | 0.914 | 0.829 | in-split gain, but weaker AJU LOCO |

Primary model:

- `results/f04_roi_evidence_encoder/20260603_062606_v6_multiview_preinit_frozen_global_mtl_3d_image_only_vqa_full64`
- 3-seed pooled AUC mean/std: 0.9113 / 0.0006
- major-cohort LOCO pooled AUCs: ADNI 0.922, A4 0.939, NACC 0.909, OASIS 0.920, AJU 0.848

Weak point:

- AJU hippocampal LOCO AUC: 0.756
- AJU hippocampal errors at threshold 0.5: 31 / 96
- crop QC audit: `results/f04_roi_evidence_encoder/20260603_075634_hippocampal_crop_qc_audit_primary_frozen_fusion_v2`
- AJU crop coverage is not low; mean crop mask fraction is 0.643
- AJU label-positive hippocampal atrophy cases are hardest; error rate 0.479

## Scientific Diagnosis

The current problem is no longer "does the image contain signal?" The answer is yes: 3D and MTL-local 3D clearly improve over 2.5D and AEB-like evidence.

The current problem is narrower:

1. AJU hippocampal atrophy positives are hard.
2. The fixed MTL crop is not obviously missing tissue.
3. Staged unfreeze improves in-split performance but hurts AJU LOCO.
4. Therefore, the next experiment should improve local hippocampal discrimination under domain shift without using clinical or ROI shortcuts.

## Next Experiment A: Fixed Local Crop Variant Screening

Goal:

- Test whether the current fixed MTL crop is too broad or too low effective resolution for hippocampal-positive AJU cases.

Inputs:

- source session manifest: `results/f04_roi_evidence_encoder/20260603_050611_3d_roi_grounded_vqa_design/unique_3d_session_manifest.csv`
- QA manifest: `results/f04_roi_evidence_encoder/20260603_050611_3d_roi_grounded_vqa_design/matched_session_qa_with_3d_paths.csv`
- image source: `final_tensor_n4_path`
- model input: cropped N4 T1w tensor + question ID

Do not use:

- ROI values, ROI percentiles, evidence percentiles, clinical fields, cohort, scanner, AEB features.

Crop candidates:

| candidate | crop box | reason |
|---|---|---|
| current MTL | `32:168,48:168,35:125` | baseline local view |
| tighter hippocampal/MTL | `48:152,64:160,44:120` | higher effective local resolution |
| wider MTL context | `24:176,40:184,28:136` | more anatomical context and less boundary risk |

Primary screening command pattern:

```bash
python scripts/run_f04_v6_3d_volume_cache_builder.py \
  --run-tag v6_3d_mtl_tight_crop_cache_full64 \
  --crop-box 48:152,64:160,44:120 \
  --shape 64x64x64

python scripts/run_f04_v6_3d_image_only_matched_vqa.py \
  --cache-dir results/f04_roi_evidence_encoder/<tight_crop_cache_dir> \
  --run-tag v6_3d_mtl_tight_crop_image_only_vqa_full64 \
  --epochs 8 \
  --batch-size 64 \
  --lr 0.002 \
  --seed 20260603
```

Success criteria:

- hippocampal AUC improves over current fixed MTL-crop 0.866
- AJU hippocampal in-split or LOCO screening improves over 0.756 after the same protocol is applied
- no large pooled AUC collapse versus fixed MTL-crop 0.881

Stop criterion:

- if tighter and wider crops both fail to improve hippocampal/MTL AUC, crop geometry is probably not the dominant bottleneck.

## Next Experiment B: Frozen Fusion With Best Local Crop

Goal:

- Replace only the MTL branch cache/checkpoint with the best local crop candidate and keep the global branch frozen.

Inputs:

- global cache: `20260603_051311_v6_3d_global_lowres_cache_full64`
- local cache: best candidate from Experiment A
- global checkpoint: `20260603_053530_v6_3d_global_lowres_image_only_vqa_full64/checkpoint_best.pt`
- local checkpoint: best candidate single-view checkpoint

Command pattern:

```bash
python scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py \
  --global-cache-dir results/f04_roi_evidence_encoder/20260603_051311_v6_3d_global_lowres_cache_full64 \
  --mtl-cache-dir results/f04_roi_evidence_encoder/<best_local_cache_dir> \
  --init-global-checkpoint results/f04_roi_evidence_encoder/20260603_053530_v6_3d_global_lowres_image_only_vqa_full64/checkpoint_best.pt \
  --init-mtl-checkpoint results/f04_roi_evidence_encoder/<best_local_single_view_run>/checkpoint_best.pt \
  --init-question-embedding-from mtl \
  --freeze-encoders \
  --run-tag v6_multiview_preinit_frozen_global_bestlocal_3d_image_only_vqa_full64 \
  --epochs 8 \
  --batch-size 32 \
  --lr 0.002 \
  --seed 20260603
```

Success criteria:

- pooled AUC >= current frozen fusion 0.912
- hippocampal AUC > 0.877
- AJU LOCO pooled AUC does not drop below 0.848
- AJU hippocampal AUC improves over 0.756

## Next Experiment C: AJU LOCO Confirmation

Goal:

- Confirm whether any apparent improvement generalizes to the weakest cohort.

Command pattern:

```bash
python scripts/run_f04_v6_multiview_3d_image_only_matched_vqa.py \
  --global-cache-dir results/f04_roi_evidence_encoder/20260603_051311_v6_3d_global_lowres_cache_full64 \
  --mtl-cache-dir results/f04_roi_evidence_encoder/<best_local_cache_dir> \
  --init-global-checkpoint results/f04_roi_evidence_encoder/20260603_053530_v6_3d_global_lowres_image_only_vqa_full64/checkpoint_best.pt \
  --init-mtl-checkpoint results/f04_roi_evidence_encoder/<best_local_single_view_run>/checkpoint_best.pt \
  --init-question-embedding-from mtl \
  --freeze-encoders \
  --exclude-train-consortium AJU \
  --test-consortium AJU \
  --run-tag v6_multiview_preinit_frozen_global_bestlocal_loco_AJU_screening \
  --epochs 8 \
  --batch-size 32 \
  --lr 0.002 \
  --seed 20260603
```

Interpretation:

- If AJU improves, the technical claim becomes stronger: local-view design, not clinical shortcut, improves the hardest anatomical VQA subgroup.
- If in-split improves but AJU LOCO fails, the result is likely domain-specific overfitting or AJU label-boundary sensitivity.
- If both fail, the next direction should shift from crop geometry to augmentation/domain robustness or ROI-label noise analysis.

## Recommended Immediate Order

1. Build tight crop cache.
2. Train tight crop single-view 3D VQA.
3. Build wide crop cache.
4. Train wide crop single-view 3D VQA.
5. Pick the better local crop based on hippocampal/MTL AUC and pooled stability.
6. Run frozen global+best-local fusion.
7. Run AJU LOCO for the new fusion only if it beats the current frozen fusion in the matched test.

This keeps the next phase small, falsifiable, and directly tied to the current failure mode.

## Execution Update: 2026-06-03

The fixed local crop screening was executed.

Artifacts:

- tight crop cache: `results/f04_roi_evidence_encoder/20260603_081351_v6_3d_mtl_tight_crop_cache_full64`
- tight crop VQA: `results/f04_roi_evidence_encoder/20260603_082924_v6_3d_mtl_tight_crop_image_only_vqa_full64`
- wide crop cache: `results/f04_roi_evidence_encoder/20260603_083311_v6_3d_mtl_wide_crop_cache_full64`
- wide crop VQA: `results/f04_roi_evidence_encoder/20260603_084914_v6_3d_mtl_wide_crop_image_only_vqa_full64`
- MTL intensity augmentation VQA: `results/f04_roi_evidence_encoder/20260603_085756_v6_3d_mtl_crop_intensity_aug_image_only_vqa_full64`
- integrated audit: `results/f04_roi_evidence_encoder/20260603_090208_v6_local_crop_comparison_audit`

Result:

| model | pooled AUC | hippocampal AUC | MTL AUC | bacc at 0.5 |
|---|---:|---:|---:|---:|
| current fixed MTL crop | 0.881 | 0.866 | 0.878 | 0.776 |
| tight crop | 0.878 | 0.847 | 0.867 | 0.526 |
| wide crop | 0.859 | 0.780 | 0.764 | 0.539 |
| MTL intensity augmentation | 0.873 | 0.848 | 0.857 | 0.779 |
| frozen global+MTL fusion | 0.912 | 0.877 | 0.884 | 0.824 |

AJU hippocampal result:

| model | AJU hippocampal AUC | AJU hippocampal bacc at 0.5 |
|---|---:|---:|
| current fixed MTL crop | 0.768 | 0.646 |
| tight crop | 0.719 | 0.521 |
| wide crop | 0.680 | 0.500 |
| MTL intensity augmentation | 0.746 | 0.688 |
| frozen global+MTL fusion | 0.757 | 0.677 |

Decision:

- Tight and wide crop variants are negative. They should not replace the current fixed MTL crop.
- MTL intensity augmentation is mixed: it improves threshold-0.5 balanced accuracy but worsens AUC/ranking.
- New frozen global+best-local fusion should not be run with tight or wide crop as a promoted path, because neither local branch is better than the existing MTL crop.
- The next experiment should focus on calibration/ranking separation, domain-robust local representation without AUC loss, or AJU hippocampal label-boundary analysis.

## Execution Update: Calibration and Boundary Training

Additional artifacts:

- calibration/boundary audit: `results/f04_roi_evidence_encoder/20260603_091940_v6_calibration_boundary_audit`
- boundary-filter training run: `results/f04_roi_evidence_encoder/20260603_091622_v6_3d_mtl_crop_boundary_filter005_image_only_vqa_full64`
- audit script: `scripts/run_f04_v6_calibration_boundary_audit.py`

The calibration/boundary audit separated AUC ranking from threshold behavior:

| model | fixed bacc | validation-threshold bacc | AUC |
|---|---:|---:|---:|
| 2.5D slab | 0.663 | 0.672 | 0.732 |
| current fixed MTL crop | 0.776 | 0.794 | 0.881 |
| MTL intensity augmentation | 0.779 | 0.787 | 0.873 |
| MTL boundary-filter training | 0.531 | 0.792 | 0.886 |
| frozen global+MTL fusion | 0.824 | 0.827 | 0.912 |

Boundary-filter training removed train examples within 0.05 of the evidence cutoff:

- train examples: 13,854 -> 10,536
- validation/test unchanged
- pooled all-row AUC: 0.886
- hippocampal AUC: 0.843, below current fixed MTL crop 0.866
- MTL AUC: 0.854, below current fixed MTL crop 0.878
- threshold-0.5 balanced accuracy: 0.531

Decision:

- Hard boundary exclusion is not a promoted strategy.
- The result supports the idea that boundary/cutoff behavior matters, but simply deleting near-boundary training examples compresses scores and weakens question-level hippocampal/MTL ranking.
- The next training experiment should use boundary-aware weighting or soft labels, not hard exclusion.

## Execution Update: Soft-Label Local Encoder and Fusion

Soft-label local training was executed:

- local run: `results/f04_roi_evidence_encoder/20260603_092527_v6_3d_mtl_crop_softlabel_tau003_image_only_vqa_full64`
- tau: 0.03
- train labels only are softened from evidence-cutoff distance
- validation/test remain binary matched QA labels
- model input remains image tensor plus question ID only

Single-view result:

| model | pooled AUC | hippocampal AUC | MTL AUC |
|---|---:|---:|---:|
| current fixed MTL crop | 0.881 | 0.866 | 0.878 |
| hard boundary-filter MTL | 0.886 | 0.843 | 0.854 |
| soft-label MTL tau=0.03 | 0.905 | 0.878 | 0.879 |

Soft-label fusion was then executed:

- main run: `results/f04_roi_evidence_encoder/20260603_092918_v6_multiview_preinit_frozen_global_mtlsoft_tau003_3d_image_only_vqa_full64`
- repeat seed 20260604: `results/f04_roi_evidence_encoder/20260603_093716_v6_multiview_preinit_frozen_global_mtlsoft_tau003_seed20260604_full64`
- repeat seed 20260605: `results/f04_roi_evidence_encoder/20260603_093716_v6_multiview_preinit_frozen_global_mtlsoft_tau003_seed20260605_full64`
- AJU LOCO seed 20260603: `results/f04_roi_evidence_encoder/20260603_093319_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_AJU_screening`
- AJU LOCO seed 20260604: `results/f04_roi_evidence_encoder/20260603_094109_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_AJU_seed20260604_screening`

Three-seed in-split result:

| model | pooled AUC mean | hippocampal AUC mean | MTL AUC mean |
|---|---:|---:|---:|
| primary frozen fusion | 0.911 | 0.876 | 0.883 |
| soft-label fusion | 0.918 | 0.890 | 0.897 |

AJU LOCO:

| model | pooled AUC | hippocampal AUC | MTL AUC |
|---|---:|---:|---:|
| primary frozen fusion AJU LOCO | 0.848 | 0.756 | 0.818 |
| soft-label fusion AJU LOCO mean, 2 seeds | 0.873 | 0.804 | 0.854 |

Decision:

- Soft-label MTL frozen fusion is the new primary candidate.
- The result directly improves the weakest AJU hippocampal/MTL screen.
- Next step is major-cohort LOCO expansion for ADNI, A4, NACC, and OASIS before final claims.

## Execution Update: Major-Cohort LOCO Expansion

Major-cohort LOCO expansion was executed:

- ADNI: `results/f04_roi_evidence_encoder/20260603_094816_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_ADNI_screening`
- A4: `results/f04_roi_evidence_encoder/20260603_094816_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_A4_screening`
- NACC: `results/f04_roi_evidence_encoder/20260603_094816_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_NACC_screening`
- OASIS: `results/f04_roi_evidence_encoder/20260603_094816_v6_multiview_preinit_frozen_global_mtlsoft_tau003_loco_OASIS_screening`
- summary artifacts: `results/f04_roi_evidence_encoder/20260603_092918_v6_multiview_preinit_frozen_global_mtlsoft_tau003_3d_image_only_vqa_full64/soft_fusion_major_LOCO_*.csv`

Pooled LOCO AUC:

| cohort | primary frozen fusion | soft-label fusion | delta |
|---|---:|---:|---:|
| ADNI | 0.922 | 0.923 | +0.001 |
| A4 | 0.939 | 0.940 | +0.001 |
| NACC | 0.909 | 0.912 | +0.003 |
| OASIS | 0.920 | 0.927 | +0.007 |
| AJU | 0.848 | 0.873 | +0.025 |

Hippocampal LOCO AUC deltas:

| cohort | delta |
|---|---:|
| A4 | +0.0137 |
| AJU | +0.0486 |
| ADNI | -0.0010 |
| NACC | -0.0138 |
| OASIS | -0.0021 |

Decision:

- The soft-label fusion candidate is robust for pooled major-cohort LOCO.
- The main novelty claim should emphasize pooled ROI-grounded VQA and weak-cohort AJU improvement.
- Hippocampal-only claims must be cohort-qualified because NACC/OASIS/ADNI hippocampal deltas are slightly negative.
