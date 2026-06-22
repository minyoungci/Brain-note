# CARE-Seg Paper Experiment Plan

Date: 2026-06-22

Status: paper-facing plan only. CARE-Seg is not locked and GPU execution is not approved.

## Paper Claim

CARE-Seg is a compute-adaptive reliability method for cross-consortium glioma segmentation.
It uses a cheap single-pass segmentation result to decide which subjects should receive
expensive ensemble/TTA inference.

The paper should argue:

- full ensemble/TTA improves robustness but is expensive,
- not every subject needs expensive inference,
- a leakage-safe subject-level gate can recover most of the ensemble/TTA gain at a fixed
  compute budget,
- the gate beats expected random escalation under leave-one-consortium-out evaluation,
- gains do not collapse on the hard UCSD/MU held-out folds.

Do not argue:

- new segmentation architecture,
- generic TTA uncertainty novelty,
- selective segmentation novelty by itself,
- successful single-pass distillation/compression.

## Required Experiments

### E1. Base Segmentation Systems

Purpose:
Establish the performance envelope.

Rows:

- compact 3D U-Net Dice+BCE baseline,
- ResUNet-DS single-pass cheap path,
- one-model all-flip TTA,
- two-model ensemble-TTA expensive path,
- failed compression/distillation rows as ablations only.

Metrics:

- mean Dice,
- Dice <= 0.8 failure rate,
- per-consortium Dice,
- paired delta vs standard baseline.

Source:

- `experiments/exp01_loco_segmentation_robust/METHOD_REPORT.md`.

### E2. CARE-Seg Main Decision Table

Purpose:
Show the decision-centric result at fixed compute budgets.

Rows:

- cheap single-pass, 0% escalation,
- random expected escalation at 10%, 30%, 50%,
- fixed-seed random diagnostic at 10%, 30%, 50%,
- CARE-Seg primary gate at 10%, 30%, 50%,
- full ensemble/TTA, 100% escalation,
- oracle upper bound, clearly marked non-deployable.

Metrics:

- mean Dice,
- delta vs cheap with subject-level bootstrap CI,
- delta vs expected random with paired subject-level bootstrap CI,
- Dice <= 0.8 rate,
- fraction of full ensemble/TTA gain retained,
- normalized compute cost.

Primary claim:

- 30% escalation delta vs expected random CI lower bound > 0.

Supportive claim:

- 50% escalation delta vs expected random CI lower bound > 0.

### E3. Per-Consortium Robustness Table

Purpose:
Prevent pooled-score hiding.

Rows:

- `loco_cheap_failure_logistic` at 30% and 50% escalation.

Columns:

- held-out consortium,
- n subjects,
- n escalated,
- escalation fraction,
- cheap mean Dice,
- CARE-Seg mean Dice,
- delta vs cheap,
- cheap Dice <= 0.8 rate,
- CARE-Seg Dice <= 0.8 rate,
- delta failure rate.

Hard-fold no-collapse gate:

- UCSD-PTGBM and MU-Glioma-Post must have nonnegative point-estimate delta vs cheap at
  30% and 50%.

Source:

- `per_dataset_policy_curve.csv`.

### E4. Risk-Gate Ablation

Purpose:
Show the selected gate is not arbitrary.

Rows:

- random expected escalation,
- small predicted tumor volume heuristic,
- `loco_cheap_failure_logistic`,
- `loco_recoverable_failure_gain_logistic`,
- `loco_recoverable_failure_nonfailure_logistic`,
- `loco_gain_ridge`,
- oracle gain upper bound.

Metrics:

- same as E2 at 30% and 50% escalation.

Expected current proxy interpretation:

- failure-risk ranking is stronger than direct gain regression,
- recoverable-failure variants do not clearly beat the simpler cheap-failure gate,
- oracle rows show headroom but are non-deployable.

### E5. Uncertainty Feature Contribution

Purpose:
After full feature export, test whether uncertainty summaries add value beyond predicted
tumor volume.

Rows:

- volume-only gate,
- probability-statistics gate,
- uncertainty/disagreement gate,
- combined cheap-feature gate.

Allowed features:

- predicted tumor volume,
- near-threshold voxel fraction,
- probability mean/max/p95,
- entropy summaries,
- probability-variance summaries,
- vote-disagreement summaries.

Forbidden features:

- target voxels,
- Dice labels on held-out subjects,
- expensive-path predictions/features,
- oracle gain.

No-go:

- If uncertainty features do not beat volume-only, the method claim should use the simpler
  volume/failure-risk gate and report uncertainty features as diagnostic only.

### E6. Compute Curve Figure

Purpose:
Make the method visually understandable.

X-axis:

- normalized compute cost or escalation rate.

Y-axis:

- mean Dice,
- Dice <= 0.8 failure rate in a second panel.

Curves:

- expected random,
- CARE-Seg primary gate,
- small-volume heuristic,
- oracle upper bound,
- full expensive inference as endpoint.

Required annotation:

- 30% primary point,
- 50% supportive point.

### E7. Failure Case Audit

Purpose:
Reviewer-facing sanity check.

Sample categories:

- cheap failure rescued by expensive path,
- cheap failure not rescued,
- cheap success unnecessarily escalated,
- hard-fold examples from UCSD/MU.

Do not make qualitative claims unless the subject-level CSV supports the category.

## Required Official Artifacts

Official CARE-Seg report directory must contain:

- `summary.json`,
- `report.md`,
- `policy_curve.csv`,
- `per_dataset_policy_curve.csv`,
- `subject_policy_scores.csv`,
- `official_acceptance.json`,
- `watch_careseg_status.json` if watcher was used.

Official export run directories must contain four folds each:

- `outer_UCSD-PTGBM`,
- `outer_MU-Glioma-Post`,
- `outer_UPENN-GBM`,
- `outer_UTSW`.

Each fold must contain:

- `test_predictions.csv`,
- `val_predictions.csv`,
- `summary.json`,
- `report.md`.

## Acceptance Criteria

Promote CARE-Seg from lock candidate to locked exp02 only if the official feature-export
report satisfies all of:

- row count N=1617,
- cheap export has `tta=none` and `n_prob_samples=1`,
- expensive export has `tta=all` and `n_prob_samples=16`,
- at least 10 nonconstant deployable cheap features in the official uncertainty-feature
  analysis, excluding compute metadata such as `n_prob_samples`,
- confirmatory decision GO=True,
- primary 30% delta vs expected random CI lower bound > 0,
- support 50% delta vs expected random CI lower bound > 0,
- UCSD/MU no-collapse gate passes,
- no target-derived or expensive-path features are used by the deployable gate.

## Rejection Criteria

Do not promote CARE-Seg if:

- official feature export fails compute-accounting checks,
- expected-random advantage disappears,
- hard-fold deltas collapse,
- the gate only works with oracle or expensive-path features,
- uncertainty features are required but not deployable from the cheap path,
- the result can only be framed as another segmentation tuning run.

## Next Action If Approved

Run:

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
PRIMARY_POLICY=loco_cheap_failure_logistic \
PRIMARY_BUDGET=0.30 \
SUPPORT_BUDGET=0.50 \
HARD_FOLDS=UCSD-PTGBM,MU-Glioma-Post \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_careseg_feature_export_pipeline.sh
```

Only run this after explicit approval.
