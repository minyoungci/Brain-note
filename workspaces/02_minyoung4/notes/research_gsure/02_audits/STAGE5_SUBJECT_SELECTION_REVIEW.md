# Stage 5 Subject-Level Selection Review

## Scope

This review converts the unit-level candidate cohort into a draft primary
subject-level cohort. It does not create a split, preprocessing output, or
training job.

## Selection Policy

```text
one_unit_per_subject_earliest_numeric_order
```

For each `dataset::subject_id`, choose the included unit with the lowest numeric
unit/session/timepoint order.

All secondary units are preserved in:

```text
outputs/unit_selection_review.csv
```

## Outputs

- `outputs/subject_level_cohort_manifest_draft.csv`
- `outputs/unit_selection_review.csv`
- `outputs/subject_level_cohort_summary.csv`
- `outputs/subject_level_cohort_report.md`

## Top-Level Result

| item | count |
|---|---:|
| candidate units before subject selection | 2,070 |
| selected primary subject units | 1,614 |
| secondary valid units retained for sensitivity/review | 456 |
| duplicate primary `dataset::subject_id` rows | 0 |
| selected rows with all MRI/mask paths present | 1,614 |
| selected rows with all modalities matching mask geometry | 1,614 |

## Dataset Summary

| dataset | selected subjects | candidate units before selection | secondary units | selected unit order |
|---|---:|---:|---:|---|
| MU-Glioma-Post | 203 | 594 | 391 | `1:187;2:13;3:1;4:2` |
| UCSD-PTGBM | 178 | 243 | 65 | `01:178` |
| UPENN-GBM | 611 | 611 | 0 | `11:611` |
| UTSW | 622 | 622 | 0 | `1:622` |

## Timing / Treatment Warnings

These are disclosure and review items, not hard exclusions.

| warning | selected rows |
|---|---:|
| UCSD selected scan missing acquisition-to-initial-event offset | 37 |
| UCSD selected scan more than 1 year after initial event | 26 |
| MU selected timepoint missing days-from-diagnosis metadata | 12 |

Interpretation:

- UCSD is explicitly post-treatment/recurrent/pseudoprogression-oriented; this
  does not invalidate the segmentation task, but it must be disclosed.
- MU is post-treatment and longitudinal; one-unit selection avoids subject
  overweighting but does not make the cohort pre-treatment.
- UPENN selected `_11` units have `Time_since_baseline_preop=0` in the local
  clinical table.
- UTSW selected units have `Operation Status=PRE` in local metadata.

## Critical Review

The subject-level primary cohort is now technically coherent:

- one selected unit per subject,
- no subject duplication,
- selected mask path present,
- selected four MRI paths present,
- all selected MRI paths match selected mask by shape and affine.

However, it is still a draft. The remaining blocker is approval of the selection
policy and timing-disclosure stance.

## Recommendation

Use this as the primary cohort policy:

```text
primary = one selected unit per subject
sensitivity = all valid units with subject-grouped statistics
```

Do not create LOCO split manifests until this policy is approved.
