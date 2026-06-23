# Stage 33 - Pre-Split Gate Audit

## Task

Re-audit the current G-SURE state immediately before the official LOCO split
approval gate.

## Research Goal Reminder

G-SURE is a glioma MRI segmentation reliability and visual-grounding study. The
first experiment requires full-volume out-of-fold segmentation predictions, but
the immediate gate is still the official subject-level LOCO split.

## Current Gate Status

Official LOCO split artifacts are absent.

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv    absent
research_gsure/02_audits/outputs/loco_split_summary.csv     absent
research_gsure/02_audits/outputs/loco_split_audit_report.md absent
```

The split builder was run in dry-run mode only.

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
Dry run only. Re-run with --write after approval to create official split outputs.
```

## Pre-Split Readiness Result

The consolidated pre-split readiness check passed.

```text
Pre-split readiness: PASS
Official split artifacts: absent
Draft subject cohort rows: 1614
Required next gate: explicit official LOCO split approval
```

Included checks:

- official split builder dry-run,
- official split artifacts absent check,
- post-split validation runner preview,
- OOF prediction manifest validator synthetic self-test,
- inner-OOF prediction manifest validator synthetic self-test,
- prediction artifact validator synthetic self-test,
- reliability label generator synthetic self-test,
- reliability label validator synthetic self-test,
- reliability metric harness synthetic self-test.

## Post-Approval Preview

The post-split validation runner was previewed only. It did not create official
split artifacts and did not run GPU work.

The planned post-approval validation sequence is:

1. official split artifact checker,
2. bounded post-split loader smoke,
3. split-aware tile budget,
4. split-aware tile-grid dry-run with coverage-hole failure enabled.

## Still Forbidden Without Explicit Approval

- `build_loco_split_manifest.py --write`,
- GPU training,
- long inference,
- preprocessing cache creation,
- checkpoint writing,
- real OOF prediction generation,
- real reliability label generation,
- real reliability metric reporting,
- G-SURE method claims.

## Required Approval Wording

To cross the official split gate, Min must explicitly say:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

## Interpretation

The workspace is ready to request official split approval. It is not yet ready
for GPU training or performance claims.
