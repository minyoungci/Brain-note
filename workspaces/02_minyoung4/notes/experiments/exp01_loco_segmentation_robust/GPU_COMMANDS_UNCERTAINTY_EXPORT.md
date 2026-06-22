# GPU Command Preview: Uncertainty Feature Export

Status: preview only. Do not run unless Min explicitly approves GPU use again.

Purpose:

- Re-run inference from completed exp01 checkpoints.
- Export subject-level uncertainty/disagreement features.
- No new training.
- No raw/shared data mutation.

Guard:

- Launchers refuse to run unless `CONFIRM_LONG_GPU_RUN=yes` is set.
- Launchers refuse to overwrite existing fold/report outputs unless `ALLOW_OVERWRITE=yes`
  is set. Prefer a new run name instead of overwrite.
- They use `setsid nohup` and write per-fold `pid.txt`, `nohup.log`, and `stderr.log`.
- The one-shot pipeline writes
  `analysis/careseg_policy_uncertainty_export_v1/careseg_feature_export_launch_manifest.json`
  before launching fold jobs; preflight refuses to overwrite this manifest unless
  `ALLOW_OVERWRITE=yes` is set.

## 0. CPU preflight before approval

Run this combined gate before any approved GPU export:

```bash
python experiments/exp01_loco_segmentation_robust/scripts/validate_careseg_pre_gpu_gate.py \
  --json-out /tmp/minyoung4_careseg_pre_gpu_gate.json
```

It must return `ok=true`.
The gate also checks that no active GPU process belongs to `/home/vlm/minyoung4` or exp01
before any new launch is approved, and verifies that proxy analysis cannot be promoted to a
locked-exp02 memo. Malformed/partial official-acceptance artifacts are also expected to fail
closed. It also runs CPU watcher success/failure smokes to verify that status JSON records
both normal completion and induced analysis failure.

For lower-level debugging, the underlying preflight command is:

Run this before any approved GPU export. It checks source fold checkpoints/metadata,
ensemble compatibility, output overwrite risk, and the official CARE-Seg decision config.

```bash
python experiments/exp01_loco_segmentation_robust/scripts/preflight_careseg_feature_export.py \
  --source-run-a resunet_ds_dice_bce_loco_full_v1_sharedcache \
  --source-run-b resunet_ds_tta_distill_loco_full_v1_sharedcache \
  --cheap-out-run resunet_ds_singlepass_uncertainty_export_v1 \
  --expensive-out-run resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1 \
  --analysis-out-dir experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1 \
  --expected-n 1617 \
  --primary-policy loco_cheap_failure_logistic \
  --primary-budget 0.30 \
  --support-budget 0.50 \
  --hard-folds UCSD-PTGBM,MU-Glioma-Post
```

## 1. Cheap ResUNet-DS single-pass feature export

This is the gate input for CARE-Seg. It must stay single-pass; otherwise the risk gate would
already be using expensive TTA compute.

## 1a. Preferred guarded one-shot launch after approval

This runs the CPU preflight, launches cheap export, launches expensive export, and launches
the CARE-Seg watcher. It still refuses to run unless `CONFIRM_LONG_GPU_RUN=yes` is set.

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
PRIMARY_POLICY=loco_cheap_failure_logistic \
PRIMARY_BUDGET=0.30 \
SUPPORT_BUDGET=0.50 \
HARD_FOLDS=UCSD-PTGBM,MU-Glioma-Post \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_careseg_feature_export_pipeline.sh
```

The separate commands below are equivalent fallbacks if the one-shot launcher is not used.

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_uncertainty_export_tta_all_folds.sh \
  resunet_ds_dice_bce_loco_full_v1_sharedcache \
  resunet_ds_singlepass_uncertainty_export_v1 \
  none
```

Expected outputs:

- `runs/resunet_ds_singlepass_uncertainty_export_v1/outer_<fold>/test_predictions.csv`
- `runs/resunet_ds_singlepass_uncertainty_export_v1/outer_<fold>/val_predictions.csv`

Expected new columns include:

- `n_prob_samples`
- `near_threshold_frac`
- `entropy_mean_all`
- `prob_std_mean_all`
- `vote_disagreement_mean_all`

For this cheap run, `n_prob_samples` should be 1 and TTA disagreement summaries should be
zero or near-zero. This is expected.

## 2. Expensive two-model ensemble all-flip TTA feature export

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_uncertainty_export_ensemble_tta_all_folds.sh \
  resunet_ds_dice_bce_loco_full_v1_sharedcache \
  resunet_ds_tta_distill_loco_full_v1_sharedcache \
  resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1 \
  all
```

Expected outputs:

- `runs/resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1/outer_<fold>/test_predictions.csv`
- `runs/resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1/outer_<fold>/val_predictions.csv`

## 3. Optional one-model all-flip TTA export

This is not a cheap gate input. It can be used as an intermediate escalation path or
diagnostic comparator.

```bash
CONFIRM_LONG_GPU_RUN=yes \
GPU_UCSD=2 GPU_MU=3 GPU_UPENN=4 GPU_UTSW=2 \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_uncertainty_export_tta_all_folds.sh \
  resunet_ds_dice_bce_loco_full_v1_sharedcache \
  resunet_ds_tta_all_uncertainty_export_v1 \
  all
```

## 4. Post-export checks

After approved runs finish:

```bash
python experiments/exp01_loco_segmentation_robust/scripts/summarize_loco_run.py \
  --run-root experiments/exp01_loco_segmentation_robust/runs/resunet_ds_singlepass_uncertainty_export_v1

python experiments/exp01_loco_segmentation_robust/scripts/summarize_loco_run.py \
  --run-root experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1
```

Then build the risk-policy analysis using the exported feature columns:

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
  --min-cheap-feature-count 10 \
  --primary-policy loco_cheap_failure_logistic \
  --primary-budget 0.30 \
  --support-budget 0.50 \
  --hard-folds UCSD-PTGBM,MU-Glioma-Post
```

## 5. Optional watcher

This watcher can be launched after the two approved export launchers. It polls both run
directories, summarizes them when complete, runs the strict CARE-Seg policy analysis, and
writes `official_acceptance.json`. If the one-shot launcher was not used, this watcher
launcher writes `careseg_feature_export_launch_manifest.json` before starting the watcher.
If summarization, policy analysis, or official acceptance fails, the watcher writes
`failure=true`, `failure_stage`, and `failure_reason` to `watch_careseg_status.json` before
exiting nonzero.

```bash
CONFIRM_LONG_GPU_RUN=yes \
PRIMARY_POLICY=loco_cheap_failure_logistic \
PRIMARY_BUDGET=0.30 \
SUPPORT_BUDGET=0.50 \
HARD_FOLDS=UCSD-PTGBM,MU-Glioma-Post \
bash experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_careseg_export_watcher.sh \
  resunet_ds_singlepass_uncertainty_export_v1 \
  resunet_ds_tta_distill_ensemble_tta_all_uncertainty_export_v1 \
  experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1
```

Expected outputs:

- `analysis/careseg_policy_uncertainty_export_v1/careseg_feature_export_launch_manifest.json`
- `analysis/careseg_policy_uncertainty_export_v1/watch_careseg_status.json`
- `analysis/careseg_policy_uncertainty_export_v1/summary.json`
- `analysis/careseg_policy_uncertainty_export_v1/report.md`
- `analysis/careseg_policy_uncertainty_export_v1/policy_curve.csv`
- `analysis/careseg_policy_uncertainty_export_v1/per_dataset_policy_curve.csv`
- `analysis/careseg_policy_uncertainty_export_v1/subject_policy_scores.csv`
- `analysis/careseg_policy_uncertainty_export_v1/official_acceptance.json`

## 6. Official acceptance validator

The watcher writes this automatically. Re-run manually only if inspecting or regenerating
the acceptance decision:

```bash
python experiments/exp01_loco_segmentation_robust/scripts/validate_careseg_official_acceptance.py \
  --analysis-dir experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1 \
  --expected-n 1617 \
  --min-feature-count 10 \
  --primary-policy loco_cheap_failure_logistic \
  --primary-budget 0.30 \
  --support-budget 0.50 \
  --json-out experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1/official_acceptance.json
```

This validator must return `go=true`. Proxy reports and smoke reports are expected to fail.

## 7. Promotion guard

Only after official acceptance returns `go=true`, create the locked-exp02 memo:

```bash
python experiments/exp01_loco_segmentation_robust/scripts/promote_careseg_if_accepted.py \
  --analysis-dir experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_uncertainty_export_v1 \
  --out-md docs/context/careseg_locked_exp02.md
```

This command refuses to write the lock memo unless official acceptance passes.
