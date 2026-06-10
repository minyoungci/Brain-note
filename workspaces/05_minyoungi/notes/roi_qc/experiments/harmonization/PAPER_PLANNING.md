# Harmonization Audit — Paper Planning (multi-agent workflow 산출, 2026-06-04)

_생성: 17-agent workflow(extract 7 → adversarial verify 7[research-critic] → synthesize). 검증: 7개 실험 전부 numbers_match_json=TRUE(조작 없음), 전부 minor_issues(major 없음). 문제는 숫자가 아니라 해석/provenance._

> ⚠️ 이 문서는 *계획*이다. 아래 §9(MUST 체크리스트)를 닫기 전에는 투고 불가. 특히 MUST-1(positive-unmask control)이 없으면 핵심 novelty가 "Bayer 2022 재확인"으로 붕괴(Reviewer-2 ATTACK 1).

---

## PART I. 논문 골격 (skeleton author)

I have everything I need. Both reference files confirm the experiment one-liners and the protocol numbers. I'll now write the complete paper skeleton, grounding every number in the verified JSON (using corrected numbers where the verifier flagged mismatches).

Let me note the key corrected numbers I must use:
- Exp 02: pooled CN/AD raw 0.893 → combatB 0.852 (−0.040, NOT −0.043); site7 0.238→0.175
- Exp 03: N4 appearance 0.556→0.517 (RF); the LogReg 0.490→0.517 is **unverified/stdout-only** and 0.517 is suspiciously identical to RF — must tag [VERIFY]
- Exp 04: "site-shift cost" baseline is a POOLED random split, not within-cohort (mislabeled); held-AUC ~0.92, gaps 0.001–0.004 inside one SD (~0.013–0.015)
- Exp 05: GAM vs linear gap = 0.0039 (main JSON), 0.0024 is the verify re-run
- Exp 07: MixStyle gain held-KDRC s17 = **+0.006** (not +0.007), s42 = +0.011; train AD max = **174** (not 205); site-probe +0.026
- Exp 08: CN/MCI pooled 0.673→0.568, within-ADNI 0.578→0.577 (LogReg, **unsaved**); RF within-ADNI 0.620→0.618; CN/AD control ALSO drops −0.041 under combatB_nodx; AJU 980/23 **unsaved**

Here is the complete skeleton.

---

# 논문 스켈레톤 — Multi-site AD 표현학습 Harmonization Shortcut-Audit

> 작성: senior author 관점, 검증 JSON·README·06_feasibility 근거. **모든 수치는 verified JSON 기준이며, verifier가 mismatch로 플래그한 값은 수정본(corrected)을 사용했다.** stdout-only/미저장 수치는 본문에서 **[UNVERIFIED — 투고 전 저장 필수]**로 명시.

---

## 1. Working Title (3 options) + Target Venue

**Option A (mechanism-forward, 권장):**
> **"When Harmonization Deflates Instead of Unmasks: A Representation-Validity Audit of Brain-MRI Site Correction under Population==Site Confounding"**

**Option B (protocol-forward):**
> **"Site is Not Always a Nuisance: A Dual-Probe Shortcut-Audit Protocol for Multi-Site Alzheimer Representation Learning in the Confounded (Korea vs Western) Regime"**

**Option C (negative-result-forward, 보수적):**
> **"No Free Lunch from Harmonization: Feature-, Image-, and Deep-Level Site Correction Fail to Beat Morphometry across 7 Alzheimer Cohorts"**

**Target venue (구체):**
| 우선순위 | Venue | 적합성 근거 |
|---|---|---|
| 1 | **NeuroImage: Clinical** (SCI, IF~4) | Saponaro 2022(직접 foil)·여러 ComBat 논문의 home. negative/audit 결과 수용 전례. |
| 2 | **Human Brain Mapping** (SCI, IF~3.5) | Tassi 2024·Liu 2023·Chen 2021(우리가 인용한 ComBat 실패모드)의 home. methodological audit 친화. |
| 3 | **IEEE J-BHI** (SCI, IF~7) | Souza 2024(secret site classifier, 우리 차별화 대상)의 home → 동일 reviewer pool에 직접 positioning. |
| 4 (conf) | **MICCAI / FAIMI@MICCAI workshop** (LNCS) | Achara 2025·Souza가 발표한 audit 장르. 단 본편은 저널이 안전(데이터·프로토콜 분량). |
| fallback | **Scientific Data / GigaScience** (벤치마크 트랙) | 06 §3.2.2 fallback: site==population 7-컨소시엄 벤치마크를 주 기여로 승격할 때. |

> ⚠️ 비판적 조언: J-BHI(Souza의 home)는 reviewer가 Souza 2024를 가장 잘 알아 "incremental" 공격이 가장 날카롭다. **차별화(§3)가 완성되기 전엔 NeuroImage:Clinical이 가장 안전**하다.

---

## 2. Abstract Draft (1 paragraph, key numbers 포함)

> Harmonization은 multi-site 뇌 MRI에서 scanner/site shortcut을 제거해 진단 신호를 회복시키는 표준 도구로 여겨진다. 그러나 거의 모든 positive 근거는 site와 생물학이 분리 가능한 **overlap regime**에서 나왔다(Fortin 2017; Saponaro 2022, ASD AUC 0.58→0.67). 우리는 **site가 모집단과 거의 공선(near-collinear)인 confounded regime** — 7개 컨소시엄(ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC), 약 13,000 T1 세션, 한국(AJU/KDRC) vs 서구, traveling subject 없음 — 을 다룬다. 이중 probe(site-probe↓ + 비순환 biology-probe 보존) + null control + leave-one-consortium-out(LOCO)로, harmonization을 feature(ComBat)·image(N4/Nyúl/WhiteStripe)·deep(MixStyle) 세 레이어에서 감사한다. 결과: (1) site는 픽셀보다 metadata에 강하게 박혀 있고(consortium 식별 metadata 0.761 > appearance 0.556, 생물학-only 통제 0.151≈chance 0.143), 이미지 정규화로는 거의 안 지워진다(N4 appearance 0.556→0.517, chance까지의 ~9%만). (2) feature-level ComBat은 site를 줄이면서(7-way 0.238→0.175) within-site 생물학을 보존하나(within-ADNI CN/AD AUC ~0.885 불변), 잔여 site는 모집단 교란분이다. (3) 강한 morphometry는 이미 site-robust다(LOCO held-cohort CN/AD AUC ~0.92, site-shift gap 0.001–0.004, 단 한 SD~0.013 이내). (4) 강한 image harmonization(MixStyle)도 morphometry를 못 이기고(Δ −0.03~−0.08, 전 seed) site shortcut을 오히려 키운다(site-probe +0.026). **핵심 기여 — mask vs inflation:** Saponaro의 unmasking과 달리, 약한 task(CN/MCI)에서 harmonization은 신호를 **회복하지 못하고 오히려 pooled accuracy를 진짜 within-site 신호 쪽으로 깎는다**(pooled 0.673→0.568; within-ADNI flat). 즉 confounded regime에서 site는 신호를 *가리는 nuisance*가 아니라 confounded label을 *부풀리는 shortcut*이며, harmonization은 그 inflation을 올바르게 제거할 뿐 unmask하지 않는다. 따라서 우리는 정확도 향상이 아니라 **representation-validity audit 프로토콜**을 기여로 제시한다: confounded regime에서는 단일 site-probe로 harmonization의 성공/실패를 판정할 수 없고, biology-preserving 비순환 probe가 유일한 판정자다.

> **Abstract 내 수치 출처 매핑(전부 verified JSON, corrected):** 0.761/0.556/0.151/0.143 = 01 · 0.517 = 03(RF) · 0.238→0.175 / 0.885 = 02 · 0.92 / 0.001–0.004 = 04 · −0.03~−0.08 / +0.026 = 07 · 0.673→0.568 = 08(RF pooled). **0.578→0.577(within-ADNI LogReg)는 stdout-only라 abstract에 넣지 않고 "flat"으로만 표현** — 본문에서 RF 0.620→0.618(저장됨)로 대체.

---

## 3. Central Thesis (one sentence) + mask-vs-inflation 메커니즘

**Central thesis (한 문장):**
> **site가 모집단과 공선인 regime에서는 harmonization이 진단을 개선하지 못한다 — 강한 morphometry(CN/AD held-AUC ~0.92)를 이기지도, 약한 task(CN/MCI)를 구제하지도 못하며, 그 이유는 site가 신호를 *가리는(mask)* nuisance가 아니라 confounded label을 *부풀리는(inflate)* shortcut이기 때문에 harmonization은 부풀린 부분을 올바르게 깎아내릴 뿐이다.**

**mask vs inflation 메커니즘 (핵심 novelty, 2-축 대비):**

| | **MASK (Saponaro 2022, overlap)** | **INFLATION (본 연구, confounded)** |
|---|---|---|
| 기하 | signal ⊥ site | signal ∥ site (near-collinear) |
| site의 역할 | signal *위에 더해진* additive nuisance | signal을 *대체하는* shortcut |
| 예시 | ABIDE ASD: site 변동이 약한 신호를 덮음 | AJU = MCI-heavy(980 MCI/23 CN [UNVERIFIED]) → "site=AJU"가 곧 "label=MCI" |
| harmonization 효과 | site 제거 → 가려진 신호 **드러남(↑)** | site 제거 → 부풀린 label 신호 **깎임(↓)**, within-site 진짜 신호로 수렴 |
| 정량 trajectory | AUC **0.58→0.67 (상승)** | pooled AUC **0.673→0.568 (하강)**; within-ADNI flat |
| metric 함의 | 단일 site-probe로 성공 판정 가능 | 단일 site-probe **판정 불가** — biology-preserving 비순환 probe가 유일 판정자 |

> **honest 경계 (반드시 본문에 명시 — 안 하면 reviewer가 무너뜨림):** inflation은 *demonstrated*가 아니라 *"데이터가 inflation과 일치하고 masking과 불일치한다"* 수준으로만 주장한다. 판별 증거는 단일 수치가 아니라 **대비**(약 task deflate vs 강 task within-site 보존)이며, AJU 980/23·CN/MCI LogReg column·within-ADNI delta 0.002는 provenance/precision gap이 있다(§8 한계).

---

## 4. Section-by-Section Outline

### 1. Introduction
- 1.1 Motivation: 멀티사이트 AD 모델이 해부 대신 scanner shortcut을 학습 (Souza 2024 secret-site-classifier; 01 metadata 0.761).
- 1.2 표준 가정과 그 한계: harmonization=nuisance 제거(Fortin 2017) — 단 overlap regime 전제. Bayer 2022의 collinearity 경고를 추상적 → **측정 가능한 현상**으로 전환하는 것이 본 연구.
- 1.3 site==population confound 정의: 한국 vs 서구, traveling subject 없음, covariate 분포 거의 disjoint.
- 1.4 Contribution 명시 (overclaim 방지용 4개 — §7과 일치):
  - (C1) confounded regime에서 harmonization은 강·약 task 둘 다 진단을 개선하지 못한다 (음성 결과, 3 레이어).
  - (C2) **mask→inflation 부호 반전**: 동일 개입이 overlap에선 unmask(↑), confounded에선 deflate(↓).
  - (C3) **단일 site-probe의 판정 무효화**: chance로 떨어지는 probe가 shortcut 제거인지 biology 공제거인지 구분 불가 → biology-preserving 비순환 probe가 유일 판정자.
  - (C4) 7-컨소시엄 site==population 벤치마크 + 비순환 audit 프로토콜 (fallback 기여).

### 2. Related Work
- 2.1 ComBat 계열 (조건부 성공): Fortin 2017 (76.6→36.3%), Tassi 2024 (외부검증 잔여 site), Bayer 2022 (collinearity over/under-correction), Pomponio 2020 GAM [VERIFY].
- 2.2 Image-level/deep (가장 어려운 케이스): Souza 2023 (정규화로 site 안 지워짐 raw 85%≈harm 85%), Guan 2021 (deep DA는 *약한* baseline·overlap에서만 이김), Liu 2023/Dinsdale 2021 (adversarial overcorrection), Cohen 2018 (CycleGAN hallucination), Billot 2023 (domain randomization).
- 2.3 Audit/leakage 장르: Souza 2024 (secret site classifier), Achara 2025 (invisible attributes).
- 2.4 **본 연구의 위치 (핵심 단락):** §3 novelty statement — Souza는 "site가 디코딩되는가?"(yes)에 답, 우리는 "그렇다면 제거가 진단을 돕는가, 그리고 site를 제거했는지 biology를 제거했는지 *알 수 있는가*?"에 답(둘 다 no). Saponaro의 직접 거울상(unmask↔deflate).

### 3. Data & the Confound
- 3.1 7 컨소시엄, ~13,022 T1 세션, manifest(13,022×101). 한국(AJU/KDRC) vs 서구(ADNI/NACC/AIBL/OASIS/A4).
- 3.2 confound 정량화: 01의 metadata 식별(A4/KDRC/AJU/AIBL recall 0.99/0.99/0.95/0.84). vendor/field-strength/voxel 분포 disjoint.
- 3.3 라벨 구성과 함정 (정직성): AJU=MCI-heavy(AD-scarce, CN n=23), A4=CN_preclinical만(MCI 0), NACC "ImpairedNotMCI"≠ADNI MCI. → **AJU는 CN/AD held-target 불가**, MCI 정의 이질성 → 분석 범위 한계 사전 고지.
- 3.4 feature: fs_vol 26 ROI + fs_MaskVol(eTIV 부재, ICV 프록시, FastSurfer/VINN, T1-only). image-appearance 20-dim 캐시 특징.

### 4. Audit Protocol (방법)
- 4.1 5단계 파이프라인 (06 §2.1): [0] LOCO split 먼저 → [1] harmonization TRAIN-only fit→held apply → [2] site-probe↓ → [3] biology-probe 보존(age R²+CN/AD AUC) → [4] null control(shuffle site→chance, fake label→0.5) → [5] morphometry baseline 병기.
- 4.2 이중 검증 + 비순환 장치 (02 v2): dx 미보존 ComBat에서도 within-site disease AUC 유지 = "shortcut 제거 vs biology 파괴" 구분자.
- 4.3 probe 견고성: subject-grouped GroupShuffleSplit, ≥2 분류기(RF+LogReg), ≥2 seed.
- 4.4 함정 2개 (06 §2.2): (i) confounded regime에선 site-probe가 chance로 떨어짐이 *위험 신호*일 수 있다 → biology가 유일 guardrail; (ii) in-sample 지표 금지(Tassi 2024).
- ⚠️ **자기 비판 단락 (reviewer 선제):** 우리 02/05는 현재 full-fit이라 4.1[1]을 위배 → §8/§9에서 train-only 재실행 명시.

### 5. Results (각 실험 → claim + figure 매핑)

| Exp | Section | 제공하는 specific claim (corrected numbers) | Figure | 비순환/한계 태그 |
|---|---|---|---|---|
| **01** | 5.1 Site identifiability | site는 3축에 차등 박힘: metadata **0.761** > appearance **0.556** > biology-only **0.151**(≈chance 0.143). top appearance feature는 intensity/edge descriptor 중심(단 csf_mean/deepgm_mean은 tissue 강도 = 부분적 biology 가능). | **Fig 2** | "shortcut"(예측적)이 아니라 **recoverability**만 주장. biology 통제는 brain_vox 단일 프록시. |
| **02** | 5.2 Feature ComBat | site7 **0.238→0.175**(chance 0.143 쪽), within-ADNI CN/AD AUC ~**0.885 불변**, pooled CN/AD **0.893→0.852**(−0.040), null pass(0.143/0.498). scan4는 0.243→**0.243**(chance 0.2 위 잔존). | **Fig 3** | site 하락 **일부 기계적**(full-fit). "AJU=AD-heavy" 예시는 **오류**(AJU는 MCI-heavy) → 제거/수정. sex-probe 미측정. |
| **03** | 5.3 Image normalization | appearance **0.556→0.517**(N4 최선, RF probe, chance까지 ~9%만). blur 0.556→0.554(무효). LogReg reversal 0.490→0.517은 **[UNVERIFIED — stdout-only, 0.517이 RF값과 동일(복사오류 의심), verify 스크립트는 반대 방향 출력]**. | **Fig 4** | LogReg 결과는 **결과로 단정 불가**, [VERIFY] 태그 필수. appearance 벡터엔 texture/resolution 미포함 → "texture에 산다"는 01/02 인용이지 03 증명 아님. |
| **04** | 5.4 Morphometry LOCO | held-cohort CN/AD AUC ~**0.92**(raw 0.920/icv 0.924), site-shift gap **0.001–0.004**(단 한 SD ~0.013–0.015 이내). minyoung4 stage8M 0.933와 근접. | **Fig 5** | "site-shift cost" 기준선은 **pooled multi-cohort random split**(변수명 random_within 오기) → within-cohort 분해 아님. 한국 경계는 **KDRC 단독(n=1)**. icv 이득은 within-SD·AIBL 한정. |
| **05** | 5.5 Nonlinear-age control | ComBat-GAM vs 선형: site7 gap **0.0039**(main JSON; verify 재실행 0.0024<pooled_sd 0.0029), slope_spread GAM 0.00719≈raw 0.00718. → age 비선형은 floor를 못 낮춤. | **Fig 6 (panel)** | **age 비선형 artifact 한 클래스만** 배제. scanner/resolution/segmentation-bias floor는 미배제. "legitimate population residue"는 02/06 인용. verify 수치 stdout-only. |
| **07** | 5.6 Deep harmonization | MixStyle img-AUC vs morphometry: Δ **−0.03~−0.08**(전 run). MixStyle gain over vanilla held-KDRC **s17 +0.006 / s42 +0.011**. site-probe **+0.026**(줄지 않고 증가). | **Fig 7** | "강한"은 **overclaim**(작은 from-scratch CNN, train AD ≤**174**). morphometry 26 ROI(entorhinal 포함) vs CNN 5 ROI(entorhinal 없음) = **feature-support 비대칭**. site-probe seed swing(0.034)>효과(+0.026). |
| **08** | 5.7 **Mask vs inflation (핵심)** | CN/MCI pooled **0.673→0.568**(deflate), within-ADNI RF **0.620→0.618**(flat; LogReg 0.578→0.577 **[UNVERIFIED]**). CN/AD 대조: pooled도 combatB_nodx에서 **0.893→0.852(−0.041)** → isolation **부분적**(CN/MCI −0.083 vs CN/AD −0.041). | **Fig 8** | AJU 980/23·LogReg column·count 전부 **[UNVERIFIED stdout-only]**. within-ADNI delta 0.002 = **sub-noise**("no mask"를 "mask below detection"과 구분 불가). A4 CN 매핑이 pooled 조성 변경. |

> Results 서술 원칙: 강한 task(04)+deep(07)은 **"개선 없음"**, 약한 task(08)은 **"구제 없음 + deflate"**, 01/02/03/05는 **전제 확립 + artifact 배제 scaffold**. 핵심 추론은 **07+08**에 있고 01–05는 지지대.

### 6. Discussion
- 6.1 두 positive 결과(Saponaro unmask, Guan deep-DA)의 **비전이(non-transfer)** + 부호 반전.
- 6.2 단일 site-probe의 undecidability → 비순환 probe 필요성 (C3).
- 6.3 Souza 2024와의 차별화 재강조: 식별 가능성(premise) vs 제거 가능성·판정 가능성(contribution).
- 6.4 실용 함의: confounded cohort에선 harmonization 전 **mask인지 inflation인지부터 판별**해야 한다(프로토콜 처방).

### 7. Limitations (§8 전개 — Reviewer-2 attack 흡수)

### 8. Conclusion
- confounded regime에서 harmonization은 진단을 개선하지 못하며, 그 이유는 site가 inflation shortcut이기 때문이다. 기여는 정확도가 아니라 **언제 harmonization이 도움이 되고 안 되는지를 confounded regime에서 정량화한 audit 프로토콜**이다.

---

## 5. FIGURE Plan (numbered)

| Fig | 제목 | 무엇을 보여주나 | 데이터 출처 | 비고 |
|---|---|---|---|---|
| **Fig 1** | site==population confound 개념도 | 한국 vs 서구 코호트의 covariate 분포 disjoint + mask/inflation 2-기하 schematic (signal⊥site vs signal∥site) | 개념도(데이터 아님) + 03.4 분포 | overclaim 없음. mechanism 그림. |
| **Fig 2** | 3축 site identifiability | bar: metadata 0.761 / appearance 0.556 / biology-only 0.151 vs chance 0.143; top-appearance feature importance | **01** out JSON | csf/deepgm 강도는 별색 표기(부분 biology 가능). |
| **Fig 3** | ComBat dual-probe | site7 0.238→0.175(chance선)+within-ADNI AUC 0.885 불변+null bars; scan4 잔존도 **함께** | **02** out JSON | scan4 0.243 잔존을 숨기지 말 것(검증 지적). |
| **Fig 4** | image normalization ceiling | original/N4/Nyúl/WhiteStripe/blur appearance probe(RF), chance선, ~9% 진행 표시 | **03** out/n4_variant_results.json | LogReg panel은 **[VERIFY] 워터마크** 또는 제외. |
| **Fig 5** | LOCO morphometry generalization | held-cohort별 CN/AD AUC(ADNI/AIBL/KDRC)+pooled-random 기준선+gap; **SD band 표시** | **04** out/loco_results.json | 기준선을 "pooled random"으로 **정직하게 라벨**(within-cohort 아님). |
| **Fig 6** | nonlinear-age control | GAM vs linear site7 probe + slope_spread overlay (gap 0.0039) | **05** out/combat_gam_results.json | "한 artifact 클래스만 배제" 캡션 명시. |
| **Fig 7** | deep harmonization vs morphometry | seed별 img-AUC vs morphometry-AUC(Δ −0.03~−0.08)+site-probe vanilla→mixstyle(+0.026); paired same-seed delta 강조 | **07** out/*/result.json | 절대 magnitude 대신 **paired delta** 강조. feature-asymmetry 캡션 disclose. |
| **Fig 8** | **mask vs inflation (핵심 그림)** | CN/MCI: pooled 0.673→0.568 ↓ vs within-ADNI flat; 옆에 Saponaro 0.58→0.67 ↑ 대비 화살표; CN/AD 대조(pooled도 −0.041 표시) | **08** out/cn_mci_results.json (RF만) | LogReg·AJU count는 그림 본문 금지, 캡션에 [VERIFY]. within-ADNI는 RF 0.620→0.618 사용. |

> Fig 8이 paper의 "money figure". RF(저장된 값)만으로 그려도 deflate↓ vs flat을 보여줄 수 있으니 **LogReg 없이 구성** 권장.

---

## 6. TABLE Plan

| Table | 내용 | 출처 | 핵심 |
|---|---|---|---|
| **Table 1** | 7-컨소시엄 데이터 요약: n_session, CN/MCI/AD count, vendor, field-strength, voxel, 한/서 | manifest (03절) | AJU CN=23·A4 MCI=0을 **명시**(범위 한계 근거). 일부 count는 **재실행 후 저장 필요**. |
| **Table 2** | 선행연구 vs 본 연구 regime 비교 | 06 §1.1 | overlap-success vs confounded; mask vs inflation 행 포함. |
| **Table 3** | 필수 metric & 합격 기준 & 우리 현황 | 06 §2.2 | site-probe/biology/null/LOCO/baseline/비순환/견고성 7행. |
| **Table 4** | 전 실험 결과 종합 (corrected numbers) | verified JSON | 각 행에 **provenance 열**(JSON-saved vs stdout-only) 추가 → 정직성. |
| **Table 5** | mask vs inflation 정량 대비 | 08 + Saponaro | overlap(↑0.58→0.67) vs confounded(↓0.673→0.568); within-site 보존. |
| (supp) | **S1 provenance audit** | verified JSON | 어떤 수치가 저장/미저장인지 전수 — reproducibility 정면 대응. |

---

## 7. CLAIMS WE MAKE vs CLAIMS WE DO NOT MAKE

### ✅ CLAIMS WE MAKE (방어 가능, 근거 부착)
1. site는 픽셀보다 metadata에 강하게 박혀 있다 (01: metadata 0.761 > appearance 0.556 > biology-only 0.151≈chance). **[recoverability 한정]**
2. 이미지 강도 정규화(N4 등)는 appearance site를 거의 못 지운다 (03: 0.556→0.517, chance까지 ~9%; Souza 2023 일치). **[RF probe 한정]**
3. feature-level ComBat은 site를 줄이면서 within-site 생물학을 보존한다; 잔여 site는 모집단 교란분이다 (02: 0.238→0.175, within-ADNI 0.885 불변, null pass). **[CN/AD·within-ADNI 한정, full-fit caveat]**
4. age 비선형(GAM)은 feature-level floor를 낮추지 못한다 (05: gap 0.0039, within noise). **[age-nonlinearity artifact 한 클래스만 배제]**
5. 강한 ROI-volume morphometry는 이미 site-robust하다 (04: held-AUC ~0.92, gap 0.001–0.004). **[Western↔Western 강함, Korea는 KDRC 단독]**
6. 강한 image harmonization(MixStyle)도 morphometry를 못 이기고 site shortcut을 못 줄인다 (07: Δ −0.03~−0.08, site-probe +0.026). **[작은 CNN·5 ROI 한정]**
7. **mask→inflation 부호 반전**: confounded regime에서 약한 task harmonization은 신호를 회복하지 못하고 pooled accuracy를 within-site 진짜 신호 쪽으로 deflate한다 (08: pooled 0.673→0.568, within-ADNI flat). **[데이터가 inflation과 일치·masking과 불일치 수준; 단정 아님]**
8. confounded regime에서는 단일 site-probe로 harmonization 성공을 판정할 수 없고, biology-preserving 비순환 probe가 유일 판정자다 (02 v2 비순환 장치). **[방법론적 처방]**

### ❌ CLAIMS WE DO NOT MAKE (overclaim 금지선)
1. ~~harmonization이 CN/AD 진단 정확도를 향상시킨다~~ (정반대를 보임).
2. ~~우리 inflation 메커니즘이 *uniquely proven*이다~~ — "masking과 불일치, inflation과 일치"만 주장. (08 provenance gap.)
3. ~~morphometry가 모든 모집단 경계에서 robust하다~~ — Korea 경계는 KDRC **단독(n=1)**, AJU(최강 confound)는 CN/AD held-target **불가**.
4. ~~harmonization이 "in principle" unmask 불가능하다~~ — "no unmasking **observed**"만. (1 task·fs_vol·ComBat·within-distribution 한정.)
5. ~~MixStyle이 site를 못 줄인다 = site shortcut이 irreducible하다~~ — "이 augmentation이 site 축과 orthogonal"일 가능성 배제 못 함.
6. ~~foundation/GAN backbone도 실패한다~~ — 작은 CNN만 검증; 큰 backbone은 미실행.
7. ~~feature-level 결과가 image-level harmonization headroom을 bound한다~~ — 다른 표현 축(04 한계 #5).
8. ~~site 잔여 floor가 "legitimate population residue"다~~ — **"기원 미상(population vs segmentation bias) 잔여 site"**로 downgrade. (05는 segmentation bias 미배제.)
9. ~~sex/diagnosis 생물학 전반이 보존된다~~ — sex-probe **미측정**, MCI 보존 **미검증**; CN-vs-AD만.
10. ~~7-컨소시엄 규모가 novelty다~~ — **명시적 disclaim**; novelty는 regime-induced 부호반전·metric 무효화.

---

## 8. LIMITATIONS (정직 — 잔존 Reviewer-2 attack 흡수)

> 우선순위 = Reviewer-2 위험도 순. **존재적(existential) 2개를 맨 앞에 둔다.**

**L1 (존재적). mask vs inflation은 within-study 대비로 *식별*되지 않고 유추된다.** 단일 실험에 unmask 비교 regime(overlap/traveling-subject/synthetic-mask)이 없다. 08의 pooled deflate(−0.083)는 dx 미보존 ComBat이 dx-상관 분산을 기계적으로 제거한 *예상* 결과와 구분되지 않으며, CN/AD 대조도 같은 ComBat에서 −0.041 떨어져 **isolation이 부분적**이다. → 데이터는 inflation과 **일치**하나 benign biology-destruction에 대해 **uniquely identify하지 못한다**. (§9: 자체 파이프라인 내 positive unmask control 필요.)

**L2 (존재적). 강한-task site-robustness는 disjoint 모집단 1개(KDRC)에만 기댄다.** ADNI/AIBL은 둘 다 서구. 가장 site-특이한 AJU(appearance 0.822)는 CN n=23으로 **held-CN/AD target 불가** → site==population을 정의하는 바로 그 경계의 최강 반례가 구조적으로 미검증. 또한 04의 "site-shift cost" 기준선은 **pooled multi-cohort random split**(within-cohort 아님)이고 gap이 한 SD 이내 → "cost=0.001" 정밀도 미지지.

**L3 (심각). deep harmonization은 작고 data-limited하며 feature-support가 비대칭이다.** 07은 from-scratch 3D CNN(train AD ≤174), morphometry는 26 ROI(entorhinal 포함) vs CNN 5 ROI(entorhinal 없음) → "image<morphometry"가 부분적으로 input-coverage artifact. GAN/IGUANe·foundation backbone 미실행 → "foundation이면 다르다" 반박 잔존. **"강한 image harmonization"이라 부르지 않는다.**

**L4 (심각). 약한-task 결론은 라벨 이질성·analyst 구성·sub-noise null에 노출.** MCI 정의가 컨소시엄마다 다름(ADNI MCI≠NACC ImpairedNotMCI); within-ADNI(1 site)에서 "no mask"를 regime 전체로 일반화 못 함. A4 CN_preclinical 매핑이 pooled CN 조성 변경. within-ADNI delta 0.002는 sub-noise → "no mask"를 "mask below detection at 8 splits"와 구분 불가.

**L5 (심각·자초). 02/05 ComBat은 full-fit이라 우리 자신의 프로토콜(train-only fit)을 위배하고 Tassi 2024가 경고한 in-sample inflation에 해당.** headline 0.238→0.175는 **부분적으로 기계적/tautological**(ComBat이 batch mean을 뺌). scan4 잔여(0.243, chance 0.2 위)는 headline 표에서 누락됐었음. → §9에서 train-only 재실행 필수.

**L6 (중간). 단일 modality·단일 segmentation pipeline.** 전 feature 결과가 fs_vol(FastSurfer/VINN, T1-only, eTIV 부재). 05의 floor가 모집단 잔여인지 **FastSurfer segmentation site-bias**(해상도 민감)인지 미분리. multimodal(T1+FLAIR/PET) 미검증.

**L7 (중간, cross-cutting). Provenance.** load-bearing "독립 검증" 수치(02 site7 0.355→0.163, 03/05/08 LogReg, **08 AJU 980/23**, 05 0.0024<0.0029)가 **전부 stdout-only, 저장 안 됨**. audit/reproducibility 논문에서 치명적. 03의 LR/RF 0.517 충돌(복사오류 의심)·verify 스크립트 반대-방향 출력도 미해결.

---

## 9. 'Before Submission' Checklist (무엇을 더 돌려야 하나)

> 사전 승인 필요 항목(GPU/벌크) 표시. **MUST = 안 하면 reject 위험 / SHOULD = 강력 권장 / NICE = 여유 시.**

**🔴 MUST — 존재적 attack 차단 (새 실험/재실행)**
1. **[L1] 자체 파이프라인 내 positive-unmask control** — 두 서구 코호트를 down-sample해 overlap을 강제하거나 CN/CN split에 site-balanced AD 효과를 주입 → **동일 dual-probe가 overlap에선 unmask(↑), confounded(AJU/KDRC arm)에선 deflate(↓)**임을 같은 그림에서 보임. **mask vs inflation을 유추→식별로 격상.** (CPU 가능, 사전 승인 권장.)
2. **[L5] 02/05 ComBat을 train-only fit → held-out apply로 재실행**, 외부검증 site reduction + scan4 잔여를 headline에 보고. (우리 프로토콜·Tassi 2024 부합. CPU.)
3. **[L7] 모든 stdout-only 수치를 versioned JSON으로 저장 + per-fold variance/CI 추가**: 02 site7 LogReg, 03 LogReg, 05 verify, **08 LogReg column·AJU 980/23·n_MCI/n_CN count**, 04 data counts·random_within. (CPU, 빠름. **최우선 — 안 하면 desk-level skepticism.**)
4. ✅ **[L7] 03 LR/RF 0.517 충돌 해소 + 하드코딩 수정 완료** (2026-06-07): verify_03_04.py를 03/04 폴더로 분할(`03_.../verify_n4_variant.py`, `04_.../verify_loco.py`), line 26 하드코딩 print를 실측 방향 판정으로 교체·재실행. 실측: LogReg original 0.490 < n4prod 0.517(Δ+0.027) vs RF 0.556→0.517 → **방향 불일치 = N4 site감소 probe-의존 결론 강화**(03/RESULTS.md와 일치).

**🟠 SHOULD — 심각 attack 약화 (싼 재실행)**
5. **[L2] 04 site-shift cost를 per-held within-cohort random-split 기준선으로 재계산 + bootstrap CI.** KDRC gap이 자체 CI를 넘는지 보고, 주장 "Western→Western 0 cost, Korea(KDRC) within-CI, AJU 미검증"으로 reframe.
6. **[L3] 07 feature-support 대칭화**: morphometry baseline을 CNN과 **동일 5 ROI**로 제한 재실행(또는 CNN에 whole-brain crop). 5-ROI morphometry가 여전히 이기면 비대칭 attack 소멸. (CPU로 morphometry-5ROI 먼저.)
7. **[L4] 08 A4 제외 민감도** + **ADNI-only MCI 정의 고정** unmask 재실행. RF variance/CI 보고 후 "no *detectable* unmask"로 reframe.
8. **[전체] 08 결론 문구 수정**: "unmasking impossible *in principle*" → **"no unmasking *observed*; mask/inflation은 within-site 비순환 probe로 판정"**. AJU 980/23은 *illustrative*로 강등.

**🟡 NICE — 견고성 보강**
9. [L6] 잔여-site ROI 부피를 voxel resolution/vendor에 회귀 → floor가 partialling out으로 붕괴 안 함을 보여 population vs segmentation-bias 부분 분리. (SynthSeg 교차검증은 out-of-scope.)
10. [L3, 사전 승인·GPU] foundation/larger backbone 1종으로 07 보강 — 단 상대결론(morphometry 우위)은 04+07로 충분하므로 *선택*.
11. 02 sex-probe 추가(보존 주장 보강), 07 held-AIBL 2nd seed.

**문구/메타 (코드 불필요)**
12. 전 RESULTS.md의 "AJU=AD-heavy"(02) → **"AJU=MCI-heavy/AD-scarce"**로 정정 (검증 mismatch).
13. 05 floor "legitimate population residue" → **"residual site of undetermined origin"**로 downgrade.
14. abstract/본문 모든 수치를 corrected 값으로 통일: 02 −0.040(not −0.043), 05 gap 0.0039(main), 07 +0.006(not +0.007)·train AD ≤174(not 205), 08 within-ADNI는 RF 0.620→0.618 우선.

---

### 핵심 메시지 (저자에게)
이 스켈레톤의 방어선은 **"우리는 정확도를 올렸다"가 아니라 "우리는 confounded regime에서 harmonization의 부호가 뒤집히고 표준 metric이 무효화됨을 측정했다"**이다. MUST 1–4(특히 **positive-unmask control**과 **provenance 저장**)를 끝내기 전엔, Reviewer-2의 한 문장 — *"inflation은 Bayer의 over-correction 재명명이고 핵심 null은 sub-noise·미저장 수치에 기댄다"* — 이 부분적으로 적중한다. 그 둘을 닫으면 reviewer의 반박이 오히려 우리 메커니즘을 *인정하면서 novelty만 다투는* 형태로 약화된다.

**참조 파일 (절대경로):**
- `/home/vlm/minyoungi/roi_qc/experiments/harmonization/README.md` (실험 인덱스·한 줄 결과)
- `/home/vlm/minyoungi/roi_qc/experiments/harmonization/06_feasibility_and_protocol.md` (프로토콜·문헌·feasibility, §2.1 파이프라인·§3.2.1 Souza 차별화·§5 references)
- 실험별 ground truth: `…/0{1,2,4,5,8}_*/out/*.json`, `…/07_deep_mixstyle/out/*/result.json` (검증 JSON이 03/05/08 LogReg·08 AJU count를 **미저장**으로 플래그 — 투고 전 저장 필수)

---

## PART II. 문헌 포지셔닝 / Novelty (literature agent)

I now have everything I need. I have the full feasibility doc with all 10 verified references, the README positioning, and the detailed verification JSON flagging exactly which claims are unverifiable/overclaimed per experiment. Let me synthesize the answer.

The critical insight from the verification JSON I must respect: the central thesis mechanism ("inflation not mask") is most directly tested in 08, but 08's load-bearing numbers (AJU 980/23, LogReg column, the within-ADNI flat null) have provenance gaps and the isolation is partial (CN/AD control also drops -0.041 under combatB_nodx). So my novelty statement must be honest about what is actually demonstrated vs asserted, or a reviewer will dismantle it.

---

# (a) NOVELTY STATEMENT vs Souza 2024 and Saponaro 2022

## The one-paragraph claim

Prior audit work establishes that a learned diagnosis representation *covertly encodes site* (Souza 2024) and that harmonization can *unmask* a weak signal hidden under site variance (Saponaro 2022, ABIDE ASD AUC 0.58→0.67). Both results were obtained in the **separable regime**, where site and biology occupy distinct, recoverable subspaces (Souza: Western multi-site; Saponaro: ABIDE with overlapping site/diagnosis distributions). Our contribution is to characterize a **qualitatively different regime — site==population (near-collinear, no traveling subjects, covariate distributions disjoint)** — and to show that this collinearity *inverts the sign of harmonization's effect and breaks the validity of its standard success metric*. Specifically: (i) in the confounded regime, the pooled label-correlated cross-site variance that Saponaro's unmasking *recovers* is instead a **shortcut that inflates** the confounded label, so a correctly-specified harmonizer *removes* it and pooled accuracy **falls toward the true within-site signal** rather than rising — i.e., there is no mask to lift; (ii) consequently the field-standard "site-probe → chance" success criterion becomes **undecidable as a standalone**: a probe falling to chance is observationally identical whether genuine acquisition shortcut was removed or population biology was co-erased (Bayer 2022's over-correction made operational), so a **biology-preserving, label-non-circular probe is the only admissible adjudicator**, which we demonstrate across 7 consortia and across three harmonization layers (feature ComBat, image N4, deep MixStyle).

## Why this is NOT incremental over Souza 2024

| Axis | Souza 2024 (secret site classifier) | This work |
|---|---|---|
| **What is shown** | A diagnosis classifier *decodes* site/scanner/sex (71/79/75%) — site is **identifiable** in the representation | Site identifiability is the *premise* (our 01 re-derives it: metadata 0.761 > appearance 0.556), not the contribution. The contribution is what happens to the **diagnostic target** when you act on that site signal |
| **Regime** | Separable (Western multi-site) → "erase site" is in-principle coherent | Collinear (Korea vs West) → "erase site" is in-principle **undecidable by the field's own metric** |
| **Prescription** | Implicit: site leakage is a problem to be removed | Removing it **cannot help and is not even measurable as success** without a second, non-circular probe; under collinearity the standard single-probe protocol is *invalid*, not just *insufficient* |
| **Direction of effect** | Not characterized (audit of static representation) | Sign-characterized: harmonization moves pooled accuracy **down** (toward within-site truth), the opposite of the implied "remove nuisance → recover signal" |

Souza answers *"is site decodable?"* (yes). We answer *"given that it is, can you remove it to help diagnosis, and can you even tell whether you removed site or biology?"* — in the confounded regime, **no and no**. Scale (7 consortia) is not the novelty and we explicitly disclaim it; the regime-induced metric breakdown is.

## Why this is NOT incremental over Saponaro 2022

Saponaro is the **direct foil**, and the contribution is best stated as its mirror image:

- Saponaro: harmonization **UNMASKS** — site variance was *hiding* a weak true signal; removing it *raises* AUC (0.58→0.67). Mechanism: signal ⊥ site, site was *additive nuisance on top of* signal.
- Ours: harmonization **DEFLATES** — in site==population, the "extra" pooled signal *is* the site axis (e.g., a single cohort being label-skewed makes site predictive of the label); removing it *lowers* pooled AUC back to the within-site truth. Mechanism: signal ∥ site, site was a *shortcut substituting for* signal.

The novel object is therefore a **third category of site–signal relationship**. The standard taxonomy is binary: site is either a *nuisance to remove* (Fortin/Saponaro success cases) or a *confound that breaks ComBat's independence assumption* (Bayer 2022, stated abstractly). We make the second category **operationally concrete and measurable** by showing it produces a *specific, predictable, opposite-signed accuracy trajectory* (down, not up) and by showing this defeats the single-probe success test — neither of which Bayer (a how-to/review) nor Saponaro (a positive unmask result) demonstrates empirically in a disjoint-population multi-cohort setting.

## Honest scope boundary (this is what keeps the novelty defensible)

The verification audit forces three caveats that **must** appear in the paper or the novelty claim is attackable:
1. The **inflation mechanism's quantitative anchor (AJU 980 MCI/23 CN) and the CN/MCI "within-ADNI flat" null have provenance/precision gaps** (08: LogReg column and counts are stdout-only, no saved artifact; within-ADNI delta 0.002 is sub-noise). So the claim must be framed as **"the data are consistent with inflation and inconsistent with Saponaro-style masking,"** not "inflation is uniquely proven." The discriminating evidence is the *contrast* (weak CN/MCI deflates, strong CN/AD within-site holds), not any single number.
2. The CN/AD control **also drops −0.041 under the same dx-non-preserving ComBat** (08, JSON-confirmed). So "harmonization removes only fake signal" is **partial isolation** (CN/MCI −0.083 vs CN/AD −0.041), not clean. The honest statement is "the deflation is *larger* for the weak/confounded task," and the within-site (within-ADNI) anchor is what defeats circularity — not the pooled trajectory.
3. The strongest confounded case (**AJU, appearance 0.822**) **cannot be a held-out CN/AD target (CN n=23)**, so the "site==population" claim is evidenced at the Korea↔West boundary by **KDRC alone** (n=1 disjoint held population). The "inflation not mask" mechanism is therefore demonstrated for **one weak task, one feature type (fs_vol ROI), one harmonizer family (ComBat), within-distribution** — and asserted (not proven) "in principle."

---

# (b) RELATED-WORK MAP — which prior result each experiment extends or contradicts

Format: Exp → prior anchor → relationship (EXTENDS = same finding, new regime/scale; CONTRADICTS/BOUNDS = shows the prior result does not transfer to our regime; with the key caveat from the verification audit).

| Exp | Topic | Prior anchor | Relationship | Load-bearing caveat (from verification) |
|---|---|---|---|---|
| **01** | 3-axis site identifiability (metadata 0.761 > appearance 0.556 > N4-resistant 0.517; biology control 0.151≈chance) | **Souza 2024** (site decodable from representation); **Souza 2023** (image site survives normalization) | **EXTENDS** Souza's "site is identifiable" to 7 consortia + decomposes *where* it lives (metadata ≫ pixels). Establishes the **premise only** | Biology control is a *single crude proxy* (brain_vox); it shows total-brain-volume is non-identifying, **not** that csf_mean/deepgm_mean intensities carry zero population biology. "Shortcut" (predictive sense) is imported from 04/08 — 01 shows **recoverability only** |
| **02** | ComBat fs_vol: site 0.238→0.175, within-ADNI AUC 0.885 unchanged, null controls pass | **Fortin 2017** (ComBat site↓ + biology↑, *overlap* sites); **Tassi 2024** (residual site after fit-train/apply-test) | **EXTENDS Fortin pattern** to our cohorts; **CONTRADICTS the "complete removal" reading** — residual 0.175 reframed as *legitimate population confound*, not failure | 02 is **full-fit** (in-sample), exactly the inflation Tassi warns of → the headline 0.238→0.175 is *partly mechanical/tautological*; the scientific verdict must rest on biology preservation. "AJU=AD-heavy" mechanism example is **wrong** (AJU is MCI-heavy/AD-scarce). Sex preservation **unmeasured**; MCI untested |
| **03** | N4/WhiteStripe/Nyul/blur: appearance 0.556→0.517 (best=N4, RF probe), reverses under LogReg | **Souza 2023** (intensity norm can't remove image site, raw 85%≈harm 85%) | **EXTENDS / strongly confirms** Souza 2023 — image post-processing barely dents site, probe-dependent | The LogReg-reversal numbers (0.490→0.517) are **stdout-only, unverifiable, and 0.517 is byte-identical to the RF value (likely copy error)**; the verify script prints the *opposite* directional conclusion. Must be tagged **[VERIFY/unverified]**, not stated as fact. N4 gain is only ~9% of the way to chance |
| **04** | LOCO CN/AD: held-cohort AUC 0.92, site-shift cost 0.001–0.004 | **Guan 2021** (deep DA beats weak baselines, *Western overlap*); minyoung4 stage8M (held-AUC 0.933) | **BOUNDS Guan**: shows the strong supervised morphometry baseline Guan's deep-DA gains do *not* apply to is already site-robust → no headroom for image harmonization | "site-shift cost" baseline is a **pooled multi-cohort random split, NOT within-cohort** (variable misnamed `random_within`); gaps lie *inside* one pooled SD. Cross-population claim rests on **KDRC alone** (n=1 disjoint). Feature-level result **cannot bound image-level headroom** (different representation axis) |
| **05** | ComBat-GAM vs linear ComBat: no gain (Δ 0.0024–0.0039, within noise) | **Pomponio 2020 ComBat-GAM** [VERIFY]; **Bayer 2022** (confound, not model form, is the problem) | **EXTENDS Bayer's mechanism**: rules out the *age-nonlinearity* artifact sub-case → residual floor is population-confound, not linear-model limitation | Rules out **exactly one** artifact class (age nonlinearity); does **not** exclude scanner/resolution/segmentation-bias floors. "Legitimate population confound" is imported from 02/06. Verify numbers are **stdout-only, sub-threshold** (0.0024 vs pooled_sd 0.0029) |
| **07** | MixStyle 3D CNN, LOCO: img Δ −0.03~−0.08 vs morphometry (all seeds), site-probe **+0.026** | **Guan 2021** (deep DA wins); **Souza 2024** (shortcut baked in); **Billot 2023 SynthSeg** (domain-randomization is less destructive) | **CONTRADICTS the "deep harmonization helps" expectation** in our regime; **EXTENDS Souza 2024** to a *trained* (not frozen) representation under style-mixing | Small from-scratch CNN, **train AD only 107–174** ("strong" is the overclaim it was meant to defend). Morphometry sees **26 ROIs incl. entorhinal**; CNN sees **5 ROIs without entorhinal** → input-coverage asymmetry inflates the gap. site-probe +0.026 can't distinguish "irreducible shortcut" from "MixStyle is the wrong tool." n=2 seeds, KDRC only |
| **08** | CN/MCI weak task: pooled deflates (0.673→0.568), within-ADNI flat (0.578→0.577); CN/AD control | **Saponaro 2022** (harmonization UNMASKS weak signal 0.58→0.67) | **DIRECT CONTRADICTION / the core novelty**: in site==population the same weak-task harmonization **deflates** (mask→inflation inversion) — Saponaro's mechanism does not transfer | **The entire LogReg column + AJU 980/23 + n_MCI/n_CN counts are stdout-only, zero saved provenance.** within-ADNI delta 0.002 is **sub-noise** (cannot distinguish "no mask" from "mask below detection at 8 splits"). CN/AD control **also drops −0.041** under combatB_nodx → isolation partial. "In principle impossible" overstates n=1-task/ComBat-only |

**Synthesis of the map:** Our experiments split cleanly into (i) **EXTENDS in new regime** — 01/02/03/05 re-derive Souza/Fortin/Bayer findings at 7-consortium scale (identifiability, conditional ComBat, image-site persistence, confound-not-model-form); and (ii) **CONTRADICTS/BOUNDS the positive results** — 04 (bounds Guan), 07 (contradicts deep-DA-helps), 08 (contradicts Saponaro unmask). The **novel inferential payload lives in 07+08**: the same intervention that *unmasks* in the separable regime (Saponaro) *deflates* in the collinear regime, and even strong domain-randomization *increases* the site shortcut. 01–05 are the supporting scaffold establishing premise + ruling out artifacts.

---

# (c) The single REJECT sentence and our rebuttal

## The sentence a reviewer would use

> *"This is Souza 2024's 'disease classifier is a secret site classifier' plus more cohorts and a re-confirmation of Saponaro 2022 / Bayer 2022 (ComBat fails under confounding) — the 'inflation not mask' framing is a relabeling of Bayer's already-known over-correction, and the central CN/MCI deflation rests on a within-site null delta of 0.002 (sub-noise, no saved variance) and an unsourced AJU 980/23 count, so no new mechanism is actually demonstrated — the headline contrast is an artifact of a dx-non-preserving ComBat mechanically removing label-correlated variance, which is expected, not novel."*

This is the strongest possible rejection because it is **partly correct** — the verification audit confirms the provenance gaps and the partial isolation, and Bayer 2022 *does* state over-correction abstractly.

## Our rebuttal (three moves, in priority order)

**1. The contribution is the regime-induced *metric invalidation* + *sign inversion*, not the over-correction itself.** Bayer 2022 states over-correction *can occur* under collinearity as a **caveat in a how-to review**; it does not show that this makes the field-standard "site-probe→chance" success criterion **undecidable**, nor that it produces a **specific opposite-signed accuracy trajectory** (down toward within-site truth) vs Saponaro's documented up-trajectory (0.58→0.67). We convert an abstract warning into a **measured, sign-characterized phenomenon with a prescribed adjudication protocol** (biology-preserving non-circular probe as sole admissible judge). That is the deliverable Souza/Saponaro/Bayer each lack: *a validity protocol for the regime where their metrics break.*

**2. The mechanism claim does not rest on the attacked numbers — it rests on the CONTRAST and the within-site anchor.** We concede (and the paper states) that AJU 980/23, the CN/MCI LogReg column, and the 0.002 within-ADNI delta are individually weak (sub-noise / stdout-only — we will *demote these to illustrative and re-run with saved variance + CIs before submission*). The load-bearing evidence is **differential**: under the identical dx-non-preserving ComBat, the **weak/confounded CN/MCI pooled drops −0.083 while the strong CN/AD within-ADNI signal holds** — and critically, **within-site (within-ADNI) diagnosis AUC is preserved**, which is exactly the non-circular guardrail (our 02 v2 design) that distinguishes "shortcut removed" from "biology destroyed." The reviewer's "expected mechanical removal" reframing is *the point*: we are not claiming a surprising algorithm, we are claiming that **in site==population the 'expected' removal lands on the label-inflating shortcut, so pooled accuracy correctly falls** — the opposite of Saponaro, where the same expected removal lifts a masked signal. The reviewer's objection concedes our mechanism while disputing its novelty.

**3. We explicitly disclaim scale and pre-empt "Souza + cohorts."** The paper states up front that 7-consortium scale is **not** the contribution and that identifiability (01) is a *re-derivation of Souza's premise*, not a result. What is new is the **demonstrated non-transfer of the two positive results** (Saponaro unmask, Guan deep-DA) into the collinear regime, with a sign flip, and the resulting **undecidability of the single-probe protocol**. If the reviewer still finds the audit "obvious," we invoke the fallback (06 §3.2.2): the **site==population 7-consortium benchmark with a non-circular adjudication protocol** is itself a contribution independent of the audit conclusion, since essentially all prior harmonization benchmarks are Western-overlap.

**Residual honest concession (do not hide):** the rebuttal is strong only if, before submission, we (a) persist the 08/03/05 verify-script numbers to disk with per-fold variance + CIs (currently stdout-only — the audit's most damaging finding), (b) reframe 08's conclusion from "unmasking impossible *in principle*" to "no unmasking *observed*; mask-vs-inflation adjudicated by the within-site non-circular probe," and (c) state plainly that the Korea↔West boundary is tested by KDRC alone and that AJU (the strongest confounded case) is unobservable for CN/AD (CN n=23). Without (a)–(c) the reviewer's sentence partially lands.

---

**Files referenced (all absolute):**
- `/home/vlm/minyoungi/roi_qc/experiments/harmonization/06_feasibility_and_protocol.md` — verified citations + numbers (Part 1 prior work, Part 3.2.1 Souza differentiation, §5 references)
- `/home/vlm/minyoungi/roi_qc/experiments/harmonization/README.md` — experiment index + one-line results
- Per-experiment evidence: `…/0{1,2,3,4,5,8}_*/RESULTS.md` and `…/07_deep_mixstyle/RESULTS.md`, with `out/*.json` as the only verifiable ground truth (the verification JSON flags that 03/05/08 LogReg numbers and 08's AJU 980/23 count have **no saved artifact** — fix before submission).

---

## PART III. Reviewer-2 공격면 (적대적 평가)

I have the central thesis, the protocol claims, and the full verification audit. I do not need to read the individual experiment dirs — the verification JSON already gives me the provenance gaps and overclaims per experiment, which is exactly the ammunition Reviewer 2 needs. Let me write the attack list directly.

Here is my Reviewer 2 report.

---

# TOP 6 REVIEWER-2 ATTACKS (ranked by danger)

The paper's defensibility rests on one load-bearing inference: that harmonization's failure to lift pooled accuracy is **shortcut-removal/inflation-correction**, not **biology-destruction or method-underpowering**. Every fatal attack targets the fact that the data are *consistent with* the thesis but do not *uniquely identify* it over the benign-failure alternative. The audit JSON confirms this is the recurring structural weakness, not a transcription nitpick.

---

## ATTACK 1 — The central mechanism (inflation, not mask) is asserted by analogy, never identified by a within-study contrast. **FATAL.**

**The attack.** The novel claim — site is a SHORTCUT that *inflates* the confounded label, so harmonization correctly *deflates* toward true signal (vs Saponaro's *masking* case it unmasks) — is the entire contribution. But no single experiment contains the comparator regime that would let it adjudicate inflation vs masking. Exp 02/08 show ComBat-B (dx-non-preserved) drops pooled CN/AD by −0.041 and pooled CN/MCI by −0.083 while within-ADNI stays flat. That is **exactly what mechanically removing dx-correlated cross-site variance does whether the variance was a "shortcut" or genuine cross-site AD biology** — combatB removes the label from the harmonization model, so the pooled drop is the *expected* consequence of not protecting dx, full stop. The within-ADNI control proves only that *within-ADNI* signal is site-independent; it is silent on whether the *cross-site* pooled lift was shortcut or real biology that ComBat-B destroyed. Calling the drop "fake signal removed = correct behavior" (02 RESULTS item 2; 08 conclusion) is the thesis imported as if it were a result. The audit flags this independently for 02 ("cannot distinguish shortcut from real cross-site AD signal destroyed because dx was unprotected"), for 08 ("data consistent with inflation but do not uniquely establish it over dx-correlated-variance-removed"), and for 04 (mask-vs-inflation "asserted, not tested").

**Why fatal.** This is not a peripheral overclaim — it is the *one sentence that differentiates the paper from Souza 2024*. If a reviewer establishes the result is equally consistent with benign biology-destruction, the paper collapses from "novel mechanism" to "we reconfirmed ComBat over-corrects under confound (Bayer 2022)," which is not novel.

**Rebuttal / experiment to close.** The honest rebuttal is weak: "within-ADNI flatness + null controls bound circularity." That does not adjudicate the mechanism. The **experiment that closes it** is a *positive control for unmasking within your own pipeline*: construct a synthetic regime where signal is genuinely masked by site (e.g., inject a site-balanced AD effect into a CN/CN split, or down-sample to force overlap between two Western cohorts so ComBat *can* unmask), and show your dual-probe protocol *recovers* the lift there while it *deflates* in the confounded AJU/KDRC arm. Without that contrast — inflation case AND masking case run through the *same* probe — "inflation not mask" is an interpretation, not a finding. This is the single most important addition; I would reject without it.

---

## ATTACK 2 — The strong-task negative ("morphometry is site-robust, harmonization has no headroom") rests on n=1 held population, and the most adversarial cohort can never be the test. **SERIOUS, bordering fatal.**

**The attack.** The whole "site-shift cost ~0" pillar (Exp 04) is built on three held cohorts, but **only KDRC is population-disjoint (Korean)**; ADNI and AIBL are both Western. The paper's *own* confound — site==population — is maximal precisely at the Korean boundary, and that boundary is tested with a single LOCO point (KDRC 0.919/0.922). One data point cannot establish cross-population transfer in general. Worse, the audit shows the "site-shift cost" baseline is a **pooled multi-cohort random split** (loco_generalization.py line 81 runs StratifiedShuffleSplit on the full pooled X), not a within-cohort split — so "cost = pooled-random − LOCO" is dominated by the easy CN-heavy Western cohorts in *both* terms, and the ~0 gap is partly "the task is easy on average," not "site shift is free." And the gaps (0.001–0.004) sit *inside* one pooled-random SD (~0.013–0.015), with no per-cohort CIs in the JSON — so "cost = 0.001" has unsupported precision. The killer: **AJU, the most site-specific cohort (appearance 0.822), has CN n=23 and can never be a held CN/AD target** (06 §3.3.1 concedes this). The strongest possible counterexample to "morphometry transfers across the disjoint boundary" is structurally untestable in your data.

**Why serious.** A reviewer will say: "Your strong-task robustness is a Western-to-Western result with one Korean anchor and a mislabeled baseline. You cannot claim morphometry is population-robust when the one population that defines your confound contributes 23 CN subjects and zero held-out evaluation." This guts the "no headroom for harmonization" claim that justifies the negative result on the strong task.

**Rebuttal / experiment to close.** Recompute the *correct* decomposition — per-held *within-cohort* random-split bound vs LOCO, with bootstrap CIs — so "site-shift cost" is honestly defined and you can report whether the KDRC gap exceeds its own CI. You cannot manufacture AJU AD, but you *can* run KDRC as held-target with within-KDRC random-split as the true ceiling, report the CI explicitly, and **reframe the claim as bounded**: "morphometry transfers Western→Western at zero cost and Western→Korean (KDRC) within CI; the AJU boundary is untestable and we do not claim it." Stating the AJU gap as a named open limitation (which 06 already does) is the minimum; pretending the Korean boundary is settled is fatal.

---

## ATTACK 3 — "Strong image harmonization can't beat morphometry / can't reduce site" (Exp 07) is a tiny, data-starved, from-scratch CNN with an unfair feature-support asymmetry. **SERIOUS.**

**The attack.** Exp 07 is positioned (06 §3.3.1) as closing the "you didn't try a strong image method" rejection vector. It does not. The actual model is a **from-scratch 3D CNN, feat_dim 128, ~85s training, train AD only 107–174** (the audit corrects the "107–205" mislabel — 205 is train+val pool, true max train_AD=174; there is no held-ADNI run at all). Three independent problems: (a) **"Strong" is indefensible** for a data-limited tiny CNN — the limitations concede a foundation backbone is a separate study, so the experiment fails to defend against the exact attack it was built for. (b) **The comparison is not fair** (despite 07 RESULTS line 7 claiming it is): morphometry gets 26 fs_vol regions *including entorhinal/fusiform/middletemporal/precuneus* — the most AD-discriminative cortex — while the CNN receives only 5 ROIs (parahippocampal/hippocampus/amygdala/lateral-ventricle/thalamus) and **never sees entorhinal**. "Image never beats morphometry" is partly an input-coverage artifact, not a representation-quality result. (c) The "site shortcut baked in / MixStyle can't remove it" claim is over-read: MixStyle mixes per-channel instance statistics; an equally consistent reading is **MixStyle is simply orthogonal to the spatial/anatomical axis where site lives — wrong tool, not irreducible shortcut.** The site-probe seed swing (0.637 vs 0.603, 0.034) is *larger* than the headline MixStyle effect (+0.026), on n=2 seeds in one cohort.

**Why serious.** "GAN/IGUANe/foundation model would be different" is the predictable rebuttal *to your own paper*, and 06 §3.3.1 already concedes it. A reviewer will add the feature-asymmetry point, which you have *not* disclosed, and conclude the image-vs-morphometry gap is partly rigged by giving morphometry the entorhinal cortex.

**Rebuttal / experiment to close.** Two cheap fixes materially help: (1) **Match the feature support** — give the morphometry baseline only the same 5 ROIs the CNN sees, OR feed the CNN a whole-brain crop. If morphometry-on-5-ROIs *still* beats the CNN, the asymmetry attack dies. (2) Reframe the absolute site-probe claim around the *paired same-seed delta* (+0.026/+0.027, which is stable) and drop the absolute-magnitude language (seed-fragile). The foundation-model gap cannot be closed cheaply; the defensible move is to scope the claim to "small-CNN style-mixing" and lean on the *relative* conclusion (morphometry ≥ image across N4+ComBat+GAM+MixStyle, four axes), explicitly *not* claiming a foundation model would also fail.

---

## ATTACK 4 — MCI label noise and analyst CN-pool construction confound the weak-task result (Exp 08). **SERIOUS.**

**The attack.** The weak-task pillar (CN/MCI, "harmonization can't rescue what was never masked") has two construction problems the audit surfaces. (a) **MCI is not a consistent label across consortia** — 08 limitation #2 concedes ADNI MCI vs NACC "ImpairedNotMCI" are heterogeneous definitions. The "no site-mask to remove" claim is generalized from *within-ADNI flatness* (one site, one MCI definition) to a regime-wide "no mask exists in principle" (06 / 08 role_in_thesis). Within-ADNI defeats circularity but cannot license a universal. (b) **The CN pool was altered by an analyst decision**: A4 CN_preclinical (n=1811) was mapped into CN, contributing zero MCI and inflating the pooled CN arm, yet A4 is not a LOCO target. The pooled raw 0.674 and its post-ComBat drop are partly a function of *this mapping choice*, so treating the pooled trajectory as a clean readout of "shortcut removal" ignores that the CN site-mix was set by the analyst. (c) The "within-ADNI flat" verdict (RF 0.620→0.618, Δ0.002) is declared with **no RF variance** — the JSON has point estimates only; the cited std (0.027) is from the unsaved LogReg run. 08 limitation #5 itself concedes "this is statistical no-change within measurement-precision limits," yet the conclusion asserts a hard null ("no mask to remove"). The experiment **cannot distinguish "no mask" from "mask below detection at n_splits=8."**

**Why serious.** "You cannot prove a null with a sub-noise delta on a noisy heterogeneous label" is textbook Reviewer 2, and your own limitations section already concedes it — so the conclusion section overclaims relative to your own caveats. The asymmetry of "absence of evidence ≠ evidence of absence" is fatal to a paper whose thesis *is* a null ("harmonization rescues neither task").

**Rebuttal / experiment to close.** (1) Report **RF variance/CIs** on the within-ADNI deltas and reframe as a bounded null: "no recoverable mask above an effect size of X at our power." (2) Run the weak-task unmask test on a **single-consortium MCI definition held constant** (ADNI-only MCI vs an ADNI-only held split), removing the cross-consortium label-noise confound, and separately show NACC/OASIS to bound generalization rather than asserting it. (3) Sensitivity analysis: re-run pooled CN/MCI with A4 *excluded* from CN, to show the shortcut-removal trajectory is not an artifact of the A4 mapping. The honest framing is "we observe no *detectable* unmask," never "there is no mask in principle."

---

## ATTACK 5 — ComBat full-dataset fit inflates the headline site reduction; the lead number is partly a tautology. **SERIOUS (and self-inflicted, because your own literature flags it).**

**The attack.** Exps 02 and 05 lead with site-probe reduction (02: site7 0.238→0.175). But ComBat is **fit on the full dataset**, and you yourself cite Tassi 2024 (06 §1.2) showing in-sample ComBat *over-estimates* site removal — external validation reveals only 26–56% reduction vs 65–91% in-sample, with residual site significant in 3/4 feature sets after fit-train/apply-test. By the protocol *you wrote* (06 §2.1 step [1]: "harmonization fit on TRAIN only → apply to held-out"; §2.3: "in-sample 지표 금지"), your own 02/05 ComBat numbers **violate your own mandatory protocol** — they are full-fit, so the headline 0.238→0.175 is "partly mechanical / a tautology" (ComBat subtracts batch means; the audit and 02's own meta.note say exactly this). The scientific verdict is supposed to rest on biology preservation, but the headline still leads with the mechanically-inflated site drop. Compounding: scanner-level probe (scan4) stays 0.243 vs chance 0.2 *after* ComBat — still +0.043 over chance — and is dropped from the headline table; only the consortium-7 probe that approaches chance is shown.

**Why serious.** You will be hoist by your own citation. A reviewer who reads §1.2 and §2.3 then sees full-fit ComBat in 02/05 will say: "Your own protocol forbids this, your own cited paper says it inflates site removal, and you led with the inflated number." That is a credibility wound across the whole paper, not just one experiment.

**Rebuttal / experiment to close.** Mandatory: **re-run 02/05 ComBat as fit-train/apply-held-out** (the protocol you already specified) and report the external-validation site reduction, which will be smaller and more honest. Report the scan4 residual in the headline. If the external-validation reduction is small (as Tassi predicts), that *strengthens* your "image/feature site is hard to remove" thesis — so this fix is pure upside. Leading with a full-fit number you've publicly labeled forbidden is indefensible.

---

## ATTACK 6 — Single modality / single segmentation pipeline: the entire "morphometry is robust" pillar could be FastSurfer site-bias, not biology. **MINOR–SERIOUS.**

**The attack.** Every feature-level result (02/04/05/08) uses **fs_vol from one segmentation pipeline (FastSurfer/VINN), T1 only, no eTIV (MaskVol proxy per your MEMORY)**. Two exposures: (a) The 0.16–0.18 residual site floor that survives ComBat-GAM (05) is attributed to "legitimate population-confound residue, not a model artifact" — but 05 rules out only the *age-nonlinearity* artifact class. It does **not** exclude that residual site is **FastSurfer segmentation bias** (scanner/resolution-driven volumetry differences — sub-mm GE vs 1mm Siemens segment differently). The audit flags this for 05 directly. (b) "Morphometry is site-robust" (04) and "image can't beat morphometry" (07) are both **single-pipeline, single-modality**; if FastSurfer itself encodes a site shortcut into the ROI volumes (plausible — segmentation is resolution-sensitive), then "morphometry baseline" is not a clean biological reference and the whole strong-baseline argument inherits hidden site signal. Single-modality also means the negative result is T1-specific; a reviewer interested in whether harmonization helps *multimodal* (T1+FLAIR, or T1+tau-PET in your A4/ADNI cohorts) gets nothing.

**Why minor-to-serious.** This is lower-ranked because it attacks the *reference*, not the headline contrast, and because no reviewer expects you to re-run a second segmentation pipeline on 13k scans. But it is a legitimate "you didn't isolate segmentation site-bias from population site-bias" point, and it directly undermines 05's "legitimate residue" interpretation.

**Rebuttal / experiment to close.** Cheap partial close: regress the residual-site-carrying ROI volumes against **voxel resolution / vendor** (you have vox_x/y/z and acq_scanner) and show the residual site floor does *not* collapse when resolution is partialled out — distinguishing population-residue from resolution-driven segmentation bias. Full close (a second pipeline, e.g. FreeSurfer cross-check on a subsample, or SynthSeg which is resolution-agnostic by design) is a real experiment but probably out of scope. Minimum: **stop calling the 0.16–0.18 floor "legitimate population residue"** — downgrade to "residual site of undetermined origin (population vs segmentation), not removed by nonlinear-age ComBat."

---

## Cross-cutting meta-attack (applies to all six, flag explicitly in rebuttal planning)

**Provenance.** The audit shows that *the load-bearing "independent verification" numbers are stdout-only and not persisted* across 02/03/04/05/08: LogReg probes, AJU 980/23 (the *sole* quantitative basis for the inflation mechanism), site7 0.355→0.163, the 05 non-inferiority margin (0.0024 < 0.0029), the 08 LogReg half-table — none are in any saved `out/*.json`. For an **audit/protocol paper whose entire value proposition is rigor and reproducibility**, having the key corroborating numbers be ephemeral and (in Exp 03's case) produced by a verification script whose hardcoded printed conclusion *contradicts* the reported numbers, is a reviewer gift. Before submission, every number cited in a RESULTS.md must be dumped to a versioned JSON, and the Exp 03 LR/RF 0.517 collision (likely a copy-error: RF n4prod value pasted into the LR row) must be resolved — a reproducibility paper that cannot reproduce its own verification numbers invites desk-level skepticism on everything else.

---

**Bottom line for the authors.** Attacks 1 and 2 are existential and must be addressed with *new contrasts* (a positive/unmasking control in your own pipeline; an honest within-cohort LOCO baseline with CIs). Attacks 3–5 are closable with cheap re-runs you should do regardless (matched feature support, train-only ComBat fit, RF CIs, A4 sensitivity). Attack 6 is a framing downgrade, not an experiment. The paper as scoped is *consistent* with its thesis but does not yet *identify* it over the benign-failure alternative — and that gap, not any single number, is what Reviewer 2 will reject on.

Relevant files: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/06_feasibility_and_protocol.md`, `/home/vlm/minyoungi/roi_qc/experiments/harmonization/README.md`.