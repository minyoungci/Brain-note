# Stage 54 - Stage Audit Trail Coverage

## Task

Ensure that every existing `STAGE*.md` audit note is protected by the pre-split
readiness required-file gate.

## Research Question

Can a Stage audit note disappear from `REQUIRED_FILES` while the pre-split
readiness check still passes?

## Why This Matters

The G-SURE workspace uses Stage notes as the decision trail for dataset audits,
split gating, loader policy, baseline requirements, prediction validators,
literature-risk hardening, and approval evidence. If early or middle Stage notes
are outside the preflight coverage, the research history can drift without the
gate noticing.

## What Changed

- Added the previously uncovered Stage notes to `REQUIRED_FILES`, including
  Stage 2-22 and Stage 26-29.
- Added `check_stage_audit_coverage()` to
  `check_pre_split_readiness.py`.
- The preflight now scans existing `research_gsure/02_audits/STAGE*.md` files
  and fails if any are absent from `REQUIRED_FILES`.
- `STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md` now records Stage 2-54
  required-file coverage.

## Guardrails

- This does not create official split artifacts.
- This does not run GPU work.
- This does not run inference, preprocessing, training, or reliability label
  generation.
- This checks audit-trail coverage only; it does not make every Stage note
  semantically complete.

## Validation

Required validation:

```bash
python -m py_compile research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
python - <<'PY'
from pathlib import Path
script = Path('research_gsure/02_audits/scripts/check_pre_split_readiness.py').read_text()
stages = sorted(Path('research_gsure/02_audits').glob('STAGE*.md'))
missing = [str(p) for p in stages if str(p) not in script]
print(f'total_stage_files={len(stages)}')
print(f'missing_stage_files={len(missing)}')
if missing:
    raise SystemExit('\\n'.join(missing))
PY
rg -n "check_stage_audit_coverage|STAGE54_STAGE_AUDIT_TRAIL_COVERAGE|Stage 2-54|missing_stage_files=0" research_gsure/02_audits/scripts/check_pre_split_readiness.py research_gsure/02_audits/STAGE35_PREFLIGHT_REQUIRED_FILES_HARDENING.md research_gsure/02_audits/STAGE54_STAGE_AUDIT_TRAIL_COVERAGE.md
```

## Interpretation

This is audit-trail integrity hardening. It is not segmentation performance,
reliability performance, or novelty evidence.

## Remaining Gate

Official LOCO split creation still requires exact approval:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```
