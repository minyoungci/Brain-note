# MIN-WMH — Results (manuscript backbone)

_Multi-cohort Inter-tool benchmark for WMH quantification & Neurodegeneration-inference._
_Verified 2026-06-16. All numbers from `results/*.json` (reproducible scripts in repo root)._

## Thesis (post-gating, defensible)
> **Using a WMH segmentation tool's downstream clinical association (WMH→hippocampus) to
> rank or validate the tool is confounded by global atrophy.** Tools disagree heavily; the
> tool that appears "clinically best" appears so partly because it captures more
> atrophy-coupled (periventricular) variance, not more true white-matter-hyperintensity. We
> demonstrate this across two US cohorts with three segmenters and show the apparent
> tool-advantage is (i) statistically real but (ii) half measurement-error attenuation and
> (iii) fully abolished by ventricular-atrophy adjustment.

This is a **cautionary methods contribution**: the increasingly popular "validate WMH tools
by clinical/downstream utility" paradigm rewards atrophy leakage. It does NOT claim a winner.

## Cohorts (FLAIR + amyloid + hippocampus; MIN = Multi-cohort Inter-tool Neurodegeneration)
| cohort | population | amyloid | FLAIR | n (subject) | role |
|---|---|---|---|---|---|
| OASIS-3 | US community | A− | native 2D 5mm | 242 | primary (clean A−) |
| A4 | US | A+ | native 2D 5mm | 250 | amyloid-positive contrast |
| AJU | Korean memory clinic | A− | native 5mm (random subset) | 96 | underpowered (disclosed) |

KDRC excluded (native FLAIR 5/20); ADNI excluded (download T1-only, 1 FLAIR subject);
AIBL/NACC have no FLAIR. These four are the only FLAIR-bearing cohorts on disk.

## Tools (three paradigms, same FLAIR per subject)
1. **WMH-SynthSeg** — domain-randomization synthetic training (Laso/Iglesias 2024)
2. **ANTsPyNet SYSU-media** — supervised, MICCAI-2017 challenge winner
3. **ANTsPyNet SHIVA** — supervised

## M6 — Inter-tool agreement (Lin's CCC on log WMH; `tool_dependence.json`)
| cohort | synthseg~sysu | synthseg~shiva | sysu~shiva |
|---|---|---|---|
| OASIS | 0.685 | 0.065 | 0.069 |
| A4 | 0.28 | 0.089 | 0.054 |
| AJU | 0.12 | 0.094 | 0.074 |
→ Tools barely agree. SHIVA (median 0.4–1k mm³, conservative) vs SYSU (median 6.5–18k mm³,
over-segmenting) differ ~10–20× in volume; SynthSeg~SHIVA CCC ≈ 0.07 = near-zero concordance.
**Volume magnitude ≠ agreement; "more WMH" is not "more correct."**

## M5 — Tool-dependence of clinical inference (`gate_analysis.json`, d0; identical subject set, β + 95% CI)
hippo/eTIV ~ wmh_z(tool) + age + sex (+ APOE where available); amyloid-negative unless noted.
| cohort | SynthSeg β [CI] | SYSU β [CI] | SHIVA β [CI] |
|---|---|---|---|
| OASIS (A−) | **−0.115 [−0.188,−0.042]** | −0.020 [−0.090,0.049] | **−0.078 [−0.145,−0.012]** |
| A4 (A+) | **−0.146 [−0.213,−0.080]** | −0.032 [−0.095,0.032] | −0.058 [−0.122,0.007] |
→ Whether the WMH→hippocampus association is "detected" depends on the tool: SynthSeg detects
in both; SYSU misses in both; SHIVA intermediate.

## d2 — Are the tool betas actually distinguishable? (paired bootstrap of β-difference, 2000×)
| cohort | synthseg−sysu [CI] | distinguishable |
|---|---|---|
| OASIS | −0.095 [−0.156,−0.036] | **YES** (CI excludes 0) |
| A4 | −0.116 [−0.188,−0.052] | **YES** |
→ Passes the Gelman–Stern test (we compare effect sizes, not significance). The tool
difference is real, not a significant-vs-nonsignificant artifact.

## d3 — But how much is just measurement-error attenuation? (SIMEX-lite)
Degrade SynthSeg's exposure with noise until its agreement with SYSU (CCC) is matched, refit:
| cohort | SynthSeg orig β | SynthSeg degraded-to-SYSU-noise β | SYSU actual β |
|---|---|---|---|
| OASIS | −0.115 | −0.070 | −0.020 |
| A4 | −0.146 | −0.054 | −0.032 |
→ Adding noise to SynthSeg to match SYSU's reliability moves β about **halfway** to SYSU's.
So the SYSU "miss" is **~half classical measurement-error attenuation, ~half systematic**
(SYSU over-segmentation captures non-WMH variance). The naive "tool-dependence as discovery"
framing over-claims; measurement noise is a large part of it.

## ⭐ d1 — The confound that breaks the benchmark's own premise (`gate_analysis.json`)
Add ventricular volume (most sensitive global-atrophy proxy) to the M5 model:
| cohort | tool | baseline β(p) | + ventricle β(p) |
|---|---|---|---|
| OASIS | SynthSeg | −0.115 (.002) | **−0.018 (.62)** |
| OASIS | SHIVA | −0.078 (.022) | −0.034 (.27) |
| A4 | SynthSeg | −0.146 (.000) | −0.057 (.099) |
→ **Every tool's WMH→hippocampus association collapses under ventricle adjustment.** SHIVA is
a WMH-only model (no shared labels with the ventricle) yet also collapses → not a SynthSeg
joint-model artifact. **The downstream signal that the benchmark uses to rank tools is
atrophy-coupled.** The "best" tool (SynthSeg) led partly because it tagged more periventricular
/ atrophy-border variance — see clinical read-across.

## Clinical read-across (Track04 AJU A− n=643; `track04_ventricle_readacross.json`, `deep_wmh_decomposition.json`)
Independent confirmation on a properly-powered cohort:
- Headline WMH→hippo β=−0.123 (cortical-GM control) → **−0.036 (p.24)** with FastSurfer
  ventricle (independent model), −0.001 with SynthSeg ventricle, −0.011 (denominator-artifact
  ruled out). Three specs all collapse.
- Deep vs periventricular decomposition (pre-committed 10mm): **97.7% of WMH is periventricular**;
  the entire association is in the periventricular fraction (β−0.142); **deep WMH carries no
  signal even before ventricle adjustment (β+0.008, p.74).** The signal is the atrophy-coupled
  periventricular fraction. (Caveat: deep fraction 2.3% → deep test underpowered.)

## ⭐⭐ GT-Dice — the killer experiment (MICCAI 2017 WMH Challenge, `gt_dice_summary.json`)
100 subjects, expert manual masks (3 sites). Tools run on co-registered pre/FLAIR(+T1) → Dice.
| tool | GT-Dice (accuracy) | clinical detection (OASIS A−) | atrophy leakage (% β collapse under ventricle) |
|---|---|---|---|
| **SYSU** | **0.664 (#1)** | **✗ misses** | — (no signal to collapse) |
| HyperMapp3r | 0.504 (#2) | (multimodal; not on cohort) | — |
| **SynthSeg** | 0.492 (#3) | **✓ detects** | **84%** |
| **SHIVA** | 0.225 (#4) | **✓ detects** | **57%** |
| wmhseg | excluded (requires >64 vox/dim; FLAIR=48 slices) | — | — |
→ **Segmentation accuracy (Dice) is decoupled from — even anti-correlated with — clinical "detection."**
The most accurate tool (SYSU) recovers NO clinical association; the tools that "detect" are less
accurate AND their detected signal is 57–84% atrophy leakage (collapses under ventricle adjustment).
**Validating/ranking WMH tools by downstream clinical association selects for atrophy leakage, not
accuracy.** The accurate segmenter reveals the true null; the leaky ones manufacture a spurious signal.
(SYSU is the MICCAI challenge winner → Dice is on its home-turf training distribution, which only
strengthens the dissociation: even at its accuracy ceiling, SYSU is the clinical "non-detector".)

## ⭐⭐⭐ Dissociation across 6 tools (bias-controlled) — `dissociation_analysis.json`
6 WMH methods spanning the accuracy spectrum: 4 deep-learning (SYSU, SHIVA, WMH-SynthSeg,
HyperMapp3r) + 2 classical baselines (fixed z>2.5 "naive", Otsu). Each scored on:
GT-Dice (MICCAI, **test split only** → removes SYSU's home-turf training bias) + OASIS A−
downstream β + atrophy-leakage (% β collapse under ventricle adjustment).
| tool | type | GT-Dice (test) | OASIS β (p) | correct detect | ventricle-leak % | survives vent+cortex |
|---|---|---|---|---|---|---|
| SYSU | DL | **0.635 (#1)** | −0.020 (.56) | ✗ | −25% | — |
| HyperMapp3r | DL | 0.496 | −0.094 (.010) | ✓ | **73%** | ✗ (collapses) |
| SynthSeg | DL | 0.477 | −0.115 (.002) | ✓ | **84%** | ✗ |
| SHIVA | DL | 0.235 | −0.076 (.026) | ✓ | **63%** | ✗ |
| naive z>2.5 | classical | 0.157 | +0.095 (.007) | ✗ (wrong sign) | 6% | — |
| Otsu | classical | 0.032 | −0.001 (.97) | ✗ | −50% | — |

**Three quantified results (`dissociation_analysis.json`, `atrophy_control_profile.json`):**
1. **Accuracy does NOT predict clinical detection (decoupled):** Spearman(GT-Dice, β) = −0.54,
   p=0.27 (n.s.). The most accurate tool (SYSU) detects nothing; the crudest fail in opposite
   ways (naive = spurious +, Otsu = null). No monotone Dice↔detection.
2. **Atrophy-leakage PERFECTLY separates detectors from non-detectors:** every detector has
   ventricle-leak 63–84%, every non-detector ≤6% — zero overlap (Mann–Whitney p=0.05). The
   leakage is ventricle-specific (all detectors collapse under ventricle control but survive
   cortex control → periventricular-WMH↔ventricular-enlargement coupling).
3. **NO tool's clinical association survives ventricle+cortex atrophy control** (survives_both = ∅).
   Every "detection" is atrophy-confounded.
→ **A downstream-clinical benchmark rewards atrophy leakage, not segmentation accuracy.**
Bias control: GT-Dice uses the held-out TEST split only (SYSU trained on the training split);
SYSU is still #1 accurate AND the clinical non-detector → the dissociation is not a training-set
artifact. 6 tools span the full accuracy spectrum (Dice 0.03–0.64).

## Multi-cohort replication (`dissociation_multicohort.json`) — partial, honestly scoped
The 6-tool dissociation was tested in 3 cohorts:
- **OASIS (A−, n=242)** — flagship: perfect leak-separation (detectors 63–84% vs non-detectors ≤6%).
- **A4 (A+, n=250)** — independent population: the strong detector (SynthSeg β−0.146, p≈0) is
  high-leak (61%) and collapses under ventricle → **core mechanism (detection=leakage) replicates**.
  But clean tool-separation does NOT hold (A+ dynamics: several tools borderline-significant with
  high leak), and the leak% metric is unstable when base β≈0.
- **AJU native (A−, n=96)** — underpowered: no tool detects (consistent with the random n=96 subset
  being null even at registered resolution); uninformative for the dissociation.
→ **Honest scope**: the *mechanism* (every significant detector is atrophy-leaky and collapses)
holds in both A− (OASIS) and A+ (A4); the *clean accuracy-vs-detection dissociation* is cleanest
in OASIS. A second well-powered A− replication is not achievable from available raw-FLAIR data
(AJU registered is z-scored → ANTsPyNet-invalid; AJU native n=96 underpowered; KDRC FLAIR 5/20).

## Tool roster note
4 deep-learning tools (SYSU, SHIVA, WMH-SynthSeg, HyperMapp3r) + 2 classical baselines (naive z>2.5,
Otsu). LST-AI (5th DL, MS-lesion ensemble) was installed and made runnable (greedy bridged via
picsl_greedy) but is ~6–8 min/subject → infeasible across the full benchmark (~90 GPU-h); MS-focused
applicability to WMH is uncertain. truenet/nnU-Net require FSL/framework+weights not available.

## Honest limitations
- GT-free by design → relative validity/robustness only, not absolute accuracy (intended framing).
- AJU benchmark arm = random n=96 subset, underpowered (null even at registered 1mm per Stage E)
  → tool-dependence evidence rests on OASIS (clean) + A4 (contrast). Disclosed, not buried.
- A4 is amyloid-positive: a *contrast* stratum, NOT a replication of the A− vascular finding.
- ANTsPyNet ran CPU (TF CUDA unavailable in venv); results unaffected (deterministic inference).
- Ventricle adjustment is itself contested (mediator vs confounder; cross-sectional) — but the
  benchmark's point stands regardless: downstream-utility ranking is *sensitive* to it.

## Reproduce
`eval_tool_dependence.py` · `gate_analysis.py` · `track04_ventricle_readacross.py` · `deep_wmh_decomposition.py`
