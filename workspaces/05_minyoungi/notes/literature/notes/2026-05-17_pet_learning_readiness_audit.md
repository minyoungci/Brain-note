# PET learning-readiness audit — 2026-05-17

## Bottom line

PET는 “있다.” 하지만 학습에 필요한 형태는 endpoint별로 다르다.

- ADNI/NACC: PET-derived numeric labels are available mainly as table endpoints (`amyloid_status`, `centiloid`, `SUVR`) from v1 pairing audits; this is suitable for T1w→PET-label supervised/probe learning after rejoining to v2 T1w outputs.
- OASIS: raw OASIS centiloid metadata exists, and a separate OASIS580 registered PET→T1w-grid SUVR final gate exists. However the older v1 QC-pass pairing manifest did not mark OASIS PET as available, so OASIS must be joined from the dedicated OASIS PET manifests, not from the broad v1 pairing file alone.
- KDRC/AJU: registered PET image paths and thalamus/cerebellum SUVR final-gate outputs exist from v1 Korean PET preprocessing, but downstream biological use requires strict provenance/semantics handling; AJU binary amyloid semantics remain especially risky.
- Current official v2 preprocessing is T1w-focused. PET has not yet been integrated into the v2 final canonical manifest. So v2 completion alone does not automatically give a training-ready PET dataset; a PET join/build step is required.

## Evidence inspected

- `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Pairing_Audit_20260511/qc_pass_t1w_pet_pairing_manifest_20260511.csv`
- `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Preprocessing_20260512/PET_SUVR_FinalReadyGate_20260512/oasis580_thalamus_cerebellum_suvr_FINAL_READY_PREPROCESSING_GATE_20260512.csv`
- `/home/vlm/data/preprocessed_official/v1/Korean Dataset/manifests/korean_dataset_aju_kdrc_thalamus_cerebellum_suvr_FINAL_READY_PREPROCESSING_GATE_20260513.csv`
- `/home/vlm/data/preprocessed_official/v1/KDRC/manifests/kdrc_unified_suvr_final_gate_DEDUP_SUBJECT_PATHVERIFIED_20260515.csv`
- `/home/vlm/data/raw/oasis3/OASIS3_amyloid_centiloid.csv`

## Broad v1 T1w/PET pairing counts

File: `qc_pass_t1w_pet_pairing_manifest_20260511.csv`

Total rows: `6,683`.

Usable row-level label tiers from this broad pairing file:

- PET any: `4,363` rows / `2,373` dataset-subjects.
  - ADNI `2,132`, AIBL `984`, AJU `437`, KDRC `552`, NACC `258`.
- Amyloid status nonempty: `3,239` rows / `1,664` dataset-subjects.
  - ADNI `2,106`, AJU `437`, KDRC `552`, NACC `144`.
- Centiloid nonempty: `2,274` rows / `695` dataset-subjects.
  - ADNI `2,130`, NACC `144`.
- SUVR nonempty: `2,833` rows / `1,232` dataset-subjects.
  - ADNI `2,130`, KDRC `490`, NACC `213`.
- PET within 365 days: `2,916` rows / `1,330` dataset-subjects.
  - ADNI `1,817`, AIBL `927`, NACC `172`.
- PET within 180 days: `2,536` rows / `1,294` dataset-subjects.
  - ADNI `1,470`, AIBL `911`, NACC `155`.

Important caveat: AIBL has PET availability/window metadata in the broad pairing file, but no amyloid/Centiloid/SUVR label values there. It is not immediately usable as a supervised PET-label endpoint without recovering endpoint columns.

## OASIS PET readiness

Raw OASIS centiloid metadata:

- `/home/vlm/data/raw/oasis3/OASIS3_amyloid_centiloid.csv`
- `1,893` rows.
- tracers: PIB `1,178`, AV45 `715`.
- `Centiloid_fSUVR_TOT_CORTMEAN` nonmissing for all `1,893`; fBP fields nonmissing for `1,141`.

Registered OASIS PET/SUVR final gate:

- `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Preprocessing_20260512/PET_SUVR_FinalReadyGate_20260512/oasis580_thalamus_cerebellum_suvr_FINAL_READY_PREPROCESSING_GATE_20260512.csv`
- `580` rows.
- `pet_in_t1w_grid_path` exists for `580/580`.
- `suvr_mean`, `suvr_median`, `status_suvr=OK` for `580/580`.
- tracer: PIB `318`, AV45 `262`.
- diagnosis skew: CN `544`, AD `33`, MCI `3`.
- QC caveat: case-level visual QC fields remain marked pending, though final gate has gross path/numeric/QC checks.

Interpretation: OASIS is usable for continuous PET/SUVR/centiloid-style endpoint work, but poor for MCI-only analysis in this OASIS580 release due to only 3 MCI rows.

## Korean PET/SUVR readiness

AJU+KDRC combined final gate:

- `/home/vlm/data/preprocessed_official/v1/Korean Dataset/manifests/korean_dataset_aju_kdrc_thalamus_cerebellum_suvr_FINAL_READY_PREPROCESSING_GATE_20260513.csv`
- `765` rows.
- `pet_in_t1w_grid_path` exists for `765/765`.
- `final_tensor_path` exists for `765/765`.
- `suvr_mean`, `suvr_median`, `status_suvr=OK` for `765/765`.
- `pet_suvr_final_ready=True` for `764/765`; one hold case.
- Caveat: `pet_suvr_allowed=False` in this combined file; downstream use needs careful provenance/tracer-aware decision.

KDRC deduplicated path-verified final gate:

- `/home/vlm/data/preprocessed_official/v1/KDRC/manifests/kdrc_unified_suvr_final_gate_DEDUP_SUBJECT_PATHVERIFIED_20260515.csv`
- `786` rows.
- `final_tensor_path` exists for `786/786`.
- `pet_registered_to_t1w_path` exists for `786/786`.
- `suvr_mean`, `suvr_median`, `status_suvr=OK` for `786/786`.
- diagnosis labels codebook-confirmed for KDRC MCD: CN `291`, MCI `244`, AD `251`.
- `pet_suvr_allowed=True` for `496`; `False` for `290`.
- `pet_suvr_blocker` indicates 496 rows come from a release where ROI/segmentation/SUVR gate was not run in the same way, so release provenance must be preserved.

Interpretation: KDRC is promising for external SUVR/ranking validation, but not a trivial plug-in binary amyloid label dataset.

## Readiness verdict by training use

### T1w → PET-derived tabular endpoint

Ready in principle after v2 join.

Best current endpoints:

- ADNI/NACC centiloid and SUVR from broad pairing.
- OASIS centiloid/SUVR from dedicated OASIS manifests.
- KDRC SUVR/ranking from path-verified KDRC final gates.

Blocked work:

- Build a v2 final canonical PET-joined manifest.
- Verify v2 T1w final tensor path for each PET row.
- Recompute close-window matching with v2 session/date keys.

### T1w + PET image multimodal learning

Partly ready, not unified.

- OASIS580 has PET in T1w grid paths.
- Korean AJU/KDRC has registered PET in T1w grid paths.
- ADNI/NACC PET image paths were not validated in the inspected learning-ready way here; broad pairing mostly points to tabular PET sources.

Recommendation: do not pitch full PET-image multimodal training across all cohorts yet.

### PET as privileged teacher

Feasible if defined as PET-derived numeric supervision, not necessarily PET image teacher.

Recommended initial version:

- T1w input.
- Targets: amyloid status, Centiloid/SUVR, ordinal/ranking bins.
- PET images optional for OASIS/Korean ablation only.

## Practical conclusion

PET is not absent. The real issue is not existence, but whether endpoints are canonical, matched to v2 T1w, and semantically comparable across cohorts.

Safe next step:

1. Wait for v2 final tensor paths.
2. Build `official_v2_pet_joined_manifest.csv` with cohort-specific source columns.
3. Separate endpoint tiers:
   - Tier A: ADNI/NACC/OASIS quantitative centiloid/SUVR.
   - Tier B: KDRC SUVR/ranking external validation.
   - Tier C: AJU/KDRC binary amyloid only after label semantics/source verification.
   - Tier D: PET-image registered paths for OASIS/Korean only.
4. Run label/path/count validation before any GPU learning.
