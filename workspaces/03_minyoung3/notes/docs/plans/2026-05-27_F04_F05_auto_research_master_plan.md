# F04/F05 Auto-Research Master Plan — 2.5D + ROI

## Executive decision

We will run this project as a rigorous auto-research program, not as ad-hoc GPU trials.

Primary direction:

```text
F04/F05: dense 2.5D axial center-slice SSL + ROI-informed representation
```

Main data setting:

```text
F04-B-dense-main
view = axial
slab_size = 5
stride = 4
expected slab rows = 571,593
sessions = 18,815
subjects = 8,251
```

Multi-view is **not** the first main setting. It is a clean ablation ladder:

```text
F04-D-multiview-ablation
views = axial + coronal + sagittal
slab_size = 5
stride = 8
edge_margin = 8
expected slab rows = 939,962

F04-E-large-multiview-final
views = axial + coronal + sagittal
slab_size = 5
stride = 4
expected slab rows = 1,988,651
```

## Non-negotiable principles

1. No slab-level random split.
2. No session-level leakage across train/val/test via repeated subject visits.
3. SSL uses all valid PASS MRI slabs; downstream probes use official-label subset.
4. Results are reported at session and subject levels; claims prefer subject-level aggregation.
5. Cohort/site/scanner/label shortcut controls are mandatory, not optional.
6. Reconstruction quality is a plumbing/pretext signal, not clinical representation evidence.
7. ROI Visual-QC PASS means usable policy layer, not perfect anatomical alignment.
8. Every long run has immutable config, manifest hash, command, checkpoint, metrics, and report.
9. Failed experiments are kept and triaged, not silently overwritten.
10. New adapters/losses are encouraged only after a written hypothesis and a cheap gate.

## Data ladder

### D0 — Existing axial conservative baseline

```text
family: f04_axial_k5_s8
views: axial
slab_size: 5
stride: 8
rows: 299,984
role: sanity/reference baseline
```

### D1 — Main dense axial setting

```text
family: f04_axial_k5_s4_dense
views: axial
slab_size: 5
stride: 4
rows: 571,593
role: main SSL corpus
```

Rationale:

- roughly doubles the current axial samples;
- avoids multi-view confounds initially;
- keeps ROI integration simpler;
- sufficient density for strong SSL without claiming artificial independent sample inflation.

### D2 — Context-thicker axial ablation

```text
family: f04_axial_k7_s4_context
views: axial
slab_size: 7
stride: 4
rows: ~562,193
role: context-width ablation
```

Kill if:

- memory/runtime cost increases without downstream gain;
- reconstruction improves but probes do not improve;
- model appears to solve via interpolation shortcut.

### D3 — Multi-view ablation

```text
family: f04_3view_k5_s8_m8_ablation
views: axial, coronal, sagittal
slab_size: 5
stride: 8
edge_margin: 8
rows: 939,962
role: view-diversity ablation
```

Reason for edge margin:

- edge_margin=0 generated some coronal/sagittal edge slabs with zero brain-mask coverage in smoke;
- edge_margin=8 preserved large sample size while passing balanced 63-row smoke across cohort/split/view.

Required controls:

- view-balanced sampler;
- per-view reconstruction loss;
- view-specific embedding probe;
- axial-only comparison under same training budget.

### D4 — Large multi-view final scale

```text
family: f04_3view_k5_s4_large
views: axial, coronal, sagittal
slab_size: 5
stride: 4
rows: ~1,988,651
role: only after D1/D3 justify it
```

Promotion rule:

- run only if D3 improves downstream probes without increasing shortcut behavior.

## Model ladder

### M0 — Debug/control CNN-lite

Role: loader/loss/debug baseline only.

Do not use as paper-facing backbone unless Transformer path fails.

### M1 — Patch-MLP token baseline

Role: cheap token-path ablation.

Purpose: separate patch-tokenization benefit from attention benefit.

### M2 — Main ViT/MAE-style patch Transformer

Role: paper-facing main SSL backbone.

Input:

```text
[B, K, H, W]
K = 5 for main, K = 7 for context ablation
```

Target:

```text
center slice masked brain patches only
```

### M3 — ROI-crop auxiliary model

Hypothesis:

ROI-local auxiliary reconstruction improves clinically useful anatomical representation beyond global slab reconstruction.

Mechanism:

- global center-slice masked reconstruction;
- ROI crop/local masked reconstruction loss;
- optional ROI crop consistency loss.

### M4 — ROI-token/prompt Transformer

Hypothesis:

ROI identity/location tokens help patch Transformer allocate attention to clinically relevant anatomy without hard-coding ROI scalar shortcuts.

Mechanisms to test:

- ROI presence/location token;
- ROI-type embedding;
- ROI mask-gated attention bias;
- ROI-aware masked patch sampling.

### M5 — Adapter family

Only after M2 baseline is stable.

Candidates:

- small bottleneck adapters per cohort/view;
- ROI-conditioned FiLM adapter;
- view-specific adapter for multi-view ablation;
- LoRA-style low-rank attention adapter for ROI prompt variants.

Adapters must be justified by failure evidence:

- cohort-specific collapse;
- view imbalance;
- ROI/no-ROI representation gap;
- overfitting in full fine-tune but underfitting in frozen probe.

## Loss ladder

### L0 — Main masked center-slice L1

```text
loss = mean(abs(pred - target) over masked brain pixels)
```

### L1 — L1 + SSIM/local structure

Purpose: avoid blurry reconstruction, but do not equate SSIM with representation quality.

Promotion if:

- downstream probe improves;
- not just reconstruction image prettiness.

### L2 — ROI-weighted masked reconstruction

Mechanism:

```text
loss = global masked loss + lambda_roi * ROI-region masked loss
```

Risks:

- ROI misalignment;
- ROI shortcut;
- overfitting to ROI volume/shape.

Must run ROI-volume-only control.

### L3 — Contrastive session/view consistency

Only after embeddings are exportable.

Positive pairs:

- slabs from same session but different center indices;
- same session across views for multi-view ablation.

Hard rule:

- positives never cross subject identity incorrectly;
- no val/test leakage into SSL train contrastive pairs.

### L4 — Mask sampling curriculum

Candidates:

- uniform patch mask;
- brain-only mask;
- ROI-biased mask;
- edge/anatomy-balanced mask.

Promotion if:

- improves downstream clinical probes under same compute;
- does not inflate reconstruction-only metrics with no representation benefit.

## Sampler contract

Bad:

```text
random slab-row shuffle with no subject/session balancing
```

Required for SSL:

1. select subject or session first;
2. select slab/view within that session;
3. keep batch subject diversity high;
4. for multi-view, balance view frequencies;
5. log per-batch or per-epoch subject/session/view coverage.

Minimum run summary fields:

```text
unique_train_subjects_seen
unique_train_sessions_seen
slabs_seen_by_view
slabs_seen_by_cohort
mean_slabs_per_subject_seen
```

## Downstream probe ladder

### P0 — Reconstruction validation

Purpose: plumbing only.

Metrics:

- masked-brain L1/MSE;
- per-view if multi-view;
- qualitative montage.

No clinical claim allowed.

### P1 — Frozen embedding probes

Targets:

- official CDR global;
- official CDR-SB;
- diagnosis secondary only;
- progression/worsening only after longitudinal label gate.

Units:

- slab embedding -> session aggregation -> subject aggregation.

### P2 — kNN / linear / shallow MLP probes

Required to distinguish representation quality from probe capacity.

### P3 — Shortcut controls

Mandatory controls:

- majority_train;
- cohort-only forbidden control;
- ROI-volume-only forbidden/diagnostic control;
- age/sex clinical-only if coverage is sufficient;
- 2D-only center-slice;
- 2.5D no-ROI;
- same-parameter or same-budget baseline where possible.

### P4 — Robustness probes

- per-cohort metrics;
- leave-one-cohort-out where feasible;
- subject-level bootstrap CI;
- CDR-SB excluding AIBL or explicitly marking AIBL missing-label policy;
- repeated-run seed sensitivity.

## Promotion / modification / kill rules

### Promote

Promote a family only if:

1. no leakage failures;
2. finite stable training;
3. validation reconstruction not degenerate;
4. frozen probe improves over no-ROI/main baseline;
5. improvement persists at subject level;
6. improvement is not explained by cohort-only or ROI-volume-only controls;
7. at least 3 seeds or bootstrap confidence supports the direction.

### Modify

Modify if:

- reconstruction improves but downstream does not;
- one cohort improves while another collapses;
- ROI benefit appears but ROI-volume-only is competitive;
- multi-view improves train/val only but not test;
- clinical-only beats image representation.

### Kill / pause

Kill or pause if:

- train/val/test subject overlap > 0;
- debug sampler collapses to one cohort/subject;
- model learns cohort shortcut stronger than clinical signal;
- external/worst-cohort performance collapses repeatedly;
- ROI alignment errors dominate visual/QC samples;
- results depend on single seed or one lucky checkpoint.

## Auto-research operating loop

Every experiment proposal follows:

```text
1. Hypothesis
2. Minimal code/config diff
3. Unit/shape tests
4. Tiny CPU smoke
5. Tiny CUDA pilot if relevant
6. Immutable full run after approval
7. Artifact triage
8. Report + Korean note
9. Decide: promote / modify / pause / kill
```

For new modules/adapters/losses:

```text
insight -> written hypothesis -> cheap ablation -> compare against baseline -> only then scale
```

## Multi-agent workflow

Controller PI:

- owns final decisions;
- writes/updates master plan;
- enforces leakage/claim boundaries;
- stages commits only after verification.

Implementer agent:

- writes code/tests for one narrow task;
- cannot launch long GPU jobs without controller gate.

Spec reviewer agent:

- checks implementation against task contract.

Quality/repro reviewer agent:

- checks leakage, paths, artifacts, tests, and run reproducibility.

Triage agent:

- parses completed run artifacts;
- extracts subject-level/cohort-level metrics;
- flags overfitting/shortcut risks.

If subagents fail or timeout, controller proceeds manually and records the failure; no silent dependency on failed agent output.

## Directory contract

```text
configs/f04_f05_auto_research/
  f04_axial_k5_s4_dense_mae.json
  f04_3view_k5_s8_ablation_mae.json
  f05_roi_aux_axial_k5_s4.json

manifests/f04_25d/
  f04_25d_axial_slab_manifest_v0.csv
  f04_25d_axial_slab_manifest_v0_official_labels.csv
  f04_25d_axial_k5_s4_dense_manifest.csv
  f04_25d_3view_k5_s8_manifest.csv

runs/<family_id>/<YYYYMMDD_HHMMSS>_seed<seed>_<tag>/
  RUN_NOTE.md
  config_resolved.json
  command.txt
  environment.json
  train_manifest.csv
  val_manifest.csv
  metrics.jsonl
  checkpoint_last.pt
  checkpoints/
  summary.json

results/<family_id>/
  selected_runs.json
  metrics_session_level.csv
  metrics_subject_level.csv
  cohort_metrics.csv
  shortcut_controls.csv
  README.md

results/comparisons/<YYYYMMDD>_f04_f05_matrix/
  experiment_matrix.csv
  model_ranking.json
  failure_modes.md

reports/
  F04_F05_AUTO_RESEARCH_STATUS.md
  F04_F05_MODEL_COMPARISON_<date>.md
  F05_ROI_SOURCE_CONTRACT_AUDIT.md
```

## Immediate next gates

### Gate A — dense axial manifest

Build and verify:

```text
manifests/f04_25d/f04_25d_axial_k5_s4_dense_manifest.csv
```

Required checks:

- row/session/subject counts;
- split counts;
- subject overlap = 0;
- official label join compatibility;
- one NIfTI slab smoke.

### Gate B — multi-view ablation manifest

Build and verify:

```text
manifests/f04_25d/f04_25d_3view_k5_s8_m8_manifest.csv
```

Required checks:

- view counts;
- per-view center index distribution;
- view-balanced sampler design;
- one slab smoke per view.

### Gate C — session-balanced sampler

Add sampler tests:

- no naive sorted head collapse;
- subject/session diversity under debug cap;
- view-balanced sampling for multi-view;
- reproducible seed behavior.

### Gate D — F05 ROI source-contract audit

Before any ROI model:

- join ROI cache to F04 sessions;
- verify split consistency;
- inspect ROI tensor shape/range/NaN;
- write ROI-volume-only control plan;
- classify visual QC as usable vs imperfect, not perfect.

## Reporting cadence

After every completed gate or run:

1. machine-readable summary JSON;
2. human report under `reports/`;
3. Korean official note under `/home/vlm/minyoung/Official/potato/Experiments/`;
4. update master status report;
5. decide promote/modify/pause/kill.

## Current first action

Proceed with Gate A and Gate B scaffolds before any more long training.
