# Korean multimodal fusion — synergy vs confound (AJU+KDRC)

**Goal:** how to fuse diverse signals/features (+ multimodal imaging) so they
SYNERGIZE for good learning. Population-controlled 2-site Korean setting (AJU+KDRC =
same population, different site) lets us measure SYNERGY (disease gain) and CONFOUND
(site-shortcut absorption) cleanly — unlike Korea-vs-Western (undecidable).

Modality feature groups: IMG = FreeSurfer morphometry (T1-derived; proxy for deep
multimodal imaging, added later); DEMO = age/sex; GENE = APOE; COG = MMSE/CDR/GDS
(LEAKAGE for dx tasks → excluded there); LABS = 16 blood tests.

## EXP-F1 — where does imaging synergy live? (feature-level, CPU)
`exp_f1_feature_fusion.py`, HistGBM, subject-level StratifiedGroupKFold ×3 seeds,
+ cross-site transfer (AJU↔KDRC).

| task | n | IMG-only | TABULAR(no img) | FULL(+img) | **image incremental** | best-single→full synergy |
|---|---|---|---|---|---|---|
| amyloid | 1820 | 0.712 | 0.779 | 0.795 | **+0.016** (null) | +0.051 (tabular) |
| ad_vs_rest | 2011 | 0.801 | 0.743 | 0.846 | **+0.103** | +0.045 |
| ad_vs_mci | 1706 | 0.784 | 0.690 | 0.814 | **+0.124** | +0.030 |

**Findings:**
1. **Imaging multimodal synergy lives in atrophy-related diagnosis (AD): image adds
   +0.10–0.12 over tabular. For amyloid it is null (+0.016)** — APOE/tabular dominate
   (confirms prior I3). → synergy research must target AD/dementia, not amyloid.
2. **The confound is in the TABULAR, esp. LABS**: cross-site transfer is erratic &
   asymmetric (labs ad_vs_rest AJU→KDRC 0.883 vs KDRC→AJU 0.589) = labs carry a
   site shortcut. **IMAGE cross-site is stable** (Δcross ≈ −0.02). AUC is prevalence-
   invariant, so this asymmetry is genuine directional site-shortcut, not class balance.
3. **Tension for fusion**: FULL fusion has the best within-site AUC (synergy) but
   inherits the tabular site-confound. The methodological question:
   **how to fuse so we KEEP image synergy (+0.10) without inheriting the labs
   site-shortcut.** → EXP-F2.

## EXP-F2 — HOW to fuse? (strategies on ad_vs_rest) `exp_f2_fusion_strategies.py`
| strategy | within-CV (synergy) | KDRC→AJU (clean cross) | asym (confound) |
|---|---|---|---|
| image_only | 0.801 | **0.747 (most robust)** | **0.071** |
| early_concat | 0.846 | 0.735 | 0.173 |
| late_avg | 0.838 | 0.732 | 0.174 |
| reliability_wt | 0.841 | 0.729 | 0.138 |
| confound_aware (drop LABS) | 0.847 | 0.698 | 0.137 |

**Findings — concrete answer to "how to fuse for synergy":**
1. Within-site synergy (+0.045 over image) is captured by ALL fusion strategies
   (~0.84). The synergy comes from **IMG(atrophy)+APOE**; LABS contribute nothing
   within-site (confound_aware drops labs yet keeps 0.847).
2. **The synergy does NOT transfer cross-site.** In the clean KDRC→AJU direction,
   image_only (0.747) beats every fusion — fusion HURTS cross-site transfer.
3. **LABS inject the site-shortcut** (asymmetry 0.173); dropping them lowers asym to
   0.137, but still above image_only's 0.071. confound-aware partially helps, not enough.
→ **The real frontier: a SITE-ROBUST fusion that keeps within-site synergy AND
transfers cross-site — beyond just dropping a modality.** Cleanly posed in the
population-controlled Korean 2-site setting.

⚠️ caveats: cross-site numbers also reflect train-size (AJU 1241 vs KDRC 770) and
recruitment (AD prevalence 0.19 vs 0.32); AUC is prevalence-invariant so the asymmetry
is a real directional shortcut, but absolute cross-site values are noisy.

## Next phase — deep MULTIMODAL IMAGES (the real goal)
So far "image" = T1 morphometry only. The genuine multimodal-imaging synergy needs the
actual images: **T1 (atrophy) + FLAIR (WMH/vascular) + amyloid-PET (molecular)** as
deep encoders. FLAIR/PET carry NON-morphometric signal morphometry misses → could
synergize differently. Requires FLAIR/PET preprocessing (scaffold in
`preprocessing/modalities/`) + deep fusion + GPU.

Status: EXP-F1, F2 done (feature-level landscape established). Single workspace, no sprawl.
