# Plan C: Few-Shot Segmentation Paper

## Target

Focused paper around segmentation transfer:

- MICCAI workshop / MIDL
- ISBI
- Medical Image Analysis short/full if external validation is strong

## Central Message

```text
In few-shot 3D brain MRI segmentation, foundation model value depends less on
raw full fine-tuning and more on preserving dense spatial priors during adaptation.
```

## Motivation

Current segmentation results are asymmetric:

- Task4 trigeminal improves strongly over scratch in the initial realistic protocol.
- Task2 meningioma remains weak despite standard augmentation, Tversky, foreground sampling, sliding-window inference, EMA/LLRD variants.

This asymmetry is valuable scientifically because it exposes how few-shot segmentation can fail.

## Hypotheses

### H1: Full fine-tuning causes catastrophic forgetting in Task2

Evidence so far:

- `seg_v2/seg_v3` use `_load_encoder(... freeze=False)` and `transfer_decoder=True`.
- `transfer_decoder=True` sets all U-Net parameters trainable.
- n=23 is small enough that encoder drift can destroy the foundation prior.

### H2: Meningioma requires task-specific detection adaptation

Task2 appears to be a detection-failure problem:

- large lesion-size variation
- false negatives dominate
- high-recall Tversky improved but did not solve it
- mean multimodal fusion diluted FLAIR signal

### H3: Decoder transfer and encoder preservation must be separated

Current `transfer_decoder=True` couples:

```text
pretrained encoder
pretrained decoder
full fine-tuning
```

The paper needs to separate these factors.

## Required Experiment Grid

| Encoder | Decoder | Encoder LR | Purpose |
|---|---|---:|---|
| pretrained frozen | pretrained transferred | 0 | preserve full foundation prior |
| pretrained frozen | fresh | 0 | test encoder-only transfer |
| pretrained low-LR | pretrained transferred | 1e-6 to 1e-5 | minimal adaptation |
| pretrained full-FT | pretrained transferred | 1e-4 | current baseline |
| scratch | scratch | matched | lower bound |

## Task2-Specific Additions

- FLAIR-only first, because mean multimodal fusion hurt.
- Learned multimodal fusion only after FLAIR frozen/low-LR baseline is known.
- Threshold sweep on validation folds.
- Connected component filtering.
- lesion-size stratified Dice and recall.
- false-negative case gallery.

## Success Criterion

This plan becomes a strong paper if:

```text
frozen or low-LR encoder substantially improves Task2 over full-FT,
or explains why Task2 differs from Task4 through case-level failure analysis.
```

If performance remains low:

```text
The paper can still become a diagnostic study of few-shot 3D segmentation transfer,
but not a pure performance paper.
```
