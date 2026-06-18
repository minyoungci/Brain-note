# exp04: Tumor-Context Tokens with Mask Dropout

Status: scaffold only.

## Objective

Use segmentation-derived tumor/context information during training while keeping
deployment robust when masks are missing or imperfect.

This is the primary technical novelty candidate.

## Prior-Work Gap

FoundBioNet and MTS-UNET use segmentation-guided tumor-aware learning, while Res3DNet
is segmentation-free but image-only. This experiment tries to combine both advantages.

## Candidate Representation

- Global whole-brain token.
- Tumor token from mask or learned attention.
- Peritumoral ring/context token.
- Optional enhancement/edema interaction token.

## Training Strategy

- Use segmentation only as auxiliary guidance where available.
- Apply mask dropout.
- Apply mask corruption/noise stress tests.
- Train no-mask inference pathway.

## Required Ablations

- Whole-brain only.
- Tumor token only.
- Tumor + peritumoral token.
- Mask required at inference.
- Mask dropout with no-mask inference.

## Metrics

- LOCO mean AUC.
- Worst-consortium MCC.
- Mask-available vs mask-dropped performance.
- Calibration under mask missingness.

## Main Risks

- Hidden mask availability leakage.
- Zero-byte or missing masks biasing cohort selection.
- Model may depend on mask quality and fail without masks.

## Approval Gate

Mask policy from exp00 must be finalized before this experiment becomes official.

