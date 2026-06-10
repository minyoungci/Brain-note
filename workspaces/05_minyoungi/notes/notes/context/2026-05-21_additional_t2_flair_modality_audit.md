# 2026-05-21 additional T2/FLAIR modality audit

Generated: 2026-05-21
Scope: read-only filename/path-level audit of additional MRI modalities, focused on T2/FLAIR availability by consortium and overlap with current v2 integrated T1w core manifest.

## Reference manifest

```text
/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
```

Core T1w subjects in current integrated manifest:

```text
ADNI: 1577
AIBL: 617
AJU: 955
KDRC: 920
NACC: 1140
OASIS: 749
```

## Bottom-line verdict

T2/FLAIR are **not yet balanced enough for a six-consortium common-core multimodal model**.

- Strongest immediately usable raw candidates:
  - **FLAIR:** AJU, KDRC, NACC; A4 also very strong but currently reserved outside core as external-validation candidate.
  - **T2:** KDRC and NACC; AJU has T2-like/GRE/`T2_FLAIR` series but needs stricter sequence taxonomy.
- Weak or absent for T2/FLAIR in current holdings scan:
  - **ADNI:** only one FLAIR-like raw directory found in the local raw mirror; T2 not found by bounded path scan.
  - **AIBL:** no FLAIR/T2 candidates found by filename/path scan.
  - **OASIS:** no FLAIR/T2 candidates found in current local OASIS raw tree by filename/path scan.

This means T2/FLAIR should be treated as a **subset/cohort-specific branch**, not as the next common modality for all six consortia.

## Counts by consortium

### ADNI

Bounded path scan under `/home/vlm/data/raw/ADNI`:

```text
FLAIR-like dirs: 1
FLAIR-like subjects: 1
T2-like dirs: 0
T2-like subjects: 0
example: /home/vlm/data/raw/ADNI/ADNI_3_4_T1w/ADNI/035_S_7030/Sagittal_3D_FLAIR_phase_A-P
```

Interpretation: not sufficient for ADNI as currently mirrored locally. Do not assume ADNI FLAIR is broadly available from this local raw tree.

### AIBL

Filename/path scan under `/home/vlm/data/raw/AIBL`:

```text
FLAIR candidates: 0
T2 candidates: 0
```

Interpretation: not usable for T2/FLAIR without a separate archive-level re-audit.

### AJU

Directory scan under `/home/vlm/data/raw/AJU/*/*/ABD-*/*/MRI/*`:

```text
FLAIR-like series dirs: 1306
FLAIR-like raw subjects: 1016
FLAIR-like subject-visits: 1305
FLAIR-like subjects overlapping current AJU core T1w subjects: 955 / 955

T2-like series dirs: 2014
T2-like raw subjects: 1016
T2-like subject-visits: 1305
T2-like subjects overlapping current AJU core T1w subjects: 955 / 955
examples:
/home/vlm/data/raw/AJU/2018/SS/ABD-SS-0053/V1/MRI/T2_FLAIR
/home/vlm/data/raw/AJU/2018/SS/ABD-SS-0034/V1/MRI/T2_FLAIR
/home/vlm/data/raw/AJU/2018/SS/ABD-SS-0058/V1/MRI/T2_FLAIR
```

Interpretation: AJU is strong for FLAIR/T2-like raw availability. Caveat: `T2` count includes `T2_FLAIR`; strict separation of pure T2 vs FLAIR vs GRE is required before modeling.

### KDRC

Raw NIfTI scan under `/home/vlm/data/raw/KDRC`:

```text
FLAIR NIfTI files: 1445
FLAIR subjects from filename: 946
FLAIR subjects overlapping current KDRC core T1w subjects: 918 / 920

T2 NIfTI files: 1330
T2 subjects from filename: 830
T2 subjects overlapping current KDRC core T1w subjects: 814 / 920
examples:
/home/vlm/data/raw/KDRC/KDRC_0513_extracted/cases/24145363/24145363_1_FLAIR.nii.gz
/home/vlm/data/raw/KDRC/KDRC_0513_extracted/cases/24145363/24145363_1_T2.nii.gz
```

Interpretation: KDRC is the cleanest T2/FLAIR candidate because files are already NIfTI-like and subject IDs match the v2 T1w core well.

### NACC

Zip filename scan under `/home/vlm/data/raw/NACC/MRI`:

```text
FLAIR zip files: 1997
FLAIR subjects from filename: 1552
FLAIR subjects overlapping current NACC core T1w subjects: 1076 / 1140

T2 zip files: 728
T2 subjects from filename: 454
T2 subjects overlapping current NACC core T1w subjects: 314 / 1140
examples:
/home/vlm/data/raw/NACC/MRI/SCAN_NACC115599_I11106227_FLAIR_ADNI4_1mm.zip
/home/vlm/data/raw/NACC/MRI/SCAN_NACC258926_I10377025_Sagittal_3D_T2_Cube__MSV21_.zip
```

Interpretation: NACC is strong for FLAIR, moderate for T2. But the data are ZIP/DICOM-derived candidates, so path validity, conversion, orientation, and exact session matching are unresolved.

### OASIS

Filename/path scan under `/home/vlm/data/raw/oasis3`:

```text
FLAIR candidates: 0
T2 candidates: 0
```

Interpretation: current local OASIS tree should not be counted as T2/FLAIR-capable. OASIS is useful for T1w/PET/DWI/fMRI-like branches, not this T2/FLAIR common-core branch.

### A4, outside current core

Raw NIfTI scan under `/home/vlm/data/raw/A4/ImageData`:

```text
T1 NIfTI files: 7133; subjects: 1787
FLAIR NIfTI files: 7096; subjects: 1785
DWI NIfTI files: 674; subjects: 168
T2 NIfTI files: 0; subjects: 0
```

Interpretation: A4 is excellent for future FLAIR external validation/domain transfer after preprocessing, but it is not part of the current six-consortium core manifest.

## Recommended use strategy

1. **Do not build a six-consortium T2/FLAIR common-core model yet.** ADNI/AIBL/OASIS would be near-empty locally, so the model would become a cohort shortcut machine.
2. **Best first branch:** KDRC + AJU + NACC FLAIR audit/preprocessing branch.
   - KDRC: easiest path-valid NIfTI start.
   - AJU: strong raw DICOM FLAIR/T2_FLAIR but conversion/QC needed.
   - NACC: strong FLAIR ZIP inventory but conversion and exact T1 session matching needed.
3. **T2 branch should be more conservative:** start with KDRC + NACC; treat AJU T2 only after strict series taxonomy separates pure T2 from T2-FLAIR/GRE.
4. **A4:** keep as external validation/domain generalization candidate for FLAIR, not training-core, until its preprocessing and labels are frozen.

## Remaining risks

- This is filename/path-level availability, not QC-pass availability.
- DICOM ZIP/series counts do not prove readable volumes, correct orientation, spacing, or T1 alignment.
- AJU `T2` count is intentionally broad and includes T2-FLAIR-like series; it needs sequence taxonomy cleanup.
- NACC zip filenames imply modality but still need archive-level conversion smoke tests.
- Cross-consortium multimodal missingness is highly non-random; using T2/FLAIR naively will encode cohort/site shortcuts.

## Next verification step

Create a read-only candidate manifest for **FLAIR only** with columns:

```text
cohort, subject_id, session_id_candidate, modality, raw_path, source_type,
series_desc, matched_t1w_row_id, matched_t1w_session_delta_days,
path_exists, needs_conversion, candidate_rank
```

Then run tiny smoke conversion/header checks per source type:

```text
KDRC: 10 NIfTI headers + affine/shape/spacing check
AJU: 10 DICOM series conversion smokes
NACC: 10 ZIP extraction/conversion smokes
A4: 10 NIfTI headers after external-validation policy confirmation
```
