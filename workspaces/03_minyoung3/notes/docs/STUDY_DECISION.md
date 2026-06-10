# Study decision

## Chosen study

**2.5D + ROI MRI representation learning for clinically probed brain-aging/AD structure.**

## One-line contract

Train a 2.5D axial T1w masked center-slice SSL encoder on all valid PASS MRI sessions, then test whether ROI-informed variants improve official-label CDR/CDR-SB/progression probes beyond non-ROI 2.5D and shortcut controls.

## Why this direction

1. Plain 3D image classifiers and PET-transfer framing are weak/shortcut-prone as headline claims.
2. 2.5D center-slice SSL is technically tractable and already passed scaffold/pilot gates.
3. ROI can add technical novelty if used as a controlled attention/prompt/crop mechanism, not as an unvalidated anatomical truth claim.
4. Official manifest provides cleaner clinical labels while allowing SSL corpus and probe corpus to be reported separately.

## Allowed main image inputs

- `final_tensor_path`
- `final_mask_path`
- F04 2.5D axial slab rows derived from official-v2 final tensors/masks

## Allowed ROI inputs, after source-contract gate

- Visual-QC-PASS ROI cache/crops/prompts only.
- ROI masks/crops must be joined to the same subject/session/path identity as the F04 slab/session.
- ROI-derived scalars are allowed only as explicit controls or auxiliary ablations, not hidden shortcuts.

## Main probe targets

- official `cdr_global`
- official `cdrsb`
- diagnosis as a secondary/sanity probe, not the headline
- progression/worsening only after longitudinal label contract is re-audited

## Required baselines

1. 2D center-slice MAE/no-ROI
2. 2.5D center-slice MAE/no-ROI
3. 2.5D + ROI token/prompt/crop variant
4. CNN-lite debug/control
5. ROI-volume-only shortcut control
6. cohort-only forbidden shortcut control
7. clinical-only allowed baseline where age/sex coverage is sufficient

## Not allowed as headline claims

- “new masked reconstruction task”
- “3D volumetric classifier”
- “MRI predicts PET amyloid robustly”
- “ROI alignment is anatomically perfect because Visual-QC PASS”
- “single-run downstream metric proves representation quality”
