# Baseline Contract

## Goal

Baselines must separate three questions:

1. Can the model segment the tumor?
2. Can the model estimate uncertainty?
3. Can the model localize actual segmentation error?

## Required Baselines

### B0: Classical / Simple Morphology QA

Use mask-derived or prediction-derived simple features only.

Purpose:

- Establish whether failure risk is mostly explained by lesion size or predicted
  volume.
- Establish whether case difficulty can be predicted by simple image/shape
  proxies before training a reliability model.
- Keep ground-truth lesion size as oracle diagnostic only; deployable QC
  baselines may use predicted volume and image-derived features, not held-out
  ground-truth masks.

Outputs:

- predicted volume,
- connected-component count,
- confidence/entropy summary when a probability map exists,
- optional image-derived difficulty proxies, such as intensity contrast,
  boundary-gradient summary, or simple texture/shape summaries,
- oracle GT lesion-size strata for reporting only.

### B1: Plain 3D Segmentation Model

Example:

- compact 3D U-Net or ResUNet.

Outputs:

- segmentation probability map,
- binary mask,
- subject-level Dice.

### B2: TTA Uncertainty

Run the same model under test-time augmentations.

Outputs:

- mean probability map,
- probability variance,
- vote disagreement,
- entropy.

### B3: Ensemble Disagreement

Use independently trained or architecturally distinct segmentation models.

Outputs:

- ensemble mean probability,
- disagreement map,
- scalar uncertainty summary.

### B4: Multi-Task Reliability Head

Segmentation backbone plus reliability/error head.

Outputs:

- segmentation map,
- predicted error/reliability map.

### B5: DeVries-Style Segmentation Quality Predictor

Quality predictor that consumes image, predicted segmentation, and uncertainty
or confidence maps.

Purpose:

- Test whether subject-level segmentation failure is already solved by standard
  QC inputs.

Outputs:

- subject-level quality/failure score,
- optional region summaries if implemented.

### B6: QCResUNet-Style Error-Map Predictor

Quality-control model that predicts both subject-level segmentation quality and
voxel-level segmentation error maps from image/prediction-derived inputs.

Purpose:

- Directly challenge the G-SURE claim that spatial reliability/error
  localization needs a new grounding method.

Outputs:

- predicted subject-level Dice/quality proxy,
- voxel-level error probability map,
- subject-level failure score.

### B7: G-SURE

Proposed grounded reliability model.

Expected difference:

- explicit lesion/boundary grounding constraints,
- reliability map trained/evaluated under strict out-of-fold or train-only
  pseudo-label generation,
- cross-consortium grounding metrics.

## Reporting Requirements

For every baseline:

- report Dice,
- report Dice <= 0.8 rate,
- report voxel-level error localization AUROC/AUPRC,
- report subject-level failure detection AUROC/AUPRC,
- report reliability/error calibration when a reliability map exists,
- report per-consortium results,
- report lesion-size stratification,
- report whether subject-level failure detection is explained by predicted
  volume or image-difficulty proxies.

## Detailed First Baseline Protocol

The first trainable segmentation baseline is specified in:

```text
research_gsure/03_baselines/SEGMENTATION_BASELINE_PROTOCOL.md
```

That protocol is still pre-GPU. It must be reviewed after the official LOCO split
manifest and CPU loader smoke test exist.

The GPU preview requirements are specified in:

```text
research_gsure/03_baselines/GPU_PREVIEW_CONTRACT.md
```

The first B1 GPU preview approval packet should use:

```text
research_gsure/03_baselines/B1_GPU_PREVIEW_COMMAND_TEMPLATE.md
```

Prediction artifacts that feed reliability labels must satisfy:

```text
research_gsure/01_protocol/OOF_PREDICTION_RELIABILITY_CONTRACT.md
```

Reliability/error-localization metrics must satisfy:

```text
research_gsure/01_protocol/RELIABILITY_METRIC_CONTRACT.md
```

Uncertainty and QC baselines must satisfy:

```text
research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md
```
