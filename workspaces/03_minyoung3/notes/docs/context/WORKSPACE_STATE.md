# Workspace state

- Root: `/home/vlm/minyoung3`
- Active purpose: F04/F05 2.5D + ROI MRI representation study.
- Primary SSL objective: 5-slice axial T1w slab -> masked center-slice brain patch reconstruction.
- Main architecture direction: ViT/MAE-style patch Transformer.
- ROI role: controlled auxiliary/token/prompt/crop pathway after source-contract and visual-QC policy verification.
- Label authority: `/home/vlm/data/preprocessed_official/official_manifest.csv` for CDR global/CDR-SB/source provenance.
- SSL corpus: keep full valid PASS MRI sessions/slabs; do not restrict SSL to labeled-only rows except as ablation.
- Probe corpus: official-label-enriched subset joined onto F04 slab/session rows.
- Deleted direction: old 3D/PET/longitudinal voxel artifacts and notes removed on 2026-05-27; inventory preserved under `Official/potato/Reset_Audits`.
- Current phase: build `f04_official_labels` manifest, then design F05 ROI-informed 2.5D variants.
- Raw data policy: `/home/vlm/data` is read-only.
- Forbidden headline: direct pooled MRI→PET prediction, full 3D volumetric classifier, or ROI-perfect-anatomy claim without separate validation.
