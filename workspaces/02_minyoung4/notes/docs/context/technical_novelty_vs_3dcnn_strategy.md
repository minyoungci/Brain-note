# Technical Novelty Strategy: Beating 3D CNN Baselines

Goal: build a technically defensible model that can beat standard 3D CNN baselines on public multi-consortium glioma IDH prediction, especially under dataset shift.

This document is a protocol plan only. It does not create splits, preprocess images, run full image audits, or train models.

## Position

The paper should not be framed as "a new glioma VLM" or "first IDH prediction model." Prior work already covers those.

The technical goal should be:

> Beat strong 3D CNN baselines under leave-one-consortium-out evaluation by using shift-aware clinical-prompt conditioning and mask-aware tumor-context representation.

The novelty is not the IDH task itself. The novelty is the combination of:

1. public multi-consortium stress test,
2. 3D MRI model conditioned on structured clinical context,
3. segmentation-derived tumor/context tokens without requiring masks at inference,
4. domain-shift regularization,
5. calibration/abstention under severe label imbalance.

## Primary Task

Use the EDA-defined cohort:

- Cohort: `eligible_T1_structural_idh`
- Subjects: 1,457
- Input MRI: T1, T1ce/T1post, T2, FLAIR
- Label: IDH mutant vs wildtype
- Positive/negative: mutant 235, wildtype 1,222
- Split key: `dataset::subject_id`

Optional variant:

- `eligible_T1b_structural_segmentation_idh`
- Subjects: 1,439
- Adds segmentation-derived tumor/context representation

## Why 3D CNN Is Beat-able Here

A plain 3D CNN sees only image voxels and is vulnerable to:

- site/scanner acquisition differences,
- IDH label imbalance by dataset,
- age-related shortcut,
- limited positive examples in UPENN and UCSD,
- whole-brain noise when tumor localization is available but not explicitly used.

Our EDA shows the shortcut problem:

| Dataset | IDH Eligible | Mutant | Wildtype | Mutant Rate |
|---|---:|---:|---:|---:|
| UTSW | 622 | 176 | 446 | 28.30% |
| MU-Glioma-Post | 189 | 28 | 161 | 14.81% |
| UCSD-PTGBM | 121 | 12 | 109 | 9.92% |
| UPENN-GBM | 525 | 19 | 506 | 3.62% |

If a model wins only on pooled random split, the result is weak. If it wins under leave-one-consortium-out, scanner-aware reporting, and calibration, the result is much stronger.

## Proposed Main Model

Working name:

**SHIFT-IDH: Shift-aware Clinical-Prompted Tumor-Context 3D MRI Model**

Core components:

1. **3D MRI encoder**
   - Start with 3D ResNet/SwinUNETR-style encoder.
   - Input channels: T1, T1ce/T1post, T2, FLAIR.

2. **Clinical prompt encoder**
   - Convert structured metadata into controlled prompts:
     - age bin,
     - sex,
     - scanner vendor,
     - field strength,
     - dataset optional only for diagnostics, not final prompt unless justified.
   - Example prompt:
     - `age: 60_69; sex: male; scanner_vendor: siemens; field_strength: 3T`
   - Encode with one of:
     - small learned token embedding,
     - lightweight transformer,
     - frozen ClinicalBERT/BioClinicalBERT if practical.

3. **Prompt-conditioned visual modulation**
   - Use FiLM/adaptive normalization or cross-attention to condition MRI features on clinical prompt.
   - This should beat naive image+tabular concatenation if the prompt mechanism is real.

4. **Optional tumor-context tokens**
   - If segmentation is available:
     - tumor token,
     - peritumoral/context token,
     - whole-brain/global token.
   - Train with mask dropout so the model can still run when masks are missing.
   - This is important because segmentation is 1,617/1,636 subjects, not 100%.

5. **Domain-shift regularization**
   - Compare:
     - ERM,
     - CORAL/MMD feature alignment,
     - domain adversarial loss,
     - group DRO by dataset,
     - domain-specific normalization.
   - The final model should reduce failure on UPENN and UCSD without just learning dataset priors.

6. **Calibration and abstention**
   - Add temperature scaling on validation consortium.
   - Report ECE, Brier score, selective risk/coverage.

## Baselines To Beat

The experiment matrix is in:

`docs/context/technical_novelty_vs_3dcnn_experiment_matrix.csv`

Minimum baselines:

1. `B0_clinical_only`
   - Logistic regression / XGBoost on age, sex, scanner, field.
   - Shows how much shortcut exists without MRI.

2. `B1_3d_resnet_image_only`
   - Main 3D CNN baseline.

3. `B2_3d_densenet_image_only`
   - Secondary CNN baseline.

4. `B3_3d_cnn_plus_tabular`
   - Tests whether prompt model is better than simple tabular concatenation.

5. `B4_mask_crop_3d_cnn`
   - Tests whether tumor localization alone explains gains.

Main model:

- `N3_shift_aware_prompt_model`

Ablations:

- prompt shuffle,
- scanner removed,
- mask dropout,
- dataset label probe.

## How We Know We Beat 3D CNN

Do not use only one metric.

A credible win requires:

1. Better mean leave-one-consortium-out AUC than B1/B2.
2. Better AUPRC or MCC, because class imbalance is severe.
3. Better calibration:
   - lower ECE,
   - lower Brier score.
4. No collapse on UPENN:
   - UPENN has only 19 mutants in the IDH cohort.
5. Prompt contribution verified:
   - true prompt > shuffled prompt,
   - prompt model > tabular concatenation.
6. Shift handling verified:
   - domain-shift regularized model > ERM under LOCO.

Headline should be something like:

> SHIFT-IDH improves leave-one-consortium-out AUC/AUPRC and calibration over strong 3D CNN baselines while reducing dataset/scanner shortcut sensitivity.

## Evaluation Protocol

Primary:

- Leave-one-consortium-out:
  - test UTSW,
  - test MU,
  - test UCSD,
  - test UPENN.

Secondary:

- grouped pooled split,
- internal validation per training split,
- bootstrap confidence intervals.

Metrics:

- AUC,
- AUPRC,
- balanced accuracy,
- MCC,
- sensitivity,
- specificity,
- ECE,
- Brier score,
- selective risk at fixed coverage.

Stratified reporting:

- dataset,
- scanner vendor,
- field strength,
- age bin,
- sex,
- IDH class.

## What Would Make This Conference-Competitive

The strongest possible result:

1. 3D CNN does okay on pooled split but fails under LOCO.
2. Clinical-only model exposes dataset/scanner/age shortcut.
3. SHIFT-IDH improves LOCO performance over 3D CNN and tabular fusion.
4. Prompt-shuffle ablation drops performance.
5. Calibration/abstention is better under UPENN/UCSD external testing.
6. The analysis is reproducible using public multi-consortium data and transparent splits.

This is a stronger story than simply reporting a high AUC.

## Red Lines

Do not claim:

- first IDH predictor,
- first VLM,
- first segmentation-aware IDH model,
- foundation model,
- report generation.

Do not use:

- unit-level random split,
- dataset label in final clinical prompt unless clearly framed as diagnostic/upper-bound,
- test-consortium statistics for normalization,
- segmentation masks without resolving the UCSD zero-byte file and UPENN missing masks.

## Approval-Gated Prerequisites

Before implementation/training:

1. Full NIfTI header audit.
2. UCSD zero-byte segmentation policy.
3. UPENN duplicate old/non-old structural path preference.
4. Preprocessing geometry/orientation/spacing/normalization policy.
5. Subject-level split protocol approval.
6. GPU training approval.

## Immediate Next Engineering Step

After approval, create a minimal modeling scaffold:

- `src/data/manifest.py`
- `src/data/preprocess.py`
- `src/splits/make_idh_loco_splits.py`
- `src/models/resnet3d.py`
- `src/models/shift_idh.py`
- `src/train.py`
- `configs/idh_loco/*.yaml`

Do not create this scaffold before the modeling protocol is approved.
