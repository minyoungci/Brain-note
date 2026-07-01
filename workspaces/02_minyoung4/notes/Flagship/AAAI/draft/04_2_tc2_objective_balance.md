# 4.2 TC2 — Objective Balance and Rank (results)

> DRAFT (revised 2026-07-01 after 5-point grid + research-critic adjudication).
> Numbers: 3-point CIs from `results/table_c2_objective_balance.csv`; 5-point point estimates from
> `results/tc2_labelfree_selection/phase1_5point.json` (program-extracted, audit-verified).
> Evidence is internal; external replication is `[EXTERNAL-PENDING]` (§4.4).

**Setup.** From a single pretraining recipe we train **five** checkpoints differing only in the dense/global
weight, `w_global ∈ {0, 0.25, 0.5, 0.75, 1}`, all to 150k steps (matched). We freeze each encoder and fit a probe
on the global vector, comparing against a **matched random-init encoder of the same architecture**. We report
Pearson `r` for brain-age regression on `n=494` subject-disjoint subjects.

**Brain age shows an inverted-U in the dense/global balance — but the interior is a plateau, not a sharp peak.**

| w_global | brain age Pearson r | 95% CI | Δ over random | RankMe (train) |
|---|---:|---|---:|---:|
| random | 0.137 | [0.042, 0.222] | — | — |
| 0 (pure dense) | 0.599 | [0.540, 0.656] | +0.462 | 14.86 |
| 0.25 | 0.774 | `[VERIFY — bootstrap TODO]` | +0.636 | — |
| **0.5 (balanced)** | **0.792** | **[0.762, 0.819]** | **+0.655** | 12.93 |
| 0.75 | 0.768 | `[VERIFY — bootstrap TODO]` | +0.630 | — |
| 1 (global-heavy) | 0.683 | [0.632, 0.722] | +0.547 | 11.65 |

The balance point (0.5) is the argmax, but on the finer grid its **immediate neighbors** wg0.25 (0.774) and wg0.75
(0.768) fall **inside** the wg0.5 CI [0.762, 0.819]: the interior triplet {0.25, 0.5, 0.75} is a statistical
**plateau**. Only the **endpoints** (pure 0.599; global-heavy 0.683) are CI-separated from the peak. Thus the grid
resolves *"endpoints vs. interior,"* not a precise optimum location. (Per-point and paired-regret bootstrap CIs are
being computed from the cached features to confirm the plateau; the two-sided CI-separation claim of the earlier
3-point draft is **retracted** — it held only because the coarse grid lacked interior neighbors.) The random floor
is low (0.137), so the interior gains are not a site/position artifact (contrast classification probes, §4.4).

**A two-force account; rank explains only the down-arm.** RankMe decreases monotonically with `w_global`
(14.86 → 12.93 → 11.65). On the **up-arm** (pure → balanced) rank *drops* while transfer *rises*, so rank alone
cannot explain the interior optimum; on the **down-arm** the continuing rank decline co-moves with falling transfer.
No ResEnc checkpoint approaches collapse (RankMe<4) — graceful compression, not collapse.

**Finding: rank-based label-free selection fails — and no tested criterion reliably locates the optimum.**
This is the technical contribution, stated without overclaim.
- **Rank-maximization selection is catastrophic.** A selector that picks the checkpoint of maximum effective rank
  (RankMe-style) chooses **wg0** (pure dense) — the *worst* checkpoint: r=0.599 vs the optimum 0.792, a **regret of
  0.194** (~4 SE; CI-separated). Effective rank, participation ratio, and stable rank are all monotone in
  `w_global` and select the same wrong endpoint. This is a concrete, non-obvious caution for RankMe-based checkpoint
  selection under dense/global objective balancing.
- **No robust label-free selector on current evidence (open problem).** We screened a pre-registered battery of
  label-free criteria (candidates: α-ReQ, EVR-top10, cluster silhouette; also uniformity). Under the pre-registered
  argmax-coincidence gate (`phase0_labelfree_screen.py::analyze`), **DECISION = NO-GO**: none locates the interior
  optimum. α-ReQ — which appeared to peak at the balance point on a coarse 3-point grid — mislocates to **wg0.25** on
  the finer grid (a coarse-grid artifact), and its regret (0.019) is (i) within noise (Δr≈0.4 SE) and (ii) **worse
  than the trivial "pick the grid midpoint" default** (regret 0.000), which is itself confounded here because the
  optimum coincides with the grid center. Post-hoc promotion of any single non-registered metric (e.g. uniformity)
  is a multiple-comparison artifact and is not claimed.

**Scope (honest) and the load-bearing next test.** The interior optimum is established on a **single** internal
brain-age task; the "rank fails" caution *presumes* the inverted-U exists (if external transfer is monotone, rank
does not mis-select). Two tests are therefore load-bearing: (1) a **dense/segmentation task whose optimum is
plausibly off-center** (breaking the grid-midpoint confound and giving a second task) — pre-registered as the
selector's decisive test; (2) external, multi-site replication of the inverted-U itself (§4.4, `docs/07`).
Auxiliary internal probes remain conservative: polymicrogyria increases *monotonically* (site floor; Δ-only),
infarct (`n=21`) is excluded.
