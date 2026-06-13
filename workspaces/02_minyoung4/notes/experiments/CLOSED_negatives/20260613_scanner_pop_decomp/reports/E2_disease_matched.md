# E2 — DISEASE-MATCHED confound control (audit fixes applied)

각 cohort를 CN/AD 균형 subsample (cohort ⟂ disease). train-only z. seed-sync. 5 seeds.

| pair | ancestry | AJU? | align(matched) | deflation(matched) |
|---|---|:--:|--:|--:|
| AIBL-AJU | cross-ancestry | Y | -0.105±0.031 | -0.002±0.002 |
| NACC-KDRC | cross-ancestry |  | -0.066±0.057 | +0.001±0.004 |
| ADNI-KDRC | cross-ancestry |  | -0.066±0.010 | +0.001±0.003 |
| ADNI-NACC | same-population |  | -0.045±0.140 | -0.000±0.003 |
| AIBL-KDRC | cross-ancestry |  | -0.044±0.066 | -0.002±0.002 |
| NACC-AIBL | same-population |  | -0.039±0.068 | +0.002±0.004 |
| NACC-AJU | cross-ancestry | Y | -0.029±0.081 | -0.003±0.003 |
| KDRC-AJU | same-population | Y | -0.001±0.134 | +0.000±0.002 |
| ADNI-AJU | cross-ancestry | Y | +0.003±0.064 | -0.002±0.003 |
| ADNI-AIBL | same-population |  | +0.009±0.045 | +0.000±0.003 |

## ③ (disease-matched): align→deflation Spearman rho = **-0.200** (p=0.580, n=10)
- **AJU 제외 rho = -0.143** (p=0.787, n=6)  ← E1 confound 견디는지 핵심

## ② (disease-matched): deflation by ancestry
- cross-ancestry = -0.001 (n=6) | same-population = +0.000 (n=4)

## permutation null (cohort shuffled within disease): mean deflation = -0.001 (진짜 effect면 ≈0 이어야)

## 판정 (정직)
- disease-matched에서 ③(AJU제외 rho>0.3) AND ②(cross>same): ❌ disease-imbalance artifact였음 (E1 기각)