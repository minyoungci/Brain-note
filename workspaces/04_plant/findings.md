# plant — findings

> **목적:** 검증된 설계 결정·feasibility 제약·label table 통계·사전등록 판정기준 정리  ·  **출처:** SCRATCHPAD(Last updated 2026-06-01), prereg(2026-06-01), summary.json  ·  **갱신:** 2026-06-02

## 결과 상태: 결과 없음, 설계 단계

모델링 산출물 없음(`results/`·`configs/` 비어 있음). 아래는 (a) 검증된 설계 결정·feasibility 제약, (b) 빌드+검증된 label table 통계, (c) prereg의 사전등록 판정기준이다. 모든 c-index/AUROC 수치는 **미측정**.

## 1. 핵심 설계 결정 (✅ 검증됨)
- **Task**: CN-at-baseline → 미래 임의 시점 cdr_global≥0.5 도달(=ever-impaired). single baseline scan 입력, cross-cohort.
- **Primary endpoint**: time-to-event conversion (survival, Harrell c-index). binary fixed-horizon은
  follow-up 기간 confound 때문에 primary 불가 → survival framing 강제 (prereg §3).
- **Secondary**: Δcdrsb≥0.5 (AIBL 제외 — CDR-SB 없음).
- **Sensitivity**: 24m/36m fixed-horizon binary (interval cohort ADNI/AIBL/OASIS만), AUROC 문헌 연결용. NON-primary.
- **증분 측정 방식**: arm 간 절대 성능 비교가 아니라 **delta 위에서** — (volumetry+image)−(volumetry)의 paired-bootstrap Δc-index CI.
- **transport 기준**: pooled 유의성만으로 주장 금지. LOCO held-out fold별 전이가 필수.

## 2. 5-arm control battery (prereg §5, EXP01에서 survival로 적응)
동일 survival head(Cox / DeepSurv partial-likelihood), 동일 fold:
1. **clinical+volumetry("the bar")** — age, sex, baseline CDR-SB + FreeSurfer ROI(hippo·entorhinal·ventricle·inf-lat-vent·amygdala·parahippocampal L/R, head-size=fs_MaskVol). Penalized Cox. **deep이 이겨야 할 대상**.
2. **image-full** — deep baseline-scan 표현(+동일 clinical 공변량, 증분 검정용).
3. **mask-only** — brain-geometry 통제(T1 intensity 없이 mask만). 신호 출처 국소화용.
4. **shuffled-label** — leakage probe (c-index≈0.5가 정상).
5. **volumetry+image** — 증분 검정 본체.

## 3. Feasibility 제약 — 코호트별 시간정렬 가능 여부 (✅ agent 검증)

| cohort | 시간키 출처 | 시간정렬 | longit. 사용 | 제외 사유 |
|---|---|:--:|:--:|---|
| ADNI | session_id=calendar date | ✅ 가능 | ✅ 사용(LOCO held-out) | — |
| AIBL | session_id=calendar date | ✅ 가능 | ✅ 사용(train-pool) | CDR-SB 없음→cdrsb endpoint 제외 |
| A4 | session_id=VISCODE 개월 | ✅ 가능 | ✅ 사용(LOCO held-out) | follow-up 짧음(1.5y)·이산 |
| OASIS | session_id=days-from-baseline | ✅ 가능 | ✅ 사용(train-pool) | 전환자 30→held-out 불가 |
| NACC | session_id=이미지ID | ❌ 불가(순서 X) | ❌ 제외 | 시간 정렬 불가능 |
| AJU | V1/V2 (ordinal) | 🟡 부분 | ❌ 제외 | CN baseline 없음(memory-clinic 거의 순수 impaired) |
| KDRC | 단일세션 | ❌ N/A | ❌ 제외 | 단일세션, cross-sectional |

추가: clin_dx_label은 **subject-level 상수** → conversion 인코딩 불가. endpoint는 session-level cdr_global/cdrsb만 사용.

## 4. Converter sparsity 표 (CN baseline → 후속 cdr_global≥0.5)

| cohort | longit. subj | CN-baseline | converters | cens. follow-up median(y) | LOCO held-out? |
|---|---:|---:|---:|---:|:--:|
| ADNI | 849 | 464 | **130** | 5.72 | **yes** |
| A4 | 769(753 usable) | 560 | **98** | 1.50 | **yes** |
| OASIS | 363 | 317 | 30 | 5.01 | train-pool (30 pos: 부족) |
| AIBL | 178 | 126 | 14 | 3.11 | train-pool (14 pos) |
| **TOTAL** | **2159** | **1467** | **272** | — | |

(summary.json 검증치. cdrsb-prog05 pos: ADNI 410 / A4 221 / OASIS 57 / AIBL 0 = 688 / 1975 evaluable.)

> ⚠️ **수치 불일치 [VERIFY]**: SCRATCHPAD §4 feasibility 텍스트는 "A4 96, total 270"으로 기재하나, §5·prereg §4·summary.json은 모두 **A4 98, total 272**. 빌드 산출물(summary.json) 기준이 정합적이며 96/270은 구버전 추정치로 판단됨.

## 5. 사전등록 판정기준 (prereg §7 — 결과 산출 시 적용)

- **ACCEPT**: (volumetry+image)−(volumetry) Δc-index paired-bootstrap **CI 하한 > 0이 ADNI·A4 두 held-out fold 모두**.
- **REJECT(null)**: Δc-index CI가 ≥1개 held-out fold에서 0 포함 → primary finding으로 보고(+CI 폭, **MDE 분석**).
- image-full은 shuffled를 능가해야(sanity) 하고 mask-only와 비교해 신호 출처 국소화.
- pooled-only 유의성만으로는 어떤 주장도 하지 않음(per-fold transport 필수).

## 6. 사전 명시된 confound 통제 (prereg §6)

- follow-up 기간: survival이 native 처리 + arm별 followup_years 분포 보고 + <1y 제외 민감도.
- cohort-as-shortcut: cohort-ID-only baseline은 LOCO에서 c≈0.5(전이 실패)가 정상.
- leakage audit: subject-level split 분리·baseline feature에 미래 visit 정보 없음·shuffled≈chance. 모델 신뢰 전 실행.
- A4 regime shift: A4 held-out 별도 보고. A4 preclinical 전환을 ADNI clinical 전환과 headline에서 풀링 금지.
