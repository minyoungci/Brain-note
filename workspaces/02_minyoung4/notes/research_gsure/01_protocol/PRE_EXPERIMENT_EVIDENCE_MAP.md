# Pre-Experiment Evidence Map

This document lists the evidence required before running segmentation or
grounding-reliability experiments.

## 1. Dataset Identity

Question:
- What datasets are included, and what does each contribute?

Required evidence:
- dataset name,
- source package,
- subject count,
- imaging unit count,
- session/timepoint count,
- available MRI channels,
- available segmentation keys,
- available clinical/scanner metadata.

Current status:
- Stage 1 path inventory completed.
- Four datasets are present: MU-Glioma-Post, UCSD-PTGBM, UPENN-GBM, UTSW.
- Draft subject-level primary cohort contains 1,614 selected subjects.

Remaining risk:
- The 1,614-subject cohort is draft-ready but not official until Min approves
  the subject-level cohort and LOCO split creation.

## 2. Unit of Analysis

Question:
- Is the analysis unit subject, visit/session, scan, or package file?

Required evidence:
- subject ID parser per dataset,
- session/timepoint parser per dataset,
- repeated-session distribution,
- one-unit-per-subject policy,
- longitudinal leakage risk.

Current status:
- Path-level unit IDs exist.
- Candidate unit-level manifest exists.
- Subject-level draft selection exists using one selected unit per subject.
- Current selection policy is `one_unit_per_subject_earliest_numeric_order`.

Remaining risk:
- Official selected unit policy is not locked until explicit approval.
- MU and UCSD include multi-timepoint/post-treatment patterns and require
  disclosure/sensitivity analysis.

## 3. MRI Channel Definition

Question:
- Can every included unit supply the same structural MRI input?

Required evidence:
- T1 availability,
- T1ce/T1-post availability,
- T2 availability,
- FLAIR availability,
- shape/affine/spacing compatibility,
- registered versus unregistered variants,
- missing-channel policy.

Current status:
- Filename-level modality grouping exists.
- Draft selected subject rows have required T1, T1ce, T2, FLAIR, and selected
  mask paths.
- Post-split loader smoke script exists and checks sampled channel/mask shape,
  affine, orientation, spacing, finite values, and non-empty binary target.

Remaining risk:
- Official post-split loader smoke is still pending because the official split
  manifest does not exist.

## 4. Segmentation Mask Taxonomy

Question:
- What exact anatomical target does each segmentation file represent?

Required evidence:
- segmentation key,
- binary or multilabel values,
- observed label values,
- empty/all-zero masks,
- zero-byte masks,
- whole tumor / tumor core / enhancing / edema semantics,
- manual-correction precedence.

Current status:
- Path-level segmentation keys are known.
- Mask value/geometry audit completed for candidate masks.
- Primary draft target is binary whole-lesion candidate:
  `selected_mask > 0`.
- UTSW primary source is FeTS-style segmentation only.

Remaining risk:
- Subregion harmonization is not claimed.
- Source mask semantics still require conservative reporting.

## 5. Image-Mask Geometry

Question:
- Does each mask align with the structural MRI channels?

Required evidence:
- mask shape,
- MRI shape,
- affine equality or tolerable difference,
- voxel spacing,
- orientation codes,
- cropped/resampled mask detection,
- per-modality match status.

Current status:
- Selected mask geometry is audited.
- Selected mask shapes/orientations are concentrated in two groups:
  `240x240x155 / LPS` and `256x256x256 / ILA`.
- Selected mask spacing is `1x1x1`.
- Sample loader smoke has been prepared for post-split verification.

Remaining risk:
- Official split-aware loader smoke remains pending.
- UCSD geometry/orientation shift must be handled by loader policy and disclosed
  in reports.

## 6. Cohort Definition

Question:
- Which cases are valid for the first official experiment?

Required evidence:
- inclusion criteria,
- exclusion criteria,
- missingness table,
- target-mask availability,
- all-four-channel availability,
- one selected unit per subject,
- consortium representation.

Current status:
- Draft primary cohort exists:
  - MU-Glioma-Post: 203 subjects
  - UCSD-PTGBM: 178 subjects
  - UPENN-GBM: 611 subjects
  - UTSW: 622 subjects
  - total: 1,614 subjects

Remaining risk:
- Training before official cohort/split lock would create moving targets and
  irreproducible results.

## 7. Split Policy

Question:
- How will generalization be tested without leakage?

Required evidence:
- subject-level grouping,
- session-level grouping,
- LOCO fold definitions,
- no subject overlap across train/test,
- no near-duplicate longitudinal leakage,
- no mask-derived preprocessing leakage.

Current status:
- LOCO is the candidate primary split.
- LOCO readiness audit reports 0 subject overlap and 0 secondary-unit leakage.
- Split builder dry-run validates 6,456 fold rows and 4 fold summaries.
- Official split artifact checker exists.

Remaining risk:
- Official split artifacts are intentionally absent until explicit approval.

## 8. Baselines

Question:
- What must be beaten before claiming a method contribution?

Required evidence:
- naive lesion-size/failure baseline,
- plain 3D U-Net or ResUNet segmentation baseline,
- TTA uncertainty,
- ensemble disagreement,
- reliability/error-head baseline,
- G-SURE full method.

Current status:
- Baseline contract and segmentation baseline protocol drafted.
- GPU preview contract drafted.
- No baseline implementation or training has been run.

Remaining risk:
- Architecture choice is not the contribution; the reliability task and
  evaluation must be stronger than standard uncertainty baselines.
- A weak segmentation baseline would make later reliability conclusions
  uninterpretable.

## 9. Grounding and Reliability Labels

Question:
- What is the supervised target for visual grounding or failure localization?

Required evidence:
- error maps from out-of-fold predictions,
- false-positive and false-negative regions,
- boundary bands,
- low-Dice subject labels,
- pseudo-label generation policy,
- train-only or OOF constraint.

Current status:
- OOF prediction/reliability contract drafted.
- OOF prediction manifest validator exists and passes synthetic self-test.
- Prediction artifact validator exists and passes synthetic self-test.
- First reliability label policy drafted.
- Reliability label generator and validator pass synthetic self-tests.
- No real reliability labels exist.

Remaining risk:
- In-sample error labels would leak model failures into training.
- Reliability labels remain blocked until OOF full-volume predictions exist and
  validators pass.

## 10. Metrics and Decision Rules

Question:
- What result would support or kill the research direction?

Required evidence:
- Dice,
- HD95 or surface Dice,
- Dice failure rate,
- voxel-level error AUROC/AUPRC,
- subject-level low-Dice AUROC/AUPRC,
- reliability calibration,
- per-consortium metrics,
- lesion-size strata,
- pre-registered go/no-go rule.

Current status:
- Candidate metrics listed in the protocol and baseline contracts.
- No segmentation or reliability results exist yet.

Remaining risk:
- Dice improvement alone is not enough for this research direction.
- Reliability/error localization metrics need real OOF predictions before they
  can be finalized.

## 11. Confounding and Reviewer Risks

Question:
- What would a reviewer attack first?

Required evidence:
- site/scanner distributions,
- mask-source/manual-correction differences,
- post-treatment versus pre-treatment ambiguity,
- structural-channel availability imbalance,
- lesion-size distribution by consortium,
- failure cases by dataset.

Current status:
- Partially audited:
  - consortium geometry/orientation shift,
  - lesion burden patterns,
  - timing warning distribution,
  - repeated-unit leakage risk,
  - post-treatment/multi-timepoint risk.

Remaining risk:
- Reliability maps might learn dataset-specific mask style rather than true
  segmentation failure.
- Scanner/source annotation style confounding remains a reviewer risk.

## 12. Literature and Novelty

Question:
- Is G-SURE technically different from existing uncertainty, calibration, and
  segmentation-error prediction work?

Required evidence:
- prior work on glioma segmentation uncertainty,
- prior work on segmentation quality control,
- prior work on error prediction/failure localization,
- prior work on visual grounding in medical imaging,
- explicit novelty delta.

Current status:
- Initial scout verified in this session:
  `research_gsure/00_context/20260623_gsure_literature_scout.md`.
- Targeted 2024-2026 update added for segmentation QC, foundation-model
  segmentation uncertainty, promptable segmentation reliability, and
  foundation-model sample-difficulty uncertainty.
- High-risk prior-work families identified:
  - brain tumor segmentation uncertainty,
  - segmentation quality prediction,
  - brain tumor segmentation QC,
  - voxel-level segmentation error-map prediction,
  - image-specific segmentation QC / difficulty estimation,
  - foundation medical segmentation uncertainty and reliability,
  - uncertainty-error alignment losses.

Remaining risk:
- Full review is still incomplete.
- Without strong comparison to uncertainty/QC/error-map baselines, G-SURE is a
  plausible direction, not a defensible method contribution.
- Lesion-size, predicted-volume, and image-difficulty proxy baselines are needed
  before claiming that a learned reliability model adds value.

## 13. Compute and Reproducibility

Question:
- Can experiments be rerun and interpreted?

Required evidence:
- frozen cohort manifest,
- frozen split manifest,
- config file,
- seed policy,
- checkpoint policy,
- logging path,
- GPU/runtime budget,
- failure criteria,
- code review record.

Current status:
- No training approved.
- GPU preview contract exists.
- Post-split validation runner exists and is preview-ready.
- Official split artifacts remain absent.

Remaining risk:
- Compute before evidence will create uninterpretable runs.

## Immediate Evidence Order

1. Keep pre-split readiness passing.
2. Obtain explicit approval for official LOCO split creation if Min accepts the
   subject-level cohort and split policy.
3. Write official split artifacts.
4. Run official split checker and consolidated post-split validation runner.
5. Prepare a reviewed GPU preview command for the first segmentation baseline.
6. Run GPU preview only after separate approval.
7. Generate OOF full-volume predictions only after baseline training is
   approved and validated.
8. Generate reliability/error labels only after OOF prediction metadata and
   artifact validators pass.
9. Verify literature novelty before claiming a method contribution.
