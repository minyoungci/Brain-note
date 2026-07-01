# 4.6 Downstream Benchmark — Foundation vs BrainIAC across 7 tasks

> Results: `downstream_benchmark.json` (frozen grid + CI), `paired_vs_brainiac.json` (paired significance),
> `finetune_benchmark.json` (full fine-tuning). Head-to-head on the **BrainIAC-available subset (n=1132**;
> A4 31 / AIBL 617 / AJU 484), same subjects/folds. Metric: Pearson r (reg) / AUROC (cls). Frozen probe unless
> noted. All models frozen for the head-to-head; fine-tuning reported separately.

## Setup
Seven downstream tasks spanning cognition, dementia, demographics, and molecular pathology: brain-age (reg),
MMSE (reg), CDR (reg), CN-vs-AD (cls), CN-vs-MCI (cls), sex (cls), amyloid-positivity (AJU, cls). Frozen
methods: **linear** probe, **+morphometry fusion** (concat FreeSurfer 26-vol), **wg-ensemble** (concat
wg0.5⊕wg1). Models: our wg0.5/wg1/wg0, **BrainIAC** (published brain foundation), random-init, morphometry-only.

## Head-to-head (frozen, best-of-ours vs BrainIAC), paired Δ with 95% CI
| Task | ours (best) | BrainIAC | paired Δ (linear) | paired Δ (+morph) | significant win |
|---|---|---|---|---|---|
| brain-age | 0.353 | 0.355 | −0.00 (ns) | +0.03 (p=.09) | tie (frozen) |
| **MMSE** | 0.471 | 0.402 | **+0.069 (p=.007)** | **+0.060 (p<.001)** | **✅** |
| **CDR** | 0.474 | 0.441 | +0.03 (ns) | **+0.047 (p<.001)** | **✅** (fusion) |
| **CN-vs-AD** | 0.824 | 0.812 | +0.01 (ns) | **+0.017 (p=.032)** | **✅** (fusion) |
| CN-vs-MCI | 0.821 | 0.810 | +0.01 (ns) | +0.018 (p=.10) | ns (dir. +) |
| **sex** | **0.944** | 0.785 | **+0.159 (p<.001)** | **+0.087 (p<.001)** | **✅✅** |
| **amyloid** | 0.607 | 0.512 | **+0.094 (p=.003)** | **+0.087 (p=.001)** | **✅** |

**Our foundation significantly outperforms BrainIAC on 5 of 7 tasks** (MMSE, CDR, CN-vs-AD, sex, amyloid),
ties on brain-age and CN-vs-MCI. **morphometry fusion** is the strongest frozen readout: `morph⊕ours` beats
both `morph⊕BrainIAC` and morphometry-alone on every regression task (brain-age 0.50 vs 0.47 vs 0.46; MMSE 0.62
vs 0.56 vs 0.58; CDR 0.64 vs 0.60 vs 0.60) — the foundation adds signal beyond FreeSurfer that BrainIAC does not.

## Fine-tuning (full FT vs scratch, our wg0.5) — `finetune_benchmark.json`
Frozen probes underestimate the foundation. Full fine-tuning **brain-age r 0.31 → 0.582 [0.53,0.63]**
(Δ+0.23 over scratch) — exceeding morphometry (0.474) and frozen BrainIAC (0.355). (MMSE/CDR/CN-vs-AD FT
in progress.)

## Two honest caveats
1. **Input regime.** Our foundation is **whole-head** (no skull-strip); BrainIAC requires skull-stripping +
   registration. Part of our advantage — pronounced on **sex** — reflects features (skull/scalp morphology)
   that BrainIAC's skull-stripped input discards. This is a genuine deployment advantage (simpler pipeline,
   broader applicability: BrainIAC could not run on ADNI, which lacks skull-strip), not evidence that our SSL
   objective is intrinsically superior.
2. **Fine-tuning fairness.** The FT brain-age number compares **fine-tuned ours vs frozen BrainIAC** — not
   apples-to-apples. A fair FT-vs-FT comparison (fine-tuning BrainIAC's backbone / using its released
   brainage head) is pending; we do not yet claim an FT-regime win.

## Relation to the rank-failure finding
Across every task, **pure-dense (wg0, the RankMe pick) is the worst of our checkpoints** (brain-age 0.17,
MMSE 0.20, sex 0.78, CN-vs-AD 0.63) — the rank-failure pattern holds on all 7 tasks. The tasks where we beat
BrainIAC use **balanced/global** checkpoints, reinforcing the paper's core: rank-max selection would forfeit
these wins.
