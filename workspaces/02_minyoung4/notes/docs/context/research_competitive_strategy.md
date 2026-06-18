# Competitive Research Strategy After Prior-Work Search

Generated for `/home/vlm/minyoung4` after targeted literature search on glioma MRI IDH prediction, VLMs, foundation models, and multi-center validation.

## Bottom Line

The broad topic **"glioma MRI VLM for molecular/IDH prediction" is already taken**.

The strongest direct prior is **Glio-LLaMA-Vision** in npj Digital Medicine 2026, which uses multiparametric MRI and paired radiology reports for molecular status prediction and radiology report generation in adult-type diffuse gliomas. It reports IDH AUCs of 0.85-0.95 across internal/external datasets and validates on AMC, TCGA, and UCSF.

Therefore, our conference strategy should not be:

- "We propose a glioma VLM."
- "We predict IDH from MRI."
- "We use segmentation plus MRI for IDH."
- "We use a foundation model for glioma IDH."

Those claims are crowded by Glio-LLaMA-Vision, FoundBioNet, MTS-UNET, AVLT, and many MRI-radiogenomics studies.

The defensible route is:

> A public multi-consortium benchmark and robust modeling study for clinical-prompted 3D MRI glioma IDH prediction under severe dataset/scanner/age shift.

## What We Have

From our EDA:

| Cohort / Feature | Subjects | Note |
|---|---:|---|
| Structural MRI core | 1,636 | T1/T1ce-or-post/T2/FLAIR common core |
| Structural + age/sex/scanner | 1,608 | Base reporting/split-balance schema |
| Structural + IDH | 1,457 | First supervised candidate |
| Structural + segmentation + IDH | 1,439 | Mask-aware variant, but one UCSD zero-byte mask needs policy |
| Structural + MGMT | 815 | Second-stage target |
| Structural + diffusion + perfusion | 669 | Advanced imaging subset |
| Structural + linked histopath | 18 | Pilot only |

IDH target imbalance is substantial:

| Dataset | Eligible | Mutant | Wildtype | Mutant Rate |
|---|---:|---:|---:|---:|
| UTSW | 622 | 176 | 446 | 28.30% |
| MU-Glioma-Post | 189 | 28 | 161 | 14.81% |
| UCSD-PTGBM | 121 | 12 | 109 | 9.92% |
| UPENN-GBM | 525 | 19 | 506 | 3.62% |

This is not just a nuisance. It is the main research opportunity: models can exploit dataset/scanner/age shortcuts unless evaluated correctly.

## Prior-Work Landscape

See `docs/context/prior_work_landscape.csv` for the source-backed table.

Key takeaways:

1. **Glio-LLaMA-Vision** already covers adult diffuse glioma VLM, molecular status prediction, and report generation with paired MRI-report data.
2. **FoundBioNet** and **MTS-UNET** already cover foundation-style/multitask MRI IDH prediction with tumor-aware modules and multi-center public datasets.
3. External validation for IDH prediction is already expected, not novel.
4. General brain MRI foundation models such as **Prima** and **BrainIAC** raise the bar for any "foundation model" claim.
5. Multimodal MRI-pathology-text benchmarks are emerging, but our linked histopath subset is too small to compete directly.

## Recommended Paper Positioning

### Working Title

**Public Multi-Consortium Evaluation of Clinical-Prompted 3D MRI Models for Glioma IDH Prediction Under Dataset Shift**

Alternative stronger title if method works:

**Shift-Aware Clinical-Prompted 3D MRI Modeling for Glioma IDH Prediction Across Public Consortia**

### Main Claim

Not "we invented a VLM."

Instead:

> We show that MRI-based glioma molecular prediction is strongly affected by dataset, scanner, and age shortcuts, and provide a reproducible public multi-consortium benchmark with shift-aware evaluation and clinical-prompted 3D MRI baselines.

### Technical Novelty Options

Pick one primary technical contribution, not all at once:

1. **Shift-aware clinical-prompt conditioning**
   - Convert structured clinical/scanner variables into controlled prompts.
   - Use frozen ClinicalBERT/BioClinicalBERT or small text encoder.
   - Fuse with 3D MRI encoder using cross-attention or FiLM/adaptive normalization.
   - Include ablations: image only, image + tabular MLP, image + prompt text, prompt shuffled, scanner removed.

2. **Domain-generalized IDH prediction benchmark**
   - Leave-one-consortium-out evaluation is the central protocol.
   - Compare ERM vs domain-adversarial loss vs CORAL/MMD vs domain-specific normalization vs group DRO.
   - Report whether methods reduce UTSW/UPENN rate shortcut.

3. **Mask-aware vs mask-free tumor representation under shift**
   - Compare whole-brain, tumor bounding box, segmentation mask pooling, and mask-eroded/dilated variants.
   - Important because segmentation is available for 1,617/1,636 subjects but not perfect.
   - Must handle UPENN missing 19 segmentation subjects and UCSD zero-byte mask.

4. **Calibration and abstention under external shift**
   - Report AUC plus balanced accuracy, MCC, AUPRC, ECE, Brier score, calibration curves.
   - Add conformal/uncertainty abstention under leave-one-consortium-out.
   - Competitive if it shows safe failure behavior on UPENN or UCSD.

## Must-Have Experimental Design

### Cohort

Primary:

- `eligible_T1_structural_idh`
- 1,457 subjects
- Input: T1, T1ce/T1post, T2, FLAIR
- Label: IDH mutant vs wildtype

Optional variants:

- T1b: structural + segmentation + IDH, 1,439 subjects
- T2: structural + MGMT, 815 subjects

### Split Policy

Required:

- Use `dataset::subject_id` as grouping key.
- No unit-level random split.
- Use leave-one-consortium-out as the key reported external setting:
  - Train MU+UCSD+UPENN, test UTSW
  - Train UTSW+UCSD+UPENN, test MU
  - Train UTSW+MU+UPENN, test UCSD
  - Train UTSW+MU+UCSD, test UPENN

Also include pooled grouped split only as secondary, not headline.

### Metrics

Minimum:

- AUC
- AUPRC
- balanced accuracy
- MCC
- sensitivity/specificity
- calibration ECE
- Brier score
- bootstrap confidence intervals

Required stratified reports:

- dataset
- scanner vendor
- field strength
- age bin
- sex
- IDH class

### Baselines

Use a hierarchy:

1. Clinical/scanner-only baseline
2. 3D ResNet/DenseNet image-only
3. 3D Swin/UNETR/SwinUNETR image-only
4. Image + tabular MLP
5. Image + structured clinical prompt encoder
6. Shift-aware method variant
7. Optional frozen foundation encoder baseline if feasible:
   - BrainIAC
   - Prima if usable
   - Glio-LLaMA-Vision components if practical and licensing permits

## What Not To Claim

Avoid:

- "First VLM for glioma molecular prediction."
- "First MRI IDH predictor."
- "First segmentation-aware IDH model."
- "Foundation model" if training only on our 1,636-subject cohort.
- Report generation unless actual paired reports are available.

## Strongest Novelty Angle With Our Data

The most defensible novelty is a **stress-tested public benchmark**:

1. Four public/locally downloaded consortia with different label/scanner distributions.
2. Explicit quantification of shortcut risk before modeling.
3. Leave-one-consortium-out evaluation as the main endpoint.
4. Clinical-prompt conditioning and domain-shift mitigation.
5. Calibration/abstention under severe class imbalance.

This can be competitive for MIDL/MICCAI-style venues if the experimental execution is rigorous.

## Immediate Next Steps Before Modeling

Approval-gated:

1. Full NIfTI header audit.
2. UCSD zero-byte segmentation repair/exclude decision.
3. UPENN duplicate old/non-old structural path preference.
4. Preprocessing policy:
   - orientation
   - spacing
   - crop/resize
   - intensity normalization
   - mask/bounding-box policy
5. Split protocol file generation.

Do not start training before these gates.

## Source Links

- Glio-LLaMA-Vision, npj Digital Medicine 2026: https://www.nature.com/articles/s41746-026-02581-x
- Glio-LLaMA-Vision abstract: https://academic.oup.com/neuro-oncology/article/27/Supplement_5/v273/8319169
- Glio-LLaMA-Vision GitHub: https://github.com/myeongkyunkang/Glio-LLaMA-Vision
- FoundBioNet MICCAI 2025: https://papers.miccai.org/miccai-2025/paper/4377_paper.pdf
- MTS-UNET foundation/multitask model: https://arxiv.org/pdf/2503.06828
- External IDH validation study: https://academic.oup.com/noa/article/6/1/vdae157/7808961
- DL IDH/1p19q systematic review: https://pmc.ncbi.nlm.nih.gov/articles/PMC12953305/
- AVLT CNS tumor VLM: https://www.mdpi.com/2227-9059/13/12/2864
- AVLT GitHub: https://github.com/imashoodnasir/Multimodal-CNS-Tumor-Diagnosis
- CoRe-BT multimodal benchmark: https://arxiv.org/html/2603.03618v1
- Prima brain MRI VLM: https://github.com/MLNeurosurg/Prima
- BrainIAC: https://github.com/AIM-KannLab/BrainIAC
