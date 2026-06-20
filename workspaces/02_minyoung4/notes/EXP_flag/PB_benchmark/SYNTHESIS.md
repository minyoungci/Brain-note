# Corrective Benchmark — synthesis (the contribution this data supports)

Locked 2026-06-20 after the strong-model experiment. The data does NOT support a higher-AUC IDH
imaging method (proven). It DOES support a rigorous, reproducible, strong-model-backed corrective
benchmark. The "higher" here is rigor/credibility, not AUC.

## Central claim
> Reported MRI glioma molecular-prediction AUCs (~0.85–0.95; e.g. Glio-LLaMA-Vision IDH 0.89) are
> largely an **age confound**. Under honest clinical-adjusted leave-one-consortium-out (LOCO)
> evaluation, even a **strong 3D CNN** — that beats weak proxies and matches published Res3DNet —
> does **not exceed an age-only baseline** and adds ~nothing on top of age. We provide a reproducible
> 4-consortium benchmark + a leakage-clean evaluation protocol that exposes these pitfalls.

## Headline evidence (all in hand)
**T1. Strong image LOCO (DenseNet121-3D) vs weak B2 proxy** (`P3_idh_strong/reports/p3_eval.json`):
UTSW 0.780, UPENN 0.871, MU 0.812, UCSD 0.589; mean 0.763 (B2 proxy 0.735; +0.03–0.05 per fold;
UPENN 0.871 ≈ published Res3DNet external 0.872). → the strong model is genuinely strong; closes the
"your image model was weak" attack on the ceiling.

**T2. Age-adjusted (the decisive table)** — age_only LOCO vs strong image vs img+age:
| consortium | age | strong image | img+age |
|---|---|---|---|
| MU | 0.936 | 0.812 | 0.925 |
| UCSD | 0.820 | 0.589 | 0.825 |
| UPENN | 0.930 | 0.871 | 0.929 |
| UTSW | 0.878 | 0.780 | 0.870 |
| mean | **0.891** | 0.763 | 0.887 |
age > image on every consortium; img+age ≈ age (no gain). → **imaging-over-age ceiling is real.**

**T3. Even shift-robust DG cannot rescue it**: DANN improves the worst consortium point estimate
(UCSD 0.589→0.662) but paired bootstrap CI95 [-0.110, +0.255] includes 0 (UCSD N=12 pos). No
significant DG win; image still < age.

## Methodology contribution (the reusable, leakage-audited protocol)
- LOCO split generator, conflict-excluded, leakage-free (`P1_01`, hash dc288827).
- Worst-consortium + low-prev-pooling metrics, generic PAIRED bootstrap, calibration (eq-width/
  eq-mass ECE, Brier), OOF schema — independently code-audited (`P1_02`, self-test 7/7).
- The "floor discipline": establish a cheap clinical/volumetric floor before GPU; a leakage case
  study (`P2_01` M0a: a +0.10 longitudinal result that was 100% feature-availability leakage).
- Multi-consortium pitfalls characterized: 8× prevalence shift, age-semantics non-uniformity,
  heterogeneous segmentation label schemas.

## Prior-work contextualization
Glio-LLaMA-Vision IDH 0.89 ≈ our age 0.891, never age-adjusted (its IDH head is BiomedCLIP 2D-slice
mean-pool + MLP, no report at inference). Res3DNet external 0.872 reported as raw AUC, no age control.
→ the field's headline numbers are age-explainable; we show this with a strong model + honest eval.

## Figure plan (figure-first)
- F1: the age-adjusted table T2 as a grouped bar (age vs image vs img+age per consortium) — the headline.
- F2: per-fold val→test gap (in-distribution near-perfect, held-out collapses; UCSD 0.93→0.59) — the
  domain-shift story.
- F3: strong vs weak proxy (T1) — "we used a strong model" rigor.
- F4: the leakage case study (M0a) — a pitfall demonstrated.

## Remaining rigor (before submission)
1. **Age-semantics HARD BLOCKER** (`exp00/age_semantics_audit.md`): MU=diagnosis-age etc. Resolve /
   sensitivity-check so the age-0.891 baseline is unimpeachable. (CPU)
2. **Fitted nested-OOF ceiling probe with the STRONG model OOF** (like exp02 did for the proxy) —
   show fitted image+age fusion also fails to beat age (exp02 found image HURTS). Needs nested-OOF
   strong-model predictions (GPU).
3. Multi-seed robustness of the strong-model LOCO AUCs.
4. Frame venue: MICCAI/journal (corrective benchmark, not AI-conf method).

Artifacts: `P3_idh_strong/reports/{P3_milestone.md,p3_eval.json}`, `P1_0{1,2}`, `P2_01`,
`docs/context/*` (EDA), memory `glioma-multiconsortium-dead-directions`.
