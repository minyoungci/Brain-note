# Phase 1 / GATE-1: 이중 covariate baseline LOCO

seed=42, n_boot=1000, LR(class_weight=balanced)

| holdout fold | N | 양성% | a-dem AUROC [95%CI] | a-clin AUROC [95%CI] | clin gap |
|---|--:|--:|---|---|--:|
| ADNI | 1257 | 39% | 0.780 [0.754,0.807] | 0.788 [0.761,0.811] | +0.008 |
| OASIS | 500 | 33% | 0.793 [0.753,0.833] | 0.804 [0.762,0.843] | +0.011 |
| AJU | 1000 | 34% | 0.700 [0.665,0.736] | 0.760 [0.727,0.789] | +0.060 |
| KDRC | 534 | 68% | 0.702 [0.656,0.746] | 0.747 [0.701,0.793] | +0.045 |

**a-dem**: mean=0.743, range=[0.700, 0.793] (fold간 spread=0.093)
**a-clin**: mean=0.775, range=[0.747, 0.804] (fold간 spread=0.057)

## 해석 노트
- **GATE-1 bar (primary 비교 대상) = a-dem fold별 위 표.** SSPD(c)는 fold별로 이걸 ≥3/4에서 CI 하한>0로 넘어야 H1.
- **F1 진단:** clin gap(=a-clin−a-dem)이 fold마다 다르면 clinical-stage 교란 실재. fold간 spread가 크면 pooled 금지 정당화.
- n_cohort=4 → subject-level bootstrap CI는 cohort-level 불확실성 과소추정(M1). 방향+일관성으로만 해석.