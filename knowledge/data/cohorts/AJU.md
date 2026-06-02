# AJU 코호트 — 데이터/임상 카드

> **목적:** AJU 코호트의 raw clinical 소스·ID 매핑·manifest 커버리지·임상 변수 현황을 정리해 실험 설계 시 함정을 사전 식별한다.  ·  **출처:** `AJU_01_clinical_eda.ipynb`·`AJU_02_mri_voxel_roi.ipynb` 출력 + `common/clinical_io.py:load_AJU` + `preprocessed_official/v2/AJU/manifests/`  ·  **갱신:** 2026-06-02

---

## 0. 코호트 성격

- AJU는 **국내 memory-clinic** 출처 코호트. 표본이 **거의 순수 impaired**(아래 CDR 분포 참조)로 구성되어, 건강대조군(CN) source로 보기 어렵다 ⚠️.
- subject-level CDR=0(정상 인지)은 23~27명 규모에 불과 → **CN source 아님**. CN/HC가 필요한 설계에는 부적합하며, 타 코호트(예: 외부 CN)와 조합 필요.
- subject_id prefix가 다중(`ABD-AJ`, `ABD-SW`, `ABD-IH` 등) → 단일 사이트가 아닌 **다중 사이트/하위코호트 묶음**으로 보임. 사이트 효과(nuisance) 점검 필요 ⚠️ `[VERIFY]` (prefix별 기관 매핑 미확인).

---

## 1. Raw clinical source · ID 매핑 · manifest 커버리지

| 항목 | 값 (노트북 출력) |
|---|---|
| raw clinical source | `임상역학정보 분양_all.xlsx` (BL 시트, header행=1) |
| id_col | `epid` (manifest subject_id로 직접 사용, `to_manifest=str`) |
| 로더 note | "sex 코드 0=여/1=남(설명서 CE_01_base). 컬럼 한글/코드 혼재 → 코드북 참조 필요." |
| clinical 테이블 shape | (1322, 876) — epid 1322행, 876컬럼 |
| manifest subject 수 | 1001 |
| clinical→매핑 subject | 1322 |
| 교집합(join 가능) | 1001 (manifest의 **100%**) ✅ |
| clinical에 없는 manifest subject | 0 ✅ |

- ID 체계: `epid`를 **직접** manifest `subject_id`로 사용(정규화 없음). 매핑 함수는 `lambda x: str(x)`.
- subject_id 형식: `ABD-AJ-0001`, `ABD-AJ-0002` 등. 로더는 `epid`가 `ABD`로 시작하는 행만 사용.
- 커버리지 **100%** — manifest 전 subject가 raw clinical에 존재. 결측 join 없음.

### Manifest 파일 (per-consortium, v2)
`/home/vlm/data/preprocessed_official/v2/AJU/manifests/`

| 파일 | 크기 | 단계 |
|---|---|---|
| `aju_official_v2_raw_input_manifest_1287.csv` | 398 KB | raw 입력 |
| `aju_official_v2_stage02_excluded_nifti_manifest_0.csv` | 409 B | stage02 제외 (0건) |
| `aju_official_v2_stage02_validated_nifti_manifest_1287.csv` | 1.2 MB | NIfTI 검증 |
| `aju_t1w_full_preprocessed_ready_manifest_1287.csv` | 1.7 MB | 전처리 완료 |

- suffix `1287` = 세션 레코드 수. stage02 제외 0건 → NIfTI 검증 단계 손실 없음 ✅.

---

## 2. 보유 임상 변수 (핵심 매핑)

노트북 `meta` 핵심 변수 매핑 및 결측 (epid 1322행 기준):

| role | column | dtype | missing% | nunique |
|---|---|---|---|---|
| cdr | `cdr` | object | 0.0% | 5 |
| age | `age` | object | 0.0% | 43 |
| sex | `sex` | object | 0.0% | 2 |

- 핵심 변수 결측 0% (cdr/age/sex 전부) ✅. 단 dtype이 `object`(문자 혼재) → 수치 분석 전 캐스팅 필요 ⚠️.
- ⚠️ **dx 컬럼 없음**: 로더 `meta['dx']=None`, raw clinical에 정제된 CN/MCI/AD 진단 컬럼 부재. 진단 분류는 CDR로 대리하거나 별도 코드북 파싱 필요.
- ⚠️ **MMSE/CDR-SB 매핑 없음**: 로더에서 `mmse=None`, `cdrsb=None`, `extra=[]`. 단 manifest에는 `cdrsb`가 통합되어 존재(노트북 02에서 `cdrsb` 값 확인됨) → MMSE 등 추가 변수는 876컬럼 raw에서 코드북 참조로 추출 가능성 있음 🟡 `[VERIFY]`.
- ⚠️ **한국어/코드 혼재**: 876개 컬럼이 한글 변수명·코드 혼재. `ise_h`/`ise_r` 같은 한국어 임상 변수("알쯔하이머형 치매", "혈관성 치매", "Borderline" 등) 존재 → 변수 해석에 코드북(`설명서 CE_01_base`) 필수.

### sex 코딩 (공식 설명서)
- **sex 0=여 / 1=남** (설명서 `CE_01_base` 기준). 타 코호트(통상 1=남, 2=여 또는 M/F)와 코딩 상이 → 통합 시 매핑 오류 위험 ⚠️.

---

## 3. 진단·CDR 분포

⚠️ 본문에서 자주 인용되는 "CN 23 / MCI 998 / AD 220" 진단 split은 **현 데이터에서 재현 불가**: raw clinical에 dx 컬럼이 없고(§2), manifest에도 진단 컬럼 부재(`cdr_global`·`cdrsb`·`cdr_source`만 존재). 진단 분류 출처 미확인 → `[VERIFY]`.

대신 **CDR 분포는 재현 가능**(아래는 본 카드 작성 중 직접 산출, 노트북 외 검증):

| CDR | subject-level (manifest, n=1001) | raw clinical epid-level (n=1322) |
|---|---|---|
| 0.0 | 27 | 42 |
| 0.5 | 776 | 1048 |
| 1.0 | 159 | 189 |
| 2.0 | 34 | 38 |
| 3.0 | 5 | 5 |

- CDR=0.5가 압도적(manifest 776/1001 ≈ 78%) → **MCI/very-mild 중심 memory-clinic 표본**. CDR=0(정상)은 manifest 27 / raw 42에 불과 → "CN ~23–27" 진술과 정합 ✅ (정확 수치는 집계 기준에 따라 변동).
- 나이: `age` nunique=43 (object dtype), 노트북 join 샘플상 60대~70대 후반 분포. 정밀 통계는 캐스팅 후 재산출 필요 🟡.
- 성별: `sex` 2값(0/1), 분포 정량은 노트북 출력에 미표기 🟡 `[VERIFY]` (산출 시 0=여/1=남 코딩 적용).

---

## 4. 종단(longitudinal) 구조

| 항목 | 값 |
|---|---|
| 세션 행 | 1287 |
| subject 수 | 1001 |
| subject당 최대 세션 | 2 |
| session_id 분포 | V1 954 · V2 287 · ses-1 46 |

- 1001명 중 286명이 2세션 보유(V1+V2), 나머지는 단일. **최대 2 visit**의 얕은 종단 구조.
- session_id가 **V1/V2 순서형**(일부 `ses-1` 혼재) → 절대 시점이 아닌 방문 순번. 종단 분석 시 visit 간격(개월)은 raw clinical에서 별도 확인 필요 ⚠️.
- 다중 prefix(ABD-AJ/SW/IH)가 동일 manifest에 공존 → 종단·사이트 교란 동시 점검 권장.

---

## 5. ROI / 영상 입력

- final_tensor: `192×224×192` z-score 정규화. 뇌내부 mean≈0, std≈1 검증됨(노트북 02), brain_fraction ≈ 0.152 ✅.
- final_qc / fs_qc: 노트북 샘플 12세션 모두 `PASS` (전수 통과 아님, 샘플 기준) 🟡.
- **ROI 관련 산출물은 BLOCKED_PROVISIONAL**: ROI 분석은 `roi_transfer_option_b_candidate_v0`의 final_tensor-grid 버전만 사용 가능하며, `roi_masks/*`(256³ conformed)는 final_tensor에 직접 오버레이 불가(노트북 02 경고). ROI 결과 인용 시 잠정·차단 상태 병기 필수 ⚠️ `[VERIFY]`.

---

## 출처

- `/home/vlm/minyoungi/Clinical/consortiums/AJU/AJU_01_clinical_eda.ipynb` (조회 2026-06-02)
- `/home/vlm/minyoungi/Clinical/consortiums/AJU/AJU_02_mri_voxel_roi.ipynb` (조회 2026-06-02)
- `/home/vlm/minyoungi/Clinical/common/clinical_io.py:load_AJU` (조회 2026-06-02)
- `/home/vlm/data/preprocessed_official/v2/AJU/manifests/` (4파일, 조회 2026-06-02)
- CDR 분포는 작성 중 `mio.load_manifest()` 및 `cio.load('AJU')` 직접 집계 (2026-06-02)
