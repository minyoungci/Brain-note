# Age Semantics Audit

Created: 2026-06-19

Status: hard blocker for final exp02 image modeling.

## Bottom Line

`age_years_subject` is not semantically uniform across consortia.

The current exp01 `B0_clinical_only` result is valid as a draft shortcut diagnostic, but it is
not yet valid as a final clinical-adjustment comparator for image modeling.

## Dataset-Level Source Semantics

| dataset | raw source column used by harmonization | apparent meaning | verdict |
|---|---|---|---|
| UTSW | `Age at Imaging` | age at imaging | usable as scan/imaging age |
| UPENN-GBM | `Age_at_scan_years` | age at scan | usable as scan age, but subject-level aggregation must be defined |
| MU-Glioma-Post | `Age at diagnosis` | age at diagnosis | not scan age; must derive or explicitly model as diagnosis-age |
| UCSD-PTGBM | `Patient's Age` | ambiguous subject/session age | not safe to assume scan age |

## Evidence

Harmonization code currently maps:

- UTSW: `Age at Imaging` -> `age_years`
- MU-Glioma-Post: `Age at diagnosis` -> `age_years`
- UCSD-PTGBM: `Patient's Age` -> `age_years`
- UPENN-GBM: `Age_at_scan_years` -> `age_years`

Raw metadata checks under workspace `data/`:

- UTSW raw file has explicit `Age at Imaging`.
- UPENN raw clinical file has explicit `Age_at_scan_years`.
- MU raw clinical file has `Age at diagnosis` plus per-timepoint MRI offsets such as
  `Number of Days from Diagnosis to 1st MRI (Timepoint_1)`.
- UCSD raw clinical file has `Patient's Age` plus acquisition-relative offsets such as
  `Days from Acquisition to Date of initial surgery, treatment or diagnosis`.

## MU-Glioma-Post Scan-Age Drift

MU has enough fields to estimate scan age:

```text
estimated_scan_age = Age at diagnosis + days_from_diagnosis_to_mri / 365.25
```

Across available MRI timepoint rows:

- rows with MRI-day offsets: 597
- mean age delta from diagnosis to MRI: 0.533 years
- median delta: 0.427 years
- min delta: -2.642 years
- max delta: 3.647 years
- age-bin changes if scan-age is used: 10 / 597 MRI timepoint rows
- negative MRI offsets: 13 / 597 MRI timepoint rows

Interpretation:

- Current MU age is diagnosis-age, not scan-age.
- For scan-level image modeling, MU should use estimated scan-age where the MRI offset is valid.
- Negative MRI offsets require review before automatic correction.

## UCSD-PTGBM Ambiguity

UCSD is session-level and has repeated subject sessions.

Repeated-session check among rows with both age and acquisition-offset fields:

- rows with age and acquisition offset: 198
- repeated subjects: 37
- max age range across repeated sessions: 0
- repeated subjects with constant age despite acquisition span >1 year: 7
- largest acquisition-relative span among repeated sessions: 2.65 years

Interpretation:

- `Patient's Age` does not behave like precise session-level scan age.
- It may be age at initial event, de-identified/rounded subject age, or another subject-level age.
- It must not be assumed to be scan-age without source documentation.

## UPENN-GBM Subject Aggregation Caveat

UPENN clinical age is scan-level, but the subject-level modeling table aggregates subject age.

Repeated scan check:

- repeated subjects: 41
- mean scan-age range among repeated subjects: 0.864 years
- max scan-age range: 2.76 years

Interpretation:

- For scan-level image modeling, use scan-level `Age_at_scan_years`.
- For subject-level modeling, define whether age is baseline scan age, median scan age, or selected
  image-unit age.

## Consequence for exp02

Do not start GPU image modeling until an age policy is approved.

Minimum acceptable policy:

1. UTSW: use `Age at Imaging`.
2. UPENN: use scan-level `Age_at_scan_years`; if subject-level, define selected scan first.
3. MU: either derive scan-age from diagnosis age plus MRI offset, or explicitly label it as
   diagnosis-age and exclude it from scan-age residualization.
4. UCSD: verify `Patient's Age` source semantics; until verified, treat it as ambiguous
   subject-level age, not scan age.

## Current Research Implication

The research topic is not locked. The strongest current candidate is no longer simply
`IDH prediction from MRI`; it is:

> testing whether glioma MRI adds IDH-relevant value beyond non-uniform clinical age and
> brain-age confounding under multi-consortium shift.
