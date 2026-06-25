# Manuscript 골격 (draft skeleton) — amyloid–vascular 이중 예후축

> 2026-06-24. 확정 결과(`11_final_results.md`) 슬롯. 베뉴/delta는 lit-scout(ART2026·Lee2016) 후 확정. 본문 prose는 그 다음.

## Working title (후보 — ADNI benchmark 일반화, `13_defense_results.md`+`15_adni_comparator.py`+lit-scout 반영)
- "An AT(N) prognostic structure generalizes from a research cohort to a vascular-inclusive Asian real-world memory-clinic: neurodegeneration and amyloid burden, but not WMH burden, predict cognitive decline"
- (대안) "Neurodegeneration and continuous amyloid burden — not WMH burden — predict 2-year cognitive decline in real-world Asian MCI, replicating ADNI as a research-cohort benchmark"
- ⚠️ outcome=**ΔMMSE(MCI-only AJU n=252 / ADNI benchmark n=309, pooled 아님)**. 금지: "두 독립축(amyloid+vascular)"(Huber 사망)·"amyloid 나이의존"(ADNI 비재현)·"WMH null=발견"(Ye2015 반례→*경계조건*만)·"Fazekas null"(결측)·전환 47%.

## Abstract (구조화 — AT(N) 방어버전, `13_defense_results.md`)
- **Background:** amyloid-enriched 연구코호트(ADNI/A4)·cross-sectional 레지스트리(K-ROAD)는 실세계 etiology 분포와 종단 예후를 동시에 못 본다. 실세계 Asian MCI에서 AT(N) 멀티모달 위 예후 구조 미확립.
- **Methods:** 단일기관 한국 memory clinic AJU **MCI-only 종단(n=252, amyloid+=76, median 1.94yr)** + **ADNI를 research-cohort benchmark**(n=309 MCI, UCBERKELEY amyloid, pooled 아님·동일 모델 따로). baseline amyloid(visual/SUVR ↔ Centiloid)·해마/내후각 위축(N)·WMH(부피+시각)·APOE. outcome=ΔMMSE(연속)+의미있는 쇠퇴(≤−3). 다변량 + Huber/outlier/부트스트랩.
- **Results:** **신경퇴행(N)이 양 코호트서 가장 robust**(AJU β−0.71 p0.001 / ADNI β−0.35 p0.025). **연속 amyloid 부담도 양쪽 예측**(AJU SUVR p0.006 / ADNI Centiloid p0.001); **이진 amyloid 양성은 양쪽 약함**(연속>이진). A,N 독립(VIF~1.05). **정량·시각 WMH 부담은 AT(N) 통제 시 독립 예측 못 함**; pooled vascular 진단도 비robust(Huber p0.18, 신호는 Subcortical VaD n=7 국한). **amyloid×age는 AJU서만(p0.004), ADNI 비재현(반대 트렌드, age분포 동일)=비일반화.**
- **Conclusion:** AT(N) 예후구조(N+연속 amyloid 부담)가 연구코호트→혈관 미배제 Asian 실세계 MCI로 **일반화**; 이 세팅에서 예후는 WMH 부담이 아니라 amyloid+신경퇴행이 운반. (WMH는 SVaD/community 소견[Ye2015]의 *경계조건*; age-효과수정은 cohort-특이.)

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

## 3. Results (figure/table 매핑) — PRIMARY MCI-only n=252, outcome=ΔMMSE
- **Table 1** — 코호트(MCI-only n=252; full n=286 보조). selection: 추적군 경증(MMSE+1.2, amyloid 균형).
- **R1 / Table 2(★AT(N) robustness 표):** N(β−0.72,p0.001)·A(β−1.15,p0.011) robust(OLS+Huber+outlier+부트스트랩 전부), **V(p0.033→Huber 0.18 사망)·WMH(p0.80 null)**. A–N 독립(VIF1.05).
- **R2 / Fig 2A(forest):** N>A≫V 효과크기·CI. SUVR 연속 dose-response(β−5.17,p0.0004).
- **R3 / Fig 2B(이진 OR):** 의미있는 쇠퇴 amyloid OR 2.6(≤−3)/3.4(≤−2). threshold 의존(≤−4선 N/V로 이동) 정직 보고.
- **R4 / ★Table 3+Fig 3(ADNI benchmark 나란히):** 동일 모델 AJU↔ADNI. N·연속 amyloid **양쪽 재현**(일반화); 이진 amyloid 양쪽 약; **amyloid×age는 AJU만·ADNI 비재현**(age분포 동일=range 인공물 아님) → *secondary는 "age-의존"이 아니라 "일반화/비일반화 검정 자체"*.
- **R5 / Fig 2C(WMH 경계조건 패널):** AT(N) 통제 시 log부피·시각등급·사분위비선형 전부 null. *발견 아님 — Ye2015(SVaD, WMH positive) 대비 "MCI memory-clinic에선 WMH 예후기여 사라짐" 경계조건으로 서술.*
- **R6 / Table 4(vascular subtype, full):** pooled vascular 신호=Subcortical VaD(n=7, resid−2.48) 국한; Vascular MCI(n=46) 약함(resid−0.31).

## 4. Discussion
- 이중축 = 실세계 MCI 예후 구조. 연구코호트(amyloid 단일축)와 대비.
- WMH 부피 음성 → 임상-병인 gestalt가 예후 운반(vs imaging 정량). 자원 함의.
- K-ROAD 종단 공백을 메움. ethnic·실세계 일반화.

## 5. Limitations (정직 — 방어분석 반영)
- 단일기관·MCI-only n=252·2-wave(궤적 아님)·median 1.94yr. MMSE screening급.
- **amyloid RTM 단서:** 표준 baseline 보정선 robust하나, 보수적 통제(mmse² p0.063·ceiling제외 p0.095)에서 borderline, 효과가 고기능 MCI 집중. amyloid는 **이진 OR·연속 SUVR/Centiloid**로 방어(연속>이진). (age 교호는 ADNI 비재현이라 방어 근거에서 제외.)
- **amyloid×age 비일반화:** AJU만(p0.004), ADNI 반대 트렌드(age분포 동일). → cohort-특이, *발견으로 주장 안 함*.
- **follow-up selection:** 추적군 경증(MMSE+1.2·CDR-SB−0.5·AD적음, p<0.001). 단 **amyloid 균형(p0.31)** → 일반화는 경증 memory-clinic MCI 한정.
- **vascular = 비robust:** pooled 진단 Huber p0.18, 신호 Subcortical VaD n=7 국한.
- **혈액=루틴 검사만**, 혈장 AD마커(p-tau217/GFAP/NfL) 미통제.
- **WMH:** Fazekas 전부 결측("Fazekas null" 불가, 시각등급으로 한정). **null은 발견 아닌 경계조건** — Ye2015(한국 SVaD) WMH positive 반례 명시.
- **ADNI는 *benchmark*이지 external validation 아님** — pooled 안 함·인종/MMSE(K-MMSE)·FS 파이프라인 차 disclose. 진짜 외부 종단검증 없음(KDRC 횡단전용).
- **선행 점유(검증):** single delta 없음 → 묶음(head-to-head 일반화 + WMH 경계조건 + age 비재현). Younes2025·Bachmann2026·Ye2015·Vemuri2015·Yim2025. "독립축"·"WMH null 발견"·"age 의존"·메소드 novelty 주장 회피.

## Tables / Figures
- T1 코호트 · T2 다변량(ΔMMSE·전환) 계수표.
- F1 etiology 구성+amyloid dissociation · **F2 forest+2×2+map** · **F3 KM 4군** · (S) EDA·robustness.
- 파일: `figs/{final_two_axis,km_conversion,eda_longitudinal}.png`.

## 베뉴/delta (lit-scout 재검증 2026-06-25)
- **1지망 = JCN(Journal of Clinical Neurology, IF~3).** ART **제외**(Bachmann 2026 = 가장 가까운 경쟁작이 거기 실림). 임상·실증 fork(CLAUDE.md §2).
- **★single novel delta 없음 → "묶음 기여"가 정직한 포지션:**
  > ①**ADNI↔Asian 실세계 종단 head-to-head AT(N) 일반화 검정**(유일하게 깨끗한 빈자리; Yim2025 K-ROAD↔ADNI는 *횡단*) + ②**WMH 경계조건 명시**(발견 아님) + ③**amyloid×age 비재현**(false-positive 차단이 head-to-head 설계 가치 입증).
- **점유 지형(검증):** **Younes 2025 *Alz&Dem***(US ADRC heterogeneous amyloid 종단 예후)=우위1 강점유 → 우리는 *Asian+정량WMH+ADNI head-to-head* 추가. **Bachmann 2026 *Alz Res Ther* 18:106**(amyloid+hippo+WMH+plasma)=우위2 잠식. **Ye 2015 *Neurology***(한국 SVaD, WMH positive)=WMH-null의 직접 반례 → 경계조건으로. **Vemuri 2015 *Brain***(독립축, 정상노인). **Yim 2025 *Neurology***(K-ROAD↔ADNI, 횡단)=head-to-head 종단은 비점유.

## 인용·한계 정정 (lit-scout 2026-06-25)
- **🚫 인용 kill:** "Lee BS 2016 *Neurology* 한국 amyloid 종단" = **특정 실패, hallucination 의심 → 사용 금지.** (SVaD는 Ye BS 2015 맞음.)
- **신규 anchor:** Younes 2025(Alz&Dem)·Bachmann 2026(ART 18:106)·Yim 2025(Neurology)·Ye 2015(Neurology)·Vemuri 2015(Brain)·Li 2024(Front Aging Neurosci).
- **WMH 재framing 필수:** "WMH null=발견" 금지 → "AT(N) 통제 시 MCI memory-clinic에서 WMH 독립기여 소실(SVaD/community 소견의 경계조건)".
- **한계:** 혈액=루틴검사(혈장 AD마커 미통제). 외부=ADNI는 *benchmark*이지 validation 아님(문장 주의).
- **[VERIFY] 미해결:** Bachmann 2026 본문(WMH 독립효과 AD마커 조정 후 유의?)·Ye 2015 도메인 계수·K-ROAD 종단 출판 임박 여부(우위1·6 잠식 위험).
