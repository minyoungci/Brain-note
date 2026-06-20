# P2.03 Tail-Robust Segmentation Variant

## Purpose

P2.02 reproduced a strong whole-tumor segmentation baseline, but the held-out low-tail is not
solved. The weakest fold is UCSD-PTGBM and performance is strongly target-size dependent.

This experiment tests whether a training-only tail-robust objective improves the clinically
important failure region without changing the inference path.

## Research Question

Can size-weighted focal Tversky training improve small-lesion and UCSD held-out segmentation
robustness over the P2.02 compact 3D U-Net baseline?

## Baseline Reference

P2.02 `v2_validseg` completed on 2026-06-20:

| held-out consortium | n | mean Dice | median Dice |
|---|---:|---:|---:|
| MU-Glioma-Post | 202 | 0.807285 | 0.870614 |
| UCSD-PTGBM | 178 | 0.737953 | 0.807485 |
| UPENN-GBM | 611 | 0.884677 | 0.900040 |
| UTSW | 621 | 0.851068 | 0.894665 |

Subject-weighted mean Dice: 0.845830.

Observed low-tail:

- Dice <= 0.5 in 61/1612 subjects.
- Mean Dice is 0.581 for 101-500 target voxels and 0.682 for 501-1000 target voxels.
- UCSD-PTGBM has the worst mean Dice and no large-target tail above 10k target voxels.

## Method

The model and data path stay identical to P2.02:

- 4-channel structural MRI input.
- Compact 3D U-Net.
- Whole-tumor binary segmentation target.
- Consortium-held-out LOCO split.
- Validation-only threshold selection.
- Mask-free inference is not relevant because this is segmentation; no test label information is
  used outside metric computation.

The only intended change is the training objective:

```text
L = w(size) * (FocalTversky(alpha=0.3, beta=0.7, gamma=1.33) + bce_weight * BCE)

w(size) = clamp((size_ref_voxels / target_voxels) ^ 0.5, 1, 4)
normalized within batch to mean 1
```

Rationale:

- beta > alpha penalizes false negatives more than false positives.
- focal gamma emphasizes hard masks.
- size weighting explicitly upweights the observed low-tail without using held-out test labels.

## Primary Endpoint

Compare against P2.02 on the same LOCO folds:

1. UCSD-PTGBM mean Dice and q10 Dice.
2. Subject-weighted mean Dice.
3. Low-tail counts: Dice <= 0.5 and Dice <= 0.8.

The method is only interesting if UCSD and small-target bins improve without materially collapsing
UPENN/UTSW.

## Leakage Controls

- The loss uses only each training subject's target mask size.
- Validation threshold remains validation-only.
- Held-out consortium is not used for training, model selection, or threshold selection.
- Cohort, valid-segmentation filtering, target shape, cache behavior, and geometry checks follow
  P2.02.

## Status

Code path is implemented as optional flags in
`EXP_flag/P2_02_segmentation_loco_baseline/scripts/train_segmentation_baseline.py`.

Operational tooling:

- nohup launcher: `scripts/launch_nohup_tail_robust.sh`
- preflight: `scripts/preflight_tail_robust.py`
- launch-all wrapper: `scripts/launch_all_nohup_tail_robust.sh`
- status monitor: `scripts/monitor_nohup_tail_robust.sh`
- watcher/auto-summary/auto-compare launcher: `scripts/launch_nohup_watcher.sh`
- watcher wrapper: `scripts/watch_summarize_compare_tail_robust.py`
- baseline comparison: `scripts/compare_to_p202_baseline.py`

`compare_to_p202_baseline.py` checks paired subject identity against P2.02 before reporting any
delta. It writes fold-level, size-bin, paired subject, and bootstrap CI outputs. Overall bootstrap
is heldout-consortium stratified.

Validation completed:

- Python/shell syntax checks passed.
- CPU real-data smoke passed.
- monitor dry-run passed on the smoke run.
- watcher foreground dry-run passed on the smoke run.
- comparison dry-run passed using P2.02 vs itself; all deltas were zero.
- preflight passed at 2026-06-20T11:09Z: GPUs 2 and 3 were free and target run
  directories were available.
- launch-all safety check passed: without `CONFIRM_LONG_GPU_RUN=yes`, it refuses to launch.
- bootstrap comparison dry-run passed using P2.02 vs itself; all deltas and CIs were zero.
- watch/summarize/compare dry-run on the smoke run correctly failed at comparison because the
  smoke candidate has only 4 subjects; this validates the subject-set guard.

Full GPU launch requires Min approval after command preview.
