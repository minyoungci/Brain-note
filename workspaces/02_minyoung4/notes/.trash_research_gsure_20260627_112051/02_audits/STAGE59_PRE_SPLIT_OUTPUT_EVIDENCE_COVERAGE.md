# Stage 59 - Pre-Split Output Evidence Coverage

## Task

Protect the current pre-split audit output artifacts with the readiness
required-file gate.

## Research Question

Can the workspace lose a mask/path/geometry/cohort/tile audit output while the
pre-split readiness check still passes?

## Why This Matters

The G-SURE decision trail depends on both Stage documents and the CSV/MD output
artifacts those documents summarize. If the output artifacts disappear, the
research claims become harder to audit even if the prose remains.

## What Changed

`check_pre_split_readiness.py` now requires the current pre-split audit outputs,
including:

- mask path inventory and summaries,
- mask value/geometry audit outputs,
- target mapping policy review outputs,
- candidate and subject-level cohort outputs,
- unit selection review,
- LOCO readiness outputs,
- loader transform feasibility outputs,
- sliding-window coverage outputs,
- tile-budget and tile-grid dry-run outputs,
- patch memory proxy outputs.

Official split outputs remain forbidden before approval and are not added to
`REQUIRED_FILES`.

`STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records that pre-split audit
output artifacts are part of required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This protects existing pre-split evidence artifacts only.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
python - <<'PY'
from pathlib import Path
script = Path('research_gsure/02_audits/scripts/check_pre_split_readiness.py').read_text()
outputs = sorted(Path('research_gsure/02_audits/outputs').glob('*'))
files = [p for p in outputs if p.is_file()]
missing = [str(p) for p in files if str(p) not in script]
print(f'total_output_files={len(files)}')
print(f'missing_output_files={len(missing)}')
if missing:
    raise SystemExit('\\n'.join(missing))
PY
rg -n "candidate_cohort_manifest_draft|mask_path_inventory|mask_value_geometry_audit|sliding_window_tile_budget_subject_level|STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE|pre-split audit output artifacts" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE59_PRE_SPLIT_OUTPUT_EVIDENCE_COVERAGE.md
```

## Interpretation

This is evidence-artifact integrity hardening. It does not prove segmentation
performance, reliability performance, or novelty.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
