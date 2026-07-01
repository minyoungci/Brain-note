# 4.4 TC3 — Shortcut-Controlled External Validation (results)

> DRAFT (2026-07-01, **code-audited**: `analyze_external_v2.py`, no critical bugs; W1 per-seed 1-vs-1
> baseline + W2 per-fold site-probe A2 applied). Numbers from `results/external_eval/external_analysis_v2.json`.
> CI = paired subject bootstrap 2000 (BCa on the post-A2 primary); Holm-corrected over the wg×{pre,post} grid.
> H4 status: ADNI preprocessed (2026-07-01, FOMO yucca4, DISJOINT) → cross-cohort ADNI→AJU/AIBL done. KDRC leg pending (data re-transfer).

**Setup.** Three external cohorts — A4 (992), AIBL (617), AJU (484); pooled **n=2093**, one scan/subject
(subject-disjoint CV), **4-level DISJOINT** from FOMO300K. Frozen global vector (z-normalized input, identical
to pretraining), linear probe. Brain age = **CN-only fit** ridge (fit on cognitively-normal, applied to all).
Baseline = **matched random-init encoder, 3 seeds** (per-seed 1-vs-1). **A2** removes the site subspace
(cohort⊕scanner cell means, fit per training fold, nested — no leakage).

## Brain-age transfer: pure-dense is site-driven; balanced/global survive shortcut control

Paired Δ over matched random-init (model r − random r), Holm-adjusted p:

| w_global | pre-A2 Δ [95% CI] (p) | post-A2 Δ [95% CI, BCa] (p) |
|---|---|---|
| **0 (pure dense)** | 0.072 [0.012, 0.129] (p=0.026) | **0.049 [−0.017, 0.112] (p=0.13 — n.s.)** |
| 0.25 | 0.241 [0.188, 0.298] (0.005) | 0.250 [0.189, 0.317] (0.005) |
| 0.5 | 0.229 [0.175, 0.284] (0.005) | 0.259 [0.198, 0.323] (0.005) |
| 0.75 | 0.242 [0.185, 0.296] (0.005) | 0.245 [0.180, 0.305] (0.005) |
| 1 (global-heavy) | 0.228 [0.173, 0.284] (0.005) | 0.289 [0.227, 0.355] (0.005) |

- **Pure-dense (w_global=0) is the RankMe-argmax checkpoint** — effective rank (RankMe) computed **on the external
  features** is maximal at w_global=0 (255.6 vs 51.6/27.8/20.3/16.0 for 0.25→1; random 195.3). A RankMe-max
  selector therefore picks pure-dense in the deployment domain.
- **After scanner-shortcut orthogonalization (A2), pure-dense transfer is indistinguishable from a random-init
  encoder** (Δ 0.049, CI includes 0, p=0.13). Its small pre-A2 edge (Δ 0.072) is site-driven. In contrast, **every
  balanced/global checkpoint retains large, significant transfer** (Δ 0.23–0.29, p=0.005, CI excludes 0, pre & post).
- **Selection consequence (regret framing):** RankMe-max selects the checkpoint with the **worst** shortcut-controlled
  transfer — regret ≈ 0.20 (post-A2 r 0.083 vs the balanced ~0.29), i.e. no better than random after site control.

**Scanner shortcut is real but the transfer is not explained by it.** Scanner decodability from the frozen
features (balanced accuracy, chance 0.25): linear probe **0.84 → 0.25** after per-fold A2; nonlinear MLP probe
**0.70 → 0.47**. A2 removes *linear* scanner structure to chance, but a **nonlinear** scanner signature persists
(0.47 > the pre-registered 0.35 threshold). We therefore scope the claim to **"transfers on held-out site,"** not
scanner-invariance (per `docs/07` H3).

## Dementia classification: same failure pattern + cross-continent transfer (H4)

CN-vs-AD, age-adjusted AUROC [95% CI] (features residualized against age, train-only):

| w_global | AIBL | AJU |
|---|---|---|
| **0 (pure dense)** | 0.489 [.42,.56] | 0.581 [.50,.66] |
| 0.5 | 0.722 [.66,.78] | 0.725 [.65,.80] |
| 1 | 0.735 [.67,.80] | 0.677 [.61,.76] |

Pure-dense is at chance (CI spans 0.5); balanced/global reach ~0.72 (CI excludes 0.5). Same rank-failure pattern
as brain age.

**Cross-cohort dementia transfer works (H4 co-primary — ADNI added, 2026-07-01).** Fitting CN-vs-AD on **ADNI**
(n=964; 840 CN / 124 AD) and testing **cross-continent**, age-adjusted AUROC reaches **ADNI→AJU (US→Korea) 0.71
[0.63,0.77]** (wg0.5) and **ADNI→AIBL (US→Australia) 0.71 [0.65,0.78]** (wg1) — CI excludes 0.5: foundation
dementia signal transfers across scanner, population, and continent. **Rank-failure replicates on this third
axis:** pure-dense (RankMe pick) is at chance (ADNI→AIBL 0.50, ADNI→AJU 0.57 ≈ random 0.51/0.58). ADNI
within-cohort brain-age is also strong (wg0.5 r=0.42 vs pure-dense 0.16). (`adni_downstream.json`.) **Remaining:**
ADNI→KDRC leg pending KDRC data (re-transfer in progress); direct AIBL↔AJU cross-cohort stays weak (0.49–0.71,
population/label heterogeneity) — dementia transfer is anchored on ADNI-as-source.

## H2 (inverted-U) not replicated externally
The internal sharp inverted-U (down-arm at w_global=1) does not appear externally — {0.25,…,1} form a plateau,
only pure-dense is deficient. The "interior optimum / balance-selection" framing is **internal-only** and retracted
for the external claim.

## Settled external claim
Under scanner-shortcut control, across two task families and three external cohorts, **RankMe-style
rank-maximization selection picks pure-dense — whose shortcut-controlled transfer is indistinguishable from a
random-init encoder** (regret ≈ 0.2 vs. balanced/global). Scoped to dense+global 3D brain-MRI SSL; transfer is on
held-out site (nonlinear scanner residual remains). **Open:** ADNI→KDRC leg (KDRC data pending); single backbone (model-vs-model
comparison in §4.5).
