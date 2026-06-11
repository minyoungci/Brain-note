# P0.3 — clinical-only baselines (ΔAUC reference)

Features per target: {'amyloid': ['age', 'sex', 'mmse', 'apoe4'], 'dementia': ['age', 'sex', 'apoe4']}. dementia drops MMSE (circular with CDR-SB label). Imaging must report ΔAUC over these.

## RANDOM split — clinical AUC (test)

| target | scope | AUC | n_test |
|---|---|--:|--:|
| amyloid | pooled | 0.776 | 485 |
| amyloid | ADNI | 0.766 | 183 |
| amyloid | OASIS | 0.818 | 68 |
| amyloid | AJU | 0.738 | 152 |
| amyloid | KDRC | 0.834 | 82 |
| dementia | pooled | 0.641 | 198 |
| dementia | ADNI | 0.733 | 111 |
| dementia | OASIS | 0.781 | 54 |
| dementia | AJU | 0.467 | 29 |
| dementia | KDRC | nan | 4 |

## LOCO — clinical AUC (train 3 cohorts → test held-out)

| held-out | target | AUC | n_test |
|---|---|--:|--:|
| ADNI | amyloid | 0.796 | 1203 |
| ADNI | dementia | 0.740 | 669 |
| OASIS | amyloid | 0.790 | 443 |
| OASIS | dementia | 0.802 | 364 |
| AJU | amyloid | 0.742 | 1000 |
| AJU | dementia | 0.657 | 213 |
| KDRC | amyloid | 0.731 | 534 |
| KDRC | dementia | nan | 21 |