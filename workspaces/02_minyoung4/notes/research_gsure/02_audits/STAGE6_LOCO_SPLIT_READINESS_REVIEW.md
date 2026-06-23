# Stage 6 LOCO Split Readiness Review

## Scope

This is a readiness audit only. It does not create an official split manifest.

Inputs:

- `outputs/subject_level_cohort_manifest_draft.csv`
- `outputs/unit_selection_review.csv`

Outputs:

- `outputs/loco_split_readiness_by_fold.csv`
- `outputs/loco_split_readiness_by_dataset.csv`
- `outputs/loco_split_readiness_report.md`

## Research Goal Reminder

G-SURE is intended to study:

```text
3D glioma MRI segmentation with spatial reliability / visual grounding under
cross-consortium shift.
```

Therefore, cross-consortium evaluation is not optional. LOCO is the correct
first split family if the cohort supports it.

## Readiness Result

| held-out consortium | test subjects | train subjects | subject overlap | secondary-unit leak |
|---|---:|---:|---:|---:|
| MU-Glioma-Post | 203 | 1,411 | 0 | 0 |
| UCSD-PTGBM | 178 | 1,436 | 0 | 0 |
| UPENN-GBM | 611 | 1,003 | 0 | 0 |
| UTSW | 622 | 992 | 0 | 0 |

Hard leakage checks passed:

- no primary subject appears in train and test in any LOCO fold,
- no held-out subject's secondary units leak into train,
- primary manifest is one row per subject.

## Distribution Risks

### Dataset size imbalance

UCSD and MU are much smaller than UPENN and UTSW. Per-fold metrics should report
both:

- unweighted mean across held-out consortia,
- pooled subject-level metrics with clear caveats.

### Lesion burden shift

Median nonzero mask fraction:

| dataset | median fraction |
|---|---:|
| UCSD-PTGBM | 0.003778 |
| MU-Glioma-Post | 0.007663 |
| UTSW | 0.007836 |
| UPENN-GBM | 0.008578 |

UCSD has a lower median lesion fraction than the other datasets. Dice and
failure metrics must be lesion-size stratified.

### Timing / treatment warning concentration

Timing warning rows:

| dataset | selected rows with timing warnings |
|---|---:|
| MU-Glioma-Post | 12 |
| UCSD-PTGBM | 63 |
| UPENN-GBM | 0 |
| UTSW | 0 |

When UCSD is held out, all UCSD timing warnings sit in the test fold. This is
not leakage, but it is an important external-validity caveat.

### Geometry / orientation shift

UCSD selected masks are `256x256x256` and `ILA`, while MU/UPENN/UTSW are
primarily `240x240x155` and `LPS`. This is expected from source preprocessing,
but preprocessing and augmentation must not hide this as a silent site cue.

## Current Recommendation

The subject-level cohort is ready for Min to approve official LOCO split
manifest creation.

Do not train yet. After approval, create:

```text
outputs/loco_split_manifest.csv
outputs/loco_split_audit_report.md
```

Then run a data-loader smoke test before any GPU job.
