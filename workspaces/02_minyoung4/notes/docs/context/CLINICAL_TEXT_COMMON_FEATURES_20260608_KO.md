# 공통 Clinical Text Feature 인벤토리 + 채택 스키마 (2026-06-08)

상태: **인벤토리/스펙 문서.** non-null 실측 기반(컬럼 존재 ≠ 값 채워짐). 7코호트 raw 임상 + manifest 교차검증. 다음 단계(harmonized 조인)의 입력 스펙.

근거: 깊은 인벤토리 에이전트(read-only, data-dictionary 기반) + 본 세션 검증. ADLIP(Lin 2025) 텍스트 재현 가능성 분석의 후속.

---

## 0. 검증으로 정정된 전제 (중요)
- **KDRC '데이터' 시트는 헤더 3행 / 데이터 row4부터.** 영문 `K_MMSE_total_score`·SNSB-II 영문컬럼은 **값 0%(껍데기)**. 실제 채워진 건 **MMSE총점(col89)·CDR(col242)·Sum of Box(col243)·CERAD 한국어 배터리**.
- **AJU = 7번째 코호트**(SNSB 한국어 배터리, MMSE 부재 가능성). raw: `/home/vlm/data/raw/AJU/metadata/임상역학정보 분양_all.xlsx`(중첩헤더, 미완 디코딩 → manifest 기준 보고).
- **manifest가 raw를 대폭 under-join**: KDRC MMSE raw 100% ↔ manifest 0%, OASIS mmse raw 100% ↔ manifest 29%, education/APOE도 A4·NACC만 조인. **→ manifest 신뢰 말고 raw 재조인.**
- **manifest `clin_moca` NACC=100%는 -4 센티넬 오염**(실제 raw 37.7%).

---

## 1. 최대 중복 공통 feature 랭킹 (값 보유 코호트 수, KDRC=held-out 별도)

| 순위 | feature | 값보유 코호트수 | KDRC | 라벨누수 | 도구이질 |
|---|---|---|---|---|---|
| 1 | **CDR-global** | 7/7 | ✓100% | **높음**(dx와 ~83%) | 낮음 |
| 2 | **age** | 7/7 | ✓ | 낮음 | 낮음 |
| 3 | **sex** | 7/7 | ✓ | 낮음 | 낮음 |
| 4 | diagnosis(target) | 7/7 | ✓ | =타깃 | 중(체계상이) |
| 5 | **CDR-SB** | 6(AIBL raw 제외) | ✓100% | **높음** | 낮음 |
| 6 | **education** | 6(AIBL 제외) | ✓ | 낮음 | 중 |
| 7 | **MMSE** | 5(ADNI 제외) | ✓100% | 중 | 중-높음(MMSE/K-MMSE/MoCA) |
| 8 | **APOE** | 5(ADNI 제외) | ✓100% | 낮음 | 중 |
| 9 | memory recall | 5(ADNI 제외) | ✓(CERAD형) | 중 | **높음**(LogMem/CERAD/SNSB) |
| 10 | race/ethnicity | 4 | ✗ | 낮음 | 중 |
| 11 | functional/IADL | 4 | ✓(도구혼재) | 중 | **매우높음** |
| 12 | MoCA | 2(저커버) | ✗ | 중 | — |
| 13 | depression(GDS) | 3 | ✓ | 낮음 | 중 |

---

## 2. 채택 스키마 (공통 clinical text)

### Tier A — 전 7코호트 공통, 무조건 채택
`age, sex, CDR_global, diagnosis(target)` — 모두 ≥98% non-null.

### Tier B — ≥5코호트 + KDRC 보유, 채택(누수/이질 주의)
`CDR_SB, education, MMSE, APOE` — ADNI는 MMSE·APOE를 IDA 추가 다운로드 필요.

### Tier C — 조건부(harmonization 전엔 보류)
`memory_recall, functional/IADL, GDS` — 도구 제각각 → site 지문 위험. **MoCA 제외**(KDRC 없음·33~38% 저커버 → held-out 무용).

---

## 3. 코호트별 source column (조인용 — 바로 사용)

| feature | ADNI | A4 | AIBL | NACC | OASIS | KDRC |
|---|---|---|---|---|---|---|
| age | PTDOB→계산 | PTAGE | PTDOB | NACCAGE | AgeatEntry/meta:Age | 데이터!col11 출생년도 |
| sex | PTGENDER | PTGENDER | PTGENDER | SEX | GENDER | col12 성별 |
| education | PTEDUCAT | PTEDUCAT | (없음) | EDUC | demo.zip:EDUC | col13 교육연수 |
| MMSE | **IDA 필요** | mmse:MMSCORE | mmse:MMSCORE | NACCMMSE(88/95-99=결측) | meta:mmse | **col89 MMSE총점** |
| CDR_global | CDR:CDGLOBAL | cdr:CDGLOBAL | cdr:CDGLOBAL | CDRGLOB | meta:cdr | **col242 CDR** |
| CDR_SB | CDRSB | cdr:CDRSB | (없음) | CDRSUM | (UDS) | **col243 Sum of Box** |
| diagnosis | entry_research_group | (파생) | pdxconv:DXCURREN | NACCUDSD | dx1/Diagnosis | col3 수준(+col4 원인) |
| APOE | **IDA 필요** | External Data | apoeres:APGEN1/2 | NACCAPOE(87%) | demo.zip:APOE | col277 APOE genotype |
| memory_recall | (없음) | coglogic:LIMM/LDEL | neurobat:LIMM/LDEL | LOGIMEM/MEMUNITS(45%) | uds:LOGIMEM/MEMUNITS | col91/col99 단어목록기억·회상 |
| functional | (없음) | adlpqsp:AI* | (없음) | FAQ10(BILLS…TRAVEL,74%) | (C1) | col75 기능총수행 |
| GDS | (없음) | (없음) | (없음) | NACCGDS(88%) | (UDS B6) | col54 노인우울척도 |

소스 파일:
- ADNI: `raw/ADNI/clinical data/{All_Subjects_CDR_02Nov2025, CDRSB_T1w_Images_ADNI_3_4_PTDEMOG_14Nov2025}.csv`
- A4: `raw/A4/Clinical/Raw Data/{ptdemog,mmse,cdr,coglogic,adlpqsp}.csv` + `External Data/`(APOE)
- AIBL: `raw/AIBL/meta/aibl_{ptdemog,mmse,cdr,neurobat,pdxconv,apoeres}_01-Jun-2018.csv`
- NACC: `raw/NACC/NACC-Clinical/commercial_nacc70.csv` (usecols 필수)
- OASIS: scan-linked `raw/oasis3/OASIS_meta.csv`(mmse/cdr/dx/age/sex 100%) + zip 내부 `OASIS3_demographics.csv`(EDUC/APOE/race)·`OASIS3_UDSc1_cognitive_assessments.csv`(memory/MoCA), OASISID 조인
- KDRC: `raw/KDRC/KDRC_0513_extracted/KDRC_clinical.xlsx` '데이터' 시트, **헤더 3행 / row4부터**

---

## 4. 정직 플래그 (조인/모델 설계 시 필수)
- **(a) 라벨 누수**: CDR(-SB)는 dx와 ~83% 일치(OASIS/ADNI는 dx가 CDR 파생). MMSE도 인지=타깃 상관. → **진단 task caption에는 CDR/MMSE 금지**(또는 누수 통제·비-진단 타깃에만).
- **(b) 도구 이질 = site 지문**: 인지(MMSE/K-MMSE/MoCA), functional(FAQ/A4-AI/K-도구), memory(LogMem/CERAD/SNSB) 모두 코호트별 도구 상이 → harmonize 없이 합치면 코호트 식별자. 특히 held-out KDRC가 한국어 배터리라 *분포 자체가 site*.
- **(c) ADNI IDA 의존**: ADNI local raw에 **MMSE·MoCA·FAQ·APOE 없음** → IDA에서 별도 다운로드해야 Tier B의 ADNI 셀이 채워짐.
- **(d) 컬럼≠값**: NACC MMSE 실측 47%, MoCA 38%, FAQ 74%. 결측 센티넬(88/95-99, -4) 반드시 제외.
- **(e) AJU/OASIS 추가비용**: AJU SNSB 한국어 매핑 미완. OASIS edu/APOE/memory는 zip 내부 CSV를 OASISID로 추가 조인.

---

## 5. 다음 단계 (조인 contract)
- Task: raw에서 Tier A+B feature를 코호트별 source column으로 추출 → canonical 스키마로 harmonize → subject+visit/date로 우리 세션(13,022)에 조인.
- Split: 한국(AJU/KDRC) held-out. probe-train=Western(ex-OASIS).
- Leakage: CDR/MMSE는 caption 정책상 진단 task에서 분리.
- Needs Min approval: ADNI IDA 다운로드(MMSE/APOE), 멀티코호트 조인(다파일), KDRC/AJU 한국어 헤더 매핑.
