# Official v2 preprocessing 결과 기반 연구 가능성 점검 — 2026-05-17

## Bottom line

`/home/vlm/data/preprocessed_official/v2`는 6개 cohort의 raw-source 기반 isolated preprocessing line이다. 현재 Stage02 validated NIfTI manifest 기준으로 `11,736` rows / `6,473` dataset-subjects가 확보되어 있고, CN/MCI/AD classifiable row는 `10,805`이다. 아직 최종 `final_tensor` 산출물은 없고, 현재 ADNI FastSurfer가 진행 중이다. 따라서 지금 당장 가능한 것은 **manifest/benchmark 설계와 shortcut baseline 정의**이고, 최종 모델 학습은 HD-BET/FastSurfer/finalizer 완료 후 시작하는 것이 맞다.

## Evidence inspected

- Process table: `scripts/run_official_v2_full_safe.sh` active under `/home/vlm/minyoung/preprocessing/official`.
- Active output root: `/home/vlm/data/preprocessed_official/v2`.
- Isolation marker: `/home/vlm/data/preprocessed_official/v2/OFFICIAL_V2_ISOLATION_MARKER.json`.
- Stage00/01 summary: `/home/vlm/data/preprocessed_official/v2/reports/official6_stage00_01/official6_stage00_01_summary.md`.
- Stage02 validated manifests under each cohort's `manifests/` directory.
- FastSurfer logs under `/home/vlm/data/preprocessed_official/v2/ADNI/logs/fastsurfer_v2_full_20260516_065401/`.

## Current preprocessing status

### Stage00/01 inventory

- Raw inventory rows: `15,718`.
- Stage01 rows: `11,750`.
- Required action by dataset:
  - ADNI: `5,037` DICOM→NIfTI + QC.
  - AIBL: `991` DICOM zip extraction/stream + conversion.
  - AJU: `1,287` DICOM→NIfTI + QC.
  - KDRC: `944` existing NIfTI input QC.
  - NACC: `1,876` DICOM zip extraction/stream + conversion.
  - OASIS: `1,615` existing NIfTI input QC.

### Stage02 validated NIfTI manifests

- Total validated rows: `11,736`.
- Total dataset-subjects: `6,473`.
- CN/MCI/AD classifiable rows excluding KDRC blank diagnosis: `10,805`.

By cohort:

- ADNI: `5,037` rows / `1,754` subjects; CN `2,686`, MCI `2,048`, AD `303`.
- AIBL: `990` rows / `617` subjects; CN `720`, MCI `141`, AD `129`; 1 excluded due to extreme voxel size.
- AJU: `1,287` rows / `1,001` subjects; CN `29`, MCI `1,028`, AD `230`; many QC WARN but ready.
- KDRC: `931` rows / `931` subjects; diagnosis column blank at this stage; 13 excluded from 944 due to unreadable/extreme/non-3D input issues.
- NACC: `1,876` rows / `1,420` subjects; CN `1,253`, MCI `415`, AD `208`.
- OASIS: `1,615` rows / `750` subjects; CN `1,312`, MCI `50`, AD `253`.

### Longitudinal potential from Stage02 rows

Unfiltered adjacent-pair potential by same subject:

- ADNI: `870` repeated subjects, `3,283` adjacent pairs.
- AIBL: `178` repeated subjects, `373` adjacent pairs.
- AJU: `286` repeated subjects, `286` adjacent pairs.
- NACC: `365` repeated subjects, `456` adjacent pairs.
- OASIS: `404` repeated subjects, `865` adjacent pairs.
- KDRC: no repeated subjects in current Stage02 manifest.

This is promising for longitudinal SSL, but pair intervals and temporal label transitions still need proper date parsing and filtering.

### Final output readiness

Observed artifact counts:

- FastSurfer segmentation completed so far: `4,469`, currently ADNI only.
- `final_tensor` NIfTI count: `0` observed at time of inspection.
- HD-BET output count: `0` observed at time of inspection.

Interpretation: current v2 is still mid-pipeline. The data are not yet ready for full representation learning from final tensors.

## Research directions enabled by v2

### Direction 1 — Multi-cohort structural MRI representation benchmark

Most immediately feasible after final tensors complete.

Core question:

> Can T1w-only MRI representations generalize across ADNI/AIBL/AJU/NACC/OASIS/KDRC without relying on cohort/scanner/QC shortcuts?

Recommended task:

- Self-supervised or supervised representation learning on T1w.
- Downstream probes on disease-axis and PET/amyloid endpoints.
- Leave-one-cohort-out evaluation.

Why v2 helps:

- v2 is isolated from v1 and old preprocessed roots.
- It is raw-source-based and 6-cohort unified.
- It greatly expands path-valid input beyond prior conservative V4-good basis.

Main risk:

- If the model only learns dataset/scanner identity, results are scientifically weak.

Mandatory baselines:

- age/sex only.
- age/sex/cohort/scanner/QC.
- ROI/FreeSurfer volumes.
- random/shuffled labels.
- leave-one-cohort-out performance.

### Direction 2 — PET-privileged amyloid-risk representation learning

This remains the strongest paper direction.

Core question:

> Can sparse PET/Centiloid/SUVR supervision teach a T1w MRI encoder to estimate calibrated amyloid-risk when PET is missing at test time?

Input:

- Test-time: T1w structural MRI only.
- Training-time privileged targets: PET-derived amyloid, Centiloid, SUVR, PET readings where semantics are verified.

Most important endpoints:

- Amyloid positive/negative.
- Centiloid continuous/ranking.
- SUVR continuous/ranking, especially for KDRC after source verification.
- PET referral/triage utility.

Why v2 helps:

- A larger and cleaner T1w basis can support pretraining and representation extraction.
- KDRC rows can become stronger Korean external validation once clinical/PET semantics are joined.
- ADNI/OASIS remain the likely primary quantitative PET benchmark.

Claim boundary:

- Do not claim MRI replaces PET.
- Claim PET-informed risk stratification and uncertainty-aware referral only if calibration/subgroup gates pass.

### Direction 3 — Longitudinal T1w SSL/JEPA as auxiliary objective

Core question:

> Does within-subject temporal structure improve PET/amyloid transfer or progression-risk representation beyond cross-sectional MRI and non-image shortcuts?

Why v2 helps:

- Stage02 suggests substantial repeated-subject data: ADNI/OASIS/NACC/AIBL/AJU together have thousands of unfiltered adjacent pairs.

Required controls:

- random-pair control.
- shuffled-time control.
- cross-sectional SSL baseline.
- Δz/velocity probe.
- time-gap-filtered pairs, not just arbitrary session order.

Claim boundary:

- Longitudinal loss alone does not prove disease trajectory learning.
- If random-pair matches real-pair, longitudinal claim must be dropped.

### Direction 4 — Shortcut-resistance / dataset identity benchmark

This could be a benchmark-style paper or an important section in the main paper.

Core question:

> How much of apparent dementia MRI performance comes from cohort, scanner, QC, diagnosis-prevalence, or preprocessing artifacts?

Why v2 helps:

- v2 includes raw-source provenance, conversion status, QC status, cohort, series metadata, and unified outputs.
- Multi-cohort row counts are large enough to build strong shortcut baselines.

Possible outputs:

- dataset-only classifier.
- cohort/scanner/QC-only amyloid/diagnosis predictor.
- external performance drop maps.
- failure maps by cohort and class.

This is not the strongest standalone top-tier AI method, but it is a reviewer-proofing component.

### Direction 5 — Korean external validation with AJU + KDRC

Core question:

> Does a PET-informed MRI model trained on public Western cohorts transfer to Korean clinical cohorts?

Why v2 helps:

- AJU and KDRC are now inside the same official v2 preprocessing root.
- KDRC has substantial T1w availability and PET/SUVR potential from prior audits.
- AJU has many MCI rows but amyloid label semantics must be decoded.

Risks:

- KDRC diagnosis blank in current Stage02 manifest.
- AJU CN count is tiny and MCI-dominant.
- Binary amyloid semantics cannot be inferred from column names.

Recommended role:

- KDRC/AJU as held-out external biological/domain validation, not mixed blindly into train.

## Recommended benchmark stack after v2 finishes

1. Build final v2 canonical manifest from final tensors + clinical + PET joins.
2. Verify subject-level uniqueness, repeated visits, label completeness, and path existence.
3. Define global subject-level splits and leave-one-cohort-out splits.
4. Run non-image shortcut baselines first.
5. Run ROI/FreeSurfer baseline.
6. Run small 3D CNN/MAE cross-sectional T1w baseline.
7. Add PET-privileged objective.
8. Add longitudinal objective only after cross-sectional and shortcut bars are fixed.
9. Evaluate ADNI↔OASIS and Korean held-out transfer.
10. Report calibration and PET-referral utility, not only AUROC.

## Metrics to prioritize

Binary amyloid:

- AUROC, AUPRC, balanced accuracy, sensitivity/specificity, confusion matrix.

Continuous PET:

- MAE, RMSE, R², Pearson, Spearman, C-index/ranking.

Calibration/triage:

- Brier, NLL, ECE, reliability plot, selective risk-coverage, PET referral curve.

Domain robustness:

- internal vs leave-one-cohort-out performance drop.
- cohort-stratified AUROC/AUPRC/calibration.

Longitudinal:

- real-pair vs random-pair delta.
- Δz/velocity correlation with PET/progression.
- future-risk prediction at fixed time windows.

## Skeptical reviewer objections

1. The model may learn cohort/scanner/QC shortcuts, not biology.
2. MRI cannot fully infer amyloid molecular pathology; PET replacement claims are unsafe.
3. Longitudinal objectives may learn identity/anatomy rather than disease trajectory.
4. AJU/KDRC label semantics may not match ADNI/OASIS endpoints.
5. Diagnosis imbalance is severe by cohort: AJU is MCI-heavy, OASIS mostly CN, ADNI has many repeated visits.
6. If v2 preprocessing changes intensity/segmentation artifacts by cohort, preprocessing itself can become a domain shortcut.

## Practical next step

Do not launch new modeling yet. Wait for v2 final tensors or build only manifest/split/shortcut-baseline code now. The first research artifact should be a v2 final canonical manifest with:

- final tensor path.
- FastSurfer/ROI path.
- subject/session keys.
- cohort/source/provenance/QC fields.
- diagnosis and clinical labels.
- PET endpoint joins where semantics are verified.
- subject-level and cohort-held-out split assignments.

