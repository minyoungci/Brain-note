# Study — T1w structural morphometry -> amyloid positivity (baseline)

- subjects used: **3180** (100 ICV-normalized FastSurfer features); dropped (no label-session stats): 0
- model: standardized L2 logistic regression (C=0.5), leakage-safe CV

| cohort | n | pos-rate | within-cohort 5f AUC | LOCO AUC (train others -> test this) |
|---|--:|--:|--:|--:|
| ADNI | 1203 | 0.397 | 0.679 | 0.691 |
| OASIS | 443 | 0.336 | 0.675 | 0.718 |
| AJU | 1000 | 0.344 | 0.717 | 0.72 |
| KDRC | 534 | 0.678 | 0.764 | 0.766 |
| **pooled** | 3180 | 0.419 | 0.752 | — |

**Read-out**: within-cohort AUC = structural signal ceiling for that site; LOCO AUC = how much survives a domain shift to an unseen cohort/tracer. The gap (within − LOCO) is the generalization headroom the PET-privileged teacher targets.