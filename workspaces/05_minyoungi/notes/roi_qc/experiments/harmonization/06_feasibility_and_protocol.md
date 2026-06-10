# 06 — Harmonization 연구 Feasibility & Protocol

_생성: 2026-06-04. deep-research(웹 22 소스 / 109 claim 추출 / 25 검증 → 24 confirmed·1 killed) + 로컬 실험 01~04 종합._
_목적(원 요청): "우리 데이터로 harmonization 연구를 진행하려면 (2) 어떤 과정·metric이 필요한지, (3) 성공 가능성이 얼마나 될지." + (1) 선행 연구 정리._
_인용 규칙: peer-reviewed(SCI 저널/top-tier conf)만 본문 근거로. preprint 단독·미검증은 [VERIFY] 또는 preprint 명시._

---

## 0. 한 줄 결론 (먼저 깨질 지점부터)

> **이미지-레벨 harmonization으로 "강한 ROI-부피 baseline(우리 04: held-cohort AUC 0.92, 단 CN/AD·ADNI/AIBL/KDRC 한정)을 이겨 진단 정확도를 올린다"는 claim은 high-risk다.** 문헌과 우리 데이터 둘 다, 이 regime(site==population 교란 + 이미 강한 morphometry)에서 그런 positive result가 거의 안 나온다. 우리가 검토한 확인된 사례에서 harmonization이 성공한 경우는 **약한 신호를 unmask**(ASD AUC 0.58→0.67)했거나 **분포가 겹치는(overlap) regime**에서였다 — 우리 상황과 반대.
>
> **현실적으로 publishable한 기여는 "정확도 향상"이 아니라 "representation-validity / shortcut-audit 프로토콜"이다**: 학습된 이미지 표현이 site==population shortcut을 인코딩하고 morphometry를 못 이긴다는 것을, 이중 probe + null control + LOCO로 정량 입증하는 것. 이 중 **feature-level 절반(01 probe·03 N4·02 ComBat)은 했지만, image-level 절반(train-only fit + 이미지 표현 자체의 null-permutation probe)은 아직 미착수**다. 서브필드가 현재 보상하는 claim type이지만, Souza 2024와의 차별화가 관건(Part 3.2).

근거 요약: 우리 04(CN/AD morphometry는 site-robust, site-shift 비용 ~0) + 문헌(harmonization은 weak signal unmask용, 강한 baseline을 못 이김; 이미지 site는 단순 정규화로 안 지워짐; 진단 분류기가 covert site 분류기가 됨).

> ⚠️ **이 verdict의 가장 큰 한계 2개 (먼저 명시):**
> 1. **04의 "site-robust"는 CN/AD·ADNI/AIBL/KDRC에서만 측정됨.** 정작 가장 site-특이한 AJU(한국, appearance 0.822로 최고)는 CN n=23뿐이라 **held-out 타깃이 될 수 없었다** → site-shift 비용 ~0은 *낙관적 하한*이지 7-컨소시엄 전체 보장이 아니다. NACC/OASIS/A4는 strict AD 부재로 LOCO 대상 외.
> 2. ~~현대 deep harmonization을 직접 안 돌렸다~~ **[2026-06-04 해소 — 07 실행]**: MixStyle domain-randomization 3D CNN을 LOCO(held-KDRC/AIBL)·이중 probe로 직접 실행 → 강한 image harmonization도 **morphometry를 못 이기고(Δ −0.03~−0.08, 전 seed) site shortcut도 못 줄임(site-probe +0.026)**. negative result가 reviewer-proof화됨. (단 GAN/IGUANe·대형 backbone은 여전히 미실행 — Part 3.3.1 한계 참조.) 결과: [`07_deep_mixstyle/RESULTS.md`](07_deep_mixstyle/RESULTS.md).

---

## Part 1. 선행 연구 — 방법과 실패 모드 (peer-reviewed)

### 1.1 큰 그림: 두 개의 결정적 gap

문헌의 거의 모든 **positive** harmonization 근거는 두 조건에서만 나온다. **우리는 둘 다 위배**한다.

| Gap | 문헌이 성공한 조건 | 우리 조건 | 출처 |
|---|---|---|---|
| **분포 overlap** | site 간 covariate(나이·진단) 분포가 겹침 | site==population (한국 AJU/KDRC vs 서구), 거의 disjoint | Bayer 2022; Fortin 2017 |
| **feature-level + 약한 baseline** | FreeSurfer ROI 특징, baseline이 near-chance(0.58) | **이미지-레벨**, baseline이 이미 강함(0.92~0.93) | Saponaro 2022; Souza 2023 |

→ "evidence-transfer gap": 좋은 결과는 overlap regime의 feature-level ComBat에서 나왔는데, 우리가 하려는 건 confounded regime의 image-level deep harmonization이다. **근거가 우리 쪽으로 전이되지 않는다.** (deep-research 종합 caveat의 핵심.)

### 1.2 ComBat 계열 (feature-level) — 작동하지만 조건부

- **Fortin et al. 2017/2018, NeuroImage 167:104-120 (PMID 29155184)** — 정준 ComBat(location+scale, empirical Bayes). cortical thickness에서 site SVM **76.6%→36.3%**(chance 36.9%)로 chance까지 낮추면서 age-thickness 상관 **-0.70→-0.79**, age 설명분산 **23%→33%** *강화*. ✅ 우리 02(ComBat fs_vol: site 0.238→0.175, biology 보존)와 **같은 패턴**. 단 EMBARC/VDLC는 **overlap site**였음. 저자 경고: scanner가 disease group과 겹치면 biology가 인위적으로 생성/삭제될 수 있다.
- **Tassi/Bonacina et al. 2024, Human Brain Mapping 45(18):e70085 (PMID 39704541)** — **결정적 실패 모드**: ComBat을 train에 fit→held-out test에 apply하면 잔여 site가 **4개 특징셋 중 3개에서 유의하게 남음**(post-test site BA: Neuromorphometrics 48.75%, Destrieux 40.42%, Desikan-Killiany 39.17%; chance 25%; permutation p<0.05). in-sample(전체 fit)에서는 65~91% 감소로 깨끗해 보이지만 **외부 검증에선 26~56%만 감소** → **in-sample 지표는 site 제거를 과대평가**한다. ⚠️ 우리 02는 "전체 fit"이라 이 inflation에 해당 → 02 RESULTS의 "site 하락 일부는 기계적, 판정 기준은 biology 보존" 주의가 이 논문으로 뒷받침됨.
- **Bayer et al. 2022, Frontiers in Neurology 13:923988** (ENIGMA계 리뷰) — **우리 regime의 실패 모드를 직접 명시**: ComBat의 독립성 가정(biology ⊥ site)이 site와 covariate가 collinear/confounded면 위배 → **over/under-correction**(site와 공선인 미모델링 생물학이 site와 함께 제거됨). "covariate 분포가 disjoint가 아니라 **overlap**해야 한다"고 권고. → site==population은 강한 공선(near rank-deficient) 사례.
- **Pomponio et al. 2020 (ComBat-GAM)**, **Chen et al. 2021 HBM (CovBat, 10.1002/hbm.25688)** — 비선형 age / covariance 확장. [VERIFY: deep-research에서 corroboration으로만 등장, 본 검증 claim 아님]. 우리 02의 site×age 기울기 차(A4 -0.048 vs AJU -0.025, ~2배)를 고려하면 ComBat-GAM이 약간 더 방어적일 여지 — 단 overlap 위배는 GAM으로도 안 풀림.

### 1.3 이미지-레벨 (deep / style-transfer / adversarial) — 가장 어려운 케이스

- **Souza et al. 2023, JAMIA 30(12):1925-1933 (PMID 37669158)** — **단순 강도 정규화로는 이미지 site를 못 지운다**: raw T1에서 site 분류 **~85%**, intensity harmonization 후에도 **~85%**(거의 불변). morphology-only log-Jacobian map조차 **54%**(chance ~2.4%, 41 site). skull-strip+1mm resample+bias correction+atlas reg 다 한 뒤에도. ⚠️ 단 여기서 테스트한 harmonization은 histogram matching(우리 N4+z-score와 같은 "simple normalization" 부류)이지 GAN/고급 harmonization은 아님. → 우리 03(N4가 appearance를 0.556→0.517로 소폭만↓, probe-의존)과 **정확히 일치**.
- **Souza et al. 2024, IEEE J Biomed Health Inform 28(4):2047-2054 — "Is the Disease Classifier a Secret Site Classifier?"** — **진단 분류기가 covert site 분류기가 됨**: 학습된 PD 분류기를 freeze하고 feature를 디코딩하니 site **71%**, scanner **79%**, sex **75%**(전부 label로 준 적 없음), 정작 PD 정확도는 **74%**. → 우리 01(metadata가 consortium을 0.761로 식별, appearance 0.556)과 같은 메커니즘. **이중 검증이 필수인 이유의 직접 증거.**
- **Achara et al. 2025, FAIMI@MICCAI, LNCS 15976 (arXiv:2509.09558)** — 3D 구조 MRI에서 보호속성이 deep model로 디코딩됨(sex F1 0.87~0.94, White-race F1 0.97~0.99; ResNet50/Swin). curated sex 불균형을 주면 CN/AD 분류에서 **AD class가 CN보다 더 가파르게 F1 하락**(shortcut + 비대칭 bias). ⚠️ within-dataset curated imbalance지 cross-site confound는 아님(analogue). MICCAI workshop(LNCS-indexed, preprint 아님).
- **Guan et al. 2021, Medical Image Analysis (AD2A, PMID 33930828)** — deep DA가 전통 DA를 이김(ADNI-1→ADNI-2 **89.92%** vs CORAL 77.65% vs TCA 74.39%). ❗**그러나 baseline이 약함**: AAL-90 GM 부피 + logistic regression에 unsupervised DA를 얹은 것(우리 같은 강한 supervised morphometry 아님), 게다가 **전부 서구(ADNI-1/2/3+AIBL) overlap regime**, 인구통계 confound는 future work로 명시. → **"deep DA가 이긴다"가 우리 0.92 baseline에 적용되지 않는 이유.**
- **Dinsdale et al. 2021, NeuroImage** (confusion-loss unlearning), **Liu et al. 2023, HBM (10.1002/hbm.26422)** — adversarial은 "acquisition 변동 vs population 변동을 구분 못 해" 둘 다 harmonize → **overcorrection**(critical biology 제거). Bayer 2022도 동일 경고: adversarial은 scan parameter가 다르고 인구통계가 confound될 때 특히 overcorrection. → **site==population에서 adversarial이 위험한 직접 근거.**
- **Cohen et al. 2018, MICCAI** [literature-scout, 02 daily note] — CycleGAN distribution-matching이 병리를 hallucinate. site==population에서 **단독 비권장**.
- **Billot et al. 2023 (SynthSeg, domain randomization)** [literature-scout] — site를 제거가 아니라 "무관화" → site==population에 더 방어적이나, 잔존 shortcut이 geometry/형태면 한계.

### 1.4 우리 minyoung4 선행작과의 일치

`/home/vlm/minyoung4/.../full_n4_experiment_redesign_20260603/`의 stage8~20(adversarial/disentangling 이미지 인코더)은 **어떤 이미지 표현도 ROI-volume baseline(held-AUC 0.933)을 못 이겼고** scanner 누수가 잔존했다. → 위 문헌(이미지 harmonization이 강한 morphometry를 못 이김)과 **독립적으로 같은 결론**. 우리 04(LOCO 0.92, site-shift 비용 ~0)가 그 baseline을 또 재확인.

---

## Part 2. 방어 가능한 harmonization 연구의 과정 & metric

서브필드가 요구하는 표준은 **이중 검증 프로토콜(dual-validation)**이다: *site probe는 chance로 ↓ 하면서 biology probe는 보존*. 둘 다 떨어지면 "scientifically useless"(Fortin 2017). 우리 01·02·04는 이미 이 틀로 짜여 있다.

### 2.1 파이프라인 단계 (순서가 중요)

```
[0] split 먼저 고정 — leave-one-consortium-out (LOCO). subject_id 기준 group split (세션 누설 차단).
     ↳ 근거(우리 01): A4/KDRC/AJU/AIBL는 metadata로 거의 완전 식별(recall 0.99/0.99/0.95/0.84)
       → random split이면 site로 코호트를 외움. random split = 낙관 편향.
[1] harmonization은 TRAIN에만 fit → held-out에 apply (transform 저장).
     ↳ 근거(Tassi 2024): 전체 fit은 site 제거를 과대평가. 외부 검증이 진짜 지표.
[2] site/scanner probe: harmonize 전/후, held-out에서 balanced_acc (chance=1/n_site).
[3] biology probe: 같은 표현에서 age 회귀 R² + CN/AD AUC (held-cohort).
[4] null control: site label shuffle(→chance 여야) + fake random label(→AUC 0.5 여야), n≈1000 permutation.
[5] baseline 대조: ICV-정규화 ROI-volume morphometry의 held-cohort AUC (반드시 같이 보고).
```

### 2.2 필수 metric (보고 표준)

| metric | 합격 기준 | 출처 | 우리 현황 |
|---|---|---|---|
| **site probe ↓** | harmonize 후 held-out에서 chance 쪽으로 | Fortin 2017, Saponaro 2022, Tassi 2024 | 02: 0.238→0.175 (fs_vol) |
| **biology probe 보존** | age R² 유지 + CN/AD AUC 유지 (필수 guardrail) | Fortin 2017 (둘 다 떨어지면 무의미) | 02: age R² 0.284→0.278, within-ADNI AUC 0.885 불변 |
| **null-label control** | shuffle site→chance, fake label→AUC 0.5 | Saponaro 2022 (n=1000 permutation) | 02: 통과 (0.143 / 0.498) |
| **LOCO held-cohort AUC** | random-split 상한과의 차(=site-shift 비용) 보고 | Tassi 2024 (외부 검증), 우리 04 | 04: 비용 0.001~0.004 |
| **morphometry baseline** | ICV-정규화 ROI-volume AUC를 항상 병기 | Guan 2021 비판점 | 04: 0.916~0.923 |
| **비순환성** | dx 보존 안 한 harmonize에서도 within-site disease AUC 유지 | (우리 02 v2가 추가한 안전장치) | 02: dx 미보존에도 0.885 |
| **probe 견고성** | ≥2개 분류기(RF+LogReg)·seed로 재현 | (artifact 배제) | 01·03: RF/LogReg 둘 다 |

핵심 함정 2개:
1. **site==population에서는 "site probe가 chance로 떨어짐"이 오히려 위험 신호일 수 있다** — biology가 같이 제거됐을 수 있으므로. → **biology probe가 유일한 guardrail**(Fortin 2017). 우리 02 v2의 "dx 미보존에도 within-ADNI AUC 불변"이 이 비순환 증거.
2. **in-sample 지표 금지** — 전체 fit한 ComBat의 site 하락은 과대평가(Tassi 2024). held-out apply가 진짜.

### 2.3 metric으로 쓰면 안 되는 것
- pooled(전 코호트 합친) CN/AD AUC를 단독 근거로 쓰면 안 됨 — site 조성(AJU=AD多, A4=CN뿐)에 편승한 가짜 dx 신호 포함(우리 02에서 pooled 0.896 vs within-ADNI 0.885로 분리 확인).
- "site 0으로" 자체를 목표로 삼으면 안 됨 — 잔여 site(02의 0.164~0.175)는 모집단 교란분의 정당한 잔존.

---

## Part 3. 성공 가능성 (Feasibility) & 현실적 claim

### 3.1 시나리오별 성공 확률 (정성, 근거 부착)

| claim 유형 | 성공 가능성 | 근거 |
|---|---|---|
| **A. 이미지 harmonization으로 CN/AD 진단 정확도 ↑ (>0.93 morphometry)** | **매우 낮음** | 04: morphometry 이미 0.92, site-shift 비용 ~0 → headroom 거의 없음. 문헌: harmonization은 weak signal unmask용(0.58→0.67)이지 강한 baseline 격파용 아님(Saponaro 2022). minyoung4 stage8~20 전부 실패. |
| **B. 이미지 harmonization으로 LOCO 일반화 ↑** | **낮음** | 04: LOCO 비용이 이미 ~0. 깰 게 거의 없음. |
| **C. ComBat류로 feature-level site↓+biology보존 입증** | **중간(이미 됨)** | 02에서 입증 완료. 단 overlap 위배(Bayer 2022)로 "완전 제거" claim은 약함 → "정당한 잔존" 프레이밍 필요. 새로움 낮음(Fortin 2017이 원조). |
| **D. shortcut-audit / representation-validity 프로토콜 기여** | **상대적으로 높음** | 01(site는 metadata 0.761>appearance 0.556에 박힘) + Souza 2024(진단기=covert site 분류기) + 04(morphometry는 robust) → "이미지 표현이 site==population shortcut을 인코딩하고 morphometry를 못 이긴다"를 이중 probe+null로 정량 입증. 서브필드가 현재 보상하는 claim type. |
| **E. site==population confound를 명시적으로 다루는 벤치마크/프로토콜** | **중간~높음** | 7-컨소시엄·한국 vs 서구라는 구성 자체가 희소(대부분 서구 overlap). confound를 "버그가 아니라 연구 대상"으로 프레이밍. |

### 3.2 권고 — 가장 방어 가능한 연구 형태

> **"Multi-site AD 표현학습에서 image-level 표현이 site==population shortcut을 학습하며, 이중 probe+null control+LOCO로 측정했을 때 강한 ROI-volume morphometry baseline을 못 이긴다"는 shortcut-audit 프로토콜 + 음성 결과(negative result) 논문.**

- **무엇을 주장**: (1) site는 픽셀보다 metadata/해상도에 강하게 박힌다(01). (2) 이미지 정규화(N4 등)는 이걸 거의 못 지운다(03, Souza 2023). (3) feature-level ComBat은 site↓+biology보존이 되지만 image shortcut은 별개 레이어다(02). (4) morphometry CN/AD는 이미 site-robust라 harmonization이 일반화엔 불필요하다(04). → **"언제 harmonization이 도움이 되고 언제 안 되는지"의 경계를 confounded regime에서 정량화.**
- **무엇을 주장하지 않음**: SOTA 정확도 향상.

#### 3.2.1 가장 큰 투고 리스크 — Souza 2024와의 차별화 (반드시 방어해야 함)
Souza 2024는 **이미** "진단 분류기를 freeze→site/scanner/sex 디코딩"(secret site classifier)을 했고 "진단기가 site를 인코딩한다"고 결론냈다. 따라서 Reviewer-2의 첫 질문은 **"Souza 2024 + 코호트 더 많은 것 아니냐"**가 된다. 규모(7-컨소시엄)만으로는 약하다. **진짜 novelty는 site==population confound가 결론을 *질적으로* 바꾼다는 점**이어야 한다:

- Souza의 multi-site(서구)는 site와 biology가 **분리 가능**하다 → "site를 지우면 된다"가 원리적으로 성립.
- 우리의 한국 vs 서구는 site와 population이 **near-collinear**라 site-down과 biology-preserved가 **얽혀서, site probe가 chance로 떨어지는 것이 biology 공제거인지 진짜 harmonization인지 단일 probe로는 결정 불가능(undecidable)**하다(Bayer 2022 + 우리 02 v2의 비순환 장치가 이걸 부분적으로만 푼다).
- → 기여 문장은 "site를 더 잘 지웠다"가 아니라 **"confounded regime에서는 shortcut 제거의 성공/실패를 단일 site-probe로 판정할 수 없으며, biology-preserving 비순환 probe가 유일한 판정자임을 7-컨소시엄에서 보인다"**가 되어야 한다. 이게 Souza와 갈리는 지점.
- **왜 publishable**: Souza 2023/2024·Achara 2025가 이 "audit" 계열로 published(장르는 보상됨). 단 위 차별화를 명시하지 않으면 incremental로 읽힐 위험.

#### 3.2.2 fallback (audit이 "당연하다"고 reject될 때)
시나리오 E(**site==population을 명시적으로 다루는 7-컨소시엄 벤치마크/데이터셋·프로토콜 공개**)를 audit과 묶어 *주 기여*로 승격. 기존 벤치마크가 거의 전부 서구-overlap이므로, 한국 코호트 포함 confounded 벤치마크 자체가 audit 결과와 독립적으로 가치를 가진다.

### 3.3 그래도 정확도 향상을 노린다면 (high-risk, 사전 승인 필요)
가장 가망 있는 단일 후보는 **augmentation/domain-randomization(MixStyle, SynthSeg류)** — site를 제거가 아니라 "무관화"라 site==population에 덜 파괴적(Billot 2023). **[2026-06-04 실행 — 07]**: MixStyle을 직접 돌렸으나 (a) morphometry를 못 이기고(Δ −0.03~−0.08) (b) site shortcut도 못 줄임(site-probe +0.026) → 04의 headroom~0 예측이 image-level에서 확증됨. adversarial 단독은 overcorrection 위험(Bayer 2022, Liu 2023)으로 비권장.

#### 3.3.1 negative-result 논문의 알려진 기각 벡터 (정직성, 07로 일부 해소)
**[해소]** "image harmonization은 morphometry를 못 이긴다"의 근거가 이제 N4(03)+ComBat/GAM(02/05)+**MixStyle domain-randomization(07, LOCO·이중 probe, 2 cohort×2 seed)**로 정규화·특징·스타일 세 축을 커버한다 → "강한 방법 안 써봤다" 반박이 크게 약화됨. **[잔존 한계]** (a) GAN/IGUANe·**대형/사전학습 backbone은 여전히 미실행**(07은 작은 CNN, train AD 107~205로 data-limited) → reviewer가 "foundation model이면 다를 것"이라 반박 가능, 단 상대결론(morphometry 우위)은 04+07로 견고. (b) **04/07의 site-robust 근거에서 가장 site-특이한 AJU가 held-out 타깃이 못 됐다(CN n=23)** → 가장 강한 반례 케이스는 여전히 미검증, 논문에 명시 필요.

---

## 4. 검증·재현 (이 문서의 근거)

- **로컬 수치**: `01`~`05` + `07_deep_mixstyle/RESULTS.md` + 각 `out/*.json`. feature-level probe는 subject-grouped GroupShuffleSplit·≥2 분류기, 07은 2 seed(17/42) 재현.
- **문헌 검증 상태**: deep-research 25 claim 중 **24 confirmed(다수 3-0 vote), 1 killed**. killed = ComBat 독립성 가정을 단일 HBM 소스로만 표현한 narrow formulation(다중 소스 버전은 confirmed). 본문 인용은 confirmed만.
- **원본 무결성**: manifest sha256 실행 전후 동일(`5ae141a4fa47df24…`, 01~05), 07 data csv sha256(`ab105ccd7808ea76…`) 전후 동일, raw/v2 텐서 READ-ONLY.

## 5. References (peer-reviewed, deep-research 검증분)

1. Fortin et al. 2017/2018. *Harmonization of cortical thickness measurements across scanners and sites.* **NeuroImage** 167:104-120. PMID 29155184.
2. Tassi/Bonacina et al. 2024. *(ComBat external-validation of residual site)* **Human Brain Mapping** 45(18):e70085. PMID 39704541.
3. Bayer et al. 2022. *Site effects how-to / ComBat limitations.* **Frontiers in Neurology** 13:923988.
4. Saponaro et al. 2022. *(site-confound RF control + unmasking ASD; ABIDE ASD AUC 0.58→0.67)* **NeuroImage: Clinical**. PMID 35700598. [ASD 0.58→0.67 수치는 deep-research 3-0 검증분 — "harmonization은 weak signal unmask용"이라는 핵심 전제의 유일한 정량 근거이므로 투고 전 원문 1회 직접 대조 권장]
5. Souza et al. 2023. *(intensity norm cannot remove site)* **JAMIA** 30(12):1925-1933. PMID 37669158.
6. Souza et al. 2024. *Is the Disease Classifier a Secret Site Classifier?* **IEEE J Biomed Health Inform** 28(4):2047-2054.
7. Achara, Puyol-Antón, Hammers, King 2025. *Invisible Attributes, Visible Biases.* **FAIMI @ MICCAI 2025**, LNCS 15976. arXiv:2509.09558.
8. Guan et al. 2021. *(AD2A deep domain adaptation)* **Medical Image Analysis**. PMID 33930828.
9. Liu et al. 2023. *(adversarial harmonization overcorrection)* **Human Brain Mapping** 10.1002/hbm.26422.
10. Dinsdale et al. 2021. *Deep learning-based unlearning of dataset bias.* **NeuroImage**.

_보조(literature-scout, peer-reviewed이나 deep-research 미검증 — [VERIFY] 권장): Pomponio 2020 ComBat-GAM (NeuroImage); Chen 2021 CovBat (HBM 10.1002/hbm.25688); Cohen 2018 CycleGAN hallucination (MICCAI); Billot 2023 SynthSeg domain randomization._
