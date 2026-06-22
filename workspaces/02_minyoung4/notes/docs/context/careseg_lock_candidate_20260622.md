# CARE-Seg Lock Candidate

Date: 2026-06-22

Status: lock candidate only. GPU execution is not approved.

## Decision

Recommended next research direction:

**CARE-Seg: Compute-Adaptive Reliability Escalation for cross-consortium glioma
segmentation.**

This should replace generic segmentation-loss tuning as the next candidate if Min wants to
continue within the segmentation line. The claim should be compute-aware reliability, not
raw segmentation architecture novelty.

## Guardrail Template

Task:
Develop a leakage-safe subject-level gate that starts from cheap single-pass segmentation
and escalates only high-risk subjects to expensive ensemble/TTA inference.

Research question:
Can a cheap first-pass risk gate recover most of the full ensemble-TTA benefit at fixed
compute budgets, while beating expected random escalation under leave-one-consortium-out
evaluation?

Outcome:
Mean Dice, Dice <= 0.8 failure rate, Dice-vs-compute curve, and paired delta versus
expected random escalation.

Input / exposure:
4-channel structural MRI. The deployable gate may use only cheap first-pass prediction
features.

Unit of analysis:
`dataset::subject_id`.

Cohort / filters:
exp01 completed cohort, N=1617 subjects.

Split policy:
Leave-one-consortium-out. Gate scores are fit on non-held-out consortia and evaluated on
the held-out consortium.

Leakage risks:
Target-derived features, held-out Dice, oracle gain, expensive-path features, and
full-expensive-path uncertainty are forbidden for the method gate.

Files to change:
Only docs and exp01/exp02-owned scripts unless a new approved exp02 directory is created.

Expected artifact:
`summary.json`, `report.md`, `policy_curve.csv`, `per_dataset_policy_curve.csv`, and
`subject_policy_scores.csv` from `build_careseg_policy_from_exports.py`.

Validation:
Python compile, CPU regression on existing predictions, config rejection tests, row-count
checks, compute-accounting checks, and explicit GPU command preview before any full export.

Unclear assumptions:
Whether Min approves CARE-Seg as the next locked research direction.

Needs Min approval:
Research lock, GPU feature export, any long-running nohup job.

## Claim Boundary

Do not claim:

- new segmentation architecture,
- novelty for TTA uncertainty,
- novelty for selective segmentation alone,
- single-pass compression success.

Defensible claim:

CARE-Seg is a decision-centric deployment method: under cross-consortium shift, a
subject-level cheap-path gate decides when expensive ensemble/TTA segmentation is worth its
compute, and it beats expected random escalation at the same budget.

## Current Evidence

Completed exp01 best artifact:

- Best system: `resunet_ds_tta_distill_ensemble_tta_all_v1`.
- Mean Dice: 0.892775.
- Delta vs standard Dice+BCE U-Net: +0.008498, CI95 [+0.005960, +0.011038].
- Limitation: two-model all-flip TTA; strong performance artifact, weak clean-method claim.

Cheap path:

- `resunet_ds_dice_bce_loco_full_v1_sharedcache`.
- Mean Dice: 0.887385.

Current CARE-Seg proxy validation from existing predictions:

- Output:
  `experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_existing_predictions_v2`.
- Bootstrap: 1000 replicates for implementation validation.
- Primary policy: `loco_cheap_failure_logistic`.
- Primary budget: 30% escalation.
- Support budget: 50% escalation.
- Hard folds: UCSD-PTGBM and MU-Glioma-Post.
- Confirmatory decision: GO=True.
- Deployable features in this proxy: `cheap_pred_voxels`, `log1p_cheap_pred_voxels`.
  This remains a volume-only proxy, not the official uncertainty-feature result.

Primary 30% escalation:

- Mean Dice: 0.890608.
- Delta vs cheap: +0.003223, CI95 [+0.001630, +0.004896].
- Delta vs expected random: +0.001606, CI95 [+0.000387, +0.002820].
- Dice <= 0.8 rate: 0.102659.
- Delta low-Dice rate vs cheap: -0.011750.

Support 50% escalation:

- Mean Dice: 0.891517.
- Delta vs cheap: +0.004132, CI95 [+0.002403, +0.005995].
- Delta vs expected random: +0.001437, CI95 [+0.000559, +0.002323].
- Dice <= 0.8 rate: 0.102041.
- Delta low-Dice rate vs cheap: -0.012369.

Hard-fold deltas vs cheap:

| fold | escalation | delta Dice | delta low-Dice rate |
| --- | ---: | ---: | ---: |
| MU-Glioma-Post | 30% | +0.003855 | -0.024631 |
| UCSD-PTGBM | 30% | +0.021696 | -0.061798 |
| MU-Glioma-Post | 50% | +0.005983 | -0.024631 |
| UCSD-PTGBM | 50% | +0.023047 | -0.061798 |

## Confirmatory Rule

CARE-Seg GO requires:

- primary policy present,
- 30% delta vs cheap CI lower bound > 0,
- 30% delta vs expected random CI lower bound > 0,
- 50% delta vs expected random CI lower bound > 0,
- 30% and 50% low-Dice failure rate not worse than cheap,
- UCSD and MU point-estimate deltas not negative.

The current harness rejects invalid official decision configs:

- oracle/random primary policy,
- unsupported escalation budgets,
- equal primary/support budgets,
- empty hard-fold list,
- unknown hard-fold names.

## Implementation State

Ready:

- uncertainty feature export code exists and is disabled by default,
- CPU preflight exists for source checkpoints, metadata, ensemble compatibility, output
  overwrite risk, and decision config,
- CPU smoke tests passed for single-pass, TTA, and ensemble export,
- policy harness excludes target-derived/leaky features,
- reports include expected-random comparison, per-consortium policy curves, and
  confirmatory decision block,
- all launch scripts refuse to start without `CONFIRM_LONG_GPU_RUN=yes`.

Not yet official:

- full single-pass feature export across all folds,
- full ensemble/TTA feature export across all folds,
- final default-bootstrap official report,
- final paper-level literature review.

The current v2 proxy intentionally fails official acceptance because it lacks the launch
manifest and watcher status from full feature export and has only 2 nonconstant deployable
cheap features. Official promotion still requires the export run to provide at least 10
nonconstant deployable cheap features and pass `official_acceptance.json`.

## Next Gate

If Min approves CARE-Seg:

1. Keep GPU training stopped; run feature-export inference only.
2. Run CPU preflight:
   `python experiments/exp01_loco_segmentation_robust/scripts/preflight_careseg_feature_export.py`.
3. Export cheap single-pass features:
   `resunet_ds_singlepass_uncertainty_export_v1`.
4. Export expensive ensemble-TTA features:
   `resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1`.
5. Run strict CARE-Seg policy analysis with default bootstrap.
6. Promote to locked exp02 only if the official feature-export report passes the
   confirmatory rule above.

If Min does not approve CARE-Seg:

- Freeze exp01 as a completed segmentation sweep.
- Do not run another generic segmentation loss, consistency, or distillation experiment.
