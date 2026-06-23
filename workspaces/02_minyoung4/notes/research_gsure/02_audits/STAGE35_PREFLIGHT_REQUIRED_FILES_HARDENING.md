# Stage 35 - Preflight Required Files Hardening

## Task

Strengthen the pre-split readiness preflight so it monitors the current core
G-SURE protocol, baseline, reliability, QC, and approval-gate documents.

## Research Question

Can the workspace lose a critical pre-GPU contract document without the
pre-split readiness check noticing?

## What Changed

- Added core direction files to the preflight required-file list.
- Added context evidence files, including data premise, literature scout, and
  prior-work matrix, to the required-file list.
- Added split, target, subject-unit, loader, OOF prediction, reliability-label,
  reliability-metric, inner-OOF, baseline, uncertainty/QC, and B1 GPU preview
  documents to the required-file list.
- Added current pre-split audit output artifacts to the required-file list so
  the evidence behind the protocol and Stage notes cannot disappear silently.
- Added Stage 2-65 audit notes to the required-file list so the current
  audit trail cannot disappear silently.
- Added dynamic Stage audit coverage checking so any existing `STAGE*.md` file
  missing from `REQUIRED_FILES` fails preflight.
- Added a Stage audit coverage self-test so missing Stage required-file entries
  are negative-control tested.
- Added an output evidence coverage self-test so missing pre-split output
  required-file entries are negative-control tested.
- Updated the Stage 24 preflight note to match the current command checks.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, labels, metrics, or checkpoints.

## Current Status

The preflight remains a pre-approval CPU-only readiness check. The next gate is
still explicit approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
