# FINAL CONCLUSIONS & LOCKED DIRECTION (2026-06-14)

Conclusion of the multi-cohort 3D brain-MRI representation-learning investigation. All claims are
backed by reproducible, code-audited, statistically-validated experiments (subject-level splits,
bootstrap CIs, permutation/aug-only/permuted-target controls, research-critic + code-auditor passes).
Negative results reported honestly; no fabricated positive.

## The locked research direction (our novelty)
**"When and why do learned 3D representations fail to beat engineered morphometry for structural
brain MRI? A multi-cohort, mechanistically-explained diagnostic framework."** The contribution is
a *diagnostic taxonomy + mechanism + reproducible benchmark*, not an accuracy SOTA — because the
data, examined exhaustively and rigorously, does not support a clean accuracy positive, and we can
explain precisely why. This is an honest, defensible AI-research contribution (negative-results +
benchmark + diagnostic framework tier: MICCAI/MIDL/NeuroImage).

## The single finding that organizes everything: the morphometry-oracle taxonomy
A 3D-MRI target falls into one of three classes; none yields a clean learned-rep > engineered-feature win:

| class | example targets | why learned reps don't win | evidence |
|---|---|---|---|
| **morphometry-saturated** | dx (AD/MCI/CN), brain-age, sex | engineered ROI-volumes already near-ceiling (AD_vs_CN morpho 0.885); learned reps tie, never beat | I02, find_image_dominant_target |
| **signal-starved (molecular)** | amyloid, APOE | T1 is structurally blind to the molecular signal (biomarker cascade); ~chance in confound-free CN | I02, I07, amyloid 60 runs |
| **confound-inflated** | amyloid pooled, WMH | apparent signal is age/dx/site confound; collapses under stratification/permutation | I02, feasibility_confound_invariant |
| (spatial, the last hope) | WMH/Fazekas | morphometry-volume genuinely weak (0.592) BUT small/single-cohort/age-confounded/T1<FLAIR -> weak positive only | I07 appendix |

## The mechanism (why — not just empirics)
1. **Molecular targets**: amyloid is an EARLY molecular event; atrophy is a LATE downstream consequence
   (Jack biomarker cascade). T1 measures macroscopic morphology -> sees amyloid only indirectly, late,
   non-specifically -> in CN (where it matters) ~chance. (CN image increment over age+APOE = +0.002.)
2. **Morphological targets**: the signal IS ROI-volume atrophy, which FreeSurfer already extracts ->
   a learned 3D CNN can at best re-derive it -> morphometry is a hard ceiling (confirmed across 5
   representation regimes incl. brain-age- and ROI-volume-pretrained encoders).
3. **Fusion**: for molecular targets the predictive signal is clinical/genetic (APOE/age/MMSE 0.768
   vs image 0.708; image +0.02 / CN −0.03). Site is a non-transferable shortcut (LOCO 0.500).
4. **Longitudinal**: same-subject contrastive SSL learns INVARIANCE to within-subject change ->
   counterproductive for progression (aug-only single-timepoint beats it on all 3 tasks). The correct
   approach is change-DIRECTION modeling (LSSL/LNE), executed here (`run_longitudinal_lssl.py`).

## Executed experiment inventory (reproducible)
- Consortium data inventory + manifest-enrichment verification (`reports/CONSORTIUM_INVENTORY.md`).
- Amyloid image-only: ~60 GPU runs across 5 representation regimes + controls (permutation null 0.51,
  matched morphometry, age+sex-matched-CN 200-draw) — representation-robust null (`results/amyloid_vision/`).
- Fusion-SSL: 24 runs, what-to-fuse × pretext + F5-permutation + M1-aug-only controls; bootstrap CIs
  + matched morphometry (`results/fusion_ssl/REANALYSIS.md`, `RESULTS_FUSION.md`).
- Modality ablation + image-dominant-target finder + confound-invariant feasibility (CPU, `scripts/*`).
- Longitudinal change-direction LSSL (+ covariate-conditioned variant) — the correct longitudinal method.
- Literature: novelty gap (longitudinal-SSL ⟂ tabular-fusion intersection) + honest bars.

## What we can honestly CLAIM (and cannot)
- CAN: a rigorous, multi-cohort, mechanism-backed demonstration that learned 3D-T1 representations do
  not beat engineered morphometry + clinical features across molecular/morphological/spatial target
  classes; the morphometry-oracle diagnostic; the amyloid-cascade explanation; the longitudinal
  invariance pitfall; the what-to-fuse rule (clinical/genetic for molecular targets).
- CANNOT: any "our 3D model beats X on accuracy" claim on this structural-T1 data. Forcing one would
  be a confounded/leakage-prone artifact (we showed this repeatedly).

## If a POSITIVE is required, the only honest routes (out of current scope)
- Add the modality T1 lacks: PET-derived / plasma pTau / FLAIR -> multimodal (image-secondary).
- A target where the image provably > ROI-volumes AND is large/multi-cohort/unconfounded (not found here).
- Reframe the contribution as the diagnostic-framework/benchmark above (recommended).

## Insights archive
`insights/I01`–`I07` capture every failure mode + reusable lesson (circularity, morphometry-oracle,
data-reality pitfalls, engineering bugs, longitudinal-contrastive-harm, what-to-fuse). Standing
practice: log failures/insights there.
