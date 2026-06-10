# roi_qc — ROI QC (numeric + visual) for option_b final-grid candidates

**Separated from the educational notebooks** (`Clinical/notebooks`, `Clinical/consortiums`).
This directory is the operational ROI-QC pipeline that gates voxel-wise supervision.
It reuses shared loaders from `Clinical/common` (no duplication) but keeps all QC
artifacts here.

## Data scope (strict)
Operates ONLY on `official_manifest.csv` (13,022 rows) via `manifest_roi_qc.parquet`.
No data outside the final manifest enters.

## Layout
```
roi_qc/
  manifest_roi_qc.parquet     # official_manifest(13,022) + per-ROI numeric QC (99.7% covered)
  VISUAL_QC_CRITERIA.md       # the visual/anatomical pass rubric (5 checks, tiered sampling)
  scripts/
    build_visualqc_montage.py # 3D mask -> multi-plane montage (mask unchanged; more sections)
    run_montages.py           # Tier-1 (all must-review) + Tier-2 (stratified) generation
  montages/{pilot,tier1,tier2}/   # one PNG per session
  reports/
    tier1_sample.parquet, tier2_sample.parquet
    visual_qc_worksheet.csv   # review worksheet: verdict + notes per session (fail-closed init)
```

## State of QC
- **Numeric QC**: done, 12,983/13,022 (99.7%). `numeric_all_required_rois_pass` True 12,978 / False 5 / uncovered 39 (A4 unprocessed).
- **Visual QC**: NOT_REVIEWED for all. `roi_final_ready=False` for all (policy).

## Run
```bash
/opt/conda/bin/python scripts/run_montages.py    # regenerate Tier-1/Tier-2 montages
```

## Promotion gate (fail-closed)
`roi_final_ready=True` requires numeric pass ∧ all-required-ROI visual PASS ∧ explicit
human approval. Agent does triage only; final sign-off is the human gate.
See `VISUAL_QC_CRITERIA.md`.

## Site/scanner bias & harmonization (2026-06-02)
Separate workstream (not ROI QC): quantify and reduce cross-consortium scanner bias in
the model-input tensors. See `research_notes/daily/2026-06-02.md` (full detail) and memory
`v2-no-n4-bias-correction`, `manifest-acq-voxel-site`.

Findings (all measured, leakage-free repeated splits):
- **v2 had NO N4 bias correction** (z-score only). Site probe reads consortium from image
  appearance at balanced_acc 0.565 (chance 0.143); biology(brain_vox) ≈ chance.
- **N4 (post-FastSurfer, image only) is the chosen harmonization**: reduces pure scanner
  signal (population-fixed within-ADNI 0.75→0.59~0.62) while preserving morphology.
  WhiteStripe(WM-ref) and Nyúl gave NO net gain over N4 → both rejected.
- **Resolution/voxel is an INDEPENDENT site axis** N4 can't touch (voxel alone predicts
  cohort 0.53, AJU 0.92; +0.14 over N4 image). Candidate next lever: resolution aug.
- **Manifest lacked acquisition metadata**; native NIfTI headers recover voxel 100%
  (13,022/13,022) via `extract_acq_voxel.py`.

Scripts: `scripts/{probe_site,probe_robust,probe_compare4,probe_resolution}.py` (probes),
`scripts/{n4_extract_features,n4_ws_extract_features,n4_nyul_extract_features}.py` (harmon.
feature extractors), `scripts/extract_acq_voxel.py` (voxel from headers).

Production (IN PROGRESS): `scripts/n4_reprocess_full.py` regenerates all 13,022 tensors
with precise N4 (shrink=2) into each session's `t1w/final_tensor_n4/` (originals untouched);
on completion `scripts/{n4_reprocess_verify,n4_prod_reprobe}.py` run the verification +
effect re-probe, then the N4 path + voxel are merged into `official_manifest_full_n4.*`.
