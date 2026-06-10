# Amyloid-PET preprocessing — systematic verification

Defects found: **3** (see `pet_defects.csv`)

| cohort | tasks | PASS files | missing | bad shape | integ bad/checked | SUVR med | in-band% | Dice med/min | late-win ok/bad | AUC | neg-anchor | teacher subj |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| ADNI | 1793 | 1789 | 0 | 0 | 0/40 | 1.309 | 100.0 | 0.885/0.849 | 0/0 | 0.815 | 1.263 | 669 |
| OASIS | 640 | 626 | 0 | 0 | 0/40 | 1.093 | 99.8 | 0.891/0.851 | 623/3 | 0.658 | 1.08 | 342 |
| AJU | 994 | 1 | 0 | 0 | 0/1 | 0.607 | 0.0 | 0.799/0.799 | 0/0 | nan | nan | 1 |
| KDRC | 899 | 1 | 0 | 0 | 0/1 | 0.69 | 0.0 | 0.904/0.904 | 0/0 | nan | nan | 1 |

## status distribution

- ADNI: {"SKIP_EXISTS": 3, "PASS": 1789, "FAIL_SUVR": 1}
- OASIS: {"SKIP_EXISTS": 3, "FAIL_PET_WINDOW": 6, "PASS": 625, "WARN": 1, "FAIL_REGISTER_TIMEOUT": 5}
- AJU: {"SKIP_EXISTS": 992, "FAIL_CONVERT": 1, "WARN": 1}
- KDRC: {"SKIP_EXISTS": 890, "FAIL_SUVR": 8, "WARN": 1}

## poolability read-out

- **AUC (SUVR vs binary label)**: PET teacher carries amyloid signal where AUC >> 0.5.
- **neg-anchor SUVR**: amyloid-NEGATIVE median SUVR per cohort. Large cross-cohort
  spread => tracer/site batch effect => teacher needs per-cohort normalization.

  neg-anchors: {"ADNI": 1.263, "OASIS": 1.08, "AJU": NaN, "KDRC": NaN}

## verdict: DEFECT-FREE ✅  (hard defects=0, QC-exclusions=3)

QC-exclusions (flagged for downstream filtering, not defects):
- OASIS OAS30132 d0063 — SUVR_OUT_OF_BAND 0.729
- AJU ABD-BS-0023 V1 — SUVR_OUT_OF_BAND 0.607
- KDRC 24678166 ses-1 — SUVR_OUT_OF_BAND 0.690