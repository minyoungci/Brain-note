# Stage 7 Split and Loader Preparation

## Scope

Prepare tools for the next approved steps without creating official split files
or loading training data at scale.

## Prepared Tools

### LOCO split builder

```text
scripts/build_loco_split_manifest.py
```

Default mode is dry-run. It writes official split outputs only with:

```text
--write
```

Expected official outputs after approval:

- `outputs/loco_split_manifest.csv`
- `outputs/loco_split_summary.csv`
- `outputs/loco_split_audit_report.md`

### Loader smoke script

```text
scripts/smoke_load_manifest_sample.py
```

This is for post-split CPU smoke testing only.

## Next Approval Gate

Run this only after Min approves official split creation:

```bash
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write
```

Then run the loader smoke command documented in:

```text
01_protocol/POST_SPLIT_LOADER_SMOKE_CONTRACT.md
```

Approval packet:

```text
01_protocol/OFFICIAL_SPLIT_APPROVAL_PACKET.md
```

Post-approval runbook:

```text
02_audits/POST_APPROVAL_SPLIT_RUNBOOK.md
```
