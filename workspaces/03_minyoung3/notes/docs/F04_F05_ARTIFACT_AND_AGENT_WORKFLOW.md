# F04/F05 Artifact Contract and Agent Workflow

## Purpose

This document defines how F04/F05 2.5D + ROI experiments are created, reviewed, run, and reported in `/home/vlm/minyoung3`.

Active direction:

```text
Main: dense axial 2.5D center-slice SSL
Ablation: multi-view 2.5D with edge-safe slabs
Extension: ROI-informed auxiliary/token/prompt representation
```

## Hard boundaries

- Do not modify raw data under `/home/vlm/data`.
- Do not use slab-row random split.
- Do not mix `/home/vlm/minyoung3` with `/home/vlm/minyoungi`.
- Do not claim clinical value from reconstruction loss alone.
- Do not scale a new adapter/loss without a cheap verified gate.
- Do not ignore cohort/site/scanner shortcut, age/sex confound, label noise, or preprocessing artifact.

## Canonical manifest families

### Main dense axial SSL

```text
family_id: f04_axial_k5_s4_dense_main
manifest: manifests/f04_25d/f04_25d_axial_k5_s4_dense_manifest.csv
label_manifest: manifests/f04_25d/f04_25d_axial_k5_s4_dense_manifest_official_labels.csv
summary: manifests/f04_25d/f04_25d_axial_k5_s4_dense_manifest_summary.json
smoke: results/f04_25d_axial_k5_s4_dense_smoke/slab_smoke_summary.json
```

### Multi-view ablation

```text
family_id: f04_3view_k5_s8_m8_ablation
manifest: manifests/f04_25d/f04_25d_3view_k5_s8_m8_manifest.csv
label_manifest: manifests/f04_25d/f04_25d_3view_k5_s8_m8_manifest_official_labels.csv
summary: manifests/f04_25d/f04_25d_3view_k5_s8_m8_manifest_summary.json
smoke: results/f04_25d_3view_k5_s8_m8_smoke/slab_smoke_summary.json
```

Multi-view uses `edge_margin=8` because `edge_margin=0` produced zero-brain-mask slabs in coronal/sagittal smoke.

## Run directory contract

Every non-trivial experiment run must create:

```text
runs/<family_id>/<YYYYMMDD_HHMMSS>_seed<seed>_<tag>/
  RUN_NOTE.md
  config_resolved.json
  command.txt
  environment.json
  manifest_hashes.json
  metrics.jsonl
  summary.json
  checkpoint_last.pt
  checkpoints/
```

Required `RUN_NOTE.md` sections:

```text
# Hypothesis
# Data/manifest
# Model
# Loss
# Sampler
# Leakage controls
# Command
# Expected failure modes
# Result summary
# PI decision: promote / modify / pause / kill
```

## Result directory contract

Aggregated results go under:

```text
results/<family_id>/
  selected_runs.json
  metrics_session_level.csv
  metrics_subject_level.csv
  cohort_metrics.csv
  shortcut_controls.csv
  failure_modes.md
  README.md
```

Cross-family comparisons go under:

```text
results/comparisons/<YYYYMMDD>_f04_f05_matrix/
  experiment_matrix.csv
  ranking.json
  subject_level_summary.csv
  cohort_level_summary.csv
  shortcut_control_summary.csv
  decision.md
```

## Minimum preflight before training

1. Manifest exists and hash is recorded.
2. Subject split overlap is exactly zero.
3. Smoke loader fail rows are zero.
4. Sampler debug confirms subject/session diversity.
5. Tensor shape/range/finite check passes.
6. One model forward pass passes.
7. One optimizer step passes if training code changed.
8. Output directory is new or explicitly resumed.

## Sampler contract

The sampler must avoid subject/session overrepresentation.

Minimum requirements:

- session-balanced or subject-balanced sampling;
- for multi-view: view-balanced sampling;
- deterministic seed behavior;
- debug cap must not select one cohort/subject only;
- log seen subjects/sessions/views per epoch or debug epoch.

## Multi-view shape warning

Current slab shapes differ by view:

```text
axial:    [5, 192, 224]
coronal:  [5, 192, 192]
sagittal: [5, 224, 192]
```

Therefore multi-view training is blocked until one of the following is implemented and tested:

1. canonical pad/resize/crop transform;
2. view-specific patch/positional embeddings;
3. per-view encoders with late aggregation.

## Agent workflow

### Controller PI

- Owns the master plan and final decision.
- Enforces leakage and claim boundaries.
- Verifies artifacts before reporting success.

### Implementer agent

- Implements one narrow module/config/test.
- Must return exact paths and verification output.
- Must not launch long GPU jobs without explicit gate.

### Spec reviewer agent

- Checks whether implementation matches the written contract.
- Looks for missing edge cases, bad defaults, and ambiguous outputs.

### Quality/repro reviewer agent

- Checks manifest hashes, split leakage, sampler bias, paths, and smoke tests.
- Flags stale files and failed gates.

### Triage agent

- Parses metrics after runs.
- Produces subject-level, session-level, cohort-level, and shortcut-control summaries.
- Recommends promote/modify/pause/kill.

## New module/loss/adaptor proposal protocol

Every proposal must include:

```text
hypothesis:
expected benefit:
risk/shortcut:
minimal implementation:
cheap gate:
baseline comparison:
promotion criterion:
kill criterion:
```

Allowed examples:

- ROI-weighted masked reconstruction;
- ROI crop auxiliary reconstruction;
- ROI token/prompt conditioning;
- view-specific adapters;
- ROI-conditioned FiLM;
- session/view contrastive consistency.

Blocked unless justified:

- full 3D volumetric classifier revival;
- direct PET headline claim;
- single-run clinical claim;
- ROI-perfect-anatomy claim.

## Reporting contract

After each completed gate/run:

1. Update machine-readable summary JSON.
2. Write/update a report under `reports/`.
3. Write Korean note under `/home/vlm/minyoung/Official/potato/Experiments/`.
4. Update `reports/F04_F05_AUTO_RESEARCH_STATUS.md` if the active decision changes.
5. Record PI decision.
