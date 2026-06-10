# 한국 코호트(AJU·KDRC) Clinical 전수 EDA + 공통 Cross-walk (2026-06-09)

원본 raw에서 직접 로드·검증한 결과. 캐시: `_korean_cache/{aju_bl,kdrc}.parquet`, 로더: `_load_korean_raw.py`.

## 0. 소스 / 규모

| | AJU | KDRC |
|---|---|---|
| raw 파일 | `임상역학정보 분양_all.xlsx` BL시트 | `clinical.xlsx` '데이터'시트 |
| 행 × 열 | **1,322 × 876** | **576 × 287** |
| 식별자 | `epid` (ABD-기관-번호) | `BCODE` (A열) |
| 종단 | BL 1,322 + TFU 295(별도시트) | 단일 차수 |
| 기관 | 7개 (아주대/삼성서울/전남대/부산대/인하대 등) | 단일 분양본 |

> 로드 검증: AJU mmse_s=1321, APOE_opi=1321, ck_sdcode=1322 — dictionary nonnull과 100% 일치.

---

## Part A. 공통 도메인 Cross-walk (실제 분포 비교)

### A1. 인구학 / 신체계측
> ⚠️ **KDRC 환자 인구학 함정**: KDRC `clinical.xlsx`의 인구학 컬럼(L 출생년도/M 성별/N 교육연수)은 전부 **보호자(caregiver) 정보**다. **환자 본인 성별·나이·교육은 raw에 없음** → curated `clin_sex`/`clin_age`(v1 DEDUP 소스, 770/909)에서만 옴. (이전 EDA의 "KDRC 성별 377:199"는 보호자였음 — 정정)

| 변수 | AJU (raw 환자) | KDRC (환자 본인) | 비고 |
|---|---|---|---|
| age | 72.4±7.4 [45,93] | 72.3 (curated, n=770) | KDRC raw엔 환자 나이 부재 |
| 교육연수 | 8.4±4.8 | (raw는 보호자 교육만) | KDRC 환자 교육 raw 부재 |
| 성별(여:남) | 851:471 (64% 여) | **F497:M273** (curated, n=770) | AJU raw 0여/1남; KDRC 환자 성별=별도 curated |
| BMI | 24.0±3.3 | (없음) | AJU만 |
| weight | 59.1±9.7 | 59.7±19.1 ⚠️(max 433) | KDRC outlier |
| SBP/DBP | 133.5/77.2 | 128.9/72.6 ⚠️(SBP min 11) | KDRC outlier |

> KDRC 보호자 성별(raw M열) = 여377/남199 — **환자 아님**, manifest에 넣지 말 것.

### A2. 진단 (둘 다 보유, 체계 다름)
- **AJU** `ck_sdcode` 23-class → 3-class: **MCI 754 / AD 252 / CN 206 / OtherDem 110**
- **KDRC** `D-수준`(1정상2MCI3치매): **치매 304 / MCI 210 / 정상 62** + 진단원인 `E`(AD 412 / 기타 164)
- 공통점: 둘 다 **memory-clinic 코호트 → CN 적고 MCI/치매 편중**. KDRC가 치매 비율 더 높음.

### A3. 인지 — MMSE / CDR (둘 다 보유)
| | AJU | KDRC |
|---|---|---|
| MMSE | K-MMSE 총점 `mmse_s` (99.9%) | CERAD `CL`(192) + SNSB `HC`(384) coalesce |
| Global CDR | 0:42 / **0.5:1048** / 1:189 / 2:38 / 3:5 | 0:22 / **0.5:362** / 1:136 / 2:34 |
| CDR-SB | mean 2.64 | mean 3.50 |

**타당성 검증 (진단별 MMSE, AD<MCI<CN이어야 정상):**
- AJU: CN **26.4** > MCI **24.4** > AD **19.0** > OtherDem 18.6 ✓
- KDRC: CN **26.6** > MCI **25.4** > Dementia **18.5** ✓
- → 양 코호트 모두 단조관계 정상, 라벨-인지점수 정합성 OK.

### A4. APOE genotype (둘 다 100%, **코드순서 다름**)
| genotype | AJU | KDRC |
|---|---|---|
| E3/E3 | 821 | 267 |
| E3/E4 | 298 | 200 |
| E4/E4 | 41 | 74 |
| **e4 보유율** | **27%** | **49%** |
- 코드맵: AJU `3=E3/E3,4=E2/E4` vs KDRC `3=E2/E4,4=E3/E3` (코드 3·4 swap). raw 코드 직접 병합 금지.
- KDRC e4 보유율이 AJU의 ~2배 → KDRC가 amyloid+/치매 enriched 반영.

### A5. Amyloid PET (둘 다 보유, **시각판독 코드 반대**)
| | AJU | KDRC |
|---|---|---|
| visual | `Amy_opi` 정상 673 / 비정상 349 (34% 양성) | `JY` Positive 383 / Negative 193 (66% 양성) |
| 코드 | 1=정상(neg), 2=비정상(pos) | 1=Positive, 2=Negative ← **반대** |
| 정량 SUVR | 없음(visual만) | `JZ` mean 1.2 (n=507) ← **KDRC 고유** |

### A6. 혈액검사 (공통 22종, 분포 거의 일치)
mean±sd: AJU / KDRC
| Lab | AJU | KDRC | Lab | AJU | KDRC |
|---|---|---|---|---|---|
| WBC | 5.83 | 5.62 | T.Chol | 176.0 | 187.9 |
| Hb | 13.46 | 13.38 | TG | 130.3 | 124.5 |
| Hct | 40.6 | 40.7 | HDL | 55.6 | 56.7 |
| PLT | 227.9 | 223.7 | LDL | 98.4 | 109.7 |
| BUN | 16.2 | 17.7 | TSH | 2.40 | 2.07 |
| Cr | 0.83 | 0.85 | fT4 | 1.20 | 1.18 |
| AST | 23.6 | 27.8 | VitB12 | 735.6 | 766.3 |
| ALT | 19.5 | 21.9 | Folate | 10.4 | 14.0 |
| Glucose | 108.1 | 103.6 | HbA1c | 6.17 | 6.02 |
- 두 한국 노인 코호트의 혈액검사 분포가 매우 유사 → 병합 시 lab feature 안정적.

### A7. 공존질환 유병률 (양성 %)
| | AJU | KDRC |
|---|---|---|
| 당뇨 | 24% | 25% |
| 고혈압 | 59% | 44% |
| 고지혈증 | 39% | 44% |
| 심장질환 | 1% | 7% |
- 코드 반대: AJU 0아니오/1예, KDRC 1있음/2없음.

### A8. 우울척도
- AJU: SGDS-K 총점 6.1±4.9 (+ MADRS 10.5±11.1) — **2개 척도**
- KDRC: GDS 6.6±6.5 — 단일

### A9. MRI 시각판독 (둘 다 WMH, 척도 다름)
- AJU: WMH grade(Min 702/Mod 349/Sev 75) + Lacune count + **Scheltens 해마위축 Rt/Lt (1,126명)**
- KDRC: Fazekas 뇌실주위(0-3) + 심부(0-3) (~292명)

### A10. 생활습관 / ADL
- 흡연·음주: AJU=연속형(흡연량/음주량), KDRC=코드형(현재/과거/비흡연). 개념 공통, 형식 다름.
- ADL: AJU=Barthel ADL + S-IADL (49 컬럼), KDRC=B-ADL + K-IADL (367/307명).

---

## Part B. AJU 고유 강점
1. **신경학적 검사 29종** — aphasia/dysarthria/facial palsy/motor weakness(상하지 좌우)/sensory loss/tremor/rigidity/bradykinesia/parkinsonian gait. (KDRC 없음)
2. **Ischemia scale 2종** — Hachinski + Rosen 총점/평가. 혈관성 치매 감별축.
3. **소변검사 12종** — USG/pH/Nitrate/Protein/Ketone/Glucose/RBC/WBC/Bilirubin/Micro-albumin 등. (KDRC 없음)
4. **추가 화학** — Ca/P/Na/K/Cl/albumin/bilirubin/protein/Uric Acid/**Homocysteine**/**Hs-CRP**/ALP/Fibrinogen. (KDRC는 기본 화학만)
5. **MADRS** 우울척도, **MRI Scheltens 해마위축 정량 시각등급(1,126명)**.
6. **정신과 진단(pd_sdcode)** + KCD 코드.
7. **TFU 추적 시트(295명)** → 종단 가능.

## Part C. KDRC 고유 강점
1. **Amyloid SUVR 정량값** (n=507, mean 1.2) — AJU는 visual만. 연속형 amyloid 축.
2. **치매 가족력 구조화** (유무/관계와진단/진단연령) — AJU는 질환별 가족력만, 치매특정 없음.
3. **e4 보유율 49%** — amyloid+ enriched, AD 신호 강함.
4. **CERAD-K 완본(56변수)** — AJU엔 CERAD 원본 항목 부재(SNSB 중심).
5. **NPI(정신행동) 빈도×심각도×고통** 정량.

## Part D. ⚠️ 데이터 품질 이슈 (전처리 전 클리닝 필수)
| 항목 | 이슈 | 처리 |
|---|---|---|
| KDRC weight | max 433kg | >200 제거 |
| KDRC SBP | min 11 | <60 제거 |
| AJU HbA1c | max 45 (%) | >20 제거 |
| AJU TSH/fT4 | TSH 84, fT4 32 | 갑상선질환 vs 오류 구분 필요 |
| KDRC VitB12 | max 20000 | 보충제 복용 가능, winsorize |
| 결측코드 | '-', 숫자센티넬 혼재 | 로더에서 '-'→NaN 처리 완료 |

---

## Part E. VLM/ADLIP 관점 시사점
- **공통 12+ 도메인이 정렬 가능** → 두 한국 코호트를 단일 텍스트 스키마(인구학+인지+APOE+amyloid+혈액검사+공존질환+우울+WMH)로 통합 가능.
- **ADLIP 텍스트 modality보다 풍부**: ADLIP은 MMSE+APOE+CSF+FAQ. 여기는 MMSE+APOE+amyloid(SUVR/visual)+혈액검사 22종+공존질환+우울 → 더 두꺼운 임상 텍스트.
- **주의 — site/코호트 confound**: 진단분포가 AJU(MCI편중) vs KDRC(치매편중)로 달라 LOCO 평가 시 코호트 추측 shortcut 위험. [[scanner-site-bias-axes]]
- **코드 정규화 필수**: 성별/APOE/amyloid/공존질환 코드가 두 데이터 **반대 방향**. 통합 시 raw 코드 직접 병합 절대 금지, 표준 라벨로 변환 후 병합.
- **CN 부족이 3-class의 병목**: AJU CN 206 + KDRC CN 62 = 268. AD/MCI는 충분하나 CN은 서구코호트(ADNI/A4) 보강 필요.
