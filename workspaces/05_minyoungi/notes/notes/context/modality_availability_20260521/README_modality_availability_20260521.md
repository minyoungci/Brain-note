# Consortium modality availability audit CSVs — 2026-05-21

Generated as a team-readable status table from current v2 integrated T1w manifest, PET report, and read-only raw filename/path audits.

## Files

- `consortium_modality_availability_long_20260521.csv`
  - One row per `cohort × modality`. Best for filtering/sorting.
- `consortium_modality_availability_wide_20260521.csv`
  - One row per cohort with status/count/subject/preprocessing columns per modality. Best for quick team overview.

## Important interpretation

- `YES_PREPROCESSED_CORE` = usable in the current official v2 T1w core manifest.
- `YES_PATH_VALID_NEEDS_REGISTRATION_QC` = image paths exist but still need registration/staticization/QC before scientific use.
- `YES_RAW_*` = raw candidates exist; not yet a QC-pass/preprocessed modeling pool.
- `LIMITED_LOCAL_RAW_ONLY` = present but too sparse for meaningful modeling.
- `NOT_FOUND_IN_LOCAL_SCAN` = not found in current local holdings scan; this is not a universal claim about the public dataset.
- `UNKNOWN/NOT_CONFIRMED` = do not use as evidence without a dedicated audit.

## Strong practical takeaway

- Common six-consortium modality ready now: **T1w only**.
- PET path-valid now: **KDRC, OASIS**, but still needs PET-specific registration/staticization/QC.
- FLAIR branch candidate: **AJU + KDRC + NACC**, with **A4 as external validation candidate**.
- T2 branch candidate: **KDRC + NACC**, optionally AJU after sequence taxonomy cleanup.
- Do **not** train a six-consortium T2/FLAIR common-core model yet; ADNI/AIBL/OASIS are near-empty for these modalities in the local scan.

## Source evidence

- Current integrated T1w manifest:
  `/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`
- PET pair/path-valid report:
  `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Preprocessing_20260512/reports/pet_t1w_pair_and_image_composition_by_consortium_20260512.csv`
- T2/FLAIR audit note:
  `/home/vlm/minyoungi/notes/context/2026-05-21_additional_t2_flair_modality_audit.md`
- Six-consortium modality status note:
  `/home/vlm/minyoungi/literature/notes/2026-05-18_six_consortium_modality_status.md`

## Caveat

Counts for non-T1w modalities are mostly raw candidate counts, not QC-pass counts. For DICOM/ZIP cohorts, counts do not prove readable volumes, correct orientation, spacing, or session-level T1 alignment.
