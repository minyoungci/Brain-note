# KDRC 코호트 — 데이터/임상 카드

> **목적:** KDRC 코호트의 cross-sectional 구조·raw clinical 소스·ID 매핑·manifest 커버리지·임상 변수 현황을 정리해 실험 설계 시 함정을 사전 식별한다.  ·  **출처:** `KDRC_01_clinical_eda.ipynb` 출력 + `preprocessed_official/v2/KDRC/manifests/` + `minyoungi/manifests/v2_partial/` join audit  ·  **갱신:** 2026-06-02

---

## 1. 구조 요약 (핵심)

| 항목 | 값 | 근거 |
|---|---|---|
| 종단성 | **엄격 cross-sectional** — 종단 0. 909 세션 = 909 subject, 전 세션 `ses-1` | NB01 join: manifest 909 subj, merged 909행, sample 전부 `ses-1` |
| 진단 라벨 결측 | **0%** — `diagnosis` 전수 보유(3 범주) | NB01 §1 결측표 |
| CDR(`cdr_global`) | DEDUP 로더 기준 **36.9% 결측**, 4 고유값 | NB01 §1 결측표 |

- ⚠️ **브리핑 명제와의 불일치**: 작업 브리핑은 "진단 라벨 0 / CDR 전수 보유"로 기술하나, NB01 출력은 그 반대다 — **diagnosis 결측 0%(전수 보유), cdr_global 결측 36.9%**. 본 카드는 노트북 실제 출력을 따른다. 브리핑 표현은 오기로 보임 `[VERIFY]`.
- session_id 전부 `ses-1` → subject-level 누수 위험은 낮으나, longitudinal/progression 설계는 **불가**(visit 1회).

---

## 2. Raw clinical source · ID 매핑 · manifest 커버리지

| 항목 | 값 (NB01 출력) |
|---|---|
| raw clinical source | `kdrc_unified_clinical_DEDUP` (v1, 큐레이션됨) |
| id_col | `dedup_subject_id` |
| 로더 note | "이미 codebook 매핑 완료(diagnosis/sex). label_tier로 라벨 신뢰도 구분." |
| clinical 테이블 shape | (786, 26) |
| manifest subject 수 | 909 |
| clinical→매핑 subject | 786 |
| 교집합(join 가능) | 770 (manifest의 **85%**) 🟡 |
| clinical에 없는 manifest subject | 139 (예: `24012209`, `24013415`, `24017783`) ⚠️ |

- subject_id 형식: 8자리 숫자 BCODE (`24006526`, `24006787` 등). 매핑 후 manifest/clinical 예시 동일 포맷으로 일치.
- merged 909행 중 clinical 매칭 **85%** → 약 139 세션이 DEDUP 로더 기준 임상 라벨 결측. 분석 전 제외/보정 정책 필요 ⚠️.

### Manifest 파일 (per-consortium, v2)
`/home/vlm/data/preprocessed_official/v2/KDRC/manifests/`

| 파일 | 크기 | 단계 |
|---|---|---|
| `kdrc_official_v2_raw_input_manifest_944.csv` | 349 KB | raw 입력 |
| `kdrc_official_v2_stage02_validated_nifti_manifest_944.csv` | 652 KB | NIfTI 검증(944) |
| `kdrc_official_v2_stage02_validated_nifti_manifest_931.csv` | 645 KB | NIfTI 검증(931) |
| `kdrc_official_v2_stage02_validated_nifti_manifest_2.csv` | 1.8 KB | 검증(2) |
| `kdrc_official_v2_stage02_excluded_nifti_manifest_13.csv` | 8.0 KB | stage02 제외(13) |
| `kdrc_t1w_full_preprocessed_ready_manifest_944.csv` | 1.3 MB | 전처리 완료(944) |

- suffix 944 = raw/ready 규모, 931 = 검증 통과, 13 = 제외(944=931+13). 🟡 정확한 의미 일부 `[VERIFY]`.
- NB01의 join 대상 manifest는 `mio.load_manifest()` 통합 manifest(909 subj)이며, 위 per-consortium csv(944) 본문은 미열람 → **909(통합 manifest) vs 944(per-consortium) 규모 차이** 존재. 불일치 사유 미확인 `[VERIFY]`.

---

## 3. 보유 임상 변수 (NB01 핵심 매핑)

| role | column | dtype | missing% | nunique |
|---|---|---|---|---|
| dx | `diagnosis` | object | 0.0% | 3 |
| cdr | `cdr_global` | float64 | 36.9% | 4 |
| age | `age_at_clinical_reference_approx` | int64 | 0.0% | 44 |
| sex | `sex` | int64 | 0.0% | 2 |

- 추가 존재 컬럼(NB01 확인): `label_tier`, `pet_suvr_final_ready`, `birth_year`, `is_classifiable`.
- **sex 결측 0%**(DEDUP 로더에서 codebook 매핑 완료). 코딩 1/2(아래 §5). ⚠️ 브리핑의 "sex 결측" 표현은 DEDUP 로더 출력과 불일치 `[VERIFY]` — 다른 소스(별도 raw 테이블)에서의 결측을 지칭했을 가능성.
- ⚠️ **MMSE 없음**: `mmse` role이 핵심 매핑에 미포함. MMSE/APOE/amyloid 등은 raw clinical XLSX(별도)에서 제공(§4 audit). DEDUP 테이블 보유 여부 `[VERIFY]`.
- `pet_suvr_final_ready`(amyloid PET) 존재 → diagnosis caption 누수 금지, held-out 검증/supervision 필드로만 사용 ⚠️(audit caveat).

---

## 4. 진단 · CDR · 나이 · 성별 분포

- dx(`diagnosis`): **3 범주**(CN/MCI/AD 또는 CN/MCI/DEMENTIA), 결측 0%. NB01엔 정량 카운트 없이 막대그래프만.
- cdr(`cdr_global`): **4 고유값**, DEDUP 기준 결측 36.9%. NB01엔 정량 카운트 없음(그래프만).
- age(`age_at_clinical_reference_approx`): int, 44 고유값, 결측 0%. sample에 58·63·64·67·71·72·76·80·81·82 관측. **평균/분포 정량값은 NB01에 없음**(히스토그램만).
- sex: int, 2값, 결측 0%. sample에 1·2 관측.

> NB01 분포는 모두 matplotlib Figure로만 출력되어 텍스트 카운트가 없다. 군별 N은 NB01에서 단정 불가. 아래 §4-b는 **별도 union-join CSV**(944 subj)에서 산출된 정량값이며 DEDUP 로더(786)와 모집단·소스가 다르다.

### 4-b. union-join CSV 정량 분포 (참고, 소스 상이)

`kdrc_v2_ready_join_clinical_union_v0.csv` (944 subj, distribution_20260504 ∪ extracted_0513):

| 변수 | 분포 |
|---|---|
| `sex` | F 602 / M 342 (sex_code 2=F, 1=M), 결측 0% |
| `diagnosis_level_label` | MCI 329 / CN 313 / DEMENTIA 302, 결측 0% |
| `cdr_global` | 0.5→471, 0.0→282, 1.0→135, 2.0→34, 결측 2.3%(22) |
| `cdrsb` | 23 고유값, 결측 2.3% |
| `diagnosis_3class_conservative` | MCI 329 / CN 313 / AD 291, 결측 1.2%(11 EXCLUDED) |
| `diagnosis_cause_label` | AD 407 / OTHER 161, 결측 39.8%(376) |

- ⚠️ **CDR 결측의 소스 의존성**: DEDUP 로더 **36.9%** vs union-join CSV **2.3%**. 같은 코호트라도 임상 소스(테이블/union 범위)에 따라 CDR 커버리지가 크게 달라짐. "CDR 전수 보유" 단정은 어느 소스에서도 성립하지 않음 ❌(union 기준 2.3% 결측, DEDUP 기준 36.9% 결측).

---

## 5. 코호트 특이 함정 · join audit 특이사항

- ⚠️ **두 raw clinical 파일의 보완적 분리**: `데이터분양_..._2026-05-04.xlsx`(576 BCODE) ∪ `KDRC_0513_extracted/KDRC_clinical.xlsx`(500 BCODE), 겹침 **단 124 BCODE**. union 952 subj → ready 944 subj **전수 커버**(ready_without_clinical=0). 단일 파일로는 커버리지 부족, **union 필수** ⚠️ (audit `kdrc_clinical_union_join_audit_v0.md`).
- ⚠️ **conservative diagnosis 매핑 규칙**: 수준1→CN, 수준2→MCI, 수준3+원인=AD→AD, 수준3+non-AD 원인→EXCLUDED. union 기준 EXCLUDED 11. 진단 3class 사용 시 이 매핑·제외 규칙 명시 필요(codebook: 진단원인 1=AD/2=혈관성/3=루이소체/4=파킨슨/5=기타).
- ⚠️ **sex 코딩**: 1=M, 2=F (union CSV `sex_code`/`sex` 대응). DEDUP 로더의 1/2도 동일 가정이나 DEDUP 자체 코드북 본문 미확인 `[VERIFY]`.
- ⚠️ **8 BCODE가 ready manifest에 없음**(clinical_without_ready=8) — 임상엔 있으나 영상 없는 subject. 학습 모집단 정의 시 제외.
- ⚠️ **manifest 규모 909 vs 944 불일치**(§2): 통합 manifest(NB01)와 per-consortium/audit(944)의 subject 수가 다름. 어느 쪽이 최종 학습 모집단인지 확정 필요 `[VERIFY]`.
- ⚠️ **amyloid PET/APOE/CDR/MMSE 누수 금지**: caption policy가 명시 허용하지 않는 한 diagnosis caption에 주입 금지(audit caveat 반복).

---

## 6. ROI / 부피

- NB01(clinical EDA)에는 ROI/부피 산출 없음. voxel/ROI는 `KDRC_02_mri_voxel_roi.ipynb`, 3D 렌더는 `KDRC_03_3d_render.ipynb`·`KDRC_roi_3d.html` 소관(본 카드 미열람).
- ⚠️ **BLOCKED_PROVISIONAL**: ROI/부피 기반 변수는 전처리 파이프라인 검증 전까지 잠정값. 다운스트림 인용 시 출처 파이프라인·정규화 단계 검증 후 사용할 것 🟡.

---

## 출처

- 노트북: `/home/vlm/minyoungi/Clinical/consortiums/KDRC/KDRC_01_clinical_eda.ipynb` (텍스트 추출, 출력 기반) — 읽은 날짜 2026-06-02.
- manifest 디렉토리(파일명만): `/home/vlm/data/preprocessed_official/v2/KDRC/manifests/` (6개 csv: raw_input_944 / stage02_validated_944·931·2 / stage02_excluded_13 / t1w_full_preprocessed_ready_944) — 2026-06-02.
- join audit: `/home/vlm/minyoungi/manifests/v2_partial/kdrc_clinical_join_audit_20260504_v0.md`, `kdrc_clinical_union_join_audit_v0.md` — 2026-06-02.
- 정량 분포 CSV: `/home/vlm/minyoungi/manifests/v2_partial/kdrc_v2_ready_join_clinical_union_v0.csv` (944 subj, §4-b) — 2026-06-02.
- 미열람(요약 보류): `KDRC_02_mri_voxel_roi.ipynb`, `KDRC_03_3d_render.ipynb`, `KDRC_roi_3d.html`.
