# Manuscript Outline

## Abstract

Problem:

- few-shot clinical generalization in 3D brain MRI is hard across segmentation, classification, regression, and embedding tasks.

Method:

- ResEnc foundation model with S3D-style anti-leakage dense branch and InfoNCE global branch.

Results:

- fill with final internal + external results.

Conclusion:

- dense-global balance and foundation-preserving fine-tuning are important for few-shot transfer.

## 1. Introduction

- Heterogeneous clinical brain MRI tasks need a single transferable representation.
- Existing 3D medical foundation models often emphasize either segmentation or global representation.
- Few-shot fine-tuning can erase useful pretrained priors.
- Contributions:
  1. anti-leakage dense branch for decoder transfer
  2. InfoNCE global branch for cls/reg stability
  3. local-global checkpoint selection
  4. external/few-shot downstream validation

## 2. Related Work

Sections:

- 3D medical SSL and foundation models
- masked image modeling in medical imaging
- contrastive/global representation learning
- few-shot medical segmentation
- fine-tuning protocols and catastrophic forgetting

## 3. Methods

### 3.1 Data and Pretraining

- foundation pretraining dataset
- preprocessing
- data independence rules

### 3.2 Architecture

- ResEnc backbone
- dense S3D-style branch
- global InfoNCE branch
- total loss

### 3.3 Downstream Adaptation

- classification/regression heads
- segmentation decoder transfer
- frozen/low-LR/full fine-tuning protocols
- embedding extraction

### 3.4 Evaluation

- tasks
- splits
- metrics
- statistical tests

## 4. Results

### 4.1 Architecture Ablation

- skip-free vs S3D
- dense-only vs global-only vs balanced

### 4.2 Internal Heterogeneous Transfer

- challenge-style tasks

### 4.3 External Consortium Generalization

- independent data
- label-efficiency curves
- site/scanner subgroup

### 4.4 Fine-Tuning Protocol Matters

- Task2 R4
- frozen vs low-LR vs full-FT

### 4.5 Failure Analysis

- Task2 false negatives
- official Task1 hidden-set drop
- modality/spacing effects

## 5. Discussion

- what the model solves
- where it fails
- implications for brain MRI foundation models
- why preserving priors matters in few-shot settings

## 6. Limitations

- data scale
- challenge hidden-set uncertainty
- Task2 weak performance if unresolved
- baseline coverage

## 7. Conclusion

- single-checkpoint dense-global brain MRI foundation model
- practical recommendation: balanced SSL + foundation-preserving adaptation
