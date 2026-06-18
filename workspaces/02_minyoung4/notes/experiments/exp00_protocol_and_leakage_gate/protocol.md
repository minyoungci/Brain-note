# Protocol Draft

Status: draft. Not yet approved for final split generation, preprocessing, or training.

## Task

Glioma MRI IDH prediction.

## Research Question

Can a shift-aware 3D MRI modeling strategy outperform strong 3D CNN/Res3DNet-style
baselines under subject-isolated and leave-one-consortium-out evaluation?

## Outcome

IDH mutant vs wildtype.

Label source and value mapping are defined in `label_policy.md`.

## Input / Exposure

Primary imaging:

- T1
- T1ce or T1post
- T2
- FLAIR

Optional training-time signals:

- segmentation mask;
- age;
- sex;
- scanner/vendor/field strength for reporting, regularization, or diagnostic ablations.

## Unit of Analysis

Subject.

Group key:

```text
dataset::subject_id
```

## Cohort / Filters

Primary cohort:

```text
eligible_T1_structural_idh
```

Known EDA counts:

- subjects: 1,457
- IDH mutant: 235
- IDH wildtype: 1,222

Variant cohort:

```text
eligible_T1b_structural_segmentation_idh
```

Known EDA counts:

- subjects: 1,439
- IDH mutant: 232
- IDH wildtype: 1,207

## Split Policy

Primary:

- leave-one-consortium-out;
- subject-isolated;
- no held-out consortium used for model selection.

Secondary:

- grouped train/validation inside non-held-out consortia only.

## Leakage Risks

- subject/session/visit leakage;
- dataset and scanner shortcut;
- age shortcut;
- segmentation availability leakage;
- zero-byte or missing masks changing cohort composition;
- normalization statistics using validation/test data;
- calibration or threshold tuning on held-out consortium.

## Files To Change

At protocol stage:

- experiment-local Markdown and CSV only.

After approval:

- experiment-local configs/scripts/results.

## Expected Artifact

- approved protocol;
- approved label policy;
- split policy;
- preprocessing policy;
- mask policy;
- leakage checklist.

## Validation

- Manifest path validity.
- Subject-group split isolation.
- Train-only transforms/statistics.
- Subject-level metric aggregation.

## Unclear Assumptions

- Whether full 1mm isotropic resampling is required.
- Whether zero-byte UCSD mask can be repaired or must be excluded for mask experiments.
- Whether UPENN old vs non-old duplicate path preference should use newest or canonical non-old path.

## Needs Min Approval

- final split file generation;
- full NIfTI header audit;
- preprocessing outputs;
- GPU training;
- any shared-data writes.
