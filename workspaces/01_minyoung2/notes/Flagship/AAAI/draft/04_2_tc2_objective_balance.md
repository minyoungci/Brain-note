# 4.2 TC2 — Objective Balance and Rank (results)

> DRAFT — all numbers from `results/table_c2_objective_balance.csv` (program-extracted, independently audit-verified).
> Evidence is internal; external replication is `[EXTERNAL-PENDING]` (§4.4).

**Setup.** From a single pretraining recipe we train three checkpoints differing only in the dense/global weight,
`w_global ∈ {0, 0.5, 1}` (denoted pure / balanced / global-heavy), all to 150k steps (matched). We freeze each
encoder and fit a probe on the global vector, comparing against a **matched random-init encoder of the same
architecture** (recipe-, crop-, and subject-matched; the projection head dimension does not affect the probe, which
reads the pre-projection vector — verified in code). We report Pearson `r` for brain-age regression with
per-subject bootstrap 95% CIs, on `n=494` subject-disjoint subjects.

**Brain age shows an inverted-U in the dense/global balance.**

| w_global | brain age Pearson r | 95% CI | Δ over random | RankMe |
|---|---:|---|---:|---:|
| random | 0.137 | [0.042, 0.222] | — | — |
| 0 (pure dense) | 0.599 | [0.540, 0.656] | +0.462 | 14.86 |
| **0.5 (balanced)** | **0.792** | **[0.762, 0.819]** | **+0.656** | 12.93 |
| 1 (global-heavy) | 0.683 | [0.632, 0.722] | +0.547 | 11.65 |

The balanced checkpoint is the **peak**, and its CI lower bound (0.762) lies strictly above the upper bounds of
both neighbors (pure 0.656; global-heavy 0.722) — i.e. the peak is CI-separated on both sides, not a tie. The
random-encoder floor is low (0.137), so the gains are not a site/position shortcut artifact (contrast with
classification probes, where random encoders score high; see §4.4 / shortcut control).

**A two-force account; rank explains only the down-arm.** RankMe decreases monotonically with `w_global`
(14.86 → 12.93 → 11.65), whereas transfer is non-monotonic. On the **up-arm** (pure → balanced) rank *drops* while
transfer *rises*, so rank alone cannot explain the peak: the semantic information injected by the global objective
outweighs the rank loss until the balance point. On the **down-arm** (balanced → global-heavy) the continuing rank
collapse dominates and transfer falls. The optimum is where the two forces balance; rank decline is a partial,
down-arm mechanism, not a full explanation. (No ResEnc checkpoint approaches the collapse threshold RankMe<4;
this is graceful compression, not collapse.)

**Selection criterion.** Because the balance optimum is visible in the rank/transfer trade-off, `w_global=0.5`
is selectable as the deployment checkpoint without task labels driving the choice.

**Scope (honest).** This inverted-U is established on a single internal brain-age task; we do **not** claim
absolute state-of-the-art brain-age prediction here (a morphometry baseline test is pre-registered, §4.4 / H5).
Auxiliary internal probes are reported conservatively: a polymicrogyria classification probe increases
*monotonically* with `w_global` (0.793 → 0.957 → 0.984) and carries a site floor, so it is reported only as
Δ-over-random and **not** as peak evidence; an infarct probe (`n=21`, all CIs spanning chance) is **excluded**.
External, multi-site, cross-continent replication of the inverted-U — the load-bearing test for generality — is
`[EXTERNAL-PENDING]` (§4.4, pre-registered in `docs/07`).
