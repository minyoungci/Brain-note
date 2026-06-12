# E2-E6 — separability diagnostic: within-data calibration

5 seeds, mean±std.

## E4 — calibration spectrum (does DEFLATION rank by true separability?)
| regime | S_raw | S_resid | **Deflation** | dem AUC before→after |
|---|--:|--:|--:|--:|
| random (neg ctrl) | 0.510 | 0.508 | **+0.081±0.051** | 0.892→0.811 |
| within-ADNI scanner (separable) | 0.895 | 0.895 | **+0.351±0.038** | 0.885→0.534 |
| 7-cohort (entangled) | 0.771 | 0.760 | **+0.233±0.061** | 0.887→0.654 |

→ **deflation 순위 random +0.081 < within-ADNI +0.351 < 7-cohort +0.233: ❌ 순위 안 맞음**
→ 핵심: within-ADNI는 S_resid 높아도(=site 신호 큼) **deflation 낮음**(=분리 가능); 7-cohort는 S_resid도 deflation도 높음(=얽힘). **S_resid만으론 구분 불가, deflation이 disambiguator.**

## E6 — robustness (7-cohort)
- nonlinear(MLP) cohort-AUC = 0.800±0.003 (linear 0.774) → site 신호가 선형에 국한 안 됨.
- permutation chance cohort-AUC = 0.498 (≈0.5 확인).
- 7-cohort deflation 95%-ish = +0.233±0.061 (5 seeds, robust).