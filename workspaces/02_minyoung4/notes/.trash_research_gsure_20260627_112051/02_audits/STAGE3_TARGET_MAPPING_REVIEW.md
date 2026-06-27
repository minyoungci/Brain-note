# Stage 3 Target Mapping Review

## Scope

This review evaluates target-mask mapping policies using Stage 1 and Stage 2
audit outputs. It does not create an official cohort manifest, split, or
preprocessed data.

## Research Decision Under Review

Candidate primary target:

```text
binary whole-lesion / whole-tumor = selected_mask > 0
```

This is a conservative target. It intentionally avoids subregion harmonization
until integer label semantics are source-verified across all datasets.

## Source Semantics Evidence

### Local evidence

MU-Glioma-Post directly defines its labels in
`MU-Glioma-Post_Segmentation_Volumes.xlsx`:

| label | local sheet meaning |
|---:|---|
| 1 | Necrotic Tumor Core |
| 2 | Tumor Infiltration and Edema |
| 3 | Enhancing Tumor Core |
| 4 | Resection Cavity |

UPENN local evidence confirms ED/ET/NC region naming through CaPTk radiomic
feature filenames, but not a direct integer label dictionary in the local files.

UTSW local metadata confirms whether a subject has manually refined
segmentation, but does not define labels `3` or `5`.

### External context checked

- UPENN-GBM Scientific Data states tumor segmentation labels were reviewed and
  manually refined, including ET/NCR/ED regions:
  <https://www.nature.com/articles/s41597-022-01560-7>
- BraTS pre-treatment documentation uses the conventional labels
  `1=NCR/NET`, `2=ED`, `4=ET`:
  <https://www.med.upenn.edu/cbica/brats2018/data.html>
- BraTS 2024 post-treatment documentation defines ET, NETC, SNFH, and RC as
  relevant post-treatment tissue classes and emphasizes treatment-related
  ambiguity:
  <https://arxiv.org/html/2405.18368v1>

Important caveat:

```text
External conventions support interpretation, but local observed labels and
source-specific masks must control our target policy.
```

## Candidate Policy Results

Policy A:

```text
binary_whole_lesion_fets_only
```

| dataset | included / units |
|---|---:|
| MU-Glioma-Post | 594 / 594 |
| UCSD-PTGBM | 243 / 243 |
| UPENN-GBM | 611 / 611 |
| UTSW | 622 / 625 |
| total | 2070 / 2073 |

UTSW exclusions:

```text
BT0926, BT1016, BT1090
```

Reason: empty `tumorseg_FeTS`.

Policy B:

```text
binary_whole_lesion_registered_manual_preferred
```

| dataset | included / units |
|---|---:|
| MU-Glioma-Post | 594 / 594 |
| UCSD-PTGBM | 243 / 243 |
| UPENN-GBM | 611 / 611 |
| UTSW | 622 / 625 |
| total | 2070 / 2073 |

UTSW selected source under Policy B:

- `rtumorseg_manual_correction`: 362 units.
- `tumorseg_FeTS`: 263 units.

## Critical Review

### Policy A strengths

- Uniform UTSW supervision source.
- Avoids unverified UTSW labels `3` and `5`.
- Easier to explain as a first official baseline target.
- Keeps broad sample size.

### Policy A weaknesses

- Does not use registered manual corrections where available.
- Excludes three empty UTSW FeTS masks.

### Policy B strengths

- Uses geometry-valid registered manual correction where available.
- May be a better annotation-quality sensitivity analysis.

### Policy B weaknesses

- Introduces mixed supervision source inside UTSW.
- Registered manual corrections contain label `3` in 116 units and label `5` in
  5 units.
- Label `5` is not source-verified in local metadata.

## Recommendation

Use Policy A as the first official target policy:

```text
binary_whole_lesion_fets_only
```

Use Policy B only as a sensitivity analysis after the first baseline:

```text
binary_whole_lesion_registered_manual_preferred
```

Do not use:

```text
UTSW tumorseg_manual_correction
```

Reason:

- 158 geometry mismatches.
- A registered alternative exists for the same corrected subset.

## Remaining Decisions Before Cohort Manifest

1. Min approval of binary `selected_mask > 0` as primary target.
2. Min approval of UTSW FeTS-only as primary source.
3. Explicit exclusion or manual review decision for `BT0926`, `BT1016`,
   `BT1090`.
4. Session/timepoint policy for MU and UCSD.

## Next Step

After approval, generate a draft candidate cohort manifest with:

- dataset,
- subject_id,
- unit_id,
- selected four MRI paths,
- selected mask path,
- target policy,
- inclusion flag,
- exclusion/review reason.
