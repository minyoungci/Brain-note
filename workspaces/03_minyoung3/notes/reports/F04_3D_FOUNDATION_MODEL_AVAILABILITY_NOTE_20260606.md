# F04 3D Foundation Model Availability Note

Updated: 2026-06-06

## Purpose

After the famous 2D DINOv2 feature probe and BN test-time adaptation controls
failed to beat the primary 3D ROI-VQA model, the remaining representation
question was whether a genuine 3D medical foundation encoder is locally
available and appropriate for a quick shallow LOCO probe.

## Local Availability Check

Local cache and workspace search found:

- cached 2D DINOv2 models under Hugging Face / torch hub;
- many project-specific 3D ROI-VQA checkpoints under `results/f04_roi_evidence_encoder/`;
- no cached genuine 3D brain MRI foundation checkpoint ready for feature extraction;
- MONAI, TorchIO, timm, transformers, Hugging Face Hub, and nibabel are installed.

Conclusion: there is no local drop-in 3D medical foundation feature source that
can be used without downloading and vetting an external checkpoint.

## External Candidates Checked

### BrainSegFounder

- Source: `https://huggingface.co/smilelab/BrainSegFounder`
- Relevant facts from the model card:
  - contains UK Biobank brain MRI SSL pretraining weights;
  - `model_weights_UKB-pretrain.pt` is trained on UKB MRI fields 20252 and 20253;
  - example SSLHead configuration uses `in_channels=2` for T1 + T2;
  - license is listed as `uk-biobank-mta`.
- Fit to our current task:
  - anatomically relevant because it is brain MRI and includes T1w-related UKB data;
  - not a clean immediate drop-in because our current task is T1-only, the example
    SSL head expects T1+T2, and the UK Biobank MTA license needs explicit review.

### OpenMind / PrimusM SimMIM

- Source: `https://huggingface.co/AnonRes/PrimusM-OpenMind-SimMIM`
- Relevant facts from the model card:
  - hosts 3D medical SSL checkpoints from an OpenMind benchmark;
  - includes transformer and CNN backbones with SSL methods such as MAE, SimMIM,
    SwinUNETR SSL, VoCo, and Models Genesis;
  - the model card explicitly says these models are not recommended to be used
    as-is for feature extraction, and recommends downstream adaptation frameworks.
- Fit to our current task:
  - methodologically relevant, but not appropriate as a quick shallow feature
    probe without implementing the intended adaptation pipeline.

### MONAI SwinUNETR SSL

- Source: `https://arxiv.org/abs/2111.14791`
- Relevant facts:
  - introduces 3D Swin UNETR self-supervised pretraining;
  - original pretraining used 5,050 public CT images from various body organs.
- Fit to our current task:
  - useful as historical 3D medical SSL precedent;
  - less appropriate as a brain T1w MRI foundation baseline because the original
    pretraining domain is CT, not brain MRI.

## Decision

Do not run an opportunistic external 3D foundation probe until the checkpoint,
license, input-channel adaptation, preprocessing, and feature extraction layer
are pre-registered.

The most plausible future foundation experiment is BrainSegFounder, but only if:

1. license/use is acceptable for this project;
2. T1-only input adaptation is defined without injecting clinical or ROI values;
3. the feature layer and pooling rule are fixed before AJU evaluation;
4. the probe is evaluated under the same AJU LOCO, validation-locked three-zone
   bootstrap, fixed 2.5D comparison, primary/tri-view comparison, and external
   morphometry `0.91` bar.

Until then, the paper direction should remain ROI-grounded three-zone 3D VQA
with explicit negative controls, not image-classifier superiority over
morphometry.
