# AIBL 코호트 — 데이터/임상 카드

> **목적:** AIBL 코호트의 raw clinical 소스·ID 매핑·manifest 커버리지·임상 변수 현황을 정리해 실험 설계 시 함정을 사전 식별한다.  ·  **출처:** `AIBL_01_clinical_eda.ipynb` 출력 + `common/clinical_io.py:load_AIBL` + `preprocessed_official/v2/AIBL/manifests/`  ·  **갱신:** 2026-06-02

---

## 1. Raw clinical source · ID 매핑 · manifest 커버리지

| 항목 | 값 (노트북/로더 출력) |
|---|---|
| raw clinical source | `aibl_{pdxconv,cdr,mmse,ptdemog}` 관계형 merge (`RID`+`VISCODE`) |
| id_col | `RID` |
| 로더 note | "DXCURREN: 1=NL,2=MCI,3=AD. ptdemog는 baseline only(나이 직접없음, PTDOB로 계산 필요)." |
| clinical 테이블 shape | (1688, 6) — visit 단위 행 1688, 컬럼 6 |
| manifest subject 수 | 617 |
| clinical→매핑 subject | 862 |
| 교집합(join 가능) | 617 (manifest의 **100%**) ✅ |
| clinical에 없는 manifest subject | 0 ✅ |

- ID 매핑: `meta['to_manifest'] = lambda x: f'AIBL_{int(x)}'` — `RID` 정수를 `AIBL_<RID>` 형식으로 변환. manifest 예 `AIBL_10`, `AIBL_100`, `AIBL_1000`과 동일 포맷으로 일치.
- raw clinical은 4개 테이블 조인: `pdxconv`(DXCURREN), `cdr`(CDGLOBAL), `mmse`(MMSCORE)는 `RID`+`VISCODE`로 outer merge, `ptdemog`(PTGENDER)는 `RID`만으로 left merge(baseline-only) — `clinical_io.py:48-66`.

### Manifest 파일 (per-consortium, v2)
`/home/vlm/data/preprocessed_official/v2/AIBL/manifests/`

| 파일 | 크기 | 단계 |
|---|---|---|
| `aibl_official_v2_raw_input_manifest_991.csv` | 447 KB | raw 입력 |
| `aibl_official_v2_stage02_validated_nifti_manifest_991.csv` | 2.3 MB | NIfTI 검증(991) |
| `aibl_official_v2_stage02_validated_nifti_manifest_990.csv` | 1.0 MB | NIfTI 검증(990) |
| `aibl_official_v2_stage02_excluded_nifti_manifest_1.csv` | 1.1 KB | 제외(1건) |
| `aibl_t1w_full_preprocessed_ready_manifest_991.csv` | 1.4 MB | 전처리 완료(991) |

- ⚠️ **세션 카운트 불일치**: per-consortium ready manifest CSV는 991행 / 618 subject인데, 노트북이 사용한 `mio.load_manifest()`(통합 manifest)의 AIBL 슬라이스는 **987 세션 / 617 subject**다. 4세션·1subject 차이의 원인(통합 단계 필터링 등)은 미확인 `[VERIFY]`. 본 카드의 종단·분포 수치는 노트북 기준인 **987/617**을 채택.
- stage02 validated가 991 → 990으로, excluded 1건이 별도 파일로 분리됨(QC 제외 1건).

---

## 2. 보유 임상 변수 (핵심 매핑)

노트북 `meta` 핵심 변수 매핑 및 결측 (clinical 테이블 1688행 기준):

| role | column | dtype | missing% | nunique |
|---|---|---|---|---|
| dx | `DXCURREN` | int64 | 0.0% | 5 |
| cdr | `CDGLOBAL` | float64 | 0.0% | 6 |
| mmse | `MMSCORE` | int64 | 0.0% | 29 |
| sex | `PTGENDER` | int64 | 0.0% | 2 |
| age | — (없음) | — | — | — |

- 추가 존재 컬럼: `VISCODE`(visit code).
- ⚠️ **age 직접 없음**: 로더 `age=None`. ptdemog는 baseline-only이며 나이 컬럼이 없어 `PTDOB`로 별도 계산 필요. 현재 테이블에서 나이 분석 불가.
- cdrsb: `cdrsb=None` — CDR sum-of-boxes는 raw clinical에 없음. (참고: manifest의 `cdrsb` 컬럼은 AIBL 세션에서 모두 NaN — `AIBL_02` 노트북 샘플에서 확인.)
- ⚠️ **DXCURREN 결측코드 존재**: 핵심 매핑은 결측 0%로 표기되나, 전체 clinical(862 subject) 기준 DXCURREN에 `-4`(=결측코드 1건), `7`(=결측/미적용 추정 3건)이 섞여 있음. manifest 교집합(617 subject)에서는 1/2/3 범주만 남음. CDGLOBAL에도 `-4` 결측코드 1건 존재 ⚠️ — 분석 전 음수/7 코드 필터링 필요.

---

## 3. 진단 · CDR · 나이 · 성별 분포

> 노트북 01의 분포 셀(§2 EDA)은 matplotlib Figure로만 출력되어 텍스트 카운트가 없다. 아래 카운트는 **본 카드 작성 시 `clinical_io.load_AIBL` + `mio.load_manifest()` 교집합(manifest 코호트 617 subject)으로 직접 산출**한 값이다(노트북 원출력 아님). 🟡

### 진단 (DXCURREN: 1=NL, 2=MCI, 3=AD)

| 단위 | NL(1) | MCI(2) | AD(3) | 계 |
|---|---|---|---|---|
| 세션 (987) | 735 | 159 | 93 | 987 |
| subject (617) | 452 | 95 | 70 | 617 |

### CDR (CDGLOBAL, subject 단위, manifest 코호트 617)

| 0.0 | 0.5 | 1.0 | 2.0 | 3.0 |
|---|---|---|---|---|
| 430 | 145 | 34 | 6 | 2 |

- CN 우세(NL 73% 세션, 70% subject). AD/중증(CDR≥2)은 8 subject로 희소 ⚠️ — 군별 불균형, 중증군 통계력 낮음.

### 성별 (PTGENDER, subject 단위, manifest 코호트 617)

| 코드 1 | 코드 2 |
|---|---|
| 269 | 348 |

- ⚠️ 성별 코딩 규약(1/2 ↔ M/F 매핑)은 로더/노트북에 명시 없음 `[VERIFY]`. ADNI 관례상 1=M,2=F 가능성 있으나 단정 불가.

### 나이
- ⚠️ 산출 불가(§2). raw 테이블에 나이 컬럼 없음.

### MMSE
- subject 단위 평균 약 27.3(전체 862 subject 기준 산출), min 0 / max 30. min=0은 결측코드 또는 중증 실측 구분 미확인 `[VERIFY]` — 분석 전 하한 점검 필요.

---

## 4. 종단(longitudinal) 현황

| 항목 | 값 (노트북 출력) |
|---|---|
| manifest 세션 행 | 987 |
| manifest subject 수 | 617 |
| merged(세션) | 987 (clinical **100%** 매칭) ✅ |
| 최대 세션/subject | 5 |
| 평균 세션/subject | 약 1.60 |

세션/subject 분포 (ready manifest 991행 기준 산출, 618 subject):

| 세션수 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| subject | 440 | 85 | 25 | 34 | 34 |

- 단일 세션 subject가 다수(약 71%)이나, 3회 이상 다중 visit subject도 93명 존재. 종단 설계 시 subject-level 누수 방지 필수(LOCO 등) ⚠️.
- ⚠️ 동일 subject의 여러 세션에서 CDR/MMSE가 동일 값으로 반복 관측됨(`AIBL_644` 두 세션 모두 CDGLOBAL=0.0, MMSCORE=29 — 노트북 join 샘플). raw merge가 visit별이긴 하나, 일부 임상값이 baseline 전파일 가능성 ⚠️ — visit-level 변화 분석 전 visit별 갱신 여부 확인 필요.
- `ptdemog`(성별)는 baseline-only left-join이므로 모든 세션에 동일 성별 복제됨(정상).

---

## 5. 코호트 특이 함정

- ⚠️ **결측코드 -4 / 7**: DXCURREN·CDGLOBAL에 음수(`-4`) 및 `7` 코드 혼입(전체 clinical 기준). manifest 교집합에서는 제거되나, 전체 raw로 작업 시 명시적 필터 필수.
- ⚠️ **나이 없음**: 나이 통제 분석 불가. `PTDOB` 기반 계산 파이프라인을 별도 구축하기 전까지 연령 보정 모델 불가.
- ⚠️ **성별 코딩 미확인**: PTGENDER 1/2의 M/F 매핑 `[VERIFY]`.
- ⚠️ **세션 카운트 991 vs 987 불일치**(§1): 통합 manifest와 per-consortium CSV가 4세션 차이. 어느 쪽을 분석 모집단으로 쓸지 사전 고정 필요.
- ⚠️ **session_id 형식**: `20140821`처럼 YYYYMMDD 정수(노트북 샘플). 날짜 파싱 시 타입/포맷 확인.
- ⚠️ **중증군 희소**: CDR≥2 = 8 subject, AD(DXCURREN=3) = 70 subject. 다중 분류·중증 검출 실험은 통계력 한계.
- ⚠️ **cdrsb 전무**: manifest의 `cdrsb` AIBL 세션 전부 NaN. CDR-SB 기반 회귀/계층화 불가.

---

## 6. ROI / 부피

- 01(clinical EDA)에는 ROI/부피 산출 없음. ROI/voxel은 `AIBL_02_mri_voxel_roi.ipynb`, 3D 렌더는 `AIBL_03_3d_render.ipynb` 소관.
- `AIBL_02` 검증(읽음): final_tensor는 192×224×192 z-score(뇌내부 mean≈0, std≈1, brain_fraction≈0.188), ROI는 `option_b`(final_tensor-grid, aseg 96 labels)가 voxel-for-voxel 정합(shape/affine 일치). 256³ conformed `roi_masks/*`는 final_tensor에 **직접 오버레이 불가** — 반드시 option_b grid 사용 ⚠️.
- ⚠️ **BLOCKED_PROVISIONAL**: ROI/부피 기반 변수는 전처리 파이프라인 검증 전까지 잠정값으로 간주. 다운스트림 사용 시 출처 파이프라인·정규화 단계 검증 후 인용할 것 🟡.

---

## 출처

- 노트북: `/home/vlm/minyoungi/Clinical/consortiums/AIBL/AIBL_01_clinical_eda.ipynb`, `AIBL_02_mri_voxel_roi.ipynb` (텍스트 추출, 출력 기반) — 읽은 날짜 2026-06-02.
- 로더: `/home/vlm/minyoungi/Clinical/common/clinical_io.py` `load_AIBL` (48–66행) — 읽은 날짜 2026-06-02.
- manifest 디렉토리(파일명만): `/home/vlm/data/preprocessed_official/v2/AIBL/manifests/` — 읽은 날짜 2026-06-02.
- §3 분포 카운트: 본 카드 작성 시 `clinical_io.load_AIBL` × `mio.load_manifest()` 교집합으로 직접 산출(노트북 원출력 아님) — 2026-06-02.
- 미열람(요약 보류): `AIBL_03_3d_render.ipynb`.
