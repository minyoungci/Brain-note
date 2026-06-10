# dicom_to_nifti

DICOM → NIfTI conversion layer. Must run before `raw_manifest/build.py` for the
three consortia that store raw data as DICOM.

## When to run

| Consortium | Raw format | Converter | Run? |
|------------|-----------|-----------|------|
| AJU  | DICOM dirs | `aju.py`  | **Required** |
| ADNI | DICOM dirs | `adni.py` | **Required** |
| NACC | DICOM zips | `nacc.py` | **Required** |
| KDRC | NIfTI already | — | skip |
| A4   | NIfTI already | — | skip |
| OASIS| NIfTI already | — | skip |
| AIBL | Uses preprocessed_official | — | skip |

## Tool

`dcm2niix` v1.0.20250505 at `/home/jovyan/.local/bin/dcm2niix`

## Usage

```bash
# AJU (large batch, run overnight)
uv run python -m preprocessing.dicom_to_nifti.aju

# ADNI
uv run python -m preprocessing.dicom_to_nifti.adni

# NACC
uv run python -m preprocessing.dicom_to_nifti.nacc
```

All converters are idempotent (skip already-converted sessions by default).
Use `run_all(force=True)` to re-convert.

## Output paths

**AJU:**
```
/home/vlm/data/raw/AJU/nifti/{site}/{subject_id}/{visit}/{modality}/
    {subject_id}_{visit}_{modality}.nii.gz
```
- Modalities: `t1` (3D_T1), `flair` (T2_FLAIR), `t2` (T2_FSE), `dwi` (DTI/DWI), `pet`
- fMRI, ASL, ADC, MRA, SWI are excluded

**ADNI:**
```
/home/vlm/data/raw/ADNI/nifti/{subject_id}/{image_id}/t1/
    {subject_id}_{image_id}_t1.nii.gz
```
- T1 only; session matched via `adni_t1w_dicom_list.csv`
- Multiple scans on same day → highest slice count wins

**NACC:**
```
/home/vlm/data/raw/NACC/MRI/nifti/{nacc_id}/{image_id}/{modality}/
    {nacc_id}_{image_id}_{modality}.nii.gz
```
- Modalities: `t1`, `flair`, `t2`
- `ses-1` sessions (274 rows) need a separate lookup; currently unresolved
