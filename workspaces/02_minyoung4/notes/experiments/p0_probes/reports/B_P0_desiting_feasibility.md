# B-P0 — feature-level de-siting feasibility (fs_vol)

n=3180 (100 ICV-norm fs_vol features). random split.

## baselines
- fs_vol→cohort  linear **0.916** / MLP **0.894**
- fs_vol→dementia (random) **0.949**

## after INLP linear cohort-erasure (k=6)
- residual cohort  linear **0.777** / MLP **0.753**
- residual dementia **0.888**  (Δ vs baseline -0.061)

## LOCO dementia (fs_vol, raw — the transfer to improve)
| held-out | dementia AUC | n_test(dem labelled) |
|---|--:|--:|
| ADNI | 0.845 | 669 |
| OASIS | 0.977 | 364 |
| AJU | 0.787 | 213 |
| KDRC | nan | 21 |

## verdict
⚠️ **entanglement**: erasing cohort also dropped dementia (0.95→0.89) → site≈severity; naive de-siting removes signal. B must be label-aware/conditional.