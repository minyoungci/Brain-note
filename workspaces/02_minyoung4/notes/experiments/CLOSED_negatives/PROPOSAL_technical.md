# Proposal — Technical, novelty-verified research (2026-06-13)
*Synthesis of: deep-research lit verdict (②③ survive) + experimental retrospective (I-1..I-5).*

## The one genuinely-open, technical gap (lit-verified)
deep-research confirmed the only un-occupied contribution = **②+③ combined**, and pinned the
*technical crux* that decides it: **can cohort distance be decomposed into a SCANNER component and
a POPULATION component WITHOUT per-dataset traveling subjects?** (Yamashita 2019 needs traveling
subjects; Parekh 2022 uses *undecomposed* site-distance.) Whoever does that decomposition
cross-sectionally owns the gap. **That decomposition is the technical method.**

## Proposed method (technical contribution)
**"Transferable scanner-distance model for cross-sectional decomposition of cohort shift, predicting
harmonization deflation."**

1. **Learn the scanner-shift manifold from PUBLIC traveling subjects** (ON-Harmony 20×6 scanners,
   SRPBS 9×12 sites): same subject across scanners ⇒ feature deltas are *pure scanner* (population
   fixed). Fit a model of how features move under scanner change (vendor/field/protocol covariates).
2. **Apply to our 7 cohorts**: predict the *scanner component* of each cohort-pair feature distance
   from acquisition metadata via the learned manifold; the **residual = population-distance**
   (the part scanner cannot explain). This is the cross-sectional decomposition that needs no
   per-dataset traveling subjects — it *transfers* the scanner model.
3. **Law ②**: show deflation/entanglement (our excess-alignment, E-result) scales with the
   *population-residual* distance, NOT the scanner component — and is largest for cross-ancestry
   pairs (US↔Korea), smallest same-population (ADNI↔NACC). (Our E3 already shows the raw spectrum;
   the decomposition makes it *population*-specific, the differentiator from Parekh/Marzi.)
4. **Predictive validity ③**: the pre-harmonization population-residual predicts the *post*-ComBat
   disease-classification loss (run ComBat, measure CN/AD AUC drop, correlate). Pre→post forecast.
5. **(optional method) selective harmonization**: harmonize only the scanner component, protect the
   population-residual ⇒ less deflation than blanket ComBat. (high-risk extension.)

## Why this is novel AND technical AND structure-respecting
- **Novel (lit-verified)**: the decomposition (scanner vs population, cross-sectional) + ②+③ on
  disease labels is un-occupied (deep-research). Differentiator from Yamashita (no traveling subjects
  needed per-dataset), Parekh (population vs undecomposed distance), Marzi/Pomponio (multivariate
  cross-ancestry vs univariate age-overlap).
- **Technical**: a transfer-learning decomposition algorithm (scanner manifold → residual), not just
  an observation. Answers the exact gating question deep-research raised.
- **Respects structure (I-1..I-4)**: does NOT try to *remove* site (that always failed); it
  *decomposes and measures* it. Uses our cross-ancestry diversity (the asset) + public traveling
  data (the calibration). Target is the *harmonization-decision*, not a morphometry-ceiling'd label.
- **Builds on validated assets**: our excess-alignment E-result + calibration discipline (I-5).

## Honest risks (must gate before full commit)
- **R1 (transfer)**: scanner manifold learned on ON-Harmony scanners may not transfer to our cohorts'
  scanners → population-residual biased. *Gate*: validate the scanner model predicts held-out
  traveling-subject deltas; if poor, decomposition is unreliable.
- **R2 (residual lit)**: deep-research left ENIGMA working-group + Radua 2020 unverified, and found
  no cross-ancestry harm comparison (could exist). *Action*: targeted check before writing.
- **R3 (identifiability)**: population/scanner are not perfectly separable (the irreducibility we
  measured) — the decomposition is an *approximation*; frame as "calibrated estimate," not exact.
- **R4 (data access)**: ON-Harmony/SRPBS DUA/login. *Gate*: confirm access first.

## Concrete first steps (gated)
1. **G1 (lit, ~1 day)**: targeted check of ENIGMA harmonization papers + Radua 2020 + any
   cross-ancestry harmonization-harm paper (close the deep-research residual risk).
2. **G2 (data, ~days)**: secure ON-Harmony or SRPBS; verify traveling-subject T1w accessible.
3. **G3 (method pilot)**: fit scanner-shift model on traveling subjects; test held-out scanner-delta
   prediction (R1 gate). If it transfers → proceed; else reassess.
4. Then ②③ on our 7 cohorts (decomposition → population-residual → deflation prediction), + ComBat-link.

## Verdict
This is the *only* lit-verified, technically-substantive, structure-respecting direction surviving
the whole session. It converts the session's recurring wall (site=population irreducible) into the
*method itself* (decompose it cross-sectionally via transferable scanner models). Realistic venue:
NeuroImage / NeuroImage:Clinical / MELBA (method+analysis). Gate on G1–G3 before full commit.

---
## G1 — residual prior-art check (literature-scout, 2026-06-13): PASS (with positioning)

**핵심 method(전이+분해, "TS-학습 scanner모델→TS-없는 코호트 거리 분해")는 검색범위 내 미점령 = 통과.**
가장 가까운 위협 3개가 각각 다른 메커니즘:
- **Yamashita 2019** (PLoS Biol): 분해하나 *traveling-subject 필수* — 우리 "전이" 축이 정확히 이게 안 한 것.
- **MURD/Liu&Yap 2024** (Comm Eng, "without traveling phantoms"): *image-level harmonization/disentanglement* (거리 분해 아님, 정반대 방향).
- **ComBat-Predict** (HBM 2026): *가장 가까운 위협*. ComBat 파라미터를 새 site로 전이(pool 없이)하나 (i)scanner/population 분해 안 함, (ii)TS 안 씀, (iii)task-loss 예측 안 함 → **점령 아님, 단 강한 baseline. 본문에서 명시 차별화 필수.**

**3개 positioning 단서 (반드시 반영):**
1. **②(cross-ancestry 잔차)의 *관찰*은 점령됨** — Li et al. 2022 (Science Advances)가 cross-ethnicity 예측실패를 이미 정량화. → 우리 novelty는 "cross-ancestry에서 population 잔차가 크다"는 *관찰*이 아니라 **그 잔차를 *전이된 scanner모델로 분리해내는* 분해 메커니즘**이어야 함. 관찰을 novelty로 주장하면 깨짐.
2. **③(전→후 task손실 예측)이 가장 약한 축** — neuroimaging 특정 선행은 미발견이나 "domain-gap↔accuracy"는 일반 ML 상식. → disease-classification 손실에 대한 *정량 예측력(r/AUC)*을 실증으로 제시해야 "당연하다" 압박 방어.
3. **baseline 배치**: ComBat-Predict + Radua 2020(NeuroImage 218, train/test ComBat)을 *비교대상*으로 본문 선제 배치.

**검색 한계(정직)**: Science Advances/Nature paywall 우회, ENIGMA 하위논문·IPMI/MICCAI 2024–2026 최신·SRPBS 후속 전수확인 못 함. point-5 부재는 "주요 DB 내 미발견"이지 부재증명 아님. → **G2에서 IPMI/MICCAI 최신 + ComBat-Predict 게재판 풀텍스트 정밀 재확인 권고.**

## 정정된 contribution (G1 후)
1. **[기술 method, 헤드라인]** transferable scanner-effect model로 cohort distance를 cross-sectional 분해 (scanner vs population) — Yamashita의 TS-필수 분해를 *전이*로 해소.
2. **[법칙 ②]** *분해된 population 잔차*가 deflation을 예측 (관찰이 아니라 분해가 기여; Li 2022와 차별).
3. **[③]** 사전 잔차 → 사후 ComBat disease-AUC 손실의 *정량 예측력* (r/AUC 실증).
baseline: Yamashita 2019 · ComBat-Predict · Radua 2020. venue NeuroImage/MELBA.
