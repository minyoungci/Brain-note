# exp01_loco_segmentation_robust

## Task

Whole-tumor segmentation from four structural MRI channels.

## Research Question

Can a source-balanced, small-lesion-aware 3D segmentation learner improve cross-consortium
robustness compared with a standard whole-brain 3D U-Net baseline?

## Outcome

Binary whole-tumor Dice on held-out consortium subjects.

## Input / Exposure

Four structural MRI channels:

- T1
- T1ce / T1post
- T2
- FLAIR

The tumor mask is used as the supervised segmentation label. Raw data are read-only.

## Unit of Analysis

Primary reporting unit is `dataset::subject_id`. For longitudinal/session datasets, one
imaging unit is selected per subject using numeric earliest session/scan sorting.

## Cohort / Filters

Starting source is `docs/context/canonical_manifest.csv`.

Required filters:

- `representation == "nifti"`
- `has_structural_core == True`
- `has_segmentation == True`
- all selected image/mask paths exist and are non-empty
- selected image channels have matching shape and affine
- selected mask shape matches image shape
- selected mask has positive voxels after resampling; optional eager validation is available
  with `--validate-mask-voxels`

Known quality issue:

- UCSD zero-byte `total_cellular_tumor_seg` is not selected; UCSD uses `BraTS_tumor_seg`.
- Full launch uses the completed `docs/context/nifti_header_audit_full.csv` for fast
  path/header/zero-byte screening. CPU/GPU smoke runs still perform direct NIfTI header checks.

## Split Policy

Leave-one-consortium-out:

- held-out dataset is test only
- validation subjects come only from the training consortia
- no `dataset::subject_id` appears in more than one split

## Leakage Risks

- subject/session leakage from MU and UCSD repeated imaging units
- test-consortium use in validation threshold or checkpoint selection
- segmentation files that are masks in a different space from structural images
- per-cohort or global intensity statistics leaking held-out site distribution

## Files to Change

This experiment owns only:

- `experiments/exp01_loco_segmentation_robust/`

It must not write to `/home/vlm/data/raw/` or mutate shared source data.

## Expected Artifacts

Per run:

- `records.csv`
- `split.csv`
- `history.csv`
- `best.pt`
- `val_thresholds.csv`
- `test_predictions.csv`
- `summary.json`
- `report.md`
- nohup logs and PID files when launched through the shell launcher

## Validation

Before full GPU training:

- Python compile
- shell syntax check
- CPU smoke on real NIfTI paths
- one short GPU smoke if needed

During GPU training:

- `setsid nohup` process launch
- PID/log files
- monitor script checks process aliveness, stderr size, history/checkpoint/report existence

## Completed Technical Variants

- `standard_dice_bce_loco_full_v1_sharedcache`: compact 3D U-Net, Dice+BCE,
  mean-Dice checkpointing. This is the current strongest completed training baseline.
- `tail_source_loco_full_v3_sharedcache`: source-balanced sampling, small-lesion
  weighted focal Tversky+BCE, worst-source checkpointing. This was worse than standard
  Dice+BCE and should not be used as a method claim.
- `source_balanced_dice_bce_loco_full_v1_sharedcache`: source-balanced sampling and
  worst-source checkpointing with Dice+BCE. This was also worse than standard Dice+BCE.

## Current Technical Direction

GPU training for this direction is stopped. The completed sweep found a positive
performance artifact, but not a strong single-pass method claim.

Current best:

- `resunet_ds_tta_distill_ensemble_tta_all_v1`
- fixed 50:50 probability ensemble of ResUNet-DS and TTA-distilled ResUNet-DS
- all-flip TTA at inference
- mean Dice 0.892775
- delta vs standard Dice+BCE compact U-Net +0.008498, CI95 [+0.005960, +0.011038]

Main limitation:

- the best result uses two models and all-flip TTA, so it is a performance artifact with
  extra inference compute rather than a clean new architecture or single-pass training
  method.

No-go findings:

- source balancing and focal Tversky degraded performance
- naive flip consistency degraded ResUNet-DS
- TTA-distillation helped hard folds but was not an overall single-model winner
- ensemble-student and confidence-weighted distillation did not preserve the ensemble gain
- validation-weighted routing and a third model did not beat the fixed two-model ensemble

Do not restart GPU training for another generic segmentation variant without a new locked
research question and explicit approval. See
`docs/context/research_direction_review_after_exp01.md`.

## Previous Default Variant

The first robust candidate was:

- compact 3D U-Net
- per-volume foreground normalization
- train-only augmentation
- source-balanced sampling
- small-lesion weighted focal Tversky + BCE
- checkpoint selection by validation worst-source Dice
- validation-only threshold selection

This is not yet the final novelty claim. It is the first fresh-start runnable baseline for
measuring small-lesion and held-out-consortium failure modes.
