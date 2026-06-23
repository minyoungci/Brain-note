# Pre-Approval Decision Brief

## Purpose

This brief is the short review surface before official LOCO split creation for
the G-SURE workspace.

It is not approval. It summarizes what Min is being asked to approve and what
remains explicitly unauthorized.

## Research Goal Reminder

G-SURE is a cross-consortium glioma MRI segmentation reliability and visual
grounding study. The first required model evidence is full-volume
out-of-fold segmentation prediction under leave-one-consortium-out shift.

The immediate decision is only the official split, not training.

## Decision Requested

Approve the first official split policy:

```text
primary cohort = subject_level_cohort_manifest_draft.csv
selection policy = one_unit_per_subject_earliest_numeric_order
target = binary selected_mask > 0
split policy = Leave-One-Consortium-Out
unit of split = dataset::subject_id
```

Exact approval phrase:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

## What Approval Creates

After approval, this command may be run:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write
```

Expected official split files:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
research_gsure/02_audits/outputs/loco_split_summary.csv
research_gsure/02_audits/outputs/loco_split_audit_report.md
```

## Current Evidence Snapshot

Current draft subject-level cohort:

| dataset | selected subjects |
|---|---:|
| MU-Glioma-Post | 203 |
| UCSD-PTGBM | 178 |
| UPENN-GBM | 611 |
| UTSW | 622 |
| total | 1,614 |

Current LOCO readiness:

| check | result |
|---|---|
| subject overlap | 0 |
| secondary-unit leakage | 0 |
| official split artifacts | absent |
| full pre-split readiness | PASS |

Current preflight requires:

- active-direction contamination self-test,
- subject-manifest semantic negative controls,
- document invariant negative controls,
- Stage audit coverage negative controls,
- output evidence coverage negative controls,
- split builder dry-run and write-safety self-test,
- official split absence check,
- post-split validation runner preview and self-test,
- prediction/reliability validator synthetic self-tests.

## Risks Accepted If Approved

- UCSD differs from the other datasets in shape/orientation.
- UCSD has lower lesion fraction and concentrated timing warnings.
- MU/UCSD timing warnings remain in the primary split.
- Timing-warning sensitivity is mandatory before final claims.
- The target is binary whole-lesion `selected_mask > 0`, not harmonized
  subregion segmentation.
- All-unit longitudinal analysis is a later sensitivity path, not the first
  official primary split.

## Still Not Authorized

Official split approval does not authorize:

- GPU training,
- long inference,
- preprocessing cache creation,
- checkpoint writing,
- OOF prediction generation,
- reliability label generation,
- G-SURE method training,
- performance, novelty, robustness, or publishability claims.

## Immediate Post-Approval Requirement

Immediately after split creation, run:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

No GPU command may be prepared until this post-split CPU validation passes.

## Source Documents

Detailed source documents:

```text
research_gsure/01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md
research_gsure/02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md
research_gsure/01_protocol/TIMING_WARNING_SENSITIVITY_CONTRACT.md
```
