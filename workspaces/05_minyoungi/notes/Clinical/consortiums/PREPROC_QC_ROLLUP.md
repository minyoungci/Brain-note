# Preprocessed-tensor QC — cross-consortium roll-up

## Completeness

- manifest sessions: **13022**
- QC'd sessions: **13022** (rows 13022)
- missing (in manifest, not QC'd): **0**
- extra (QC'd, not in manifest): **0**
- duplicate QC rows for same tag: **0**

## Status

| consortium | n | PASS | WARN | FAIL |
|---|---|---|---|---|
| A4 | 1811 | 1811 | 0 | 0 |
| ADNI | 4742 | 4742 | 0 | 0 |
| AIBL | 987 | 987 | 0 | 0 |
| AJU | 1287 | 1287 | 0 | 0 |
| KDRC | 909 | 909 | 0 | 0 |
| NACC | 1866 | 1864 | 2 | 0 |
| OASIS | 1420 | 1420 | 0 | 0 |
| **TOTAL** | 13022 | 13020 | 2 | 0 |

## Cross-session duplicate tensors

- raw tensor hash collisions: **4** (distinct hashes 13018 / 13022 files)
  - `394f73c2b052b44d` x2 [CROSS-SUBJECT (leakage risk)]: AJU_ABD-BS-0013_V1, AJU_ABD-BS-0014_V1
  - `09e995895d0edf13` x2 [same-subject]: OASIS_OAS30422_d0099, OASIS_OAS30422_d0104
  - `aa0a914221c8f8f3` x2 [same-subject]: OASIS_OAS30527_d0000, OASIS_OAS30527_d0006
  - `69ce332586addc29` x2 [CROSS-SUBJECT (leakage risk)]: AJU_ABD-AJ-0029_V2, AJU_ABD-AJ-0030_V1
- N4 tensor hash collisions: **4** (distinct hashes 13018 / 13022 files)
  - `6b7b3e092a9e4969` x2 [CROSS-SUBJECT (leakage risk)]: AJU_ABD-BS-0013_V1, AJU_ABD-BS-0014_V1
  - `3bbd81f526bb3639` x2 [same-subject]: OASIS_OAS30422_d0099, OASIS_OAS30422_d0104
  - `00675de660da4f0e` x2 [same-subject]: OASIS_OAS30527_d0000, OASIS_OAS30527_d0006
  - `72e19b58df2f704c` x2 [CROSS-SUBJECT (leakage risk)]: AJU_ABD-AJ-0029_V2, AJU_ABD-AJ-0030_V1

## Image QC status x manifest roi_usability

| roi_usability | PASS | WARN | FAIL |
|---|---|---|---|
| NOT_CANDIDATE | 44 | 0 | 0 |
| REVIEW_REQUIRED | 10 | 1 | 0 |
| ROI_UNUSABLE | 5 | 0 | 0 |
| USABLE_AUTO | 12931 | 1 | 0 |
| USABLE_W_CAVEAT | 30 | 0 | 0 |

_roi_usability is a ROI-table verdict from the manifest; image-level QC here is independent. They need not agree, but image FAILs concentrated in ROI_UNUSABLE/REVIEW_REQUIRED would be expected._

## WARN breakdown (by type)

- `raw:mask_touches_fov_edge`: 2
- `n4:mask_touches_fov_edge`: 2

## Verdict

**PROBLEMS FOUND:**
- 4 raw-tensor content-hash collisions (byte-identical files; 2 cross-subject)
- 4 N4-tensor content-hash collisions (byte-identical files; 2 cross-subject)
