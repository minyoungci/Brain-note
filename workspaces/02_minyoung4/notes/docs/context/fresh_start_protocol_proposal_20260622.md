# Fresh-Start Modeling Protocol Proposal — 2026-06-22

This is an approval document only. It does not create splits, preprocessing outputs,
training code, checkpoints, or GPU jobs.

## Current Constraint

`AGENTS.md` states that this workspace is a fresh restart. Prior `EXP_flag`/`experiments`
paths are absent and must not be used as current evidence. Before coding or training, the
following must be locked: task, outcome, input/exposure, unit of analysis, cohort/filters,
split policy, leakage risks, files to change, expected artifacts, validation, assumptions,
and Min approval.

## Recommended First Protocol

### Task

Structural MRI representation / segmentation-aware baseline as the first fresh-start
engineering track.

### Research Question

Can a lesion-aware structural MRI representation improve cross-consortium whole-tumor
segmentation or serve as a robust foundation for later molecular prediction under LOCO
stress testing?

### Why This First

- It has the strongest data availability: structural MRI is available for 1,636/1,636
  subjects.
- Structural+segmentation coverage is near-complete and does not require accepting a
  fragile molecular performance claim first.
- Prior context marks IDH and MGMT molecular performance-improvement claims as high-risk
  or previously negative unless reproduced under a fresh approved ceiling protocol.
- A segmentation/representation track can support a conference method story without
  relying on IDH age/site shortcuts.

### Outcome

Primary, if segmentation track is approved:

- Whole-tumor segmentation Dice under leave-one-consortium-out evaluation.

Alternative, if representation-only pretraining is preferred:

- No supervised outcome for pretraining; downstream protocol must be separately approved.

### Input / Exposure

- 4-channel structural MRI core where available: T1, T1ce/T1post, T2, FLAIR.
- Tumor segmentation is allowed only if the approved task is segmentation or
  train-time lesion-aware representation.

### Unit of Analysis

- Subject-level for reporting.
- NIfTI unit may be used internally, but all units from the same `dataset::subject_id`
  must remain in the same train/val/test split.

### Cohort / Filters

Candidate starting cohort:

- `eligible_T0_structural_common`: 1,636 subjects for representation/preprocessing QA.
- `eligible_T1b_structural_segmentation_idh` or structural+segmentation baseline rows
  only if the segmentation-aware task is approved.

Known filters / quality gates:

- Exclude or repair the known UCSD zero-byte segmentation before segmentation-aware work.
- Resolve UPENN duplicate old/non-old structural path preference before preprocessing.
- Full NIfTI header audit must pass before image preprocessing.

### Split Policy

- Leave-one-consortium-out for primary evaluation.
- `leakage_group_id = dataset::subject_id`.
- No unit-level random split.
- Validation split must be drawn only from training consortia for each LOCO fold.
- Report dataset, scanner vendor, field strength, age bin, sex, and target/lesion-size
  distributions when applicable.

### Leakage Risks

- Multi-unit subject leakage in MU, UCSD, and UPENN.
- Dataset/scanner shortcut under molecular labels.
- Test-label use for threshold/routing/checkpoint decisions.
- Segmentation provenance and zero-byte segmentation artifacts.
- Preprocessing normalization using test-consortium statistics.

### Files To Change After Approval

Do not create these until approval. Proposed structure:

- `src/data/manifest.py`
- `src/data/header_audit.py` only if reused beyond docs/context audit
- `src/splits/make_loco_splits.py`
- `src/preprocess/structural_mri.py`
- `src/models/unet3d.py` or method-specific model file
- `src/train_segmentation.py`
- `configs/segmentation_loco/*.yaml`
- `experiments/<approved_exp_name>/`

### Expected Artifacts

Before training:

- `docs/context/nifti_header_audit_full.csv`
- `docs/context/nifti_header_audit_full_summary.md`
- approved preprocessing policy
- approved split manifest

During/after training:

- nohup logs with PID files
- fold-level checkpoints under approved experiment directory
- validation-only threshold/checkpoint selection
- test summaries per held-out consortium
- final report with paired bootstrap confidence intervals

### Validation

Pre-training validation:

- full NIfTI header audit
- zero-byte and missing path audit
- affine/orientation/spacing policy
- subject-level split isolation check
- small CPU smoke on real paths
- `py_compile` and shell syntax checks

Training validation:

- `nvidia-smi` preflight
- nohup/setsid process PPID/SID check
- stderr byte checks
- fold monitor script
- checkpoint/test-summary existence checks

### Unclear Assumptions

- Whether Min wants segmentation/representation as the first fresh-start track or a
  molecular ceiling probe first.
- Whether the known UCSD zero-byte segmentation should be repaired or excluded.
- UPENN old/non-old structural path preference.
- Exact target spacing/shape and interpolation policy, pending full header audit.

### Needs Min Approval

1. Approve this first task direction or choose another.
2. Approve full NIfTI header audit.
3. Decide UCSD zero-byte segmentation repair vs exclusion.
4. Decide UPENN duplicate structural path preference.
5. Approve preprocessing policy after audit.
6. Approve split generation and GPU training command preview.

## Immediate Command Preview After Approval

Preflight:

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

Full NIfTI header audit:

```bash
python docs/context/build_nifti_header_audit.py --mode full
```

No GPU training command should be previewed until the audit and protocol decisions above
are complete.
