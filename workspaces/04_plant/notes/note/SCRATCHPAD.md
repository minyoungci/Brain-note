# SCRATCHPAD — plant/ research program

_Workspace: `/home/vlm/plant` (fresh). Goal: SCI journal / AI top-tier conference result._
_Last updated: 2026-06-01 (initial inventory + direction scoping)._

## 0. Operating rules (from CLAUDE.md — non-negotiable)
- bf16 only (no fp16). B200 GPUs available, resources currently ample.
- `/home/vlm/data` is READ-ONLY canonical. Never write there.
- `cdr_global` is **string-typed** in the manifest → `pd.to_numeric()` before any comparison, or it silently TypeErrors / mis-sorts.
- Generation and verification are SEPARATE steps. Do not self-declare "done" without independent verification (test run / agent audit).
- Surgical changes only; pre-approval for GPU runs, 10+ file bulk edits, pyproject changes.

## 1. Primary data asset
`/home/vlm/data/preprocessed_official/official_manifest_full.parquet` — 13,022 sessions × 75 cols, 1 row/session.
Dict: `official_manifest_full.README.md`. Join key `tag = consortium_subject_session`.

| cohort | sessions | subjects | ≥2 sessions | CN/IMPAIRED (subj, baseline) |
|---|---:|---:|---:|---|
| A4 | 1811 | 992 | 793 | 710 / 282 |
| ADNI | 4742 | 1580 | 849 | 860 / 720 |
| AIBL | 987 | 617 | 178 | 425 / 192 |
| AJU | 1287 | 1001 | 286 | 27 / 974 (memory-clinic, ~pure impaired — NOT a CN source) |
| KDRC | 909 | 909 | 0 | 280 / 629 (strictly cross-sectional) |
| NACC | 1866 | 1414 | 361 | 897 / 517 |
| OASIS | 1420 | 718 | 363 | 518 / 200 |
| **TOTAL** | **13022** | **7231** | **2830** | **3717 / 3514** |

**Labels:** cdr_global & cdrsb = 100%. FastSurfer volumes (33 cols) = 100%, signal confirmed (hippo −20% CN→CDR≥1).
clin_dx_label 10,550 (CN 5025 / MCI 2937 / CN_preclinical 1811[=A4 amyloid+] / AD 558 / Dementia 165 / ImpairedNotMCI 54; AJU=0).
**Single-cohort traps:** APOE & MoCA = NACC-only; MMSE absent in ADNI; sex NaN for A4+ADNI (use clin_sex_raw).
**ROI:** roi_usability USABLE_AUTO 12,932 (USABLE_AUTO∪W_CAVEAT = 12,962 / 99.5%). roi_final_ready = ALL False (fail-closed, no human gold standard).

## 2. Prior-work frontier (what's settled — do NOT re-propose)
### EXP01 (minyoung2) — LOCO control-battery protocol (MATURE)
- Q: does T1 rep carry transportable CDR-impairment signal incremental over nuisance shortcuts (site/provenance/tracer/volume)?
- **Headline (revised 2026-06-01):** vs 5-ROI regional-volume baseline (F9), deep **ties 5/5 folds**; advantage only **pooled +0.018 AUROC [+0.011,+0.026]** (n=4966). Honest thesis = parsimony/cautionary, NOT "deep adds value".
- FALSIFIED (never re-propose): amyloid line (OASIS-only, label 81.9% missing); discrete tokenizer (no incremental signal); "brain-pretrain stabilizes transport" (false, ConvNeXt-linked not pretrain); "group-DRO fixes transport" (cohort-dependent, breaks AIBL).
- Open weakness: **LOCO transport is seed-unstable** (NACC/AIBL collapse on some seeds); in-dist val checkpoint → OOD gap.
- In-flight (no ledger yet): full-res 3D CNN strong-deep baseline (IMG-020/021/022).

### F04 (minyoung3) — 2.5D MAE SSL + ROI
- MAE backbone NEVER fully trained (pilot only). ROI-evidence encoder: ventricle R²≈0.64 strong, hippo/MTL weak. Downstream probes all DELETED (scripts survive).

## 3. Reusable code assets
- minyoung2: `build_exp01_cdr_split.py` (subject-level + LOCO splits, tested), `run_exp01_nuisance_baseline.py` (the "bar"), `train_roi2p5d_mil_smoke.py` (2.5D MIL trainer), `exp01_incremental_value.py` (paired bootstrap ΔAUROC), `exp01_regional_volume_baseline.py` (F9 5-ROI baseline), `train_exp01_3dcnn.py` (3D CNN). Data: `data/derived/exp01_cdr_multicohort/`.
- minyoung3: `train_f04_roi_evidence_cached.py`, ROI slab cache builders, `audit_*_leakage.py`, MAE DDP trainer (untested at scale). Dataset: `results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset/` (18,815 sessions, 56,445 slabs, 10,564 longitudinal pairs).

## 4. CHOSEN DIRECTION: Longitudinal progression (2026-06-01)
Predict FUTURE CDR progression from a SINGLE baseline scan, cross-cohort. Framed as a temporal
extension of the EXP01 protocol:
> **H1**: a learned baseline-scan representation predicts future CDR progression incrementally
> over baseline FreeSurfer regional volumetry + clinical covariates, AND this transports to held-out cohorts.
Either answer publishable (positive = deep earns its keep on the harder temporal task; negative = strong cautionary extension of EXP01's deep≈volumetry finding).

### Feasibility constraints (VERIFIED by agent, 2026-06-01) — these reshape the design
- **No time-interval column.** Interval computable only via session_id parse:
  ADNI/AIBL = calendar date; A4 = VISCODE months; OASIS = days-from-baseline. **NACC = image ID (NO time, NOT orderable); AJU = V1/V2 (ordinal); KDRC = single-session.**
- **clin_dx_label is subject-level constant** → CANNOT encode conversion. Endpoint must use session-level cdr_global/cdrsb only.
- **Converter sparsity (CN baseline → later CDR≥0.5):** ADNI 130, A4 96, OASIS 30, AIBL 14, NACC 16, AJU 0. Only ADNI & A4 have enough positives to be LOCO held-out folds.
- **DESIGN DECISION:** restrict longitudinal task to temporally-orderable cohorts = **ADNI, AIBL, A4, OASIS** (270 converters). Exclude NACC (unorderable), AJU (no CN baseline), KDRC (single-session). Held-out LOCO folds = ADNI, A4. Honest 4-cohort transportability.
- **Primary endpoint:** CN-at-baseline → ever-impaired (cdr_global≥0.5 at any later session). **Confound to control: follow-up duration** (longer follow-up → more progression chance) → include as covariate + sensitivity analysis on interval cohorts.
- **Secondary:** cdrsb-delta≥0.5 (761 pos overall; richer, includes impaired baselines). AIBL has NO cdrsb, AJU cdrsb all-zero → exclude from cdrsb endpoint.
- Prior F04 pairs are consecutive-visit, not baseline-anchored → must REBUILD baseline-anchored.

### Literature scan status
- deep-research workflow FAILED (StructuredOutput env incompat, ~1.36M tokens wasted). NOT retrying.
- Fallback: literature-scout agent for positioning (launched 2026-06-01).

## 4b. Literature positioning (literature-scout, 2026-06-01) — DECISIVE
- **Bron et al. 2021 (NeuroImage:Clinical)**: deep CNN does NOT beat conventional structural features
  for MCI→AD conversion (SVM 0.756 vs CNN 0.742 internal p<0.01; tie external). → "deep beats volumetry
  on progression" already ~falsified. Our novelty CANNOT rest on a deep advantage.
- Honest image-only baseline-T1 conversion AUROC ≈ 0.70–0.78; >0.85 = leakage/multimodal.
- Genuine gap = systematic LOCO incremental-value-over-volumetry TRANSPORT test for progression.
- MANDATORY: time-to-event/survival (c-index), NOT binary fixed-horizon (follow-up-duration confound).
- Sharpest angle = FALSIFICATION study; a well-powered pre-registered NULL with tight CIs is publishable.
  A4 preclinical regime = stress test. Power is the #1 threat.
- Cite [VERIFY all DOIs]: Bron 2021 nicl; Li/Habes/Wolk/Fan 2019 A&D; TRIPOD 2015.

## 5. PROGRESS (2026-06-01)
- ✅ `scripts/build_longitudinal_cases.py` + `tests/test_build_longitudinal_cases.py` — PASS.
  Invariants + 160-subject independent re-derivation match. Output: `data/derived/longitudinal_progression/`.
  Counts cross-validate feasibility agent: ADNI 130 / A4 98 / OASIS 30 / AIBL 14 converters (272 total,
  1467 CN-baseline evaluable). Survival fields (event/time_to_event/censoring) added + verified.
- ✅ Pre-registration: `docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md`
  (endpoints, LOCO held-out=ADNI+A4, 5-arm control battery, decision criteria, null-is-valid, power threat).

## 6. NEXT ACTIONS (awaiting greenlight on pre-reg §7 criteria)
1. [next] LOCO survival splits + leakage audit (CPU).
2. [next] **Volumetry+clinical Cox baseline ("the bar")** — c-index + bootstrap CI per fold. CPU, before any deep.
3. [pending] cohort-ID + shuffled controls.
4. [pending] deep image arm (GPU — needs pre-approval) + incremental test on the delta.
5. [pending] power/MDE analysis + synthesis.

### Key numbers to remember
- Held-out converters: ADNI 130, A4 98 → wide CIs; +0.02 Δc-index may be undetectable (MDE analysis required).
- A4 follow-up median 1.5y (m48/m66 visits), ADNI 5.7y, OASIS 5.0y. AIBL has NO cdrsb.
