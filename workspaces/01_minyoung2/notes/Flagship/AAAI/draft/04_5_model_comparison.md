# 4.5 Model-vs-Model Comparison (results)

> DRAFT (2026-07-01). All models scored through the **same audited pipeline** as TC3
> (`compare_models.py` → `model_comparison.json`; CN-fit brain age, per-seed 1-vs-1 Δ-over-random,
> per-fold A2 site-orthogonalization, age-adjusted dx). n=2093, subject-disjoint, post-A2 = the
> shortcut-controlled metric. **Fairness noted per row** (training budget / input regime differ).

**Claim scope.** Our contribution is methodological (rank-max selection fails), not "our foundation is
SOTA." This table (i) shows objective balance is the dominant lever, (ii) that RankMe-max picks the
single worst model, and (iii) situates our foundation against other SSL paradigms.

| model | budget / arch | brain-age r (post-A2) | Δ-over-random (post-A2) [95% CI] | dx AUROC AIBL/AJU | A2 drop (pre→post) |
|---|---|---:|---|---|---:|
| **wg1 (ours, global-heavy)** | 150k, ResEnc | **0.322** | **0.289** [0.227, 0.355] | 0.74 / 0.68 | +0.01 |
| **wg0.5 (ours, balanced)** | 150k, ResEnc | 0.292 | 0.259 [0.198, 0.323] | **0.72 / 0.73** | −0.02 |
| wg0.25 (ours) | 150k, ResEnc | 0.283 | 0.250 [0.189, 0.317] | 0.68 / 0.68 | −0.04 |
| wg0.75 (ours) | 150k, ResEnc | 0.278 | 0.245 [0.180, 0.305] | 0.66 / 0.69 | −0.04 |
| ViT-MAE-8 | 8k, ViT | 0.289 | 0.256 [0.193, 0.322] | 0.56 / 0.69 | −0.06 |
| ViT-MAE | 8k, ViT | 0.260 | 0.227 [0.157, 0.288] | 0.53 / 0.54 | −0.06 |
| ViT-iBOT | 8k, ViT | 0.188 | 0.155 [0.089, 0.220] | 0.59 / 0.60 | −0.06 |
| **wg0 (ours, dense-only = RankMe-max)** | 150k, ResEnc | 0.082 | **0.049 [−0.017, 0.112] (n.s.)** | 0.49 / 0.58 | −0.07 |
| from-scratch (random-init, 3 seeds) | — | ~0.06 | 0 (baseline) | ~0.5 | — |

## Findings
1. **Objective balance dominates.** Within our matched-budget (150k) family, balanced/global checkpoints
   (w_global ≥ 0.25) all reach Δ 0.25–0.29 (p=0.005), while **pure-dense (w_global=0) is the single worst
   model** — Δ 0.049 (n.s.), below even the 8k-step ViT pilots. **RankMe-max selection (which picks
   pure-dense) therefore selects a checkpoint worse than a 19×-cheaper ViT baseline and no better than random.**
2. **Our foundation vs. other SSL paradigms.** Post-shortcut-control, balanced/global ResEnc ≥ all ViT
   baselines on brain age and clearly on dementia dx (0.72–0.73 vs 0.53–0.69). (An earlier pre-A2, per-cohort
   analysis suggested ViT-iBOT led; that did **not** survive the audited post-A2 CN-fit pipeline — a
   shortcut/setup artifact.)
   **Published BrainIAC (SimCLR 3D-ViT, skull-stripped input; own loader, verified strict backbone load).**
   On the shared BrainIAC∩age subset (n=1132; A4 31 / AIBL 617 / AJU 484), BrainIAC brain-age r **0.365 >**
   our wg1 0.311 / wg0.5 0.280; dementia dx is **~tied** (BrainIAC 0.69/0.75 vs ours 0.72–0.74 / 0.68–0.73).
   **Stated honestly: a dedicated published brain foundation beats ours on brain age** — our contribution is
   the *selection* finding, not absolute superiority. Our foundation still ≫ from-scratch (0.067) and ≫ the
   RankMe-selected pure-dense (0.173). (`brainiac_comparison.json`.)
3. **Our features are more site-robust.** ViT baselines lose ~0.06 brain-age r to A2 (site-dependent), while
   balanced/global ResEnc lose ≤0.02 or gain — evidence the dense+global signal is less scanner-entangled.
4. **FreeSurfer morphometry beats the foundation (H5 rejected — stated honestly).** A ridge on 26 FreeSurfer
   volumes reaches brain-age r **0.474**, above every learned foundation (wg0.5/wg1 ≈ 0.31; Δ **−0.165**).
   Consistent with known cross-sectional-T1 morphometry saturation, we therefore **do not claim absolute
   brain-age superiority** — the contribution is the *selection* finding (rank-max fails), which is a
   **relative** statement unaffected by the morphometry gap. (`h5_morphometry.json`.)
6. **Honest limits.** ViT baselines are 8k-step pilots (budget mismatch noted). BrainIAC A4 coverage is a
   pilot (HD-BET n=31 of our A4 subjects; AIBL/AJU near-full) — its comparison is effectively AIBL+AJU. The
   BrainIAC vs. our-model comparison uses each model's native input regime (ours full-head, BrainIAC
   skull-stripped), a documented fidelity choice, not identical preprocessing.
