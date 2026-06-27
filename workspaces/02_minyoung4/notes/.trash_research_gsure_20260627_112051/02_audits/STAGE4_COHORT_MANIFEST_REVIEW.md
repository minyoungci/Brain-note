# Stage 4 Candidate Cohort Manifest Review

## Scope

This review is based on the approved draft target policy:

```text
binary_whole_lesion_fets_only
selected_mask > 0
```

The generated manifest is unit-level. It is not a train/test split and is not
yet the official subject-level cohort.

## Outputs

- `outputs/candidate_cohort_manifest_draft.csv`
- `outputs/candidate_cohort_summary.csv`
- `outputs/candidate_cohort_manifest_report.md`

## Top-Level Result

| item | count |
|---|---:|
| units reviewed | 2,135 |
| include candidates | 2,070 |
| excluded by hard criteria | 65 |
| included subjects | 1,614 |
| included units with review flags | 878 |

All 2,070 included unit rows have selected T1, T1ce, T2, and FLAIR paths that
match the selected mask by shape and affine.

## Dataset Summary

| dataset | units | included units | subjects | included subjects | excluded |
|---|---:|---:|---:|---:|---:|
| MU-Glioma-Post | 596 | 594 | 203 | 203 | 2 |
| UCSD-PTGBM | 243 | 243 | 178 | 178 | 0 |
| UPENN-GBM | 671 | 611 | 630 | 611 | 60 |
| UTSW | 625 | 622 | 625 | 622 | 3 |
| total | 2,135 | 2,070 | 1,636 | 1,614 | 65 |

## Selected MRI Policy Observed

The builder selected MRI paths only when they matched the selected mask geometry:

- MU: `brain_t1n`, `brain_t1c`, `brain_t2w`, `brain_t2f`.
- UCSD: `T1pre`, `T1post`, `T2`, `FLAIR`.
- UPENN: stripped `images_structural` paths preferred over unstripped variants.
- UTSW: `_ants` registered structural paths selected for all included units.

## Hard Exclusions

### MU-Glioma-Post

Two units have all four structural MRI candidates but no selected `tumorMask`:

- `PatientID_0187::Timepoint_3`
- `PatientID_0191::Timepoint_1`

### UPENN-GBM

Sixty `_21` units have structural MRI but no selected segmentation mask. These
are excluded from the first target-policy manifest.

### UTSW

Three units have empty selected `tumorseg_FeTS` masks:

- `BT0926`
- `BT1016`
- `BT1090`

## Review Flags

Review flags do not exclude a unit. They indicate unresolved design decisions.

Included units with review flags:

- MU/UCSD timepoint or session policy not locked: 837 units.
- Multiunit subject requires selection policy: 701 units.

This means the unit-level manifest is ready, but the official experiment cohort
is not ready.

## Critical Interpretation

The headline number for possible unit-level segmentation training is 2,070
included units. The more conservative subject-level ceiling is 1,614 included
subjects if exactly one unit is selected per subject.

For a first publishable segmentation reliability study, the safer primary cohort
is likely:

```text
one selected unit per subject as primary,
all valid units as sensitivity analysis with subject-grouped statistics.
```

Reason:

- It avoids overweighting longitudinal MU/UCSD subjects.
- It simplifies subject-level leakage prevention.
- It makes LOCO and per-subject reporting easier to defend.

## Next Gate

Do not create splits or train yet. The next required decision is the subject/unit
selection policy:

1. one unit per subject primary, or
2. all valid units with subject-grouped split/statistics.

Recommended:

```text
one unit per subject primary;
all units sensitivity only.
```
