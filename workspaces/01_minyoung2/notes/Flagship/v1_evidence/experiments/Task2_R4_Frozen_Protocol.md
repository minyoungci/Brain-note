# Task2 R4: Frozen / Low-LR Protocol

## Why This Exists

Current Task2 meningioma performance is weak under the realistic segmentation pipeline:

```text
R1: pretrained Dice 0.127 / scratch 0.107
R3-C best: high-recall Tversky beta0.8 + EMA, Dice around 0.159
```

The current `seg_v2/seg_v3` path uses:

```text
_load_encoder(... freeze=False)
_SegFT(... transfer_decoder=True)
```

In `pretrain/seg_finetune.py`, `transfer_decoder=True` sets all U-Net parameters trainable. Thus the current realistic Task2 runs are full fine-tuning, not foundation-preserving few-shot adaptation.

## Primary Hypothesis

```text
Task2 underperforms because full fine-tuning with n=23 causes catastrophic forgetting
of the foundation dense prior.
```

## Experiment Arms

### Arm A: Frozen Encoder + Transferred Decoder

Goal:

- keep pretrained stem/encoder fixed
- train transferred decoder/head only

Interpretation:

- if this improves over full-FT, forgetting is likely.

### Arm B: Frozen Encoder + Fresh Decoder

Goal:

- isolate encoder representation from pretrained decoder transfer.

Interpretation:

- if this works, encoder prior is useful even without dense decoder transfer.

### Arm C: Very-Low-LR Encoder + Transferred Decoder

Goal:

- allow minimal adaptation while preserving prior.

Candidate encoder LRs:

```text
1e-6
3e-6
1e-5
```

### Arm D: Scratch Matched Controls

Every arm needs a scratch/random matched control with the same decoder/fine-tuning budget.

## Fixed Settings

Start conservative:

```text
task: task2_meningioma
modality: flair
spacing: 1.0
crop: 128
loss: Tversky beta0.8 + BCE
EMA: on for decoder/head if stable
foreground sampling: default first; pos4 only if detection failure persists
evaluation: subject-disjoint k-fold, per-subject bootstrap CI
```

Do not start with multimodal fusion. FLAIR-only is the current strongest signal and mean multimodal fusion previously hurt.

## Postprocess Grid

After model protocol is selected:

```text
threshold: 0.2, 0.3, 0.4, 0.5
min component volume: 0, 10, 30, 100 voxels
keep largest component: yes/no
```

Use validation folds only. Do not tune on hidden/test.

## Required Outputs

- summary table with Dice/NSD/lesion recall
- per-case CSV:
  - subject id
  - lesion volume
  - prediction volume
  - Dice
  - NSD
  - false negative flag
- representative failure figure list

## Decision Rule

If frozen/low-LR improves Task2 by at least:

```text
Dice +0.05 absolute over full-FT
or lesion recall meaningfully improves with stable FP volume
```

then the manuscript should include a dedicated section:

```text
Few-shot segmentation requires preserving foundation priors.
```

If no arm improves:

move to modality/spacing/label-noise diagnosis.
