# D2-S1 — adaptation ladder, brain-age, LOCO (mean±std over seeds)

## held-out = AJU
| mode | test MAE (down=better transfer) | site-AUC (down=less site) | n_seed |
|---|--:|--:|--:|
| frozen | 5.72 ± 0.02 | 0.764 ± 0.022 | 3 |
| partial | 5.43 | 0.767 | 1 |
| scratch | 5.70 ± 0.10 | 0.718 ± 0.002 | 3 |
| full | 5.47 ± 0.06 | 0.771 ± 0.017 | 3 |

→ full vs frozen: -0.25yr | full vs scratch (foundation value): -0.23yr

## held-out = KDRC
| mode | test MAE (down=better transfer) | site-AUC (down=less site) | n_seed |
|---|--:|--:|--:|
| frozen | 6.36 ± 0.02 | 0.768 ± 0.008 | 3 |
| partial | 6.06 | 0.784 | 1 |
| scratch | 5.79 ± 0.07 | 0.698 ± 0.020 | 3 |
| full | 5.35 ± 0.04 | 0.752 ± 0.003 | 3 |

→ full vs frozen: -1.02yr | full vs scratch (foundation value): -0.44yr


## 판정
- full < frozen (음수) → 적응이 frozen 천장 escape. full < scratch (음수) → pretraining 가치.