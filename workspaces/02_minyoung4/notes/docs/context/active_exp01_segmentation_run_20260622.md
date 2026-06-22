# Active exp01 Segmentation Run — 2026-06-22

## Current Task

Fresh-start whole-tumor segmentation from four structural MRI channels under
leave-one-consortium-out evaluation.

This is not a segmentation-only endpoint claim yet. It is the current executable proxy
task for building a lesion-aware, cross-consortium robust medical-vision method after
molecular IDH/MGMT prediction did not provide a reliable performance-improvement claim.

## Research Question

Can a source-balanced, small-lesion-aware 3D learner reduce held-out-consortium and
small-lesion segmentation failures relative to a standard 3D U-Net baseline?

## Outcome

Primary: held-out consortium whole-tumor Dice.

## Input / Exposure

Four structural MRI channels:

- T1
- T1ce / T1post
- T2
- FLAIR

Tumor segmentation is used as the supervised label. Raw/shared data are read-only.

## Unit of Analysis

`dataset::subject_id`. For repeated session/timepoint datasets, the run selects one
numeric-earliest imaging unit per subject.

## Cohort / Filters

Run metadata locks N=1617 subjects:

- MU-Glioma-Post: 203
- UCSD-PTGBM: 178
- UPENN-GBM: 611
- UTSW: 625

The run uses `docs/context/canonical_manifest.csv` and the completed
`docs/context/nifti_header_audit_full.csv` for fast path/header screening.

## Split Policy

Leave-one-consortium-out:

- held-out consortium is test only
- validation is drawn only from training consortia
- split key is `dataset::subject_id`

## Technical Variant

`tail_source_loco_full_v3_sharedcache`:

- compact 3D U-Net
- per-volume foreground normalization
- train-only flips/intensity/noise augmentation
- source-balanced training sampler
- small-lesion weighted focal Tversky + BCE
- checkpoint selection by validation worst-source Dice
- validation-only threshold selection
- bf16 autocast on GPU

## Validation Before Launch

- `python -m py_compile` passed for trainer and monitor.
- shell syntax check passed for launch scripts.
- CPU real-data smoke passed:
  `experiments/exp01_loco_segmentation_robust/runs/smoke_cpu_ucsd_v2`.
- GPU bf16 real-data smoke passed:
  `experiments/exp01_loco_segmentation_robust/runs/smoke_gpu_ucsd_v2`.

## Active Full Run

The earlier `tail_source_loco_full_v2_fastheader` run was intentionally stopped before
epoch 0. It was alive and error-free, but each fold built a separate cache, causing
unnecessary fourfold preprocessing I/O. The launcher was patched so the current run uses
a shared run-level cache.

Run root:

`experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache`

Launch command:

```bash
CONFIRM_LONG_GPU_RUN=yes EPOCHS=30 TARGET_SHAPE=80,96,96 BASE_CHANNELS=16 \
  BATCH_SIZE=1 NUM_WORKERS=2 \
  bash experiments/exp01_loco_segmentation_robust/scripts/launch_all_nohup.sh \
  tail_source_loco_full_v3_sharedcache
```

Launched folds:

| heldout | pid | GPU |
|---|---:|---:|
| UCSD-PTGBM | 422235 | 2 |
| MU-Glioma-Post | 422241 | 3 |
| UPENN-GBM | 422249 | 4 |
| UTSW | 422255 | 2 |

Watcher:

- pid: 515898
- command: `experiments/exp01_loco_segmentation_robust/scripts/watch_and_summarize.py`
- status: `experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache/watch_status.json`

Launch verification:

- all four processes had `PPID=1` and `SID=PID`
- stderr was 0 bytes
- GPU attach verified
- `records.csv`, `split.csv`, `metadata.json`, and `history.csv` exist for all folds
- run-level shared cache is used to avoid fourfold duplicated preprocessing I/O

Split verification:

- held-out dataset appears only in `test` for all four folds
- no held-out dataset appears in train or validation
- UID duplicates in each split file: 0

Current early status:

- all four fold processes alive
- watcher alive
- fold stderr files: 0 bytes
- watcher stderr: 0 bytes
- shared cache reached 1617 files
- no final Dice result yet

Early validation confirms the robust run is actually training:

| heldout | latest epoch checked | val mean Dice | val worst-source Dice |
|---|---:|---:|---:|
| MU-Glioma-Post | 1 | 0.8760 | 0.8409 |
| UCSD-PTGBM | 1 | 0.8500 | 0.8137 |
| UPENN-GBM | 2 | 0.8448 | 0.7904 |
| UTSW | 6 | 0.8829 | 0.8445 |

These are validation metrics only, not held-out test results.

## Standard Baseline Run

To support a real performance-improvement claim, a standard Dice+BCE baseline has also
been launched. It reuses the robust run's shared cache.

Run root:

`experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_loco_full_v1_sharedcache`

Launched folds:

| heldout | pid | GPU |
|---|---:|---:|
| UCSD-PTGBM | 732617 | 3 |
| MU-Glioma-Post | 732623 | 4 |
| UPENN-GBM | 732629 | 3 |
| UTSW | 732635 | 4 |

Watcher pid: 736538.

Early validation confirms the standard baseline is also training:

| heldout | latest epoch checked | val mean Dice | val worst-source Dice |
|---|---:|---:|---:|
| MU-Glioma-Post | 2 | 0.8922 | 0.8284 |
| UCSD-PTGBM | 2 | 0.8838 | 0.8141 |
| UPENN-GBM | 3 | 0.8487 | 0.7998 |
| UTSW | 4 | 0.8797 | 0.8179 |

These are validation metrics only. Final comparison must use held-out test predictions
and paired bootstrap, not validation scores.

## Automatic Comparison

Comparison watcher:

`experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_tail_source_v1`

pid: 766980.

When both runs produce `loco_summary`, it will run paired subject-level comparison:

- delta mean Dice with bootstrap CI
- delta Dice <= 0.5 failure rate
- delta Dice <= 0.8 failure rate
- fold-level deltas

## First Comparison Result

The focal-Tversky robust candidate is **NO-GO** against the standard Dice+BCE baseline.

Comparison:

`experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_tail_source_v1/comparison_report.md`

Summary:

- standard mean Dice: 0.884277
- focal-Tversky candidate mean Dice: 0.878937
- paired delta mean Dice: -0.005340, CI95 [-0.007761, -0.002890]
- delta Dice <= 0.5 rate: +0.001237, CI95 [-0.003711, +0.006803]
- delta Dice <= 0.8 rate: +0.007421, CI95 [-0.002474, +0.017934]

Interpretation:

- The small-lesion/focal-Tversky loss did not improve the held-out test objective.
- It worsened MU and UPENN and did not meaningfully improve UTSW.
- It should not be used as the final method claim.

Next ablation:

`source_balanced_dice_bce_loco_full_v1_sharedcache`

Purpose:

- keep the stable Dice+BCE objective
- add source-balanced sampling
- checkpoint by validation worst-source Dice
- test whether domain/source robustness helps without the focal-Tversky loss penalty

## Active Second Ablation

Run:

`experiments/exp01_loco_segmentation_robust/runs/source_balanced_dice_bce_loco_full_v1_sharedcache`

Launched folds:

| heldout | pid | GPU |
|---|---:|---:|
| UCSD-PTGBM | 1790722 | 2 |
| MU-Glioma-Post | 1790728 | 3 |
| UPENN-GBM | 1790734 | 4 |
| UTSW | 1790740 | 2 |

Watcher pid: 1792174.

Comparison watcher:

`experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_source_balanced_dice_v1`

pid: 1792186.

Initial verification:

- all folds detached with `PPID=1`
- GPU attach verified
- fold stderr files: 0 bytes
- watcher/comparison stderr files: 0 bytes
- metadata/history files created

Early validation:

| heldout | latest epoch checked | val mean Dice | val worst-source Dice |
|---|---:|---:|---:|
| MU-Glioma-Post | 4 | 0.8840 | 0.8588 |
| UCSD-PTGBM | 2 | 0.8829 | 0.8258 |
| UPENN-GBM | 6 | 0.8772 | 0.8496 |
| UTSW | 4 | 0.8798 | 0.8043 |

The comparison watcher is waiting for this run to complete; the standard baseline is
already complete.

## Second Ablation Result

`source_balanced_dice_bce_loco_full_v1_sharedcache` is also **NO-GO** against the
standard Dice+BCE baseline.

Comparison:

`experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_source_balanced_dice_v1/comparison_report.md`

Summary:

- standard mean Dice: 0.884277
- source-balanced Dice+BCE mean Dice: 0.879252
- paired delta mean Dice: -0.005025, CI95 [-0.008068, -0.002164]
- delta Dice <= 0.5 rate: +0.000618, CI95 [-0.005566, +0.006803]
- delta Dice <= 0.8 rate: +0.006184, CI95 [-0.003711, +0.015461]

Interpretation:

- Source-balanced sampling plus worst-source checkpointing did not improve the held-out
  test objective.
- The loss/sampling/checkpoint variants are not enough as a method claim.

Validation-routed diagnostic:

`experiments/exp01_loco_segmentation_robust/runs/validation_routed_standard_focal_source_v1`

- routing selected standard for MU, UCSD, and UTSW, and source-balanced for UPENN.
- paired delta vs standard mean Dice: ~0.000000, CI95 [-0.000817, +0.000808].
- diagnostic conclusion: the completed variants do not provide a useful fold-level
  complementarity story.

Next diagnostic:

- evaluate test-time augmentation on the standard Dice+BCE checkpoint.
- If TTA improves, use it as a teacher/upper bound for a future single-model
  uncertainty/distillation method.
- If TTA does not improve, move to architecture-level changes rather than additional
  scalar loss tweaks.

## Monitor Command

```bash
python experiments/exp01_loco_segmentation_robust/scripts/monitor_runs.py \
  --run-root experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache
```

## Remaining Risks

- No final Dice result is available until all folds finish.
- This first variant is still a robust baseline, not yet a publishable architecture claim.
- If performance is weak, the next method should target domain shift and small-lesion failure
  more explicitly, not only adjust scalar loss weights.

## 2026-06-22 Continuation Update

Completed diagnostic:

`experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_tta_all_v1`

- all-flip TTA on the completed standard Dice+BCE checkpoint.
- mean Dice: 0.886454 vs standard 0.884277.
- paired delta mean Dice: +0.002177, CI95 [+0.000459, +0.003924].
- fold deltas: MU +0.008180, UCSD +0.001811, UPENN -0.000367, UTSW +0.002819.
- interpretation: small positive diagnostic signal. TTA itself is not a final method claim,
  but it motivates train-time equivariance/consistency or distillation.

Implemented probes:

- `--arch resunet_ds`: residual SE 3D U-Net with auxiliary decoder deep supervision.
- `--consistency-mode flip`: single-pass flip-equivariance consistency regularizer.

Validation completed:

- `py_compile` passed after code changes.
- shell syntax passed for new launchers.
- CPU real-data smoke passed for `resunet_ds`.
- GPU bf16 smoke passed for `resunet_ds`.
- CPU real-data smoke passed for flip consistency.
- GPU bf16 smoke passed for flip consistency.

Active full GPU run:

`experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache`

- completed 4/4 folds with stderr 0.
- summary: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache/loco_summary/report.md`.
- comparison: `experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_resunet_ds_dice_bce_v1/comparison_report.md`.
- mean Dice: 0.887385 vs standard 0.884277.
- paired delta mean Dice: +0.003108, CI95 [+0.000509, +0.005785].
- fold deltas: MU +0.011721, UCSD +0.005077, UPENN +0.003166, UTSW -0.000306.
- interpretation: current strongest completed training candidate. This is the first positive
  architecture-level result in the fresh exp01 track.

Completed inference diagnostic:

`experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1`

- all-flip TTA over completed ResUNet-DS checkpoints.
- completed 4/4 folds with stderr 0.
- summary: `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1/loco_summary/report.md`.
- mean Dice: 0.889639.
- paired delta vs ResUNet-DS: +0.002253, CI95 [+0.000740, +0.003781].
- paired delta vs standard: +0.005362, CI95 [+0.002599, +0.007976].
- interpretation: current best performance artifact, but not a single-pass training method
  because it uses extra inference compute.

Active second full GPU run:

`experiments/exp01_loco_segmentation_robust/runs/unet_flip_consistency_loco_full_v1_sharedcache`

- UCSD heldout pid 2902189 on GPU2.
- MU heldout pid 2902200 on GPU2.
- UPENN heldout pid 2902207 on GPU2.
- UTSW heldout pid 2902213 on GPU2.
- watcher pid 2908231.
- comparison watcher vs standard pid 2908240.
- latest check: all four fold processes alive, detached with `PPID=1`, stderr 0.
- UPENN and UTSW completed 30 epochs and wrote reports/test predictions.
- MU epoch 24 and UCSD epoch 23 at latest monitor.
- train consistency loss remains finite at about 3e-4 to 5e-4.
- A 2-minute line-count audit confirmed the run is progressing, not hung. It is slower
  because all four folds share GPU2.

Active third full GPU run:

`experiments/exp01_loco_segmentation_robust/runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache`

- purpose: test whether the positive ResUNet-DS architecture and TTA-derived flip consistency
  combine into a single-pass training method.
- UCSD heldout pid 346798 on GPU3.
- MU heldout pid 346804 on GPU4.
- UPENN heldout pid 346810 on GPU3.
- UTSW heldout pid 346816 on GPU4.
- watcher pid 359296.
- comparison watchers:
  `comparisons/standard_vs_resunet_ds_flip_consistency_v1/` pid 359303,
  `comparisons/resunet_ds_vs_resunet_ds_flip_consistency_v1/` pid 359326,
  `comparisons/resunet_ds_tta_vs_resunet_ds_flip_consistency_v1/` pid 359612.
- validation before launch: launcher syntax OK, Python compile OK, CPU real-data smoke OK,
  GPU bf16 smoke OK.
- latest check: all four fold processes alive, detached with `PPID=1`, stderr 0.
- current progress: MU epoch 6, UCSD epoch 6, UPENN epoch 9, UTSW epoch 9.
- consistency loss is finite and all stderr files are 0.
