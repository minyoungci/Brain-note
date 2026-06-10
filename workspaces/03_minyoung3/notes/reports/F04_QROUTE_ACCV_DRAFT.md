# Which ROI Conditioning Helps Image-Only 3D Brain-MRI Question Answering? An Anatomy-Routed Study

Working draft — 2026-06-10. Numbers are from this repository's runs (AJU LOCO, 3 seeds, macro AUC unless stated). All claims are AJU-LOCO only pending OASIS/NACC replication.

## Abstract

We study image-only ROI-grounded visual question answering (VQA) on 3D T1w brain MRI,
where a model must answer normative anatomical-evidence questions (low hippocampal
volume, medial-temporal atrophy, ventricular enlargement, low hippocampus-to-ventricle
ratio) from image tensors and a question id alone, with all clinical, cohort, and ROI
metadata excluded. On a shortcut-controlled, subject-level leave-one-cohort-out (LOCO)
benchmark, we ask a single question: *what form of ROI conditioning actually improves
fine-grained 3D MRI VQA?* We compare single-view fusion, naive multi-crop concatenation,
learned question-conditioned 3D localization with weak ROI-mask supervision, cross-ROI
relational reasoning, and question-conditioned anatomical routing over high-resolution
dedicated ROI experts. Three findings: (1) **anatomical routing** to dedicated
high-resolution ROI crops is the only conditioning that robustly beats both single-view
and multi-crop baselines (+0.034 / +0.059 macro AUC), with gains concentrated in fine
medial-temporal questions (MTL +0.113, hippocampal +0.073); (2) **learned soft
localization and relational reasoning do not help** — the benefit comes specifically
from high-resolution dedicated ROI evidence, not from localizing within a global volume
or relating pooled features; (3) the benefit of any conditioning module is **gated by
representation quality**: it is invisible with from-scratch or frozen-contrastive
encoders and emerges only after fine-tuning a 3D-SSL base, and we show that standard
contrastive augmentations harm volumetric-atrophy representations.

## 1. Introduction

- Problem: faithful, shortcut-resistant ROI-grounded VQA from 3D MRI; fine medial-temporal
  evidence is the documented bottleneck (2.5D pooled AUC 0.732 vs 3D MTL-crop 0.881).
- Gap: prior work adds capacity/crops but does not isolate *which* ROI conditioning
  transfers across cohorts under leakage-safe LOCO.
- Contributions: C1 anatomy-routed conditioning result; C2 controlled conditioning study
  (what works vs not); C3 representation-gating + contrastive-augmentation-harm analysis;
  C4 shortcut-controlled multi-cohort benchmark.

## 2. Benchmark and protocol

- Source: official N4 manifest (13,022 sessions, 7,231 subjects, all QC PASS). Matched
  ROI-VQA benchmark: 19,236 QA rows / 9,278 sessions / 5,601 subjects; 4 session
  questions; train-only normative reference; percentile-cutoff labels; 1:1 balanced.
- Shortcut control: under `cohort_dx_cdr_age_sex` matching, clinical-context AUC ~= chance
  (0.50-0.55), ROI-oracle = 1.0. Inputs are image tensors + question id only.
- Protocol: AJU LOCO (train/val exclude AJU; test = 340 AJU rows / 124 subjects),
  subject+session leakage 0. Primary metric: macro AUC (per-question mean; pooled AUC
  is volatile across 4 heterogeneous questions). Subject-level bootstrap for significance.
- Experts/caches (100% coverage): global 64^3; bilateral MTL crop 80^3; ROI-union
  (MTL+ventricle) 80^3.

## 3. Methods (conditioning variants)

All variants share the same small 3D conv encoder (Conv3d x4) per view and a shared
answer head; they differ only in how ROI information is conditioned.

- B1 single-view fusion: global + MTL pooled late fusion.
- B2 multi-crop concat: global + MTL + ROI-union pooled concat (no routing).
- B_loc learned localization: question-conditioned soft 3D attention over the global
  feature map; localized feature appended; optional weak supervision toward population
  ROI-occupancy priors (registered FreeSurfer masks, 8^3, train-only). Attention is
  learned at test.
- B2rel relational: learned relation embedding over hippo(MTL) and ventricle(ROI) experts.
- Routing (oracle): question id deterministically routes to its anatomically-relevant
  high-resolution ROI expert (hippo/MTL->MTL crop; ratio/ventricle->ROI-union); the
  routed evidence is added residually to the multi-crop concat. The route is a function
  of the (allowed) question id only.
- Encoders: from-scratch; frozen contrastive (SimCLR, LOCO-safe); or contrastive-init
  fine-tuned. SSL excludes AJU.

## 4. Results

### 4.1 Conditioning on a fine-tuned 3D-SSL base (main)

| variant | macro AUC | hippo | MTL | ratio | vent | vs B1 | vs B2 |
|---|---:|---:|---:|---:|---:|---:|---:|
| B1 single-view | 0.837 +/- 0.009 | 0.748 | 0.766 | 0.898 | 0.935 | - | +0.025 |
| B2 multi-crop concat | 0.812 +/- 0.032 | 0.730 | 0.730 | 0.870 | 0.919 | -0.025 | - |
| B_loc localization (weak-sup) | 0.827 +/- 0.010 | 0.741 | 0.761 | 0.888 | 0.917 | -0.010 | +0.015 |
| B2rel relational | 0.832 +/- 0.004 | - | - | - | - | -0.005 | +0.020 |
| **Routing (oracle)** | **0.871 +/- 0.014** | 0.803 | 0.843 | 0.896 | 0.942 | **+0.034** | **+0.059** |

Routing vs B2 subject-bootstrap: P(delta>0) = 1.00 / 1.00 / 0.77 across seeds (positive
in all 3). Routing vs B1: +0.034 mean, driven by MTL (+0.077 vs B1) and hippocampal.

### 4.2 Representation-gating (why the base matters)

| variant | from-scratch | frozen-contrastive | fine-tuned |
|---|---:|---:|---:|
| B1 | 0.787 +/- 0.017 | 0.736 +/- 0.007 | 0.837 +/- 0.009 |
| B2 | 0.815 +/- 0.020 | 0.737 +/- 0.005 | 0.812 +/- 0.032 |
| Routing (oracle) | 0.835 +/- 0.008 | 0.727 +/- 0.005 | 0.871 +/- 0.014 |

- From-scratch: noise floor (std 0.02-0.03) > module effect sizes; no module is
  separable.
- Frozen-contrastive: stable but low; all variants collapse to ~0.73. SimCLR
  augmentations (scale +/-10%, cutout 18%) teach invariance to the size cues that
  atrophy questions depend on, so frozen features are partly blind to atrophy.
- Fine-tuned: strong and stable; routing's advantage becomes significant.

### 4.3 Negative modules (the two hypothesized novelties)

- Localization: weak ROI-mask supervision lifts MTL 0.733 -> 0.761 over unsupervised
  attention, but the module stays below single-view B1. Coarse 8^3 global attention
  cannot recover the fine signal of a dedicated 80^3 MTL crop.
- Relational: no ratio-specific gain; does not beat B1.

## 5. Analysis

- The effective ingredient is **high-resolution dedicated ROI evidence selected per
  question**, not soft localization or feature relations.
- Routing benefit is **representation-gated**; reporting only one encoder regime would
  have hidden it (frozen) or buried it (from-scratch).
- A free-form learned router collapses to a single safe expert; gate supervision recovers
  the routing but a competing loss degrades the answer task; hard routing (a function of
  the allowed question id) is cleanest and best.

## 6. Limitations

- AJU LOCO only so far; OASIS/NACC LOCO required for a generalization claim.
- Routing map is hand-specified over 4 questions / 2-3 ROIs; richer question/ROI sets
  needed to argue a learned router.
- Single SSL pretrain seed; small encoder. Labels are normative percentiles, not clinical
  cutoffs (three-zone framing avoids over-claiming).

## 7. Conclusion

For image-only 3D MRI ROI-VQA, question-conditioned anatomical routing to high-resolution
dedicated ROI experts is the conditioning that helps, especially on fine medial-temporal
questions; learned localization and relational reasoning do not, and the effect only
appears on a properly fine-tuned representation.
