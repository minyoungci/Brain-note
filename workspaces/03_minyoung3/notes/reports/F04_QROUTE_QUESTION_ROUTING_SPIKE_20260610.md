# F04 Q-ROUTE: Question-Conditioned Multi-ROI Routing Spike

Updated: 2026-06-10

## Goal

Test whether a question-conditioned multi-ROI routing module is a defensible
ACCV-level method contribution on top of the 3D ROI-grounded VQA task, or whether
the gain over baselines comes only from adding crops. Decision is made against the
naive multi-crop concat baseline (B2), not against fixed 2.5D.

Input policy unchanged: model inputs are image tensors plus question id only.
consortium / diagnosis / CDR / age / sex / ROI values / percentiles are NOT model
inputs. Oracle routing uses only the question id (an allowed input), so it is a
legitimate model, not leakage.

## Setup

- script: `scripts/run_f04_v6_qroute_spike.py`
- protocol: AJU LOCO (exclude AJU from train/val; test = AJU test-split rows)
- rows train/val/test: 11,528 / 2,454 / 340 (124 AJU subjects); subject leakage 0
- experts / caches (all 100% QA coverage):
  - global 64^3  `20260603_051311_v6_3d_global_lowres_cache_full64`
  - mtl 80^3     `20260604_130651_v6_3d_mtl_bilateral_crop_cache_full80`
  - roi-union(MTL+vent) 80^3 `20260604_164419_v6_3d_roiunion_mtl_vent_finalgrid_fixedcenter_cache_full80`
- encoders trained from scratch (identical init across variants); bf16; 8 epochs; seed 20260610
- primary metric: macro AUC (mean per-question AUC). Pooled AUC mixes 4 heterogeneous
  questions and was unstable across epochs, so macro is the honest primary.

## Variants

- B1: global + mtl pooled late-fusion (2 experts; current-arch baseline)
- B2: global + mtl + roi pooled concat (3 experts, NO routing) — anchor
- B5: token-bank cross-attention where the readout REPLACES direct features (bottleneck)
- B5r: B5 with residual readout (keeps B2 concat, ADDS routed readout); learned soft gate
- B5r_oracle: B5r with gate hard-fixed to the anatomical prior
  (hippocampal/MTL -> mtl crop; ratio/ventricle -> roi-union crop)

## Results (AJU LOCO test, macro AUC primary)

| variant | macro AUC | pooled AUC | hippo | ratio | MTL | vent | learned gate |
|---|---:|---:|---:|---:|---:|---:|---|
| B1 global+mtl | 0.766 | 0.746 | 0.615 | 0.882 | 0.624 | 0.944 | — |
| B2 concat (anchor) | 0.821 | 0.808 | 0.712 | 0.925 | 0.720 | 0.926 | — |
| B5 bottleneck | 0.744 | 0.739 | 0.558 | 0.865 | 0.602 | 0.952 | near-uniform |
| B5r residual + learned gate | 0.807 | 0.815 | 0.691 | 0.907 | 0.688 | 0.942 | collapsed to roi (~0.99) |
| **B5r_oracle** residual + anatomical gate | **0.859** | 0.825 | 0.766 | 0.917 | **0.820** | 0.935 | hard one-hot (correct) |

External reference (pretrained-frozen baseline, prior reports): AJU pooled 0.879,
macro ~0.883 (hip 0.808, ratio 0.924, MTL 0.858, vent 0.940). The from-scratch
encoders here underperform that baseline in absolute terms, which is expected and
held constant across variants.

## Causal diagnosis

1. The routing premise is correct. Oracle question->ROI routing beats the concat
   anchor by +0.038 macro, and the gain concentrates on the fine medial-temporal
   questions: MTL +0.100 (0.720 -> 0.820), hippocampal +0.054 (0.712 -> 0.766).
   Different questions genuinely benefit from being routed to different ROI crops.

2. The original B5 failure had two separable causes:
   - Design flaw (bottleneck): replacing direct MTL/ROI features with a single
     attention readout discarded strong signal. Fixed by the residual readout
     (B5 0.744 -> B5r 0.807).
   - Gate-learning failure: the free-form learned gate does NOT discover the correct
     per-question routing. It collapses to a single "safe" expert (roi-union, which
     contains MTL+vent), reaching only concat-level accuracy and losing MTL detail
     (MTL 0.688 vs oracle 0.820). Gate evolution shows progressive collapse to
     roi by epoch 4.

3. Therefore entropy / load-balancing regularizers are the wrong fix (the correct
   routing is per-question one-hot, not balanced). The correct fix is anatomy-prior
   gate supervision.

## Stage 1b: anatomy-supervised learned router

B5r with a gate CE loss toward the anatomical prior, lambda sweep 0.3 / 1.0.
The learned gate specializes to the correct one-hot routing (identical to the
oracle) by mid-training, confirmed on the held-out gate table.

| variant | macro AUC | gate at test | hippo | MTL | ratio | vent |
|---|---:|---|---:|---:|---:|---:|
| B2 concat | 0.821 | — | 0.712 | 0.720 | 0.925 | 0.926 |
| B5r unsupervised | 0.807 | collapsed to roi | 0.691 | 0.688 | 0.907 | 0.942 |
| B5r_oracle (hard) | 0.859 | correct one-hot | 0.766 | 0.820 | 0.917 | 0.935 |
| B5r sup lambda=0.3 | 0.801 | correct one-hot | 0.686 | 0.690 | 0.896 | 0.934 |
| B5r sup lambda=1.0 | 0.782 | correct one-hot | 0.648 | 0.649 | 0.886 | 0.946 |

Counter-intuitive key finding: the supervised gates converge to exactly the same
correct one-hot routing as the oracle, yet score much lower (0.80 / 0.78 vs 0.859).
Same routing, different accuracy. Furthermore, supervised "correct routing" (0.80)
is not better than unsupervised "wrong routing" / roi-collapse (0.807). Higher
lambda is worse (0.801 -> 0.782).

Interpretation: what matters is hard-fixing the routing from the start, not
learning it. A hard gate gives the encoders/head a stationary signal to co-adapt
to (answer loss only). A learned gate trains against a moving soft gate plus a
competing CE objective, landing in a worse optimum even when the final routing is
identical. The gate-learning attempts therefore degrade the answer task.

Conclusion: the method is the HARD anatomical question->ROI router (B5r_oracle,
0.859), which is legitimate because the gate is a deterministic function of the
question id (an allowed input). The two gate-learning attempts are retained as
informative negatives (free-form collapse; supervised answer-task degradation).

## Forward plan

Method selected: hard anatomical question->ROI router (B5r_oracle architecture),
macro 0.859 vs concat 0.821 (+0.038), fine MTL +0.100. Gate-learning attempts are
reported as negatives.

- Stage 2 (next): confirm and strengthen for a paper.
  1. 80^3 contrastive-pretrained encoder init (re-pretrain mtl80 / roi80 with the
     existing `run_f04_v6_mtl_contrastive_pretrain.py`; global64 init exists).
     From-scratch oracle 0.859 already approaches the pretrained baseline macro
     ~0.883, so pretrained init should push above the baseline.
  2. Multi-seed (>=3) to remove the single-seed + volatile-pooled-val-selection
     confound, reported with subject-level bootstrap vs B2 and vs the pretrained
     baseline.
  3. Multi-cohort LOCO (OASIS, NACC in addition to AJU) for a generalization claim.
  4. Switch primary checkpoint selection to macro (or per-question) val AUC; pooled
     val AUC is too volatile.
- Optional polish: a decoupled learned router (CE trains only the gate params,
  stop-grad to the answer encoders) to present a learned router that matches the
  hard router without degrading the answer task.
- Question/ROI expansion (later): more anatomical questions and ROI experts make the
  routing table richer and the contribution less "hand-specified".

## Caveats

- Single seed; from-scratch encoders; pooled AUC volatile across epochs.
- Best checkpoint selected by val pooled AUC (same rule for all variants).
- 4 questions only; routing is over 3 experts. Multi-seed/cohort replication
  required before any method claim.

## Stage 2 update (2026-06-10): multi-seed confirmation DEFLATES the routing win

Re-ran B2 and B5r_oracle with macro-AUC checkpoint selection (pooled is too
volatile) across seeds 20260610/11/12.

| seed | B2 macro | oracle macro | delta | subject bootstrap P(delta>0) |
|---|---:|---:|---:|---:|
| 20260610 | 0.821 | 0.823 | +0.002 | 0.54 |
| 20260611 | 0.837 | 0.843 | +0.006 | 0.62 |
| 20260612 | 0.789 | 0.839 | +0.050 | 0.99 |
| mean | 0.815 +/- 0.020 | 0.835 +/- 0.008 | +0.019 | significant in 1/3 |

Findings:

- The Stage-1 single-seed +0.038 (oracle 0.859) did NOT replicate. With macro
  selection the same seed-10 oracle is 0.823 (not 0.859): the 0.859 was an
  artifact of a lucky volatile pooled-val checkpoint.
- Across 3 seeds the oracle advantage is mean +0.019 and bootstrap-significant in
  only 1 of 3 seeds; the large seed-12 gap is driven by B2 variance (B2 0.789),
  not a stable oracle win.
- The real, robust effect of routing is variance reduction (oracle std 0.008 vs
  B2 0.020), not mean accuracy.

Revised conclusion:

- Hard anatomical routing does NOT robustly beat the concat baseline on mean
  accuracy. Routing is demoted from "the method" to a stability/analysis result.
- The robust positive finding is adding the high-resolution multi-ROI (roi-union
  80^3) crop expert: B1 0.766 -> B2 ~0.815 (~+0.05 macro). This is the foundation
  to build on.
- From-scratch encoders are noise-limited (B2 std 0.020) which buries any
  architectural module effect. A stable base (pretrained encoders) is needed to
  fairly evaluate novelty modules.

## Direction after deflation (paper plan)

Novelty axes that do NOT depend on the fragile routing win:

- Relational cross-ROI reasoning (variant B2rel): learned relation embedding over
  the hippo(mtl) and ventricle(roi) experts, motivated by the
  hippocampus-to-ventricle ratio question. Running 3 seeds vs B2.
- Learned question-conditioned 3D evidence localization with weak ROI-mask
  supervision (interpretability-justified, not accuracy-justified).

B1->B2 high-res ROI gain is being confirmed across 3 seeds as the foundation.
