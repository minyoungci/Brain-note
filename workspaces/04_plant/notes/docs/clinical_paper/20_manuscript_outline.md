# Manuscript 골격 (draft skeleton) — amyloid–vascular 이중 예후축

> 2026-06-24. 확정 결과(`11_final_results.md`) 슬롯. 베뉴/delta는 lit-scout(ART2026·Lee2016) 후 확정. 본문 prose는 그 다음.

## Working title (후보 — outcome=2년 인지쇠퇴(ΔMMSE), NOT 전환/독립축)
- "Amyloid and clinically-defined vascular etiology independently predict 2-year cognitive decline in real-world Asian MCI, with age-dependent amyloid effect"
- (대안) "Baseline amyloid and vascular etiology, not WMH volume, predict cognitive decline in a real-world memory-clinic MCI cohort"
- ⚠️ 헤드라인 outcome=**ΔMMSE(인지쇠퇴)**. 전환(47%)·"독립축"·trajectory 과대포장 금지(진단필드·2-wave·Vemuri2015).

## Abstract (구조화 — 수치 확정)
- **Background:** amyloid-enriched 연구코호트(ADNI/A4)·cross-sectional 레지스트리(K-ROAD)는 실세계 etiology 분포와 종단 예후를 동시에 못 본다. 실세계 Asian MCI에서 멀티모달 위 예후 구조 미확립.
- **Methods:** 단일기관 한국 memory clinic, MCI 중심 종단(n=286, median 1.94yr). baseline amyloid-PET·구조 MRI·WMH·혈액22종·APOE. outcome=ΔMMSE, MCI→AD 전환. 다변량(full 임상바)·Cox.
- **Results:** baseline amyloid(β−1.39, p=0.002)·vascular etiology(β−1.28, p=0.004)가 2년 ΔMMSE를 독립·**가산**(상호작용 없음) 예측, ΔCDR-global 일관. **amyloid 효과는 나이 의존적**(amyloid×age p=0.001, 젊은 MCI서 강). 객관적 WMH 부피·혈액(루틴)은 독립기여 없음.
- **Conclusion:** 실세계 MCI 인지쇠퇴는 amyloid·vascular 두 baseline 인자로 예측되며 amyloid는 *젊을수록* 예후적. vascular 신호는 WMH 부피가 아닌 임상 병인. 자원·나이-층화 함의.

## 1. Introduction (gap → claim)
- amyloid 예후는 ADNI서 확립되나 실세계 Asian·vascular 동반 미흡.
- K-ROAD: ethnic 분포 선점, 종단 예후 불가(저자 명시).
- 실세계 memory clinic은 vascular/혼합 다수(연구코호트 배제) → 이중 etiology 가설.
- 본 연구: full-stack 통제 하 amyloid·vascular 이중축 + 가산 + 전환 정량.

## 2. Methods
- **코호트:** AJU memory clinic, V1 baseline·V2 TFU(edate), MCI 252·AD 32. 선택편향 동등성(추적 vs 전체).
- **측정:** amyloid-PET(visual+SUVR), FreeSurfer morphometry, WMH(FastSurfer WM-hypo 연속 + 시각등급), 혈액22종, APOE. etiology=임상 진단 라벨(혈관/혼합).
- **outcome:** ΔMMSE(연속), MCI→AD 전환(time-to-event).
- **통계:** 다변량 OLS(full 임상바), nested-CV 증분, Cox PHReg, 등가검정 보조. 사전지정 모델. subject-level.

## 3. Results (figure/table 매핑) — outcome=ΔMMSE(주)
- **Table 1** — 코호트.
- **R1 / Fig 2A(forest):** 두 축 독립 ΔMMSE 예측(amyloid β−1.39 p=0.002·vascular β−1.28 p=0.004, full보정), **상호작용 없음=가산**.
- **R2 / Fig 2B(2×2):** 가산 ΔMMSE(+0.12→−1.04/−1.68→−2.28). ΔCDR-global 일관(보조).
- **R3 / ★Fig 3(나이 층화):** **amyloid 예후효과 나이 의존**(amyloid×age p=0.001) — 젊은 MCI서 강, 고령서 소멸. *secondary 핵심 인사이트.*
- **R4 / within-MCI:** 진단 proxy 배제(둘 다 p<0.005).
- **R5 / Fig 2C(modality map):** amyloid·hippo 기여; **WMH 부피·혈액(루틴) null** → "vascular=병인 패턴≠부피". 연속 SUVR 용량반응 β−5.7.
- **R6(보조):** amyloid음성-임상AD = 혈관/혼합(11/17), 측정오류 아님(SUVR AUC0.97·etiology). 전환=치매진행(병인불문) 보조+한계.

## 4. Discussion
- 이중축 = 실세계 MCI 예후 구조. 연구코호트(amyloid 단일축)와 대비.
- WMH 부피 음성 → 임상-병인 gestalt가 예후 운반(vs imaging 정량). 자원 함의.
- K-ROAD 종단 공백을 메움. ethnic·실세계 일반화.

## 5. Limitations (정직)
- 단일기관·n=286·MCI중심. 전환 23 events(검정력 보통). MMSE screening급(CDR 보조).
- vascular etiology=임상 라벨(영상-정보; 단 outcome=미래라 비순환). vascular 연관 유의·CV예측증분 약함.
- **혈액=루틴 검사만, 혈장 AD마커(p-tau217/GFAP/NfL) 미통제** — "혈액 null"은 루틴검사 한정. K1(ART2026)은 p-tau217로 양성.
- 외부검증 제한(KDRC 종단 가용성 확인 필요).
- **선행 점유:** Vemuri2015(독립축)·K1(WMH부피·plasma)·K2(SVaD) — delta는 전환·병인라벨·clinic에 한정. "독립축" 단독 주장 회피.

## Tables / Figures
- T1 코호트 · T2 다변량(ΔMMSE·전환) 계수표.
- F1 etiology 구성+amyloid dissociation · **F2 forest+2×2+map** · **F3 KM 4군** · (S) EDA·robustness.
- 파일: `figs/{final_two_axis,km_conversion,eda_longitudinal}.png`.

## 베뉴/delta (lit-scout 확정 2026-06-24)
- **1지망 = JCN(Journal of Clinical Neurology, IF~3).** ART는 **K1이 거기 실렸고 너무 가까워 risk** → 제외. 임상·실증 발견이라 임상 SCI가 정직한 fork(CLAUDE.md §2).
- **delta 무게중심 (★"두 독립축"은 delta 아님 — Vemuri2015/K1/K2 점유):**
  > 실세계 memory-clinic **MCI** + **MCI→AD 전환(Cox HR)** + 가산 위험층화(47%vs1.5%) + **"vascular 신호=WMH 부피 아닌 *임상 병인 라벨*"(부피는 age-교란 null, K1/K2와 정반대)**.
- **점유 지형:** Vemuri 2015 Brain("vascular·amyloid independent predictors", 정상노인)=헤드라인 "독립축" 점유 → 우리는 *전환·병인라벨·clinic*으로 차별. K1(ART2026, 비치매 community, WMH부피, plasma통제)·K2(Ye 2015 Neurology, SVaD치매 n61)=부분점유.

## 인용·한계 정정 (lit-scout)
- **인용:** K2는 **Ye BS et al. 2015, Neurology** (≠ "Lee 2016"). 정정 필수.
- **한계 추가:** 혈액 22종 = **루틴 검사**(CBC·대사·지질·갑상선·B12), *혈장 AD마커(p-tau217/GFAP/NfL) 미포함*. K1은 p-tau217 양성. → "혈액 null"은 *루틴검사 한정*으로 정밀화 + "핵심 AD 혈장마커 미통제"를 한계로.
- **미해결:** Vemuri 2015 Brain 본문 정독(헤드라인 충돌 정도)·K1 전환-HR 모델 여부 `[VERIFY]`.
