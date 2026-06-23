# Stage 27: Pre-Approval State Audit

## Task

Re-check the current G-SURE preparation state before official LOCO split
approval.

## Research Question

Is the workspace internally consistent with the current G-SURE objective before
crossing the official split gate?

## Current Research Goal

G-SURE is a glioma MRI segmentation reliability/grounding study. The first
technical target is not Dice-only segmentation. The required evidence chain is:

```text
official split
-> full-volume OOF segmentation predictions
-> validated prediction artifacts
-> reliability/error labels
-> reliability and grounding evaluation
-> only then G-SURE method work
```

## What Was Inspected

- `research_gsure/README.md`
- `research_gsure/ROADMAP.md`
- `research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md`
- `research_gsure/01_protocol/GSURE_PROTOCOL_DRAFT.md`
- `research_gsure/01_protocol/PRE_EXPERIMENT_EVIDENCE_MAP.md`
- `research_gsure/02_audits/README.md`
- `research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md`
- `SCRATCHPAD.md`

## Findings

The core direction is consistent:

- primary task is segmentation plus reliability/grounding,
- primary target remains binary `selected_mask > 0`,
- primary cohort remains the draft 1,614-subject selected-unit cohort,
- official split remains absent,
- next gate remains explicit official LOCO split approval,
- GPU, inference, prediction generation, and reliability label generation remain
  blocked.

One stale-document issue was found:

- `PRE_EXPERIMENT_EVIDENCE_MAP.md` still described several completed audits as
  not yet verified.

One stale-gate issue was found:

- `OFFICIAL_SPLIT_APPROVAL_PACKET.md` described only loader smoke as the
  immediate post-approval validation, not the newer consolidated post-split
  validation runner.

## Actions Taken

- Updated `PRE_EXPERIMENT_EVIDENCE_MAP.md` to reflect current evidence.
- Updated `OFFICIAL_SPLIT_APPROVAL_PACKET.md` to require the post-split
  validation runner after split creation.
- Updated `README.md`, `ROADMAP.md`, and `02_audits/README.md` so the immediate
  gate is consistent across entry-point documents.

## Current Gate

Official split creation is still not approved. The exact approval wording
remains:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

## Validation Required

After these documentation updates, run:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/run_post_split_validation.py --preview
python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing
```

## Interpretation

This audit improves consistency before the split gate. It does not validate
segmentation performance, GPU feasibility, reliability labels, novelty, or
publication readiness.
