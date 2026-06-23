# Stage 50 - Context Evidence Preflight Coverage

## Task

Ensure that the G-SURE pre-split readiness gate monitors the context evidence
that defines the research premise and novelty/baseline risks.

## Research Question

Can the workspace lose the data premise, literature scout, or prior-work matrix
without the pre-split readiness check noticing?

## Why This Matters

The G-SURE direction depends on two kinds of evidence before any GPU work:

- data evidence: the workspace has multi-consortium glioma MRI and segmentation
  masks suitable for a subject-level segmentation reliability study,
- novelty/baseline evidence: G-SURE must beat uncertainty, segmentation QC,
  QCResUNet-style, and simple proxy baselines before method claims.

If these context files disappear, the gate could still pass while the research
direction loses its reviewer-facing defense.

## What Changed

`check_pre_split_readiness.py` now requires:

```text
research_gsure/00_context/DATA_PREMISE.md
research_gsure/00_context/20260623_gsure_literature_scout.md
research_gsure/00_context/20260623_gsure_prior_work_matrix.md
research_gsure/02_audits/STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE.md
```

`STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` was updated to record that
context evidence and Stage 30-50 audit notes are part of required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, training, preprocessing, or reliability label
  generation.
- This checks file presence only; it does not make the literature review
  systematic or complete.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "00_context/DATA_PREMISE|20260623_gsure_literature_scout|20260623_gsure_prior_work_matrix|STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE|Stage 30-50" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE50_CONTEXT_EVIDENCE_PREFLIGHT_COVERAGE.md
```

## Interpretation

This improves gate integrity for the research context. It is not segmentation
performance evidence and not a novelty claim.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
