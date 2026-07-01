# STATUS & ROADMAP (official repo)

Last updated: 2026-07-01. Confirmed content is in this repo; the working repo (`/home/vlm/minyoung2`)
holds in-progress/conditional work until it is verified and migrated here.

## Confirmed (in this repo)
| Item | Evidence |
|---|---|
| Foundation spec + 5 checkpoints + z-norm input + InfoNCE global | `pretrain/`, `draft/03_method.md` |
| Leakage DISJOINT (A4/AIBL/AJU vs 226,793) | `results/external_eval/LEAKAGE_CHECK.md` |
| TC1 protocol-adaptive transfer (Δ+0.134, gap +0.101) | `results/ablation_registry.csv`, draft |
| TC2 FINDING (rank–transfer decoupling; RankMe-max picks worst) | `results/tc2_labelfree_selection/`, `table_c2_objective_balance.csv`, `collapse_diagnostics.*` |
| TC2 selector METHOD = NO-GO (honest open problem) | `results/tc2_labelfree_selection/phase1_5point.json` |
| External label table (brain-age 2093, dx, morphometry) | `results/external_eval/labels/` |

## Roadmap (pending — migrates here once confirmed)

**1. TC3 external — fix batch (critic-conditional → confirm).** Core ("RankMe-max selects worst,
regret ~0.2, 3 external cohorts, post-scanner-A2") is real; before it is *official* it needs:
- **F2** ≥3 matched random-init seeds (currently 1).
- **F3/M5** paired-Δ bootstrap + BCa CI + Holm; **reframe to regret** (not "= random" — per-cohort wg0 is
  above random in A4/AIBL, below in AJU).
- **M1** nonlinear (MLP) post-A2 site probe (linear→chance is partly tautological): decides "site-invariant"
  vs "held-out-site transfer."
- **M2** external RankMe argmax = wg0 (already confirmed: 255.6 max) — write up.
- **M4** dx → secondary (add AUROC bootstrap CI; cross-cohort AIBL↔AJU weak; ADNI→KDRC/AJU co-primary needs
  those cohorts preprocessed).

**2. Baselines.** from-scratch (random-init) + **BrainJEPA** (local, external-eval cache exists) + internal
ViT-MAE; **BrainIAC** if obtainable (not local — web/HF acquisition, else JEPA suffices).

**3. External validation (cognitive-impairment).** A4/AIBL/AJU at `/home/vlm/data/preprocessed`
(FastSurfer-processed) — brain-age + CN/MCI/AD, shortcut-controlled (`docs/07`).

**4. FastSurfer ROI dense-seg (TC2 selector rescue, upside).** `docs/10` pre-registration; blocked on the
seg-alignment QC gate (provisional/BLOCKED on disk).

## Scoping (critic M6)
Claims are scoped to **"dense+global 3D brain-MRI SSL"** — single backbone (ResEnc+S3D); we do not claim a
general law. A second global objective / JEPA reproduction would strengthen generality (deferred).
