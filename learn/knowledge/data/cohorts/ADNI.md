# ADNI 코호트 — 데이터/임상 카드

> **목적:** ADNI 코호트의 raw clinical 소스·ID 매핑·manifest 커버리지·임상 변수 현황을 정리해 실험 설계 시 함정을 사전 식별한다.  ·  **출처:** `ADNI_01_clinical_eda.ipynb` 출력 + `preprocessed_official/v2/ADNI/manifests/`  ·  **갱신:** 2026-06-02

---

## 1. Raw clinical source · ID 매핑 · manifest 커버리지

| 항목 | 값 (노트북 출력) |
|---|---|
| raw clinical source | `adni_t1w_clinical_final.csv` (T1w에 사전조인) |
| id_col | `subject_id` |
| 로더 note | "성별 컬럼은 PTDEMOG(clinical data/)에 별도. 여기 final은 영상+CDR 중심." |
| clinical 테이블 shape | (1745, 35) — subject(매핑) 1745, 컬럼 35 |
| manifest subject 수 | 1580 |
| clinical→매핑 subject | 1745 |
| 교집합(join 가능) | 1569 (manifest의 99%) ✅ |
| clinical에 없는 manifest subject | 11 (예: `013_S_2389`, `013_S_4268`, `022_S_10256`) ⚠️ |

- subject_id 형식: `002_S_0413`, `002_S_10814` 등 (site_S_subject).
- `meta['to_manifest']` 매핑으로 clinical id → manifest subject_id 변환. 매핑 후 manifest/clinical 예시가 동일 포맷으로 일치 (별도 정규화 불필요해 보임). 🟡 매핑 규칙 본문은 미확인 `[VERIFY]`.

### Manifest 파일 (per-consortium, v2)
`/home/vlm/data/preprocessed_official/v2/ADNI/manifests/`

| 파일 | 크기 | 단계 |
|---|---|---|
| `adni_official_v2_raw_input_manifest_5037.csv` | 2.2 MB | raw 입력 |
| `adni_official_v2_stage02_validated_nifti_manifest_5037.csv` | 11 MB | NIfTI 검증 |
| `adni_t1w_full_preprocessed_ready_manifest_5037.csv` | 7.0 MB | 전처리 완료 |

- 파일명 suffix `5037` = raw 입력 레코드 규모로 추정 🟡 `[VERIFY]` (노트북에 5037 정량 근거 없음).
- 노트북에서 사용된 join 대상 manifest는 `mio.load_manifest()`의 통합 manifest이며, 위 per-consortium csv 본문은 미열람.

---

## 2. 보유 임상 변수 (핵심 매핑)

노트북 `meta` 핵심 변수 매핑 및 결측:

| role | column | dtype | missing% | nunique |
|---|---|---|---|---|
| dx | `entry_research_group` | object | 0.0% | 6 |
| cdr | `CDGLOBAL` | float64 | 0.0% | 5 |
| cdrsb | `CDRSB` | float64 | 0.0% | 21 |
| age | `entry_age` | float64 | 0.0% | 1283 |

- 추가 존재 컬럼(노트북 확인): `diagnosis_cdrsb`, `VISDATE`, `scanner_manufacturer`, `magnetic_field_strength`.
- ⚠️ **sex 매핑 없음**: 핵심 변수 매핑에 `sex` role이 빠짐. 로더 note에 따르면 성별은 `PTDEMOG`(clinical data/)에 별도 보관 → 이 final 테이블에서는 성별 분석 불가. 성별 분포 산출에는 PTDEMOG 별도 조인 필요 ⚠️.
- ⚠️ **MMSE 없음**: `mmse` role이 매핑에 없음(핵심 변수 매핑 dict에 미포함). MMSE/APOE/MoCA/amyloid는 이 final 테이블에서 노트북상 미확인 — 추가 변수는 raw clinical(별도 테이블)에서 제공된다고 노트북이 명시. 🟡 보유 여부 `[VERIFY]`.
- 전체 35컬럼 중 노트북이 명시적으로 확인한 것만 위에 한정. 나머지 컬럼 목록은 미열람.

---

## 3. 진단 · CDR · 나이 · 성별 분포

- dx(`entry_research_group`): **6개 범주**, 결측 0%. 샘플 행에 `CN`, `MCI` 등장. 정확한 6개 라벨명/카운트는 노트북에 정량 표 없음 — 막대그래프(Figure)만 출력.
- cdr(`CDGLOBAL`): **5개 고유값**, 결측 0%. 샘플에 0.0 / 0.5 관측. 분포 카운트는 노트북에 정량값 없음(그래프만).
- cdrsb(`CDRSB`): 21개 고유값, 결측 0%.
- age(`entry_age`): 1283개 고유값, 결측 0%. 샘플에 76.34, 77.25 관측. **평균/분포 정량값은 노트북에 없음**(히스토그램만).
- sex: 이 테이블에 없음(§2 참조) → 성별 분포 **노트북에 정량값 없음**.

> 분포는 모두 matplotlib Figure로만 출력되어 텍스트 카운트가 없다. 정확한 군별 N은 본 카드에서 단정하지 않는다.

---

## 4. 종단(longitudinal) 현황

| 항목 | 값 |
|---|---|
| manifest 세션 행 | 4742 |
| manifest subject 수 | 1580 |
| merged(세션) | 4742 (clinical 99% 매칭) |
| 최대 세션/subject | 16 (알려진 값) 🟡 `[VERIFY]` — 노트북 join 출력엔 max session 정량 없음 |

- subject당 다중 visit 구조 확인됨(예: `002_S_0413` 단일 subject가 11개 세션 행). 종단 설계 시 subject-level 누수 방지 필수(LOCO 등) ⚠️.
- subject-level CDR이 visit 간 동일 값으로 반복 채워진 행 관측(`002_S_0413` 전 세션 CDGLOBAL=0.0, entry_age=76.34 고정). entry_* 변수는 **등록 시점 고정값**이며 visit별 갱신이 아님 ⚠️ — visit별 진행 분석에 그대로 쓰면 오해 소지.

---

## 5. 코호트 특이 함정

- ⚠️ **session_id `.0` 절단/부동소수**: `session_id`가 `20061115.0`처럼 float로 표기됨(YYYYMMDD가 float). 문자열 join·날짜 파싱 시 `.0` 절단 및 정수 변환 필요. 직접 비교 시 타입 불일치 위험.
- ⚠️ **sex 코딩/소재**: 성별이 final 테이블에 없고 PTDEMOG에 별도. 코딩 규약(1/2 vs M/F) 미확인 `[VERIFY]`. 성별 통제 분석 전 별도 조인·코딩 확인 필수.
- ⚠️ **entry_* 고정값**: `entry_age`/`entry_research_group`/`CDGLOBAL`이 등록 시점 기준으로 visit 전체에 동일 복제됨(§4). visit-level 변화 분석에 부적합.
- ⚠️ **manifest 11 subject 미커버**: clinical에 없는 manifest subject 11개 → 임상 라벨 결측 세션 존재. 분석 전 제외/보정 정책 필요.
- ⚠️ **dx 범주 6개**: CN/MCI 외 추가 범주 4개 존재(SMC/EMCI/LMCI/AD 가능성) — 정확 라벨 미확인 `[VERIFY]`. 이진/다중 분류 매핑 시 범주 통합 규칙 명시 필요.

---

## 6. ROI / 부피

- 이 노트북(01 clinical EDA)에는 ROI/부피 산출 없음. ROI/voxel은 `ADNI_02_mri_voxel_roi.ipynb`, 3D 렌더는 `ADNI_03_3d_render.ipynb` 소관(본 카드 미열람).
- ⚠️ **BLOCKED_PROVISIONAL 후보**: ROI/부피 기반 변수는 전처리 파이프라인 검증 전까지 잠정값으로 간주. 다운스트림 사용 시 출처 파이프라인·정규화 단계 검증 후 인용할 것 🟡.

---

## 출처

- 노트북: `/home/vlm/minyoungi/Clinical/consortiums/ADNI/ADNI_01_clinical_eda.ipynb` (텍스트 추출, 출력 기반) — 읽은 날짜 2026-06-02.
- manifest 디렉토리(파일명만): `/home/vlm/data/preprocessed_official/v2/ADNI/manifests/` (`adni_official_v2_raw_input_manifest_5037.csv`, `adni_official_v2_stage02_validated_nifti_manifest_5037.csv`, `adni_t1w_full_preprocessed_ready_manifest_5037.csv`) — 읽은 날짜 2026-06-02.
- 미열람(요약 보류): `ADNI_02_mri_voxel_roi.ipynb`, `ADNI_03_3d_render.ipynb`.
