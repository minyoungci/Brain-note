# FINDINGS — microbrain (consolidated, 2026-06-11)

> 이 라인의 전체 발견을 한 곳에. 임무: T1w MRI에서 표현학습 부진이 **(a) site/scanner bias 오염**인지
> **(b) 부피(morphometry) 너머 미세신호의 천장**인지 분리·판정. 모든 수치는 직접 측정·재현 가능
> (notebooks/01~06, experiments/P2, results/). 근거 문서는 각 행에 표기.

---

## 0. 한 줄 결론 (research-critic 검증 후 정정 2026-06-11)

**(a)/(b)는 아직 미결이다.** P2-③의 "image≈morph match"는 ① 인코더가 held-out 코호트를 학습 시 본
**표현-수준 LOCO 누수**(F1), ② emb가 morph-distilled라 ≈morph가 **동어반복**(F2), ③ amyloid는 morph도
0.66뿐인 **약한 target**(F2)이라 (b) 증거로 못 쓴다. 1.5mm "cortical 복원"도 **과대 진술**이었다
(mean R²=0.23, precuneus/PCC 음수, 자동판정 (c)). → **깨끗한 판정엔 (1) 진짜 nested-LOCO + (2) morph가
강한 target(AD/CN, morph 0.936)에서의 검정이 필수.** 상세는 §0.1.

## 0.1 research-critic 적대 검증 — 결론 정정 (필독)

독립 research-critic이 (b) 결론을 무너뜨림. **현재 (b) 주장은 철회.** 핵심:
- **[F1] LOCO 누수:** `diag_morph_regress.py`가 random 80/20(LOCO 아님)로 4코호트 전부 학습 → frozen 인코더가 held-out 코호트 이미지를 이미 봄. ③의 "match"는 representation-level 누수 가능.
- **[F2] (b) 미검증:** morph-distilled emb의 ≈morph는 순환논증. amyloid는 morph도 약함(0.66) → "둘 다 약함"이 천장과 구별 안 됨. TOST/CI 없음(Δ0.001=noise).
- **[F3] 과대 진술:** 1.5mm mean R²=0.23(verdict=(c)), precuneus −0.87·PCC −0.70 등 음수. "복원/약한백본 반론 닫힘"은 거짓.
- **[M2] 2mm 0.63<morph는 핸디캡 실험** → (b) 증거 아님(해상도 병목 자인).
- **[M3] amyloid label 이질성**(visual/SUVR/tracer 혼합) LOCO 미통제.
- **[M4] morph baseline에 APOE/age 미포함** → 0.78 임상 바 대비 image·morph 둘 다 미달.
- **판정 부적합 target:** amyloid는 morph가 약해 (b) 판정에 부적합. **(b)는 morph가 강하고(AD/CN 0.936) 모델이 그 morph를 재현 가능한(R² 높은) target에서 image가 못 넘을 때만 증명된다.**

---

## 1. 핵심 증거 사슬 (측정값)

| # | 실험 | 결과 | 함의 | 근거 |
|---|---|---|---|---|
| P0-A0 | site×diagnosis confound | Cramér's V(site,impaired)=**0.42**, (site,dx)=0.53 | site≈diagnosis proxy | `results/P0/P0_AUDIT_REPORT.md` |
| P0-A1 | morphometry→site | bAcc **0.27** (chance 0.14) | 부피도 site 일부 인코드 | 〃 |
| P0-A2 | voxel→site (base vs N4) | **0.475**(3.3×), N4 **−0.006** | bias 이미지에 강함, N4 무효 | 〃 |
| P0-A4 | decidability(site 잔차화) | disease 0.774→**0.722**(−0.05) | morph 수준선 disease는 site와 분리 가능 | 〃 |
| P0-A5 | morph→CDR LOCO 바 | impaired 0.766 · **AD/CN 0.936** · amyloid 0.66~0.72 · MCI 0.61 | AD/CN은 천장, MCI/amyloid는 morph 약함 | 〃 |
| scout | harmonization | IGUANe(MedIA25) 유일 적합, **morph 초과 증거 없음** | harmonization=해법 아님 | `investigations/harmonization_scout_review.md` |
| DR | deep-research(104 agents) | D1~D4(fusion/tabular/distill/VLM) crowded+**cross-site 전무**, D5(혈액) whitespace | 멀티모달 방법론 포화 | `investigations/novelty_deep_research.md` |
| 혈액 | biomarker injection | texture +0.00 · **APOE +0.023** · MCI/amyloid/dementia 전부 +0.00 | 혈액≠레버, APOE(유전)만 | `investigations/novelty_deep_research.md` |
| 종단 | longitudinal 가능성 | 궤적 ADNI만(849), Korean cross-sectional(CDR변화 35) | rich↔longitudinal disjoint | `ledgers/2026-06-11_longitudinal_richdata_negative.md` |
| **P2-S1** | **2mm supervised(from-scratch) amyloid LOCO** | **0.63 < morph 0.72**, **site-probe 0.81** | 핸디캡(2mm+site+from-scratch) | `results/P2/stage1_loco_results.csv` |
| P2-diag | image→fs_vol 회귀 R² (2mm) | subcortical **0.67**, cortical **−0.5** | 2mm가 cortical 죽임(해상도) | `results/P2/diag_morph_regress.json` |
| P2-diag | image→fs_vol 회귀 R² (1.5mm) | **mean R²=0.23(verdict=(c))**; 일부 cortical 개선(entorhinal 0.61) but precuneus −0.87·PCC −0.70·fusiform_R −0.21 음수 잔존 | [정정] "복원" 아님 — 모델이 morph 재현 못함 → (b)/(c) **미결** | `results/P2/diag_morph_regress_1p5mm.json` |
| **P2-③** | 1.5mm morph-pretrained frozen probe, amyloid LOCO | image-emb 0.662, morph 0.663, +emb 0.665, site-probe 0.722 | **[무효] F1 누수+F2 순환+약한 target → (b) 증거 아님** | `results/P2/stage1b_frozen_probe.json` |

---

## 2. 판정 — (a)/(b) [research-critic 후 정정: **미결**]

- **(a) bias 오염: 실재 확정.** voxel→site 3.3×, 표현 site-probe 0.72~0.81. P0-A4(잔차 disease 0.722 생존)는 robust. 이 부분은 유효.
- **(b) 신호 천장: 미검증 (이전 "지지" 주장 철회).** ③의 fair-test 논거는 F1(누수)·F2(순환/약한 target)·F3(1.5mm 미복원)으로 무너짐. **현재 깨끗한 (b) 검정은 한 번도 안 돌렸다.**
- **(b)를 증명하는 유일한 형태:** morph가 *강한* target(AD/CN, morph LOCO 0.936) + 모델이 그 morph를 *재현 가능*(R² 높음) + 진짜 nested-LOCO에서 image가 morph를 **유의 미초과**(TOST). 이 셋을 동시에 만족할 때만 "천장". amyloid는 morph가 약해(0.66) 이 형태가 불가능.

> 정직: minyoung2/4/i의 "deep≈morphometry"를 *재확인하려 했으나*, 현재 P2 증거는 누수·순환·과대진술로 그 주장을 받치지 못한다. 미결.

---

## 3. 부차 발견 (그 자체로 기여 가능)

1. **bias atlas / decidability framework** — confounded regime에서 (a)/(b) 판정 방법론(residualization + dual-gate). 문헌에 cross-site 평가가 전무(DR 확인).
2. **해상도 진단** — 이미지가 morph를 재현하는지를 fs_vol 회귀 R²로 측정 → "모델 실패 vs 신호 천장"을 가르는 도구. 2mm가 cortical 신호를 죽인다는 정량 증거.
3. **표현의 site 오염 지속** — morph(해부)를 배우게 학습해도 표현이 site를 0.72로 인코드. site-invariant image 표현의 본질적 난이도.
4. **혈액 바이오마커 음성** — 공개셋이 못 가진 혈액 패널도 morph 너머 dementia/amyloid 기여 0 (단 APOE는 +0.023).

---

## 4. 미완 / 열린 질문 (정직)

| 열린 것 | 왜 중요 | 비용 |
|---|---|---|
| **"beyond" airtight 종결** | ③의 emb는 morph-distilled(≈morph 당연). 순수 fine-tune/SSL은 미시도 | 수시간(GPU), prior 낮음 |
| **target 일반화** | 1.5mm fair test는 **amyloid만**. AD/CN(0.93 천장)·**MCI(0.61, headroom)** 미검정 | 중간(캐시·probe 재사용) |
| **G1 개입 미시도** | site 오염(0.72)을 *제거*하는 invariance(Arm B)를 안 돌림 → dual-gate G1 미검정 | 중간 |
| **통계 엄밀성** | "match"(image≈morph) 주장엔 equivalence test(TOST)+bootstrap CI 필요(점추정만 있음) | 저(CPU) |
| **단일 backbone/해상도** | resnet18·1.5mm 단일. 강한 백본/SSL/foundation 미시도(minyoung2 W5) | 가변 |

---

## 5. Reviewer-2 예상 공격 (선제 점검)

- **"morph가 FastSurfer 산물인데 바로 두는 게 타당한가"** → morph는 정답 아닌 baseline-predictor, 독립 target(amyloid-PET) 기준. 단 morph도 site 0.27 인코드 → 명시 필요.
- **"amyloid는 T1w로 원래 어려운 target(구조-분자 decoupling). image=morph가 천장 증명인가?"** → 강한 반론. MCI/AD/CN으로 일반화 필요.
- **"image<morph는 모델이 약해서다"** → 우리는 match(0.662=0.663)를 입증해 이 반론을 닫음. 단 SSL/강백본 미시도는 잔여.
- **"underpowered to detect difference ≠ equivalence"** → TOST 필요(minyoung2 B2/B3 교훈).

---

## 6. 어떤 논문이 되나 (정직)

- ❌ **성능 SOTA 논문**: 불가(image ≯ morph, fair test 후에도).
- △ **cautionary/benchmark + 방법론 논문**: 가능권(중위 venue: NeuroImage:Clinical/HBM/benchmark track). 헤드라인 = "다기관 fair-resolution에서 학습 표현은 morphometry를 따라잡되 넘지 못하고 site를 외운다 + (a)/(b) decidability framework + bias atlas". top-tier(MedIA/TMI)는 novelty 부족 위험.
- 강화 조건: §4의 target 일반화(MCI) + 통계 엄밀성(TOST) + G1 개입 1회 시도.
