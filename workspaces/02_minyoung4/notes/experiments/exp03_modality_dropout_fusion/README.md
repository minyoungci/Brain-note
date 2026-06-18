# exp03: Modality Dropout and Fusion

Status: scaffold only.

## Objective

Test whether robust sequence fusion improves over early 4-channel concatenation.

## Prior-Work Gap

Many models concatenate T1, T1ce, T2, and FLAIR early.
That ignores sequence-specific reliability and scanner/protocol variation.

## Candidate Methods

- Early 4-channel concat baseline.
- Modality dropout during training.
- Late fusion with per-modality encoders.
- Lightweight cross-modal attention.
- T2-FLAIR and T1CE-FLAIR interaction token.

## Required Ablations

- No modality dropout.
- Random modality dropout.
- Late fusion without interaction token.
- Full fusion model.

## Expected Gain

Better LOCO stability and less collapse when a sequence has weaker quality or
acquisition differences.

## Metrics

- LOCO AUC and MCC.
- Sequence-ablation robustness.
- Scanner/vendor subgroup performance.

## Main Risk

Added parameters may overfit the small mutant class.
This experiment should follow exp02 and reuse the same loader and metric contract.

