# Korean 통합 Manifest (AJU + KDRC, 공통 컬럼)

빌드: `build_korean_manifest.py` (소스: `_korean_cache/{aju_bl,kdrc}.parquet` + `official_manifest_full_n4_real_final.parquet`).
EDA 근거: `../KOREAN_AJU_KDRC_CLINICAL_CROSSWALK_EDA.md`.

## 산출물 2종

| 파일 | 단위 | 행 | 용도 |
|---|---|---|---|
| `korean_clinical_subject_level.parquet/.csv` | subject | **1,898** (AJU 1,322 + KDRC 576) | 순수 임상 통합 분석 |
| `korean_manifest_session_level.parquet/.csv` | 영상 세션 | **2,196** (AJU 1,287 + KDRC 909) | VLM 학습 (영상+ROI+임상 페어) |

## 공통 컬럼 스키마 (표준화 완료)
식별자 `consortium, subject_id` (+session: `session_id`, 영상/ROI 컬럼)
- 인구학: `sex`(M/F), `age`, `education_years`, `demo_source`
- 진단: `dx_3class`(CN/MCI/AD/OtherDementia/Dementia), `dx_detail`, `dx_source`
- 인지: `mmse`, `cdr_global`, `cdr_sb`
- 유전: `apoe_genotype`(E#/E#), `apoe_e4_count`
- amyloid: `amyloid_visual`(positive/negative), `amyloid_suvr`(KDRC만)
- 혈액검사 22종: `wbc rbc hb hct mcv mch mchc plt bun cr ast alt glucose hba1c tchol tg hdl ldl tsh ft4 vitb12 folate`
- 공존질환: `dm htn dyslipidemia` (0/1)
- 우울: `gds_total`, `gds_instrument`(척도 표기 — AJU SGDS-K 0-15 vs KDRC GDS, **점수 직접비교 금지**)
- 신체계측: `weight sbp dbp bmi`(bmi는 AJU만)
- WMH: `wmh_grade_visual`(AJU 1-3), `fazekas_pv`/`fazekas_deep`(KDRC 0-3) — **척도 달라 별도 컬럼**
- 품질: `qc_flags` (raw 보존 + 임상범위 밖 값 `{col}:oob` 표기)

## ⚠️ 표준화로 해결한 코드 반대방향 (raw 직접 병합 금지였던 것)
| 항목 | AJU raw | KDRC raw | → 표준 |
|---|---|---|---|
| sex | 0=여,1=남 | (raw엔 보호자만) | M/F |
| APOE | 3=E3/E3,4=E2/E4 | 3=E2/E4,4=E3/E3 | genotype 문자열 |
| amyloid | 1=정상(neg),2=비정상(pos) | 1=Positive,2=Negative | positive/negative |
| comorbidity | 0=no,1=yes | 1=yes,2=no | 0/1 |

검증: 표준화 후 AJU e4 27% / KDRC e4 49%, amyloid+ AJU 34% / KDRC 66% — raw 분포와 일치.

## 커버리지 / 한계
- **AJU 거의 100%** (raw 1,322 환자 본인 인구학·임상 완비).
- **KDRC 환자 인구학(sex/age)은 raw에 없음** → curated `clin_sex/clin_age`(v1 DEDUP)에서 옴. raw L/M/N은 **보호자** 정보.
- **KDRC clinical↔영상 매칭 534/909 세션(59%)**: `clinical.xlsx` 분양본(576명)이 영상 manifest(909세션)의 일부만 커버. ID 형식은 동일(8자리), 단순 미포함. → session-level KDRC 임상 부착 ~59%, labs 83%(전체).
- KDRC 교육연수: raw에 환자 값 없음(보호자만) → 전부 NaN.

## session-level 컬럼 사용 가이드
- **진단**: `dx_session` (AJU=aju_dx3, KDRC=clin_dx_label; session-aware) 권장. `dx_3class`는 baseline.
- **인지**: `mmse_session`(v3 session-aware) 권장. `mmse_baseline`은 raw baseline.
- **검사패널**(labs/apoe/amyloid/comorbidity/wmh): baseline-stable, subject_id로 broadcast.

## 타당성 (진단별 MMSE, 정상 단조)
- AJU: CN 26.4 > MCI 24.4 > AD 19.0 > Other 18.6
- KDRC: CN 26.6 > MCI 25.4 > Dementia 18.5
