# E1 — ComBat-deflation predictive validity (leakage-safe, 5 seeds)

alignment(PRE, train) vs ComBat disease-AUC deflation(POST, test). covars=age+sex.

| pair | ancestry | n | align(PRE) | ComBat deflation | base→combat AUC |
|---|---|--:|--:|--:|--:|
| ADNI-AIBL | same-population | 5686 | -0.038 | +0.001±0.001 | 0.874→0.873 |
| NACC-AIBL | same-population | 2853 | -0.020 | +0.008±0.005 | 0.893→0.885 |
| ADNI-NACC | same-population | 6565 | +0.042 | +0.003±0.002 | 0.872→0.869 |
| ADNI-scanner(within) | within-scanner | 4697 | +0.095 | +0.002±0.002 | 0.878→0.876 |
| NACC-KDRC | cross-ancestry | 2636 | +0.267 | +0.004±0.010 | 0.873→0.870 |
| KDRC-AJU | same-population | 2057 | +0.299 | +0.017±0.007 | 0.912→0.895 |
| AIBL-KDRC | cross-ancestry | 1757 | +0.372 | +0.041±0.006 | 0.913→0.872 |
| ADNI-KDRC | cross-ancestry | 5469 | +0.409 | +0.024±0.004 | 0.892→0.867 |
| AIBL-AJU | cross-ancestry | 2274 | +0.489 | +0.116±0.017 | 0.928→0.812 |
| NACC-AJU | cross-ancestry | 3153 | +0.494 | +0.057±0.015 | 0.901→0.845 |
| ADNI-AJU | cross-ancestry | 5986 | +0.552 | +0.064±0.016 | 0.888→0.824 |

## ③ predictive validity: align(PRE) → ComBat deflation(POST)
- Spearman rho = **+0.900** (p=0.000), Pearson r = +0.777, n_pairs=11

## ② population law: deflation by ancestry
- cross-ancestry mean deflation = +0.051 (n=6)
- same-population  mean deflation = +0.007 (n=4)
- within-ADNI-scanner deflation = +0.002

## 판정
- ③ (align→deflation 예측): ✅ 양의 상관 (robust)
- ② (cross-ancestry > same-pop deflation): ✅