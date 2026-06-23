# Stage 13 Split Builder Overwrite Guard

## Scope

Strengthen official split artifact safety before any official split is created.
This stage did not run `--write` and did not create official split files.

## Goal Reminder

G-SURE depends on reproducible out-of-fold segmentation predictions. Those
predictions depend on a stable official split. Silent overwrite of split
artifacts would invalidate downstream comparison and reliability labels.

## Change

`build_loco_split_manifest.py` now refuses to overwrite existing official split
outputs unless `--force` is passed:

```text
loco_split_manifest.csv
loco_split_summary.csv
loco_split_audit_report.md
```

`--force` is not part of the normal approval path and requires a separate
explicit overwrite approval.

## Validation

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/build_loco_split_manifest.py
```

Dry-run:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py
```

Observed dry-run result:

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
Dry run only. Re-run with --write after approval to create official split outputs.
```

Official split manifest check:

```text
official_split_manifest=absent
```

Helper-level existing-output detection was checked without writing official
split files:

```text
existing_count 1
existing_paths ['AGENTS.md']
```

## Guardrail

The full overwrite refusal path requires existing official split files and
`--write`; it should be exercised only after the official split exists or in a
separate non-official test directory. Do not create official split outputs just
to test overwrite behavior.
