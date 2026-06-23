# Official Split Approval Packet

## Purpose

This packet summarizes the exact decision Min must approve before the G-SURE
workspace creates the official LOCO split artifacts.

This document is not approval by itself. It is a review packet.

## Research Goal Reminder

G-SURE is a cross-consortium glioma MRI segmentation reliability/grounding study.
The first baseline must produce full-volume out-of-fold segmentation predictions.
Therefore, the primary split must test consortium shift and must isolate subjects.

## Decision Requested

Approve the following as the first official experiment split:

```text
primary cohort = subject_level_cohort_manifest_draft.csv
selection policy = one_unit_per_subject_earliest_numeric_order
target = binary selected_mask > 0
split policy = Leave-One-Consortium-Out
unit of split = dataset::subject_id
```

## What Approval Will Create

If approved, this command will be run:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write
```

The split builder refuses to overwrite existing official split files unless
`--force` is passed. `--force` is not part of this approval.

Expected output files:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
research_gsure/02_audits/outputs/loco_split_summary.csv
research_gsure/02_audits/outputs/loco_split_audit_report.md
```

No raw data, preprocessed arrays, checkpoints, cached tensors, or GPU jobs will
be created by this command.

## Current Evidence

Subject-level cohort draft:

| dataset | selected subjects |
|---|---:|
| MU-Glioma-Post | 203 |
| UCSD-PTGBM | 178 |
| UPENN-GBM | 611 |
| UTSW | 622 |
| total | 1,614 |

LOCO readiness and lesion-burden audit:

| heldout | test subjects | train subjects | subject overlap | secondary leak | timing warnings test/train | median lesion fraction test/train |
|---|---:|---:|---:|---:|---|---:|
| MU-Glioma-Post | 203 | 1,411 | 0 | 0 | 12/63 | 0.0076631944 / 0.0073662634 |
| UCSD-PTGBM | 178 | 1,436 | 0 | 0 | 63/12 | 0.0037783086 / 0.00816929885 |
| UPENN-GBM | 611 | 1,003 | 0 | 0 | 0/75 | 0.008578069 / 0.0063692876 |
| UTSW | 622 | 992 | 0 | 0 | 0/75 | 0.00783551745 / 0.00706810035 |

Dry-run split builder evidence:

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
Dry run only. Re-run with --write after approval to create official split outputs.
```

Pre-split readiness also runs:

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
```

That preflight must pass before this approval is acted on. It checks the draft
cohort, the absence of official split artifacts, document invariants, and the
current CPU-only validator self-tests.

Required preflight evidence includes:

- direction contamination self-test: active G-SURE direction documents are clean
  and 3 injected stale-direction terms are rejected,
- subject manifest semantic self-test: baseline validation and 8 negative
  controls pass,
- document invariant self-test: current gate/novelty/baseline invariant phrases
  pass and missing-text negative controls are rejected,
- Stage audit coverage self-test: all current Stage audit notes are covered and
  a removed-stage negative control is rejected,
- output evidence coverage self-test: all current pre-split output artifacts
  are covered and a removed-output negative control is rejected,
- official split builder dry-run passes without writing files,
- official split builder write-safety self-test passes, refusing invalid split
  writes after validation errors,
- official split artifacts absent check passes,
- official split checker dry-run self-test passes,
- tile-audit overwrite-safety self-tests pass, refusing existing-output
  collisions unless overwrite is explicit,
- post-split validation runner preview succeeds,
- post-split validation runner dry-run self-test passes,
- OOF, inner-OOF, prediction artifact, reliability label, and reliability metric
  synthetic self-tests pass.

The official split checker self-test may also be run directly:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --dry-run-self-test
```

That split-checker self-test builds split rows and summaries in memory, validates
lesion-burden summary fields, and confirms a corrupted lesion-burden summary is
rejected. It writes no official split artifacts.

## Known Risks To Accept

- UCSD differs in geometry/orientation (`256x256x256 / ILA`) from the other
  datasets (`240x240x155 / LPS`).
- UCSD has lower median lesion fraction than the other datasets
  (`0.0037783086` in UCSD-heldout test rows versus `0.00816929885` in the
  corresponding train rows).
- UCSD has concentrated timing warnings.
- MU/UCSD timing warnings are disclosure and stratification risks unless Min
  decides they should become exclusion criteria.
- Timing-warning recommendation before approval: keep all 1,614 rows in the
  primary split, disclose MU/UCSD timing warnings, and require sensitivity
  analysis excluding timing-warning rows before any final claim.
- The target is binary whole-lesion candidate (`selected_mask > 0`), not
  harmonized subregion segmentation.
- The split is subject-level, one selected unit per subject; all-unit
  longitudinal sensitivity analysis remains separate.

## What Approval Does Not Mean

Approval does not authorize:

- GPU training,
- long inference,
- preprocessing cache creation,
- checkpoint writing,
- reliability label generation,
- G-SURE method training,
- claims about performance, novelty, robustness, or publishability.

## Required Immediate Validation After Approval

After writing the official split, run the consolidated post-split validation
runner:

```bash
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

This runner executes:

1. official split artifact checker,
2. bounded post-split loader smoke for all held-out consortia,
3. split-aware tile-budget audit,
4. split-aware tile-grid dry-run with coverage-hole failure enabled.

The loader smoke step is run for all held-out consortia:

```text
MU-Glioma-Post
UCSD-PTGBM
UPENN-GBM
UTSW
```

The per-fold command pattern is:

```bash
python research_gsure/02_audits/scripts/smoke_load_manifest_sample.py \
  --manifest research_gsure/02_audits/outputs/loco_split_manifest.csv \
  --heldout-dataset <HELDOUT_DATASET> \
  --split-role test \
  --max-rows 8
```

The validation sequence must confirm:

- official split files exist and have expected fold counts,
- subject overlap is 0,
- duplicate train/test subjects are 0,
- required path fields are present,
- lesion-burden summary fields exist and match the split manifest,
- selected 4-channel MRI paths load,
- selected mask paths load,
- channel and mask shapes match for sampled rows,
- channel and mask affines match for sampled rows,
- channel and mask orientations match for sampled rows,
- channel and mask voxel spacings match for sampled rows,
- loaded arrays contain only finite values,
- binary target is non-empty,
- candidate full-volume tile grids cover all official held-out test rows,
- no preprocessed arrays are written.

## Approval Wording

To approve, Min should explicitly say:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

Without that explicit approval, `--write` must not be run.
