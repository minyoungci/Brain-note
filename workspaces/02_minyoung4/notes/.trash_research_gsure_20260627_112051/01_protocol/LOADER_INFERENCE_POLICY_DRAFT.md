# Loader and Full-Volume Inference Policy Draft

## Scope

This is the pre-GPU loader/inference policy draft for the first G-SURE
segmentation baseline. It does not approve official split creation, preprocessing
cache creation, GPU execution, or training.

## Research Goal Reminder

G-SURE depends on full-volume out-of-fold segmentation predictions. Those
predictions become the evidence used to define segmentation error, uncertainty,
and reliability maps. Therefore, the loader and inference path must be designed
to avoid artificial crop, geometry, or mask-access artifacts.

## Primary Input Contract

Input channels:

```text
[T1, T1ce, T2, FLAIR]
```

Target:

```text
selected_mask > 0
```

Tensor convention for model code:

```text
image batch: [B, C, D, H, W]
mask batch:  [B, 1, D, H, W]
C = 4
```

Spatial axes `D,H,W` must correspond to the post-canonicalization array axes used
consistently for image and mask. Do not silently permute image and mask axes
differently.

## Canonical Geometry Policy

Allowed:

- Load NIfTI with nibabel.
- Apply in-memory closest-canonical orientation consistently to each MRI channel
  and mask.
- Treat RAS-canonical arrays as the model-space arrays.
- Verify all four MRI channels and the mask have matching shape, affine,
  orientation, and voxel spacing after loading/canonicalization.
- Keep all preprocessing in memory unless a separate cache-writing plan is
  explicitly approved.

Forbidden:

- Writing canonicalized volumes into `/home/vlm/data/raw/`.
- Mixing original-orientation images with canonical-orientation masks.
- Using shape equality alone as proof of co-registration.
- Resampling with interpolation before a reviewed resampling policy exists.
- Silently accepting affine, orientation, spacing, or finite-value mismatches.

Current evidence:

- MU/UPENN/UTSW selected units are generally `240x240x155 / LPS` before
  canonicalization.
- UCSD selected units are generally `256x256x256 / ILA` before canonicalization.
- Sampled rows became RAS-canonical with channel/mask geometry agreement in the
  Stage 9 and Stage 15 checks.

## Training Patch Policy

Allowed for training split only:

- Patch-based training.
- Foreground-biased patch sampling using train-split masks.
- Random/background patches to avoid all-positive patch bias.
- Train-only spatial/intensity augmentation.

Required:

- Sampling policy must be recorded in the run config.
- Any mask-based sampling may use only training labels.
- Validation/held-out masks may be used for metric computation only, not crop
  selection or tile placement.

Forbidden:

- Using held-out masks to center crops.
- Using lesion bounding boxes from held-out masks during inference.
- Reporting fixed-center crop inference as full-volume segmentation.

## Validation and Test Inference Policy

Required:

- Validation and held-out test predictions must be reconstructed as full-volume
  probability maps.
- Sliding-window tile placement must depend only on image shape and configured
  patch/overlap, not on the ground-truth mask.
- Output probability map shape must match the canonical input volume shape.
- Reliability/error labels must be computed only after full-volume assembly.

Forbidden:

- Patch-only error labels.
- Center-crop-only held-out prediction.
- Selecting patch shape by held-out Dice during GPU preview.

## First GPU Preview Candidates

Compare only the following candidates first:

| patch | overlap | role |
|---|---:|---|
| `160x192x160` | `0.50` | memory-conservative full-coverage candidate |
| `192x224x160` | `0.50` | larger-context candidate with higher memory risk |

Do not preview `224x224x160` first unless both candidates above clearly fit and
there is a reviewed reason to pay the extra memory cost.

## Why Fixed-Center Is Not Acceptable

The expanded 80-subject audit found that:

- `160x192x160` preserved lesion bbox extent in the sample, but failed one UCSD
  row under fixed-center containment.
- `192x224x160` also failed the same fixed-center UCSD row.
- Sliding-window coverage removed the full-volume coverage failure mode for the
  tested patch sizes.

Therefore, a fixed-center full-input baseline would be a loader artifact, not a
valid segmentation baseline for G-SURE.

## Minimum Post-Split Checks Before GPU

After official split approval and creation:

1. Run post-split loader smoke on `loco_split_manifest.csv`.
2. Confirm channel/mask shape, affine, orientation, spacing, finite values, and
   non-empty mask target.
3. Run split-aware tile budget on official held-out test rows.
4. Run a CPU dry-run of tile grid generation for the selected patch candidates.
5. Prepare GPU command preview; do not run it without separate approval.

Current draft-cohort tile-grid evidence:

- `160x192x160@0.50`: 0 coverage failures over 1,614 draft subject rows.
- `192x224x160@0.50`: 0 coverage failures over 1,614 draft subject rows.
- Official split-aware tile-grid dry-run is still required after split creation.

## Open Implementation Decisions

These remain unresolved until the actual baseline loader is implemented and
reviewed:

- exact train patch positive/background sampling ratio,
- exact normalization implementation,
- exact augmentation recipe,
- full-volume blending rule for overlapping tiles,
- whether validation uses sliding-window every epoch or a bounded validation
  subset during early smoke training,
- checkpoint and prediction-map output paths.
