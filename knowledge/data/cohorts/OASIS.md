# OASIS 코호트 — 임상·데이터 카드

> **목적:** OASIS(OASIS-3 계열) 코호트의 raw clinical 소스·ID·커버리지·임상변수·분포·종단 구조를 정리한다.  ·  **출처:** `OASIS_01_clinical_eda.ipynb`, `preprocessed_official/v2/OASIS/manifests/`  ·  **갱신:** 2026-06-02

## 개요

| 항목 | 값 | 근거 |
|---|---|---|
| Raw clinical source | `OASIS_meta.csv` (811 rows × 26 cols) | nb01 `meta['source']` |
| 임상 ID 컬럼 | `subject_id` (예: `OAS30001`) | nb01 `meta['id_col']` |
| Manifest(영상) 규모 | 1420 세션 / 718 subject | `common.mri_io.load_manifest()` |
| Raw input manifest | 1615 세션 / 750 subject | `oasis_official_v2_raw_input_manifest_1615.csv` |

## ⚠️ 커버리지 함정 (핵심)

- `OASIS_meta.csv`는 imaged subject의 **일부만 커버(≈29%)**. nb01 `meta['note']`에 명시.
- manifest 718 subject 중 clinical→매핑 가능 subject는 **207개 (29% of manifest)**. 세션 기준으로도 1420 세션 중 **29%만** raw clinical row-level join 가능.
- 나머지 ~71%의 CDR 라벨은 raw clinical이 아니라 **manifest `raw_input`(=`cdr_global`) 기준**으로 채워짐. 즉 `OASIS_meta.csv`를 join해 MMSE·APOE 등 추가 변수를 붙이면 대다수 세션이 결측이 된다 — 실험 설계 시 두 라벨 출처를 혼동하지 말 것.
- manifest `cdr_global`은 이미 통합된 라벨(`cdr_source`: visit_level_v7 1402 / baseline_broadcast 18). raw clinical은 그 출처와 부가 변수를 제공한다.

## 보유 임상변수 (`OASIS_meta.csv`, 결측%는 811행 기준)

| 역할 | 컬럼 | dtype | 결측% | nunique |
|---|---|---|---|---|
| dx | `Diagnosis` | object | 0.0% | 3 |
| cdr | `cdr` | float64 | 0.0% | 3 |
| mmse | `mmse` | int64 | 0.0% | 16 |
| age | `Age` | int64 | 0.0% | 20 |
| sex | `M.F` | object | 0.0% | 2 |

부가 컬럼(존재): `dx1`, `Class`, `Scanner`, `MagneticFieldStrength`. (결측 0%는 `OASIS_meta.csv`에 행이 존재하는 811 subject 한정 — 위 커버리지 함정과 함께 해석.)

## 진단·CDR 분포

### CDR (manifest 1420 세션, `cdr_global` — 전체 커버) ✅
| cdr_global | 세션 수 |
|---|---|
| 0.0 | 1133 |
| 0.5 | 209 |
| 1.0 | 72 |
| 2.0 | 6 |

### 진단 라벨 (raw_input manifest 1615 세션) ✅
| diagnosis | 세션 수 |
|---|---|
| CN | 1312 |
| AD | 253 |
| MCI | 50 |

### 작업 지시서 제시 분포 (CN 1126 / MCI 42 / AD 252) `[VERIFY]`
- 이 삼중값은 위 두 출처(1420 `cdr_global` 또는 1615 raw diagnosis) 어느 쪽으로도 직접 재현되지 않음. subject 단위 또는 별도 derived diagnosis 컬럼 기준일 가능성 — 출처 컬럼/필터 확인 필요.

## 나이·성별

| 지표 | 값 | 근거 |
|---|---|---|
| Age (raw_input 1615 세션) | mean 70.7, min 42.7, max 97.1 | `oasis_official_v2_raw_input_manifest_1615.csv` |
| Sex (raw_input 1615 세션) | F 948 / M 667 | 동일 |

## 종단(longitudinal) 구조 ✅

- manifest 기준 1420 세션 / 718 subject / subject당 **최대 8 세션**(평균 ~2.0 세션/subject).
- raw_input 1615 세션 기준에서도 subject당 최대 8 세션(평균 ~2.15).
- 다중 visit 구조이므로 split 시 subject-level grouping(LOCO 등) 필수.

## Centiloid / amyloid / PET

- `OASIS_meta.csv` 핵심/부가 컬럼에 centiloid·amyloid·APOE·PET SUVR 컬럼은 확인되지 않음 `[VERIFY]`.
- full_preprocessed manifest에 `do_not_use_for_pet_suvr` 플래그가 존재 — PET SUVR 산출은 현재 비활성/차단 상태로 취급. 별도 PET 소스 연결 여부 미확인 `[VERIFY]`.

## ROI 상태 — BLOCKED_PROVISIONAL ⚠️

`oasis_t1w_full_preprocessed_ready_manifest_1615.csv` 기준 전 세션(1615/1615):

| 플래그 | 값 |
|---|---|
| `roi_current_status` | BLOCKED_PROVISIONAL |
| `roi_block_reason` | "FastSurfer-to-native transfer requires ROI-specific visual approval; legacy ROI dirs and repair candidates are provisional." |
| `do_not_use_for_atlaswide_roi_features` | True |
| `roi_final_ready` | False |
| `roi_visual_anatomical_pass` | False |
| `t1w_ready` | True 1609 / False 6 |

→ T1w 영상은 ready(1609)이나 **ROI 피처는 시각적 해부 승인 미완으로 사용 차단**. ROI 기반 분석은 BLOCKED_PROVISIONAL 병기 필수.

## 출처

- `/home/vlm/minyoungi/Clinical/consortiums/OASIS/OASIS_01_clinical_eda.ipynb` (2026-06-02)
- `/home/vlm/minyoungi/Clinical/common/{clinical_io,mri_io}.py` — `load()`, `load_manifest()` (2026-06-02)
- `/home/vlm/data/preprocessed_official/v2/OASIS/manifests/oasis_official_v2_raw_input_manifest_1615.csv` (2026-06-02)
- `/home/vlm/data/preprocessed_official/v2/OASIS/manifests/oasis_t1w_full_preprocessed_ready_manifest_1615.csv` (2026-06-02)
