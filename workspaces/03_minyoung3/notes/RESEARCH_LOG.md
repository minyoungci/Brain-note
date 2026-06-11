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
