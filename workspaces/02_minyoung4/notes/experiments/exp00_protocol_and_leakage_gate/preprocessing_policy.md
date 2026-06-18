# Preprocessing Policy Draft

Status: draft.

No preprocessing output has been created.

## Required Before Preprocessing

- Full NIfTI header audit approval.
- Shape, affine, orientation, and spacing summary.
- UPENN duplicate old/non-old structural path preference.
- Confirm train-only or per-volume normalization scope.

## Allowed Draft Choices

- Per-volume intensity normalization is allowed as a candidate because it does not use
  validation/test cohort statistics.
- Train-only global statistics may be allowed if computed only inside each training fold.
- Spatial resampling/cropping policy must be documented before implementation.

## Forbidden

- Global normalization over all subjects before split.
- Any preprocessing that writes into `/home/vlm/data/raw/`.
- Any overwrite of shared preprocessed artifacts without approval.

