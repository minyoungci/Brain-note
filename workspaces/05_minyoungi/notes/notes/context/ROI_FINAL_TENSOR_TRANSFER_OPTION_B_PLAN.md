# ROI Final-Tensor Transfer Plan — Option B

작성일: 2026-05-22  
상태: Min 승인 방침 반영 / 실행 전 audit plan  
범위: read-only audit 및 metadata discovery 우선. 대량 재생성/overwrite 없음.

## 0. Decision

Voxel-wise ROI supervision을 다시 열기 위한 경로는 **Option B**로 간다.

```text
기존 FastSurfer output은 유지한다.
FastSurfer aparc/aseg를 final_tensor grid로 정확히 transfer한다.
FastSurfer 입력을 final_tensor로 바꾸지 않는다.
```

이유:

```text
FastSurfer는 native/conformed T1 input contract에 맞춰 동작한다.
final_tensor는 z-score/skull-strip/crop/pad/RAS normalization이 적용된 student input이다.
final_tensor를 FastSurfer 입력으로 쓰면 segmentation model contract를 깨뜨릴 위험이 있다.
따라서 기존 FastSurfer output을 보존하고, transform provenance + transfer QC를 강화하는 것이 더 안전하다.
```

---

## 1. Target transfer chain

목표 chain:

```text
FastSurfer aparc/aseg
→ native / HD-BET grid candidate
→ same RAS / 1mm / crop-pad transform as final_tensor
→ final_tensor 192×224×192 grid
→ physical volume + overlap + centroid + visual QC
→ 승인된 ROI만 roi_final_ready=True
```

중요 원칙:

```text
image interpolation: linear/cubic 허용 가능
label mask interpolation: nearest-neighbor only
ROI label identity는 절대 fractional interpolation으로 만들지 않는다.
```

---

## 2. 현재 실패 원인 재정의

현재 voxel-wise ROI supervision이 막힌 이유는 전처리 전체 실패가 아니라:

```text
FastSurfer native/conformed segmentation space
↔ final_tensor 192×224×192 RAS student space
```

사이의 transform provenance가 불충분하거나, affine-only transfer가 실패했기 때문이다.

이미 확인된 실패:

```text
FastSurfer native ROI mask → final_tensor using stored NIfTI affines only
n_cases = 54
n_resampled_nonzero = 52
median_relative_volume_error = -0.892
p10/p90_relative_volume_error = -0.961 / -0.766
```

해석:

```text
median resampled ROI volume이 native ROI volume의 약 11%만 남음.
이 상태의 mask로 ROI crop/attention/loss를 걸면 잘못된 anatomy를 가르치게 된다.
```

---

## 3. Metadata discovery checklist

한 subject부터 다음 파일/metadata 존재 여부를 확인한다.

Example subject:

```text
/home/vlm/data/preprocessed_official/v2/ADNI/subjects/002_S_0413/20061115.0/t1w/
```

확인 대상:

```text
final_tensor/t1w_brain_1mm_RAS_192x224x192_zscore.nii.gz
final_tensor/brain_mask_1mm_RAS_192x224x192.nii.gz
native_t1w_hdbet.nii.gz
native_t1w_hdbet_bet.nii.gz
fastsurfer/<sid>/mri/orig.mgz
fastsurfer/<sid>/mri/orig_nu.mgz
fastsurfer/<sid>/mri/aparc.DKTatlas+aseg.deep.mgz
fastsurfer/<sid>/mri/aseg.auto_noCCseg.mgz
fastsurfer/<sid>/stats/aseg+DKT.VINN.stats
roi_masks/*.nii.gz
```

추가로 찾아야 하는 것:

```text
preprocessing command logs
crop offset / pad offset metadata
orientation transform metadata
resampling affine / target grid metadata
FastSurfer conformed-to-native transform
LTA / registration matrix / JSON sidecar / provenance files
```

---

## 4. Transfer reconstruction candidates

### Candidate B1. FastSurfer segmentation → orig/native T1 → final_tensor

```text
aparc.DKTatlas+aseg.deep.mgz
→ map from FastSurfer conformed space to orig/native T1 space
→ apply final_tensor preprocessing transform
→ final_tensor grid
```

Pros:

```text
uses full existing FastSurfer segmentation
preserves FastSurfer contract
```

Risk:

```text
requires conformed-to-native transform and final_tensor crop/pad metadata
```

### Candidate B2. Existing roi_masks → final_tensor exact transform

```text
roi_masks/*.nii.gz
→ identify their current grid/affine relative to native_t1w_hdbet
→ apply same final_tensor transform
→ final_tensor grid
```

Pros:

```text
may be closer to native/HD-BET grid already
less label extraction work
```

Risk:

```text
current roi_masks are BLOCKED_PROVISIONAL; their grid semantics must be audited first
```

### Candidate B3. Reconstruct final_tensor crop from image/mask geometry

```text
native_t1w_hdbet or native_t1w_hdbet_bet
→ infer RAS/1mm/crop-pad operation by matching final brain_mask
→ apply same operation to segmentation labels
```

Pros:

```text
possible even if explicit metadata is missing
```

Risk:

```text
inverse inference can be brittle; must be validated with overlap/centroid/visual QC
```

---

## 5. QC gates before `roi_final_ready=True`

A subject/ROI is approved only if all relevant gates pass.

### Gate Q1. Nonzero and volume retention

```text
resampled ROI nonzero = True
physical volume computed from final_tensor voxel size
relative volume error against source stats acceptable
```

Initial thresholds:

```text
large structures: abs(relative volume error) <= 0.10–0.20
small structures: use wider threshold, but no systematic collapse
```

### Gate Q2. Centroid consistency

```text
centroid source→target transformed location lands inside/near resampled ROI
left/right centroid ordering preserved
no systematic boundary/corner drift
```

### Gate Q3. Brain-mask overlap

```text
ROI voxels mostly inside final brain_mask
no major off-brain mask fragments
ventricle/cortex/subcortical ROIs anatomically plausible
```

### Gate Q4. Visual contact sheet

Minimum sample:

```text
6 cohorts × CN/MCI/AD × 3 samples where available
```

Required overlays:

```text
hippocampus
lateral ventricle
entorhinal/parahippocampal if available
whole DKT/subcortical label composite
```

### Gate Q5. Cohort-specific failure audit

```text
failure rate by cohort
relative volume error by cohort
centroid shift by cohort
left/right flip flags by cohort
```

No cohort should have hidden systematic transform failure.

---

## 6. Manifest policy

Do not globally set `roi_final_ready=True`.

Use staged approval:

```text
roi_final_ready = True only for subject/ROI pairs that pass Q1–Q5
roi_current_status = APPROVED_FINAL_TENSOR only after QC
seg_alignment_qc_status = PASS only with saved metrics + contact sheet evidence
```

For failed cases:

```text
roi_final_ready = False
roi_current_status = BLOCKED_PROVISIONAL or TRANSFER_QC_FAIL
record failure reason
```

No raw data or existing FastSurfer outputs are modified.

---

## 7. Execution order

```text
1. Metadata discovery on 3–5 subjects across different cohorts.
2. Identify available transform/provenance files.
3. Min adds a new Option-B transfer module under the preprocessing code path.
4. Sky verifies the code path, transform logic, interpolation mode, output contract, and QC metrics before any bulk run.
5. Run one-subject transfer reconstruction candidate only after code review.
6. Compute volume/centroid/brain-overlap metrics.
7. Generate one visual overlay sheet.
8. If one-subject pass, expand to 6 cohorts × 3 labels × 3 samples.
9. Only then consider final_tensor-space voxel-wise ROI supervision.
```

### Code-review handoff contract

When Min provides the preprocessing-code path, verify before execution:

```text
1. Does it preserve existing FastSurfer outputs and avoid rerunning FastSurfer on final_tensor?
2. Does it use the exact same RAS/1mm/crop-pad transform as final_tensor generation?
3. Does it resample label maps with nearest-neighbor only?
4. Does it preserve integer label IDs and left/right identity?
5. Does it write new outputs to a separate roi_final_tensor/ or QC staging directory, not overwrite raw/FastSurfer/final_tensor files?
6. Does it produce per-subject QC JSON with source volume, target physical volume, relative volume error, centroid shift, brain-mask overlap, and status?
7. Does it keep manifest update separate from transfer generation, so roi_final_ready=True is never set without QC approval?
8. Does it have a one-subject dry-run mode and a no-overwrite default?
```

---

## 8. 2026-05-22 6-cohort smoke result and full-candidate policy

Smoke report verified:

```text
/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_6cohort_smoke_20260522T033423Z/summary.json
/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_6cohort_smoke_20260522T033423Z/smoke_results.csv
```

Scope:

```text
6 cohorts × 3 samples = 18 cases
ADNI / AIBL / AJU / KDRC / NACC / OASIS
```

Verified summary:

```text
selected = 18
runs = 18
pass_run = 18
issue_count = 0
```

Numeric QC reported for Deep5 ROI:

```text
hippocampus
amygdala
thalamus
lateral_ventricle
parahippocampal_cortex
```

Observed:

```text
relative_volume_error max_abs = 0.0
inside_brain_frac mostly 1.0; parahippocampal_cortex sometimes ~0.995–0.999, above 0.98 threshold
centroid_shift_vox = 0 or numerical epsilon, max ~2e-14
```

One earlier failed smoke folder exists:

```text
/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_6cohort_smoke_20260522T033345Z/
```

Interpretation: failure was environment/runner issue (`nibabel` import due to wrong Python executable), not transform logic. Corrected successful run is the `033423Z` folder.

Policy for next step:

```text
CONDITIONAL GO:
  Apply Option B candidate/QC branch to full v2 rows.

Strict limits:
  generate candidate ROI + QC report only
  do not modify existing final_tensor files
  do not modify existing FastSurfer outputs
  do not modify canonical ready manifest
  do not set roi_final_ready=True
  do not enable voxel-wise ROI loss
```

Full-candidate outputs should be report/staging only:

```text
candidate_exists=True and numeric_qc_status may be recorded in a separate full QC report
roi_final_ready remains False in canonical manifest
roi_current_status remains BLOCKED_PROVISIONAL in canonical manifest until separate approval
```

Required after full-candidate generation:

```text
cohort-level failure audit
ROI-level issue table
overlay contact sheet sampling review
subject/ROI-pair readiness report
separate approval before any manifest status change
```

---

## 9. Expected impact if successful

If Option B succeeds, it unlocks:

```text
ROI-local feature pooling
segmentation auxiliary loss
ROI-aware masked reconstruction
anatomical region contrastive learning
image-to-ROI caption grounding
```

But success does not automatically solve CN/MCI/AD classification.

Primary expected benefit:

```text
stronger anatomical representation
```

Evaluation must still include:

```text
CN vs AD disease axis
MCI projection
age/anatomical prediction
cohort probe
```
