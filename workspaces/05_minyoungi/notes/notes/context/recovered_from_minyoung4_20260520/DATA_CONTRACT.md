# Stage 0 DATA_CONTRACT — v2 Brain MRI / Amyloid-Aware Manifest Builder Spec

Updated: 2026-05-20
Workspace: `/home/vlm/minyoungi`
Status: **Stage 0 builder specification, not final experimental evidence**

이 문서는 `build_eligible_manifest.py` 계열 manifest builder가 따라야 할 데이터 계약이다. 목적은 좋은 결과를 보장하는 것이 아니라, **데이터 누수, 라벨 시점 불일치, 코호트별 biomarker semantics 혼합, reviewer-risk를 명시적으로 제어**하는 것이다.

## 0. Scope and non-goals

### Scope

- v2 full-preprocessed T1w image-ready cohort 정의
- subject/visit scoped key 정의
- subject-disjoint split 강제 규칙
- Phase A/B/C별 eligible/pending/excluded 규칙
- ADNI Centiloid primary amyloid anchor join 규칙
- KDRC SUVR proxy 격리 규칙
- AIBL/AJU/NACC amyloid pending/exclusion 규칙
- builder output column contract

### Non-goals

- 이 문서는 모델 성능, novelty, clinical utility를 증명하지 않는다.
- 이 문서는 ADNI Centiloid가 MRI representation에 encode된다는 증거가 아니다.
- 이 문서는 KDRC SUVR와 ADNI Centiloid가 같은 scale이라고 가정하지 않는다.
- 이 문서는 AIBL/AJU/NACC의 amyloid labels를 확정하지 않는다.
- 이 workspace는 설계/context 기록용이다. 대규모 실험/모델링은 별도 승인된 workspace에서 수행한다.

## 1. Verified source files

### v2 image-ready manifests

- ADNI: `/home/vlm/data/preprocessed_official/v2/ADNI/manifests/adni_t1w_full_preprocessed_ready_manifest_5037.csv`
- AIBL: `/home/vlm/data/preprocessed_official/v2/AIBL/manifests/aibl_t1w_full_preprocessed_ready_manifest_991.csv`
- AJU: `/home/vlm/data/preprocessed_official/v2/AJU/manifests/aju_t1w_full_preprocessed_ready_manifest_1287.csv`
- KDRC: `/home/vlm/data/preprocessed_official/v2/KDRC/manifests/kdrc_t1w_full_preprocessed_ready_manifest_944.csv`
- NACC: `/home/vlm/data/preprocessed_official/v2/NACC/manifests/nacc_t1w_full_preprocessed_ready_manifest_1876.csv`

### Amyloid / PET sources inspected

- ADNI PET quantitative source: `/home/vlm/data/raw/ADNI/PET/UCBERKELEY_AMY_6MM_30Mar2026.csv`
- AIBL PET metadata sources:
  - `/home/vlm/data/raw/AIBL/meta/aibl_pibmeta_01-Jun-2018.csv`
  - `/home/vlm/data/raw/AIBL/meta/aibl_av45meta_01-Jun-2018.csv`
  - `/home/vlm/data/raw/AIBL/meta/aibl_flutemeta_01-Jun-2018.csv`
- KDRC SUVR proxy source: `/home/vlm/data/preprocessed_official/v1/KDRC/manifests/kdrc_unified_suvr_final_gate_DEDUP_SUBJECT_PATHVERIFIED_20260515.csv`
- AJU/KDRC source-preserving clinical: `/home/vlm/data/preprocessed_official/v1/Korean Dataset/clinical/korean_dataset_aju_kdrc_full_clinical_source_preserving_manifest_20260513.csv`
- NACC session labels: `/home/vlm/data/metadata/reingest_minyoung4/nacc_session_labels.csv`
- NACC session metadata: `/home/vlm/data/metadata/reingest_minyoung4/nacc_session_metadata.csv`
- NACC legacy candidate table: `/home/vlm/data/metadata/final_3841/nacc_final_v2_3841.csv`

## 2. Phase A image base contract

### Included cohorts

Use v2 full-ready T1w image manifests from:

- `ADNI`
- `AIBL`
- `AJU`
- `KDRC`
- `NACC`

OASIS is explicitly excluded from the v2 full-ready image base because only stage02-like validated NIfTI was found, not final full-preprocessed 192x224x192 tensor manifest.

### Hard usable gate

A row is image-usable only if:

```python
(final_qc_status == "PASS") and (t1w_image_ready == True)
```

The builder must also assert:

- `final_tensor_path` is non-null
- `final_tensor_path` exists on filesystem
- loaded NIfTI/image header shape equals `(192, 224, 192)` for sampled or full validation mode
- voxel spacing is compatible with the v2 1mm contract when checked

### Verified usable image counts

Counts below are v2 rows satisfying `final_qc_status == PASS` and `t1w_image_ready == True`.

- ADNI: 5,023 rows
- AIBL: 988 rows
- AJU: 1,287 rows
- KDRC: 931 rows
- NACC: 1,867 rows
- Total: 10,096 rows

These counts are **data inventory facts**, not evidence of downstream performance.

## 3. Scoped keys and leakage prevention

### Required keys

The builder must create:

```text
subject_key = consortium + "::" + subject_id
visit_key   = consortium + "::" + subject_id + "::" + session_id
```

Rationale:

- `subject_id` alone is not a globally safe namespace.
- Multi-visit subjects must not be split across train/val/test.
- All downstream splits must operate at `subject_key` level, not row level.

### Required split assertion

For every downstream manifest:

```python
assert set(train_subject_keys).isdisjoint(val_subject_keys)
assert set(train_subject_keys).isdisjoint(test_subject_keys)
assert set(val_subject_keys).isdisjoint(test_subject_keys)
```

The builder must write or print split-intersection counts. Any nonzero intersection is a hard failure.

### Multi-visit reviewer risk

Observed multi-visit burden is nontrivial, especially ADNI/AIBL/NACC. Row-level random split is therefore forbidden.

- ADNI: 5,023 usable rows / 1,751 subjects / max 16 visits
- AIBL: 988 usable rows / 617 subjects / max 5 visits
- AJU: 1,287 usable rows / 1,001 subjects / max 2 visits
- KDRC: 931 usable rows / 931 subjects / max 1 visit
- NACC: 1,867 usable rows / 1,415 subjects / max 4 visits

## 4. Phase B clinical diagnosis/CDR contract

Phase B may use the five image-ready cohorts as candidates for diagnosis/CDR tasks, subject to label availability and date alignment checks.

Required output columns for clinical labels when available:

- `diagnosis`
- `cdr_global`
- `cdrsb`
- `clinical_label_source`
- `clinical_join_mode`
- `clinical_gap_days`
- `clinical_primary_eligible`

NACC requires special handling because exact session label coverage is incomplete.

### NACC clinical join rule

Observed NACC facts:

- v2 usable image rows: 1,867
- v2 usable subjects: 1,415
- exact `subject_id + session_id` label join: 828 / 1,867 rows
- subject-level label coverage: 1,415 / 1,415 subjects

Builder rule:

1. Try exact `subject_id + session_id` join.
2. If exact join fails, use same-subject nearest date fallback when dates are available.
3. Primary eligible: `abs(clinical_gap_days) <= 365`.
4. Sensitivity only: `365 < abs(clinical_gap_days) <= 730`.
5. Exclude from primary clinical supervised analysis if gap is missing or `> 730`.

Required flags:

- `nacc_label_join_mode`: `exact_session`, `nearest_date`, `subject_only`, `unmatched`
- `nacc_label_gap_days`
- `nacc_label_primary_eligible`
- `nacc_label_sensitivity_eligible`

## 5. Phase C amyloid target contract

Phase C must not assume a single universal amyloid target across cohorts unless scale equivalence is established. Current contract uses one confirmed quantitative anchor plus one provisional proxy branch.

### 5.1 ADNI Centiloid primary anchor

Source:

`/home/vlm/data/raw/ADNI/PET/UCBERKELEY_AMY_6MM_30Mar2026.csv`

Verified relevant columns:

- `PTID`
- `SCANDATE`
- `TRACER`
- `TRACER_SUVR_WARNING`
- `CENTILOIDS`
- `SUMMARY_SUVR`
- `AMYLOID_STATUS`
- `AMYLOID_STATUS_COMPOSITE_REF`
- `qc_flag`
- `LONIUID`

Join rule:

1. Use v2 ADNI image rows passing image usable gate.
2. Parse MRI date from image manifest `session_id` when it is date-like.
3. Match PET candidates by `subject_id == PTID`.
4. Select nearest PET by minimal `abs(MRI_date - SCANDATE)`.
5. Record all gap and tracer information.

Primary eligibility:

```python
adni_centiloid_primary = (
    image_usable
    and pet_matched
    and CENTILOIDS is numeric
    and AMYLOID_STATUS is not missing
    and abs(gap_days) <= 365
)
```

Sensitivity eligibility:

```python
adni_centiloid_sensitivity = (
    image_usable
    and pet_matched
    and CENTILOIDS is numeric
    and 365 < abs(gap_days) <= 730
)
```

Verified read-only audit facts:

- v2 usable ADNI rows: 5,023
- nearest PET matched rows: 4,552
- `abs(gap_days) <= 365`: 3,886 rows
- Centiloid non-null rows among matched: 4,550
- Summary SUVR non-null rows among matched: 4,550
- Amyloid status non-null rows among matched: 4,486
- tracer distribution among nearest PET matches:
  - FBP: 3,365
  - FBB: 1,123
  - NAV: 64
  - no PET match: 471

Interpretation guardrail:

- Across-tracer quantitative comparison should use `CENTILOIDS`, not raw `SUMMARY_SUVR`.
- `SUMMARY_SUVR` may be retained as a secondary/tracer-stratified variable, not as the global master scale.
- `qc_flag`, `AMYLOID_STATUS`, and `AMYLOID_STATUS_COMPOSITE_REF` code meanings still require codebook confirmation before final paper claims.

Required output columns:

- `adni_pet_matched`
- `adni_pet_date`
- `adni_pet_gap_days`
- `adni_pet_tracer`
- `adni_pet_centiloids`
- `adni_pet_summary_suvr`
- `adni_pet_amyloid_status`
- `adni_pet_qc_flag`
- `adni_centiloid_primary_eligible`
- `adni_centiloid_sensitivity_eligible`

### 5.2 KDRC SUVR proxy branch

Source:

`/home/vlm/data/preprocessed_official/v1/KDRC/manifests/kdrc_unified_suvr_final_gate_DEDUP_SUBJECT_PATHVERIFIED_20260515.csv`

Relevant columns:

- `subject_id`
- `session_id`
- `pet_date`
- `pet_image_t1w_abs_days`
- `pet_tracer`
- `clinical_pet_summary_suvr`
- `suvr_mean`
- `suvr_median`
- `reference_region`
- `target_roi`
- `pet_suvr_qc_pass`
- `pet_suvr_final_ready`
- `pet_suvr_final_ready_caveat`

Verified caveats:

- tracer is currently `amyloid_unknown` where populated.
- reference region observed: `cerebellum_cortex_aseg_8_47`.
- target ROI observed: `thalamus`.
- caveat indicates no radiologist/manual biological validation and tracer-aware downstream requirement.

Contract:

- Do not name this variable `M_i` or a global amyloid burden.
- Use explicit variable name: `kdrc_suvr_proxy`.
- Report KDRC proxy performance separately from ADNI Centiloid performance.
- Do not pool KDRC SUVR regression metrics with ADNI Centiloid metrics.

Primary eligibility should require:

```python
kdrc_suvr_proxy_primary = (
    image_usable
    and pet_suvr_final_ready == True
    and pet_suvr_qc_pass == True
    and kdrc_suvr_proxy is numeric
)
```

Builder should prefer an explicitly chosen proxy column and record which was used:

- `suvr_mean`
- `suvr_median`
- `clinical_pet_summary_suvr`

Until a stronger reason is documented, use `suvr_mean` as the default computational proxy and retain the other values for audit.

Required output columns:

- `kdrc_suvr_proxy`
- `kdrc_suvr_proxy_source_column`
- `kdrc_suvr_mean`
- `kdrc_suvr_median`
- `kdrc_clinical_pet_summary_suvr`
- `kdrc_pet_tracer`
- `kdrc_reference_region`
- `kdrc_target_roi`
- `kdrc_pet_gap_days`
- `kdrc_suvr_proxy_primary_eligible`

### 5.3 AIBL amyloid status

Current status: **not eligible yet for Phase C amyloid loss**.

Verified facts:

- v2 usable AIBL rows: 988
- PET metadata date/tracer match exists for 981 rows by nearest-date logic
- `abs(gap_days) <= 365`: 924 rows
- observed tracer sources: PIB, FLUTE, AV45
- currently inspected AIBL files expose PET dates/tracers but not Centiloid, SUVR, or amyloid positive/negative status values.

Contract:

```python
aibl_amyloid_eligible = False
```

Do not activate amyloid loss for AIBL unless a quantitative or binary amyloid table is found and audited.

Required pending flag:

- `aibl_amyloid_status = "metadata_only_no_quant_or_status_target_found"`

### 5.4 AJU amyloid status

Current status: **pending codebook confirmation**.

Observed candidate columns:

- `aju_raw__Amy_test`
- `aju_raw__Amy_opi`

Observed values are code-like 1/2, not clean 0/1 binary labels. Code semantics are not confirmed.

Contract:

```python
aju_amyloid_eligible = False
```

Do not activate amyloid loss for AJU until codebook confirms:

- whether `Amy_opi=1` means positive or negative
- whether `Amy_opi=2` is the opposite class or another state
- whether `Amy_test=2` means not-tested/missing/other
- whether this is PET visual read or another amyloid test proxy

Required pending flag:

- `aju_amyloid_status = "unmapped_until_codebook_confirmed"`

### 5.5 NACC amyloid status

Current status: **pending codebook and quantitative table confirmation**.

Observed candidate fields in inspected legacy/source tables:

- `AMYLPET`
- `AMYLCSF`
- `NACCAMY`
- `NPATGAMY`

No confirmed Centiloid/SUVR variable was found in inspected NACC files.

Contract:

```python
nacc_amyloid_eligible = False
```

Do not activate amyloid loss for NACC until:

- `AMYLPET` code semantics are confirmed by NACC codebook, or
- a GAAIN/NACC quantitative amyloid table with date alignment is found and audited.

Required pending flag:

- `nacc_amyloid_status = "status_code_only_no_confirmed_centiloid"`

## 6. Loss-function dependency contract

The current data contract supports only the following Phase C losses:

```text
L_total =
  L_ssl
  + λ_dx L_diagnosis
  + λ_cdr L_cdr
  + λ_adni I[ADNI_centiloid_primary] L_centiloid_adni
  + λ_kdrc I[KDRC_suvr_proxy_primary] L_suvr_proxy_kdrc
```

Interpretation constraints:

- `L_centiloid_adni` is the only currently confirmed quantitative master-anchor loss.
- `L_suvr_proxy_kdrc` is a cohort-specific local proxy loss.
- ADNI and KDRC Phase C metrics must be reported separately.
- AIBL/AJU/NACC amyloid losses must remain inactive until their target semantics are confirmed.
- Do not claim generalized amyloid representation without ablation and external validation evidence.

## 7. Required manifest outputs

A Stage 0 builder should produce separate artifacts, not one overloaded table.

### 7.1 `stage0_image_base_manifest.csv`

Required columns:

- `consortium`
- `subject_id`
- `session_id`
- `subject_key`
- `visit_key`
- `final_tensor_path`
- `final_mask_path`
- `final_shape`
- `final_qc_status`
- `fs_qc_status`
- `t1w_image_ready`
- `image_usable`
- `path_exists`
- `shape_verified`

### 7.2 `stage0_clinical_manifest.csv`

Required columns:

- all image base keys
- `diagnosis`
- `cdr_global`
- `cdrsb`
- `clinical_label_source`
- `clinical_join_mode`
- `clinical_gap_days`
- `clinical_primary_eligible`
- `clinical_sensitivity_eligible`

### 7.3 `stage0_amyloid_manifest.csv`

Required columns:

- all image base keys
- `amyloid_contract_status`
- ADNI fields listed in section 5.1
- KDRC fields listed in section 5.2
- AIBL/AJU/NACC pending flags listed in sections 5.3–5.5
- `phase_c_loss_name`
- `phase_c_primary_eligible`
- `phase_c_sensitivity_eligible`

### 7.4 `stage0_split_manifest.csv`

Required columns:

- `subject_key`
- `consortium`
- `split_name`
- `split_role`: train / val / test / external_test / sensitivity
- `split_seed`
- `split_policy`

Every split artifact must include a validation summary showing zero subject-key intersections.

## 8. Validation checklist for builder

Before accepting builder outputs, run the cheapest checks first:

1. Input files exist.
2. Required columns exist.
3. Row counts by cohort match expected v2 usable counts or deviations are explained.
4. `subject_key` and `visit_key` are non-null.
5. `visit_key` is unique within image base or duplicates are explicitly reported.
6. `final_tensor_path` exists for all `image_usable=True` rows.
7. Sampled NIfTI shape check confirms `(192, 224, 192)`.
8. ADNI nearest PET join preserves `PTID`, `SCANDATE`, `TRACER`, `CENTILOIDS`, `AMYLOID_STATUS`.
9. ADNI primary/sensitivity counts are reported.
10. KDRC proxy values are numeric only where proxy eligible.
11. AIBL/AJU/NACC amyloid losses remain inactive by default.
12. Train/val/test subject intersections are zero.
13. Builder prints or writes a compact JSON/YAML validation report.

## 9. Open risks and unresolved assumptions

### ADNI

- `qc_flag`, `AMYLOID_STATUS`, and `AMYLOID_STATUS_COMPOSITE_REF` require codebook confirmation before final paper wording.
- Long MRI-PET gaps exist; primary analysis should use `<=365d`, while larger gaps should be sensitivity or excluded.
- Diagnosis severity, age, site, and tracer can confound apparent amyloid predictability from MRI.

### KDRC

- SUVR proxy is not equivalent to ADNI Centiloid.
- Tracer is unknown in current source.
- Manual/radiologist biological validation is not confirmed.

### AIBL

- PET dates/tracers are available, but quantitative/status target values were not found in inspected files.
- Hidden quantification files may exist elsewhere and require separate audit.

### AJU

- `Amy_opi` 1/2 code semantics are not confirmed.
- Must not map to positive/negative without codebook evidence.

### NACC

- Exact session clinical join is incomplete; date fallback must be auditable.
- `AMYLPET` is a code candidate, not a confirmed binary target yet.
- No confirmed Centiloid/SUVR field found in inspected files.

## 10. Builder implementation note

Do not place uncertain exploratory code or throwaway artifacts in the workspace. If a script is created for the actual builder, it must be intentionally named, small, and validated. Temporary probes should be read-only one-shot commands and should not leave files behind.
