# Post-Split Loader Smoke Contract

## Purpose

Before any GPU job, prove that the official split manifest can be read into a
minimal CPU data path.

## Required Commands After Split Approval

The consolidated post-split validation runner should smoke all held-out
consortia:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

That runner invokes the bounded loader smoke for each held-out consortium:

```text
MU-Glioma-Post
UCSD-PTGBM
UPENN-GBM
UTSW
```

Manual single-fold smoke remains available for debugging:

```bash
python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset UCSD-PTGBM \
  --split-role test \
  --max-rows 8
```

This is a smoke check, not preprocessing.

## What It Must Verify

- selected manifest exists,
- selected rows exist,
- T1/T1ce/T2/FLAIR paths load,
- selected mask path loads,
- all five volumes have matching shape,
- all five volumes have matching affine,
- all five volumes have matching orientation,
- all five volumes have matching voxel spacing,
- all loaded arrays contain finite values,
- mask has nonzero target voxels.

## Optional Pre-Split Development Smoke

Before official split approval, the same script may be run on the subject-level
draft manifest for bounded read-only development checks. This does not replace
the required post-split smoke.

Example:

```bash
python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py \
  --manifest research_gsure/02_audits/outputs/subject_level_cohort_manifest_draft.csv \
  --dataset UCSD-PTGBM \
  --max-rows 2
```

## Tensor Convention For Later Loader

The training data loader must expose:

```text
image: [B, C, D, H, W]
mask:  [B, 1, D, H, W]
C = 4 in order [T1, T1ce, T2, FLAIR]
target = selected_mask > 0
```

## Non-Negotiable Rules

- Do not write preprocessed arrays into raw data.
- Do not create cached tensors before split approval.
- Do not use clinical metadata as model input for the image-only baseline.
- Do not generate reliability labels from in-sample predictions.
