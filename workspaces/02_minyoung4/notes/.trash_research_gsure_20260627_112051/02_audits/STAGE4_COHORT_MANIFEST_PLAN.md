# Stage 4 Candidate Cohort Manifest Plan

## Purpose

Create a unit-level manifest for the approved first target policy:

```text
binary_whole_lesion_fets_only
selected_mask > 0
```

This stage does not create a split and does not preprocess images.

## Manifest Unit

The draft manifest is one row per imaging unit, not one row per final subject.
This is intentional because MU and UCSD contain repeated sessions/timepoints,
and subject-level selection is not locked yet.

## Required Columns

- dataset
- subject_id
- unit_id
- selected mask key/path
- selected T1 path
- selected T1ce path
- selected T2 path
- selected FLAIR path
- inclusion flag
- exclusion reason
- review flag
- review reason

## Inclusion Rules

Hard include candidate requirements:

1. selected mask exists,
2. selected mask loads,
3. selected mask is non-empty,
4. selected mask has same-unit structural geometry match,
5. all four selected MRI paths exist,
6. each selected MRI path matches selected mask by shape and affine.

Review flags do not exclude by themselves. They identify unresolved design
questions before the official cohort is locked.

## Approved Target Policy

| dataset | selected mask |
|---|---|
| MU-Glioma-Post | `tumorMask` |
| UCSD-PTGBM | `BraTS_tumor_seg` |
| UPENN-GBM | `UPENN_segm` |
| UTSW | `tumorseg_FeTS` |

## Expected Blockers

- UTSW empty FeTS masks: `BT0926`, `BT1016`, `BT1090`.
- MU and UCSD multi-session/timepoint selection policy.
- UPENN scan suffix review for non-baseline-looking units.

## Output

- `outputs/candidate_cohort_manifest_draft.csv`
- `outputs/candidate_cohort_summary.csv`
- `outputs/candidate_cohort_manifest_report.md`
