# Stage 53 - Approval Preflight Evidence Sync

## Task

Synchronize the official split approval packet and readiness checklist with the
current pre-split readiness command checks.

## Research Question

Does the approval-facing documentation describe the same preflight evidence that
`check_pre_split_readiness.py` actually runs?

## Why This Matters

Min's official split decision depends on the approval packet. If the packet
omits the document-invariant negative-control self-test, it understates the
current gate and weakens the evidence trail.

## What Changed

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` now lists the document invariant self-test
  as required preflight evidence.
- `EXPERIMENT_READINESS_CHECKLIST.md` now states that pre-split preflight checks
  document-invariant negative controls.
- `STAGE24_PRE_SPLIT_PREFLIGHT.md` now records that selected document invariants
  are negative-control tested, including G-SURE novelty/baseline guardrails.
- `check_pre_split_readiness.py` now has document invariants that protect the
  approval packet and readiness checklist descriptions of this stronger
  preflight scope.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This synchronizes documentation with existing CPU-only gate behavior.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py --document-invariant-self-test
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
rg -n "document invariant self-test: current gate/novelty/baseline invariant phrases|document-invariant negative controls|negative-control tested|STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC|Stage 30-53" research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md research_gsure/01_protocol/EXPERIMENT_READINESS_CHECKLIST.md research_gsure/02_audits/STAGE24_PRE_SPLIT_PREFLIGHT.md research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE53_APPROVAL_PREFLIGHT_EVIDENCE_SYNC.md research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

This keeps the approval-facing evidence current. It is not segmentation
performance evidence and not approval to create the official split.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
