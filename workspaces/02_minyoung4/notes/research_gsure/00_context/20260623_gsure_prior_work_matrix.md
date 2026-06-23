# 2026-06-23 G-SURE Prior-Work Matrix

## Scope

This matrix converts the initial G-SURE literature scout into experimental
requirements.

Literature status:

```text
INITIAL TARGETED REVIEW + 2024-2026 UPDATE VERIFIED IN THIS SESSION; NOT SYSTEMATIC
```

Do not claim novelty from this file. Use it to prevent weak novelty framing and
to decide which baselines are mandatory.

## Research Goal Reminder

G-SURE is not a Dice-only glioma segmentation project. It asks whether
full-volume segmentation predictions can be paired with spatial reliability and
error localization under held-out consortium shift.

## Prior-Work Matrix

| prior-work family | representative source | task | input | output | evaluation | direct implication for G-SURE |
|---|---|---|---|---|---|---|
| Brain tumor segmentation uncertainty | Jungo et al. | uncertainty estimation for MRI brain tumor segmentation | MRI + segmentation model predictions | voxel uncertainty, calibration/failure signals | segmentation error identification and failure detection | basic uncertainty maps are not novel; use entropy/TTA/ensemble as required baselines |
| Medical segmentation quality prediction | DeVries and Taylor | predict segmentation quality/failure | image, predicted segmentation, uncertainty map | spatial uncertainty and image-level failure prediction | quality prediction without GT at test time | subject-level failure prediction is not novel; build a DeVries-style QC baseline |
| BraTS uncertainty evaluation | BraTS 2020 Task 3 / QU-BraTS | rank uncertainty maps for glioma subregion segmentation | segmentation + uncertainty maps | uncertainty scores associated with ET/TC/WT | Dice after filtering uncertain voxels plus filtered TP/TN penalties | uncertainty must be evaluated quantitatively, not visually; adapt uncertainty-error curves to binary whole-lesion target |
| Brain tumor segmentation QC | QCResUNet | subject-level and voxel-level segmentation quality prediction | multimodal MRI + generated segmentation masks | predicted DSC/NSD and voxel-level segmentation error map | Pearson/MAE for quality, error-map localization, internal/external datasets | direct threat; include QCResUNet-style baseline before G-SURE method claims |
| Image-specific segmentation QC | Fournel et al. MICCAI 2025 | estimate case-specific segmentation quality/difficulty | image, automated segmentation, uncertainty maps, radiomic/difficulty features | predicted inter-observer agreement / image-specific threshold | simulated clinical acceptance thresholding on multi-annotator lesion segmentation | fixed global Dice thresholding is weak; include difficulty/lesion-size proxies and stratified QC reporting |
| Medical segmentation calibration/evidential uncertainty | calibrated/evidential segmentation literature | improve uncertainty calibration | image, labels, evidential/probabilistic model | calibrated segmentation probabilities and uncertainty | calibration/error correspondence | calibration-only G-SURE claim is weak |
| Uncertainty-error alignment losses | AvU and related losses | align uncertainty with correctness | segmentation model outputs and correctness targets | uncertainty concentrated on errors | uncertainty-error correspondence | an uncertainty-error loss is not enough unless LOCO spatial reliability improves beyond baselines |
| Foundation/promptable medical segmentation reliability | U-MedSAM, SAM reliability papers | uncertainty/reliability for promptable segmentation | prompts + medical image | segmentation and uncertainty/reliability | challenge or dataset-specific segmentation metrics | foundation-model framing alone is not the contribution |
| Foundation-model data uncertainty | 2026 VFM aleatoric uncertainty preprint | estimate sample difficulty/uncertainty from foundation-model features | image features from medical visual foundation models | sample/class uncertainty scores, data filtering, dynamic optimization | segmentation performance across public datasets | noisy-label filtering or adaptive uncertainty-weighted training is not enough for G-SURE novelty |

## Source Details That Matter

### QCResUNet

Key facts from the MICCAI 2023 page and later arXiv/PubMed record:

- It targets brain tumor segmentation quality control.
- It predicts both subject-level segmentation-quality measures and voxel-level
  segmentation error maps.
- It uses multimodal MRI and image-segmentation pairs.
- It evaluates on BraTS 2021 internally and external BraTS-SSA/WUSM datasets.
- It reports subject-level quality through correlation/MAE for DSC/NSD and
  voxel-level error-map performance.
- Reviews explicitly raised the concern that simulated/generated segmentation
  errors may not represent real clinical/OOD failures.

G-SURE response:

- Use real full-volume OOF predictions from the segmentation baseline as error
  sources, not only synthetic corruptions.
- Use LOCO held-out consortium evaluation, not only internal split or generated
  errors.
- Compare directly against a QCResUNet-style model before claiming a method
  contribution.

Sources:

- https://conferences.miccai.org/2023/papers/524-Paper0839.html
- https://arxiv.org/html/2412.07156v2
- https://pubmed.ncbi.nlm.nih.gov/40945175/

### QU-BraTS / BraTS 2020 Uncertainty Task

Key facts from BraTS 2020 and QU-BraTS:

- BraTS included uncertainty maps associated with tumor subregions.
- The uncertainty task rewards confidence when predictions are correct and
  uncertainty when predictions are incorrect.
- The evaluation filters uncertain voxels across thresholds and combines Dice
  after filtering with penalties for filtering true positives and true negatives.
- QU-BraTS benchmarks uncertainty maps from multiple participating teams.

G-SURE response:

- Do not evaluate reliability maps visually only.
- Include an uncertainty-error curve adapted to binary whole-lesion segmentation.
- Penalize methods that mark too much correct tissue as uncertain.

Sources:

- https://www.med.upenn.edu/cbica/brats2020/tasks.html
- https://digitalcommons.odu.edu/ece_fac_pubs/356/
- https://openreview.net/forum?id=H-PvDNIex

### DeVries-Style Quality Prediction

Key facts:

- The work frames medical segmentation systems as failing silently.
- It uses spatial uncertainty maps as an intermediate representation.
- It predicts image-level segmentation failure/quality.
- It is designed to be attachable to arbitrary medical segmentation pipelines.

G-SURE response:

- Include a subject-level quality/failure predictor baseline.
- Use image, predicted probability/binary mask, and uncertainty/confidence maps
  as baseline inputs.
- Evaluate subject-level low-Dice detection before claiming reliability novelty.

Source:

- https://arxiv.org/abs/1807.00502

### 2024-2026 Targeted Update

QCResUNet has a 2025 Medical Image Analysis / PubMed record, making it a direct
journal-level prior for brain-tumor segmentation QC with voxel-level error maps.
This strengthens the requirement that G-SURE compare against QCResUNet-style
baselines using leakage-safe OOF error labels.

Sources:

- https://pubmed.ncbi.nlm.nih.gov/40945175/
- https://arxiv.org/html/2412.07156v2

MICCAI 2025 image-specific segmentation QC argues against a single global DSC
acceptance threshold by predicting case-specific segmentation difficulty from
inter-observer agreement. G-SURE should not rely on a fixed low-Dice label alone;
it should include lesion-size, predicted-volume, and difficulty-proxy baselines.

Source:

- https://papers.miccai.org/miccai-2025/0232-Paper4042.html

U-MedSAM and 2025 prompt-triggered SAM reliability papers show that foundation
medical segmentation uncertainty/reliability is already active. A foundation
model backbone is not a novelty claim unless the G-SURE evaluation and error
localization contribution remains clear.

Sources:

- https://arxiv.org/html/2408.08881v2
- https://openaccess.thecvf.com/content/ICCV2025W/CVAMD/papers/Zhang_Enhancing_the_Reliability_of_Auto-Prompting_SAM_for_Medical_Image_Segmentation_ICCVW_2025_paper.pdf

A 2026 visual-foundation-model aleatoric uncertainty preprint uses foundation
model feature diversity for sample difficulty and training-time uncertainty
handling. This is a warning against framing G-SURE as only sample difficulty,
noisy-label filtering, or adaptive loss weighting.

Source:

- https://arxiv.org/html/2604.10963v1

## Mandatory Baseline Consequences

G-SURE must not proceed directly from B1 segmentation to a new method.

Required baseline families:

1. segmentation-only probability map,
2. entropy/confidence from the probability map,
3. TTA uncertainty,
4. ensemble or repeated-seed disagreement,
5. DeVries-style subject-level quality predictor,
6. QCResUNet-style subject-level QC plus voxel error-map predictor,
7. lesion-size, predicted-volume, and image-difficulty proxy baselines,
8. reliability head without explicit grounding constraint,
9. G-SURE full method only after a gap remains.

## Leakage-Safe QC Training Requirement

QC/error-map baselines need labels derived from segmentation errors. Those labels
must obey the same leakage standard as G-SURE:

- outer held-out consortium rows may be used only for evaluation,
- second-stage QC training labels for training subjects must come from
  train-consortia inner-OOF predictions or an explicitly approved train-only
  protocol,
- in-sample predictions from a model evaluated on its own training rows are
  diagnostic only,
- patch-only or center-crop predictions are ineligible,
- full-volume prediction artifact validation must pass first.

This requirement is expensive, but without it the QC baseline can leak and make
the G-SURE comparison invalid.

## Reviewer Attack Converted To Test

| reviewer attack | required test |
|---|---|
| "This is just uncertainty estimation." | compare against entropy, TTA, MC dropout if available, and ensemble disagreement |
| "This is just segmentation QC." | compare against DeVries-style and QCResUNet-style QC baselines |
| "Error maps come from model artifacts." | train/evaluate on real OOF errors and report cross-consortium results |
| "Reliability is lesion-size driven." | include lesion-size-only and predicted-volume-only baselines |
| "Quality is just case difficulty." | include image-difficulty proxies and lesion/volume strata |
| "Uncertainty maps only highlight boundaries." | report FP and FN localization separately, not only boundary/ERR aggregate |
| "Annotation style dominates." | report per-consortium and mask-source stratified metrics |

## Method-Lock Rule

Do not lock or implement the G-SURE method until:

1. official split exists,
2. B1 full-volume OOF predictions exist,
3. prediction artifacts pass validators,
4. error labels are generated from OOF predictions,
5. uncertainty/QC baselines are either implemented or explicitly scoped as
   infeasible with a documented reason,
6. a baseline gap remains under LOCO evaluation.
