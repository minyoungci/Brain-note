# P2.02 Segmentation LOCO Baseline

## Purpose

This track is a recovery/rebuild of the tumor segmentation baseline after the previous
`P2_01_segmentation_loco_baseline` artifacts disappeared from the active workspace.

The molecular IDH/MGMT performance-improvement direction is not used as the main claim here:
the current exp02 ceiling probes are NO-GO under clinical-adjusted LOCO evaluation. Segmentation
remains the strongest observed positive signal and gives a cleaner path toward a CV method paper:
robust lesion delineation under consortium and mask-provenance shift.

## Task

Binary whole-tumor segmentation from four structural MRI channels:

- T1
- T1 post-contrast / T1CE
- T2
- FLAIR

The target is any positive voxel in the selected tumor segmentation file. This baseline does not
model subregions yet.

## Cohort

The cohort is manifest-based, not IDH/MGMT-label-based:

- source manifest: `docs/context/canonical_manifest.csv`
- imaging unit: earliest numeric unit per `dataset::subject_id`
- required inputs: four structural channels plus a valid segmentation path
- raw data are read-only

## Split

Consortium-held-out LOCO:

- test: one held-out consortium
- train/validation: remaining consortia only
- validation split: deterministic subject-level hash split within each training consortium

## Leakage Controls

- test consortium is never used for training, validation, threshold selection, or checkpoint choice
- normalization is per-volume foreground normalization, reused from the exp02 image runner
- validation threshold is selected on validation subjects only, then frozen for test
- geometry checks can be enabled to assert channel/mask shape, affine, and spacing compatibility
- subject UID is `dataset::subject_id`

## Baseline Model

`scripts/train_segmentation_baseline.py` implements a compact 3D U-Net:

- 4-channel input
- binary logit output
- Dice + BCE loss
- bf16 autocast on CUDA
- best checkpoint selected by validation mean Dice
- subject-level test metrics written as CSV

## Reproduced Result

Full `v2_validseg` LOCO run completed on 2026-06-20:

- subject-level n: 1612
- subject-weighted mean Dice: 0.845830
- median Dice: 0.888112
- q10/q25/q75/q90 Dice: 0.732230 / 0.836842 / 0.916514 / 0.932910
- worst consortium: UCSD-PTGBM, mean Dice 0.737953

Fold-level held-out test Dice:

| held-out consortium | n | mean Dice | median Dice |
|---|---:|---:|---:|
| MU-Glioma-Post | 202 | 0.807285 | 0.870614 |
| UCSD-PTGBM | 178 | 0.737953 | 0.807485 |
| UPENN-GBM | 611 | 0.884677 | 0.900040 |
| UTSW | 621 | 0.851068 | 0.894665 |

Current report:
`EXP_flag/P2_02_segmentation_loco_baseline/reports/loco_full_v2_validseg/loco_segmentation_baseline_report.md`

The prior disappeared-run observation is therefore broadly reproduced: mean Dice is slightly lower
than the previously remembered 0.857, and UCSD remains the worst held-out consortium at about 0.74.

## Failure Pattern

The baseline is strong for typical tumor volumes but has a low-tail problem:

- Dice <= 0.5 in 61/1612 subjects.
- Dice <= 0.8 in 278/1612 subjects.
- Performance is strongly target-size dependent. Mean Dice is 0.581 for 101-500 target voxels,
  0.682 for 501-1000, 0.796 for 1000-2500, and >0.86 above 2500 target voxels.
- UCSD-PTGBM is both the worst fold and a small-target-heavy held-out cohort.

## Next Valid Claim

A defensible next claim is not "IDH prediction improved." It is:

> robust tumor segmentation across heterogeneous public glioma consortia exposes a real
> domain/mask-provenance shift, and gives a measurable target for a new shift-robust lesion
> learning method.

The next experiment should target the observed low-tail directly: small-lesion sensitivity,
post-treatment/UCSD robustness, and mask-provenance shift. A generic larger U-Net alone is not a
sufficient method claim.
