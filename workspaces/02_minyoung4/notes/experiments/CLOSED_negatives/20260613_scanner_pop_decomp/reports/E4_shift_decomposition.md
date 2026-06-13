# E4 — covariate-shift vs prior-shift decomposition (LOCO, pre-registered tests)

| held-out | n | P(AD) src→tgt | prior-shift | oracle AUC | LOCO AUC | AUC gap | oracle BA | LOCO BA | BA gap |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| ADNI | 2666 | 0.13→0.08 | 0.05 | 0.887 | 0.859 | +0.028 | 0.692 | 0.693 | -0.002 |
| NACC | 1398 | 0.11→0.12 | 0.01 | 0.849 | 0.823 | +0.026 | 0.744 | 0.641 | +0.102 |
| AIBL | 828 | 0.11→0.11 | 0.00 | 0.917 | 0.919 | -0.002 | 0.736 | 0.656 | +0.080 |
| KDRC | 531 | 0.09→0.47 | 0.38 | 0.896 | 0.904 | -0.008 | 0.837 | 0.694 | +0.143 |
| AJU | 261 | 0.09→0.91 | 0.82 | 0.896 | 0.823 | +0.073 | 0.662 | 0.660 | +0.002 |

## pre-registered tests
- **T1** mean AUC gap (oracle−LOCO) = **+0.024** (작으면 site가 discrimination에 benign)
- **T2** corr(prior-shift, AUC gap) = +0.396 [95% -1.00,+1.00] (≈0이면 discrimination 손실이 prior-shift 아님)
- **T3** corr(prior-shift, BA gap) = -0.179 [95% -1.00,+1.00] (양수면 배포(threshold) 손실이 prior-shift)

## 판정 (정직, n_folds 작음 주의)
- T1(AUC gap 작음): ✅ | T3(BA gap↔prior-shift 양): ❌
- 재프레이밍 'site benign for ranking, prior-shift drives deployment': 부분/미지지

⚠️ n_folds=5 (코호트 5개) — 상관 CI 넓음. 강한 주장 금물, 방향성 증거로만.