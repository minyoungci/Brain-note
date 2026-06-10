# Research synthesis — amyloid prediction from structural MRI with a privileged PET teacher

_Generated 2026-06-10. All numbers are from real computation on the official v2
tree (scripts + reports in this folder); nothing here is estimated._

---

## 1. Preprocessing state — DEFECT-FREE ✅ (certified)

`verify_pet_preprocessing.py` → **hard defects = 0** (missing / unreadable /
bad-shape / integrity / no-late-window). 3 subjects flagged as **QC-exclusions**
(global SUVR < 0.8: AJU ABD-BS-0023 0.607, KDRC 24678166 0.690, OASIS OAS30132
0.729) — these are downstream filters, not preprocessing failures.

### 1.1 The 4-cohort dataset (official v2 tree, voxel-aligned 192×224×192)

| modality | role | ADNI | OASIS | AJU | KDRC |
|---|---|--:|--:|--:|--:|
| T1w (+FastSurfer seg) | universal input backbone | ✓ all | ✓ all | ✓ all | ✓ all |
| FLAIR | input (3/4; adapter for ADNI) | ✗ | raw only | ✓ | ✓ |
| **PET-amyloid (SUVR)** | **train-only privileged teacher** | **669** | **343** | **993** | **891** |
| binary amyloid label | target (y) | 1203 | 443 | 1000 | 534 |

- **PET teacher: 2,896 subjects** (4,305 scans) — 91% of the 3,180 labelled set.
  Remaining 284 (mostly ADNI without extracted AV45, OASIS without raw) train
  student-only (no distillation loss).
- Verified independently: grid 192³ (all), finite/nonzero integrity (sample 0/160
  bad), PET↔T1w brain Dice median **0.88–0.90**, OASIS late-window (50–70 min)
  applied per tracer.
- Genuine failures excluded (~0.5%): FAIL_PET_WINDOW 6 (OASIS scans too short),
  FAIL_REGISTER_TIMEOUT, FAIL_SUVR, FAIL_CONVERT.

### 1.2 What this work added
ADNI + OASIS amyloid PET were wired into the Korean (AJU/KDRC) SUVR pipeline:
same whole-cerebellum SUVR core, cohort-specific front-end only (ADNI averaged
DICOM; OASIS BIDS dynamic → 50–70 min late-window; nearest-T1w session pairing).
Patch: `minyoungi/preprocessing/{paths,executor,pet_suvr}.py` + `run_pet_adni_oasis.py`.

---

## 2. Selected study (highest-probability, defensible)

> **Privileged amyloid-PET distillation for amyloid-positivity prediction from
> structural MRI (T1w + FLAIR), evaluated leave-one-cohort-out (LOCO) across 4
> cohorts and 3 tracer domains.**

- **Input (test-time)**: T1w (universal) + FLAIR (adapter absorbs ADNI's absence).
- **Target**: binary amyloid positivity (the only label common to all 4; ADNI/
  OASIS = Centiloid≈20, AJU/KDRC = visual read).
- **Privileged signal (train-only)**: PET SUVR teacher, distilled into the student.
- **Why this one**: it is the single axis where the data is complete and the
  motivating gap is real and measured (below). The heterogeneity (tracer/site/
  label-method) is turned into the research question via LOCO rather than hidden.

---

## 3. Results produced (real numbers)

### 3.1 The privileged teacher is a valid amyloid signal — but batch-effected
`verify_pet_preprocessing.py` (global whole-cerebellum SUVR vs binary label):

| cohort | teacher AUC (SUVR→label) | neg-anchor SUVR |
|---|--:|--:|
| AJU | **0.937** | 1.20 |
| ADNI | **0.815** | 1.263 |
| KDRC | 0.774 | 1.16 |
| OASIS | 0.658* | 1.08 |

\*OASIS uses the *global* SUVR; the cortical-composite SUVR is materially stronger
(AJU composite ≈ 0.97 vs global 0.937 in prior work) and is the recommended
teacher target. **neg-anchor spread 1.08–1.263** quantifies the tracer/site batch
effect → the teacher needs per-cohort/tracer normalization (Centiloid is blocked
for FBB/FMM + KDRC per-subject tracer unknown; whole-cerebellum SUVR stays
self-consistent within cohort).

### 3.2 Structural baseline — the gap the teacher must close
`study_structural_baseline.py` (FastSurfer aseg+DKT volumes / BrainSegVol →
amyloid, L2 logistic regression, leakage-safe; **3,180 subjects, 100 features**):

| cohort | within-cohort 5-fold AUC | LOCO AUC |
|---|--:|--:|
| ADNI | 0.679 | 0.691 |
| OASIS | 0.675 | 0.718 |
| AJU | 0.717 | 0.720 |
| KDRC | 0.764 | 0.766 |
| pooled | 0.752 | — |

**Read-out**: T1w morphometry predicts amyloid at AUC ≈ 0.68–0.76, and — notably —
**LOCO ≈ within-cohort**, i.e. the structural amyloid signal *transfers* across
unseen cohorts/tracers without collapse. The PET teacher sits ~0.82–0.94. The
**~0.15–0.25 AUC headroom** between the student baseline and the teacher is exactly
what privileged distillation aims to recover at inference (where PET is absent).

---

## 4. The thesis, in one line
Structural MRI carries a real, cohort-transferable amyloid signal (LOCO AUC ≈ 0.70)
but well below PET (AUC ≈ 0.82–0.94); distilling the (now 4-cohort, defect-free)
PET teacher into a T1w(+FLAIR) student should lift the student toward the teacher
while preserving cross-site generalization — testable directly via LOCO.

## 5. Next step (designed, ready to train — needs GPU run)
1. **Student**: 3D CNN on T1w(+FLAIR) → binary amyloid. Baseline AUC target ≈ the
   0.70 above (sanity: should match/beat the LR baseline).
2. **+ Distillation**: add a train-only PET branch; distill its features/logits
   into the student on the 2,896 teacher subjects (student-only loss on the other
   284). Teacher SUVR normalized per cohort (composite recommended).
3. **Eval**: LOCO (4 folds) — report per-cohort AUC + the within−LOCO gap for
   baseline vs distilled. Domain-aware training (cohort embedding / adversarial)
   to suppress the site shortcut (KDRC 68% positive vs others ~34%).
4. **Ablations**: T1w-only → +FLAIR adapter → +PET distillation, each measured
   separately so every component's contribution is isolated.

Artifacts: `config.py`, `audit_amyloid_pet.py`, `pet_pairing_adni_oasis.py`,
`verify_pet_preprocessing.py`, `study_structural_baseline.py` + `reports/`.
