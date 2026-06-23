# LOCO Split Policy Draft

## Purpose

Define the intended split policy for G-SURE without creating the official split
yet.

## Research Goal Reminder

The research goal is not simply tumor segmentation. The goal is:

```text
3D glioma MRI segmentation with spatial reliability / visual grounding under
cross-consortium shift.
```

Therefore, the split must test cross-consortium generalization.

## Intended Primary Split

```text
Leave-One-Consortium-Out (LOCO)
```

For each fold:

- held-out dataset = one consortium,
- train datasets = remaining three consortia,
- unit of split = `dataset::subject_id`,
- primary row source = `subject_level_cohort_manifest_draft.csv`.

## What Is Not Allowed

- random unit-level split,
- mixing secondary longitudinal units into train/test against primary subjects,
- using all valid units as primary without subject grouping,
- creating reliability pseudo-labels from in-sample predictions.

## Required Validation Before Official Split

1. no subject overlap between train and test,
2. no secondary-unit leakage,
3. fold subject counts,
4. lesion-volume distribution by fold,
5. timing warning distribution by fold,
6. scanner strength distribution by fold,
7. selected mask/source consistency by fold.

## Current Status

Readiness audit only. Official split manifest is not created until Min approves:

```text
primary cohort = subject_level_cohort_manifest_draft.csv
selection policy = one_unit_per_subject_earliest_numeric_order
split policy = LOCO
```
