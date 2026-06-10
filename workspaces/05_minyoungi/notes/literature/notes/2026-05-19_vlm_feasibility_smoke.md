# VLM/MLLM 연구 가능성 smoke check

Created UTC: `2026-05-19`
Workspace: `/home/vlm/minyoungi`
Scope: read-only feasibility check. No training launched. No raw/shared data mutated.

## Bottom line

현재 데이터 상태로 **작은 VLM/structured-caption representation smoke experiment는 가능**하다. 다만 바로 full VLM training으로 가면 안 되고, 먼저 `caption/text-only`, `clinical-only`, `ROI-only`, `image-only` baseline과 leakage audit을 통과해야 한다.

## Evidence inspected

### 1. V7 canonical inventory

Source: `/home/vlm/data/metadata/reingest_minyoung4/experiment_manifest_v7.csv`

Observed:

- Rows: `10,834`
- CN/MCI/AD + `is_classifiable=True`: `10,806`
- Dataset counts in classifiable rows:
  - ADNI: `5,037`
  - NACC: `1,876`
  - OASIS: `1,615`
  - AJU: `1,287`
  - AIBL: `991`
- Non-missing in classifiable rows:
  - age: `10,632`
  - sex: `10,806`
  - cdr_global: `10,349`
  - cdrsb: `9,607`
  - scanner: `10,389`
  - field_strength: `10,520`
- Manifest flags:
  - has_t1w: all classifiable rows non-missing / true in inspected summary
  - has_seg: all classifiable rows non-missing / true in inspected summary
  - has_mask: all classifiable rows non-missing / true in inspected summary

Interpretation:

- This is enough for structured clinical-language captions at inventory level.
- But V7 has only flags, not actual path columns, so training should not start directly from V7 alone.

### 2. Official v1 QC-pass T1w manifest with actual image/mask/ROI paths

Source: `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/manifests/qc_pass_t1w_6683_clinical_merged_manifest_20260511.csv`

Observed:

- Rows: `6,683`
- Consortium counts:
  - ADNI: `2,284`
  - OASIS: `1,293`
  - AIBL: `991`
  - NACC: `906`
  - AJU: `657`
  - KDRC: `552`
- Direct path-existence sample checks:
  - `final_tensor_path`: 20/20 existed
  - `final_mask_path`: 20/20 existed
  - `roi_final_tensor_grid_dir`: 20/20 existed
  - `roi_mask_dir`: 20/20 existed
- ROI directory sample includes anatomically relevant masks:
  - `amygdala.nii.gz`
  - `entorhinal_cortex.nii.gz`
  - `hippocampus.nii.gz` likely present beyond first 8 sample entries, but not explicitly counted in this smoke
  - `cerebral_cortex.nii.gz`
  - `cerebral_white_matter.nii.gz`
  - `accumbens.nii.gz`, `caudate.nii.gz`, etc.

NIfTI header smoke:

- Example path: `/home/vlm/data/preprocessed_official/v1/ADNI/subjects/002_S_0413/20061115/t1w/final_tensor/t1w_brain_1mm_RAS_192x224x192_zscore.nii.gz`
- Header parsed successfully without nibabel.
- Shape: `192 x 224 x 192`
- Datatype: NIfTI datatype `16` = float32
- Voxel size: `1 x 1 x 1 mm`
- sform_code: `2`

Interpretation:

- Actual image + mask + ROI path basis exists for a VLM/data-loader smoke.
- v1 QC-pass is currently the easiest path-valid basis for fast feasibility testing.

### 3. Official v2 stage02 manifests

Sources inspected:

- `/home/vlm/data/preprocessed_official/v2/ADNI/manifests/adni_official_v2_stage02_validated_nifti_manifest_5037.csv`
- `/home/vlm/data/preprocessed_official/v2/OASIS/manifests/oasis_official_v2_stage02_validated_nifti_manifest_1615.csv`
- `/home/vlm/data/preprocessed_official/v2/NACC/manifests/nacc_official_v2_stage02_validated_nifti_manifest_1876.csv`
- `/home/vlm/data/preprocessed_official/v2/AJU/manifests/aju_official_v2_stage02_validated_nifti_manifest_1287.csv`
- `/home/vlm/data/preprocessed_official/v2/AIBL/manifests/aibl_official_v2_stage02_validated_nifti_manifest_991.csv`
- `/home/vlm/data/preprocessed_official/v2/KDRC/manifests/kdrc_official_v2_stage02_validated_nifti_manifest_944.csv`

Observed row counts:

- ADNI: `5,037`
- OASIS: `1,615`
- NACC: `1,876`
- AJU: `1,287`
- AIBL: `991`
- KDRC: `944`

Path sample checks:

- `input_path`/`raw_t1_path`/`source_path` samples existed for all inspected cohorts.
- These stage02 manifests have no PET/amyloid/Centiloid/SUVR columns in the inspected column list.

Interpretation:

- v2 is excellent as a T1w source inventory / preprocessing basis.
- v2 is **not yet** a PET-learning or VLM endpoint manifest by itself. PET/clinical/ROI-ready joins must be constructed explicitly.

### 4. PET image availability summary

Source: `/home/vlm/data/preprocessed_official/v1/QC_Pass_T1w/PET_Preprocessing_20260512/reports/pet_t1w_pair_and_image_composition_by_consortium_20260512.csv`

Observed:

- 6-row consortium-level summary exists.
- PET image path-valid status remains cohort-dependent.
- Prior notes indicate KDRC/OASIS are the most path-valid PET-image candidates, while ADNI/AIBL/AJU/NACC need additional PET path/conversion work despite metadata/pairing.

Interpretation:

- PET should be treated as privileged endpoint/validation subset, not assumed available for all T1w rows.

## Caption smoke

A leakage-controlled non-PET caption can be generated from available fields, e.g.:

```text
A 76.95-year-old F participant from ADNI; T1-weighted brain MRI available; CDR global 0.0, CDR-SB 0.0; scanner PHILIPS, field strength 3.0.
```

But this exact caption is **not safe for every downstream task**:

- If predicting diagnosis, remove diagnosis from captions.
- If predicting CDR/CDR-SB, remove CDR/CDR-SB from captions.
- If predicting PET/amyloid, remove PET/amyloid fields from captions.
- Cohort/scanner should usually be metadata for audit/baseline, not training text, unless deliberately testing shortcut behavior.

## Environment smoke

Current Hermes Python environment:

- `torch`: available, version `2.9.1+cu130`
- CUDA visible: yes, `8` devices
- Missing in this environment:
  - `nibabel`
  - `SimpleITK`
  - `torchio`
  - `monai`
  - `transformers`
  - `sklearn`

Interpretation:

- A true image/VLM training smoke needs a project environment or minimal dependency install.
- No GPU training was launched in this smoke.

## Feasibility verdict

### 가능

1. **Structured-caption VLM dataset construction**
   - feasible from V7/v1/v2 clinical + scanner + image metadata.

2. **Image + ROI mask + text smoke**
   - feasible from v1 QC-pass paths because final tensor, brain mask, and ROI directories exist.

3. **Official v2 T1w-backed VLM direction**
   - feasible as a T1w source basis, but needs explicit joins to clinical/PET/ROI-ready outputs.

4. **PET/ATN-aware representation**
   - feasible only as a matched-subset/privileged-endpoint task, not all-row PET multimodal training.

### 아직 불가 / 위험

1. **바로 “large VLM” claim**
   - data size is domain-useful, not foundation-scale.

2. **Radiology-report VLM claim**
   - most rows do not have genuine free-text radiology reports.

3. **PET-image multimodal across all six cohorts**
   - not supported by current path-valid evidence.

4. **Diagnosis-caption → diagnosis prediction**
   - trivial leakage unless task-specific forbidden text fields are enforced.

## Reviewer objection to expect

> “Your language supervision is generated from structured labels and covariates, so the model may be learning diagnosis/age/scanner/cohort shortcuts rather than visual disease biology.”

This objection is strong. The first experiment must therefore include:

- text-only baseline
- clinical-only baseline
- cohort/scanner-only baseline
- ROI-only baseline
- image-only baseline
- image+ROI+text model
- subject-level split
- held-out cohort split if possible
- task-specific forbidden-caption-field contract

## Practical next experiment

Do **not** start with a full 3D VLM. Start with a tiny bounded artifact:

1. Build a small canonical VLM smoke manifest from v1 QC-pass rows:
   - columns: subject/session, consortium, diagnosis, age/sex/CDR, `final_tensor_path`, `final_mask_path`, ROI directory, allowed captions.
2. Generate 3–4 caption variants per row with forbidden-field rules.
3. Run text-only / clinical-only shortcut baselines first.
4. Run CPU dataset loader smoke that reads image header and ROI mask paths.
5. Only after that, run a tiny GPU smoke with either:
   - 2.5D slice encoder + PubMed/BioClinical text encoder, or
   - small 3D CNN encoder + simple text encoder.

Scientific interpretation limit:

- Passing this smoke means **implementation feasibility**, not research success.
- The first real claim gate is whether image/ROI/text representation beats shortcut baselines under cohort-held-out evaluation.
