# 2026-06-13 — Fusion combiner search (beyond simple mean)

**Status:** RUNNING (λ=0 wave training, λ=1 queued; code-audit in progress)

## Motivation
Prior work established (EXP-011e) that a parameter-free **mean(morph, deep)** fusion
beats the morphometry baseline on all 6 held-out cohorts (LOCO MAE 4.81→4.28,
p<1e-97). BUT a simple average is **not a methodological novelty** — it is textbook
ensembling, and the literature already shows deep+FreeSurfer brain-age fusion
(Mouches 2022, Front Neurol) and averaging ensembles (Lombardi 2021). See
`../../EXPERIMENTS.md` and literature-scout summary.

The only remaining method hook: a combiner that is **adaptive yet leakage-immune**
(does not fit on labels) and beats the simple mean cross-cohort. Top bet:
**`precision_subj`** — per-subject inverse-variance weighting using deep ensemble
disagreement (epistemic) + morph bootstrap std. If it beats mean leakage-safe,
that is an ACCV-plausible method ("stacking's adaptivity with averaging's
robustness, without label fitting"). If NO combiner beats mean → rigorous negative
("the gain is ensemble variance reduction, not a clever combiner") → benchmark
framing (MICCAI/NeuroImage), reversing Couvy-Duchesne's "stacking>averaging".

## Setup (reproducible)
- Task: brain-age regression on CN subjects, 96³ N4 T1, 6 evaluable cohorts
  (A4/ADNI/AIBL/KDRC/NACC/OASIS; AJU dropped, <30 CN-with-age).
- Honest metric: **leave-one-cohort-out (LOCO)**, per-cohort bootstrap 95% CI on
  ΔMAE + subject-level paired Wilcoxon.
- `dump_brainage_rich.py`: per fold, morph Ridge + bootstrap std, deep K=5 seeds
  (per-seed preds saved), λ=0 (vanilla) and λ=1 (cohort-adversarial GRL ablation).
  Fold-parallel: one held-out cohort per GPU (GPU1-6; GPU0 = another user's job).
- `fusion_lab.py`: pre-registered combiner family, all fitted params on TRAIN rows
  only, evaluated on held-out TEST rows. Reports ALL variants (no cherry-pick).

## Leakage safeguards (must hold — under independent audit)
- morph/deep fit on train cohorts only; held-out cohort never seen in any fit.
- NA fill + standardization use TRAIN statistics only.
- Combiners fit on `split=='train'`, evaluated on `split=='test'`.
- `precision_subj` uses only model uncertainties (no held-out labels).
- Known caveat: deep TRAIN preds are in-sample (optimistic) → handicaps FITTED
  combiners but does NOT inflate held-out test eval (test cohort never trained on).

## Artifacts (this directory)
- `preds/`   — rich per-fold parquets + merged `brainage_rich_l{0,1}_96.parquet`
- `analysis/`— fusion_lab outputs (per-combiner CSVs)
- `logs/`    — training logs per fold
- Inputs/code live in the track root; this dir holds THIS experiment's outputs only.

## Convention
Directories with a genuinely novel / strong verified result are marked with ⭐ in
their name. This experiment is unmarked until a result is verified novel.

## Results
(pending — filled after waves complete + audit + fusion_lab Mode B)
