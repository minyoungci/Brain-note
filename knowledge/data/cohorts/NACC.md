# NACC 코호트 — 임상·데이터 카드

> **목적:** NACC(National Alzheimer's Coordinating Center) 코호트의 raw clinical 소스·임상변수·진단/CDR 분포·종단 구조·함정을 정리한다.  ·  **출처:** `minyoungi/Clinical/consortiums/NACC/NACC_01_clinical_eda.ipynb` 실제 출력 + `clinical_io.load_NACC` + v2 manifests  ·  **갱신:** 2026-06-02

## Raw Clinical 소스·ID·커버리지

| 항목 | 값 |
|---|---|
| Raw 소스 | `commercial_nacc70.csv` (원본 1024컬럼 중 핵심 12컬럼만 로드) |
| 경로 | `/home/vlm/data/raw/NACC/NACC-Clinical/commercial_nacc70.csv` |
| ID 컬럼 | `NACCID` (manifest `subject_id`와 동일 문자열, `to_manifest=str`) |
| Raw 행 구조 | visit 단위 다행 — shape `(178052, 12)`, 매핑 subject 48,595명 |
| 진단 변수 | `NACCUDSD` = UDS 진단(int, nunique 4) |

**Manifest join (NB01 실측):** manifest subject 1,414명 ∩ clinical 매핑 subject → 교집합 1,414 (manifest의 **100%**). 세션 행 기준 1,866행 모두 매칭(100%). clinical에 없는 manifest subject 0명. ✅ row-level join 완전 연결.

## 보유 임상변수 (`load_NACC` keep 12)

`NACCID, SEX, EDUC, NACCAGE, NACCMMSE, NACCMOCA, CDRGLOB, CDRSUM, NACCALZD, NACCUDSD, NACCAPOE, NACCNE4S`

| role | column | dtype | raw missing% | nunique |
|---|---|---|---|---|
| dx | NACCUDSD | int64 | 0.0% | 4 |
| cdr | CDRGLOB | float64 | 0.0% | 6 |
| cdrsb | CDRSUM | float64 | 0.0% | 35 |
| mmse | NACCMMSE | int64 | 0.0% | 37 |
| age | NACCAGE | int64 | 0.0% | 93 |
| sex | SEX | int64 | 0.0% | 2 |

추가 관심 컬럼(존재 확인): `NACCMOCA, NACCALZD, NACCAPOE, NACCNE4S, EDUC`.

**APOE·MoCA의 NACC-only 여부** (`clinical_io.py` 전 로더 대조):
- **MoCA** (`NACCMOCA`): 본 데이터셋 7개 컨소시엄(ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC) 로더 중 **NACC에만 존재** → 🟡 NACC-only로 확인(이 코드베이스 한정).
- **APOE**: NACC(`NACCAPOE`, `NACCNE4S`)와 A4(`APOEGN`) 두 곳에 존재 → APOE는 NACC-only가 **아님** ❌. NACC는 APOE 유전형+e4 allele 수(`NACCNE4S`)를 함께 보유.

## 진단·CDR·나이/성별 분포

⚠️ raw missing%는 0.0%이나 이는 **NACC 결측코드**(`88/99/-4` 등)가 결측이 아닌 정수로 들어있기 때문 — 실제 결측은 코드 디코딩 후 재계산 필요(`meta['note']`). 예: NB01 join 샘플에서 `NACCMMSE = -4`(결측코드) 다수 관찰.

- `NACCUDSD`: UDS 진단 4범주(코드값 1/3/4 등 — NB01 샘플에서 1,3,4 관찰). 코드→라벨 매핑은 [VERIFY].
- `CDRGLOB`: 6수준(0/0.5/1/2/3 등). manifest `cdr_global`은 이미 통합된 라벨이며 raw가 그 출처.
- `NACCAGE`: nunique 93(연속). `SEX`: 2범주(1/2).

## 종단(longitudinal) 구조

| 지표 | 값 | 근거 |
|---|---|---|
| 세션 행(merged) | 1,866 | NB01 `manifest 세션 행: 1866` |
| subject 수 | 1,414 | NB01 `manifest subject 수: 1414` |
| subject당 세션 max | 4 | v2 ready manifest groupby (max 4, mean 1.32) |
| diagnosis 무라벨 | 274 세션 | [VERIFY] — NB01/02에 미산출, 작업 브리프 수치 |

참고 — v2 전처리 ready manifest(`nacc_t1w_full_preprocessed_ready_manifest_1876.csv`): 전체 1,876행 중 `final_qc_status=PASS` 1,867행 / 1,415 subj, `FAIL` 9행. EDA join의 1,866/1,414와 1행/1subj 차이(join 단계 차이로 추정, [VERIFY]).

## 특이 함정 ⚠️

- **diagnosis 커버리지 85.3%** — [VERIFY]. NB01/NB02 출력에 직접 산출되지 않음. NB01 join은 영상↔clinical row-level 100% 매칭을 보고하나, 이는 NACCUDSD 행 존재 여부이지 *유효 진단 라벨* 커버리지와 별개. 85.3%는 작업 브리프 기준 수치로 재현 전까지 미검증.
- **결측코드 위장**: `88/99/-4` 등이 정수로 저장 → naive `isna()`는 0% 결측으로 오판. 통계/필터 전 디코딩 필수.
- **visit 단위 다행**: raw는 visit 다행 구조 → subject-level 분석 시 dedup/visit 선택 정책 명시 필요.
- **ROI**: NB02에서 final_tensor-grid(192×224×192) ↔ option_b aseg(96 labels) shape/affine 일치 검증됨(voxel 정합 OK). 단, `roi_masks/*`(256³ conformed)는 final_tensor에 직접 오버레이 불가 → 반드시 `roi_transfer_option_b_candidate_v0`의 final_tensor-grid 버전 사용. **BLOCKED_PROVISIONAL** — ROI 산출물은 잠정(option_b candidate v0).

## 출처

- `/home/vlm/minyoungi/Clinical/consortiums/NACC/NACC_01_clinical_eda.ipynb` (실측 출력)
- `/home/vlm/minyoungi/Clinical/consortiums/NACC/NACC_02_mri_voxel_roi.ipynb` (ROI/tensor 정합)
- `/home/vlm/minyoungi/Clinical/common/clinical_io.py` (`load_NACC`, 컨소시엄별 변수 대조)
- `/home/vlm/data/preprocessed_official/v2/NACC/manifests/` (4 manifest, ready=1876)
- `/home/vlm/data/raw/NACC/NACC-Clinical/commercial_nacc70.csv`
- 갱신: 2026-06-02
