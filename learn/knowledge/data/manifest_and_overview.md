# data · manifest alignment & 코호트 개요

> **목적:** official manifest 3-way join 구조와 7개 코호트의 정량 개요(노트북 00·01 실측)  ·  **출처:** minyoungi `Clinical/notebooks/00_manifest_alignment.ipynb`, `01_consortium_overview.ipynb` (헤드리스 실행 출력)  ·  **갱신:** 2026-06-02

세션 수준(session-level) 실측치다. plant `00_data_manifest.md`의 subject-baseline CN/IMPAIRED 표와는
집계 단위가 다르므로 혼동 금지(여기는 세션 단위 diagnosis, 거기는 subject baseline CDR-bin).

## 1. official_manifest.csv 스키마 (13,022 × 12)

| # | 컬럼 | dtype | 비고 |
|---|---|---|---|
| 0–3 | consortium, subject_id, session_id, qc_t1w_key | object | 키. `session_id`에 `.0` 접미(`20061115.0`) → strip 필수 |
| 4–5 | final_tensor_path, final_mask_path | object | 텐서/마스크 경로 |
| 6–7 | final_qc_status, fs_qc_status | object | QC 상태 |
| 8–9 | cdr_global, cdrsb | float64 | ⚠️ 여기선 float이나, 일부 manifest 버전에서 string → `to_numeric` 습관화 |
| 10–11 | cdr_source, cdr_source_table | object | CDR 출처 |

**CDR global 분포(세션):** 0.0 → 7,080 / 0.5 → 4,931 / 1.0 → 831 / 2.0 → 161 / 3.0 → 19 (합 13,022).

## 2. 3-way join 구조 (master_df 생성)

| manifest | 행 | 역할 |
|---|---|---|
| `official_manifest.csv` | 13,022 × 12 | CDR·경로·QC (기준) |
| `v2/<C>/manifests/*_raw_input_manifest_*.csv` | 코호트별, 합 18,883 × 32 | 진단(AD/CN/MCI)·나이·성별 |
| `v2/<C>/manifests/*_t1w_full_preprocessed_ready_manifest_*.csv` | 합 18,882 × 62 | QC/geometry 62컬럼 |

- **join key**: `consortium + subject_id + session_id`. 결과 `master_df` = **13,022 × 44, 행 손실 0%, 중복 0**.
- raw/preprocessed manifest는 official보다 행이 많다(전처리 전 후보 포함). join은 official 기준 left-merge.
- **raw_input_manifest 행 수**: ADNI 5,037 · NACC 1,876 · AIBL 991 · OASIS 1,615 · A4 7,133 · AJU 1,287 · KDRC 944.
  → A4가 7,133으로 가장 큼(최종 manifest 1,811과 큰 차이 = 전처리/QC 탈락 다수).

### master_df 주요 컬럼 null 비율
- diagnosis **23.4%** null(A4·KDRC 무라벨 때문), cdrsb 7.7%, age 9.5%, sex 9.5%. CDR global 0%.

### sex 코딩 이질성 (정규화 없으면 parquet 직렬화 실패)
| 코호트 | 원본 | 캐논 |
|---|---|---|
| ADNI/NACC/AIBL/OASIS | M/F | M/F |
| A4 | Male/Female | M/F |
| AJU | 0/1 (정수) | **0=F, 1=M** (공식 설명서 `임상역학정보_all_설명서.xlsx`) |
| KDRC | 결측 | None |

⚠️ 정수/문자 혼재가 `ArrowTypeError: Expected bytes, got int`를 유발. `sex_raw`(원본 보존) + `sex`(캐논) 분리.

## 3. 코호트별 개요 (master_df, 세션 수준)

| 코호트 | subjects | sessions | sess/subj | CN | MCI | AD | unlabeled | AD율 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| ADNI | 1,580 | 4,742 | 3.00 | 2,509 | 1,935 | 295 | 3 | 0.06 |
| NACC | 1,414 | 1,866 | 1.32 | 1,062 | 356 | 174 | 274 | 0.09 |
| AIBL | 617 | 987 | 1.60 | 719 | 139 | 129 | 0 | 0.13 |
| OASIS | 718 | 1,420 | 1.98 | 1,126 | 42 | 252 | 0 | 0.18 |
| A4 | 992 | 1,811 | 1.83 | 0 | 0 | 0 | 1,811 | 0.00 |
| AJU | 1,001 | 1,287 | 1.29 | 23 | 998 | 220 | 46 | 0.17 |
| KDRC | 909 | 909 | 1.00 | 0 | 0 | 0 | 909 | 0.00 |
| **합** | **7,231** | **13,022** | **1.80** | **5,439** | **3,470** | **1,070** | **3,043** | |

- **diagnosis 라벨 커버리지**(ADNI/NACC/AIBL/OASIS/AJU): 96.86%. NACC만 85.3%(274 무라벨).
- A4·KDRC는 진단 라벨 0 → SSL pretraining / domain adaptation 후보(단 CDR은 보유: A4 1,811·KDRC 909 전수).
- ⚠️ **raw diagnosis(중복 포함) ≠ master diagnosis**: 예 ADNI raw AD303/CN2686/MCI2048 → master(세션 dedup 후) AD295/CN2509/MCI1935. 집계 시 master 기준 사용.

## 4. 종단(longitudinal) 현황

| 코호트 | 종단 subject(세션>1) | 비율 | 최대 세션 |
|---|---|---|---|
| ADNI | 849/1,580 | 53.7% | **16** |
| OASIS | 363/718 | 50.6% | 8 |
| A4 | 793/992 | 79.9% | 4 |
| AIBL | 178/617 | 28.8% | 5 |
| AJU | 286/1,001 | 28.6% | 2 |
| NACC | 361/1,414 | 25.5% | 4 |
| KDRC | 0/909 | 0.0% | 1 |

→ 종단 모델링(plant)에 ADNI/OASIS/A4가 핵심. KDRC는 단일세션(종단 불가), AJU는 최대 2세션.
시간정렬 가능성은 별도 제약(→ `../03_longitudinal.md`): NACC는 세션이 있어도 image-ID라 정렬 불가.

## 5. 검증 사실 (생성≠검증 교훈)

- ✅ 행 손실 0%, 중복 0, 라벨 커버리지 96.86% — assert로 게이트.
- ⚠️ 과거 "FastSurfer 39% 결측"은 ADNI `session_id .0` 절단 경로 버그였고, 전수 재검증 시 100% 존재.
  경로는 `session_id` 재구성 금지, `final_tensor_path`에서 유도(`mri_io.t1w_dir`).
