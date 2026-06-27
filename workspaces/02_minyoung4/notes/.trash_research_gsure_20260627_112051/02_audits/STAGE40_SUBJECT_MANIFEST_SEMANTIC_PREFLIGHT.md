# Stage 40 - Subject Manifest Semantic Preflight

## Task

Strengthen the pre-split readiness check so the draft subject-level cohort
manifest must match the G-SURE approval decision and primary segmentation target.

## Research Question

Could the subject-level cohort manifest keep the correct row counts and paths
while silently changing the target policy, selected-unit policy, mask source, or
subject-level uniqueness?

## Why This Matters

Official split creation will materialize the current subject-level draft into
four LOCO folds. If the manifest drifts before split creation, the official split
could no longer correspond to the reviewed G-SURE task.

## What Changed

`check_pre_split_readiness.py` now checks the subject-level cohort manifest for:

- required semantic columns,
- exactly 1,614 rows,
- expected dataset counts,
- no duplicate `dataset::subject_id` leakage groups,
- `policy = binary_whole_lesion_fets_only`,
- `target_definition = selected_mask > 0`,
- `selection_policy = one_unit_per_subject_earliest_numeric_order`,
- `include_candidate = 1`,
- `is_primary_subject_unit = 1`,
- `selection_rank = 1`,
- dataset-specific primary mask keys:
  - `MU-Glioma-Post -> tumorMask`
  - `UCSD-PTGBM -> BraTS_tumor_seg`
  - `UPENN-GBM -> UPENN_segm`
  - `UTSW -> tumorseg_FeTS`
- positive `mask_nonzero_voxels`,
- valid `0 < mask_nonzero_fraction <= 1`,
- `all_modalities_shape_affine_match_mask = 1`,
- required 4-channel MRI and selected-mask paths.

## Guardrails

- This does not create official split artifacts.
- This does not load NIfTI image data.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --subject-manifest-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This makes the official split gate more defensible. It proves that the current
CSV metadata matches the reviewed cohort/target policy; it does not prove image
quality, segmentation performance, reliability generalization, novelty, or GPU
feasibility.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
