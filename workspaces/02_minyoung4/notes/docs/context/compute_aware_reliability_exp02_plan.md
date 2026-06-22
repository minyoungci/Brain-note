# exp02 Draft Plan: Compute-Aware Reliability Segmentation

Status: draft, not approved for GPU execution.
Date: 2026-06-22

## Guardrail Template

Task:
Develop a compute-aware segmentation reliability method that starts with cheap single-pass
segmentation and selectively escalates high-risk subjects to expensive TTA/ensemble inference.

Research question:
Can a leakage-safe risk gate recover most of the full ensemble-TTA segmentation gain with
substantially less inference compute under leave-one-consortium-out evaluation?

Outcome:
Whole-tumor Dice, low-Dice failure rate, and Dice-vs-compute curves on held-out consortia.

Input / exposure:
4-channel structural MRI. The gate can use only features available after the cheap first-pass
segmentation unless explicitly reported as an upper-bound diagnostic.

Unit of analysis:
`dataset::subject_id`.

Cohort / filters:
Use the exp01 completed cohort definition unless a new cohort audit is performed.

Split policy:
Leave-one-consortium-out. The risk gate is trained on non-held-out consortia and applied to
the held-out consortium. Held-out Dice, target volume, and target-derived features must not
be used to fit or select the gate.

Leakage risks:
- fitting the gate on held-out test Dice,
- using target voxel count as a deployable feature,
- selecting escalation thresholds on held-out test performance,
- reporting oracle gain ranking as a method result,
- treating full ensemble-TTA predictions as cheap gate inputs.

Files to change:
Only docs and exp01/exp02-owned scripts. Do not write to `/home/vlm/data/raw/`.

Expected artifact:
A report comparing cheap single-pass, full ensemble-TTA, random escalation, cheap risk-gated
escalation, and oracle upper bounds.

Validation:
Python compile, CPU-only analysis checks, row-count checks, LOCO policy fit checks, explicit
GPU command preview before any long run.

Unclear assumptions:
Whether Min wants segmentation reliability as the next locked paper direction.

Needs Min approval:
Any GPU inference/training sweep, new exp02 directory, or long-running nohup job.

## Why This Direction Is Better Than Another Loss Variant

exp01 showed:

- Best artifact: two-model all-flip TTA, mean Dice 0.892775.
- Standard ResUNet-DS: mean Dice 0.887385.
- Full best gain over ResUNet-DS: +0.005390.
- Single-pass distillation and consistency variants did not preserve the gain.

CPU-only post-hoc analyses showed:

- Best-artifact Dice <= 0.8 can be predicted with LOCO OOF AUC 0.923800 using existing
  prediction-derived features.
- A stricter cheap gate using only single-pass ResUNet predicted volume recovers 60.1458%
  of the full best gain at 30% escalation.
- At 50% escalation it recovers 76.6592% of the full best gain.

This suggests the useful method question is not "which generic loss improves Dice?" but
"which subjects deserve expensive segmentation compute?"

## Prior-Work Spot Check And Claim Boundary

Spot check date: 2026-06-22. This is not a complete literature review, but it is enough
to constrain the claim.

Relevant prior work:

- Wang et al. formulated test-time augmentation for medical image segmentation uncertainty
  and evaluated it on MRI tasks, including brain tumors:
  https://arxiv.org/abs/1807.07356
- Ding et al. studied uncertainty-aware training for selective medical image segmentation,
  where uncertain cases are deferred rather than accepted automatically:
  https://proceedings.mlr.press/v121/ding20a.html
- Recent decision-focused segmentation uncertainty work argues that uncertainty should be
  judged by the decisions it enables, not only by calibration/error correlation:
  https://arxiv.org/abs/2604.13262
- Recent brain-tumor uncertainty work again emphasizes that voxel-level uncertainty and
  segmentation error detection can fail in clinically important sub-regions:
  https://arxiv.org/html/2606.19300v1

Implication:

- Do **not** claim novelty for TTA uncertainty, uncertainty estimation, or selective
  segmentation alone.
- Do **not** claim that CARE-Seg is a new segmentation architecture.
- The defensible claim is narrower: **subject-level compute-adaptive escalation** under
  cross-consortium shift, where a cheap first-pass gate decides when expensive
  ensemble/TTA segmentation is worth its compute.
- The evaluation must therefore be decision-centric: Dice-vs-compute, low-Dice failure
  rate, and paired improvement over random escalation at the same budget.

## Confirmatory Decision Rule

Primary budgets:

- 30% escalation: main budget.
- 50% escalation: supportive budget.
- 10% escalation: exploratory; too few subjects are escalated for a hard no-go.

Primary gate:

- `loco_cheap_failure_logistic`, trained only on non-held-out consortia.
- Deployable cheap-path features only. Target-derived features, held-out Dice, oracle gain,
  and expensive-path features are forbidden for the method result.

A CARE-Seg GO requires all of the following:

- At 30% escalation, mean Dice delta vs cheap single-pass is positive with subject-level
  bootstrap CI lower bound > 0.
- At 30% escalation, mean Dice delta vs expected random escalation at the same budget is
  positive with paired subject-level bootstrap CI lower bound > 0. A fixed-seed random row
  is reported only as a diagnostic.
- At 50% escalation, delta vs expected random is also positive with CI lower bound > 0.
- Low-Dice failure rate does not increase versus cheap single-pass at 30% or 50%.
- UCSD and MU do not show a collapse relative to cheap single-pass.

Current evidence from existing predictions:

- 30% `loco_cheap_failure_logistic`: mean Dice 0.890608, delta vs cheap +0.003223,
  retained full gain 0.598003.
- 50% `loco_cheap_failure_logistic`: mean Dice 0.891517, delta vs cheap +0.004132,
  retained full gain 0.766592.
- A CPU validation run of the updated harness with 500 bootstrap replicates produced:
  - 30% delta vs expected random +0.001606, CI95 [+0.000398, +0.002838].
  - 50% delta vs expected random +0.001437, CI95 [+0.000578, +0.002285].

The random-comparison CI must be regenerated in the official report with the default
bootstrap setting after approved full feature export. The 500-bootstrap values above are
implementation validation, not the final paper number.

## Method Candidate

Working name: CARE-Seg, Compute-Adaptive Reliability Escalation for Segmentation.

Pipeline:

1. Run cheap single-pass ResUNet-DS on every subject.
2. Extract deployable risk features from that pass:
   - predicted tumor volume,
   - near-threshold voxel fraction,
   - mean/max foreground probability,
   - optional entropy from the probability map.
3. Rank subjects by predicted failure risk.
4. Escalate only the highest-risk subjects to an expensive path:
   - all-flip TTA,
   - two-model ensemble-TTA,
   - or a budget-specific variant.
5. Report segmentation performance as a function of compute budget.

Optional stronger version after explicit approval:

- Export TTA variance and spatial disagreement maps during inference.
- Train a leakage-safe risk model using non-held-out consortia only.
- Compare risk-gated escalation to random, small-volume heuristic, and oracle upper bound.

## Primary Metrics

Primary:

- Mean Dice at fixed escalation budgets: 10%, 30%, 50%.
- Fraction of full ensemble-TTA gain retained at each budget.
- Dice <= 0.8 failure rate at each budget.

Secondary:

- Risk model AUC/AP for low-Dice failure.
- Risk-coverage curve.
- Per-consortium Dice and failure-rate changes.
- Paired delta-vs-random escalation at the same compute budget.
- Paired delta-vs-expected-random escalation at the same compute budget.
- Normalized compute cost:
  - ResUNet single-pass = 1x,
  - one-model all-flip TTA = 8x,
  - two-model all-flip TTA = 16x.

## No-Go Rules

Do not continue this direction if:

- risk-gated escalation is not clearly better than random escalation at 30% and 50% budgets,
- gains collapse on UCSD or MU,
- the gate requires target-derived or full-expensive-path features to work,
- the method cannot be explained as compute-aware reliability rather than post-hoc cherry-picking.

## Current Evidence

Available reports:

- `experiments/exp01_loco_segmentation_robust/METHOD_REPORT.md`
- `experiments/exp01_loco_segmentation_robust/analysis/failure_risk_audit_v1/report.md`
- `experiments/exp01_loco_segmentation_robust/analysis/selective_compute_policy_v1/report.md`

Key current result:

| policy | escalation | mean Dice | retained full gain |
|---|---:|---:|---:|
| cheap risk gate | 30% | 0.890627 | 60.1458% |
| cheap risk gate | 50% | 0.891517 | 76.6592% |
| full ensemble-TTA | 100% | 0.892775 | 100% |

## Next Implementation Step Before GPU

Add optional uncertainty/disagreement feature export to existing TTA and ensemble evaluators.
This is implemented and disabled by default, so completed exp01 behavior remains unchanged.

Minimum subject-level features to export:

- number of probability samples,
- mean/max/p95 probability,
- near-threshold voxel fraction,
- entropy mean/p95,
- probability standard-deviation mean/p95,
- vote-disagreement mean/p95,
- predicted-region versions of uncertainty summaries when the prediction is non-empty.

Implemented files:

- `experiments/exp01_loco_segmentation_robust/scripts/uncertainty_features.py`
- `experiments/exp01_loco_segmentation_robust/scripts/eval_tta_loco.py`
- `experiments/exp01_loco_segmentation_robust/scripts/eval_ensemble_tta_loco.py`

Validation completed:

- Python compile passed for all three files.
- CPU smoke passed for cheap single-pass export:
  `runs/smoke_uncertainty_singlepass_cpu_v1/outer_UCSD-PTGBM`.
- CPU smoke passed for single-model TTA export:
  `runs/smoke_uncertainty_tta_cpu_v1/outer_UCSD-PTGBM`.
- CPU smoke passed for ensemble-TTA export:
  `runs/smoke_uncertainty_ensemble_cpu_v1/outer_UCSD-PTGBM`.
- Exported test prediction CSVs contain `n_prob_samples`, `near_threshold_frac`,
  `entropy_mean_all`, `prob_std_mean_all`, and `vote_disagreement_mean_all`.

Next step, if Min approves GPU use:

- Run cheap single-pass feature-export inference and expensive ensemble-TTA feature-export
  inference. No new training is needed for the first exp02 gate.
- Prepare command preview before launch.
- Use `setsid nohup` and write PID/log files if approved.

Compute-accounting rule:

- `resunet_ds_singlepass_uncertainty_export_v1` is the only valid cheap gate-input export.
- `resunet_ds_tta_all_uncertainty_export_v1` is not a cheap gate input; it is an optional
  intermediate escalation/diagnostic run because it already uses all-flip TTA.
- `resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1` is the expensive path.

## Policy Analysis Harness

Implemented:

- `experiments/exp01_loco_segmentation_robust/scripts/build_careseg_policy_from_exports.py`

Purpose:

- consume a cheap-path prediction run and an expensive-path prediction run,
- auto-detect deployable cheap-path numeric features,
- exclude target-derived/leaky columns such as target voxels, Dice labels, failure labels,
  and gain labels,
- fit risk policies in a held-out-consortium LOCO manner,
- report Dice-vs-compute curves and oracle upper bounds.

Validation completed:

- Python compile passed.
- Existing full predictions regression check passed:
  - cheap path: `resunet_ds_dice_bce_loco_full_v1_sharedcache`
  - expensive path: `resunet_ds_tta_distill_ensemble_tta_all_v1`
  - N=1617
  - deployable features: `cheap_pred_voxels`, `log1p_cheap_pred_voxels`
  - 30% LOCO cheap-failure gate: mean Dice 0.890608, 59.8003% of full gain.
  - subject-level bootstrap CI for 30% gate:
    mean Dice CI95 [0.883548, 0.897049], delta-vs-cheap CI95 [0.001539, 0.004862].
- Recoverable-failure label probes were implemented and tested:
  - `loco_recoverable_failure_gain_logistic`
  - `loco_recoverable_failure_nonfailure_logistic`
  - On current predicted-volume-only features, neither beats the simpler cheap-failure gate.
    The best 30% policy remains `loco_cheap_failure_logistic`.
- Uncertainty smoke check passed:
  - cheap path: `runs/smoke_uncertainty_singlepass_cpu_v1`
  - expensive path: `runs/smoke_uncertainty_ensemble_cpu_v1`
  - nonconstant deployable cheap feature count after excluding compute metadata: 10
- Strict compute-accounting checks passed:
  - single-pass smoke passes with `--require-cheap-tta none` and
    `--require-cheap-n-prob-samples 1`.
  - TTA smoke intentionally fails if used as the cheap path with `--require-cheap-tta none`.
- CARE-Seg reports now include subject-level bootstrap CI columns for mean Dice,
  low-Dice rate, and delta-vs-cheap.
- CARE-Seg reports now include paired subject-level bootstrap CI columns for fixed-seed
  delta-vs-random and deterministic delta-vs-expected-random escalation at the same budget.
- CARE-Seg reports now include an automatic confirmatory decision block and a
  `per_dataset_policy_curve.csv` file so UCSD/MU collapse checks are not left to manual
  interpretation.
- The confirmatory decision is parameterized by CLI flags:
  `--primary-policy`, `--primary-budget`, `--support-budget`, and `--hard-folds`.
  Defaults match this protocol: `loco_cheap_failure_logistic`, 30%, 50%,
  `UCSD-PTGBM,MU-Glioma-Post`.
- The analysis script rejects invalid decision configs: oracle/random primary policies,
  unsupported escalation budgets, empty hard-fold lists, and unknown hard-fold names.
- The CARE-Seg watcher and nohup watcher launcher now forward the same decision config
  flags, so approved unattended runs produce a report with the official primary policy,
  budgets, and hard-fold list recorded in `summary.json`.
- CPU validation on existing predictions with 500 bootstrap replicates produced
  `confirmatory_decision.go = true` for `loco_cheap_failure_logistic`:
  - 30% delta vs expected random +0.001606, CI95 [+0.000398, +0.002838].
  - 50% delta vs expected random +0.001437, CI95 [+0.000578, +0.002285].
  - hard-fold point-estimate deltas vs cheap at 30%/50% were nonnegative for MU and UCSD.
  - This existing-prediction proxy has only two nonconstant deployable features
    (`cheap_pred_voxels`, `log1p_cheap_pred_voxels`); the official feature-export result
    must re-pass the gate using uncertainty features.
- Watcher implemented:
  - `experiments/exp01_loco_segmentation_robust/scripts/watch_careseg_exports.py`
  - `experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_careseg_export_watcher.sh`
  - CPU `--once` smoke passed using existing tiny export outputs.
  - The smoke exposed a nonpositive full-gain display issue; retained-gain fraction is now
    left empty when the expensive path is not better than the cheap path.
- Overwrite guards added:
  - feature-export launchers refuse existing fold outputs unless `ALLOW_OVERWRITE=yes`.
  - CARE-Seg watcher launcher refuses existing report/status outputs unless
    `ALLOW_OVERWRITE=yes`.
  - validation confirmed the normal approval guard exits 2 and overwrite guard exits 4.

Post-export command after approved GPU feature export:

```bash
python experiments/exp01_loco_segmentation_robust/scripts/build_careseg_policy_from_exports.py \
  --cheap-run resunet_ds_singlepass_uncertainty_export_v1 \
  --expensive-run resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1 \
  --out-dir experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1 \
  --expected-n 1617 \
  --require-cheap-tta none \
  --require-expensive-tta all \
  --require-cheap-n-prob-samples 1 \
  --require-expensive-n-prob-samples 16 \
  --min-cheap-feature-count 10
```
