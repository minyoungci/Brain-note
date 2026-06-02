# 00 · 공식 데이터 manifest 완전 이해

_5개 워크스페이스가 공유하는 단일 데이터 원천. 여기를 모르면 어느 연구도 못 읽는다._
_출처: plant SCRATCHPAD §1, minyoungi 2026-05-31 daily, minyoung2 SCRATCHPAD. (2026-06-02)_

## 1. 무엇인가

- **파일**: `/home/vlm/data/preprocessed_official/official_manifest_full.parquet`
  (CSV 버전 `official_manifest.csv`도 존재). **read-only canonical** — 절대 쓰지 마라.
- **규모**: 13,022 sessions × 75 cols, **1 row = 1 session**.
- **join key**: `tag = consortium_subject_session`.
- **데이터 사전**: `official_manifest_full.README.md` (같은 디렉토리).

## 2. 코호트 구성 (반드시 외울 표)

| cohort | sessions | subjects | ≥2 sessions | CN/IMPAIRED (subj, baseline) | 성격 |
|---|---:|---:|---:|---|---|
| A4 | 1811 | 992 | 793 | 710 / 282 | preclinical(amyloid+), CN 다수 |
| ADNI | 4742 | 1580 | 849 | 860 / 720 | 종단 풍부, 최대 |
| AIBL | 987 | 617 | 178 | 425 / 192 | 호주 |
| AJU | 1287 | 1001 | 286 | 27 / 974 | **memory-clinic, ~순수 impaired. CN source 아님** |
| KDRC | 909 | 909 | 0 | 280 / 629 | **엄격 cross-sectional(종단 0)** |
| NACC | 1866 | 1414 | 361 | 897 / 517 | US 다기관 |
| OASIS | 1420 | 718 | 363 | 518 / 200 | |
| **합계** | **13,022** | **7,231** | **2,830** | **3,717 / 3,514** | |

## 3. 라벨 가용성

- ✅ `cdr_global`, `cdrsb`: **100%**. 1차 endpoint의 권위.
- ✅ FastSurfer volumes (33 cols): **100%**. 신호 확인됨(hippo CN→CDR≥1에서 −20%).
- 🟡 `clin_dx_label`: 10,550 (CN 5025 / MCI 2937 / CN_preclinical 1811[=A4] / AD 558 / Dementia 165 / ImpairedNotMCI 54; **AJU=0**).
  - ⚠️ **subject-level 상수** → conversion(전환)을 인코딩 못 함. 종단 endpoint는 session-level `cdr_global`/`cdrsb`만 써야 한다.

## 4. ⚠️ 데이터 함정 (5곳에서 반복해서 사람을 죽인 것들)

1. **`cdr_global`은 string 타입.** `pd.to_numeric()` 안 하면 조용히 TypeError 나거나 `"0.5" < "1"` 문자열 비교로 오정렬. **모든 비교 전 숫자 변환.**
2. **single-cohort 함정** (한 코호트에만 있는 컬럼 — pooled로 쓰면 누수/편향):
   - `APOE`, `MoCA` = **NACC only**
   - `MMSE` = **ADNI에 없음**
   - `sex` = **A4·ADNI는 NaN** → `clin_sex_raw` 사용. AJU는 0=여/1=남(공식 설명서 확인).
3. **ROI는 fail-closed 잠정.** `roi_usability` USABLE_AUTO 12,932 (∪W_CAVEAT 99.5%)이지만
   `roi_final_ready`는 **전부 False** (사람 gold standard 없어 fail-closed). ROI 기반 정량 주장은 "검증"이 아닌 "후보".
4. **경로 정규화 버그 전례.** ADNI session_id가 `20061115.0`처럼 `.0`로 끝나는데 정규화가 `.0`를 떼면 ADNI 경로 전부 깨짐 → 과거 "FastSurfer 39% 결측"이 사실 이 버그였고, 전수검증 시 **13,022건 100% 존재**. 경로는 session_id 재구성 말고 `final_tensor_path`에서 유도.
5. **종단(시간) 정보 부재.** time-interval 컬럼 없음. interval은 session_id 파싱으로만:
   ADNI/AIBL=달력날짜, A4=VISCODE month, OASIS=baseline-from-days. **NACC=이미지ID(시간 아님, 정렬 불가), AJU=V1/V2(순서형), KDRC=단일세션.**

## 5. 텐서 표현

- `final_tensor`: 192×224×192, identity affine, z-score 정규화.
- `option_b`: final_tensor-grid ROI/aseg (FastSurfer/VINN). **VINN에 eTIV 없음** → MaskVol을 ICV proxy로.

## 6. 이 데이터로 무엇을 하나 (워크스페이스별 사용)

- **minyoung2 EXP01**: cross-sectional CN vs IMPAIRED, LOCO. 7코호트(AJU는 CN=27이라 holdout 부적격→train-only).
- **plant**: 종단 converter 예측. 시간정렬 가능 4코호트(ADNI/AIBL/A4/OASIS)만.
- **minyoung3 F04**: SSL corpus(라벨 없이) + official 라벨 probe 분리.
- **minyoungi**: clinical 이해 ipynb(00~04) + ROI QC.
