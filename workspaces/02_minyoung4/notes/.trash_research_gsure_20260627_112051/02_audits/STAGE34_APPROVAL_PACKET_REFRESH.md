# Stage 34 - Approval Packet Refresh

## Task

Refresh the official LOCO split approval materials after adding lesion-burden
split-summary validation.

## Research Question

Can Min review the official split approval gate with the current evidence,
including lesion-burden imbalance and the split checker dry-run self-test?

## What Changed

- Updated `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`.
- Updated `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`.

## Evidence Added To Approval Packet

- Fold-level median lesion fraction for test/train rows.
- Explicit mention of the official split checker dry-run self-test.
- UCSD lesion-burden risk with numeric median lesion fraction.
- Post-approval validation requirement that lesion-burden summary fields match
  the split manifest.

## Current Status

No official split files were created. The next gate remains explicit approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
