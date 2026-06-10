# Manual Full-Review Queue

Created: 2026-05-16

Purpose: 자동 API triage 결과를 그대로 믿지 않고, Min의 연구 방향 결정에 실제로 필요한 논문/데이터셋 문서를 수동 full-review 대상으로 분리한다.

## Review extraction fields

각 항목은 full abstract/full text 확인 후 아래 필드를 채운다.

```yaml
title:
pmid_doi_url:
venue_year:
IF:
citations_openalex:
dataset:
sample_count:
modality_input:
target_task:
unit_of_analysis:
split_external_validation:
metrics:
baselines:
main_result:
limitations:
shortcut_or_leakage_risk:
relevance_to_our_data:
possible_extension:
claim_strength_for_us:
review_status:
```

## A. Dataset / protocol anchors

### A1. ADNI MRI methods

- Title: The Alzheimer's Disease Neuroimaging Initiative (ADNI): MRI methods.
- PMID: `18302232`
- DOI: `10.1002/jmri.21049`
- OpenAlex citations from seed: `4336`
- Why: ADNI MRI acquisition/preprocessing/protocol anchor. Must understand before comparing our T1w pipeline to ADNI-derived work.
- Status: `needs_full_review`

### A2. Design and validation of the ADNI MR protocol

- PMID: `39115941`
- Journal: *Alzheimer's & Dementia*, 2024
- OpenAlex citations from seed: `18`
- Why: updated ADNI MR protocol; important for harmonization and scanner/site arguments.
- Status: `needs_full_review`

### A3. OASIS-3 official dataset documentation / paper

- Source: NITRC OASIS-3 official page; official homepage listed in notebook.
- Why: external/cohort-shift anchor for MRI/PET/clinical longitudinal work.
- Missing: exact dataset paper PMID/DOI needs API lookup and official homepage extraction.
- Status: `needs_dataset_doc_review`

### A4. NACC UDS / MRI / neuropathology documentation

- Why: NACC differs from ADNI/OASIS in clinical ascertainment, MRI availability, and neuropathology labels. Essential for shortcut/domain-shift analysis.
- Missing: official docs and representative imaging/AD papers need API lookup.
- Status: `needs_dataset_doc_review`

### A5. AIBL cohort / amyloid PET / MRI documentation

- Why: AIBL can be external/OOD or amyloid-rich comparator. Need confirm PET tracer/centiloid availability and MRI compatibility.
- Status: `needs_dataset_doc_review`

## B. MRI → PET / ATN biomarker prediction anchors

### B1. Deep Learning-Based Prediction of PET Amyloid Status Using MRI

- PMID: `40579043`
- DOI: `10.3174/ajnr.A8899`
- Journal: *AJNR American Journal of Neuroradiology*, 2025
- Datasets: ADNI, OASIS3, A4; external Stanford ADRC
- Known from seed: T1w-only AUC about `0.61`; T1w+FLAIR AUC about `0.67`; external AUC about `0.65`.
- Why: directly overlaps our T1w/PET amyloid direction.
- Status: `needs_full_review`

### B2. MRI-based Deep Learning Assessment of Amyloid, Tau, and Neurodegeneration Biomarker Status across the Alzheimer Disease Spectrum

- PMCID: `PMC10623183`
- Journal: *Radiology*, 2023
- Dataset: ADNI
- Known from seed: MRI+clinical ATN AUCs amyloid `0.79`, tau `0.73`, neurodegeneration `0.86`.
- Why: strong ATN benchmark and clinical-feature caution.
- Status: `needs_full_review`

### B3. Multimodal integration of plasma biomarkers, MRI, and genetic risk to predict cerebral amyloid burden in Alzheimer's disease

- PMID: `41135743`
- Journal: *NeuroImage*, 2025/2026 seed result
- Why: may define modern non-image + MRI amyloid burden benchmark; important if blood/plasma is a stronger shortcut baseline.
- Status: `needs_full_review`

## C. Longitudinal progression / MCI conversion anchors

### C1. Structural MRI and Amyloid PET Imaging for Prediction of Conversion to AD in MCI: A Meta-Analysis

- PMID: `28326120`
- Why: establishes older but useful structural MRI vs amyloid PET prognostic effect-size context.
- Status: `needs_full_review`

### C2. Cross-cohort generalizability of deep and conventional machine learning for MRI-based diagnosis and prediction of Alzheimer's disease

- PMID: `34118592`
- DOI: `10.1016/j.nicl.2021.102712`
- OpenAlex citations from seed: `103`
- Why: directly relevant to reviewer question: does MRI model generalize across cohorts or exploit dataset shortcuts?
- Status: `needs_full_review`

### C3. Using machine learning to quantify structural MRI neurodegeneration patterns of Alzheimer's disease into dementia score: Independent validation on 8,834 images from ADNI, AIBL, OASIS, and MIRIAD databases

- PMID: `32614505`
- DOI: `10.1002/hbm.25115`
- OpenAlex citations from seed: `90`
- Why: multi-dataset structural MRI disease-score anchor; relevant to CN/AD disease-axis and PET transfer framing.
- Status: `needs_full_review`

### C4. Predicting the progression of MCI and Alzheimer's disease on structural brain integrity and other features with machine learning

- PMID: `40285975`
- Why: recent MCI/AD progression paper using structural brain integrity; check if task overlaps our longitudinal direction.
- Status: `needs_abstract_screen_first`

## D. MRI/PET multimodal fusion anchors

### D1. An Effective Multimodal Image Fusion Method Using MRI and PET for Alzheimer's Disease Diagnosis

- PMID: `34713109`
- DOI: `10.3389/fdgth.2021.637386`
- Why: common ADNI MRI/PET fusion baseline; likely diagnosis-classification saturated literature, useful as caution not main novelty.
- Status: `screen_for_baseline_only`

### D2. Multi-scale multimodal deep learning framework for Alzheimer's disease diagnosis

- PMID: `39579666`
- DOI: `10.1016/j.compbiomed.2024.109438`
- Why: recent MRI/PET AD diagnosis fusion; check baseline and whether task is only diagnosis classification.
- Status: `needs_abstract_screen_first`

## E. Conference VLM / brain MRI anchors

### E1. Enhancing vision-language models for medical imaging: bridging the 3D gap with innovative slice selection

- Venue: **NeurIPS 2024 Datasets and Benchmarks Track**; not workshop.
- URL: `https://openreview.net/forum?id=JrJW21IP9p`
- Authors: Yuli Wang et al.
- Dataset/benchmark: **BrainMD**, `2,453` annotated 3D MRI brain scans with radiology reports and EHR; BrainMD-select; BrainBench.
- Method: **Vote-MI**, unsupervised representative slice selection for adapting 2D VLMs to 3D MRI/CT-like volumes.
- Reported seed facts: average absolute gain `14.6%` zero-shot and `16.6%` few-shot over random slice/example selection.
- Why: strongest non-workshop conference anchor found for brain MRI VLM mechanics. Not AD-specific, but directly relevant to the 3D-volume-to-2D-VLM bottleneck and benchmark design.
- Status: `read_next_for_conference_vlm_anchor`

### E2. Medical Vision-Language Pre-Training for Brain Abnormalities

- Venue: **LREC-COLING 2024 main conference**.
- URL/PDF: `https://aclanthology.org/2024.lrec-main.973.pdf`
- Authors: Masoud Monajatipoor et al.
- Dataset: PubMed-derived brain abnormality image-caption pairs; `9,371` papers, `22,795` initial image-caption pairs, `39,535` processed subfigure/subcaption pairs.
- Method: automated medical image-text collection and subfigure-subcaption alignment; BLIP pretraining.
- Why: conference anchor for brain-domain VL pretraining/data construction. Less directly aligned with our 3D T1w cohort setting because images are publication figures rather than subject-level MRI volumes.
- Status: `secondary_conference_vlm_anchor`

## Immediate interpretation discipline

- Diagnosis-only MRI/PET fusion papers are not automatically strong novelty anchors. They mainly define saturated baselines and reviewer expectations.
- MRI→amyloid/PET transfer and cross-cohort generalization are more directly useful for our potential contribution.
- T1w-only PET prediction appears modest in current seed evidence; our claim must be framed as incremental value under constrained modality and multi-cohort validation, not as replacing PET.
- For VLM-specific reading, separate **conference/main-track VLM mechanics** from **AD-specific journal VLM competitors**. Current strongest conference anchor is BrainMD/Vote-MI; current strongest AD-specific VLM anchor remains ADLIP journal paper.
