# Stage 39 - Approval Decision Invariants

## Task

Strengthen the pre-split readiness check so the official split approval packet
cannot silently drift away from the intended G-SURE split decision.

## Research Question

Could the approval packet still exist and contain the exact approval sentence,
while the cohort, target, split policy, or split unit being approved has changed?

## Why This Matters

The next action after pre-split readiness is approval-gated official LOCO split
creation. If the approval packet changes the decision tuple, Min could approve a
different task than the one validated by the current audits.

## What Changed

`check_pre_split_readiness.py` now verifies that
`OFFICIAL_SPLIT_APPROVAL_PACKET.md` still contains:

- `primary cohort = subject_level_cohort_manifest_draft.csv`
- `selection policy = one_unit_per_subject_earliest_numeric_order`
- `target = binary selected_mask > 0`
- `split policy = Leave-One-Consortium-Out`
- `unit of split = dataset::subject_id`
- `Approval does not authorize:`
- `- GPU training,`
- `- reliability label generation,`

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.
- These checks are string invariants, not a full semantic proof of the document.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

The approval packet now has machine-checked guardrails for the decision Min is
being asked to approve. This supports the official split gate; it does not
authorize the split, GPU training, or any downstream experiment.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
