# Harmonization Scout Review — 다기관 AD/CN setting

> literature-scout(2026-06-11) + 우리 데이터 그라운딩. 질문: "다기관 AD/CN으로 가서 harmonization으로
> bias를 줄여 진행 가능한가?" 결론: **기술적 가능 / 과학적 신중(낙관 금지).**

## 1. 데이터 그라운딩 (직접 측정)

- **다기관 AD/CN 구성 가능.** CN(CDR0) 3,909 · AD(CDR≥1) 807 subjects. disease-rich 5코호트(ADNI/NACC/OASIS/AIBL/KDRC) = 6,551 세션. (A4=거의 CN-only AD33, AJU=CN27뿐 → 제외.)
- **confound 완화.** Cramér's V(consortium, AD/CN)=**0.24** (impaired 0.42 대비 낮음 — MCI 빼고 양끝만 쓰니 감소). KDRC만 AD_rate 0.37 outlier.
- **★ morphometry LOCO 바 = 0.936** (held-out별 ADNI 0.923·NACC 0.919·OASIS 0.937·AIBL 0.961·KDRC 0.942). **morphometry가 site bias 있어도 cross-site 거의 완벽 transport** → CN-vs-AD에서 site bias 는 baseline 의 병목이 아니다.

## 2. Harmonization 방법 검토 (scout, top-tier 한정)

| 방법 | venue | 우리 입력 | cross-site AD/CN 증거 | 판정 |
|---|---|---|---|---|
| ComBat/ComBat-GAM | NeuroImage 17/20 | feature-only | 우리 데이터서 이미 음성(부호반전) | **NO-GO** |
| CovBat | HBM 2022 | feature-only | 공분산까지 제거→confound서 over-corr 위험 | **NO-GO** |
| ComBat-Predict | HBM 2025 | feature-only | unseen-site RMSE↓ (AUC 아님), 테스트 site 3명 필요 | CAUTION(morph arm용) |
| CALAMITI/HACA3 | NeuroImage21/MedIA23 | **multi-contrast 필요** | seg 위주, AD/LOCO 없음 | **NO-GO**(데이터 불충족) |
| ImUnity | MedIA 2023 | single-T1w OK | ASD만, biological module 유망 | CAUTION |
| **IGUANe** | **MedIA 2025** | **single-T1w 3D, 최적합** | unseen-vendor AD 0.894→0.921(단 vs raw image, **vs morphometry 아님**) | **CAUTION→조건부 GO** |
| Dinsdale unlearning | NeuroImage 2021 | image/CNN | age 위주, 우리 GRL 2회 실패 선례 | CAUTION(Arm B) |
| MixStyle | ICLR 2021 | image | 우리 데이터서 이미 음성(+0.026) | **NO-GO** |
| SSL(FOMO25 등) | MICCAI 24/25 | single-T1w OK | OOD 강건(harmon objective 아님) | GO(표현으로서, Arm A) |

## 3. 메타-결론 (scout 핵심)

- **문헌 어디에도 "site==population confound 강한 regime에서 harmonization이 LOCO로 morphometry 바를 넘어 AD/CN을 올렸다"는 직접 증거가 없다.** 긍정 보고는 (a) in-dist site-probe↓, (b) brain-age RMSE, (c) raw-image 대비 개선뿐.
- **IGUANe**가 우리 입력과 가장 호환되나, ① baseline이 morphometry 아닌 raw image, ② over-correction을 "HC-only 학습"으로 회피 → AD가 site와 얽힌 우리 confound를 다루지 않음, ③ 입력 정규화(median-brain vs 우리 z-score)·격자(160³ vs 192³) 차이로 재학습/재정규화 필요.
- survey: over-correction은 **"정량 증거 없는 open problem"**. covariate-preserving/biology-guided 는 개념만 있고 AD/CN LOCO 검증 부재.

## 4. Feasibility 판정 (정직)

**진행은 가능하나, "harmonization으로 bias 줄여 바를 넘는다"는 전제는 약하다:**

1. **CN-vs-AD에서 morphometry 바가 0.936이고 이미 transport된다 → bias가 baseline의 병목이 아니다.** harmonization은 *baseline을 안 해치는 bias*를 줄이는 셈. 즉 이 task에서 harmonization의 upside가 구조적으로 작다.
2. **0.936을 이미지로 넘는 것 = minyoung2/4가 실패한 자리.** headroom(→1.0)이 0.06뿐. 천장 효과.
3. 따라서 **CN-vs-AD 다기관 + harmonization**의 가장 가능성 높은 결과는 **(b) 천장의 깨끗한 재확인**(harmonization 써도 이미지 ≯ morphometry). 이건 *판정 논문*으로는 가치 있으나 *method-win 논문*으로는 거의 확실히 실패.

## 5. 권고

- **harmonization = 해법이 아니라 P2 Arm C 대조군.** IGUANe를 1순위 구체 후보로, 성공기준은 site-probe↓ 아닌 **G1∧G2 동시(LOCO disease가 morphometry 0.936 초과)**. Arm D(무처리) 대비 개선 없으면 음성 ledger.
- **전략적 재고(중요):** 미세표현의 headroom은 morphometry가 *약한* 곳에 있다 — CN-vs-AD(바 0.94)가 아니라 MCI/CDR≥0.5(바 0.68~0.77)·progression·preclinical. "깨끗한 다기관 AD/CN"은 매력적이나 **천장이 너무 높아 micro-signal이 더할 여지가 거의 없다.**

## 출처 (peer-reviewed 우선; preprint 단독은 [VERIFY])
- DL harmonization survey: PMC11365220 (2024) · arXiv 2507.16962
- IGUANe: Medical Image Analysis 2025 (S136184152400313X / arXiv 2402.03227)
- HACA3: MedIA 2023 (PMC10592042) · ImUnity: MedIA 2023 (S1361841523000609)
- Dinsdale unlearning: NeuroImage 2021 (PMC7903160) · CovBat: HBM 2022 (PMC8837590)
- ComBat-Predict: HBM 2025 (PMC12407725) · Pomponio: NeuroImage 2020
- conv adversarial AE multi-center AD: MedIA 2022 (S1361841522002237) [VERIFY 본문]
- Learn to Ignore: MICCAI 2022 [VERIFY] · FOMO25: MICCAI 2025 (arXiv 2604.11679)
