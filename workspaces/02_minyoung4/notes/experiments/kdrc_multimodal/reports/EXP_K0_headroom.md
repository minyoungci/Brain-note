# EXP-K0 — Direction-1 headroom gate (KDRC mixed-pathology)

## feasibility N (amyloid SUVR + Fazekas + CDR-SB): **263** subjects
- amyloid SUVR n=481, Fazekas n=287, both n=263

## amyloid↔vascular 독립성: corr(SUVR, Fazekas) = **-0.099** (독립 축(혼합병리 분리 가능))

## CDR-SB (R²) — nested ladder (n=263, 5-fold CV)
| 모델 | score | Δ vs morphometry |
|---|--:|--:|
| clinical | -0.020 |  |
| +morphometry | 0.236 |  |
| +amyloid | 0.240 | +0.004 |
| +vascular(Fazekas) | 0.228 | -0.008 |

## CDR-global (R²) — nested ladder (n=263, 5-fold CV)
| 모델 | score | Δ vs morphometry |
|---|--:|--:|
| clinical | -0.022 |  |
| +morphometry | 0.142 |  |
| +amyloid | 0.146 | +0.004 |
| +vascular(Fazekas) | 0.125 | -0.017 |

## amyloid+/− 예측 (imaging→amyloid) — AUC (n=287, pos 208/neg 79, 5-fold)
> 보조 체크: 구조+혈관 영상이 amyloid 양성을 예측? (amyloid는 SUVR 제외)
| 모델 | AUC |
|---|--:|
| clinical | 0.468 |
| +morphometry | 0.697 |
| +vascular(Fazekas) | 0.682 |

## CN vs impaired(MCI+AD) — AUC (n=244, imp 243/CN 1, 5-fold)
| 모델 | AUC |
|---|--:|
| (skipped — CN 부족) | — |

## 게이트 판정