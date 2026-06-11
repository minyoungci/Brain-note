# SPEC — minyoung3 (F04 Q-ROUTE)

Living spec. Last updated: 2026-06-11. Keep this file current as the project evolves.

## 1. Research goal

Image-only **ROI-grounded 3D MRI Visual Question Answering (VQA)**: given a 3D T1w brain
MRI and a question id (no clinical/cohort/ROI metadata), answer normative anatomical-
evidence questions. Central question we study: **what form of ROI conditioning actually
improves fine-grained 3D MRI VQA, and when?**

Target venue: **ACCV** (computer-vision; method + rigorous empirical study).

## 2. Task

4 binary session questions (1:1 balanced), labels = normative percentile cutoffs from a
train-only CN reference (regress ROI on age/age^2/sex/log-brain/consortium/field, residual
percentile):

| question_id | rule | ROI evidence |
|---|---|---|
| normqa_low_hippocampal_volume | percentile <= 0.10 | hippocampus volume residual |
| normqa_mtl_atrophy_evidence | percentile <= 0.10 | MTL (hippo+amyg+ento+parahippo) sum |
| normqa_ventricle_enlargement | percentile >= 0.90 | ventricle-to-brain ratio residual |
| normqa_low_hippocampus_to_ventricle_ratio | percentile <= 0.10 | hippo-to-ventricle ratio |

Model input: image tensors + question id ONLY. Forbidden inputs: clinical fields, cohort,
diagnosis/CDR, age/sex, FreeSurfer ROI values, evidence percentiles.

## 3. Data (verified 2026-06-11)

Authoritative manifest: `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`
(13,022 sessions / 7,231 subjects, all QC PASS, N4 T1w tensors 192x224x192). `/home/vlm/data`
is READ-ONLY.

Matched VQA benchmark (`results/.../20260603_050611_3d_roi_grounded_vqa_design/matched_session_qa_with_3d_paths.csv`):
- **19,236 QA rows / 9,278 sessions / 5,601 subjects**
- 7 consortia (sessions): ADNI 3410, A4 1536, NACC 1194, AJU 1184, OASIS 842, AIBL 607, KDRC 505
- scanners: SIEMENS 10320, GE 5260, PHILIPS 1797 (multi-vendor); field: mostly 3.0T, few 1.5T
- dx mix: MCI 8112, CN 5380, CN_preclinical 3540, AD 1482, Dementia 276; CDR 0.5/0/1 = 10588/7056/1462
- AJU/KDRC = Korean cohorts; rest public (ADNI/A4/NACC/OASIS/AIBL)

Shortcut control: `cohort_dx_cdr_age_sex` matched -> clinical-context AUC ~ chance (0.50-0.55),
ROI-oracle = 1.0. LOCO test sizes: AJU 340 rows/124 subj, OASIS 210/75, NACC 320/145; leakage 0.

3D caches (100% coverage of the 9,278 sessions):
- global low-res 64^3 ; MTL bilateral crop 80^3 ; ROI-union (MTL+ventricle) crop 80^3
- per-session FreeSurfer ROI masks at the 192x224x192 grid (for weak-supervision prior only)

## 4. Method (current)

**Q-ROUTE: parameter-efficient anatomy-prior-guided question router.** Per-ROI expert
encoders (global64, MTL80, ROI-union80), each contrastively pretrained (LOCO-safe) and
fine-tuned. A learned gate (question emb + global summary) softmax-routes each question to
its expert; weakly regularized toward an anatomical prior (CE, lambda=0.3). Routed evidence
via question-as-query cross-attention, added residually to the multi-crop concat -> answer head.

## 5. Latest status / key results (2026-06-11)

- Method works on the **compact** encoder; multi-cohort LOCO (AJU/OASIS/NACC) learned router
  beats single-view + multi-crop, bootstrap-significant in 5/6 cells. Gains concentrated on
  fine MTL/hippocampal questions (MTL +0.12, hippo +0.10 vs multi-crop).
- **Parameter-efficiency frontier (the headline)**: 0.35M routed model (0.882) beats 14M
  ResNet-10 and 33M ResNet-18; routing gain monotonically vanishes with scale
  (+0.070 -> +0.006 -> -0.005).
- Ablations: prior is a weak regularizer (no-prior router still beats single-view, gate
  data-driven, not a lookup); learned localization & relational modules FAIL (below single-view);
  benefit is representation-gated (only on fine-tuned base; contrastive scale/cutout aug harms atrophy).
- Honest limitation: routing not a universal gain (subsumed by large backbones); does not beat
  morphometry CN/AD bar (~0.91); single SSL seed; ResNet rows AJU-only/2-seed.

Submission package: `ACCV/` (PAPER_DRAFT.md, RESULTS_TABLES.md, figures, scripts).

## 6. Boundaries

- Do NOT revive old full-3D-voxel / PET-transfer direction. Do NOT write to `/home/vlm/data`.
- Do NOT claim ROI anatomical perfection from QC PASS, nor clinical validity from percentile labels.
- bf16 only (no fp16); B200 GPUs; respect ~1TB RAM ceiling.

## 7. Open / next (vision-contribution candidates — see PAPER_PLAN)

- Learned-attention baseline (ViT-3D / whole-volume attention) vs explicit ROI routing at matched compute.
- Data-scale axis (low-data regime) -> 2D data x params efficiency frontier.
- Generality on a 2nd 3D task/dataset (strongest but largest scope).
