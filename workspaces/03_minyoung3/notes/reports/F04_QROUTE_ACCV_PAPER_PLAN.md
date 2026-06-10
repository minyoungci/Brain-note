# F04 Q-ROUTE — ACCV Paper Plan

Updated: 2026-06-10 (living document; results placeholders filled as runs complete)

## Target

- Venue: ACCV (tier-2 CV; method + solid experiments + honest analysis is enough;
  no SOTA-over-morphometry requirement because the contribution is a VQA method,
  not a disease classifier).
- One-line framing: *question-conditioned ROI-grounded 3D MRI VQA — what kind of
  ROI conditioning actually helps, under strict multi-cohort LOCO.*

## Established facts (do not re-litigate)

- Task: image-only ROI-grounded normative-evidence VQA. Inputs = 3D image tensors +
  question id only. Shortcut-resistant matched benchmark: clinical-context AUC ~=
  chance (0.50-0.55), ROI-oracle = 1.0. 4 session questions, 1:1 balanced.
- Protocol: AJU LOCO (train/val exclude AJU; test = 340 AJU rows / 124 subjects),
  subject+session leakage 0. macro AUC is the primary metric (pooled is volatile).
- From-scratch multi-seed (macro-selected) results:
  - B1 global+mtl: 0.787 +/- 0.017
  - B2 +roi-union concat: 0.815 +/- 0.020  (B2 > B1 mean +0.028, sig 1/3 seeds)
  - B5r_oracle hard routing: 0.835 +/- 0.008 (vs B2 +0.019, sig 1/3 seeds; lower variance)
  - B2rel relational: 0.788 +/- 0.034 (WORSE than B2; no ratio-question gain)
- Key negative finding: on from-scratch encoders the noise floor (std 0.02-0.03)
  exceeds module effect sizes (0.02-0.05). No architectural module robustly beats
  the concat baseline. Pretrained encoders are a prerequisite for fair evaluation.
- Routing analysis (reusable result): free-form learned gate collapses to a single
  safe expert; gate CE supervision recovers correct routing but a competing loss
  degrades the answer task; hard anatomical routing trains cleanest. "Hard-from-start
  beats learned routing even at identical final routing."

## Decision pending pretrained base

Re-run all variants with frozen contrastive-pretrained encoders (LOCO-safe, AJU
excluded from SSL), 3 seeds. This decides the paper's spine:

- If a module (oracle routing / relational / localization) robustly beats B2 on the
  stable base -> that module headlines (method paper).
- If no module beats B2 even on the stable base -> reframe as a benchmark + ablation
  + analysis paper: "high-res multi-ROI experts help; ROI conditioning beyond concat
  does not, and we explain why (label/representation limits)."

## Contributions (target)

- C1 (firm): a shortcut-controlled, multi-cohort, image-only ROI-grounded 3D MRI VQA
  benchmark with subject-level LOCO and three-zone evaluation.
- C2 (firm): a systematic study of ROI conditioning for 3D MRI VQA — single-view,
  multi-crop concat, question-routing, relational, localization — with multi-seed
  bootstrap, isolating which conditioning actually transfers across cohorts.
- C3 (pending): the winning conditioning module (PEFT adapter on frozen 3D SSL
  encoders), if it robustly beats concat on the pretrained base.
- C4 (firm): analysis of why naive learned routing fails and why pretraining is
  necessary (noise-floor vs effect-size argument).

## Experiment matrix

| axis | values |
|---|---|
| encoder | from-scratch (done) ; contrastive-pretrained frozen (running) ; pretrained fine-tuned |
| variant | B1, B2, B2rel, B5r_oracle, B5r(+sup), [localization] |
| seeds | 20260610/11/12 (>=3) |
| cohort LOCO | AJU (done) ; + OASIS, NACC |
| metric | macro AUC (primary), per-question AUC, three-zone bacc, subject bootstrap vs B2 |
| reference bars | fixed 2.5D (lower) ; morphometry 0.91 (context only) |

## Tables / figures planned

- T1: benchmark stats + shortcut-control AUC table.
- T2: variant x encoder macro AUC with bootstrap CIs vs B2, multi-seed.
- T3: per-question AUC (highlight ratio + MTL).
- T4: cross-cohort LOCO (AJU/OASIS/NACC).
- F1: method/architecture diagram.
- F2: routing/attention interpretability (gate per question; localization attention maps).
- F3: noise-floor vs effect-size (variance of from-scratch vs pretrained).

## Risk register

- R1: no module beats concat even pretrained -> fall back to C1+C2+C4 (benchmark/
  analysis paper). Still ACCV-plausible but weaker; decide after pretrained run.
- R2: gains do not transfer to OASIS/NACC -> claim AJU-only or reframe.
- R3: hand-specified routing/relational reads as engineering -> lean on the learned
  localization module (F2 interpretability) and the analysis (C4).
- R4: label limits (adjusted-vs-raw, ratio question) cap fine-question AUC -> report
  with three-zone framing; do not over-claim clinical validity.

## Module results — organized (2026-06-10, fine-tuned base, AJU LOCO, 3 seeds)

All numbers are test macro AUC mean +/- std. Baselines on the SAME fine-tuned base:
B1 (global+mtl) 0.837 +/- 0.009 ; B2 (+roi concat) 0.812 +/- 0.032 ;
oracle anatomical routing 0.871 +/- 0.014.

### Module 1 — learned question-conditioned 3D evidence localization (weak ROI-mask supervision)

Variant B_loc: question-conditioned soft 3D attention over the global-volume
feature map (8^3 grid); localized feature concatenated with global+mtl pooled
features. Weak supervision pulls the attention toward population ROI-occupancy
priors (built from per-session FreeSurfer ROI masks, registered, downsampled to
8^3, non-AJU train only). At test the attention is fully learned (no prior input).

| setting | macro AUC | hippo | MTL | ratio | vent |
|---|---:|---:|---:|---:|---:|
| lambda=0 (unsupervised attention) | 0.823 +/- 0.011 | 0.747 | 0.733 | 0.882 | 0.930 |
| lambda=0.3 (ROI-prior weak supervision) | 0.827 +/- 0.010 | 0.741 | 0.761 | 0.888 | 0.917 |

Verdict: NEGATIVE. Weak ROI-mask supervision gives a small MTL improvement
(0.733 -> 0.761) over unsupervised attention, confirming the prior carries signal,
but the module does NOT beat the single-view B1 baseline (0.837) and is far below
hard routing (0.871). Mechanism: soft attention over the coarse 8^3 global grid
cannot recover the fine medial-temporal signal that a dedicated high-resolution
80^3 MTL crop provides. The gain source is high-resolution dedicated ROI evidence,
not soft localization in the global volume.

### Module 2 — relational cross-ROI reasoning (ratio hook)

Variant B2rel: learned relation embedding (MLP over [zm, zr, zm*zr, |zm-zr|]) on the
hippo(mtl) and ventricle(roi) experts, appended to the B2 concat.

| variant | macro AUC |
|---|---:|
| B2rel | 0.832 +/- 0.004 |

Verdict: NEGATIVE/inconclusive. Beats the noisy B2 concat (+0.020) but does not beat
the single-view B1 baseline (-0.005), and provides no ratio-question-specific gain.
The relation MLP does not add usable signal beyond the pooled experts.

### Effective mechanism (for contrast)

Hard anatomical question routing over high-resolution dedicated ROI experts
(oracle, 0.871) is the only variant that robustly beats both B1 (+0.034) and B2
(+0.059), with gains concentrated in fine questions (MTL +0.113, hippo +0.073).
The two hypothesized novelty modules (localization, relational) do not.

## Finalized paper spine (honest)

Lead contribution is NOT the two originally-hypothesized modules (both negative).
It is the empirical finding + analysis:

- C1 (primary): question-conditioned anatomical routing over high-resolution
  dedicated ROI experts beats single-view and naive multi-crop fusion for image-only
  3D MRI ROI-VQA, with gains concentrated in fine medial-temporal questions, under
  subject-level LOCO + bootstrap.
- C2 (analysis): a controlled study of ROI conditioning showing WHICH conditioning
  works — dedicated high-res crops + routing yes; soft global localization and
  cross-ROI relational MLP no. The benefit is high-resolution dedicated ROI evidence,
  not localization or feature relations.
- C3 (representation-gating): module benefits are gated by representation quality —
  invisible on from-scratch (noise) and frozen-contrastive (augmentation destroys
  atrophy signal), visible only on a fine-tuned base. Contrastive SSL augmentations
  (scale/cutout) harm volumetric-atrophy tasks.
- C4 (benchmark): shortcut-controlled image-only ROI-grounded multi-cohort VQA.

## Immediate next steps

1. (running) LOCO-safe contrastive pretrain of global64/mtl80/roi80 encoders.
2. Pretrained-frozen multi-seed eval of all variants vs B2; fill T2.
3. If a module wins -> add OASIS/NACC LOCO + interpretability figure; draft method.
4. If not -> design the learned localization module on the stable base before reframing.
