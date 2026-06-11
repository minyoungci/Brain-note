# EXP-F2 — BrainIAC frozen features vs morphometry BAR

n=3307 sessions (768-d). probes leakage-safe.

| axis | BrainIAC | morphometry BAR | winner |
|---|--:|--:|---|
| (A) site-probe (↓ better) | 0.842 | 0.770 | morpho less site |
| (B) brain-age MAE clean (↓ better) | 5.73yr | 5.56yr | morpho |
| (C) CN/AD KDRC-CV (↑ better) | 0.735 | 0.911 | morpho |

## 해석
- site-probe 0.842 vs 0.770: 파운데이션이 더 site-loaded.
- brain-age 5.73 vs 5.56: morphometry가 더 정확.
- CN/AD 0.735 vs 0.911: morphometry ceiling 확인.