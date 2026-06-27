# Stage 52 - Document Invariant Self-Test

## Task

Add a negative-control self-test for selected document invariant enforcement.

## Research Question

Can the pre-split readiness gate prove that it rejects missing gate, novelty, and
baseline guardrail phrases rather than only checking the current files once?

## Why This Matters

Stage 51 added semantic invariants for G-SURE framing, but a guardrail without a
negative-control self-test can silently weaken. The readiness gate should verify
that removing an invariant phrase is detected.

## What Changed

`check_pre_split_readiness.py` now has:

```bash
--document-invariant-self-test
```

The self-test:

- validates that current documents satisfy all selected invariants,
- verifies that a missing required invariant document is rejected,
- removes each required invariant phrase in-memory and verifies that the
  corresponding invariant fails,
- runs as part of the full pre-split readiness command checks.

## Guardrails

- The self-test is in-memory except for reading existing required documents.
- It does not edit documents.
- It does not create official split artifacts.
- It does not run GPU, inference, preprocessing, training, or reliability label
  generation.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "document invariant self-test|--document-invariant-self-test|Missing-text negative controls rejected|STAGE52_DOCUMENT_INVARIANT_SELF_TEST|Stage 30-52" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE36_PREFLIGHT_DOCUMENT_INVARIANTS.md research_gsure/02_audits/STAGE52_DOCUMENT_INVARIANT_SELF_TEST.md
```

Expected self-test output includes:

```text
Document invariant self-test: PASS
Baseline document invariants: PASS
Missing-text negative controls rejected:
```

## Interpretation

This improves preflight correctness. It is not evidence of segmentation
performance, reliability performance, novelty, or publishability.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
