# Visual / Anatomical QC Criteria — option_b final-grid ROI candidates

Scope: judges whether each per-ROI **candidate mask on the final_tensor grid** is
anatomically usable as a voxel-wise supervision target. Operates ONLY on rows of
`official_manifest.csv` (13,022), via `roi_qc/manifest_roi_qc.parquet`.

## Why visual QC is needed (what numeric QC cannot see)

Numeric `overlap ≈ 1.0` / `volerr ≈ 0` only proves the candidate mask faithfully
**reproduces FastSurfer's own segmentation** on the final grid (transfer fidelity /
self-consistency). It can NOT detect:

1. **Transfer/grid breakage** — off-brain / outside-FOV placement (partly flagged by
   `inside_brain_frac`, e.g. KDRC 24221593/ses-1 at 0.51–0.59).
2. **FastSurfer's own segmentation errors** — invisible to numeric QC because the
   reference *is* FastSurfer. This is the unique value of visual QC.

## Required ROI set (must all pass for an MRI to be promotable)

hippocampus, amygdala, thalamus, lateral_ventricle, parahippocampal_cortex

## Per-ROI checks → each scored PASS / BORDERLINE / FAIL

| # | Check | PASS | FAIL signal |
|---|-------|------|-------------|
| 1 | **Localization** | mask centered on the correct structure | wrong structure / off-brain / outside FOV |
| 2 | **Boundary fit** | mask edge tracks the T1 intensity boundary | over-inclusion into adjacent tissue/CSF, or erosion |
| 3 | **Inter-structure leakage** | no bleed into neighbors | hippocampus↔amygdala↔inferior-horn ventricle; ventricle↔WM (MTL = top confusion zone) |
| 4 | **Topology** | contiguous, plausible shape; expected bilateral presence | spurious disconnected islands; one side missing |
| 5 | **Symmetry sanity** (soft) | L/R roughly symmetric | extreme asymmetry not explained by atrophy — flag, not auto-FAIL |

### Per-ROI verdict rule
- **PASS** — all of 1–5 clean.
- **BORDERLINE** — only #2 minor imperfection, no meaningful volume impact.
- **FAIL** — any of #1/#3/#4 grossly wrong, OR #2 large enough to shift volume materially.

### MRI-level aggregation (voxel-wise supervision uses all 5 required ROIs)
- All 5 ROIs PASS → MRI is a `roi_candidate_qc_pass=True` candidate.
- Any required ROI FAIL → MRI BLOCKED.
- Any BORDERLINE → explicit note + human decision; never auto-promote.

`roi_final_ready=True` requires: numeric pass ∧ all-ROI visual PASS ∧ **explicit human
approval**. Policy stays fail-closed (matches the existing readiness-draft policy).

## Reviewer ergonomics & reproducibility

- Montage = per session, rows = 5 ROIs, cols =
  `[sagittal@ctr, coronal@ctr, axial@ctr, axial@25%, axial@75%]`,
  fixed windowing (z-score −1.5..2.5), low-alpha fill + boundary contour.
  Contour exposes leakage/erosion that fill alone hides.
- Record per ROI: verdict + free-text note (→ `reports/visual_qc_worksheet.csv`).
- **Rater reliability**: double-rate ~10% of the sample; report Cohen's κ. If κ is
  low, the rubric is ambiguous → refine before scaling.

## Sampling strategy (full 13,022 manual review is infeasible)

- **Tier 1 — review all**: every numeric FAIL + HIGH/MEDIUM priority + overlap<0.98
  borderline (~15 rows).
- **Tier 2 — stratified estimate**: numeric-pass rows stratified by
  `consortium × cdr_global bin`, N=17/cell. Estimates the per-stratum PASS rate and
  surfaces any consortium-wide systematic failure.
- **Tier 3 — acceptance sampling (for promotion)**: to promote a large block without
  100% review, draw a stratified sample; accept the block at a stated confidence level
  iff failures ≤ k. Quantifies residual risk instead of assuming 100% clean.

## Hard limits (do not overclaim)
- Agent can perform Tier-1/Tier-2 **triage** (flag obvious failures); it cannot grant
  `roi_final_ready`. Final sign-off is the human gate.
- Single-slice judgments miss sub-voxel boundary error; montage gives 5 sections/ROI,
  not the full 25–50 slices a structure spans. It is triage-grade, not exhaustive.
