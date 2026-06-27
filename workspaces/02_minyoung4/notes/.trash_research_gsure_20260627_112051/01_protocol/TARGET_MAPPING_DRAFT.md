# Target Mapping Draft

This is a draft policy review for the first G-SURE segmentation target. It is
not yet an official cohort manifest or split.

## Proposed Primary Target

```text
binary whole-lesion / whole-tumor candidate = selected_mask > 0
```

Rationale:

- It is the only target that can plausibly span all four datasets without
  mixing incompatible subregion definitions.
- It avoids relying on exact subregion label-number harmonization before that is
  fully verified.
- It is suitable for the first reliability/grounding task because segmentation
  failure can be measured against one binary lesion support.

## Local Evidence

### MU-Glioma-Post

Local file:

```text
data/MU-Glioma-Post/MU-Glioma-Post_Segmentation_Volumes.xlsx
```

The workbook directly names four label sheets:

- Label 1: necrotic tumor core.
- Label 2: tumor infiltration and edema.
- Label 3: enhancing tumor core.
- Label 4: resection cavity.

Recommended primary source:

```text
tumorMask, mapped as mask > 0
```

### UCSD-PTGBM

Local files include:

- `BraTS_tumor_seg`
- `enhancing_cellular_tumor_seg`
- `non_enhancing_cellular_tumor_seg`
- `total_cellular_tumor_seg`

The component masks are binary and frequently empty, which may represent absent
cellular components. They should not define the all-consortium primary target.

Recommended primary source:

```text
BraTS_tumor_seg, mapped as mask > 0
```

### UPENN-GBM

Local files include:

```text
images_segm/<scan_id>_segm.nii.gz
```

Local `radiomic_features_CaPTk.zip` contains feature files named by ED, ET, and
NC regions. The local availability table distinguishes automatic and corrected
tumor segmentation but does not directly define integer label semantics.

Recommended primary source:

```text
UPENN_segm, mapped as mask > 0
```

### UTSW

Local files include:

- `tumorseg_FeTS`
- `tumorseg_manual_correction`
- `rtumorseg_manual_correction`

Stage 2 geometry audit found:

- `tumorseg_FeTS`: geometry matches all 625 units, but 3 masks are empty.
- `tumorseg_manual_correction`: 158 geometry mismatches.
- `rtumorseg_manual_correction`: geometry matches all 362 corrected units.

Do not use:

```text
tumorseg_manual_correction
```

Recommended source policy options:

1. `tumorseg_FeTS` for every UTSW unit.
2. `rtumorseg_manual_correction` where present, otherwise `tumorseg_FeTS`.

## External Evidence Checked

Literature/source verification was used only to contextualize label semantics,
not to override local audits.

- UPENN-GBM Scientific Data states that tumor segmentation labels were reviewed
  and manually refined where needed, including ET, NCR, and ED regions.
- A UPENN-GBM derivative data page lists tumor segmentation labels as necrotic
  tissue, peritumoral edema, and enhancing tumor. This is useful support but is
  not treated as the primary official source for our local integer mapping.
- BraTS 2018/2020 documentation uses labels 1/2/4 for NCR/NET, ED, and ET in
  the pre-treatment convention.
- BraTS 2024 post-treatment glioma documentation defines ET, NETC, SNFH, and RC
  as the relevant post-treatment tissue classes and explicitly highlights RC as
  a new post-treatment subregion.

## Candidate Policies

### Policy A: FeTS-only UTSW

```text
MU    -> tumorMask > 0
UCSD  -> BraTS_tumor_seg > 0
UPENN -> UPENN_segm > 0
UTSW  -> tumorseg_FeTS > 0
```

Strength:

- Simpler and uniform within UTSW.
- Avoids mixing automatic and manually corrected masks.

Weakness:

- Ignores registered manual corrections.
- Includes three suspicious empty FeTS masks unless explicitly excluded.

### Policy B: Registered Manual Preferred UTSW

```text
MU    -> tumorMask > 0
UCSD  -> BraTS_tumor_seg > 0
UPENN -> UPENN_segm > 0
UTSW  -> rtumorseg_manual_correction > 0 when present, else tumorseg_FeTS > 0
```

Strength:

- Uses geometry-valid manual correction where available.
- Avoids the unregistered correction files.

Weakness:

- UTSW supervision source becomes heterogeneous.
- Needs a source-precedence statement in the protocol.

## Recommendation

Use Policy A as the first official candidate:

```text
binary_whole_lesion_fets_only
```

Reason:

- It is simpler and source-consistent within UTSW.
- UTSW FeTS masks use observed values drawn from `{0,1,2,4}` and do not contain
  the unexplained labels `3` or `5`.
- It avoids mixing automatic FeTS masks with registered manual corrections in
  the first baseline.
- It still covers 622 usable UTSW units after excluding three empty FeTS masks.

Use Policy B only as a sensitivity analysis:

```text
binary_whole_lesion_registered_manual_preferred
```

Reason:

- It may be higher quality where registered manual corrections exist.
- However, UTSW registered manual corrections contain label `3` in 116 units and
  label `5` in 5 units. These labels are not yet source-verified.
- Because of this, it is not the cleanest primary target even though binary
  `mask > 0` reduces the label-number risk.

Do not lock this as official until Min approves the source-precedence policy.

## Required Before Official Cohort Manifest

1. Approve binary `mask > 0` as the first target.
2. Approve UTSW FeTS-only as primary and registered manual correction as
   sensitivity analysis, or explicitly override this recommendation.
3. Decide whether to exclude suspicious empty whole-lesion masks.
4. Decide session/timepoint selection for MU and UCSD.
5. Generate candidate cohort manifest.
