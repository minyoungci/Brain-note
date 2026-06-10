# minyoung3 — F04 2.5D + ROI MRI representation study

This workspace is now dedicated to one primary paper direction only:

- **Primary study:** 2.5D axial T1w MRI masked center-slice representation learning with ROI-informed auxiliary/probe pathways.
- **Core SSL objective:** 5-slice slab `[z-2,z-1,z,z+1,z+2]` -> reconstruct masked brain patches of the center 2D slice `z`.
- **Clinical/probe labels:** use `/home/vlm/data/preprocessed_official/official_manifest.csv` as the label authority for CDR global/CDR-SB/source provenance.
- **ROI role:** controlled technical novelty layer, not unverified atlas-wide ROI evidence.

## Critical boundary

- Do **not** revive the old full 3D voxel/PET-transfer direction.
- Do **not** use `/home/vlm/data` as a writable workspace; it is read-only canonical data.
- Do **not** claim ROI anatomical perfection from Visual-QC PASS alone. Treat PASS as a trainability/policy layer.
- Do **not** claim reconstruction loss proves clinical representation quality.

## Current active families

- `F04`: 2.5D axial slab masked center-slice SSL with ViT/MAE-style patch Transformer.
- `F04-label`: official-label-enriched slab manifest for downstream probes.
- `F05`: ROI-informed 2.5D extension to be built after label-join and ROI-source contract are verified.

## Novelty target

The novelty is not “masked reconstruction” itself. The defensible novelty is:

1. strict multi-consortium 2.5D MRI SSL corpus construction;
2. center-slice masked reconstruction with subject-level split discipline;
3. ROI-informed token/prompt/crop auxiliary pathway under fail-closed ROI QC;
4. official CDR/CDR-SB/progression probes separated from the unlabeled SSL corpus;
5. shortcut controls: cohort-only, ROI-volume-only, clinical-only, 2D-only, 2.5D-no-ROI.

## Current status

- Old PET/longitudinal voxel/3D remnants were deleted from code/results/reports/notes on 2026-05-27 with pre-delete inventory preserved under `Official/potato/Reset_Audits/`.
- F04 2.5D SSL scaffold and short CUDA pilot already passed.
- Next active gate: build and verify official-label-enriched F04 slab manifest.
