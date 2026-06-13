# 20260613 scanner/population decomposition — VERIFIED NEGATIVE (no ⭐)

## 결론: 제안된 ②③ 방향은 disease-imbalance artifact로 기각됨.
- **E1** (`E1_combat_deflation.md`): align(PRE)→ComBat deflation(POST) Spearman rho=+0.90, cross-ancestry deflation↑. *겉보기 강함.*
- **code-auditor**: leakage(전역 z-score, 경미) + **disease-cohort imbalance confound**(AJU AD-heavy → cohort≈disease → 순환) 지적.
- **E2** (`E2_disease_matched.md`, 결정적): cohort별 CN/AD 균형 subsample(cohort⊥disease) + train-only z + seed-sync + AJU제외 rho + permutation null.
  → **rho +0.90 → −0.20 (AJU제외 −0.14, p=0.79). cross-ancestry deflation +0.05→−0.001 = same-pop와 동일. 전 alignment≈0.**
- **판정**: E1은 **disease-prevalence imbalance artifact**. ② 법칙·③ predictive validity 모두 FALSE in our data.

## genuine new fact (검증됨, 기여 후보지만 modest)
7코호트에서 겉보기 cohort-disease 얽힘 + ComBat disease-deflation은 *전부 disease-prevalence 불균형* 탓이지 scanner/ancestry 탓이 아님.
disease-matched면 ComBat은 美-韓 cross-ancestry에서도 신호-중립. = "site=population deflation" 통념의 반례.
단, "confound 통제하라"는 일반 원칙의 특수 사례라 novelty는 제한적(More 2023 confound-leakage 인접).

## leakage/overclaim 점검
- E2는 train-only z, subject-split, ComBat fit-train/apply-test, seed-sync, permutation null 적용 = leakage-safe.
- E1의 rho=0.90을 결과로 *주장하지 않음* (artifact로 기각). 과대포장 회피.

---
## E3 (proceed from E2 gap): prior-shift vs covariate-shift — `E3_labelshift_vs_combat.md`
LOCO CN/AD, leakage-safe. label-shift(Saerens EM) vs ComBat.
- ❌ label-shift가 ComBat을 깨끗이 못 이김 (ΔBA −0.024; KDRC +0.15 회복하나 AJU 극단prior서 over-correct).
- ✅ clean facts: (1) AUC cross-cohort 보존 0.861 = site는 discrimination에 benign; (2) Saerens EM이 target 유병률 |오차0.023| 정확 추정; (3) ComBat은 미관측 LOCO site엔 적용 불가(nan).

## 일관된 종합 (E1→E2→E3) — modest cautionary 발견 (⭐ 아님)
> 다코호트 뇌MRI disease 분류에서: (a) 겉보기 site-disease 얽힘·harmonization 손실은 **disease-prevalence 불균형 artifact**(E2); (b) site는 **discrimination(AUC)엔 benign**, cross-cohort 진짜 shift는 **prior-shift**(E3); (c) 단 prior 보정은 regime-의존이라 단순 해결책 아님.
**= "site-shift가 아니라 prior-shift" 재프레이밍.** 단 prior/covariate-shift 구분은 known ML(BBSE/Saerens)이라 novelty 제한적 → 강한 논문 아님, cautionary methods note 수준.

## leakage/overclaim 점검 (전 실험)
train-only z, subject-split, ComBat fit-src/apply-tgt, label-shift는 target label 미사용(transductive), seed-sync(E2), permutation null(E2). E1 rho=0.90은 artifact로 *주장 안 함*. 과대포장 없음.

---
## E4 (decisive): covariate-shift vs prior-shift 분해 — `E4_shift_decomposition.md`
LOCO, pre-registered tests, bootstrap CI.
- ✅ **T1**: AUC gap(oracle−LOCO) 평균 +0.024 (작음) = **site는 discrimination/ranking에 benign**. 견고.
- ❌ **T3**: BA gap ↔ prior-shift corr −0.18 = **prior-shift 재프레이밍 미지지** (NACC/AIBL은 prior-shift≈0인데 BA gap 큼). E3의 가설 refute.
- ⚠️ n_folds=5 (코호트 수), 상관 CI 넓음 — 방향성 증거로만.

## ★없음 — 최종 검증된 종합 (modest cautionary, 강한 novelty 아님)
세션 ~10회 엄밀 실험의 robust 생존 사실:
1. site는 cross-cohort AUC에 benign (gap~0.02).
2. 겉보기 site-disease 얽힘 = disease-prevalence 불균형 artifact (disease-matched면 ComBat 신호-중립, cross-ancestry 포함).
3. de-confounding/harmonization은 disease discrimination을 돕지 않고, disease가 site와 confound될 때만 deflate.
→ "site는 ranking에 benign; de-confounding이 겨냥하는 얽힘은 sampling 불균형" = cautionary 재프레이밍.
**정직한 한계**: (a) "site decodable-but-benign"은 부분 known (domain-gen 문헌), (b) disease-imbalance 통제는 일반 confound 원칙의 특수사례, (c) prior-shift 각도는 자체 데이터로 refute. → 강한 단독 논문 아님. cautionary methods note 또는 기존 audit과 묶음 수준.
