# PAPER_PLAN — Site-Population Separability Diagnostic
*Roadmap from validated core → submission. Companion to STUDY_PROTOCOL_E.md.*

## 0. One-liner
**"Before you harmonize, test whether you can."** A calibrated, cross-sectionally-computable
diagnostic (excess subspace-alignment between the disease direction and the cohort subspace)
that tells you whether site is separable from population in a multi-cohort brain-MRI dataset —
so you know whether harmonization will *unmask* or *deflate* signal.
**Contribution**: a *pre-harmonization* test (orthogonal to the harmonizer-evaluation literature).
**Venue**: NeuroImage:Clinical / MELBA / Human Brain Mapping (realistic); not top-AI.

## 1. DONE (validated core — this session)
- Diagnostic metric **derived and validated**: naive INLP-deflation FAILED calibration (confounded
  by decodability/dimensionality); **excess subspace-alignment** PASSES.
- **E4 calibration** (5 seeds): random +0.086 ≈ within-ADNI scanner +0.003 (separable) ≪ 7-cohort
  +0.546 (entangled). Neg control + separable-scanner pass.
- **Application**: 7-cohort entanglement morphometry +0.546 / BrainIAC +0.389.
- **Per-pair spectrum**: same-population pairs separable (ADNI–NACC +0.13, AJU–KDRC +0.29) ≪
  cross-population entangled (US–Korea +0.57–0.59) → quantitative "site==population" proof.
- Artifacts: `final_diagnostic.py` (+ v0/improved/full_study), `reports/*.md`, `STUDY_PROTOCOL_E.md`.

## 2. REMAINING — 3 phases to submission

### Phase 1 — analysis completeness (NO new data; ~1–2 weeks; do first)
| task | what | why (reviewer) |
|---|---|---|
| **P1.1 full 21-pair matrix + population-distance correlation** | excess-alignment for all 21 cohort pairs; correlate vs a population-distance proxy (age/sex/ancestry/scanner-vendor distance, or demographic Mahalanobis) | turns the spectrum into a *quantitative law* ("alignment ∝ population distance") — the headline figure |
| **P1.2 E5 ComBat-link** | run actual ComBat (+ harmonize) on the 7 cohorts; show high-alignment pairs lose more disease-AUC under ComBat | proves the diagnostic *predicts real harmonization deflation* (not just an abstract number) |
| **P1.3 statistics** | bootstrap 95% CI (resample subjects), permutation null for alignment, Holm across pairs, k-ablation (k∈{1,2,4,6}) | "no inferential stats" was the critic's desk-reject risk |
| **P1.4 second feature space + robustness** | repeat on a 2nd representation (e.g., supervised CNN or brain2vec) + nonlinear cohort-probe variant | generality beyond morphometry/BrainIAC |
| **P1.5 sensitivity** | n-subsampling (does alignment hold at small n?), age/sex-matched subsets | construct-validity of "alignment ≠ age/sex artifact" |

### Phase 2 — external traveling-subject calibration (needs data access; the *gold-standard* validation)
| task | what | blocker |
|---|---|---|
| **P2.1 acquire** | ON-Harmony (public, UKB-aligned T1w; Nat Sci Data 2025) and/or SRPBS Traveling Subject (Synapse/DecNef) | DUA/account/login; check size + access |
| **P2.2 process** | run through our feature pipeline (FastSurfer or 96³ + a feature extractor) | FastSurfer is slow → prefer a lightweight feature (intensity/registration-based) or BrainIAC feats |
| **P2.3 calibrate** | true site-separable regime (same subjects, varied scanner) → diagnostic should read ≈0; synthetic-entangled (site⟂correlated-with-age strata) → high. Validates the metric against *real* traveling-subject ground truth | — |
| *note* | within-population scanner already provides an achievable separable-regime control (Phase-1 result); P2 *strengthens* but is not strictly blocking for a first submission to a mid venue. |

### Phase 3 — writeup & figures (~2 weeks)
- Figures: (F1) calibration bar (random/scanner/7-cohort), (F2) 21-pair alignment heatmap,
  (F3) alignment vs population-distance scatter (the law), (F4) ComBat-deflation vs alignment.
- Sections: Intro (harmonization-by-default risk) → Methods (metric + calibration design) →
  Results (calibration → application → spectrum → ComBat-link) → Discussion (when to harmonize;
  the irreducibility limit) → Limitations (cross-sectional cannot resolve unmeasured population).
- Reproducibility: release code + the *public-data* calibration (private AJU/KDRC = application only).

## 3. Risks & mitigations
- **R1 metric = "restatement of cohort-AUC"** → mitigated: within-ADNI scanner (cohort-AUC 0.895)
  reads alignment ≈0, proving alignment ≠ decodability. Keep this front-and-center.
- **R2 within-data calibration not enough** → Phase 2 external; meanwhile R1 + neg-control carry it.
- **R3 "known (harmonization can hurt)"** → reframe as the *predictive pre-flight test* + the
  population-distance law (P1.1) is the new, quantitative result.
- **R4 single private application** → emphasize the *public* calibration + the method's generality.

## 4. Recommended immediate next actions (priority order)
1. **P1.1** (21-pair matrix + population-distance correlation) — cheap, our data, becomes the headline.
2. **P1.2** (ComBat-link) — cheap, our data, proves practical relevance + unifies with prior audit.
3. **P1.3** (statistics) — cheap, mandatory for any submission.
4. Then **P2** (external calibration) once Phase-1 confirms the story holds.
5. **Phase 3** writeup in parallel once P1.1–P1.3 are in.

→ Phases 1+3 alone (no external data) already constitute a submittable mid-venue paper; Phase 2
upgrades the validation strength. Decision point after P1.1–P1.2: if the population-distance law
+ ComBat-link are clean → commit to full submission; if noisy → reassess venue.
