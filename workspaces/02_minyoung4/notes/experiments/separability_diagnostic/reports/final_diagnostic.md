# FINAL — site-population separability diagnostic (excess-alignment, validated)

metric = ||P_cohort · w_disease|| − chance, k=2 dirs, 5 seeds mean±std.

## E4 — calibration (excess-alignment ↑ = entangled)
| regime | excess-alignment | disease-AUC drop (k dims) |
|---|--:|--:|
| random pseudo-cohort (separable, neg ctrl) | +0.086±0.109 | +0.001 |
| within-ADNI scanner (separable) | +0.003±0.081 | -0.001 |
| 7-cohort (entangled) | +0.546±0.018 | +0.013 |

→ **separable regimes ≤ +0.086  ≪  entangled +0.546: ✅ 진단도구가 분리↔얽힘 구분 (calibrated)**

## E1/E2 — application: 7-cohort entanglement, two feature spaces
- morphometry (FastSurfer 30-d): excess-alignment **+0.546±0.018**
- BrainIAC features (768-d, learned): excess-alignment **+0.389±0.021**
  → 학습 표현도 morphometry와 같은 방향(얽힘) — 표현 학습이 entanglement 못 줄임.

## E3 — per-cohort-pair entanglement (which pairs are separable?)
| pair | excess-alignment |
|---|--:|
| AJU–KDRC | +0.294±0.044 |
| ADNI–OASIS | +0.305±0.081 |
| ADNI–AJU | +0.575±0.029 |
| OASIS–KDRC | +0.593±0.036 |
| ADNI–NACC | +0.132±0.073 |

## E6 — robustness
- excess-alignment chance-corrected (Monte-Carlo 300) + dimension-matched (fixed k) → cohort-decodability에 불변 (naive deflation의 결함 제거, improved_metric.md 참조).
- 7-cohort entanglement morphometry 0.546 (tight CI), 음성대조 통과.