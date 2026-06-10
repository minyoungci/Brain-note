# Pre-registration — Does deep baseline-MRI representation add *transportable* incremental value over volumetry for AD progression?

_Status: DRAFT for review (2026-06-01). Locks endpoints + success criteria BEFORE modeling._
_Workspace: `/home/vlm/plant`. Data: `official_manifest_full.parquet` (read-only)._

## 1. Framing (falsification, not advocacy)
In-house cross-sectional result: deep T1 representation only **ties** FreeSurfer regional
volumetry for CDR classification (deep advantage +0.018 AUROC pooled; ties 5/5 LOCO folds).
Published progression head-to-head (Bron et al. 2021, *NeuroImage:Clinical*) likewise finds deep
**does not beat** conventional structural features for MCI→AD conversion (SVM 0.756 vs CNN 0.742
internal, p<0.01; tie externally). [VERIFY DOI 10.1016/j.nicl.2021.102712]

**We therefore TEST, not assume, a deep advantage.** Two questions:
- **Q1 (replication on temporal task):** Does a learned baseline-scan representation add incremental
  predictive value for *future* CDR progression over baseline FreeSurfer volumetry + clinical
  covariates (age, sex, baseline CDR-SB)?
- **Q2 (transport):** If there is any increment, does it **transport** to held-out cohorts (LOCO)?

A well-powered, pre-registered **null with tight CIs is a valid primary outcome** and the intended
contribution if the increment is absent — the field is littered with non-replicated positives.

## 2. Contribution claims (what we will assert)
1. A **negative-result-resistant transportability protocol** for progression: incremental value
   measured **on the delta** (paired bootstrap CI of Δ c-index), with an explicit **transport
   criterion** across LOCO folds — not standard in AD-DL (dominated by single-split accuracy).
2. The **substantive answer** to Q1/Q2 across 4 consortia, with A4's preclinical (amyloid-enriched,
   mostly CDR 0) regime as a deliberate **out-of-regime stress test**.

## 3. Endpoints
- **Primary — time-to-event conversion (survival).** Subjects CN at baseline (cdr_global==0).
  `event_conversion` = cdr_global ≥ 0.5 ever observed after baseline; `time_to_event_years` = time
  of first conversion (event) or last follow-up (right-censored). Metric = **Harrell's c-index**.
  Survival framing is mandatory (handles variable follow-up + censoring; binary fixed-horizon
  confounds follow-up duration — see §6).
- **Secondary — CDR-SB worsening.** Δcdrsb ≥ 0.5 from baseline. AIBL excluded (no CDR-SB).
- **Sensitivity — fixed-horizon binary** at 24m / 36m on interval cohorts only (ADNI/AIBL/OASIS),
  to connect to the conversion-AUROC literature. NOT primary.

## 4. Cohorts & splits (built + verified: `data/derived/longitudinal_progression/`)
Longitudinal-eligible = temporally orderable + ≥2 CDR sessions. **ADNI / AIBL / A4 / OASIS only**
(NACC unorderable image-IDs; AJU no CN baseline; KDRC single-session — all excluded by design).

| cohort | longit. subj | CN-baseline | converters | cens. follow-up median (y) | LOCO held-out? |
|---|---:|---:|---:|---:|:--:|
| ADNI | 849 | 464 | 130 | 5.72 | **yes** |
| A4 | 769 | 560 | 98 | 1.50 | **yes** |
| OASIS | 363 | 317 | 30 | 5.01 | train-pool (30 pos: too few to hold out) |
| AIBL | 178 | 126 | 14 | 3.11 | train-pool (14 pos) |
| TOTAL | 2159 | 1467 | 272 | — | |

- **LOCO folds = held-out {ADNI}, {A4}.** Remaining 3 cohorts = train+val (stratified subject-level).
  OASIS/AIBL too sparse in positives to be held-out test sets — reported pooled only.
- Split unit = subject_id (no subject in >1 split). Baseline scan must be `baseline_usable`
  (roi_usability ∈ USABLE_AUTO/W_CAVEAT, tensor+mask exist). Attrition ≤16 subjects (A4).

## 5. Arms (control battery, adapted from EXP01 to survival)
All arms feed an identical survival head (Cox or DeepSurv-style partial-likelihood) on the same folds:
1. **clinical+volumetry baseline ("the bar")** — age, sex, baseline CDR-SB + FreeSurfer ROI volumes
   (hippocampus, entorhinal, ventricle, inf-lat-vent, amygdala, parahippocampal, L/R; head-size
   = fs_MaskVol). Penalized Cox. **This is what deep must beat.**
2. **image-full** — deep baseline-scan representation (+ same clinical covariates for the increment test).
3. **mask-only** — brain-geometry control (representation from mask, no T1 intensity).
4. **shuffled-label** — leakage probe (must give c-index ≈ 0.5).
5. **volumetry+image** — for the incremental-value test: does image add over volumetry?

## 6. Confound controls (mandatory)
- **Follow-up duration**: survival framing handles it natively; additionally report `followup_years_max`
  distributions per arm and a sensitivity excluding subjects with <1y follow-up.
- **Cohort-as-shortcut**: a cohort-ID-only baseline must NOT transport under LOCO (expect c≈0.5).
- **Leakage audit**: subject-level split disjointness; no future-visit info in baseline features;
  shuffled-label arm ≈ chance. Run before any model is trusted.
- **A4 regime shift**: report A4-held-out separately; do not pool A4 preclinical conversions with
  ADNI clinical conversions in the headline number without the per-fold breakdown.

## 7. Pre-registered decision criteria
- **H-incremental ACCEPTED** iff (volumetry+image) − (volumetry) has paired-bootstrap Δc-index
  **CI lower bound > 0 on BOTH held-out folds (ADNI and A4)**.
- **H-incremental REJECTED (null)** iff Δc-index CI includes 0 on ≥1 held-out fold. Reported as the
  primary finding with CI widths + a **power/MDE analysis** (minimum detectable Δ given converter n).
- image-full must beat shuffled (sanity) and is compared to mask-only to localize signal source.
- No claim is made from pooled-only significance without per-fold transport.

## 8. Threats / honest limitations
- **Power is the dominant threat**: 130/98 held-out converters → wide CIs that can swamp a +0.02 Δ.
  MDE analysis is part of the deliverable, not an afterthought.
- A4 follow-up is short (1.5y) and coarse (visits ~m48/m66) → fewer events, censoring-heavy.
- CDR≥0.5 crossing is rater-noisy. clin_dx-based conversion is impossible here (subject-level label).
- 4 cohorts, 2 held-out folds — a modest transport test; framed honestly, not as a broad benchmark.

## 9. Build order (each gated by independent verification)
1. ✅ Baseline-anchored survival label table (`build_longitudinal_cases.py` + test — PASS, 160 subj re-derived).
2. LOCO survival splits + leakage audit. (next)
3. **Volumetry+clinical Cox baseline ("the bar")** — c-index + bootstrap CI per fold. (CPU; before any deep run)
4. Cohort-ID + shuffled controls.
5. Deep image arm (GPU; pre-approval) + incremental test.
6. Power/MDE analysis + synthesis.
