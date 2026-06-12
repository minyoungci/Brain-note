# Study Protocol — Adaptation of a 3D Brain-MRI Foundation Model under Site Shift
*(NeuroImage-targeted; living protocol. Numbers = measured unless marked planned.)*

## Working title
**"How you adapt matters: a multi-cohort study of fine-tuning vs. frozen brain-MRI
foundation features, and the transfer–site-invariance trade-off they impose."**

## 1. Motivation & thesis
3D brain-MRI foundation models (e.g., BrainIAC, *Nat. Neurosci.* 2026) are increasingly
adopted, but two assumptions are untested at the multi-cohort level:
(i) that **frozen features** faithfully represent the model's value, and
(ii) that **pretraining improves robustness to scanner/site**.
We test both on a 7-consortium leave-one-cohort-out (LOCO) benchmark with leakage control.

**Central thesis (the contribution):** Multi-site SSL pretraining injects **age-independent
site information** into the representation that fine-tuning retains, producing a
**transfer ↔ site-invariance trade-off**; the standard frozen-probe evaluation obscures this.
Whether the trade-off is *mitigable* (site-adversarial adaptation) or *fundamental* is the
study's decisive question.

## 2. Data
- Source: `official_manifest_full_n4_real_final.csv` — 12,840 QC-PASS T1w (age available),
  7 consortia: ADNI, NACC, A4, OASIS, AIBL, AJU, KDRC.
- Preprocessing: HD-BET brain extraction → 1mm RAS → 192³ → N4 → z-score; resized 96³ +
  intensity-normalized for the model (matches BrainIAC transform). Subject-level splits.
- **Leakage map** (vs public-foundation pretraining): AJU·KDRC = **CLEAN** (Korean, not in
  public corpora) → used as held-out for task probes. ADNI/OASIS/AIBL = likely-leaked,
  NACC/A4 = uncertain → used only in training pool / site-probe. *Must-have: cross-check
  against BrainIAC pretraining dataset list (Appendix table).* [planned]
- Tasks: **brain-age** (regression, all cohorts) and **CN-vs-AD** (CN/preclinical vs AD/Dementia;
  KDRC 282/249, the balanced clean held-out).

## 3. Foundation model
BrainIAC: SimCLR-pretrained 3D ViT-B (12 layers, hidden 768, patch 16³), ~35 datasets.
CC BY-NC. Frozen-feature audit reproduced exactly (site-probe 0.842 / brain-age 5.73 /
CN-AD 0.735), confirming a faithful re-implementation.

## 4. Methods — adaptation ladder
Same backbone + a linear head, under increasing adaptation:
| mode | backbone | trainable |
|---|---|---|
| frozen | frozen | head only (0.0M) |
| partial | last 4 ViT blocks + norm | 28.3M |
| full | all | 88.3M |
| scratch | random init, all | 88.3M (no pretraining; lower bound on "foundation value") |
| **+LP-FT** | linear-probe then fine-tune | *[planned — Kumar et al. ICLR'22 rebuttal]* |

Training: AdamW, OneCycle, bf16, L1 (age) / BCE (CN-AD), grad-clip 5, best-by-val checkpoint.

## 5. Methods — evaluation axes (morphometry is a *reference*, not the yardstick)
1. **Transfer** = held-out-cohort MAE (age) / AUC (CN-AD), LOCO.
2. **Site-loading** = adapted CLS features → cohort 7-way macro-AUC (balanced 250/cohort).
   - **Age-confound control**: residualize age out of features (linear), re-probe; report
     feature→age R². *[planned: age/sex-matched site-AUC + nonlinear probe + chance level].*
3. **Mitigation** = site-adversarial fine-tuning (cohort head via Gradient Reversal, DANN
   ramp). Question: does it cut site-loading at fixed transfer? λ ∈ {0.3, 1.0}.

## 6. Results so far (measured; KDRC held-out unless noted)
**6.1 Adaptation ladder (3 seeds; mean±std)**
| mode | brain-age MAE↓ | CN-AD AUC↑ | site-AUC↓ |
|---|--:|--:|--:|
| frozen | 6.36 ± .02 | 0.734 ± .002 | ~0.76 |
| scratch | 5.79 ± .07 | 0.779 ± .034 | **~0.71** |
| **full** | **5.35 ± .04** | **0.800 ± .017** | ~0.76 |
- AJU held-out (brain-age, 3 seeds) reproduces direction: frozen 5.72 / scratch 5.70 / full 5.47.

**6.2 Findings**
- **F1 — frozen-probe misleads**: full ≫ frozen on both tasks (large, robust). The common
  frozen-only audit *understates* the model.
- **F2 — foundation value (full ≥ scratch)**: same direction on both tasks, but **modest** and
  noisier for CN-AD. (Single-seed "scratch wins CN-AD" was an outlier — killed at 3 seeds.)
- **F3 — pretraining injects age-independent site info**: scratch is consistently the least
  site-loaded; age-residualization barely changes site-AUC (full .749→.743, frozen .775→.775);
  frozen has high site (.775) yet low feature→age R² (.207) — clean evidence site ≠ age.
- **F4 — mitigation**: *[running — full+GRL λ=0.3/1.0, both tasks].*

## 7. Planned experiments (must-have status)
- [running] **Mitigation** (GRL) — decides journal tier + the "fundamental vs mitigable" question.
- [ ] **≥5 seeds** on the core comparisons (frozen/full/scratch ± GRL); paired seed tests, effect sizes.
- [ ] **LP-FT** baseline (reconcile Kumar et al. ICLR'22: FT can distort features OOD).
- [ ] **Site-metric robustness**: age/sex-matched cohort-AUC, nonlinear probe, chance control.
- [ ] **Second held-out** generality (AJU for CN-AD is CN-poor → report with caveat / add NACC fold).
- [ ] **Leakage appendix**: BrainIAC pretraining dataset cross-check table.
- [ ] **A second foundation** (brain2vec, Apache-2.0) to show generality. *(optional, strengthens)*

## 8. Statistical analysis plan
Per (mode, task, cohort): mean ± SD over ≥5 seeds; seed-paired Wilcoxon for mode contrasts;
report effect size (Δ years / ΔAUC) with 95% CI; Holm correction across the mode comparisons.
Site-AUC reported with permutation chance level.

## 9. Positioning / novelty (literature-scout)
- vs **BrainIAC (Nat. Neurosci. 2026)**: it reports frozen/FT/few-shot but **not** the LOCO
  site-loading trade-off nor age-controlled site analysis → our differentiator.
- vs **Kumar et al. (ICLR 2022)**: they show FT can underperform LP OOD; we find the opposite
  in this domain and condition it (large domain gap, supervised target) → contribution, not contradiction.
- vs harmonization literature (ComBat/DANN): we operate at the *foundation-adaptation* level,
  not post-hoc feature harmonization.
- F3 contests the prevailing "pretraining is scanner-robust" claim → the paper's edge.

## 10. Target venue
Primary: **NeuroImage** (multi-site, brain-age, scanner-effect home; report+analysis fits).
Stretch (if mitigation yields a working method): **Medical Image Analysis / IEEE TMI**.
Fallback: **Human Brain Mapping / Imaging Neuroscience**. Conference: **MICCAI/ISBI** (FOMO25 adjacent).
