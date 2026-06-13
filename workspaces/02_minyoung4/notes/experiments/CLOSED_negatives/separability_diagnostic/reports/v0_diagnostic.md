# E/v0 — site-population separability diagnostic (7 cohorts, morphometry)

- **S_raw** (cohort 7-way macro-AUC) = **0.774**  (chance 0.5)
- **S_resid** (cohort-AUC after age+sex+dx 제거) = **0.759**  (높을수록 biology 너머 cohort 신호 큼)
- **Deflation D**: dementia AUC 0.889 → 0.757 after cohort-INLP = **+0.131**  (cohort-AUC 0.774→0.519 확인)

## 해석
- S_resid 0.759: 측정 biology를 다 빼도 cohort가 강하게 남음 = site/unmeasured-population 신호 큼.
- Deflation +0.131: cohort를 제거하면 dementia 신호가 함께 손실(얽힘=비가역).
- → 우리 7코호트는 **irreducible 영역 (S_resid 높음 + deflation 큼)**: harmonization이 unmask가 아니라 deflate할 것이라 *진단도구가 예측*.

## 남은 단계 (calibration, 외부데이터)
- ON-Harmony/SRPBS traveling-subject에서 *site 분리 가능*(population 고정)일 때 S_resid 높지만 deflation 낮음을 보여 진단도구가 두 체제를 *구분*함을 검증.