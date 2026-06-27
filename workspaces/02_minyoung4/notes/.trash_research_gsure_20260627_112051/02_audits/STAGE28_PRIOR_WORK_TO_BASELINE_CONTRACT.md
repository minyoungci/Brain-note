# Stage 28: Prior Work To Baseline Contract

## Task

Convert the initial G-SURE literature scout into baseline requirements.

## Research Question

What must G-SURE compare against before claiming a method contribution in
segmentation reliability/error localization?

## Sources Inspected

- QCResUNet MICCAI 2023 page and arXiv/PubMed records.
- BraTS 2020 Task 3 uncertainty evaluation page.
- QU-BraTS article/abstract and MIDL uncertainty metric page.
- DeVries and Taylor arXiv page.
- Current G-SURE protocol and baseline documents.

## Key Finding

G-SURE cannot treat uncertainty maps, subject-level segmentation QC, or
voxel-level error-map prediction as novel by themselves.

QCResUNet is the direct prior-work threat because it predicts:

- subject-level segmentation quality,
- voxel-level segmentation error maps,
- for brain tumor segmentation QC.

QU-BraTS/BraTS uncertainty work means uncertainty maps need quantitative
uncertainty-error evaluation, not just visualization.

DeVries-style quality prediction means subject-level failure detection is a
baseline, not a contribution.

## Actions Taken

Added:

```text
research_gsure/00_context/20260623_gsure_prior_work_matrix.md
research_gsure/03_baselines/UNCERTAINTY_QC_BASELINE_REQUIREMENTS.md
```

Updated:

```text
research_gsure/00_context/20260623_gsure_literature_scout.md
research_gsure/03_baselines/BASELINE_CONTRACT.md
research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md
research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md
```

## Experimental Implication

Before G-SURE method work:

1. B1 full-volume OOF segmentation predictions must exist.
2. Prediction artifacts must pass metadata and NIfTI validators.
3. Error/reliability labels must be generated only from eligible OOF predictions.
4. Probability-derived uncertainty, TTA uncertainty, ensemble disagreement,
   DeVries-style QC, and QCResUNet-style error-map baselines must be evaluated
   or explicitly scoped as infeasible with a documented reason.
5. Method work proceeds only if a baseline gap remains under LOCO evaluation.

## Leakage Implication

QC/error-map baselines require leakage-safe training labels:

- outer held-out consortium rows are evaluation only,
- train-row QC labels must come from train-consortia inner-OOF predictions or an
  approved train-only protocol,
- in-sample segmentation predictions are diagnostic only,
- patch-only predictions are ineligible.

## Validation Required

Run:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "UNCERTAINTY_QC_BASELINE_REQUIREMENTS|prior_work_matrix|QCResUNet|DeVries|QU-BraTS" research_gsure
git diff --check
```

## Remaining Risk

This is not a complete related-work section. 2024-2026 segmentation reliability
and foundation-segmentation uncertainty papers still need a deeper review before
method lock.
