# Stage 51 - Context Semantic Invariants

## Task

Protect the G-SURE novelty and baseline guardrails with selected preflight
document invariants.

## Research Question

Can core reviewer-defense language disappear from the context and baseline
documents while the pre-split readiness check still passes?

## Why This Matters

File-presence coverage is not enough for the research goal. G-SURE must remain
framed as a LOCO full-volume glioma segmentation reliability/error-localization
study, not a generic uncertainty, quality-control, or foundation-model
segmentation claim.

## What Changed

`check_pre_split_readiness.py` now checks that:

- the literature scout records the targeted 2024-2026 update as non-exhaustive,
- the literature scout blocks unsupported "first", "novel", "SOTA", "robust",
  and "clinically useful" claims,
- the prior-work matrix keeps QCResUNet as a 2025 Medical Image Analysis /
  PubMed direct novelty threat,
- the readiness checklist requires lesion-size, predicted-volume, and
  image-difficulty proxy baselines,
- the baseline contract keeps ground-truth lesion size as oracle diagnostic only,
- the uncertainty/QC baseline sequence computes predicted-volume, morphology,
  and image-difficulty proxy controls before method comparison.

`STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 30-51 coverage,
and `STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md` records the broader invariant
scope.

## Guardrails

- This does not make the literature review systematic.
- This does not claim novelty.
- This does not create official split artifacts.
- This does not run GPU work, inference, preprocessing, reliability label
  generation, or model training.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "TARGETED 2024-2026|QCResUNet has a 2025 Medical Image Analysis|Lesion-size, predicted-volume, and image-difficulty proxy baselines|oracle diagnostic only|Compute B0 predicted-volume|STAGE51_CONTEXT_SEMANTIC_INVARIANTS|Stage 30-51" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md research_gsure/02_audits/STAGE51_CONTEXT_SEMANTIC_INVARIANTS.md research_gsure/00_context research_gsure/01_protocol research_gsure/03_baselines
```

## Interpretation

This is gate hardening. It protects the research framing against accidental
regression but does not provide segmentation or reliability performance
evidence.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
