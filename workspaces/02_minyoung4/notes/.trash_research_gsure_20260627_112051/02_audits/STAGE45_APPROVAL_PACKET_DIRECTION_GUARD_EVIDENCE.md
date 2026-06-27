# Stage 45 - Approval Packet Direction Guard Evidence

## Task

Synchronize the official split approval packet with the latest direction
contamination guard.

## Research Question

Could Min review an approval packet that lists older preflight evidence but omits
the newer active-direction contamination self-test?

## Why This Matters

The split approval packet should reflect the full current pre-split gate. After
the direction guard was added, the packet needed to state that active G-SURE
documents are checked against stale IDH/VLM/exp-style contamination before
official split creation.

## What Changed

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` now lists:

```text
direction contamination self-test: active G-SURE direction documents are clean
and 3 injected stale-direction terms are rejected
```

- `check_pre_split_readiness.py` now guards that approval-packet phrase as a
  document invariant.

## Guardrails

- This does not approve official split creation.
- This does not create official split artifacts.
- This does not run GPU work.
- This does not generate predictions, reliability labels, metrics, checkpoints,
  or preprocessing arrays.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

## Interpretation

The approval packet now matches the current preflight evidence chain. This is
approval-context hygiene, not segmentation performance evidence.

## Remaining Gate

Official LOCO split creation still requires explicit Min approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
