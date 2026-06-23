# B1 Autoresearch Baseline Ladder

## Current Goal

Build the strongest defensible scratch segmentation baseline before training
G-SURE reliability models.

This ladder is performance-oriented, but every step must preserve:

- official subject-level LOCO split,
- train-only mask-based patch sampling,
- full-volume sliding-window validation/test inference,
- no pretrained weights unless a separate baseline is explicitly approved,
- no held-out mask access for crop/tile placement.

## Primary Baseline

`B1_plain_3d_unet_loco`

- Model: 3D U-Net, random initialization.
- Architecture option: `unet3d` by default; `resunet3d` is implemented as a
  later structure variant after smoke/full-fit gates are satisfied.
- Loss option: `dice_bce` by default; `dice_focal` and `dice_tversky` are
  implemented as later controlled loss variants.
- Input: `[T1, T1ce, T2, FLAIR]`.
- Target: `selected_mask > 0`.
- Training: patch-based, foreground-biased train patches.
- Inference: full-volume sliding-window probability assembly.
- Fold: one held-out consortium at a time.

## Autoresearch Ladder

| stage | experiment | purpose | decision rule |
|---|---|---|---|
| B1.0 | GPU preview, `160x192x160` vs `192x224x160` | verify bf16 memory, loader, forward/backward, full-volume assembly | choose feasible patch shape by stability/memory, not Dice |
| B1.1 | scratch U-Net smoke, one LOCO fold | confirm loss decreases and checkpoints/logging are safe | continue only if masks are non-degenerate and inference assembles |
| B1.2 | B1 scratch OOF, all LOCO folds | produce first held-out segmentation maps | report per-consortium Dice and failure maps |
| B1.3 | loss variants | Dice+BCE vs Dice+Focal/Tversky | keep only if held-out OOF improves without degenerate false positives |
| B1.4 | capacity variants | base channels/depth and compact ResUNet | keep only if improves worst-consortium metrics, not only mean Dice |
| B1.5 | augmentation variants | spatial/intensity augmentation strength | keep only if cross-consortium robustness improves |
| B2 | TTA uncertainty | baseline reliability from segmentation stochasticity | compare failure detection and voxel-error localization |
| B3 | small ensemble | stronger uncertainty baseline | use only if B2 leaves room and compute is justified |
| B4+ | reliability heads / G-SURE | train grounding/reliability models from OOF errors | allowed only after B1/B2 OOF artifacts exist |

## What Counts as Improvement

Primary:

- held-out consortium Dice distribution,
- worst-consortium Dice,
- Dice <= 0.8 failure rate,
- full-volume error maps suitable for reliability labels.

Secondary:

- surface metrics if implementation is reviewed,
- uncertainty-to-error AUROC/AUPRC after OOF predictions exist,
- lesion-size-stratified robustness.

Do not select models using held-out Dice during GPU preview. Preview is only for
runtime and data-flow feasibility.

## Stop Rules

Stop or redesign before G-SURE if:

- any held-out consortium produces degenerate masks,
- full-volume assembly fails or silently crops,
- reliability/failure prediction is solved by lesion volume alone,
- the strongest scratch/TTA baseline leaves no measurable room for a method
  contribution.

## Current Implementation Artifact

`research_gsure/03_baselines/scripts/train_b1_segmentation.py`

Capabilities now present:

- official LOCO manifest loading,
- train/test leakage-group validation,
- RAS canonical NIfTI loading and affine/spacing/orientation checks,
- foreground-preserving per-volume normalization,
- train-only foreground-biased patch sampling,
- scratch 3D U-Net,
- compact scratch 3D ResUNet option,
- Dice+BCE / Dice+Focal / Dice+Tversky loss options,
- bf16 autocast on CUDA,
- shape-based sliding-window assembly,
- smoke/fit checkpoint writing,
- checkpoint-based held-out probability-map prediction,
- OOF prediction manifest writing,
- CPU synthetic self-test.

OOF segmentation evaluator:

- `research_gsure/03_baselines/scripts/evaluate_b1_segmentation_predictions.py`
- CPU-only; loads validated prediction probability maps and target masks.
- Computes per-subject and grouped Dice, IoU, precision, recall, volume ratio,
  `Dice <= 0.8` failure rate, lesion-size bins, and worst-consortium guard
  metrics.
- Uses the predeclared per-row `threshold_value` from the prediction manifest;
  it does not tune thresholds on held-out data.

Post-OOF evaluation command planner:

- `research_gsure/03_baselines/scripts/plan_b1_evaluation_commands.py`
- CPU-only; emits metadata validation, artifact validation, and combined
  segmentation evaluation commands for all LOCO prediction manifests.
- Blocks evaluation planning when expected prediction manifests are absent.

Variant leaderboard/ranker:

- `research_gsure/03_baselines/scripts/rank_b1_segmentation_variants.py`
- CPU-only; consumes segmentation evaluator summary JSON files.
- Ranks eligible variants by worst-consortium mean Dice first, then overall
  mean Dice, then lower `Dice <= 0.8` failure rate.
- This is the selection guard for loss/architecture/augmentation variants so
  pooled mean Dice alone cannot choose the next model.

Variant promotion decision:

- `research_gsure/03_baselines/scripts/decide_b1_variant_promotion.py`
- CPU-only; consumes a variant leaderboard JSON and applies explicit promotion
  thresholds against the primary B1A baseline.
- Current plan:
  `research_gsure/03_baselines/B1_VARIANT_PROMOTION_DECISION_PLAN.md`
- Promotion requires worst-consortium Dice improvement, not pooled mean Dice
  alone.

Variant ladder planner:

- `research_gsure/03_baselines/scripts/plan_b1_variant_ladder.py`
- CPU-only; emits the staged baseline/loss/architecture/capacity variant
  registry and the command-plan generation sequence.
- Blocks later variants conceptually until the primary scratch baseline has
  complete OOF segmentation metrics.
- Keeps variant identifiers capacity-aware (`architecture`, `loss`,
  `base_channels`, `depth`, `seed`) so model IDs cannot collide across capacity
  experiments.

Latest generated variant plan:

- `research_gsure/03_baselines/B1_VARIANT_LADDER_PLAN_20260623_080158.md`

Status/gate checker:

- `research_gsure/03_baselines/scripts/check_b1_autoresearch_status.py`
- CPU-only; does not train, infer, write probability maps, or approve GPU work.
- Reports whether the current B1 state is blocked, ready for smoke approval,
  ready for full-fit approval, ready for prediction approval, ready for CPU
  evaluation, or ready for leaderboard ranking after validated metrics.

Next-action controller:

- `research_gsure/03_baselines/scripts/plan_b1_next_action.py`
- CPU-only; combines the status checker with the latest command-plan artifacts
  and emits exactly one recommended next action.
- Lists the active transition guard script for post-smoke, post-fit,
  post-prediction, and post-evaluation states so Autoresearch does not jump
  straight from artifacts to later decisions.
- Current latest packet:
  `research_gsure/03_baselines/B1_NEXT_ACTION_20260623_091123.md`
- This is the preferred first file to inspect at the start of a B1
  Autoresearch session.

Post-smoke transition guard:

- `research_gsure/03_baselines/scripts/plan_b1_post_smoke_transition.py`
- CPU-only; validates a completed B1A smoke output, confirms the status checker
  has advanced to `smoke_passed_ready_for_full_fit_approval`, and generates the
  full-fit approval packet only when the smoke gate is truly passed.
- Blocks if the smoke directory is missing, if the smoke validator fails, if
  runtime binding is not GPU4, or if the generated full-fit plan does not show
  exactly four GPU4 fit commands.
- This is the preferred command immediately after a smoke run and before any
  full LOCO fit approval request.

Full-fit validator:

- `research_gsure/03_baselines/scripts/validate_b1_fit_results.py`
- CPU-only; validates all four B1A LOCO fit artifacts before any held-out
  prediction command is allowed.
- Requires the expected config, scratch initialization, GPU4 runtime binding,
  finite train losses, finite validation Dice, no prediction-like artifacts,
  and `checkpoint_last.pt`/`fit_summary.json`/`training_log.jsonl`.
- The expected architecture/loss/capacity/seed can be overridden for later B1
  variants, so the validator is no longer locked to the first B1A config.
- The full-fit planner must use this validator, not only
  `decision.smoke_passed`, before marking fit commands as passed.

Post-fit transition guard:

- `research_gsure/03_baselines/scripts/plan_b1_post_fit_transition.py`
- CPU-only; validates all four full-fit artifacts, confirms the status checker
  has advanced to `fit_checkpoints_present_ready_for_prediction_approval`, and
  generates the held-out prediction approval packet only when the fit gate is
  truly passed.
- Blocks if any fit directory is missing, if `validate_b1_fit_results.py`
  fails, if runtime binding is not GPU4, or if the generated prediction plan
  does not show one GPU4 prediction command per held-out consortium.
- This is the preferred command immediately after all four full-fit commands
  finish and before any held-out prediction approval request.

GPU4 guard:

- `train_b1_segmentation.py` refuses CUDA execution unless
  `CUDA_VISIBLE_DEVICES=4`.
- Smoke, full-fit, and prediction planners all default to GPU 4 and reject
  any other `--gpu` value.
- Smoke and fit validators require runtime summaries to report
  `cuda_visible_devices=4` and `fixed_cuda_visible_devices_required=4`.
- Prediction planning validates fit artifacts against the requested
  architecture/loss/capacity/seed before allowing held-out inference plans.

Evaluation validator:

- `research_gsure/03_baselines/scripts/validate_b1_evaluation_results.py`
- CPU-only; validates metric outputs before any leaderboard ranking or variant
  promotion.
- Requires all expected official LOCO test rows, all consortium summary rows,
  finite Dice/failure metrics, matching `selection_guard`, no held-out threshold
  tuning, and per-subject CSV consistency.

Post-evaluation transition guard:

- `research_gsure/03_baselines/scripts/plan_b1_post_evaluation_transition.py`
- CPU-only; validates the evaluation summary, confirms the status checker has
  advanced to `b1_evaluation_valid_ready_for_leaderboard`, and generates
  leaderboard ranking plus promotion-decision commands only after those checks
  pass.
- Blocks if the metric summary is missing or invalid, if official LOCO
  consortium coverage is incomplete, if per-subject/summary CSV consistency
  fails, or if the status checker is still before the validated-evaluation
  stage.
- This is the preferred command immediately after CPU evaluation finishes and
  before any leaderboard ranking or variant-promotion decision.

Post-prediction transition guard:

- `research_gsure/03_baselines/scripts/plan_b1_post_prediction_transition.py`
- CPU-only; validates all held-out prediction manifests against the official
  split, checks referenced probability/target NIfTI geometry and value ranges,
  confirms the status checker has advanced to `b1_oof_prediction_manifests_present`,
  and generates CPU evaluation commands only after those checks pass.
- Blocks if any manifest is missing, if schema/split/file validation fails, if
  NIfTI artifact validation fails, or if the generated evaluation plan lacks
  manifest validation, artifact validation, metric evaluation, and
  post-evaluation validation commands.
- This is the preferred command immediately after all four prediction manifests
  are written and before any segmentation metric evaluation.

Plan-chain validator:

- `research_gsure/03_baselines/scripts/validate_b1_plan_chain.py`
- CPU-only; verifies the B1A smoke/full-fit/predict/evaluation plan artifacts
  point to one consistent run prefix and expected output paths.
- Current latest report:
  `research_gsure/03_baselines/B1_PLAN_CHAIN_VALIDATION_20260623_084634.md`

Current status:

- CPU compile/self-test passed.
- Actual NIfTI load-one dry-run passed for UCSD held-out fold.
- GPU preview passed for both `160x192x160@0.50` and `192x224x160@0.50`
  on GPU 4.
- `192x224x160@0.50` is recommended for the first B1 smoke training command.
- Smoke training mode is implemented but has not been executed.
- Latest GPU4 smoke preflight:
  `research_gsure/03_baselines/B1A_SMOKE_PREFLIGHT_20260623_085000_gpu4_fixed.md`.
- Fit mode is implemented for post-smoke fold checkpoints, but it must not be
  executed until smoke output passes `validate_b1_smoke_result.py`.
- Full-fit mode writes `fit_summary.json` alongside `checkpoint_last.pt`; all
  four folds must pass `validate_b1_fit_results.py` before held-out prediction
  commands should run.
- Current B1A full-fit commands are recorded in
  `research_gsure/03_baselines/B1_FULL_FIT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_fit.md`.
- Predict mode is implemented for post-fit held-out full-volume probability maps
  and OOF prediction manifests, but it has not been run because no full-fit
  checkpoint exists yet.
- Current B1A held-out prediction commands and per-fold manifest validation
  commands are recorded in
  `research_gsure/03_baselines/B1_PREDICT_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_predict.md`.
- Current B1A evaluation commands and post-evaluation validation command are
  recorded in
  `research_gsure/03_baselines/B1_EVALUATION_COMMAND_PLAN_20260623_080846_b1a_unet3d_dice_bce_bc16_d4_eval.md`.
