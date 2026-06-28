# Task1-v2 Frozen Encoder Results

Date: 2026-06-28

## Motivation

Task1 Synapse validation AUROC was 0.658, much lower than the internal full-finetune estimate. The likely failure mode is overfitting from full encoder fine-tuning on only 21 labelled cases. Task1-v2 therefore freezes the ResEnc-S3D foundation encoder and trains only a small linear logistic head on submission-matched manual preprocessing.

## Setup

```text
script=Challenge_Submission/task1_infarct_cls/train_task1_v2_frozen.py
preprocessing=submission_manual_resize_128
encoder=ResEnc-S3D wg0.5 frozen
feature=SimPool global vector per modality
fusion=mean
selection=repeated LOOCV, repeats=5
head=linear logistic classifier with AdamW/L2
n=21, positives=13
```

## Best Variant

```text
modalities=dwi_b1000 + adc + flair
fusion=mean
C=0.3
feature_dim=320
LOOCV AUROC=0.942307710647583
repeat AUROC mean=0.9307692289352417
repeat AUROC min=0.9230769276618958
repeat AUROC max=0.942307710647583
```

Final v2 checkpoints:

```text
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_seed0.pt
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_seed1.pt
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_seed2.pt
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_seed3.pt
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_seed4.pt
```

Manifest:

```text
Challenge_Submission/task1_infarct_cls/v2_frozen/task1_v2_frozen_manifest.json
```

## Leaderboard Summary

```text
dwi_adc_flair mean C=0.3  AUROC=0.942 repeat_min=0.923
dwi_adc_flair mean C=1.0  AUROC=0.933 repeat_min=0.923
dwi_adc_flair mean C=0.03 AUROC=0.913 repeat_min=0.904
dwi_adc_flair mean C=0.1  AUROC=0.904 repeat_min=0.904
dwi_adc_flair mean C=0.01 AUROC=0.865 repeat_min=0.865
flair_dwi     mean C=0.01 AUROC=0.865 repeat_min=0.865
all4          mean C=0.01 AUROC=0.837 repeat_min=0.837
```

## Interpretation

The best frozen-head model removes the T2*/SWI slot and uses DWI/ADC/FLAIR. This is a useful sign: the previous all-4-modality full fine-tune may have learned unstable training-set correlations from the extra modality. The v2 result is still based on only 21 cases, so it should not be treated as guaranteed hidden performance, but it is a more defensible submission candidate than full encoder fine-tuning because the encoder is frozen and the trainable capacity is much smaller.

Recommended next step: package Task1 route with these v2 checkpoints and submit as a distinct Task1-v2 validation attempt.
