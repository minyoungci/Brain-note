# Multi-Consortium Alzheimer's Brain MRI Dataset

Create a publication-ready infographic / schematic diagram summarizing a 7-consortium
T1-weighted brain MRI dataset (13,022 sessions) used for Alzheimer's representation learning.

Title: Multi-Consortium Brain MRI Dataset (13,022 sessions, 7 consortiums)

Layout:
- Landscape 16:9.
- One rounded box per consortium, arranged in a grid, grouped by population:
  Western cohorts (top row) and Korean cohorts (bottom-right), with a legend.
- Each box shows: consortium name, #subjects / #sessions, longitudinal %, scanner vendors,
  native voxel range. Use muted academic colors; color-code by scanner heterogeneity.

The 7 consortium boxes (use these exact numbers):
- ADNI : 1,580 subj / 4,742 ses ; longitudinal 54% (up to 16 timepoints) ; SIEMENS+GE+PHILIPS ; voxel 0.50-1.20mm. Tag as "multi-vendor, multi-year".
- NACC : 1,414 subj / 1,866 ses ; longitudinal 26% ; SIEMENS+GE+PHILIPS ; voxel ~1.0mm.
- A4   : 992 subj / 1,811 ses ; longitudinal 80% ; Siemens ; voxel ~1.06mm ; preclinical.
- OASIS: 718 subj / 1,420 ses ; longitudinal 51% ; Siemens ; voxel ~1.0mm.
- AIBL : 617 subj / 987 ses ; longitudinal 29% ; Siemens (Trio/Verio) ; voxel ~1.0mm.
- AJU  : 1,001 subj / 1,287 ses ; cross-sectional ; GE (single vendor) ; voxel 0.39-1.02mm (high-res). Korean cohort.
- KDRC : 909 subj / 909 ses ; cross-sectional ; scanner UNKNOWN (anonymized) ; voxel 0.40-1.00mm. Korean cohort.

Annotations (small callouts):
- "Site/scanner bias: image alone predicts consortium at 56.5% (chance 14.3%)"
- "Korean (AJU/KDRC) vs Western = population confounded with scanner"
- "N4 bias correction applied; resolution heterogeneity is an independent site axis"

Keep it clean, legible, with a clear legend and grouped layout.
