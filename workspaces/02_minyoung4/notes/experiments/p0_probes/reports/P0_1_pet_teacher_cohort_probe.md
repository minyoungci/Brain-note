# P0.1 — PET teacher cohort-separability (KILL GATE)

Sample: 1000 subjects (15 SUVR-distribution features). Reference: structural fs_vol→cohort AUC = **0.747**.

## 4-way cohort macro one-vs-rest AUC = **0.829**

## pairwise cohort AUC (SUVR distribution → which cohort)

| pair | AUC | note |
|---|--:|---|
| ADNI vs OASIS | 0.900 |  |
| ADNI vs AJU | 0.885 |  |
| ADNI vs KDRC | 0.840 |  |
| OASIS vs AJU | 0.927 |  |
| OASIS vs KDRC | 0.810 |  |
| AJU vs KDRC | 0.780 | same-tracer FBB/FMM |

## verdict

- PET teacher macro AUC 0.829 — comparable to/below the learned-feature confound; biological-teacher premise survives this gate. Proceed to P0.2.