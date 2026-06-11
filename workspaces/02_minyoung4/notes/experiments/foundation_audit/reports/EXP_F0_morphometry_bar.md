# EXP-F0 — morphometry BAR (fs_vol). Foundation models must beat this.

## (A) site-probe — fs_vol → cohort 7-way macro-AUC = **0.770** (chance 0.5)

## (B) brain-age — fs_vol → age (ridge), MAE (lower=better)
| scope | MAE (yr) | n_test |
|---|--:|--:|
| CLEAN(AJU+KDRC) subj-split | 5.56 | 607 |
| ADNI within-5CV | 4.47 | 4699 |
| NACC within-5CV | 5.54 | 1866 |
| A4 within-5CV | 3.14 | 1811 |
| OASIS within-5CV | 5.11 | 1420 |
| AIBL within-5CV | 4.67 | 987 |
| AJU within-5CV | 5.25 | 1287 |
| KDRC within-5CV | 5.27 | 770 |

## (C) CN/AD — fs_vol → CN vs AD(+Dem), AUC (leakage-clean only)
| setup | AUC | n_test(CN/AD) |
|---|--:|--:|
| KDRC within-5CV | 0.911 | 531 |
| train KDRC → test AJU | 0.87 | 261 |
| train AJU → test KDRC | 0.875 | 531 |

## BAR 요약 (BrainIAC이 넘어야 할 기준선)
- site-probe (낮을수록 site-robust): 0.770
- brain-age MAE (낮을수록 좋음): CLEAN 5.56yr
- CN/AD KDRC-CV AUC: 0.911