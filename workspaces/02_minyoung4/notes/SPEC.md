# SPEC

## ❌ 20260613 scanner/population decomposition — VERIFIED NEGATIVE (no ⭐)
E1: align(PRE)→ComBat deflation(POST) rho=+0.90 *겉보기*. → code-auditor가 disease-imbalance confound 지적 → **E2(disease-matched, leakage 수정): rho 붕괴(+0.90→−0.20, AJU제외 −0.14), cross-ancestry deflation +0.05→−0.001=same-pop.** = **E1은 disease-prevalence imbalance artifact. ②③ FALSE in our data → 분해 방향 기각.**
**genuine new fact**: 겉보기 cohort-disease 얽힘·ComBat deflation은 전부 disease-prevalence 불균형 탓(scanner/ancestry 아님); disease-matched면 ComBat은 cross-ancestry서도 신호-중립. (단 "confound 통제" 일반원칙의 특수사례, novelty 제한적.) 기록: `experiments/20260613_scanner_pop_decomp/reports/SUMMARY.md`.

---
## (기각됨) CONFIRMED DIRECTION (2026-06-13, lit-validated): Transferable scanner/population decomposition
`experiments/PROPOSAL_technical.md` (+ `RETROSPECTIVE.md`). 문헌 검증 통과: deep-research(98 agents, ②③ survive) + G1(literature-scout, 핵심 method 미점령).
- **기술 헤드라인**: 공개 traveling-subject(ON-Harmony/SRPBS)로 *순수 scanner 효과* 모델 학습 → *전이*해 우리 코호트의 cohort-distance를 **scanner vs population 성분으로 cross-sectional 분해** (Yamashita 2019의 TS-필수 분해를 전이로 해소 = novelty 핵심).
- **② 법칙**: *분해된 population 잔차*가 deflation 예측 (관찰이 아니라 *분해*가 기여; Li 2022 cross-ethnicity와 차별).
- **③ 예측타당성**: 사전 잔차 → 사후 ComBat disease-AUC 손실의 정량 예측력(r/AUC). (가장 약한 축 — 실증 필요.)
- baseline: ComBat-Predict(HBM 2026)·Radua 2020·Yamashita 2019. venue NeuroImage/MELBA.
- **다음 게이트**: G2(ON-Harmony/SRPBS DUA·다운로드 + IPMI/MICCAI 최신 정밀 재확인) → G3(scanner모델 전이 검증 R1) → 통과 시 본실험.
- 자산: 우리 excess-alignment E-result(`separability_diagnostic/`)가 ②의 deflation 측정에 직접 재사용.

---
## (이전) E — Site-Population Separability Diagnostic
foundation-adaptation(아래 Direction 2)은 research-critic 검증서 "novel core 얇음+메트릭 교란+mitigation 무효"로 NeuroImage급 미달 판정 → **E로 전환**.
**E = harmonize 전에 site가 population과 분리 가능한지 측정하는 calibrated diagnostic.** `experiments/separability_diagnostic/STUDY_PROTOCOL_E.md`.
- **검증된 메트릭 = excess subspace-alignment** ‖P_cohort·w_disease‖ − chance (dim-matched·chance-corrected). naive deflation은 calibration 실패(디코딩/차원 교란)→폐기.
- **E4 calibration ✅**: random +0.086 ≈ within-ADNI scanner +0.003 (분리) ≪ 7-cohort +0.546 (얽힘). 음성대조 통과.
- **application**: 7-cohort entanglement morphometry +0.546 / BrainIAC +0.389 (표현학습도 못 줄임).
- **per-pair spectrum**: same-pop 분리(ADNI–NACC +0.13, AJU–KDRC +0.29) ≪ cross-pop 얽힘(美vs韓 +0.57~0.59) = "site=population" 정량 입증.
- E1✅E2✅E3✅E4✅(within-data)E6✅. 남은 강화: 외부 traveling-subject(ON-Harmony/SRPBS) calibration(DUA 필요). target NeuroImage:Clinical/MELBA/HBM.

---
# (이전) SPEC — Adaptation of 3D brain-MRI foundation models under site shift (minyoung4, Direction 2)

> Living spec. 이전 closure들: `docs/context/FAILED_*_CLOSURE_20260611_KO.md`.
> 1순위 제약: leakage(train-eval) 금지 + honest eval. **morphometry는 yardstick 아님 — 여러 baseline 중 하나.**

## 0. 목적 / Thesis (2026-06-11 확정, 사용자 선택 = "adaptation 방법론 연구")
사전학습된 3D 뇌-MRI foundation(BrainIAC 등)을 **어떻게 적응(adapt)시켜야 site-shift에 강건한가**를
우리 7코호트 leakage-통제 벤치로 체계적으로 측정한다.
> **질문**: frozen이 (이미 측정상) 단순 baseline에 지고 site를 더 싣는다. **fine-tuning regime이 이를 escape하는가?
> 어떤 적응 전략(linear / LoRA / partial / full FT)이 transfer↑·site-loading↓를 best로 주는가?**

## 1. Task / 평가 (morphometry-yardstick 아님)
- **adaptation ladder**: ① frozen-probe ② linear-probe ③ LoRA/partial-FT ④ full-FT. (+ baseline: from-scratch 동일 backbone)
- **endpoint**: (A) CN/AD 분류 (B) brain-age 회귀. 둘 다 **leakage-clean**(AJU+KDRC) + 가능시 다코호트.
- **평가 축**:
  1. **LOCO transfer** (미관측 cohort 일반화) — 핵심.
  2. **site-loading** (표현→cohort AUC, 적응이 줄이나).
  3. baseline 대비(from-scratch·frozen·morphometry는 *참조*, 천장 아님).
- 모든 수치 다seed mean±std. ΔAUC/Δsite over from-scratch & frozen.

## 2. Data
- `official_manifest_full_n4_real_final.csv` 7코호트. leakage-map: AJU·KDRC=CLEAN(공개 foundation 미포함), ADNI/OASIS/AIBL=likely 누수, NACC/A4 uncertain.
- foundation transfer 평가의 task-probe(B,C)는 **clean(AJU+KDRC)**; site-probe(A)는 전 코호트.
- 입력: v2 T1w final_tensor_n4 → 96³ resize + normalize (BrainIAC transform 매칭).

## 3. Win / 판정
- **(positive)** 어떤 적응 전략이 frozen·from-scratch 대비 LOCO transfer를 유의 개선 AND/OR site-loading 감소 → "foundation 적응이 site-shift에 도움" 입증.
- **(negative-but-real)** full-FT조차 from-scratch와 동등·site 안 줄면 → "이 regime에선 대규모 pretrain이 이점 없다"는 강한 audit 결론(우리 BrainIAC frozen audit의 fine-tune 확장).

## 4. 선결 (setup gate)
1. **모델 재취득**: BrainIAC(GitHub AIM-KannLab, CC-BY-NC, ViT 7GB) 또는 brain2vec(HF, Apache-2.0, VAE). 직전 리셋서 삭제 → 재다운로드.
2. env: monai 호환(이전 monai-1.3.2 격리 env). 입력 전처리 공정성 재확인.
3. frozen baseline 재현(이전 audit: site 0.842 / brain-age 5.73 / CN-AD 0.735)으로 setup 검증.

## 5. 실험 로그
| EXP | 내용 | 결과 |
|---|---|---|
| (이전 audit, archived) | BrainIAC **frozen** vs morphometry | site 0.842>0.770 / brain-age 5.73>5.56 / CN-AD 0.735≪0.911 (frozen 열세) |
| K0/K1 (archived→closure) | KDRC 멀티모달 WMH headroom | morphometry ceiling (Δ≈0) |
| D2-S0 | BrainIAC 재취득(repo+가중치+monai1.3.2 env) + frozen 재현 | ✅ site **0.842**/brain-age **5.73**/CN-AD **0.735** = 이전 audit 완전 일치 (셋업 검증) |
| D2-S1 (seed0) | adaptation ladder, brain-age, **held-out=KDRC** | ✅ MAE: frozen 6.35 / partial 6.06 / scratch 5.86 / **full 5.31**. site: frozen .775/full .749/scratch .709. |
| D2-S1 conf | brain-age LOCO, KDRC 3seed + AJU 1seed | ✅ **KDRC**: frozen 6.36±.02 / scratch 5.79±.07 / **full 5.35±.04** (full−frozen −1.02, full−scratch −0.44, robust). **AJU**: frozen 5.73 / scratch 5.60 / full 5.49 (full−frozen −0.23, full−scratch −0.11 약함). site: scratch 최저(.698/.717), full 더 실음. |
| D2-S1 AJU 3seed | AJU full/scratch/frozen ×3 | ✅ frozen 5.72±.02 / scratch 5.70±.10 / **full 5.47±.06** (full−frozen −0.25, **full−scratch −0.23 robust**). site: scratch .718 최저, full .771. |
| D2-S2 confound | site-loading age-confound stress (age 잔차화 + feat→age R²) | ✅ **#3 생존**: age 제거해도 site 불변(frozen .775→.775, full .749→.743, scratch .718→.712). frozen site .775인데 age-R² .207 = **사전학습이 age보다 site를 강인코딩**(age-독립). |

| D2-S3 cnad | CN/AD adaptation ladder (KDRC seed0) — multi-task 일반성 | ✅ AUC: frozen .734 / partial .730 / full .780 / **scratch .810**. site: scratch .728 최저. age-잔차화 불변(full .766→.767). **brain-age와 반대: scratch>full!** |
| D2-S3 cnad 3seed | CN/AD KDRC full/scratch/frozen ×3 | ✅ frozen .734±.002 / scratch **.779±.034**(분산 큼) / **full .800±.017**. site: scratch .722 최저. **seed0의 scratch>full은 outlier — 3seed로 full>scratch(노이즈 제거, #4 KILL)**. |

**문헌 + 게이트 + multi-task 종합 (발견 지형 확정)**:
- **#1 frozen 오도**: ✅ 양 task robust (full ≫ frozen).
- **#2 foundation 가치(full ≥ scratch)**: ✅ **양 task 동일 방향**(brain-age full<scratch MAE / CN/AD full>scratch AUC) — modest, CN/AD scratch 분산 큼. (seed0의 "CN/AD scratch 우세 #4"는 노이즈→KILL, 3seed로 정정)
- **#3 pretraining이 age-독립 site 주입**: ✅ **양 task robust** (scratch 항상 site 최저 ~0.71 vs full ~0.76, age 제거 불변) = transfer↔site tradeoff.

→ **논문 thesis (정직·견고)**: "full fine-tuning이 양 task에서 best transfer(frozen-probe는 이를 가림), 단 pretraining은 *task 무관하게 age-독립 site 정보를 주입*해 from-scratch보다 site-loaded다 = transfer↔site-invariance tradeoff." (scout 권고 #3중심 부합). #1·#2 단독(BrainIAC 재탕) 회피.
**교훈**: single-seed는 오도(#4 사례) → 모든 claim ≥3, 핵심은 ≥5 seed.

| D2-S4 mitigation | full+GRL(λ0.3,1.0) site-adversarial, 양 task | ❌ **site 변화 ~0.02·비단조·task 불일치 = GRL 무효**. transfer만 보존. mitigation 경로 닫힘. |

**research-critic + F4 종합 판정 (2026-06-11, 정직)**: **현 상태 NeuroImage급 아님.**
- F1·F2 = KNOWN(transfer-learning 정설). F2는 CN-AD 효과(0.021) < scratch 분산(0.034), 유의성 미입증.
- F3 = OVER-CLAIMED: "tradeoff"는 Pareto frontier 없는 1D 관찰. 효과 ~0.04 baseline 분산에 잠김. **site 메트릭이 한국vs서구 = population/race 분류기로 교란**(선형 age-잔차화로 방어 불가) — 구조적.
- F4 = GRL mitigation 실패 → 승격 경로 닫힘.
- 메타: 이 세션 전체의 **site=population irreducible**가 여기서도 재확인.
→ 현실적: Imaging Neuroscience/HBM의 약화된 cautionary report(“frozen audit 과소평가 + pretraining이 site 못 줄임”), "tradeoff" 단어 폐기. 또는 재고.
SCI 빌드 남은 것: ≥5seed·LP-FT(Kumar)·age/sex-matched metric·다 held-out cohort·mitigation·leakage 증빙. 타깃 NeuroImage/HBM ~ MedIA/TMI.

**D2-S1 확정 발견 (nuanced positive)** — `reports/D2_S1_verdict.md`:
1. ✅ **frozen-probe 오도**: full-FT >> frozen (KDRC −1.02 tiny CI / AJU −0.23), 양 cohort robust. 이전 frozen audit("foundation 무용") 반박.
2. ~ **foundation 가치(vs scratch) modest·cohort 의존**: KDRC −0.44(robust) / AJU −0.11(약, 다seed 확인중).
3. ⚠️ **pretraining이 site-loading 증가**(scratch 최저) → **transfer↔site tradeoff**. transfer-best(full)이 site-cleanest 아님.
→ thesis: "적응 전략이 결정적, frozen 평가는 오도; foundation은 transfer엔 modest 도움이나 site bias를 주입한다."

## 6. Artifact policy
`experiments/foundation_adapt/` 1디렉토리, 가중치·캐시 gitignore, 리포트 작은 md/csv. 매 실험 SPEC 갱신.
