# Timing-Warning Sensitivity Contract

## Scope

This contract defines the required timing-warning sensitivity analyses for the
first G-SURE segmentation reliability study.

It does not approve:

- official split creation,
- GPU training,
- inference,
- prediction generation,
- reliability label generation,
- metric computation.

## Research Goal Reminder

The primary G-SURE task is cross-consortium glioma MRI segmentation reliability.
The current primary split recommendation keeps all 1,614 subject rows, including
MU/UCSD timing-warning rows, because pre-split exclusion would materially weaken
the UCSD held-out fold.

This choice is defensible only if timing-warning sensitivity analyses are
mandatory before final claims.

## Timing Groups

Every subject-level result table after official split creation must be able to
identify these groups from the subject manifest:

```text
timing_group = no_warning
timing_group = mu_missing_days_from_diagnosis
timing_group = ucsd_missing_acquisition_to_initial_event_offset
timing_group = ucsd_scan_more_than_1y_after_initial_event
```

The current draft subject-level cohort has:

| timing group | subjects |
|---|---:|
| no warning | 1,539 |
| MU missing days from diagnosis | 12 |
| UCSD missing acquisition-to-initial-event offset | 37 |
| UCSD scan more than 1y after initial event | 26 |
| total | 1,614 |

## Required Primary Reporting

The primary headline analysis uses the approved keep-all official LOCO split.

All primary tables must report:

- total eligible subjects,
- timing-warning subject count,
- timing-warning count by held-out consortium,
- whether the metric is pooled, per-consortium, or subgroup-specific.

## Required Sensitivity Reporting

primary keep-all results require no-warning and UCSD high-risk subgroup
sensitivity before final claims.

Before any final G-SURE method claim, rerun segmentation and reliability metrics
on:

1. the no-warning subset,
2. the UCSD no-warning subset,
3. the UCSD `scan >1y` high-risk subgroup if sample size is sufficient,
4. warning versus no-warning rows within each consortium where sample size is
   sufficient.

Minimum metrics to repeat:

- Dice,
- `Dice <= 0.8` subject failure rate,
- ERR AUROC/AUPRC for reliability maps,
- FP and FN AUPRC separately,
- top-k error capture,
- subject-level failure AUROC/AUPRC when available.

Small groups must report row counts and may be marked exploratory. They must not
be hidden.

## No-Claim Rules

Do not make a final G-SURE reliability claim if:

- the method improves only on timing-warning rows,
- the method collapses on the no-warning subset,
- the UCSD held-out result is driven entirely by `scan >1y` rows,
- timing-warning subgroup counts are missing from the report,
- timing-warning subgroup metrics are omitted without a row-count explanation.

If a sensitivity result contradicts the primary keep-all result, narrow the
claim to mixed-treatment/mixed-timing segmentation reliability or stop the method
claim.

## Relation To Other Contracts

This contract extends:

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md
```

It does not replace the official split, prediction artifact, reliability label,
or reliability metric validation requirements.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
