# minyoung4 Research: Shortcut-aware 3D Brain MRI Representation Learning (CN vs AD)

Create a publication-ready research-overview diagram for an AI-conference-style methodology.
Clean boxes, directional arrows, grouped stages, muted academic colors, legible at slide scale.

Title: Shortcut-aware 3D T1w MRI Representation Learning for CN vs AD

Prominent research-question banner (top): "Can 3D T1w representations separate CN from AD
using brain MORPHOLOGY, not cohort / scanner / source shortcuts?"

Layout: landscape 16:9, left-to-right flow with 4 stages, plus a bottom "shortcut control" rail
running underneath all stages.

STAGE 1 — Data (left):
- Integrated manifest: official_manifest_full_n4 (13,022 sessions / 7 consortiums; N4-harmonized 3D T1w [192x224x192], ROI masks, FastSurfer volumes, clinical).
- Strict labels (diagnosis-CDR concordance): CN = dx CN & CDR 0; AD = dx AD & CDR >= 1; exclude MCI / discordant.
- Supervised target: ADNI / AIBL / KDRC. CN-only domain controls / pretraining: NACC / OASIS.

STAGE 2 — Representation objectives (center; show as a stack of compared ablations):
- 8C: shortcut-aware ROI-text objective
- 8D: image-only patch MAE (masked volume modeling)
- 8E: whole-brain ROI token pooling
- 8F: resolution / site-invariant token pooling
- Extension (BioTime-3D): longitudinal temporal-consistency + amyloid/Centiloid-conditioned objective
Encoder: 3D ViT / ConvViT.

STAGE 3 — Baselines (compared against, small box):
supervised 3D CNN/ViT from scratch, generic 3D MAE, 3D DINO/SimCLR, longitudinal-only, biomarker-only.

STAGE 4 — Evaluation (right):
- Primary: LEAVE-ONE-CONSORTIUM-OUT (held cohort) — true generalization.
- Shortcut encodability probes reported BEFORE any disease-performance claim.
- Random subject split = smoke test only, flagged "shortcut-prone".

BOTTOM RAIL — "Shortcut / control variables (suppressed via adversarial head + probe, and evaluated)":
cohort, scanner / site, acquisition resolution, ROI volume, crop geometry, N4 intensity stats, age, sex, clinical missingness.

Goal box (green, bottom-right): "Learn a representation that retains disease-relevant morphology
while reducing cohort/scanner/source/missingness shortcuts."

Keep text concise inside boxes; show the bottom shortcut rail clearly spanning all stages.
