# Stage 25 Official Split Artifact Checker

## Scope

Add a CPU-only checker for official LOCO split artifacts. This stage did not
create official split files, run GPU, preprocess data, run inference, generate
predictions, or generate reliability labels.

## Goal Reminder

G-SURE depends on a stable official split. If split artifacts are missing,
overwritten, malformed, or contain subject leakage, every downstream OOF
prediction and reliability label becomes invalid.

## Added Script

```text
research_gsure/02_audits/scripts/check_official_split_artifacts.py
```

## Modes

Pre-approval mode:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --expect-missing
```

This passes only when official split artifacts are absent.

Pre-approval dry-run self-test:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --dry-run-self-test
```

This builds the split rows and summary in memory only, validates the checker
against those rows, and runs a negative control that intentionally corrupts a
lesion-burden summary field.

Post-approval mode:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py
```

This validates:

- `loco_split_manifest.csv` exists,
- `loco_split_summary.csv` exists,
- `loco_split_audit_report.md` exists,
- manifest has 6,456 rows,
- summary has 4 fold rows,
- fold train/test counts match the 1,614-subject cohort,
- held-out test rows belong to the held-out dataset,
- train rows exclude the held-out dataset,
- train/test subject overlap is 0,
- duplicate train/test subject count is 0,
- missing path rows are 0,
- lesion-burden summary fields exist,
- lesion-burden summary values match the split manifest.

## Validation Performed

Compile:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_official_split_artifacts.py
```

Pre-approval current-state check:

```bash
python research_gsure/02_audits/scripts/check_official_split_artifacts.py \
  --expect-missing
```

Observed:

```text
Official split artifact check: PASS
Official split artifacts are absent as expected.
```

## Guardrails

- The checker never creates split files.
- `--expect-missing` is for pre-approval only.
- `--dry-run-self-test` is for pre-approval checker logic validation and writes
  no official artifacts.
- Default mode is for after approved split creation.
- PASS is not GPU approval.

## Next Action

After explicit official split approval:

1. run pre-split preflight,
2. create official split with `build_loco_split_manifest.py --write`,
3. run this checker in default mode,
4. continue to post-split loader smoke only if the checker passes.
