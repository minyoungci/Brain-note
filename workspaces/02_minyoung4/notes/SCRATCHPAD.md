# SCRATCHPAD — Decision Log (handoff only)

> 새 세션 인계용 decision log. 긴 연구 노트 아님. 상세는 링크 문서 참조.
> Updated: 2026-06-22

## 2026-06-22 pre-launch workspace override

- Earlier filesystem state after context transition: `EXP_flag/`, `experiments/`,
  `src/`, `configs/`, and `tests/` were **absent** from `/home/vlm/minyoung4`.
- `nvidia-smi -i 2,3,4` showed **no running processes** at 2026-06-22 02:01 UTC.
- Therefore older `EXP_flag/*` entries below are **historical handoff notes only** and must
  not be treated as current-file-authoritative evidence or active jobs.
- Active guardrail remains `AGENTS.md`: previous `EXP_flag/*` results are historical only.
- The current active experiment is the fresh exp01 run recorded below.

## 2026-06-22 stop-state after exp01 segmentation sweep

- Min requested stopping GPU training because the current direction was not producing a
  strong enough research result.
- Verified active GPU processes: none belonged to `/home/vlm/minyoung4` or exp01. Existing
  GPU jobs belonged to other workspaces and were not touched.
- exp01 current best artifact remains:
  `resunet_ds_tta_distill_ensemble_tta_all_v1`.
  - mean Dice 0.892775.
  - delta vs standard Dice+BCE U-Net: +0.008498, CI95 [+0.005960, +0.011038].
- Main limitation: best result depends on two-model all-flip TTA; single-pass distillation
  and consistency variants did not preserve the gain.
- Generated final non-GPU method summary:
  `experiments/exp01_loco_segmentation_robust/METHOD_REPORT.md`.
- Added CPU-only failure/risk audit:
  `experiments/exp01_loco_segmentation_robust/analysis/failure_risk_audit_v1/report.md`.
  - best Dice <= 0.8 is predictable from existing subject-level prediction signals:
    LOCO OOF AUC 0.923800, AP 0.662324.
  - selective escalation from single-pass ResUNet-DS to full ensemble-TTA for the highest-risk
    30% recovers 59.6717% of the full best-artifact gain.
- Added stricter CPU-only selective-compute policy prototype:
  `experiments/exp01_loco_segmentation_robust/analysis/selective_compute_policy_v1/report.md`.
  - cheap gate uses only single-pass ResUNet predicted volume.
  - best cheap 30% escalation policy reaches mean Dice 0.890627 and recovers 60.1458% of
    full best-artifact gain.
  - gain-regression ranking underperforms; failure-risk ranking is the more plausible
    method direction.
- Drafted exp02 compute-aware reliability plan:
  `docs/context/compute_aware_reliability_exp02_plan.md`.
- Added optional uncertainty/disagreement export, disabled by default:
  - `scripts/uncertainty_features.py`
  - `scripts/eval_tta_loco.py --export-uncertainty`
  - `scripts/eval_ensemble_tta_loco.py --export-uncertainty`
  - CPU smoke passed for cheap single-pass, single-model TTA, and ensemble-TTA export.
- Prepared GPU command preview and guarded nohup launchers for feature-export inference only:
  - `experiments/exp01_loco_segmentation_robust/GPU_COMMANDS_UNCERTAINTY_EXPORT.md`
  - `scripts/launch_nohup_uncertainty_export_tta_all_folds.sh`
  - `scripts/launch_nohup_uncertainty_export_ensemble_tta_all_folds.sh`
  - `bash -n` passed; without `CONFIRM_LONG_GPU_RUN=yes`, both launchers exit 2 and refuse
    to start.
  - Important correction: cheap gate export must use `--tta none`
    (`resunet_ds_singlepass_uncertainty_export_v1`). One-model all-flip TTA export is an
    optional intermediate/diagnostic, not a cheap gate input.
- Added CARE-Seg exported-feature policy analysis harness:
  `scripts/build_careseg_policy_from_exports.py`.
  - First validation caught and fixed two leakage/feature bugs:
    internal failure labels are now excluded from deployable features; uncertainty columns
    are now prefixed and detected.
  - Full existing-prediction regression: N=1617, 30% LOCO cheap-failure gate mean Dice
    0.890608, 59.8003% of full best gain.
    Bootstrap CI: mean Dice [0.883548, 0.897049], delta-vs-cheap [0.001539, 0.004862].
  - Added recoverable-failure probes:
    `loco_recoverable_failure_gain_logistic` and
    `loco_recoverable_failure_nonfailure_logistic`.
    With current predicted-volume-only features, both are no-go versus the simpler
    cheap-failure gate; keep cheap-failure gate as primary for now.
  - Single-pass uncertainty smoke: after excluding constant columns and compute metadata,
    10 nonconstant deployable cheap uncertainty features are detected.
  - Existing-prediction proxy remains much weaker as a feature set: after the same filter it
    has only `cheap_pred_voxels` and `log1p_cheap_pred_voxels`. Treat its GO result as a
    volume-only proxy, not the final CARE-Seg evidence.
  - Added CPU regression script:
    `experiments/exp01_loco_segmentation_robust/scripts/validate_careseg_policy_harness.py`.
    It checks that forbidden/constant/compute-metadata features are excluded, that the
    existing-prediction proxy has exactly 2 deployable features, that the uncertainty smoke
    has exactly 10, and that `--min-cheap-feature-count 11` fails as expected.
  - Added official acceptance validator:
    `experiments/exp01_loco_segmentation_robust/scripts/validate_careseg_official_acceptance.py`.
    It requires the launch manifest, watcher status, N=1617, 4 datasets, >=10 nonconstant
    deployable features, official policy/budget config, positive expected-random CIs, and
    nonnegative MU/UCSD hard-fold deltas. Validation: existing-prediction proxy and
    uncertainty smoke both correctly return `go=false`.
  - `scripts/watch_careseg_exports.py` now runs the official acceptance validator after
    strict CARE-Seg policy analysis and writes `official_acceptance.json`. CPU watcher smoke
    returns exit 0 while recording `official_acceptance_go=false`, as expected for smoke.
    The watcher now also writes machine-readable failure fields (`failure`,
    `failure_stage`, `failure_reason`, optional `failure_returncode`/`failure_cmd`) before
    nonzero exits from summarization, policy analysis, official acceptance, once-incomplete,
    or stopped-incomplete states. CPU induced-failure smoke with an invalid policy exits 6
    and records `failure_stage=careseg_analysis`.
  - `scripts/launch_nohup_careseg_export_watcher.sh` now writes
    `careseg_feature_export_launch_manifest.json` if the one-shot launcher did not already
    create it. `DRY_RUN_MANIFEST_ONLY=yes` validates this path without starting the watcher.
  - Added one-command CPU pre-GPU gate:
    `experiments/exp01_loco_segmentation_robust/scripts/validate_careseg_pre_gpu_gate.py`.
    It runs compile checks, default preflight, policy harness regression, official-acceptance
    negative controls including malformed JSON, no-confirm pipeline refusal, launcher syntax
    checks, and an active GPU-process scan that fails if any `/home/vlm/minyoung4`/exp01 GPU
    job is already running. Validation: `/tmp/minyoung4_careseg_pre_gpu_gate.json` reported
    `ok=true` with `no_active_minyoung4_gpu_jobs.matches=[]`; the gate also checks that the
    promotion guard refuses proxy output and writes no lock memo, and that fallback watcher
    manifest dry-run writes a valid manifest without creating `watch_careseg.pid`. The gate
    now also runs watcher success/failure status smokes: success records
    `analysis_complete=true` and `official_acceptance_go=false`; induced invalid-policy
    failure exits 6 and records `failure_stage=careseg_analysis`.
  - Added promotion guard:
    `experiments/exp01_loco_segmentation_robust/scripts/promote_careseg_if_accepted.py`.
    It refuses to write a locked-exp02 memo unless official acceptance passes. Validation:
    current proxy and smoke outputs both fail promotion and write no lock memo.
  - Strict compute-accounting checks added: cheap path can require `tta=none`,
    `n_prob_samples=1`; expensive path can require `tta=all`, `n_prob_samples=16`.
    A TTA smoke run intentionally fails if forced through the cheap-path `tta=none` check.
  - Added CARE-Seg post-export watcher:
    `scripts/watch_careseg_exports.py` and `scripts/launch_nohup_careseg_export_watcher.sh`.
    CPU `--once` smoke passed. A nonpositive full-gain display issue was found and fixed:
    retained-gain fraction is now empty if the expensive path is not better than cheap.
  - CARE-Seg policy reports now include subject-level bootstrap CIs for mean Dice, low-Dice
    rate, and delta-vs-cheap.
  - Added overwrite guards to feature-export and CARE-Seg watcher launchers:
    existing fold/report outputs are refused by default; `ALLOW_OVERWRITE=yes` is required
    to intentionally overwrite. Validation: no-confirm exits 2, overwrite refusal exits 4.
  - Added the same no-confirm guard to direct lower-level nohup launchers:
    `launch_nohup_fold.sh`, `launch_nohup_watcher.sh`, and
    `launch_nohup_compare_watcher.sh`. Validation: all three exit 2 without
    `CONFIRM_LONG_GPU_RUN=yes`, and no exp01 process was started.
  - Full launcher audit: every `experiments/exp01_loco_segmentation_robust/scripts/launch*.sh`
    passes `bash -n` and exits 2 without `CONFIRM_LONG_GPU_RUN=yes`.
  - CARE-Seg claim/protocol tightened after prior-work spot check:
    novelty must be subject-level compute-adaptive escalation, not generic TTA uncertainty
    or selective segmentation. The exp02 plan now requires paired delta-vs-expected-random
    CI at the same escalation budget; fixed-seed random remains diagnostic only.
  - Updated `build_careseg_policy_from_exports.py` to report paired bootstrap CI for
    `delta_vs_random` and `delta_vs_random_expected`. CPU validation on existing predictions
    with 500 bootstrap replicates: 30% `loco_cheap_failure_logistic` delta vs expected
    random +0.001606 CI95 [+0.000398, +0.002838]; 50% +0.001437 CI95
    [+0.000578, +0.002285].
  - Extended the same harness to write `per_dataset_policy_curve.csv` and an automatic
    `confirmatory_decision` block. New CPU validation in `/tmp` reported GO=True for the
    current existing-prediction proxy, including nonnegative MU/UCSD deltas at 30% and 50%.
  - Parameterized the confirmatory decision with `--primary-policy`, `--primary-budget`,
    `--support-budget`, and `--hard-folds`. Default CPU regression still reports GO=True;
    a non-default smoke (`small_cheap_pred_volume`, 20%/30%, UCSD only) recorded the
    requested config and returned GO=False, confirming the decision block is not hard-coded.
  - Added decision-config validation: oracle/random primary policies, unsupported budgets,
    and unknown hard folds now fail with a concise `ERROR:` message instead of silently
    producing a misleading decision block.
  - Added CARE-Seg lock-candidate memo:
    `docs/context/careseg_lock_candidate_20260622.md`. It recommends CARE-Seg as a
    lock candidate only, not an approved GPU run, and records the current proxy GO evidence.
  - Updated CARE-Seg watcher path to forward decision config flags from the nohup launcher
    (`PRIMARY_POLICY`, `PRIMARY_BUDGET`, `SUPPORT_BUDGET`, `HARD_FOLDS`) into
    `build_careseg_policy_from_exports.py`. CPU watcher smoke confirmed the config appears
    in `summary.json` and all expected report files are produced.
  - Added CPU preflight:
    `experiments/exp01_loco_segmentation_robust/scripts/preflight_careseg_feature_export.py`.
    Default preflight currently reports ok=true for the approved-source-run assumptions;
    invalid policy/budget/fold and existing output markers are rejected.
  - Added guarded one-shot feature-export pipeline launcher:
    `experiments/exp01_loco_segmentation_robust/scripts/launch_nohup_careseg_feature_export_pipeline.sh`.
    It refuses without `CONFIRM_LONG_GPU_RUN=yes`, runs preflight first, then launches cheap
    export, expensive export, and the CARE-Seg watcher via the already-guarded sublaunchers.
    The launcher now exports the resolved decision/GPU config to sublaunchers and writes
    `careseg_feature_export_launch_manifest.json` under the analysis output directory before
    launching fold jobs; preflight treats an existing manifest as an overwrite marker.
  - Added paper-facing experiment plan:
    `docs/context/careseg_paper_experiment_plan_20260622.md`. It defines required tables,
    ablations, figures, official artifacts, acceptance criteria, and rejection criteria.
- Latest CPU-only continuation:
  - Regenerated the existing-prediction CARE-Seg proxy with the current harness:
    `experiments/exp01_loco_segmentation_robust/analysis/careseg_policy_existing_predictions_v2/`.
    It now includes `per_dataset_policy_curve.csv`, expected-random deltas, and a
    `confirmatory_decision` block.
  - v2 proxy decision is GO=True for `loco_cheap_failure_logistic` at 30%/50%:
    30% delta vs expected random +0.001606 CI95 [+0.000387, +0.002820];
    50% +0.001437 CI95 [+0.000559, +0.002323].
  - v2 remains a volume-only proxy with exactly two deployable features:
    `cheap_pred_voxels`, `log1p_cheap_pred_voxels`.
  - Official acceptance correctly rejects v2 (`go=false`) because it lacks full feature
    export launch/watcher artifacts and does not meet the >=10 deployable feature rule.
  - Latest CPU pre-GPU gate:
    `/tmp/minyoung4_careseg_pre_gpu_gate_latest.json` reported `ok=true`.
  - Official acceptance validator was strengthened to independently inspect
    `subject_policy_scores.csv` for row count, unique UID, and actual compute-accounting
    constants: `cheap_tta=none`, `cheap_n_prob_samples=1`, `expensive_tta=all`,
    `expensive_n_prob_samples=16`. Re-validation:
    `/tmp/minyoung4_careseg_pre_gpu_gate_after_compute_guard.json` reported `ok=true`.
  - Official acceptance now also verifies that all listed deployable features exist in
    `subject_policy_scores.csv`, are numeric, and are nonconstant. Added a pre-GPU
    negative-control that creates an otherwise official-looking artifact with wrong cheap
    compute constants; validator rejects it via
    `subject_policy_scores_cheap_tta_constant` and
    `subject_policy_scores_cheap_n_prob_samples_constant`. Re-validation:
    `/tmp/minyoung4_careseg_pre_gpu_gate_feature_compute_negative.json` reported `ok=true`.
  - Added a stricter namespace check: every deployable feature must come from the cheap path
    (`cheap_*` or `log1p_cheap_pred_voxels`). A new pre-GPU negative-control creates an
    otherwise official-looking artifact with `expensive_prob_mean_all` in
    `deployable_features`; validator rejects it via `deployable_features_cheap_path_only`.
    Re-validation:
    `/tmp/minyoung4_careseg_pre_gpu_gate_feature_namespace_negative.json` reported `ok=true`.
- Do not restart GPU training without a new explicit approval and a revised research
  question. The next useful step is research-direction review, not another generic
  segmentation loss run.

## 2026-06-22 fresh exp01 active run

- New current-file-authoritative experiment:
  `experiments/exp01_loco_segmentation_robust/`.
- Purpose: fresh-start 4-channel structural MRI whole-tumor segmentation under LOCO,
  as a robust lesion-representation baseline after molecular IDH/MGMT claims were not
  reliable enough.
- Technical variant currently running:
  compact 3D U-Net + per-volume foreground normalization + train-only augmentation +
  source-balanced sampling + small-lesion weighted focal Tversky/BCE +
  worst-source validation checkpointing + validation-only threshold selection.
- Validation completed before launch:
  `py_compile` OK, shell syntax OK, CPU real-data smoke OK, GPU bf16 smoke OK.
- Initial `tail_source_loco_full_v2_fastheader` was stopped before epoch 0 because each
  fold created its own cache, causing duplicated I/O.
- Launcher was patched to pass a run-level shared cache:
  `--cache-dir runs/<run_name>/shared_cache`.
- Current full run launched with `setsid nohup`:
  `tail_source_loco_full_v3_sharedcache`.
  - UCSD heldout: pid 422235, GPU2.
  - MU heldout: pid 422241, GPU3.
  - UPENN heldout: pid 422249, GPU4.
  - UTSW heldout: pid 422255, GPU2.
  - watcher: pid 515898, detached, summarizes when all folds finish.
- All four fold processes and watcher had `PPID=1`; stderr/watcher.err were 0 at
  verification.
- Cohort locked by the run metadata: N=1617 subjects
  (MU 203, UCSD 178, UPENN 611, UTSW 625).
- Initial check: records/split/metadata/history files exist for all folds; shared cache
  files are being generated; GPU attach verified.
- Early validation confirmed actual training is running:
  - MU heldout epoch 1 val mean Dice 0.8760, worst-source 0.8409.
  - UCSD heldout epoch 1 val mean Dice 0.8500, worst-source 0.8137.
  - UPENN heldout epoch 2 val mean Dice 0.8448, worst-source 0.7904.
  - UTSW heldout epoch 6 val mean Dice 0.8829, worst-source 0.8445.
- Shared cache reached 1617 files, so expensive preprocessing/cache fill is complete.
- Monitor command:
  `python experiments/exp01_loco_segmentation_robust/scripts/monitor_runs.py --run-root experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache`
- Watcher status:
  `experiments/exp01_loco_segmentation_robust/runs/tail_source_loco_full_v3_sharedcache/watch_status.json`.
- Standard comparison baseline launched:
  `standard_dice_bce_loco_full_v1_sharedcache`.
  - UCSD heldout: pid 732617, GPU3.
  - MU heldout: pid 732623, GPU4.
  - UPENN heldout: pid 732629, GPU3.
  - UTSW heldout: pid 732635, GPU4.
  - watcher: pid 736538.
  - Uses the robust run's shared cache path to avoid duplicate preprocessing.
  - Early validation confirmed baseline is training:
    MU epoch 2 val mean 0.8922; UCSD epoch 2 val mean 0.8838;
    UPENN epoch 3 val mean 0.8487; UTSW epoch 4 val mean 0.8797.
- Automatic paired comparison watcher launched:
  `experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_tail_source_v1/`,
  pid 766980. It will run `compare_loco_runs.py` after both run summaries are complete.
- Result: `tail_source_loco_full_v3_sharedcache` is **NO-GO** vs standard Dice+BCE.
  - standard mean Dice 0.884277.
  - focal-Tversky candidate mean Dice 0.878937.
  - paired delta mean Dice -0.005340, CI95 [-0.007761, -0.002890].
  - low-Dice failure rates did not improve.
  - Do not use focal-Tversky candidate as final method claim.
- Next active ablation to run:
  `source_balanced_dice_bce_loco_full_v1_sharedcache` =
  Dice+BCE + source-balanced sampling + worst-source checkpointing.
  - launched with `setsid nohup`.
  - UCSD heldout pid 1790722 GPU2.
  - MU heldout pid 1790728 GPU3.
  - UPENN heldout pid 1790734 GPU4.
  - UTSW heldout pid 1790740 GPU2.
  - watcher pid 1792174.
  - comparison watcher vs standard pid 1792186.
  - initial verification: GPU attach yes, stderr 0, metadata/history created.

## 2026-06-22 exp01 current continuation

- Completed diagnostic: `standard_dice_bce_tta_all_v1`.
  - all-flip TTA over the completed standard Dice+BCE model.
  - summary: `experiments/exp01_loco_segmentation_robust/runs/standard_dice_bce_tta_all_v1/loco_summary/report.md`.
  - comparison: `experiments/exp01_loco_segmentation_robust/comparisons/standard_vs_standard_tta_all_v1/comparison_report.md`.
  - result vs standard: mean Dice 0.886454 vs 0.884277, paired delta +0.002177
    CI95 [+0.000459, +0.003924]. Small positive, not a final method claim.
  - fold deltas: MU +0.008180, UCSD +0.001811, UPENN -0.000367, UTSW +0.002819.
- Implemented and smoke-tested architecture probe:
  - `--arch resunet_ds`: residual SE 3D U-Net with auxiliary deep-supervision heads.
  - CPU smoke: `runs/smoke_resunet_ds_cpu_v1/`.
  - GPU bf16 smoke: `runs/smoke_resunet_ds_gpu_v1/`.
- Active full GPU run:
  `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_dice_bce_loco_full_v1_sharedcache/`.
  - UCSD heldout pid 2668154 GPU3.
  - MU heldout pid 2668160 GPU4.
  - UPENN heldout pid 2668166 GPU3.
  - UTSW heldout pid 2668172 GPU4.
  - watcher pid 2677206.
  - comparison watcher vs standard pid 2677254, output
    `comparisons/standard_vs_resunet_ds_dice_bce_v1/`.
  - completed 4/4 folds with stderr 0.
  - summary: `runs/resunet_ds_dice_bce_loco_full_v1_sharedcache/loco_summary/report.md`.
  - comparison: `comparisons/standard_vs_resunet_ds_dice_bce_v1/comparison_report.md`.
  - result vs standard: mean Dice 0.887385 vs 0.884277, paired delta +0.003108
    CI95 [+0.000509, +0.005785].
  - fold deltas: MU +0.011721, UCSD +0.005077, UPENN +0.003166, UTSW -0.000306.
  - This is the current strongest completed training candidate.
- Completed inference diagnostic:
  `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_tta_all_v1/`.
  - all-flip TTA over the completed ResUNet-DS checkpoints.
  - completed 4/4 folds with stderr 0.
  - summary: `runs/resunet_ds_tta_all_v1/loco_summary/report.md`.
  - comparison vs ResUNet-DS:
    `comparisons/resunet_ds_vs_resunet_ds_tta_all_v1/comparison_report.md`.
    delta +0.002253, CI95 [+0.000740, +0.003781].
  - comparison vs standard:
    `comparisons/standard_vs_resunet_ds_tta_all_v1/comparison_report.md`.
    delta +0.005362, CI95 [+0.002599, +0.007976].
  - Current best performance artifact, but not a single-pass training method.
- Implemented and smoke-tested TTA-inspired single-pass training candidate:
  - `--consistency-mode flip --consistency-weight 0.15`.
  - CPU smoke: `runs/smoke_flip_consistency_cpu_v1/`.
  - GPU bf16 smoke: `runs/smoke_flip_consistency_gpu_v1/`.
- Completed full flip-consistency GPU run:
  `experiments/exp01_loco_segmentation_robust/runs/unet_flip_consistency_loco_full_v1_sharedcache/`.
  - UCSD heldout pid 2902189 GPU2.
  - MU heldout pid 2902200 GPU2.
  - UPENN heldout pid 2902207 GPU2.
  - UTSW heldout pid 2902213 GPU2.
  - watcher pid 2908231.
  - comparison watcher vs standard pid 2908240, output
    `comparisons/standard_vs_flip_consistency_v1/`.
  - initial verification: all fold processes detached with PPID 1, stderr 0, GPU attached.
  - completed 4/4 folds with stderr 0.
  - summary: `runs/unet_flip_consistency_loco_full_v1_sharedcache/loco_summary/report.md`.
  - comparison vs standard:
    `comparisons/standard_vs_flip_consistency_v1/comparison_report.md`.
  - result vs standard: mean Dice 0.882868 vs 0.884277, paired delta -0.001409
    CI95 [-0.004078, +0.001082].
  - This is no-go / neutral-negative. Flip-consistency alone did not transfer the TTA gain
    into the compact U-Net.
- Completed full ResUNet-DS flip-consistency GPU run:
  `experiments/exp01_loco_segmentation_robust/runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache/`.
  - Purpose: test whether the ResUNet-DS architecture and TTA-derived flip consistency
    combine into a single-pass training method.
  - UCSD heldout pid 346798 GPU3.
  - MU heldout pid 346804 GPU4.
  - UPENN heldout pid 346810 GPU3.
  - UTSW heldout pid 346816 GPU4.
  - watcher pid 359296.
  - comparison watchers:
    `comparisons/standard_vs_resunet_ds_flip_consistency_v1/` pid 359303,
    `comparisons/resunet_ds_vs_resunet_ds_flip_consistency_v1/` pid 359326,
    `comparisons/resunet_ds_tta_vs_resunet_ds_flip_consistency_v1/` pid 359612.
  - Validation before launch: launcher `bash -n` OK, `py_compile` OK, CPU real-data smoke OK,
    GPU bf16 smoke OK.
  - completed 4/4 folds with stderr 0.
  - summary: `runs/resunet_ds_flip_consistency_loco_full_v1_sharedcache/loco_summary/report.md`.
  - comparison vs standard:
    `comparisons/standard_vs_resunet_ds_flip_consistency_v1/comparison_report.md`.
    mean Dice 0.883842 vs 0.884277, paired delta -0.000435
    CI95 [-0.003360, +0.002374].
  - comparison vs ResUNet-DS:
    `comparisons/resunet_ds_vs_resunet_ds_flip_consistency_v1/comparison_report.md`.
    paired delta -0.003543, CI95 [-0.005933, -0.001208].
  - comparison vs ResUNet-DS TTA:
    `comparisons/resunet_ds_tta_vs_resunet_ds_flip_consistency_v1/comparison_report.md`.
    paired delta -0.005797, CI95 [-0.007952, -0.003794].
  - Verdict: no-go. Naive train-time flip-consistency does not transfer the TTA gain into
    single-pass training and degrades the best training architecture.
- Implemented next candidate after flip-consistency failure:
  `flip_tta_distill` in `train_segmentation_loco.py`.
  - Mechanism: use detached average of original and flipped predictions as a TTA-style
    soft teacher, and train only the original-view student toward that target.
  - Rationale: inference-time all-flip TTA is positive, but bidirectional consistency is
    negative; distillation is a closer training analogue to TTA averaging.
  - Launcher:
    `scripts/launch_all_nohup_resunet_ds_tta_distill.sh`.
  - CPU real-data smoke passed:
    `runs/smoke_resunet_ds_tta_distill_cpu_v1/outer_UCSD-PTGBM`.
  - GPU full-run command preview:
    `experiments/exp01_loco_segmentation_robust/GPU_COMMANDS_TTA_DISTILL.md`.
  - Full GPU run launched with `setsid nohup` and completed:
    `resunet_ds_tta_distill_loco_full_v1_sharedcache`.
    - UCSD heldout pid 1771374 GPU2.
    - MU heldout pid 1771398 GPU3.
    - UPENN heldout pid 1771418 GPU4.
    - UTSW heldout pid 1771444 GPU2.
    - watcher pid 1777536.
    - comparison watchers:
      `standard_vs_resunet_ds_tta_distill_v1` pid 1777576,
      `resunet_ds_vs_resunet_ds_tta_distill_v1` pid 1777594,
      `resunet_ds_tta_vs_resunet_ds_tta_distill_v1` pid 1777638.
  - Initial verification:
    all fold processes and watchers have PPID 1 / independent sessions, GPU attach verified,
    stderr 0, metadata/split/records/history files created.
  - Final status: all 4 folds completed, stderr 0.
  - summary:
    `runs/resunet_ds_tta_distill_loco_full_v1_sharedcache/loco_summary/report.md`.
  - result vs standard:
    mean Dice 0.885826 vs 0.884277, delta +0.001549,
    CI95 [-0.001405, +0.004473].
  - result vs ResUNet-DS:
    delta -0.001559, CI95 [-0.003975, +0.000881].
  - result vs ResUNet-DS TTA:
    delta -0.003812, CI95 [-0.005958, -0.001663].
  - Fold pattern vs ResUNet-DS:
    MU +0.006838, UCSD +0.005980, UPENN -0.001597, UTSW -0.006396.
  - Verdict: no-go as an overall method, but positive on the hard MU/UCSD folds and
    better than plain flip-consistency. Next direction should be adaptive/source-risk-aware
    use of TTA-derived training signal rather than stronger global consistency.
- Validation-routed selection between ResUNet-DS and TTA-distill failed:
  - val_mean routing mean Dice 0.884913, delta vs ResUNet-DS -0.002472
    CI95 [-0.004099, -0.000982].
  - worst-source routing mean Dice 0.884310, delta vs ResUNet-DS -0.003076
    CI95 [-0.004792, -0.001479].
  - Interpretation: simple validation routing cannot identify the folds where TTA-distill helps.
- TTA-distill with all-flip TTA completed:
  `resunet_ds_tta_distill_tta_all_v1`.
  - mean Dice 0.888930.
  - vs standard: +0.004653, CI95 [+0.001918, +0.007449].
  - vs ResUNet-DS TTA: -0.000709, CI95 [-0.002524, +0.001161].
  - It is positive vs standard but not a new best.
- Implemented and ran probability ensemble TTA:
  `scripts/eval_ensemble_tta_loco.py` and
  `scripts/launch_nohup_ensemble_tta_all_folds.sh`.
  - ensemble sources:
    `resunet_ds_dice_bce_loco_full_v1_sharedcache` +
    `resunet_ds_tta_distill_loco_full_v1_sharedcache`.
  - run: `resunet_ds_tta_distill_ensemble_tta_all_v1`.
  - all 4 folds completed, stderr 0.
  - mean Dice 0.892775.
  - vs previous best ResUNet-DS TTA: +0.003136, CI95 [+0.002044, +0.004342].
  - vs standard: +0.008498, CI95 [+0.005960, +0.011038].
  - Dice <= 0.8 failure reduction vs ResUNet-DS TTA: -0.011750,
    CI95 [-0.018553, -0.005566].
  - Current best performance artifact. It is not single-pass, but it proves complementary
    information between the standard ResUNet-DS and TTA-distilled ResUNet-DS.
- Implemented ensemble-to-student compression:
  - trainer args:
    `--teacher-run-root`, `--teacher-distill-weight`,
    `--teacher-distill-warmup-epochs`, `--teacher-distill-views`.
  - teacher validation checks enforce heldout/target_shape/n_records compatibility.
  - teacher signal averages standard ResUNet-DS and TTA-distilled ResUNet-DS checkpoints
    over original + cycle-flip views during training.
  - launcher:
    `scripts/launch_all_nohup_resunet_ds_ensemble_student.sh`.
  - GPU smoke passed:
    `runs/smoke_resunet_ds_ensemble_student_gpu_v2/outer_UCSD-PTGBM`.
    teacher distill loss finite: 0.317227 on the single smoke step.
- Full ensemble-student run launched with `setsid nohup`:
  `resunet_ds_ensemble_student_loco_full_v1_sharedcache`.
  - UCSD heldout pid 3615286 GPU2.
  - MU heldout pid 3615295 GPU3.
  - UPENN heldout pid 3615374 GPU4.
  - UTSW heldout pid 3615391 GPU2.
  - watcher pid 3615423.
  - comparison watchers:
    `standard_vs_ensemble_student_v1` pid 3615491,
    `resunet_ds_vs_ensemble_student_v1` pid 3615522,
    `ensemble_tta_vs_ensemble_student_v1` pid 3615656.
  - Initial verification:
    all fold processes and watchers have PPID 1 / independent sessions, GPU attach verified,
    stderr 0, metadata/split/records/history files created.
  - First training monitor:
    MU epoch 5, UCSD epoch 3, UPENN epoch 6, UTSW epoch 4; all alive, stderr 0.
    Warmup behavior is correct: pre-warmup folds show teacher loss 0, post-warmup folds
    show small finite teacher distill loss (~5e-4).
  - Final status: all 4 folds completed, stderr 0.
  - mean Dice 0.885765.
  - vs standard: +0.001488, CI95 [-0.001390, +0.004324].
  - vs ResUNet-DS: -0.001620, CI95 [-0.003487, +0.000300].
  - vs ensemble-TTA teacher: -0.007010, CI95 [-0.009016, -0.005096].
  - Verdict: no-go compression. Simple MSE soft-probability distillation from the
    complementary ensemble does not preserve the ensemble-TTA gain as a single-pass model.
- TTA on ensemble-student completed:
  `resunet_ds_ensemble_student_tta_all_v1`.
  - mean Dice 0.892077.
  - vs standard: +0.007800, CI95 [+0.005067, +0.010471].
  - vs ResUNet-DS TTA: +0.002438, CI95 [+0.000792, +0.004210].
  - vs two-model ensemble-TTA: -0.000698, CI95 [-0.002478, +0.001103].
  - Verdict: strong 1-model TTA artifact, but not new best. Useful as a cheaper
    deployment tradeoff; current best remains `resunet_ds_tta_distill_ensemble_tta_all_v1`.
- Validation-selected weighted ensemble completed:
  `resunet_ds_weighted_ensemble_tta_all_v1`.
  - Mechanism: select ResUNet-DS/TTA-distill probability weights and threshold on validation
    subjects only, then apply once to held-out test subjects with all-flip TTA.
  - selected weights by held-out fold:
    MU 0.7/0.3, UCSD 0.4/0.6, UPENN 0.7/0.3, UTSW 0.5/0.5
    for ResUNet-DS/TTA-distill.
  - mean Dice 0.891906.
  - vs standard: +0.007629, CI95 [+0.004949, +0.010257].
  - vs fixed 50:50 ensemble-TTA: -0.000869, CI95 [-0.001551, -0.000396].
  - Verdict: no-go. Validation-selected fold-level weighting overfits/does not generalize
    better than the fixed 50:50 average. Current best remains
    `resunet_ds_tta_distill_ensemble_tta_all_v1`.
- Active follow-up training:
  `resunet_ds_confidence_distill_loco_full_v1_sharedcache`.
  - Purpose: stronger single-pass distillation attempt after simple MSE ensemble-student
    failed.
  - Mechanism: supervised Dice/BCE + teacher ensemble distillation using confidence-weighted
    soft BCE+Dice instead of MSE.
  - Teachers: `resunet_ds_dice_bce_loco_full_v1_sharedcache` and
    `resunet_ds_tta_distill_loco_full_v1_sharedcache`.
  - Teacher views: `single_flip`; weight 0.15; warmup 5 epochs.
  - GPU smoke passed before launch; finite `train_teacher_distill_loss=1.870873`.
  - Full folds launched with `setsid nohup`:
    UCSD pid 1854996 GPU2; MU pid 1855023 GPU3; UPENN pid 1855045 GPU4;
    UTSW pid 1855075 GPU2; watcher pid 1855467.
  - Compare watchers:
    `standard_vs_confidence_distill_v1`, `resunet_ds_vs_confidence_distill_v1`,
    `ensemble_tta_vs_confidence_distill_v1`.
  - Health check 2026-06-22 08:29 UTC:
    all four folds alive, stderr 0, best checkpoints present.
    Teacher loss activated after warmup and is finite
    (e.g. MU epoch 5 `train_teacher_distill_loss=0.078384`;
    UPENN epoch 5 `0.097814`; UTSW epoch 5 `0.086321`).
    Progress: MU 19/30, UCSD 12/30, UPENN 26/30, UTSW 15/30.
    No `loco_summary` or comparison json yet.
  - Final result: completed cleanly, stderr 0, all four fold reports and comparisons written.
    - mean Dice 0.887774.
    - vs standard: +0.003497, CI95 [+0.000801, +0.006272].
    - vs ResUNet-DS: +0.000389, CI95 [-0.001428, +0.002163].
    - vs fixed 50:50 ensemble-TTA: -0.005001, CI95 [-0.006488, -0.003496].
    - Fold deltas vs ResUNet-DS: MU +0.002433, UCSD +0.004306,
      UPENN -0.000652, UTSW -0.000374.
    - Verdict: no-go as a new single-pass method; positive only versus the weaker standard
      baseline. Next cheap check: all-flip TTA on this checkpoint as a possible 1-model
      TTA artifact.
  - All-flip TTA follow-up completed:
    `resunet_ds_confidence_distill_tta_all_v1`.
    - mean Dice 0.890254.
    - vs standard: +0.005977, CI95 [+0.003389, +0.008572].
    - vs ResUNet-DS TTA: +0.000616, CI95 [-0.000852, +0.002120].
    - vs fixed 50:50 ensemble-TTA: -0.002521, CI95 [-0.003665, -0.001373].
    - vs ensemble-student TTA: -0.001823, CI95 [-0.003886, +0.000129].
    - Verdict: positive but not best. One-model compression remains weaker than current
      two-model ensemble-TTA; UCSD improves, but MU/UPENN trade off.
  - Three-model ensemble follow-up completed:
    `resunet_ds_three_model_ensemble_tta_all_v1`.
    - Sources: ResUNet-DS + TTA-distilled ResUNet-DS + confidence-distilled ResUNet-DS.
    - mean Dice 0.892344.
    - vs standard: +0.008067, CI95 [+0.005448, +0.010681].
    - vs fixed two-model ensemble-TTA: -0.000431, CI95 [-0.000940, +0.000089].
    - vs ensemble-student TTA: +0.000268, CI95 [-0.001772, +0.002263].
    - Verdict: no new best. Keep `resunet_ds_tta_distill_ensemble_tta_all_v1`
      as current best artifact; confidence-distilled checkpoint is diagnostic only.

## 현재 결정 (locked)
- 목표 수준: **ACCV-tier CV / medical-vision method paper** (IDH 예측 응용 논문 아님).
- 메인 방법 후보: **CTEC** = lesion-grounded behavioral regularization. **NOT LOCKED / performance-claim stopped for IDH and MGMT.**
  - draft: `docs/context/ctec_method_claim_draft.md`
  - IDH B2/B3 and MGMT B2/B3 ceiling probes are all negative; do **not** promote to exp03 as a molecular prediction performance-improvement method.
- Fork: **A (image-only CTEC) = main method**, **B (image+clinical) = main-table comparator/upper-bound** (appendix 아님).
- brain-age disentanglement(C2)는 novelty 아님 → age-independent / clinical-adjusted **평가축으로만** 사용.
- 제외: C4 IRM/V-REx. 보류: C3 confound-balanced contrastive.

## post-IDH pivot / MGMT status
- Pivot audit: `docs/context/post_idh_pivot_audit.md`
  - best next molecular candidate by static audit was **MGMT methylation prediction**.
  - cohort: N=815, methylated=347, unmethylated=468, all four consortia represented.
  - clinical shortcut floor was weak: age_sex LOCO AUC mean 0.528; age_only 0.522; age_sex_scanner 0.510.
- **MGMT B2 whole-brain Res3DNet proxy ceiling = NO-GO** (2026-06-20).
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B2_res3dnet_proxy/ceiling_probe_mgmt_b2_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B2_res3dnet_proxy/ceiling_probe_mgmt_b2_nested_v1/ceiling_probe/report.md`
  - OOF validation: 3260 rows = 815 outer test + 2445 nested train; fold-internal train/test UID overlap 0; duplicate uid/fold/role/score rows 0; missing p_img/y_true 0.
  - primary result over age_sex: dAUC -0.0057 CI95 (-0.0267, +0.0153), dAUPRC -0.0088 CI95 (-0.0322, +0.0142), dBrier +0.0041 CI95 (-0.00003, +0.0081).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = 0.089).
- **MGMT B3 lesion-ROI/mask-input oracle proxy ceiling = NO-GO** (2026-06-20).
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B3_lesion_roi_resnet_proxy/ceiling_probe_mgmt_b3_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/MGMT_B3_lesion_roi_resnet_proxy/ceiling_probe_mgmt_b3_nested_v1/ceiling_probe/report.md`
  - cohort: clinical subset from image UID set, 800/815 subjects (15 dropped for validated segmentation availability).
  - OOF validation: 3200 rows = 800 outer test + 2400 nested train; fold-internal train/test UID overlap 0; duplicate uid/fold/role/score rows 0; missing p_img/y_true 0.
  - primary result over age_sex: dAUC -0.0131 CI95 (-0.0391, +0.0127), dAUPRC -0.0096 CI95 (-0.0348, +0.0164), dBrier +0.0029 CI95 (-0.0022, +0.0081).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = 0.077).
  - verdict: even a segmentation-dependent lesion-ROI oracle failed to prove clinical-adjusted MGMT imaging value. Molecular prediction performance-improvement is not viable as the main ACCV-tier method claim under the current LOCO protocol.

## post-molecular P2 segmentation pivot
- Molecular performance-improvement is stopped unless a new positive ceiling appears.
- Previous executable track `EXP_flag/P2_01_segmentation_loco_baseline/` disappeared from the
  active workspace after earlier segmentation runs. Treat previous Dice numbers as observed but not
  current-file-authoritative until recovered or reproduced.
- Rebuilt executable track: `EXP_flag/P2_02_segmentation_loco_baseline/`.
  - task: binary whole-tumor segmentation from 4-channel structural MRI.
  - cohort: manifest-based subjects with 4 structural channels + tumor mask; current existence
    count N=1616 (MU 202, UCSD 178, UPENN 611, UTSW 625).
  - split: LOCO by consortium, subject UID `dataset::subject_id`.
  - script: `scripts/train_segmentation_baseline.py`.
  - launcher: `scripts/launch_nohup_segmentation.sh` (`setsid nohup`, append-only run dirs).
  - monitor: `scripts/monitor_nohup_segmentation.sh`.
  - summarizer: `scripts/summarize_loco_segmentation.py`.
  - CPU smoke passed on real NIfTI/mask paths with geometry checks and best-checkpoint test write:
    `runs/smoke_cpu_20260620_v4/outer_UCSD-PTGBM/`.
  - GPU command preview: `EXP_flag/P2_02_segmentation_loco_baseline/GPU_COMMANDS.md`.
  - GPU full folds launched after preview/continuation approval:
    - failed diagnostic run: `seg_unet3d_loco_ucsd_full_v1` stopped at train step 100 because
      UTSW `BT1258/tumorseg_FeTS.nii.gz` had only 2 positive voxels. This was a data-validity
      failure, not OOM.
    - launcher patched to add `--validate-segmentation-in-record-build`, excluding invalid tiny
      masks before train loop.
    - full `v2_validseg` run completed 2026-06-20, all 4 folds finished with stderr empty.
      report: `reports/loco_full_v2_validseg/loco_segmentation_baseline_report.md`.
    - subject-level aggregate: N=1612, mean Dice 0.845830, median 0.888112,
      q10/q25/q75/q90 0.732230 / 0.836842 / 0.916514 / 0.932910.
    - held-out test Dice: MU 0.807285 (n=202), UCSD 0.737953 (n=178),
      UPENN 0.884677 (n=611), UTSW 0.851068 (n=621).
    - worst fold remains UCSD. Low-tail is target-size dependent: mean Dice 0.581 for
      101-500 target voxels, 0.682 for 501-1000, 0.796 for 1000-2500, >0.86 above 2500.
    - next method target: small-lesion/tail robustness + post-treatment/UCSD and
      mask-provenance shift. Do not pitch a generic larger U-Net as the main novelty.
  - status collector: `scripts/collect_segmentation_status.py`; latest output:
    `reports/status_latest.csv` and `reports/status_latest.json`.

## current P3 IDH caution
- `EXP_flag/P3_idh_strong/scripts/train_idh_strong.py` runs MONAI DenseNet121 outer LOCO IDH jobs.
- As currently written, it emits test-only OOF and does not satisfy the nested-OOF
  clinical-adjusted ceiling-probe contract.
- Do not treat P3 as overturning IDH NO-GO unless it is converted to nested OOF and evaluated by
  the locked exp02 ceiling probe.

## P2.03 tail-robust segmentation setup
- New executable track: `EXP_flag/P2_03_tail_robust_segmentation/`.
- Method: same compact 3D U-Net/data/split as P2.02, but training objective is
  size-weighted focal Tversky + BCE:
  `alpha=0.3`, `beta=0.7`, `gamma=1.33`, `size_ref_voxels=2500`,
  `size_weight_exp=0.5`, `size_weight_clip=4.0`.
- Code implemented as optional flags in
  `EXP_flag/P2_02_segmentation_loco_baseline/scripts/train_segmentation_baseline.py`.
  Default remains `--loss-mode dice_bce`, so P2.02 baseline behavior is unchanged by default.
- Validation completed:
  - `python -m py_compile` OK.
  - `bash -n` launcher OK.
  - CPU real-data smoke OK:
    `EXP_flag/P2_03_tail_robust_segmentation/runs/smoke_tail_cpu_20260620/outer_UCSD-PTGBM`.
  - summarizer smoke OK:
    `EXP_flag/P2_03_tail_robust_segmentation/reports/smoke_tail_cpu_20260620/`.
  - synthetic loss backward finite OK.
  - monitor dry-run OK on smoke run.
  - watcher foreground dry-run OK on smoke run.
  - comparison dry-run OK: P2.02 vs itself produced zero deltas in
    `EXP_flag/P2_03_tail_robust_segmentation/reports/compare_dryrun_p202_self/`.
  - bootstrap comparison dry-run OK: P2.02 vs itself produced zero deltas and zero CIs in
    `EXP_flag/P2_03_tail_robust_segmentation/reports/compare_dryrun_p202_self_bootstrap/`.
  - watch/summarize/compare smoke dry-run correctly failed at compare with subject-set mismatch
    (baseline=1612, candidate=4), proving incomplete candidate reports cannot be compared silently:
    `EXP_flag/P2_03_tail_robust_segmentation/reports/watch_compare_dryrun_smoke/watch_compare_state.json`.
  - preflight OK at 2026-06-20T11:09Z:
    `EXP_flag/P2_03_tail_robust_segmentation/reports/preflight_latest.json`.
    GPUs 2/3 free, target run dirs available.
  - launch-all safety OK: refuses without `CONFIRM_LONG_GPU_RUN=yes`.
- GPU full run launched 2026-06-20T11:12Z with `CONFIRM_LONG_GPU_RUN=yes`.
  All 4 folds and watcher are `setsid nohup` processes with PPID 1.
  - UCSD: `seg_tail_tversky_loco_ucsd_full_v1`, pid 2146590, GPU2.
  - MU: `seg_tail_tversky_loco_mu_full_v1`, pid 2146607, GPU3.
  - UPENN: `seg_tail_tversky_loco_upenn_full_v1`, pid 2146628, GPU2.
  - UTSW: `seg_tail_tversky_loco_utsw_full_v1`, pid 2146649, GPU3.
  - watcher: pid 2146672, writes `EXP_flag/P2_03_tail_robust_segmentation/reports/watch_state.json`
    and will summarize to `reports/loco_full_v1/`, then compare to P2.02 in
    `reports/compare_vs_p202_loco_full_v1/`.
  - early check at 2026-06-20T11:24Z: all folds alive, stderr 0, GPU attached
    (~1968 MiB each), metadata/split/loss verified, history and checkpoints created.
    Current early best val Dice: MU 0.8306, UCSD 0.8173, UPENN 0.7877, UTSW 0.8250.

## P2.03 final result / P2.04 active run
- P2.03 full run completed cleanly, but is **not sufficient as the final method claim**.
  - report: `EXP_flag/P2_03_tail_robust_segmentation/reports/loco_full_v1/loco_segmentation_baseline_report.md`
  - comparison: `EXP_flag/P2_03_tail_robust_segmentation/reports/compare_vs_p202_loco_full_v1/comparison_report.md`
  - mean Dice: P2.02 0.845830 -> P2.03 0.847251, paired delta +0.001421,
    CI95 [-0.000652, +0.003571] => not a clear mean-Dice win.
  - low Dice <=0.5 rate improved: delta -0.006824, CI95 [-0.011787, -0.001861].
  - UCSD mean degraded: 0.737953 -> 0.730335, although Dice <=0.5 failures fell 25 -> 19.
  - interpretation: P2.03 is a useful tail-failure ablation, not a strong ACCV method result.
- P2.03 threshold rescan completed.
  - report: `EXP_flag/P2_03_tail_robust_segmentation/reports/loco_full_v1_threshold_rescan/loco_segmentation_baseline_report.md`
  - comparison: `EXP_flag/P2_03_tail_robust_segmentation/reports/compare_vs_p202_loco_full_v1_threshold_rescan/comparison_report.md`
  - extended thresholds selected 0.95 for MU/UCSD/UTSW and 0.8 for UPENN.
  - mean Dice delta +0.001690, CI95 [-0.000420, +0.003848]; low Dice <=0.5 rate still improved.
  - threshold fix does not rescue the method; it exposes calibration/over-segmentation pressure.
- P2.04 active track: `EXP_flag/P2_04_size_calibrated_segmentation/`.
  - method: size-calibrated precision-balanced focal Tversky + soft volume-ratio calibration.
  - goal: keep P2.03 low-tail benefit while recovering precision and avoiding UCSD degradation.
  - training script updated backward-compatibly with `--loss-mode size_calibrated_tversky`; P2.02 default remains `dice_bce`.
  - validation before launch: py_compile OK, bash -n OK, CPU real-data smoke OK, preflight OK, launch-all refusal without `CONFIRM_LONG_GPU_RUN=yes` OK.
  - full GPU run launched 2026-06-20T12:05Z with `CONFIRM_LONG_GPU_RUN=yes`.
    All 4 folds and watcher are `setsid nohup` processes with PPID 1.
    - UCSD: `seg_size_cal_loco_ucsd_full_v1`, pid 3880360, GPU2.
    - MU: `seg_size_cal_loco_mu_full_v1`, pid 3880372, GPU3.
    - UPENN: `seg_size_cal_loco_upenn_full_v1`, pid 3880384, GPU4.
    - UTSW: `seg_size_cal_loco_utsw_full_v1`, pid 3880398, GPU2.
    - watcher: pid 3880405, will summarize to
      `EXP_flag/P2_04_size_calibrated_segmentation/reports/loco_full_v1/`
      and compare against P2.02 in
      `EXP_flag/P2_04_size_calibrated_segmentation/reports/compare_vs_p202_loco_full_v1/`.
  - early health at ~12:10Z: all folds alive, stderr 0, GPU attached (~1968 MiB per process),
    metadata/split/loss verified, train step logs present, loss decreasing.
  - early validation check at ~12:17Z: all folds alive, stderr 0, epoch summaries present.
    Best val Dice so far: MU 0.8315, UCSD 0.8149, UPENN 0.7962, UTSW 0.8148.
    This proves the training/eval loop is working, but is **not** evidence of final test improvement.
  - final P2.04 result: **NO-GO**.
    - report: `EXP_flag/P2_04_size_calibrated_segmentation/reports/loco_full_v1/loco_segmentation_baseline_report.md`
    - comparison: `EXP_flag/P2_04_size_calibrated_segmentation/reports/compare_vs_p202_loco_full_v1/comparison_report.md`
    - mean Dice: 0.840718, delta vs P2.02 = -0.005112, CI95 [-0.007132, -0.003142].
    - UTSW degraded strongly: -0.012465 Dice, CI95 [-0.016253, -0.009026].
    - small lesions degraded: 101-500 vox delta -0.0354, 501-1k delta -0.0175.
    - interpretation: scalar size-calibrated loss balancing over-regularized/failed to transfer; do not use P2.04 as method claim.

## P2.05 checkpoint ensemble result
- New exploratory track: `EXP_flag/P2_05_checkpoint_ensemble/`.
- Method: validation-thresholded probability ensemble of P2.02 baseline + P2.03 tail checkpoint, single-axis flip TTA.
  No training, no raw data mutation. Threshold selected on validation only.
- Run:
  `EXP_flag/P2_05_checkpoint_ensemble/reports/p202_p203_tta_single_v1/`
- Comparison vs P2.02:
  `EXP_flag/P2_05_checkpoint_ensemble/reports/compare_vs_p202_p202_p203_tta_single_v1/comparison_report.md`
- Result vs P2.02: **first statistically positive mean-Dice improvement**.
  - mean Dice 0.845830 -> 0.847901.
  - paired delta Dice +0.002071, CI95 [+0.000767, +0.003392].
  - low Dice <=0.8 rate delta -0.008065, CI95 [-0.014888, -0.001241].
  - low Dice <=0.5 rate delta -0.002481, CI95 [-0.006824, +0.001241].
  - UTSW improved clearly: +0.006870 Dice, CI95 [+0.004977, +0.009137].
  - UCSD remains weak: -0.007023 Dice, CI95 [-0.015298, +0.000156].
- Comparison vs P2.03:
  `EXP_flag/P2_05_checkpoint_ensemble/reports/compare_vs_p203_p202_p203_tta_single_v1/`
  - mean Dice delta +0.000650, CI crosses zero.
  - Dice <=0.8 rate improves, but Dice <=0.5 rate is worse than P2.03.
- Interpretation:
  - P2.05 is the current best performance artifact against P2.02, but ensemble/TTA alone is weak novelty.
  - Strong next direction: distill P2.02/P2.03 complementarity into a single uncertainty/tail-aware model, with explicit UCSD transfer diagnostics.
- P2.05 all-flip TTA result:
  - run: `EXP_flag/P2_05_checkpoint_ensemble/reports/p202_p203_tta_all_v1/`
  - vs P2.02:
    `EXP_flag/P2_05_checkpoint_ensemble/reports/compare_vs_p202_p202_p203_tta_all_v1/comparison_report.md`
  - vs P2.05 single:
    `EXP_flag/P2_05_checkpoint_ensemble/reports/compare_vs_p205_single_p202_p203_tta_all_v1/comparison_report.md`
  - mean Dice 0.849610.
  - delta vs P2.02 +0.003780, CI95 [+0.002435, +0.005146].
  - low Dice <=0.8 rate delta -0.009926, CI95 [-0.017990, -0.002481].
  - delta vs single-axis TTA +0.001709, CI95 [+0.001132, +0.002332].
  - current best performance artifact = P2.05 all-flip TTA ensemble.
  - still weak as novelty alone; use as teacher/upper bound for a stronger method.

## P2.07 validation-routed inference result
- New report-composition track: `EXP_flag/P2_07_validation_routed_inference/`.
- Method: fold-level validation Dice routing between P2.02 baseline and P2.05 all-flip TTA.
  Uses validation Dice only; test labels are not used for routing.
- Run:
  `EXP_flag/P2_07_validation_routed_inference/reports/p202_vs_p205all_val_routed_v1/`
- Routing selected:
  - MU -> P2.02 baseline.
  - UCSD/UPENN/UTSW -> P2.05 all-flip TTA.
- Comparison vs P2.02:
  `EXP_flag/P2_07_validation_routed_inference/reports/compare_vs_p202_p202_vs_p205all_val_routed_v1/comparison_report.md`
  - mean Dice 0.849862.
  - delta +0.004032, CI95 [+0.002854, +0.005238].
  - low Dice <=0.8 rate delta -0.012407, CI95 [-0.019231, -0.005583].
- Comparison vs P2.05 all-TTA:
  `EXP_flag/P2_07_validation_routed_inference/reports/compare_vs_p205all_p202_vs_p205all_val_routed_v1/comparison_report.md`
  - delta +0.000252, CI95 [-0.000338, +0.000925].
- Current best performance artifact = P2.07 validation-routed P2.02/P2.05-all.
  The improvement over P2.05 all-TTA is small/non-significant, so the publishable novelty should not be
  "manual fold routing" itself; it should become validation-calibrated uncertainty/domain routing.

## P2.08/P2.09 follow-up routing/fusion results
- P2.08 subject-level uncertainty router:
  - track: `EXP_flag/P2_08_uncertainty_routed_inference/`.
  - method: fit simple prediction-feature routing rules on validation subjects only, then choose P2.02 vs P2.05 all-TTA per test subject.
  - full GPU/nohup run completed on 2026-06-20; stderr 0.
  - report: `EXP_flag/P2_08_uncertainty_routed_inference/reports/p202_vs_p205all_uncertainty_router_v1/loco_segmentation_baseline_report.md`
  - mean Dice 0.849477.
  - vs P2.02: +0.003646, CI95 [+0.002539, +0.004798].
  - vs P2.05 all-TTA: -0.000134, CI95 [-0.000905, +0.000662].
  - vs P2.07: -0.000386, CI95 [-0.000897, +0.000148].
  - low Dice <=0.5 rate is slightly best (0.032878), but mean Dice does not beat P2.05/P2.07.
  - verdict: useful diagnostic / low-tail hint, **not final method**.
- P2.09 validation-calibrated weighted ensemble:
  - track: `EXP_flag/P2_09_weighted_ensemble_calibration/`.
  - method: validation grid over P2.02/P2.03 probability weight + threshold, then one held-out test evaluation.
  - full GPU/nohup run completed on 2026-06-20; stderr 0.
  - report: `EXP_flag/P2_09_weighted_ensemble_calibration/reports/p202_p203_weighted_tta_all_v1/loco_segmentation_baseline_report.md`
  - mean Dice 0.848405.
  - vs P2.02: +0.002574, CI95 [+0.001014, +0.004089].
  - vs P2.05 all-TTA: -0.001205, CI95 [-0.002126, -0.000303].
  - vs P2.07: -0.001457, CI95 [-0.002600, -0.000447].
  - UCSD degraded badly under validation-selected weighting (0.741227 -> 0.729331).
  - verdict: **NO-GO**. Validation-selected fold weights overfit consortium shift; fixed all-TTA average remains stronger.
- Current best performance artifact remains **P2.07 validation-routed P2.02/P2.05-all**:
  mean Dice 0.849862, delta vs P2.02 +0.004032 CI95 [+0.002854, +0.005238].
  But novelty is still not enough for ACCV as-is.
- Main methodological problem now: validation split inside train consortia does not reliably predict held-out consortium transfer. Next method should explicitly model domain/consortium shift or train a single robust model, not keep tuning validation-only inference calibration.

## P2.10 source-robust segmentation active run
- New training-method track: `EXP_flag/P2_10_source_robust_segmentation/`.
- Motivation: P2.08/P2.09 proved validation-only inference calibration is unstable under held-out consortium shift.
- Method: same compact 3D U-Net and Dice+BCE as P2.02, but:
  - `--train-sampling source_balanced`
  - `--checkpoint-metric worst_dataset_dice`
  - extended validation threshold grid up to 0.95.
- Shared trainer updated backward-compatibly:
  - default remains random sampling + mean Dice checkpointing.
  - new metadata fields: `train_sampling`, `checkpoint_metric`.
  - validation summaries now include `worst_dataset_dice_mean`.
- Validation before launch:
  - `py_compile` OK.
  - `bash -n` OK.
  - CPU real-data smoke OK:
    `EXP_flag/P2_10_source_robust_segmentation/runs/smoke_source_robust_cpu/outer_UCSD-PTGBM/`.
  - smoke summary OK:
    `EXP_flag/P2_10_source_robust_segmentation/reports/smoke_source_robust_cpu/`.
  - preflight OK:
    `EXP_flag/P2_10_source_robust_segmentation/reports/preflight_latest.json`.
- Full GPU run launched 2026-06-20 with `CONFIRM_LONG_GPU_RUN=yes`.
  All 4 folds and watcher are `setsid nohup` processes with PPID 1.
  - UCSD: `seg_source_robust_loco_ucsd_full_v1`, pid 3051880, GPU2.
  - MU: `seg_source_robust_loco_mu_full_v1`, pid 3051884, GPU3.
  - UPENN: `seg_source_robust_loco_upenn_full_v1`, pid 3051888, GPU2.
  - UTSW: `seg_source_robust_loco_utsw_full_v1`, pid 3051892, GPU3.
  - watcher: pid 3051896, will summarize to
    `EXP_flag/P2_10_source_robust_segmentation/reports/loco_full_v1/`
    and compare against P2.02/P2.05-all/P2.07.
- Early health after epoch 0:
  - all folds alive, stderr 0, GPU attached.
  - epoch 0 validation recorded `worst_dataset_dice` path correctly.
  - val Dice / worst-source val Dice:
    - MU heldout: 0.804839 / 0.690881
    - UCSD heldout: 0.812300 / 0.748480
    - UPENN heldout: 0.743711 / 0.681244
    - UTSW heldout: 0.761845 / 0.668778
  - Do not interpret epoch 0 as final performance.
- Status checked 2026-06-20: full GPU run is still active via `setsid nohup`; watcher pid 3051896 is running; stderr bytes are 0 for all folds.
  - Latest monitor snapshot:
    - MU heldout: alive, epoch 17, latest val Dice 0.863764, best 0.868742.
    - UCSD heldout: alive, epoch 17, latest val Dice 0.870941, best-checkpoint mean Dice 0.868572.
    - UPENN heldout: alive, epoch 24, latest val Dice 0.840045, best-checkpoint mean Dice 0.835582.
    - UTSW heldout: alive, epoch 35, latest val Dice 0.853566, best-checkpoint mean Dice 0.858693.
  - Test summaries are not written yet. Do not claim performance until watcher produces
    `EXP_flag/P2_10_source_robust_segmentation/reports/loco_full_v1/` and comparisons against P2.02/P2.05/P2.07.

## P2.11 source-DRO segmentation stopped diagnostic
- New training-method track: `EXP_flag/P2_11_source_dro_segmentation/`.
- Motivation: P2.10 handles source shift with source-balanced sampling and worst-source checkpointing; P2.11 additionally makes source risk part of the training objective.
- Method:
  - same compact 3D U-Net and Dice+BCE as P2.02/P2.10.
  - `--train-sampling source_balanced`
  - `--train-objective source_dro`
  - `--source-dro-eta 0.05`
  - `--checkpoint-metric worst_dataset_dice`
  - extended validation threshold grid up to 0.95.
- Shared trainer updated backward-compatibly:
  - default remains `--train-objective standard`.
  - source-DRO state is logged as `source_dro_q_*` in `history.csv`.
  - P2.10 running processes are unaffected because they already loaded the previous script into memory.
- Validation before launch:
  - `py_compile` OK.
  - `bash -n` OK.
  - CPU real-data smoke OK:
    `EXP_flag/P2_11_source_dro_segmentation/runs/smoke_source_dro_cpu/outer_UCSD-PTGBM/`.
  - smoke summary OK:
    `EXP_flag/P2_11_source_dro_segmentation/reports/smoke_source_dro_cpu/`.
  - preflight OK:
    `EXP_flag/P2_11_source_dro_segmentation/reports/preflight_latest.json`.
- Full GPU run launched 2026-06-20 with `CONFIRM_LONG_GPU_RUN=yes`.
  Uses GPU4 only, to avoid P2.10's active GPU2/3 jobs. All folds and watcher are `setsid nohup` with PPID 1.
  - UCSD: `seg_source_dro_loco_ucsd_full_v1`, pid 3652432, GPU4.
  - MU: `seg_source_dro_loco_mu_full_v1`, pid 3652436, GPU4.
  - UPENN: `seg_source_dro_loco_upenn_full_v1`, pid 3652440, GPU4.
  - UTSW: `seg_source_dro_loco_utsw_full_v1`, pid 3652444, GPU4.
  - watcher: pid 3652448, will summarize to
    `EXP_flag/P2_11_source_dro_segmentation/reports/loco_full_v1/`
    and compare against P2.02/P2.05-all/P2.07, and P2.10 if completed by then.
- Early health after epoch 0:
  - all folds alive, stderr 0, GPU attached.
  - source-DRO q is updating and recorded in history.
  - val Dice / worst-source val Dice:
    - MU heldout: 0.812648 / 0.737407
    - UCSD heldout: 0.799666 / 0.740375
    - UPENN heldout: 0.724674 / 0.678789
    - UTSW heldout: 0.775495 / 0.694032
  - Do not interpret epoch 0 as final performance.
- Updated 2026-06-20: **P2.11 was manually stopped; treat as partial diagnostic / NO-GO, not an active candidate.**
  - reason: early source-DRO q collapse and validation degradation versus P2.10/P2.02 expectations.
  - all fold processes and watcher are stopped; stderr remained empty.
  - latest stopped state:
    - MU: epoch 1, latest val Dice 0.792891, best 0.812648.
    - UCSD: epoch 1, latest val Dice 0.766975, best 0.799666.
    - UPENN: epoch 2, latest val Dice 0.718262, best 0.724674.
    - UTSW: epoch 2, latest val Dice 0.790686, best 0.790686.
  - observed q collapse examples:
    - MU epoch 1 q: UCSD 0.965, UPENN 0.006, UTSW 0.029.
    - UCSD epoch 1 q: MU 0.739, UPENN 0.083, UTSW 0.178.
    - UPENN epoch 2 q: UCSD 0.870, MU 0.101, UTSW 0.029.
    - UTSW epoch 1 q: UCSD 0.828, MU 0.126, UPENN 0.046.
  - implication: current `source_dro_eta=0.05` is too aggressive. If source-DRO is retried, use tempered/clipped q updates or source-balanced training only; do not report P2.11 as a complete run.
- Shared trainer was patched after stopping P2.11 with backward-compatible options for a possible P2.12 retry:
  - `--source-dro-min-q`
  - `--source-dro-mix-uniform`
  - defaults preserve old behavior (`0.0`, `0.0`), so prior runs are not redefined.
  - CPU real-data smoke passed:
    `EXP_flag/P2_11_source_dro_segmentation/runs/smoke_tempered_dro_cpu_20260620/outer_UCSD-PTGBM/`.
  - smoke metadata confirms `source_dro_eta=0.005`, `source_dro_min_q=0.1`,
    `source_dro_mix_uniform=0.05`; history q stayed balanced
    (UPENN 0.500690, UTSW 0.499310 after epoch 0).
  - Do not launch a full tempered-DRO GPU run until P2.10 final test/comparison is known.

## P2.12 tempered source-DRO prepared, launch-gated
- New contingency track: `EXP_flag/P2_12_tempered_source_dro_segmentation/`.
- Purpose: failure-driven P2.11 revision with bounded/mixed q updates, not a blind source-DRO retry.
- Method:
  - same P2.02/P2.10 compact 3D U-Net, Dice+BCE, source-balanced sampling, and `worst_dataset_dice` checkpointing.
  - `--source-dro-eta 0.005`
  - `--source-dro-min-q 0.10`
  - `--source-dro-mix-uniform 0.05`
- Scripts:
  - `scripts/launch_all_nohup_tempered_source_dro.sh`
  - `scripts/launch_nohup_tempered_source_dro.sh`
  - `scripts/launch_nohup_watcher.sh`
  - `scripts/monitor_nohup_tempered_source_dro.sh`
  - `scripts/preflight_tempered_source_dro.py`
  - `scripts/watch_summarize_compare_tempered_source_dro.py`
  - `scripts/run_smoke_cpu.sh`
- Validation completed:
  - Python compile OK for P2.12 preflight/watcher and shared trainer.
  - `bash -n` OK for P2.12 shell scripts.
  - launch-all guard refuses without `CONFIRM_LONG_GPU_RUN=yes`.
  - default preflight OK; GPU4 has enough free memory.
  - CPU real-data smoke OK:
    `EXP_flag/P2_12_tempered_source_dro_segmentation/runs/smoke_tempered_dro_cpu/outer_UCSD-PTGBM/`.
  - smoke history q stayed balanced:
    UPENN 0.500690, UTSW 0.499310 after epoch 0.
- Full launch policy updated:
  - default launch can run as a parallel contingency while P2.10 finishes, because GPU4 is idle and P2.10 still has no final report.
  - watcher compares against P2.10 only if P2.10 final metrics exist; otherwise it records that comparison as skipped.
  - strict gate remains available with `REQUIRE_P210_COMPLETE=yes`.
- Full GPU run launched 2026-06-20 with `CONFIRM_LONG_GPU_RUN=yes` as parallel contingency.
  All folds and watcher are `setsid nohup` processes with PPID 1, using GPU4.
  - UCSD: `seg_tempered_dro_loco_ucsd_full_v1`, pid 73533.
  - MU: `seg_tempered_dro_loco_mu_full_v1`, pid 73537.
  - UPENN: `seg_tempered_dro_loco_upenn_full_v1`, pid 73541.
  - UTSW: `seg_tempered_dro_loco_utsw_full_v1`, pid 73545.
  - watcher: pid 73549, final report target:
    `EXP_flag/P2_12_tempered_source_dro_segmentation/reports/loco_full_v1/`.
  - launch health: all fold processes alive, stderr 0, GPU4 attached (~7.9 GiB used shortly after launch).
  - metadata/splits verified for all 4 folds. Example train/test isolation:
    UCSD heldout has train n=1219 with UCSD=0 and test n=178 with UCSD=178.
  - early q health: UCSD/UPENN fold step 50 q remains near uniform; UTSW step 500 q remains near uniform.
    This addresses the P2.11 q-collapse failure mode at least in early training.
  - Final P2.10 result: **NO-GO as standalone method**.
    - report: `EXP_flag/P2_10_source_robust_segmentation/reports/loco_full_v1/loco_segmentation_baseline_report.md`
    - comparisons: `reports/compare_vs_p202_loco_full_v1/`, `reports/compare_vs_p205all_loco_full_v1/`, `reports/compare_vs_p207_loco_full_v1/`
    - mean Dice 0.845773, essentially equal/slightly below P2.02 0.845830.
    - vs P2.02 delta -0.000057, CI95 [-0.002286, +0.002178].
    - vs P2.05 all delta -0.003837, CI95 [-0.006235, -0.001435].
    - vs P2.07 delta -0.004089, CI95 [-0.006576, -0.001635].
    - fold pattern: MU improved clearly (0.819956 vs P2.07 0.807285), but UCSD/UPENN/UTSW degraded versus P2.05/P2.07.
    - interpretation: source-balanced/worst-source checkpointing is useful as a candidate for MU only, not as a global model.
  - New P2.13 source-risk routed artifact: **current best performance artifact, but still routing/inference-level novelty**.
    - method note: `EXP_flag/P2_13_source_risk_routed_inference/METHOD.md`
    - generic router patch: `EXP_flag/P2_07_validation_routed_inference/scripts/build_validation_routed_report.py` now accepts repeated `--candidate NAME=REPORT_DIR`.
    - compatibility dry run against original P2.07 passed: same routed sources, 1612 subjects, max Dice diff 0.
    - report: `EXP_flag/P2_13_source_risk_routed_inference/reports/p202_p205all_p210_val_routed_v1/loco_segmentation_baseline_report.md`
    - routing: MU -> P2.10; UCSD/UPENN/UTSW -> P2.05 all-TTA.
    - mean Dice 0.851450.
    - vs P2.02 delta +0.005620, CI95 [+0.003894, +0.007465].
    - vs P2.05 all delta +0.001840, CI95 [+0.000869, +0.002946].
    - vs P2.07 delta +0.001588, CI95 [+0.000332, +0.002912].
    - next direct check: after P2.12 finishes, add P2.12 as another candidate to the same validation router.
  - P2.12 still active on GPU4, watcher alive, stderr 0.
    Current validation history:
    - MU epoch 11 latest val mean Dice 0.867045.
    - UCSD epoch 11 latest val mean Dice 0.866361.
    - UPENN epoch 16 latest val mean Dice 0.831599; best-checkpoint mean Dice 0.832619.
    - UTSW epoch 16 latest val mean Dice 0.854007.
  - P2.12 q remains near uniform across active logs:
    all observed q values remain around 0.333 per source; no P2.11-like q collapse so far.
    This confirms the tempered/min-q/mix update is doing what it was designed to do mechanically.
  - No final Dice comparison is available yet for P2.10 or P2.12; keep current best completed result as P2.07.

## P2.06 ensemble distillation active run
- New executable track: `EXP_flag/P2_06_ensemble_distillation/`.
- Method: single compact 3D U-Net student trained with hard mask loss plus P2.02/P2.03 soft teacher ensemble,
  teacher-disagreement weighting, and mild small-target sample weighting.
- Goal: convert P2.05 ensemble/TTA performance artifact into a single-model method with stronger novelty.
- Validation before launch:
  - `python -m py_compile` OK.
  - `bash -n` launch scripts OK.
  - CPU real-data smoke with teacher loading/distillation/eval/checkpoint/test summary OK:
    `EXP_flag/P2_06_ensemble_distillation/runs/smoke_distill_cpu_20260620/outer_UCSD-PTGBM/`.
  - preflight OK:
    `EXP_flag/P2_06_ensemble_distillation/reports/preflight_latest.json`.
  - launch-all safety OK: refuses without `CONFIRM_LONG_GPU_RUN=yes`.
- Full GPU run launched 2026-06-20 with `CONFIRM_LONG_GPU_RUN=yes`.
  All folds and watcher are `setsid nohup` processes with PPID 1.
  - UCSD: `seg_distill_loco_ucsd_full_v1`, pid 2537682, GPU3.
  - MU: `seg_distill_loco_mu_full_v1`, pid 2537708, GPU4.
  - UPENN: `seg_distill_loco_upenn_full_v1`, pid 2537729, GPU3.
  - UTSW: `seg_distill_loco_utsw_full_v1`, pid 2537750, GPU4.
  - watcher: pid 2537775, will summarize to
    `EXP_flag/P2_06_ensemble_distillation/reports/loco_full_v1/`
    and compare against P2.02 and P2.05.
- Early health:
  - all folds alive, GPU attached, stderr 0, train step logs present, loss decreasing.
  - first validation/checkpoint path works. Early best val Dice:
    MU 0.8469, UCSD 0.8376, UPENN 0.8080, UTSW 0.8315.
  - final P2.06 result: **NO-GO as main method**.
    - report: `EXP_flag/P2_06_ensemble_distillation/reports/loco_full_v1/loco_segmentation_baseline_report.md`
    - vs P2.02: `EXP_flag/P2_06_ensemble_distillation/reports/compare_vs_p202_loco_full_v1/comparison_report.md`
    - vs P2.05: `EXP_flag/P2_06_ensemble_distillation/reports/compare_vs_p205_loco_full_v1/comparison_report.md`
    - mean Dice 0.846789.
    - delta vs P2.02 +0.000958, CI95 [-0.000904, +0.002752] => not significant.
    - delta vs P2.05 -0.001112, CI95 [-0.002790, +0.000558].
    - UCSD degraded strongly vs P2.02: -0.017055, CI95 [-0.030041, -0.004979].
  - interpretation: distillation partially transferred complementarity to UPENN/UTSW/MU but amplified UCSD validation-to-test failure. P2.05 remains current best performance artifact.

## exp02 ceiling probe 결과 (locked)
- **B2 Res3DNet proxy ceiling = NO-GO** (2026-06-19).
  - spec: `experiments/exp02_res3dnet_proxy_baseline/CEILING_PROBE_SPEC.md`
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/B2_res3dnet_proxy/ceiling_probe_full_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/B2_res3dnet_proxy/ceiling_probe_full_nested_v1/ceiling_probe/report.md`
  - OOF validation: 5776 rows = 1444 outer test + 4332 nested train; fold/role/score UID duplicates 0; missing image scores 0.
  - primary result over age_sex: dAUC -0.0405 CI95 (-0.0505, -0.0310), dAUPRC -0.0749 CI95 (-0.1064, -0.0447), dBrier +0.0277 CI95 (+0.0174, +0.0380).
  - strata: 40_59 dAUC -0.1575; 60_69 dAUC -0.1792; 70_plus discrimination undefined (0 mutants).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = -0.452).
  - verdict: **do not promote CTEC to exp03 from this B2 evidence**. Pivot or build a materially stronger image baseline before any CTEC performance claim.

- **B3 lesion-ROI/mask-input oracle proxy ceiling = NO-GO** (2026-06-19).
  - purpose: stronger tumor-localized image signal probe after B2 NO-GO. This is **not** the final mask-free method; it uses tumor segmentation at inference as an oracle-style lesion ROI/mask input.
  - full nested OOF: `experiments/exp02_res3dnet_proxy_baseline/runs/B3_lesion_roi_resnet_proxy/ceiling_probe_roi96_nested_v1/image_oof_long.csv`
  - report: `experiments/exp02_res3dnet_proxy_baseline/runs/B3_lesion_roi_resnet_proxy/ceiling_probe_roi96_nested_v1/ceiling_probe/report.md`
  - cohort: clinical subset from image UID set, 1421/1444 subjects (23 dropped for validated segmentation availability).
  - OOF validation: 5684 rows = 1421 outer test + 4263 nested train; fold-internal train/test UID overlap 0; fold/role/score UID duplicates 0; missing image scores 0.
  - primary result over age_sex: dAUC -0.0370 CI95 (-0.0497, -0.0248), dAUPRC -0.0663 CI95 (-0.1092, -0.0260), dBrier +0.0251 CI95 (+0.0137, +0.0363).
  - strata: 40_59 dAUC -0.1185; 60_69 dAUC -0.0723; 70_plus discrimination undefined (0 mutants).
  - diagnostics: no strong brain-age shortcut signature by tau=0.85 (corr image_logit, age = -0.412).
  - verdict: **do not promote CTEC/lesion-grounded IDH performance claim from B3 evidence**. Even an oracle lesion-ROI/mask proxy failed to add clinical-adjusted value over age_sex.

## exp02 implementation notes
  - harness: `scripts/run_ceiling_probe.py` (analysis-only, synthetic self-test 3/3 통과, GPU 없음).
    `p_age_only` LOCO OOF 필수. test-only image OOF는 GO 차단.
  - image runner: `scripts/run_image_baseline.py` (smoke/diagnostic). `draft_first_lexical` full run은 코드가 거부.
    `earliest_numeric` policy, geometry check, bf16 autocast path, deterministic worker seed, full audit CSV 추가됨.
    GPU diagnostic 완료: B2/bf16/96x128x128/augment path 통과. Full-fold raw NIfTI on-the-fly run은 CPU I/O 병목으로 중단;
    `--cache-volumes` run-local tensor cache 추가 및 small GPU cache smoke 통과.
    Full outer-fold B2/96x128x128/bf16/cache jobs 완료:
    UCSD `b2_loco_ucsd_full_96_bf16_cache_v1`, UPENN `b2_loco_upenn_full_96_bf16_cache_v1`,
    UTSW `b2_loco_utsw_full_96_bf16_cache_v1`, MU `b2_loco_mu_full_96_bf16_cache_v1`.
    monitor: `experiments/exp02_res3dnet_proxy_baseline/scripts/monitor_nohup_image_training.sh`.
    outer OOF collector: `scripts/collect_outer_oof.py` (test-only; ceiling GO에는 nested train OOF 필요).
    auto orchestrator log: `runs/B2_res3dnet_proxy/auto_orchestrator_v1/`; outer 4개 완료 후 nested OOF 12개를
    GPU2-5에 자동 launch했고, 완료 시 `build_ceiling_image_oof.py` + `run_ceiling_probe.py`까지 실행 완료.
    Outer 4 folds completed and collected: `runs/B2_res3dnet_proxy/outer_oof_test_only_v1/outer_oof_test_only.csv`
    (test-only, not ceiling-valid). Fold AUC: UCSD 0.591, UPENN 0.844, UTSW 0.732, MU 0.772.
    Nested OOF 12/12 completed. Cohort for this run is conflict-excluded N=1444. Shortcut tau used by report: 0.85.

## 하드 제약
- GPU 실행·장시간 작업은 `nvidia-smi`/cwd/git 상태/command preview 후 Min 승인 필요.
- shared/raw data write/delete/move/rename 금지.
- glioma 데이터는 `docs/context/` 소스 경유 (AD manifest와 별개; CLAUDE.md의 두 manifest는 AD용).

## 검증된 사실 (재확인 불필요)
- `age_only` LOCO AUC `0.890952` — brain-age confound.
- tumor seg coverage **1439/1457 (98.8%)**, 4 consortia 전부.
- age reference frame 사이트별 상이(MU=diagnosis, UPENN=scan, UTSW=imaging, UCSD=fixed). **HARD BLOCKER (미해소)**: MU 진단-스캔 offset max 3.647y 등 사이트 offset이 40/60 경계와 상호작용 → future confirmatory analysis 전 반드시 해소. ("age-bin 보정으로 견고"라고 단정 금지.)
- 활성 agent config home = `/home/jovyan/.claude` (5 agents). `professor`/`pipeline-validator`는 `/home/vlm/.claude`(비활성)라 미등록.
