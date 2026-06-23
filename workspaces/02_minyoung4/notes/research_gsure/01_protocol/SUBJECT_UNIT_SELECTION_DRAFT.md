# Subject / Unit Selection Draft

## Purpose

Convert the unit-level candidate cohort into a primary subject-level cohort
without leaking repeated visits or overweighting longitudinal subjects.

## Recommended Primary Policy

```text
one_unit_per_subject_earliest_numeric_order
```

For each `dataset::subject_id`, select the included unit with the lowest numeric
unit/session/timepoint order.

Examples:

- MU: `Timepoint_1` before `Timepoint_2`.
- UCSD: `_01` before `_02`.
- UPENN: `_11` is the only included segmentation-bearing unit under the current
  policy.
- UTSW: one unit per subject.

## Why This Policy

- Avoids subject duplication in the primary cohort.
- Simplifies subject-level LOCO splitting.
- Prevents longitudinal subjects from dominating training and metrics.
- Keeps all secondary units available for sensitivity analysis.

## What This Does Not Prove

- It does not prove selected scans are pre-treatment.
- It does not solve post-treatment heterogeneity.
- It does not create a split.
- It does not authorize GPU training.

## Metadata Timing Signals

Metadata timing is attached where available:

- MU: days from diagnosis to MRI for each timepoint.
- UCSD: days from acquisition to initial surgery/treatment/diagnosis and last
  prior surgery.
- UPENN: time since baseline preop.
- UTSW: operation status.

These fields are for review and reporting. They are not model inputs.

## Primary Output

- `outputs/subject_level_cohort_manifest_draft.csv`

Expected row count after current audits:

```text
1,614 selected subject-level rows
```

## Sensitivity Output

- `outputs/unit_selection_review.csv`

This keeps all `2,070` valid included units and marks primary/secondary status.

## Remaining Gate

Before split creation, Min must approve:

1. one-unit-per-subject primary policy,
2. all-valid-units sensitivity policy,
3. disclosure of post-treatment timing heterogeneity.
