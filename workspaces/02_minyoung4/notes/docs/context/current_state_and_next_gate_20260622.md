# Current State and Next Gate — 2026-06-22

## Current Authoritative State

- Workspace: `/home/vlm/minyoung4`.
- `EXP_flag/`, `experiments/`, `src/`, `configs/`, and `tests/` are absent in the current filesystem.
- `nvidia-smi -i 2,3,4` showed no running processes at 2026-06-22 02:01 UTC.
- Previous experiment paths referenced in older handoff notes are historical context only, not current-file-authoritative evidence.
- Active guardrail: `AGENTS.md` fresh-start policy.

## Why GPU Training Is Not Relaunched Yet

AGENTS.md requires that outcome, cohort, label, split, metric, preprocessing policy, and compute scope are explicitly defined before coding/training. It also requires Min approval before GPU training, long preprocessing, split generation, or full audits.

Therefore, no GPU job should be launched from the current workspace until the next protocol gate is approved.

## Recommended Next Gate

Use the EDA context to approve the first concrete protocol and the full NIfTI header audit.

### Gate A: Protocol Selection

Required decision:

- Task / research question
- Outcome label or unsupervised objective
- Input modalities
- Unit of analysis
- Cohort and filters
- Split policy
- Primary metrics
- Leakage controls
- Compute scope

Current EDA-supported candidates:

1. Structural MRI representation / segmentation-aware baseline
   - strongest data availability
   - no molecular label claim required
   - can support later downstream tasks
2. T1 structural IDH prediction
   - large cohort, but known dataset/age shortcut risk
   - must use LOCO and clinical/scanner baselines
3. MGMT prediction
   - smaller but more balanced than IDH
   - requires fresh ceiling probe if pursued

### Gate B: Full NIfTI Header Audit

Purpose:

- Validate shape, spacing, orientation, dtype, and header readability for all canonical NIfTI paths before preprocessing/training.

Command preview only; do not run without Min approval:

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
python docs/context/build_nifti_header_audit.py --mode full
```

Expected artifacts:

- `docs/context/nifti_header_audit_full.csv`
- `docs/context/nifti_header_audit_full_summary.md`
- updated zero-byte NIfTI evidence if encountered

## Explicit Non-Actions

Do not create `src/`, `configs/`, `experiments/`, or launch GPU training until protocol selection and audit scope are approved.
Do not treat missing `EXP_flag/*` experiment paths as active results.
Do not write/delete/move raw data.
