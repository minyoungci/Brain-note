# 6개 컨소시엄 modality 현황 점검

Created UTC: `2026-05-18`
Scope: read-only audit of raw holdings and current official/preprocessed manifests.

## 결론

6개 컨소시엄 모두 현재 official T1w preprocessing manifest에는 **T1w 중심**으로 들어가 있다. 그러나 raw 보유 기준으로는 컨소시엄별로 PET, FLAIR, T2, DWI/DTI/fMRI 등 추가 modality가 존재한다.

가장 중요한 구분:

- **Raw 보유 기준:** 실제 `/home/vlm/data/raw/*` 아래 존재하는 파일/series.
- **Current official/preprocessed 기준:** official6/v1 QC-pass manifest에 들어가 실제 연구 파이프라인에서 정리된 것.
- **PET image path-valid 기준:** PET image가 실제 NIfTI path로 연결되어 header/QC/registration 후보로 올라온 것.

## Current official/preprocessed T1w status

Source: `/home/vlm/data/preprocessed_official/v2/manifests/official6_stage00_01/official6_stage00_raw_source_inventory.csv`

- ADNI: `7358` selected raw rows, `1756` subjects; selected series are MPRAGE/SPGR/T1w-like DICOM directories.
- OASIS: `2650` selected raw rows, `786` subjects; selected series `OASIS_T1w` NIfTI.
- NACC: `2158` selected raw rows, `1639` subjects; selected source `zip_filename_t1_candidate`.
- AIBL: `1297` selected raw rows, `692` subjects; selected MPRAGE DICOM zip series.
- AJU: `1293` selected raw rows, `1006` subjects; selected `MRI/3D_T1` DICOM directories.
- KDRC: `962` selected raw rows, `944` subjects; selected `KDRC_T1` NIfTI.

Source: `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/manifests/qc_pass_t1w_6683_clinical_merged_manifest_20260511.csv`

- ADNI QC-pass T1w: `2284` rows
- OASIS QC-pass T1w: `1293` rows
- AIBL QC-pass T1w: `991` rows
- NACC QC-pass T1w: `906` rows
- AJU QC-pass T1w: `657` rows
- KDRC QC-pass T1w: `552` rows

## PET status in current T1w-linked PET inventory

Source: `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Preprocessing_20260512/reports/pet_t1w_pair_and_image_composition_by_consortium_20260512.csv`

- ADNI:
  - QC-pass T1w rows/subjects: `2284` / `736`
  - prior PET source/clinical pair rows/subjects: `2132` / `593`
  - path-valid PET NIfTI rows/subjects: `0` / `0`
  - status: PET metadata/pairing exists, image path extraction/conversion still not path-valid in this report.

- AIBL:
  - QC-pass T1w rows/subjects: `991` / `618`
  - prior PET source/clinical pair rows/subjects: `984` / `611`
  - path-valid PET NIfTI rows/subjects: `0` / `0`
  - status: PET metadata exists, path-valid image not found in this report.

- AJU:
  - QC-pass T1w rows/subjects: `657` / `440`
  - prior PET source/clinical pair rows/subjects: `437` / `437`
  - path-valid PET NIfTI rows/subjects: `0` / `0`
  - status: raw PET DICOM exists; mapping/conversion needed.

- KDRC:
  - QC-pass T1w rows/subjects: `552` / `552`
  - prior PET source/clinical pair rows/subjects: `552` / `552`
  - path-valid PET NIfTI rows/subjects: `552` / `552`
  - header QC OK rows: `548`
  - static 3D candidates: `390`
  - dynamic 4D header OK: `158`
  - status: strongest path-valid PET image availability among Korean cohorts.

- NACC:
  - QC-pass T1w rows/subjects: `906` / `760`
  - prior PET source/clinical pair rows/subjects: `258` / `180`
  - path-valid PET NIfTI rows/subjects: `0` / `0`
  - status: clinical/commercial PET metadata exists; image extraction unresolved.

- OASIS:
  - QC-pass T1w rows/subjects: `1293` / `533`
  - prior PET source/clinical pair rows/subjects: `0` / `0`
  - path-valid PET NIfTI rows/subjects: `946` / `282`
  - header QC OK rows: `946`
  - static 3D candidates: `4`
  - dynamic 4D header OK: `942`
  - status: path-valid PET NIfTI exists, mostly 4D; staticization/registration needed.

## Raw holding modality scan

Important: raw file counts are filename/path-based approximations, not QC-pass counts. DICOM-heavy cohorts have huge file counts because each slice/frame is a file.

### ADNI raw

Root: `/home/vlm/data/raw/ADNI`

Observed modality families:

- T1w / MPRAGE / SPGR: present, very large DICOM/raw holdings.
- PET: present, very large PET holdings under ADNI PET roots, e.g. AV45/FDG-like resources.
- fMRI/rest BOLD: present in raw paths.
- FLAIR: present, at least ADNI3/4 FLAIR examples found.
- Metadata/tabular: present.

Current official use: T1w only selected for official6 T1 pipeline; PET metadata/pairing exists but path-valid PET NIfTI was `0` in the 20260512 report.

### AIBL raw

Root: `/home/vlm/data/raw/AIBL`

Observed modality families:

- T1w/MPRAGE: present mainly inside IDA zip archive, selected in official6.
- PET metadata: PIB/AV45 metadata CSVs present.
- Large imaging archive zip present.
- Direct path-valid PET NIfTI was not found in the 20260512 PET report.

Current official use: T1w/MPRAGE selected and QC-pass available; PET pairing metadata exists, image path-valid unresolved.

### AJU raw

Root: `/home/vlm/data/raw/AJU`

Observed modality families:

- T1w: `MRI/3D_T1` DICOM directories.
- PET: raw DICOM PET directories.
- FLAIR: `T2_FLAIR` DICOM directories.
- DTI/DWI: `DTI` PAR/REC/DICOM-like holdings.
- T2/GRE-like: present.
- fMRI/rest-like: present in raw folder names.
- Metadata/tabular: present.

Current official use: T1w selected for official6 and QC-pass T1w exists; PET clinical/source pairing exists but path-valid PET NIfTI was `0` in the 20260512 report.

### KDRC raw

Root: `/home/vlm/data/raw/KDRC`

Observed raw NIfTI modality counts:

- FLAIR: `1445` files, filename subject IDs about `946`
- PET: `1444` files, filename subject IDs about `946`
- T1w: `1443` files, filename subject IDs about `944`
- T2: `1330` files, filename subject IDs about `830`
- DTI: `1184` files, filename subject IDs about `693`
- metadata/tabular: small number of XLSX/JSON files

Current official use: official6 selected only `KDRC_T1` / `nifti_t1`; PET is separately linked and path-valid for 552 QC-pass T1w rows.

### NACC raw

Root: `/home/vlm/data/raw/NACC`

Observed modality families:

- T1w/MPRAGE zip series: present.
- FLAIR zip series: present.
- T2/T2*/Cube-like zip series: present.
- ASL/other imaging_unknown examples present.
- PET metadata CSVs: present; image-level PET extraction unresolved in current report.
- Clinical/MRI/PET QC metadata and PDFs: present.

Current official use: T1 candidate zip archives selected and QC-pass T1w exists; PET metadata/pairing exists but path-valid PET NIfTI was `0` in the 20260512 report.

### OASIS raw

Root: `/home/vlm/data/raw/oasis3`

Observed modality families:

- T1w: BIDS/NIfTI T1w present.
- DWI/DTI: BIDS DWI directory present.
- PET: `pet_bids_v7_exact_pet_only` and amyloid/centiloid CSV present.
- fMRI/BOLD: raw fMRI/NIfTI examples present.
- Metadata/tabular: OASIS metadata and BIDS JSONs present.

Current official use: T1w selected and QC-pass T1w exists; PET has path-valid NIfTI for `946` rows / `282` subjects, mostly dynamic 4D.

## Practical summary for modeling

- If we mean **current clean T1w baseline pool**: all 6 consortia are available as T1w in the official/QC-pass pipeline.
- If we mean **PET image-ready paired with QC-pass T1w**: KDRC and OASIS are currently path-valid; ADNI/AIBL/AJU/NACC need conversion/path-link work despite metadata/pairing.
- If we mean **raw multimodal potential**:
  - ADNI: T1w + PET + FLAIR + fMRI/rest and rich metadata.
  - AIBL: T1w archive + PET metadata, image extraction needs audit.
  - AJU: T1w + PET + FLAIR + DTI/DWI + T2/GRE + fMRI-like raw holdings.
  - KDRC: T1w + PET + FLAIR + T2 + DTI as NIfTI.
  - NACC: T1w + FLAIR + T2/T2*/ASL-like MRI, PET metadata; PET images unresolved.
  - OASIS: T1w + PET + DWI + fMRI/BOLD + metadata.

## Caution

This is a holdings/status audit, not a guarantee that non-T1w modalities are aligned, QC-pass, label-matched, or usable for training. For non-T1w modalities, next step should be per-cohort path validity + header/QC + subject/session matching audit.
