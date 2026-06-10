# 03 · 처리 데이터 정본 (Korean: AJU·KDRC, 임상 + 영상/ROI)

> **목적**: "우리가 실제로 처리한 데이터가 정확히 무엇인가"의 단일 정본(canonical spec). 연구 계획·논문 Methods·VLM 학습은 이 문서의 검증된 수치 위에서만 출발한다.
> **범위**: Korean 코호트(AJU·KDRC)의 임상 + 영상/FastSurfer ROI. 7-코호트 영상 전체 자산은 `00_data_constraints.md` 참조.
> **검증**: 모든 수치는 2026-06-10에 산출물 manifest에서 **재계산**(문서 복사 아님). 50+ 수치를 `notna().sum()` 직접 카운트로 assertion 검증 → ALL PASS(생성과 분리된 독립 단계).
> **언어**: 척도/코드 비호환은 "직접 비교 금지"로 명시. 낙관 수치 없음 — 결측은 결측으로 적는다.

---

## 1. Provenance / Lineage (소스 → 처리 → 산출물)

```
[raw 분양본]
  AJU  임상역학정보 분양_all.xlsx (BL시트)  ─┐
  KDRC clinical.xlsx (데이터시트)          ─┤
        │  _load_korean_raw.py            │  결측코드('-',''→NaN) 정규화, 헤더 다단 ffill
        ▼                                 ▼
  _korean_cache/aju_bl.parquet (1322×876)
  _korean_cache/kdrc.parquet   (576×287)
        │
        │  build_korean_manifest.py  ← 코드 표준화(반대방향 통일) + QC flag + 공통 51컬럼 정렬
        │       ├─ 임상 baseline (AJU epid / KDRC BCODE)
        │       └─ 영상행 병합: official_manifest_full_n4_real_final.parquet
        │              + enrich_aju_adni_clinical_v3.py (AJU session-aware dx/mmse)
        │              + enrich_kdrc_clinical_v2.py     (KDRC curated demo/dx)
        ▼
  [산출물 2종 — Clinical/consortiums/Korean/]
   korean_clinical_subject_level.{parquet,csv}   1,898 × 51
   korean_manifest_session_level.{parquet,csv}   2,196 × 76
```

| 단계 | 파일 | 역할 |
|---|---|---|
| 로더 | `Clinical/consortiums/_load_korean_raw.py` | raw xlsx → 표준 parquet 캐시. AJU(헤더 row1 eng, data row3+), KDRC(헤더 3행 ffill, excel_col→position) |
| 캐시(소스) | `Clinical/consortiums/_korean_cache/{aju_bl,kdrc}.parquet` | 표준화 raw. 모든 재현의 입력 |
| 임상강화 | `roi_qc/scripts/enrich_aju_adni_clinical_v3.py` | AJU session-aware(V2→TFU, V1→BL) MMSE/dx + ADNI MMSE(nearest≤365d) |
| 임상강화 | `roi_qc/scripts/enrich_kdrc_clinical_v2.py` | KDRC curated demo/dx (NaN-only additive, 13022행 불변 assert) |
| 영상 정본 | `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet` (13,022×122) | N4 텐서 경로 + FastSurfer ROI 소스. `[[manifest-real-final]]` |
| 빌더 | `Clinical/consortiums/Korean/build_korean_manifest.py` | 정본 2종 생성. 코드맵·QC RANGES·COMMON_ORDER 정의 |

---

## 2. 산출물 정의

| 산출물 | 단위 | 행×열 | 무엇 | 1차 용도 |
|---|---|---|---|---|
| `korean_clinical_subject_level` | subject | **1,898 × 51** (AJU 1,322 + KDRC 576) | 순수 임상, 영상 무관 | 임상 통계, 텍스트 스키마(시나리오 B) |
| `korean_manifest_session_level` | 영상 세션 | **2,196 × 76** (AJU 1,287 + KDRC 909) | 영상경로 + ROI + session-aware 임상 | VLM 페어 학습(시나리오 A), fusion(C) |

**종단 구조 (검증)**
- **AJU**: 1,287 세션 / **1,001 subject** — `V1` 954, `V2` 287, `ses-1` 46. → **종단 추적 존재**(동일인 다회 방문).
- **KDRC**: 909 세션 / **909 subject** — 전부 `ses-1`. → **단면(1인 1회)**.

> ⚠️ subject-level(1,898)과 session-level의 subject 수(AJU 1,001 + KDRC 909 = 1,910)는 **다른 모집단**이다. subject-level은 *임상 분양본*(AJU 1,322 / KDRC 576) 기준, session-level subject는 *영상 보유자* 기준. 두 수를 같은 N으로 혼용 금지.

---

## 3. 공통 51컬럼 스키마 (subject-level) + 검증된 커버리지

식별자: `consortium, subject_id`

| 도메인 | 컬럼 | ALL | AJU | KDRC |
|---|---|---|---|---|
| 진단 | `dx_3class` `dx_detail` `dx_source` | **100%** | 100% | 100% |
| 인지 | `mmse` | 97% (1,834) | 100% (1,321) | 89% (513) |
| 인지 | `cdr_global` `cdr_sb` | 99% (1,876) | 100% | 96% (554) |
| 유전 | `apoe_genotype` `apoe_e4_count` | **100%** (1,897) | 100% (1,321) | 100% (576) |
| amyloid | `amyloid_visual` | 84% (1,598) | 77% (1,022) | 100% (576) |
| amyloid | `amyloid_suvr` (KDRC 고유) | 27% (507) | 0% | 88% (507) |
| 혈액 22종 | `wbc rbc hb hct mcv mch mchc plt bun cr ast alt glucose hba1c tchol tg hdl ldl tsh ft4 vitb12 folate` | ~100% | ~100% | ~100% |
| 공존질환 | `dm htn dyslipidemia` (0/1) | ~100% | 100% | 98% (567) |
| 우울 | `gds_total` `gds_instrument` | 99% (1,875) | 99% | 99% |
| 신체 | `weight sbp dbp bmi`(bmi=AJU만) | AJU~100% | — | — |
| WMH | `wmh_grade_visual`(AJU 1–3) | 59% (1,126) | 85% (1,126) | **0%** |
| WMH | `fazekas_pv` `fazekas_deep`(KDRC 0–3) | 15% (292) | **0%** | 51% (292) |
| 인구학 | `age` `sex` | 91% (1,719) | 100% (1,322) | **69% (397)** |
| 인구학 | `education_years` | 70% (1,321) | 100% (1,321) | **0%** |
| 인구학 | `demo_source` | — | raw | curated |
| 품질 | `qc_flags` | — | — | — |

**dx_3class 실분포 (검증)** — ⚠️ **라벨 체계가 코호트마다 다름**:
- AJU: MCI 754 / AD 252 / **CN 206** / OtherDementia 110 (4-class)
- KDRC: Dementia 304 / MCI 210 / **CN 62** (3-class, "AD"가 아니라 "Dementia")
- → pooled 시 `AD`(AJU)와 `Dementia`(KDRC)는 **같은 라벨이 아님**. OtherDementia(AJU 110)는 KDRC에 대응 없음.

---

## 4. session-level 추가 컬럼 (76 = 51 공통 + 영상/ROI/session-aware)

| 그룹 | 컬럼 | 커버리지 |
|---|---|---|
| 영상 경로 | `final_tensor_path` `final_mask_path` | **100%** (2,196 전부) |
| 영상 QC | `final_qc_status` `fs_qc_status` `roi_usability` `roi_final_ready` `tensor_exists` | 영상 유래 |
| FastSurfer ROI | `fs_MaskVol` `fs_BrainSegVol` + `fs_vol_{hippocampus,amygdala,entorhinal,lateral_ventricle}_{L,R}` (8 ROI) | 영상 유래 |
| **session-aware 임상** | `dx_session` | AJU 100% / **KDRC 85% (770)** |
| (권장 사용) | `mmse_session` | AJU 100% / KDRC 52% (477) |
| | `cdr_global_session` | AJU 100% / KDRC 59% (534) |
| baseline 원본 | `mmse_baseline` `cdr_global_baseline` `cdr_sb_baseline` | broadcast |
| broadcast 패널 | `apoe_*` `amyloid_*` `labs` `dm/htn/dyslipidemia` `gds` `wmh/fazekas` | AJU 100% / **KDRC 59% (534)** |

**영상 텐서 사양**: 192×224×192, identity affine, z-score 정규화, N4 보정. 예: `…/v2/AJU/subjects/ABD-AJ-0001/V1/t1w/final_tensor/t1w_brain_1mm_RAS_192x224x192_zscore.nii.gz`. ⚠️ v2 텐서는 N4는 적용했으나 site shortcut 잔존(probe 0.565) — `[[v2-no-n4-bias-correction]]` 주의.

**session-level 사용 규칙**:
- 진단/인지/CDR → `dx_session`/`mmse_session`/`cdr_global_session` 사용(session-aware authoritative). `dx_3class`/`mmse`는 baseline broadcast.
- ⚠️ **KDRC 두 분모를 구분하라**: `dx_session`(curated v3 라벨) **85%(770)** ≠ broadcast 패널(apoe/amyloid/labs, clinical.xlsx 매칭) **59%(534)**. amyloid·labs는 770이 아니라 **534에만** 붙는다.

---

## 5. 코드 표준화 (raw 직접 병합 금지였던 것 — 검증 완료)

AJU·KDRC는 **반대 방향 코딩**. 빌더에서 표준 라벨로 변환 후 병합.

| 항목 | AJU raw | KDRC raw | → 표준 | 검증 분포 |
|---|---|---|---|---|
| sex | 0=여,1=남 | (raw는 보호자만) | M/F | AJU 64% 여 |
| APOE | 3=E3/E3, 4=E2/E4 | 3=E2/E4, 4=E3/E3 (3·4 **swap**) | genotype 문자열 | E3/E3 AJU 821·KDRC 267 |
| e4 보유율 | — | — | `apoe_e4_count` | **AJU 27% / KDRC 49%** |
| amyloid visual | 1=정상(neg), 2=비정상(pos) | 1=Positive, 2=Negative (**반대**) | positive/negative | **양성 AJU 34% / KDRC 66%** |
| comorbidity | 0=아니오,1=예 | 1=있음,2=없음 (**반대**) | 0/1 | DM ~24–25% 양 코호트 |

> e4율·amyloid+가 KDRC ≈ 2×AJU — KDRC가 amyloid+/치매 enriched임을 일관되게 반영(표준화 정확성 교차검증 통과).

---

## 6. QC flag 정책 (raw 보존 + 범위밖 표기)

- 원칙: outlier를 **삭제·치환하지 않음**. raw 값 유지 + `qc_flags`에 `{col}:oob;` 누적.
- subject-level 플래그된 행 = **40 / 1,898**. 분포(상위): `tsh` 14, `hba1c` 5, `vitb12` 4, `folate` 3, `glucose` 3, `weight` 2, `hct` 2, `bun` 2, `mcv` 1, `mchc` 1 …
- 사용 측이 분석 전 `qc_flags` 비어있는 행만 필터하거나 winsorize 결정. (예: VitB12 max 20000 = 보충제 복용 가능 → 삭제 아닌 winsorize 권장)

---

## 7. 검증된 한계 (활용 전 필수 인지)

| # | 한계 | 정확한 수치 | 영향 |
|---|---|---|---|
| 1 | **CN 부족** | subject CN = AJU 206 + KDRC 62 = **268** | 3-class·정상감별 병목. 서구코호트(ADNI/A4) 보강 전제 |
| 2 | **KDRC 임상 패널 커버리지** | session broadcast(apoe/amyloid/labs) **534/909 = 59%**; subject 576 | clinical.xlsx 분양본(576)이 영상(909)의 일부만 커버. 상한 59% |
| 3 | **KDRC dx vs 패널 분모 상이** | dx_session **770(85%)** ≠ 패널 **534(59%)** | 라벨은 770, 검사값은 534. 동일 N으로 취급 금지 |
| 4 | **KDRC 환자 인구학** | sex/age subject **397/576(69%)**, 교육 **0%** | raw L/M/N은 **보호자** → curated 의존. 교육연수 전무 |
| 5 | **amyloid 척도 비대칭** | AJU=visual만(1,022), KDRC=SUVR(507)+visual(576) | visual↔SUVR 통합/분리 학습 결정 필요 |
| 6 | **CSF 전무** | 7코호트 공통 부재 | ADLIP의 CSF 축 불가 → amyloid PET로 대체. `[[csf-absent-all-cohorts]]` |
| 7 | **라벨 체계 불일치** | AJU{CN,MCI,AD,OtherDem} vs KDRC{CN,MCI,Dementia} | "AD"≠"Dementia". pooled 라벨 정의 선결 |
| 8 | **코호트 confound** | AJU MCI편중 vs KDRC 치매편중 | LOCO 시 코호트 추측 shortcut. `[[scanner-site-bias-axes]]` |
| 9 | **척도 비호환(별도컬럼)** | 우울 SGDS-K(AJU)/GDS(KDRC), WMH visual(AJU)/Fazekas(KDRC) | **점수 직접비교 금지** |

---

## 8. 재현 (Reproducibility)

```bash
# 1) raw → 표준 캐시 (이미 생성됨; raw 갱신 시에만 재실행)
uv run python Clinical/consortiums/_load_korean_raw.py
# 2) 정본 2종 재생성 (코드맵/QC/병합 전부 이 안에)
uv run python Clinical/consortiums/Korean/build_korean_manifest.py
# 3) 수치 검증: df.notna().sum() 직접 카운트로 본 문서 커버리지 재산출
#    (작성 시 50+ 항목을 assertion으로 교차검증 → ALL PASS)
```

검증 기대값(정상 출력 기준): subject (1898,51) AJU1322/KDRC576, session (2196,76) AJU1287/KDRC909, dx_3class 100%, apoe 100%, KDRC 패널 broadcast 534(59%).

---

## 9. 연결

- 영상 자산 전체(7코호트, 닫힌/열린 방향): [`00_data_constraints.md`](00_data_constraints.md)
- Korean 스키마/활용: `../Clinical/consortiums/Korean/{README, USAGE_ROADMAP}.md`
- 전수 EDA(분포 비교): `../Clinical/consortiums/KOREAN_AJU_KDRC_CLINICAL_CROSSWALK_EDA.md`
- 메모리: `[[korean-unified-manifest]]` `[[korean-cohort-enrichment-v3]]` `[[manifest-real-final]]` `[[aju-clinical-rich]]` `[[kdrc-clinical-rich]]`
