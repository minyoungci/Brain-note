# Sprint-2 scaled rigor-control — RESULT (honest, 2026-06-22)

Scaled to **1022 findings / 412 artifacts** (3 endpoints × 65 feature-families × LOO-CV over 6 cohorts + graded
planted controls). Pre-registered question: does the deterministic controller beat naive significance-thresholding
on artifact detection? **Answer: only on PLANTED (synthetic) controls — NOT on real findings.** No spin.

## Headline
| set | controller F1 [95% CI] | naive F1 [95% CI] | verdict |
|---|---|---|---|
| PLANTED (n=112, 56 artifact) | **0.926 [0.871, 0.967]** | 0.250 [0.128, 0.370] | controller dominates (CIs disjoint) |
| REAL (n=910, 356 artifact) | 0.830 [0.800, 0.858] | 0.836 [0.809, 0.863] | **TIE** (CIs overlap; naive acc 0.869 ≥ controller 0.858) |

## Diagnosis (slice of the 1022)
- naive-failure zone in REAL (high disc≥0.6 but truly artifact) = **54 findings**; controller rescues **31/54 = 57%**
  (not dominant). By family (real): raw 0.835 vs naive 0.852 · icv 0.819 vs 0.827 · asym 0.984 vs 0.989 — naive ≥
  controller everywhere.
- **Root cause:** for real ROI features, discovery-AUROC and cross-cohort replication are *correlated* (genuinely
  strong regions replicate; weak ones don't), so naive disc-thresholding already predicts replication. The
  controller's extra signals (replication tool, covariate-incremental) add value ONLY for *decoupled* findings
  (high disc, no replication = confounds) — which had to be PLANTED because they are rare among real ROI features.
- Threshold tuning cannot fix this: it trades recall↔precision on a correlated signal (no Pareto win).

## This is the 4th consistent negative/sobering signal
1. ClaimTrap-AD: controller does not beat the checklist prompt on completeness (trade-off).
2. E1: open models over-claim (problem exists) — but that only motivates, doesn't make a method win.
3. D3: LLM-as-decider over-kills; verifiers make it worse.
4. Sprint-2: deterministic controller ties naive on real data (wins only on planted synthetics).
**Pattern: the rigor/safety-control contributions do not beat simple baselines on real data.** Structural, not a
tuning gap.

## What IS real here (salvageable, honest findings — not a "strong agent paper")
- A clean **multi-cohort replication benchmark with graded planted controls** that *quantifies* the confound-failure
  mode: naive significance-thresholding F1=0.25 on planted site-confounds; a replication+covariate controller F1=0.93.
  (methods/benchmark contribution; real-data null must be reported alongside.)
- The empirical result that **discovery-AUROC predicts cross-cohort replication for AD ROI features** (so naive
  significance is adequate on typical findings; rigor matters only against adversarial confounds). Useful negative
  result for the neuroimaging-reproducibility community.

## Honest strategic read
With this data, the "rigor-control agent/system beats baselines on real neuroimaging findings" thesis is **not
supported**. The defensible outputs are modest methods/negative-result contributions (clinical/methods venue), not
a top-tier agent paper. Decide: (a) reframe to the honest modest findings, (b) change the data/problem so the
controller's edge is not washed out by the disc↔replication correlation, or (c) step back and reconsider the line.
