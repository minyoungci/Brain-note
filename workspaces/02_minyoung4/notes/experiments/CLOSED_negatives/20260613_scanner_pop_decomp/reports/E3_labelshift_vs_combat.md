# E3 — label-shift correction vs ComBat for cross-cohort (LOCO) disease deployment

LOCO CN/AD. balanced-acc @0.5. label-shift=Saerens EM (target probs only). leakage-safe. 5 seeds.

| held-out | n | src P(AD) | tgt P(AD) | est P(AD) | AUC | BA raw | BA +ComBat | BA +label-shift |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| ADNI | 2666 | 0.13 | 0.08 | 0.07 | 0.857 | 0.694 | nan | 0.638 |
| NACC | 1398 | 0.11 | 0.12 | 0.11 | 0.819 | 0.641 | nan | 0.641 |
| AIBL | 828 | 0.11 | 0.11 | 0.05 | 0.917 | 0.649 | nan | 0.577 |
| KDRC | 531 | 0.09 | 0.47 | 0.46 | 0.900 | 0.687 | nan | 0.838 |
| AJU | 261 | 0.09 | 0.91 | 0.90 | 0.814 | 0.665 | nan | 0.521 |

## 결과
- mean ΔBA: **+ComBat +nan** vs **+label-shift -0.024** (raw 대비)
- AUC(prior-invariant) 평균 0.861 = ranking은 cross-cohort서 보존(site benign for discrimination).
- prior 추정 정확도: |est−tgt| 평균 0.023

## 판정 (정직)
- label-shift > ComBat (cross-cohort gap 더 닫음): ❌/미미