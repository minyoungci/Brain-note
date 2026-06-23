# First Segmentation Baseline Protocol

## Research Design Note

Research claim:
- A conventional 4-channel 3D segmentation baseline can produce held-out
  consortium predictions good enough to define segmentation failure maps for the
  later G-SURE reliability task.

Minimum evidence needed:
- Official subject-level LOCO split.
- CPU loader smoke check for selected MRI channels and selected mask.
- Non-degenerate held-out segmentation on every held-out consortium.
- Out-of-fold prediction maps saved without train/test leakage.

Negative control:
- Lesion-size-only failure predictor.
- Predicted-volume-only failure predictor.

Positive control, if available:
- In-distribution validation fold performance inside train consortia. This is
  diagnostic only and must not replace held-out consortium reporting.

Baseline model:
- Plain 3D U-Net or compact 3D ResUNet segmentation model.

Naive baseline:
- Thresholded lesion prior / morphology-only QA summaries from masks or
  predictions. This is not a segmentation model but tests whether failure is
  mostly lesion-size driven.

Strong baseline:
- Same segmentation architecture with TTA uncertainty.
- Repeated-seed or small ensemble disagreement if compute allows.
- DeVries-style segmentation quality prediction from image, predicted mask, and
  uncertainty.
- QCResUNet-style subject-level QC plus voxel-level error-map prediction.

Ablation plan:
- Segmentation only.
- Segmentation plus TTA uncertainty.
- Segmentation plus repeated-seed disagreement.
- Reliability head only after out-of-fold error labels exist.

Expected failure mode:
- UCSD shift may dominate due different shape/orientation distribution
  (`256x256x256`, `ILA`) and lower lesion fraction.
- Reliability target may be explained by lesion size rather than visual
  grounding.
- Post-treatment/timing warnings in UCSD/MU may produce failure modes unrelated
  to segmentation evidence.

Reviewer attack points:
- The task is only Dice tuning.
- Reliability labels are generated from in-sample predictions.
- Dataset-specific annotation or geometry artifacts drive results.
- Simple TTA/ensemble uncertainty is enough.
- Prior segmentation QC models already predict subject-level quality and
  voxel-level error maps.

Decision rule:
- Continue to reliability/G-SURE only if held-out predictions create meaningful
  error maps and uncertainty/QC baselines leave measurable room.

Stop rule:
- Stop or pivot if any held-out consortium produces degenerate masks, if failure
  prediction is solved by lesion size, or if split/loader checks reveal leakage
  or incompatible geometry.

## Experiment Definition

Experiment ID:
- `B1_plain_3d_unet_loco`

Status:
- Draft protocol only. No GPU command approved.

Model:
- 3D U-Net or compact 3D ResUNet.
- Architecture is not the contribution.

Pretraining status:
- From scratch unless an explicitly reviewed medical segmentation checkpoint is
  approved later.

Input:
- Four MRI channels in order `[T1, T1ce, T2, FLAIR]`.

Tensor convention:

```text
image: [B, C, D, H, W]
mask:  [B, 1, D, H, W]
C = 4
target = selected_mask > 0
```

Target:
- Binary whole-lesion / whole-tumor candidate, `selected_mask > 0`.

Unit:
- One selected imaging unit per subject from
  `subject_level_cohort_manifest_draft.csv`.

Split:
- Leave-One-Consortium-Out after official split approval.
- No official split file exists at this stage.

Normalization:
- Per-volume, image-only normalization.
- Do not estimate normalization statistics on held-out test labels.
- Do not write normalized arrays into raw data.

Shape/orientation policy:
- All selected masks have spacing `1x1x1`.
- UCSD selected masks are `256x256x256 / ILA`.
- MU, UPENN, and UTSW selected masks are `240x240x155 / LPS`.
- The loader must standardize orientation consistently before batching.
- Any crop, pad, or resize policy must be documented before GPU training.

Loader feasibility note:
- A small CPU-only sample audit is documented in
  `research_gsure/02_audits/STAGE9_LOADER_TRANSFORM_FEASIBILITY.md`.
- After canonical orientation, sampled MRI channels and masks all became `RAS`
  with matching shapes.
- `128x160x128` is unsafe: it failed 1 / 20 sampled lesion bboxes by extent and
  7 / 20 sampled rows under fixed-center crop containment.
- In the expanded 80-subject quantile audit, `160x192x160` preserved all sampled
  lesion bboxes by extent but failed one UCSD row under fixed-center crop
  containment.
- `224x224x160` is the smallest expanded-sample candidate that passed both
  extent and fixed-center containment, but it is not locked until a post-split
  loader smoke and GPU memory preview are reviewed.
- Test-time inference must not use GT-mask-centered crops. If patch-based
  training is used, inference must reconstruct full-volume predictions through a
  reviewed sliding-window or equivalent full-coverage path.
- A CSV-only sliding-window coverage audit is documented in
  `research_gsure/02_audits/STAGE10_SLIDING_WINDOW_COVERAGE.md`.
- On the 80-subject quantile sample, `160x192x160` with 50% overlap achieved
  full-volume and bbox-union coverage for all sampled rows, but single-window
  whole-bbox containment failed in 5 / 80 rows. This is acceptable only for
  assembled full-volume inference, not for a single-crop baseline.
- Larger patches (`192x224x160` or `224x224x160`) improve single-window bbox
  containment in the sample but carry higher memory risk.
- Full subject-level draft tile budget is documented in
  `research_gsure/02_audits/STAGE11_TILE_BUDGET_AUDIT.md`.
- Pre-GPU preview should compare `160x192x160@0.50` against
  `192x224x160@0.50`. The former is more memory-conservative; the latter gives
  better sampled whole-lesion single-tile context with a 1.233x tile-voxel budget
  relative to `160x192x160@0.50`.
- GPU preview requirements are defined in
  `research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md`.
- The B1 GPU preview approval template is defined in
  `research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md`.
- Loader and full-volume inference policy is drafted in
  `research_gsure/01_protocol/LOADER_INFERENCE_POLICY_DRAFT.md`.
- OOF prediction and reliability-label artifact requirements are drafted in
  `research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md`.

Augmentation:
- Train split only.
- Conservative spatial/intensity augmentation suitable for MRI segmentation.
- No augmentation may use labels from held-out consortium.

Loss:
- Dice + BCE or Dice + focal/Tversky variant.
- Loss choice must be fixed in the GPU command preview.

Optimizer:
- AdamW or equivalent, fixed in config/command preview.

Batch size:
- To be determined after GPU memory preview.
- Preview must report peak memory and expected tile count for both candidate
  patch sizes before a training command is approved.

Epochs:
- Smoke run first after approval.
- Full training only after smoke passes.

Early stopping:
- Training-consortia validation only.
- Held-out consortium may not be used for early stopping.

Seed:
- Fixed seed required for every run.
- Repeated-seed baselines are separate experiments.

Metrics:
- Dice.
- Dice <= 0.8 rate.
- HD95 or surface distance if implementation is reviewed.
- Surface Dice if implementation is reviewed.
- Subject-level failure detection AUROC/AUPRC for uncertainty summaries.
- Voxel-level error localization AUROC/AUPRC for uncertainty maps.
- Per-consortium and lesion-size-stratified reports.

Logging:
- Command, git status, config, seed, split manifest path, and dataset snapshot.
- OOF prediction manifest path if prediction maps are written.

Checkpoint policy:
- Checkpoints require explicit output path review.
- Do not overwrite existing checkpoints.

GPU requirement:
- Requires Min approval after command preview.
- Preview is limited to feasibility and memory/runtime measurement; it must not
  be interpreted as a model-performance experiment.

Failure criteria:
- Shape/orientation mismatch in loader.
- Empty targets in selected rows.
- Train/test subject overlap.
- In-sample predictions used to create reliability labels.
- Test-time predictions produced from center crop only.
- Reliability labels generated from patch-only predictions before full-volume
  assembly.
- Prediction artifacts missing OOF provenance required by
  `OOF_PREDICTION_RELIABILITY_CONTRACT.md`.
- Prediction probability maps failing artifact-level value-range or geometry
  validation.
- Degenerate held-out predictions.

## Pre-GPU Checklist

- [ ] Official LOCO split manifest created after approval.
- [ ] Official split audit passes.
- [ ] CPU loader smoke test passes on at least one held-out test fold.
- [ ] Crop/pad/resize/orientation policy is locked.
- [ ] GPU preview contract is reviewed.
- [ ] B1 GPU preview command template is filled but not executed.
- [ ] First baseline command preview is reviewed.
- [ ] GPU execution is explicitly approved.
