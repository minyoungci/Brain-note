# raw_manifest

Attaches `raw_*_path` columns to the canonical manifest so downstream code
always has a direct pointer to the unprocessed source file per modality.

## Columns added

| Column | Modality | Who has it |
|--------|----------|-----------|
| `raw_t1_path`    | T1w    | All 7 consortia |
| `raw_flair_path` | FLAIR  | KDRC, A4, OASIS, AJU, NACC |
| `raw_t2_path`    | T2     | KDRC, AJU, NACC |
| `raw_dwi_path`   | DWI    | KDRC, OASIS, AJU |
| `raw_pet_path`   | PET    | KDRC, AJU |

NaN = data not available in local raw store.

## Usage

```bash
# Dry-run (no save, just print coverage)
uv run python -m preprocessing.raw_manifest.build --dry-run

# Full run (saves manifest)
uv run python -m preprocessing.raw_manifest.build

# Full run + path existence check
uv run python -m preprocessing.raw_manifest.build --verify
```

## Pre-conditions

Run these **before** `build.py` for DICOM-based consortia:

```bash
uv run python -m preprocessing.dicom_to_nifti.aju   # AJU
uv run python -m preprocessing.dicom_to_nifti.adni  # ADNI
uv run python -m preprocessing.dicom_to_nifti.nacc  # NACC
```

## Resolver per consortium

| Consortium | Module | Strategy |
|------------|--------|----------|
| KDRC  | `resolvers/kdrc.py`  | Glob `{subj}_*/{subj}_1_{MOD}.nii.gz` |
| A4    | `resolvers/a4.py`    | `A4_MR_{MOD}_{bid}_{viscode_num}.nii.gz` |
| OASIS | `resolvers/oasis.py` | Glob session dir `{subj}_MR_{sess}/anat*/` |
| AIBL  | `resolvers/aibl.py`  | preprocessed_official `native_t1w_hdbet.nii.gz` |
| AJU   | `resolvers/aju.py`   | Post-conversion `nifti/{site}/{subj}/{visit}/{mod}/` |
| ADNI  | `resolvers/adni.py`  | Post-conversion `nifti/{subj}/{image_id}/t1/` |
| NACC  | `resolvers/nacc.py`  | Post-conversion `nifti/{nacc_id}/{image_id}/{mod}/` |

## Known gaps

- **AIBL T1**: skull-stripped (`native_t1w_hdbet.nii.gz`), not truly raw
- **NACC ses-1** (274 sessions): `session_id = "ses-1"` has no image-ID based path;
  requires a separate lookup table (TODO)
- **ADNI FLAIR/DWI**: not in local raw store (T1 only)
- **A4 DWI/PET**: not in local raw store
