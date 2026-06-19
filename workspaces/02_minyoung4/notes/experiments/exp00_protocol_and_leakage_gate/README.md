# exp00: Protocol and Leakage Gate

Status: scaffold only. No split file, preprocessing output, or training has been created.

## Objective

Freeze the experimental protocol before any model is trained.
This experiment is a gate, not a performance experiment.

## Questions

- Which subjects are eligible for the primary IDH task?
- Are all units grouped by `dataset::subject_id`?
- What is the exact leave-one-consortium-out policy?
- What image preprocessing is allowed, and which statistics are train-only?
- How are missing or corrupted segmentation masks handled?

## Inputs

- `docs/context/research_cohort_membership.csv`
- `docs/context/research_cohort_summary.csv`
- `docs/context/candidate_task_bias_audit.md`
- `docs/context/nifti_zero_byte_files.csv`
- `docs/context/upenn_nifti_manifest_gap.csv`

## Required Decisions

- Primary cohort: `eligible_T1_structural_idh`.
- Unit of analysis: subject.
- Group key: `dataset::subject_id`.
- Primary evaluation: leave-one-consortium-out.
- Mask policy: exclude or repair known zero-byte mask before mask-dependent experiments.
- UPENN duplicate structural path policy: choose old vs non-old path preference before preprocessing.

## Expected Artifacts

- `protocol.md`
- `label_policy.md`
- `age_semantics_audit.md`
- `split_policy.md`
- `preprocessing_policy.md`
- `mask_policy.md`
- `leakage_checklist.md`

These files should be produced before exp01 or any image model implementation is treated as official.

## Validation

- Manifest rows map to existing files.
- No subject appears in both train and held-out evaluation.
- No train statistic is computed on validation/test.
- All class balancing is train-only.

## Approval Gate

Min approval is required before:

- final split files are written;
- age policy is treated as final for clinical adjustment;
- full NIfTI header audit is run;
- preprocessing outputs are created;
- GPU training starts.
