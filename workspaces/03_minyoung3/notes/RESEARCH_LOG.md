# RESEARCH LOG — F04 Q-ROUTE (single source of truth)

Consolidated record of what we did and what the data told us. Companion to `SPEC.md`
(live data/task spec) and `ACCV/` (submission package). Last updated: 2026-06-11.

## Data (verified)

- Source (read-only): `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`
  — 13,022 sessions / 7,231 subjects, QC PASS, N4 T1w tensors 192x224x192.
- VQA benchmark: 19,236 QA rows / 9,278 sessions / 5,601 subjects; leakage 0.
- 7 cohorts (sessions): ADNI 3410, A4 1536, NACC 1194, AJU 1184, OASIS 842, AIBL 607, KDRC 505.
- Multi-vendor: SIEMENS 10320, GE 5260, PHILIPS 1797; mostly 3.0T. Dx: MCI/CN/CN_preclin/AD/Dem.
- Caches (100% cover): global 64^3, MTL crop 80^3, ROI-union(MTL+vent) crop 80^3.

## Task

Image-only ROI-grounded 3D MRI VQA. Input = image tensors + question id ONLY. 4 binary
session questions (low hippocampal volume / MTL atrophy / ventricle enlargement /
low hippo-to-ventricle ratio), labels = train-only-CN normative percentile cutoffs
(<=0.10 or >=0.90). Eval: subject-level LOCO, macro AUC, subject bootstrap.

## What we tried and what happened (chronological, honest)

| direction | result | verdict |
|---|---|---|
| 2.5D slab vs 3D | 2.5D pooled AUC 0.732 << 3D MTL-crop 0.881 | 3D wins; abandoned 2.5D |
| single-view (B1) vs multi-crop concat (B2) | B1 0.837, B2 0.812 (noisy) | concat alone unstable |
| hard anatomical routing (oracle) | 0.871 (AJU) | beats concat but hand-specified |
| learned router + anatomy-prior (lambda=0.3) | 0.882 (AJU), 3-cohort all-seed > baselines | best single model |
| no-prior learned router | 0.859 (unstable, gate seed-dependent) | prior = weak regularizer, not lookup |
| learned 3D localization (weak ROI-mask) | 0.827 < B1 | FAIL |
| relational cross-ROI (ratio hook) | 0.832 < B1 | FAIL |
| representation regime | from-scratch noisy / frozen-contrastive 0.74 (aug harms atrophy) / fine-tuned best | benefit is representation-gated |
| backbone scaling (compact/ResNet-10/ResNet-18) | router gain +0.070 -> +0.006 -> -0.005 | gain vanishes as backbone scales |
| V1: routing vs plain attention (B_attn) | attn 0.876, router 0.882 (delta +0.005) | **routing ~= attention; gate redundant** |
| V2: data-scale (frac 1.0/0.3/0.1) | router-B2 +0.070 / +0.076 / +0.012 | advantage peaks at 30%, collapses at 10% |
| Gumbel hard (discrete) routing | no-prior collapses to 1 expert (0.840) | FAIL |

## Multi-cohort LOCO (main router, macro AUC, 3 seeds)

| variant | AJU | OASIS | NACC |
|---|---:|---:|---:|
| B1 single-view | 0.837 | 0.873 | 0.891 |
| B2 multi-crop | 0.812 | 0.852 | 0.875 |
| learned router | 0.882 | 0.905 | 0.905 |

Bootstrap vs B2: 5/6 cohort-router cells strictly positive (NACC learned borderline).

## Bottom-line conclusion (the meta-finding)

- The ONE robust positive: **high-resolution multi-crop ROI tokens + cross-attention**
  beat pooled concat (+0.064) and are parameter-efficient (0.35M routed beats 14M/33M ResNet).
- EVERY claimed "special mechanism" was deflated by the data: question routing (~= plain
  attention, +0.005), large backbones (gain vanishes), Gumbel (collapses), localization &
  relational (below single-view). There is **no strong vision-method novelty** on this task.
- Root cause: labels are FreeSurfer-percentile-derived and morphometry+norm already reaches
  ~0.91 LOCO AUC, so the task is near-saturated and semi-circular (image -> predict what
  FreeSurfer computed from the same image). Little headroom for a vision method.

## Strengths to keep (regardless of next direction)

- Shortcut-controlled benchmark (clinical-context AUC ~ chance, ROI-oracle = 1.0).
- Strict subject-level multi-cohort LOCO + subject bootstrap; multi-vendor/multi-site data.
- Reproducible code + ablation/efficiency infrastructure (`ACCV/scripts/`).

## Brain-age + cross-vendor DG probe (2026-06-11) — NEGATIVE on quick test

- Morphometry (FS ROI volumes -> age, ICV-norm): MAE 4.5yr random / 4.2-4.4 cross-vendor, r~0.5.
- Learned 3D CNN on cache-limited CN subset (3,333 sessions, 2,452 train):
  Small3D test MAE 4.58 (random) / 4.63 (xvendor) -- ties/loses to morphometry, overfits (val 4.0 -> test 4.6).
  ResNet-10 overfits worse (val MAE climbs 4.4 -> 4.9). 14M params on 2.4k samples.
- Root limits: (i) global cache covers only 44% of CN-age sessions; (ii) elderly narrow age
  range (70.6 +/- 7.0) caps brain-age MAE ~4; (iii) crowded field. Morphometry features are
  vendor-robust so cross-vendor gap is small for them.
- Verdict: quick test does NOT show clear vision headroom. A proper test needs the full CN
  cache (7,580) + SSL pretraining, but structural headwinds make a STRONG result unlikely.

## Meta-conclusion across topics

A strong VISION-METHOD (ACCV-main) contribution is structurally hard on this dataset:
morphometric signal saturates simple methods; genuinely-hard labels (APOE 14%, ~30 MCI->AD
converters) are data-starved; brain-age is capped (narrow elderly age + crowded field).
Dataset is strong for MEDICAL-IMAGING contributions (multi-cohort benchmark, harmonization,
biomarkers) -> MICCAI/ISBI tier, not a pure-vision method paper.

## Decision (2026-06-11)

Stop optimizing the conditioning/routing axis (diminishing returns; data has answered).
Two honest paths: (A) package the current work as a benchmark + empirical-study paper
(medical-imaging/workshop tier), or (B) re-scope to a task with genuine vision headroom.
Next step: detailed data exploration for a vision-headroom ACCV topic (see SPEC open items).

## Grounding result (2026-06-11) — REFRAME: contribution axis = grounding, not accuracy

Reference check (M3D, AutoRG-Brain) showed oracle-accuracy is the WRONG bar; 3D medical VQA
contributes via dataset/grounding/generalization. FreeSurfer-percentile = legitimate pseudo-label.

B_loc (localization variant), AJU LOCO, 3 seeds:
- answering macro AUC: loc-sup 0.827+-0.012 vs no-loc-sup 0.823+-0.014 (SAME -> grounding is free)
- grounding mass-in-ROI: loc-sup 0.778+-0.011 (x26 over uniform 0.030) vs no-loc-sup 0.245+-0.11
- pointing-game: loc-sup 0.953 vs no-loc-sup 0.295
Findings: (1) loc-sup necessary for reliable grounding (no-sup weak + unstable, seed collapses);
(2) grounding costs nothing in answering; (3) weak emergent grounding without sup (x8) but unreliable.
This axis (localize the evidence ROI under cross-cohort LOCO) is something morphometry CANNOT do
-> NOT capped by the 0.91 accuracy ceiling. See ACCV/POSITIONING.md.

## CIRCULARITY CONTROL (2026-06-13) — GROUNDING CLAIM REFUTED

Reviewer-2 (research-critic) flagged the grounding result as a possible registration
artifact: attention is supervised toward a FIXED population prior (2 maps only), evaluated
vs the same FreeSurfer mask family on registered brains. Ran the decisive CPU control
(scripts/control_circularity.py; saved test_attn.npz + saved prior; no retraining).

PAIRED mass-in-ROI (same subject×question pairs), STATIC prior vs LEARNED loc-sup attn:
- AJU   static 0.807 vs learned 0.790 (delta -0.016)
- OASIS static 0.836 vs learned 0.830 (delta -0.006)
- NACC  static 0.736 vs learned 0.748 (delta +0.012)
=> learned attention does NOT beat a non-learned constant prior (within noise; worse on 2/3).

Mechanism (AJU): cos(learned_attn, prior)=0.95-0.97 (it IS the prior); per-subject
per_cell_std=0.0005 (nearly constant); 4-9 distinct peak cells over ~100 subjects.

CONSEQUENCE: C2 (grounding) as written is WITHDRAWN. The "supervised 0.78 vs no-sup 0.20 vs
Grad-CAM 0.14" table omits the dominant baseline (static prior 0.80); cross-cohort "x27 flat"
is the signature of a constant prior on registered brains. C1 (benchmark) unaffected; answer-
accuracy/efficiency axis pending its own re-audit. See ACCV/results/CONTROL_FINDING.md.

## RESOLUTION SWEEP (2026-06-13) — finer-res grounding salvage REFUTED

Space is conformed NATIVE (t1w_brain_1mm_RAS_192x224x192, identical affine all subjects),
NOT template-registered. But static-prior mass-in-ROI stays high at every grid:
  hippo 0.80/0.84/0.73 | mtl 0.92/0.89/0.80 | vent 0.84/0.84/0.74 | ratio 0.88/0.85/0.76
  (grids 8^3/16^3/32^3 = 24/12/6 mm cells)
Per-subject ROI centroid scatter = 3.3-3.9 mm (smaller than the structures). Brain-extraction
+ fixed-FOV conform co-locates deep structures to a few mm => a CONSTANT wins spatial grounding
at ALL resolutions. Finer-resolution grounding has no image-conditioned headroom. Script:
scripts/resolution_sweep.py; raw ACCV/results/CONTROL_resolution_sweep.txt.

ROOT CAUSE (generalized): every supervision signal here is FreeSurfer-derived (answer labels =
threshold(morphometry); grounding GT = FS masks) AND anatomy is spatially trivial after conform.
=> accuracy axis = tool mimicry (oracle-bounded); grounding axis = constant-prior trivial.
No top-tier novelty in THIS task/data. Novelty needs a non-FreeSurfer label source (clinical
outcome/genetics, currently data-starved) or a different task. See report.

## PIVOT — Amyloid molecular-status VQA (2026-06-13)

Non-FreeSurfer escape from the circularity: amyloid positivity is PET-measured (independent of
the T1 image), so image->amyloid is non-circular. Data exists (real_final manifest): 3,383
binary-amyloid sessions / 2,407 subjects / 4 cohorts (OASIS/AJU/KDRC/NACC; A4 excluded =
positive-only). Multi-tracer (PiB/AV45/F18-centiloid/F18-visual), multi-ethnicity (Korean+West).
Full results: results/amyloid_vision/RESULTS_AMYLOID.md. Bar: results/amyloid_probe/BASELINE_BAR.md.

Honest CPU bar (subject-level, bootstrap): morphometry is NOT an oracle for amyloid (within-cohort
0.709 / LOCO 0.665, not 1.0) -> circularity broken, real headroom to probe. BUT in age-matched CN
morphometry's increment over age+APOE = +0.002 (~0); literature ceiling multi-cohort T1 ~0.62.

Vision result (image-only 3D CNN, strict LOCO, image-only input, A4 excluded, subject-level):
| arm | macro-LOCO | age-matched CN (200-draw) |
|---|---|---|
| scratch w16/w32 | 0.610 / 0.584 | ~chance (CI brackets 0.5) |
| brain-age pretrained (MAE 4.40yr) ft/frozen | 0.627 / 0.603 | ~chance |
| ROI-volume pretrained ("learned morpho") ft/frozen | 0.653 / 0.636 | ~chance |
| morphometry bar | 0.665 | 0.55-0.58 (CI excludes 0.5) |
| permutation null | 0.510 | (no leakage) |
| APOE-e4 from MRI | 0.52 | (chance; genotype not structural) |

VERDICT: a null robust across 3 pretext families (none/age/structure) x {frozen,fine-tune}. No
image representation beats morphometry; the best (ROI-volume ft 0.653) only approaches it; ALL are
at chance in age+sex-matched CN. Ceiling = MODALITY (structural T1 carries no usable CN-amyloid
signal beyond ROI volumes), not model/representation/resolution. Reviewed twice by research-critic
(F1/F2 width-confound + n-seed + wording fixed) and code-auditor (no leakage, A4 excluded,
cache-aligned, image-only confirmed). Subject overlap pretrain(ADNI/A4/AIBL) vs test = 0.

CONTRIBUTION (honest, non-fabricated): (C1) first molecular-status 3D-MRI VQA + shortcut/confound-
controlled multi-cohort/tracer/ethnicity LOCO benchmark; (C2) a representation-robust bounded null
(MRI does not read CN-amyloid beyond morphometry); (C3) morphometry-oracle taxonomy connecting the
archived FreeSurfer-VQA dead-end (morpho=oracle, no headroom above) to amyloid (morpho~=clinical~=
chance in CN, no headroom for anything). NOT a positive accuracy claim. Tier: MICCAI/MIDL/journal
bounded-negative+benchmark; not a top-CV method paper.

REMAINING honest gap (next, if pursued): the one regime NOT capped is LONGITUDINAL imaging
(literature: longitudinal CN amyloid ~0.87 vs single-timepoint ~0.62); data has 18,868 longitudinal
sessions / 599 CDR-SB progressors / 273 dx converters. Single-timepoint structural T1 has converged
to a null; within-subject change is the only structural axis with literature-supported headroom.
