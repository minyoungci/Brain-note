# SPEC — minyoung3 (amyloid molecular-status VQA)

Living spec. Last updated: 2026-06-13. Pivoted from the FreeSurfer-percentile ROI-VQA
direction (now in `Archive/`, post-mortem in `FAILURE_AND_NOVELTY_ANALYSIS.md`).

## 1. Why the pivot

The previous task answered anatomical questions whose labels were `threshold(FreeSurfer
morphometry(image))` → morphometry is a perfect oracle (AUC→1.0) and grounding is a constant-
prior artifact → **2-level circularity, no vision headroom** (verified: circularity control
reproduced). The escape is a **non-circular label**: an amyloid PET read is measured by an
independent modality, so predicting it from T1 is NOT tool-mimicry.

## 2. Research question

**Does a 3D CNN extract brain-amyloid signal from raw structural T1 MRI BEYOND ROI-volume
morphometry + age + APOE, and does it generalize across PET tracers / sites / ethnicities under
strict leave-one-cohort-out (LOCO)?** Framed as the first molecular-status 3D-MRI VQA (question
= "is this brain amyloid-positive?"), shortcut/confound-controlled, multi-cohort.

Honest prior (literature + our CPU bar): the ceiling is MODEST (multi-cohort T1 ~0.62, Kim AJNR
2025); in cognitively-normal (CN) subjects ROI volumes add ~0 over age+APOE. A clean positive
(image > morphometry in age-matched CN) would be a genuine finding; a null is the honest,
expected outcome and is still a publishable benchmark/negative.

## 3. Data (verified 2026-06-13)

Source (read-only): `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.csv`
(13,022 sessions, 7 cohorts; the canonical manifest with PET amyloid / APOE / cognition labels).

Binary amyloid set (A4 EXCLUDED — enrolled positive-only → pure site shortcut):
- **3,383 sessions / 2,407 subjects / 4 cohorts**: OASIS 1048 (PiB/AV45), AJU 1286 (F18 visual),
  KDRC 534 (F18 visual), NACC 515 (F18 centiloid). pooled pos-rate 0.39.
- Canonical dataset: `results/amyloid_probe/amyloid_vqa_dataset.csv` (label provenance, confound
  columns age/sex/APOE/dx/tracer, subject-level splits, image path).
- Image cache: `results/amyloid_probe/cache96/images_f16.npy` — 96^3 whole-brain (amyloid is
  diffuse/cortical), built from `final_tensor_n4_path` (brain-extracted, N4, per-volume z-scored).

## 4. Honest baseline bar (CPU, the bar the vision model must beat)

`results/amyloid_probe/BASELINE_BAR.md` (subject-level, bootstrap CIs):
- within-cohort CV: age+APOE 0.720, morpho 0.709, morpho+age+APOE 0.742;
  **CN-only image increment over age+APOE = +0.002 [-0.029,+0.034]** (≈0).
- age-matched CN: age-AUC 0.481, **morphometry-AUC 0.616** (small real structural signal, but
  redundant with age+APOE).
- strict LOCO: morpho 0.665, morpho+age+APOE 0.712.

## 5. Method / protocol

- Model: image-only compact 3D CNN (`Small3D`, ~0.3M params) — IMAGE ONLY (+ const question id).
  age/sex/APOE/dx/cohort/tracer/ROI are NEVER model inputs (eval-stratification only).
- Primary protocol: strict LOCO (= cross-site + cross-tracer + cross-ethnicity). Subject-level
  splits; held-out cohort absent from train+val. bf16 only. ≥3 seeds.
- Eval: test AUC overall + dx-stratified (CN reported separately) + age-matched CN + subject
  bootstrap. Compare to §4 bars. Optional image+clinical late-fusion comparison.
- Code: `scripts/run_amyloid_vision.py` (LOCO runner), `scripts/agg_amyloid_vision.py` (aggregate).
  Audited (code-auditor): no leakage, A4 excluded, cache-aligned, image-only confirmed.

## 6. Boundaries / integrity

- Never pool A4 into binary. Never feed clinical/ROI/cohort to the model. Subject-level LOCO only.
- Report dx-stratified honestly; CN is the least-confounded number. No age-leakage spin.
- bf16 only; B200 GPUs; ~1TB RAM ceiling. `/home/vlm/data` read-only.
- Report negatives honestly. Do NOT manufacture novelty the data does not support.

## 7. Open / next

- Run LOCO × seeds; does image beat morpho (and morpho+age+APOE)? age-matched CN the key cell.
- If image > morpho in CN: characterize WHAT it sees (saliency, regional). Genuine finding.
- If null: cross-tracer generalization benchmark + honest "structural T1 carries no amyloid
  signal beyond ROI volumes in CN" as the contribution.
- Secondary molecular questions (APOE-carrier from MRI) to make it a multi-question molecular VQA.
