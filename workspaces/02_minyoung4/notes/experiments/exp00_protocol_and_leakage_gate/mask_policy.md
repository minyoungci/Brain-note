# Mask Policy Draft

Status: draft.

No mask-dependent experiment is official until this policy is approved.

## Known State

- Segmentation available for 1,617/1,636 subjects overall.
- Structural + segmentation + IDH cohort has 1,439 subjects.
- One UCSD segmentation file is zero-byte.
- UPENN has missing segmentation for 19 subjects.

## Default Modeling Role

Segmentation is a training-time auxiliary signal unless an experiment is explicitly labeled
mask-required.

## Required Handling

- Zero-byte masks must be repaired or excluded from mask-dependent training.
- Missing masks must be represented explicitly, not silently dropped unless the cohort variant
  says so.
- Mask availability must not be used as a shortcut for label prediction.

## Required Ablations

- mask available;
- mask dropped;
- mask corrupted/noisy;
- no-mask inference.

