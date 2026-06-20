# P2.04 Size-Calibrated Precision-Balanced Segmentation

## Purpose

P2.03 reduced catastrophic failures but did not deliver a clear mean-Dice win over P2.02 and shifted the model toward recall at the cost of precision. P2.04 keeps the same cohort, input channels, LOCO split, compact 3D U-Net, and validation protocol, but changes the training objective to target the observed failure mode directly.

## Method

P2.04 uses a size-calibrated focal Tversky objective with a soft volume-ratio calibration term:

- small tumors: higher FN penalty to preserve P2.03's tail-recall benefit
- larger tumors: balanced FP/FN penalty to recover precision
- all tumors: soft predicted-volume calibration to discourage global over-segmentation
- threshold selection: validation-only grid extended to 0.95, fixed before test evaluation

The objective is train-only. No test labels, test thresholds, or held-out consortium statistics are used during fitting or checkpoint selection.

## Fixed Run Contract

- Cohort: same valid-seg subject set as P2.02/P2.03
- Unit: subject-level selected imaging unit using audited numeric earliest policy
- Split: held-out consortium LOCO; remaining consortia split into train/val by subject
- Input: 4 structural MRI channels
- Target: binary whole-tumor mask
- Model: compact 3D U-Net, `base_ch=24`
- Precision: bf16 on CUDA
- Primary comparison: paired subject-level comparison vs P2.02
- Main metrics: mean Dice, low-Dice <=0.5 rate, low-Dice <=0.8 rate, fold-wise behavior, size-bin behavior

## Loss Parameters

```text
loss_mode=size_calibrated_tversky
large alpha/beta = 0.50 / 0.50
small alpha/beta = 0.35 / 0.65
gamma = 1.25
bce_weight = 0.75
size_ref_voxels = 2500
size_weight_exp = 0.35
size_weight_clip = 3.0
volume_calibration_weight = 0.08
volume_calibration_log_clip = 2.0
thresholds = 0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.85,0.90,0.95
```

## Interpretation Rules

P2.04 is a candidate only if it improves over P2.02 without repeating P2.03's precision-collapse pattern. A small mean-Dice gain with a CI crossing zero is not enough for the main method claim. A credible positive result should show at least one of:

- overall mean Dice improvement with bootstrap CI excluding zero
- UCSD non-degradation plus meaningful tail failure reduction
- low-Dice <=0.5 and <=0.8 reductions without sacrificing mean Dice

If P2.04 is neutral, it remains an ablation showing that loss-level balancing is insufficient, and the next method should move beyond scalar loss design.
