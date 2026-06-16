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
