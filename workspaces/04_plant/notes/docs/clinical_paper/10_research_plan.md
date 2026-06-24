# 연구계획서 (MAIN) — 실세계 Asian MCI의 amyloid–vascular 이중 예후축

> 2026-06-24 확정. 이 문서가 라인의 권위 SoT. 앞선 `00_positioning`·`01_study_design`(parsimony 프레임)은 EDA·감사로 **이중축 프레임으로 대체**됨(`03~08` 결과 반영). claim-first(CLAUDE.md §5).

---

## 1. 메인 연구 주제 (중심 claim, 한 문장)

> **실세계 Asian memory-clinic MCI 코호트(AJU, n=286, median 1.94yr)에서 2년 인지쇠퇴·MCI→AD 전환은 *두 독립 예후축*으로 구조화된다 — amyloid-PET 양성(ΔMMSE β−1.86 p<0.001; 전환 Cox HR 2.90)과 cerebrovascular/혼합 etiology(β−1.03 p=0.021; HR 3.36) — full 임상바(나이·교육·baseline 인지·CDR·dx·interval) 통제 후. *가산 구조*: 둘 다면 전환 39% vs 둘 다 없으면 2%. 임상 "AD"이나 amyloid음성은 대부분 혈관/혼합. 이 이중축은 amyloid-enriched 연구코호트·cross-sectional K-ROAD가 구조적으로 못 본다.**
> *(검증: `11_final_results.md`. 단 vascular는 *연관* 유의·*개별예측 증분*은 약함; AI-WMH 객관적 부피는 age-교란 null → vascular 신호는 부피 아닌 병인 패턴. hippo 구조는 예측 기여.)*

**기여 유형:** 임상·실증(표준 방법, 임상적으로 의미 있는 종단 발견 + 측정 프로토콜). ML 메소드 novelty 아님 → 임상 SCI 베뉴.

---

## 2. 배경 & 빈틈 (gap)

- **Amyloid-enriched 연구코호트(ADNI/A4)**: 모집 단계에서 amyloid+ 또는 혈관질환 배제 편향 → 실세계 etiology 분포·혈관축을 못 봄.
- **K-ROAD(한국 28-center, n=5,856)**: ethnic amyloid 분포를 선점했으나 **종단 추적 불완전로 예후 연구 불가**(저자 명시). cross-sectional.
- **선행 종단 amyloid 예후(Younes 2025, Lee 2016)**: amyloid가 예후라는 *base claim*은 포화. 단 (i) 대부분 amyloid vs 임상만 비교(구조·WMH·혈액 동시통제 없음), (ii) Lee 2016은 SVaD-한정 n=61, (iii) 실세계 Asian MCI *전체 스펙트럼*에서 amyloid·vascular *이중축* + amyloid음성-AD 해부는 미점유.
- **우리 빈틈(delta):** 실세계 Asian MCI에서 **full-stack(amyloid·구조·WMH·혈액22종) 통제 하 amyloid·vascular 이중 독립축 정량 + amyloid음성-AD = 혈관/혼합 특성화 + 종단(전환)** — K-ROAD가 못 하는 종단, 연구코호트가 못 보는 실세계 etiology.

---

## 3. 연구질문 / Aim (각 RQ ↔ 죽이는 리뷰어 반론)

- **RQ1 (주):** 실세계 MCI 인지쇠퇴/전환의 독립 예후축은 무엇인가? → 가설: amyloid·vascular 두 축이 독립 유의, 구조·혈액은 부가 안 함. *반론 "그냥 진단/중증도다" 를 죽임(full 통제).*
- **RQ2:** amyloid는 *진단을 통제해도* 예후를 더하는가? (proxy 아님) → within-MCI amyloid 효과. *반론 "amyloid=AD 라벨 대리" 를 죽임.*
- **RQ3:** 임상 "AD"이나 amyloid음성인 환자의 정체는? → 혈관/혼합 병리. *반론 "오진 노이즈" 를 죽임(SUVR·etiology로 검증).*
- **RQ4:** 멀티모달+혈액 중 *무엇이 예후를 안 더하는가*? (modality-specific 음성 지도) → FLAIR-grade·혈액 null. *반론 "멀티모달 다 필요" 를 정량 반박.*

---

## 4. 코호트 & 데이터 (검증됨)

- **AJU 단일기관 실세계 memory clinic.** 종단쌍 n=286(MCI 252·AD 32·CN 2), V1=baseline·V2=TFU(`label_source_tier` 무결, 페어링 위반 0).
- **추적간격:** median 1.94yr(mean 2.37, IQR 1.70–2.28). `aju_session_labels.csv` edate로 복원.
- **모달리티(V1 baseline):** T1 morphometry(FreeSurfer) · FLAIR(WMH 시각등급) · amyloid-PET(SUVR + visual) · 혈액 22종 · APOE.
- **outcome:** ΔMMSE(연속, 주), MCI→AD 전환(23 events, 보조), CDR-SB 변화(보조).
- **선택편향:** 추적군 vs 전체 AJU 베이스라인 동등(age/MMSE/CDR/amyloid 차 미미) → 편향 작음.

---

## 5. Task / 계획 실험 (각 실험 = 방법 + robustness + 죽이는 반론)

### E1 — 코호트 특성화 (Table 1) [RQ 전반]
- 인구학·dx·etiology 아형·amyloid·interval 분포. 추적군 vs 전체 AJU 대표성. amyloid visual↔SUVR 일치(AUC 0.966) 보고.

### E2 — ★주 분석: 이중축 다변량 예후 모델 [RQ1]
- **모델:** ΔMMSE ~ amyloid + vascular + (age·sex·edu·baseline MMSE·**CDR-SB**·**dx**·interval). 전환은 별도 E4.
- **예측자 정의:** amyloid = SUVR(연속) + visual(이진) 둘 다; vascular = etiology(혈관/혼합 indicator) + WMH 시각등급 둘 다(어느 표현이 신호를 잡나).
- **결과 보고:** 각 축 β·95%CI·p (full 통제). 현재 pilot: amyloid β−1.96(p<0.0001)·vascular β−1.20(p=0.008) — **단 full 임상바(CDR·dx) 추가 후 재현 필수**(현 OLS는 mmse_v1+interval만).
- **incremental:** 계층 nested CV(subject-level)로 각 축의 ΔR² + bootstrap CI(05 결과: amyloid +0.058 ΔMMSE; FLAIR/혈액 null).
- **죽이는 반론:** "중증도/진단 교란" → CDR·dx·baseline MMSE 동시통제 + within-stratum(E3).

### E3 — within-stratum (진단 proxy 배제) [RQ2]
- within-MCI amyloid 효과: ΔMMSE(트림 후 p=0.021)·연속 SUVR corr·전환(20% vs 5%, χ² p=0.0003). within-MCI vascular도 동일 검정.
- **죽이는 반론:** "amyloid=AD 라벨" → 진단 고정 후에도 유의.

### E4 — 전환 time-to-event (생존분석) [RQ1]
- **Cox PH:** time=interval, event=MCI→AD 전환, 예측자=amyloid + vascular (+ baseline). 23 events → **2 예측자만**(10 events/predictor 규율), 그 이상은 과적합. HR·CI 보고.
- **보조:** logistic(전환 이진) AUROC 계층 incremental(05: amyloid +0.031).
- **죽이는 반론:** "ΔMMSE는 interval 교란" → 생존이 시간 명시적.

### E5 — amyloid음성-AD 해부 [RQ3]
- 임상 dx × amyloid 교차표. AD-amyloid음성(n17): SUVR(1.22=진짜음성)·etiology(11/17 혈관/혼합/FTD)·궤적(ΔMMSE−1.35, 전환0). MCI-amyloid양성(n76, prodromal): 전환 20%.
- **죽이는 반론:** "측정오류/오진" → SUVR 검증(B) + etiology 일관.

### E6 — modality-specific 음성 지도 [RQ4]
- 계층 incremental(임상→구조→FLAIR→혈액→amyloid)로 *무엇이 안 더하는가* 정량. amyloid·vascular만 더하고 구조-부피·FLAIR-grade·혈액22종은 등가적으로 무시가능(TOST, margin 사전등록 0.02). Ridge+GBM 양쪽.

### E7 — robustness/sensitivity [전반]
- (a) 모델 class(Ridge/GBM/OLS), (b) outlier-trim, (c) interval 보정 vs decline-rate, (d) vascular 정의(etiology vs WMH-grade), (e) AD-amyloid음성 제외 민감도, (f) 결측대체(혈액 863 vs 858).
- **이미 통과:** 페어링·SUVR신뢰·interval(보수적, corr−0.18)·바닥효과 없음·outlier.

### E8 — 외부 anchoring
- AJU 기술통계(amyloid-by-etiology 등)를 K-ROAD·ADNI 공개수치 옆 제시(재분석 아님). KDRC 종단 가용 시 *부분* 외부확인(가용성 확인 필요).

---

## 6. Figure-first 서사 (figure 1 = 주장 1요소)
- **F1.** 코호트 etiology 구성 + amyloid-by-etiology dissociation(실세계 분포 vs 연구코호트).
- **F2. ★주 figure:** 이중축 — ΔMMSE/전환의 amyloid β·vascular β forest plot(full 통제), 2×2(amyloid×vascular) 궤적.
- **F3.** within-MCI amyloid 전환곡선(20% vs 5%) + amyloid음성-AD = 혈관 해부.
- **F4.** modality-specific 음성 지도(무엇이 안 더하나) + 양성대조(FLAIR가 *혈관 dx*엔 +0.126 AUROC = 방법 민감).

---

## 7. 정직한 한계 & 대응
- **단일기관·n=286(MCI 252):** 외부검증 제한 → KDRC 부분확인 + "실세계 단일기관 종단" 한정. 전환 23 events=Cox 검정력 제약(예측자 2개로).
- **vascular 라벨이 FLAIR 사용:** *미래* 쇠퇴 예측이라 순환 아님(outcome=미래 인지, baseline 영상과 독립). 단 vascular는 임상-진단 구성물임을 명시.
- **novelty 점유 리스크:** Lee 2016(SVaD amyloid+vascular)·Younes 2025. **delta=전체 실세계 MCI 스펙트럼 + amyloid음성-AD 해부 + full-stack 통제 + 종단전환**. 체급=중위 SCI(JAD/JCN~ART). top 아님.
- **MMSE는 screening급**(SNSB full 아님): CDR-SB 보조 outcome 동반.

## 8. delta 한 문장 (점유 회피)
> "SVaD-한정·소표본 선행(Lee 2016)·amyloid-단독 선행(Younes 2025)과 달리, *전체 실세계 Asian MCI 스펙트럼*에서 full-stack(구조·WMH·혈액) 통제 하 amyloid·vascular 이중 독립 예후축을 정량하고, 임상 AD-amyloid음성을 혈관/혼합으로 해부하며, K-ROAD가 못 한 종단 전환을 보인다."

## 9. 미해소 게이트 (착수 전/중)
1. **ART2026 본문**: full-stack modality-specific을 했나 → 베뉴 tier(ART vs JAD) 결정.
2. **E2 full 임상바 재현**: CDR·dx 추가 후 amyloid·vascular β 유지 확인.
3. **Lee 2016 정독**: delta가 충분한지 최종 판정.
