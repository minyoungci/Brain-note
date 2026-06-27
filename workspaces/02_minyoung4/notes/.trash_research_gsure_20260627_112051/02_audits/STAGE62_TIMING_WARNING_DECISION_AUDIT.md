# Stage 62 - Timing Warning Decision Audit

## Task

Quantify MU/UCSD timing warnings before official LOCO split creation.

## Research Question

Should the subject-level primary cohort exclude timing-warning rows before the
official split, or should timing warnings be retained in the primary split with
mandatory disclosure and sensitivity analysis?

## Why This Matters

The G-SURE task is cross-consortium segmentation reliability. Timing warnings
can indicate post-treatment or uncertain timing semantics, but excluding them
before split creation can also weaken the held-out consortium evaluation,
especially for UCSD.

## Evidence Read

Source:

```text
research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv
```

No raw data, preprocessing output, official split artifact, GPU job, prediction,
reliability label, or metric was created.

## Timing Warning Counts

| dataset | no warning | warning rows | warning type |
|---|---:|---:|---|
| MU-Glioma-Post | 191 | 12 | missing days from diagnosis |
| UCSD-PTGBM | 115 | 63 | 37 missing acquisition-to-event offset; 26 scan >1y after initial event |
| UPENN-GBM | 611 | 0 | none |
| UTSW | 622 | 0 | none |
| total | 1,539 | 75 | MU/UCSD only |

## Policy Scenarios

| scenario | total subjects | removed | MU | UCSD | UPENN | UTSW |
|---|---:|---:|---:|---:|---:|---:|
| keep all, disclosure-only | 1,614 | 0 | 203 | 178 | 611 | 622 |
| exclude any timing warning | 1,539 | 75 | 191 | 115 | 611 | 622 |
| exclude only known UCSD >1y | 1,588 | 26 | 203 | 152 | 611 | 622 |
| exclude UCSD missing or >1y, keep MU missing | 1,551 | 63 | 203 | 115 | 611 | 622 |
| exclude MU missing and UCSD >1y, keep UCSD missing | 1,576 | 38 | 191 | 152 | 611 | 622 |

## Lesion Fraction Check

Median mask fraction by primary keep-all cohort:

| dataset | subjects | median mask fraction |
|---|---:|---:|
| MU-Glioma-Post | 203 | 0.007663 |
| UCSD-PTGBM | 178 | 0.003778 |
| UPENN-GBM | 611 | 0.008578 |
| UTSW | 622 | 0.007836 |

Warning rows are not obviously trivial-lesion rows. UCSD warning rows have
higher median mask fractions than UCSD no-warning rows:

| dataset / warning type | rows | median mask fraction |
|---|---:|---:|
| UCSD no warning | 115 | 0.003082 |
| UCSD missing acquisition-to-event offset | 37 | 0.004956 |
| UCSD scan >1y after initial event | 26 | 0.005260 |
| MU no warning | 191 | 0.007440 |
| MU missing days from diagnosis | 12 | 0.008728 |

## Interpretation

Strictly excluding all timing-warning rows would remove 75 subjects and reduce
UCSD from 178 to 115 subjects. That would weaken the UCSD held-out fold and may
make cross-consortium reliability conclusions less stable. Missing timing fields
are not equivalent to invalid segmentation labels.

Known UCSD scans more than one year after initial event are a clearer semantic
risk than missing offsets, but removing only those rows changes the primary task
definition before baseline evidence exists.

## Recommendation

For the first official LOCO split:

```text
primary split = keep all 1,614 subject rows
timing warnings = disclosed and stratified
sensitivity analysis = required before final claims
```

Required sensitivity analysis after official split and baseline predictions:

1. rerun subject/fold summaries excluding all timing-warning rows,
2. rerun segmentation and reliability metrics on no-warning subsets where
   sample size is sufficient,
3. separately report UCSD `scan >1y` rows as a high-risk subgroup if retained.

## Reviewer Attack Points

- Mixed pre/post-treatment timing may make the task less clinically specific.
- UCSD timing warnings are concentrated in one held-out consortium.
- If reliability performance is driven by timing-warning rows, the claim should
  be narrowed to mixed-treatment segmentation reliability rather than a generic
  glioma segmentation method.

## Decision Status

This audit recommends disclosure-plus-sensitivity, not pre-split exclusion.
Min still must approve the official split policy before any official split
artifacts are written.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
