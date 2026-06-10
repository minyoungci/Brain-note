# KDRC Clinical 상세 재파싱 — 발견 + 코드 범례 (2026-06-08)

소스: `/home/vlm/data/raw/KDRC/clinical.xlsx` '데이터' 시트 (**576행 × 287열**, 헤더 3행 / 데이터 row4부터).
코드 범례: 같은 파일 'MCD 설명' 시트. 전수 인벤토리: `kdrc_clinical_field_dictionary.csv`(이 폴더).

## ⚠️ 핵심 정정 — 우리가 놓쳤던 것들
이전에 KDRC를 "임상 빈약 + scanner 없음"으로 취급했으나 **틀렸다.** clinical.xlsx는 우리 7코호트 중 **단일 코호트로는 가장 풍부한 임상 데이터**다.

### 1. MRI 촬영기기(scanner) — "missing"이 아니라 **존재** (JT, idx280)
- 컬럼 `뇌 MRI > 촬영 정보 > 촬영 기기`, 범례: **1.Philips-Achieva / 2.Philips-Ingenia / 3.Siemens-Skyra / 4.GE** (vendor×model)
- 분포: 2=233, 1=133, 3=65, 4=47, 결측('-')=98 → **478/576 = 83% scanner 보유.** 4개 기종.
- → site/scanner-bias 작업에서 KDRC를 vendor×field로 조건화 가능(메모리 정정 대상).

### 2. Amyloid PET — SUVR + visual + scanner (JW~JZ)
- `JZ` 정량 SUVR(508 unique, ~576), `JY` 핵의학 visual 판독(1.Positive 383 / 2.Negative 193), `JX` PET 기기(1.Siemens/2.GE), `JW` 촬영날짜.
- → 우리가 "biomarker value 없음"이라던 amyloid가 **KDRC엔 SUVR 값으로 존재.**

### 3. APOE genotype — **100%** (JR, idx277)
- 범례: **1.E2/3 22 / 2.23 / 3.24 / 4.33 / 5.34 / 6.44**. 분포: 4(33)=267, 5(34)=200, 6(44)=74, 2(23)=20, 3(24)=7 → e4 보유(34,44) 다수. 576 전수.

### 4. Fazekas WMH (JU 뇌실주위 / JV 심부, 0-3)
- 범례: 0 없음/1 경도/2 중등도/3 고강도. ~292행 평가됨(나머지 '-'). 임상 백질변성 등급.

### 5. 전체 혈액검사 (IU~JQ, 576 100%)
- CBC(WBC/RBC/Hb/Hct/MCV/MCH/MCHC/PLT) + 화학(AST/ALT/BUN/Cr/공복혈당/HbA1c/TC/TG/HDL/LDL) + TSH/fT4 + RPR + B12/Folate.

### 6. 공존질환 21종 (AB~BB, 576): 당뇨·고혈압·고지혈증·갑상선·간·출혈·심장·폐·관절·암·전신마취·두부외상·정신·뇌경색·뇌출혈·경련·신장·알코올·약물·시력·청력.

### 7. 신경심리 — CERAD(192) + SNSB(384) **상호배타 분할**(192+384=576)
- CERAD(CC~EF): C-fluency, BNT, **MMSE 총점(CL)+Z(CM)+항목(CG~CK)**, 단어목록기억/회상/재인, 구성, TMT, 숫자외우기, FAB, CLOX, Stroop.
- SNSB(EG~IG): Digit span, cancellation, repetition, K-BNT, praxis, 계산, Rey-CFT, SVLT, RCFT, COWAT, Stroop, **K_MMSE_total_score(HC)**, **K_IADL(HV/HW)**, B-ADL(HF), Sum_of_boxes(HG), CDT, SNSB-II 도메인(주의/언어/시공간/기억/전두, HX~IG).
- **MMSE 통합 커버리지**: CERAD `CL`(192) + SNSB `HC K_MMSE`(384) = **~576(전수)**, 단 두 컬럼·두 도구.

### 8. 치매척도 (IH~IQ, 576): **CDR Total(II) + Sum of Box(IJ) + 6도메인(IK~IP)** + **GDS 전반적황폐화(IQ, 1-7)**.
### 9. NPI (BT~BW): 빈도/심각도/빈도×심각도/고통. 기능평가(BX~BZ). 가족력(BQ~BS). 생활습관 흡연·음주(BD~BL). 신체계측 체중·맥박·혈압(BM~BP).
### 10. 인구학(L~R): 출생년도·성별(1남/2여)·교육연수·읽기·쓰기·결혼·손잡이.

## 주요 코드 범례 (MCD 설명)
| 필드 | 범례 |
|---|---|
| 진단 수준(D) | **1.정상(CN) / 2.경도인지장애(MCI) / 3.치매** |
| 진단 원인(E) | 1.알츠하이머 / 2.혈관성 / 3.루이소체 / 4.파킨슨 / 5.기타 |
| 성별(M) | 1.남 / 2.여 |
| APOE(JR) | 1.22 / 2.23 / 3.24 / 4.33 / 5.34 / 6.44 |
| MRI scanner(JT) | 1.Philips-Achieva / 2.Philips-Ingenia / 3.Siemens-Skyra / 4.GE |
| PET scanner(JX) | 1.Siemens / 2.GE |
| PET visual(JY) | 1.Positive / 2.Negative |
| Fazekas(JU/JV) | 0 없음 / 1 경도 / 2 중등도 / 3 고강도 |
| MRI 금기(Z) | 1.해당없음 / 2.심장박동기 / 3.제세동기 / 4.강자성금속 |

## 반드시 reconcile할 불일치
- **행 수**: clinical.xlsx = **576행** ↔ manifest KDRC = 909~920 세션. → 이 파일은 더 작은/다른 추출본일 수 있음. (다른 KDRC 파일: `KDRC_0513_extracted/KDRC_clinical.xlsx`, `데이터분양_..._2026-05-04.xlsx`)
- **진단 분포 불일치**: 이 파일 D-수준 = CN62/MCI210/치매304 ↔ manifest KDRC = CN282/MCI239/AD249. → manifest의 KDRC dx는 *다른 소스*에서 옴. 세션-조인 시 어느 dx를 쓸지 명시 필요.
- **결측 코드**: '-' 와 숫자 센티넬 혼재 → 파싱 시 '-' 제외 필수.
- **subject 식별자**: A열 `BCODE`(576 고유). 우리 세션(`subject_id`)과의 매핑 키 확인 필요.

## 의미
KDRC는 held-out 시험대인데 **scanner·APOE·amyloid SUVR·Fazekas·labs까지 갖춘 가장 풍부한 코호트**다. 이는 (a) scanner/site-bias 분석에 KDRC 포함 가능, (b) amyloid/APOE를 *서구 코호트엔 부족한* 검증축으로 활용 가능, (c) 단 clinical.xlsx(576)와 manifest(909~920) 정합이 선결.
