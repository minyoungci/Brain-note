# 2026-06-13 — Brain-age-gap (BAG) as a cross-cohort biomarker

**Status:** PILOT done (morphometry). deep/fused BAG queued (after λ=1 wave frees GPUs).

## Why (the gap)
The combiner search (`../2026-06-13_combiner_search/`) closed the "clever fusion
method" door: no learned/adaptive combiner beats the simple mean cross-cohort.
literature-scout confirmed one remaining gap: **deep-BAG vs morphometry-BAG vs
FUSED-BAG head-to-head clinical prediction, cross-cohort, is unpublished** (Q4).
This experiment tests whether the FUSED brain-age-gap is a stronger cross-cohort
biomarker of cognitive impairment than either component alone.

## Leakage-safe design (LOCO)
- Brain-age model trained on CN(+CN_preclinical) of ALL OTHER cohorts only.
- de Lange & Cole (2020) age-bias correction fit on CN-train only.
- Applied to held-out cohort's CN/MCI/AD subjects → BAG = corrected_pred − age.
- Biomarker tested on held-out cohort. Model/correction never see held-out.

## Pilot result — morphometry BAG (CPU, `analysis/morph_bag_percohort.csv`)
Held-out per cohort, BAG by dx severity (CN→MCI→AD):
| cohort | BAG CN→MCI→AD | d(CN,AD) | AUC(CN vs imp) |
|---|---|---|---|
| ADNI | −2.2 → +1.6 → +9.7 | 1.19 | 0.625 |
| AIBL | −2.5 → +3.2 → +10.9 | 1.60 | 0.742 |
| AJU (Korean) | −9.1 → −8.1 → −2.8 | **0.40** | **0.534** ⚠️ |
| KDRC (Korean) | −6.1 → −6.0 → +4.5 | 1.05 | 0.638 |
| NACC | +0.7 → +3.0 → +15.7 | 1.60 | 0.633 |
| OASIS | −2.4 → +3.2 → +16.4 | 2.49 | 0.690 |

**mean d(CN,AD)=1.39, mean per-cohort AUC=0.644; pooled AUC=0.563.**

Observations (candidate new facts, to confirm with deep/fused):
1. BAG carries cross-cohort impairment signal (CN<MCI<AD monotone in 5/6 cohorts).
2. **per-cohort AUC (0.644) ≫ pooled (0.563)** → large between-cohort BAG offset
   (site effect on BAG); pooling washes signal. Cross-cohort BAG harmonization is
   itself a candidate gap.
3. **AJU (Korean) is an outlier** — BAG offset −9yr, weak dx separation (d=0.40,
   AUC 0.534). Non-Western generalization limit.

No overselling: morph-BAG separating dx is KNOWN (Franke 2010); the pilot only
confirms cross-cohort survival. NOVELTY = does fused-BAG beat morph/deep-BAG
(esp. on weak cohorts / MCI / pooled). That needs the deep run.

## Cache feasibility
CN (7580) + AD (969) fully cached at 96³; MCI 1301/4034 cached (2733 missing →
ADNI MCI mostly uncached). Head-to-head restricted to CACHED subjects for fairness;
CN-vs-AD is full coverage, MCI cohort-limited. Cached non-CN: AJU 1217, KDRC 364,
NACC 301, ADNI 216, AIBL 93, OASIS 79.

## Next
`dump_bag_rich.py` (train deep brain-age on CN-train, predict held-out all-dx) →
`bag_analysis.py` (morph/deep/fused BAG head-to-head, bias-corrected, per-cohort +
pooled, dx discrimination). Launch when λ=1 wave frees GPU1-6.
