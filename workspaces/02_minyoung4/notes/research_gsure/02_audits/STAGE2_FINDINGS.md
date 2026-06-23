# Stage 2 Findings: Mask Values and Geometry

## Scope

This finding note is based on:

- `outputs/mask_path_inventory.csv`
- `outputs/mask_value_geometry_audit.csv`
- `outputs/structural_coverage_by_unit.csv`
- `outputs/mask_value_summary_by_key.csv`

No raw data were modified. No preprocessing, split creation, or training was
performed.

## What Is Now Verified

### 1. Four-channel structural MRI is available by path/header candidate

After fixing the modality classifier order, every discovered imaging unit has
all four core structural modality candidates:

| dataset | units | units with seg | units with all 4 core | seg + all 4 core |
|---|---:|---:|---:|---:|
| MU-Glioma-Post | 596 | 594 | 596 | 594 |
| UCSD-PTGBM | 243 | 243 | 243 | 243 |
| UPENN-GBM | 671 | 611 | 671 | 611 |
| UTSW | 625 | 625 | 625 | 625 |

This supports a 4-channel structural MRI task after official cohort/unit
selection.

### 2. Segmentation masks mostly load and align

- Segmentation masks audited: 3,673.
- Loaded successfully: 3,672.
- Load error / zero-byte: 1.
- Masks matching at least one same-unit structural MRI by shape and affine:
  3,514.
- Masks needing geometry review: 159.

The single load error is:

```text
UCSD-PTGBM-0149_02_total_cellular_tumor_seg.nii.gz
```

### 3. Geometry problems are localized

The 159 review cases are not diffuse:

- 158 are UTSW `tumorseg_manual_correction` files with no same-unit structural
  shape/affine match.
- 1 is the UCSD zero-byte `total_cellular_tumor_seg` file.

UTSW also has `rtumorseg_manual_correction` for the same 362 manual-correction
units, and those registered correction files match geometry. Therefore:

```text
Do not use UTSW tumorseg_manual_correction directly for training.
Use rtumorseg_manual_correction if manual correction is selected.
```

### 4. Mask labels are integer-valued but not harmonized

Observed label signatures show that most all-tumor masks are multilabel:

- MU `tumorMask`: values drawn from `{0,1,2,3,4}` variants.
- UCSD `BraTS_tumor_seg`: values drawn from `{0,1,2,3,4}` variants.
- UPENN `UPENN_segm`: values drawn from `{0,1,2,4}` variants.
- UTSW FeTS/manual masks: values drawn from `{0,1,2,3,4,5}` variants.

Binary component masks exist for UCSD cellular components:

- `enhancing_cellular_tumor_seg`
- `non_enhancing_cellular_tumor_seg`
- `total_cellular_tumor_seg`

These are not automatically equivalent to the all-consortium target.

### 5. Empty masks exist and must be interpreted

Empty mask counts:

| dataset | key | empty masks |
|---|---|---:|
| UCSD-PTGBM | enhancing_cellular_tumor_seg | 54 |
| UCSD-PTGBM | non_enhancing_cellular_tumor_seg | 52 |
| UCSD-PTGBM | total_cellular_tumor_seg | 51 |
| UTSW | tumorseg_FeTS | 3 |

UCSD empty component masks may be legitimate absent tumor components. UTSW empty
whole-tumor FeTS masks are suspicious and require source/metadata review:

```text
BT0926
BT1016
BT1090
```

## Candidate Target Mapping

The safest first official target is likely:

```text
binary lesion / whole-tumor candidate = mask > 0
```

Candidate source per dataset:

| dataset | candidate source mask | mapping | status |
|---|---|---|---|
| MU-Glioma-Post | `tumorMask` | `mask > 0` | feasible, semantic still source-verify |
| UCSD-PTGBM | `BraTS_tumor_seg` | `mask > 0` | feasible; avoids component-mask ambiguity |
| UPENN-GBM | `UPENN_segm` | `mask > 0` | feasible, semantic still source-verify |
| UTSW | `tumorseg_FeTS` | `mask > 0` | feasible for all units, but 3 empty masks require review |
| UTSW | `rtumorseg_manual_correction` | `mask > 0` | feasible for 362 corrected units only |

Not recommended:

```text
UTSW tumorseg_manual_correction
```

Reason: 158 files do not match structural MRI geometry.

## Research Implications

The data can support a segmentation-centered research direction, but only after
target mapping is locked. The strongest near-term path is:

1. Define binary whole-tumor / lesion target using nonzero labels.
2. Treat UCSD cellular component masks as auxiliary analysis, not the primary
   all-consortium target.
3. Decide whether UTSW uses FeTS consistently or registered manual corrections
   where available.
4. Exclude or manually inspect empty/suspicious whole-tumor masks before cohort
   manifest creation.

## Remaining Blockers Before Training

- Source-document verification of label semantics for values 1/2/3/4/5.
- UTSW target-source decision: FeTS-only versus registered manual-correction
  precedence.
- Unit selection policy for multi-session MU and UCSD.
- Official cohort manifest.
- Subject-level LOCO split manifest.
- Baseline protocol lock.

## Do Not Do Yet

- Do not train a segmentation model.
- Do not create a split.
- Do not claim novelty.
- Do not use unregistered UTSW manual corrections as supervision.
