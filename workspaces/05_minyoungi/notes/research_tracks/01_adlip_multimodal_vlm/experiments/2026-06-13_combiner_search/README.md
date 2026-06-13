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

## Results — λ=0 (vanilla deep), 5 seed × 18 ep, 96³, 6-cohort LOCO
Analysis: `analysis/fusion_lab_l0_96.csv` / `.log`. deep_std(test) mean = 2.09yr.

### Sanity (vs morphometry): mean fusion reproduces the prior win
- mean(arith) vs morph: mean-LOCO 4.805→4.479, overall 4.523→4.201, p=1.4e-50,
  5 WIN / 1 tie / 0 loss. (Consistent with EXP-011e at 96³.)

### Novelty bar (vs simple mean): NO combiner beats the mean — clean NEGATIVE
| combiner | overall Δ vs mean | overall p | per-cohort |
|---|---|---|---|
| precision_subj (uncertainty-weighted, **no label fit**) | −0.016 | **0.93** | 0 win / 5 tie / 1 loss |
| geometric / harmonic (parameter-free) | ≈−0.001 | — | ≈ mean (noise) |
| BLUE_global (inverse-variance) | −0.207 | 1.3e-21 | 0 win / 2 tie / **4 loss** |
| ridge_stack_nn | −0.109 | 7.2e-5 | 3 win / 3 loss (A4 −0.75 = overfit) |
| age_cond_BLUE | −0.207 | 1.5e-21 | **4 loss** |
| biascorr_mean | −1.520 | 3.1e-185 | catastrophic loss |

**Conclusion (honest):** The cross-cohort fusion gain is **pure ensemble variance
reduction**, not a learnable/adaptive combiner. Even the unbiased adaptive combiner
(precision_subj, no label fit) is statistically indistinguishable from the simple
mean. Every label-fitted/adaptive combiner OVERFITS the source cohorts and loses
under LOCO. This is a NEGATIVE for method-novelty (the "uncertainty-weighted
fusion" hook is dead), but a real empirical fact: under domain shift, the within-
cohort wisdom "stacking > averaging" (Couvy-Duchesne) REVERSES.

**Caveats (no overselling):** (1) fitted combiners carry the in-sample-train
handicap (audit Q3) — their losses are partly self-inflicted; the decisive clean
evidence is precision_subj's TIE. (2) cudnn nondeterminism in deep_std (audit H-1)
— exploration-grade, not reproducible-grade. (3) NOT yet repeated with OOF train
preds for the fitted combiners.

### Verdict for this experiment: ❌ no method novelty. → pivot (see below).
λ=1 (GRL ablation) wave running; biomarker-gap direction scoped separately.
