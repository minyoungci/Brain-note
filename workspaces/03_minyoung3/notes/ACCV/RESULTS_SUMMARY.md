# Grounded ROI-VQA — Paper Results Summary

Last updated: 2026-06-12. All numbers below are saved artifacts under `ACCV/results/` and
`ACCV/figures/`, reproducible from `scripts/`. This is the consolidated inventory for the paper.

## Reframe (why this is not ceiling-limited)

Earlier we benchmarked against "beat the morphometry oracle on answer AUC" and hit a ~0.91
ceiling (labels are FreeSurfer-percentile pseudo-labels). Reference works (M3D, AutoRG-Brain)
show that is the WRONG bar: 3D medical VQA contributes via **dataset / grounding / cross-site
generalization**, not oracle accuracy. Our contribution axis is therefore **grounding** (localize
the evidence ROI) + **cross-cohort generalization** — things morphometry/oracle cannot do.

## Contributions

- **C1 Benchmark**: shortcut-controlled (clinical-context AUC ~ chance, ROI-oracle = 1.0),
  multi-cohort (7) / multi-vendor (3), subject-level LOCO, normative FreeSurfer pseudo-labels.
- **C2 Grounding**: the model ANSWERS an anatomical-evidence question AND GROUNDS it (localizes
  the ROI). Strong vs Grad-CAM, generalizes across 3 held-out cohorts.
- **C3 Conditioning study**: when explicit 3D ROI conditioning helps (representation- and
  capacity-gated; parameter/data efficiency) — completed earlier (see RESEARCH_LOG).

## Main results

### Table A — grounding method comparison (AJU LOCO, mean+-sd over seeds)
| method | mass-in-ROI | pointing | x chance |
|---|---|---|---|
| supervised attention (loc-sup, ours) | 0.780 +- 0.010 | 0.947 | x27 |
| attention, no loc-sup | 0.200 +- 0.074 | 0.244 | x7 |
| Grad-CAM (post-hoc, B2) | 0.143 +- 0.007 | 0.357 | x5 |
| uniform (chance) | 0.029 | - | x1 |

Supervised question-conditioned attention localizes far better than the free post-hoc
Grad-CAM a plain classifier provides. Localization supervision (lambda=0.3) costs nothing in
answering AUC (0.827 vs 0.823 without).

### Table B — cross-cohort grounding generalization (B_loc loc-sup, true LOCO)
| held-out cohort | test n | mass-in-ROI | pointing | x chance | answering macro AUC |
|---|---|---|---|---|---|
| AJU | 340 | 0.785 +- 0.008 | 0.941 | x27.5 | 0.818 |
| OASIS | 210 | 0.837 +- 0.004 | 0.990 | x27.8 | 0.891 |
| NACC | 320 | 0.747 +- 0.004 | 0.920 | x27.3 | 0.886 |

Grounding holds at ~x27 over chance across three independently held-out cohorts (scanner/site
shift) -> cross-site grounding claim supported.

### Per-question grounding (AJU, loc-sup) — Table 2
| question | n | mass | uniform | pointing |
|---|---|---|---|---|
| Hippo-low | 96 | 0.693 | 0.016 | 0.826 |
| MTL-atrophy | 100 | 0.887 | 0.025 | 0.990 |
| Ventricle-up | 64 | 0.773 | 0.037 | 0.995 |
| Hippo/Vent-low | 80 | 0.758 | 0.041 | 1.000 |

## Figure inventory (`ACCV/figures/`)
- `fig1_grounding_bars.png` — per-question mass-in-ROI (loc-sup vs no vs uniform).
- `fig2_attention_overlay.png` — attention overlay on MRI (ventricle example).
- `fig3_question_conditioning.png` — same MRI, 4 questions -> attention follows the asked ROI.

## Table inventory (`ACCV/results/`)
- `TABLE_A_grounding_methods.md`, `TABLE_B_grounding_crosscohort.md`
- `TABLE1_grounding_main.md`, `TABLE2_grounding_perquestion.md`

## Honest caveats
- Pseudo-label grounding GT is an anatomical ROI (FreeSurfer mask), not radiologist-verified
  pathology; no free-text generation.
- SSL pretrain excluded AJU only; OASIS/NACC supervised-LOCO uses AJU-excluded SSL init
  (label-free) — proper per-cohort SSL pretrain is future work.
- Answering AUC is pseudo-label-ceiling-limited (~0.91); the contribution is grounding +
  cross-site generalization, not answer accuracy.

## Reproduce
- Grounding GT: `scripts/build_grounding_gt.py {AJU|OASIS|NACC}`
- Cross-cohort LOCO: `scripts/run_ground_loco.sh`; loc-sup ablation: `scripts/run_ground_multi.sh`
- Grad-CAM baseline: `scripts/run_gradcam.sh`
- Tables: `scripts/make_grounding_results.py`; figures: `scripts/plot_grounding_figures.py`,
  `scripts/plot_question_conditioning.py`; eval: `scripts/eval_grounding.py <run> <gt.npz>`
