# Stage 8 Baseline Readiness Preparation

## Scope

Prepare the first segmentation baseline protocol without creating the official
split manifest, preprocessing data, or launching GPU training.

## Goal Reminder

G-SURE is not a Dice-only segmentation project. The first segmentation model is
needed because later reliability and grounding labels must come from
out-of-fold segmentation predictions and error maps.

## Read-Only Evidence Checked

Current subject-level draft:

| dataset | subjects |
|---|---:|
| MU-Glioma-Post | 203 |
| UCSD-PTGBM | 178 |
| UPENN-GBM | 611 |
| UTSW | 622 |
| total | 1,614 |

Shape/orientation distribution:

| shape | orientation | subjects |
|---|---|---:|
| 240x240x155 | LPS | 1,436 |
| 256x256x256 | ILA | 178 |

Voxel spacing:

| zooms | subjects |
|---|---:|
| 1x1x1 | 1,614 |

Selected mask sources:

| mask key | subjects |
|---|---:|
| tumorseg_FeTS | 622 |
| UPENN_segm | 611 |
| tumorMask | 203 |
| BraTS_tumor_seg | 178 |

Selection warnings:

| warning | subjects |
|---|---:|
| none | 1,539 |
| ucsd_missing_acquisition_to_initial_event_offset | 37 |
| ucsd_scan_more_than_1y_after_initial_event | 26 |
| mu_selected_timepoint_missing_days_from_diagnosis | 12 |

## Implication For The First Baseline

- The first baseline must standardize orientation before batching.
- The first baseline must define a crop/pad/resize policy before GPU training.
- UCSD is a clear shift-risk case: it differs in shape, orientation, lesion
  fraction, and timing-warning concentration.
- Because G-SURE needs out-of-fold error maps, in-sample validation predictions
  cannot be used as reliability labels.

## Validation Performed

Dry-run split builder:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py
```

Result:

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
Dry run only. Re-run with --write after approval to create official split outputs.
```

Official split output check:

```text
loco_split_manifest.csv does not exist.
```

Package availability check:

```text
nibabel 5.4.2
torch 2.10.0+cu128, cuda_available=True
monai 1.5.2
```

This only confirms environment availability. It is not GPU approval.

## Remaining Approval Gate

Do not proceed to training until Min approves:

```text
primary cohort = subject_level_cohort_manifest_draft.csv
selection policy = one_unit_per_subject_earliest_numeric_order
split policy = LOCO
official split creation = build_loco_split_manifest.py --write
```

After approval:

1. Create official split outputs.
2. Run post-split CPU loader smoke.
3. Review crop/pad/resize/orientation policy.
4. Preview first GPU command.
5. Train only after explicit GPU approval.
