# SCRATCHPAD — Decision Log (handoff only)

> 새 세션 인계용 decision log. 긴 연구 노트 아님. 상세는 링크 문서 참조.
> Updated: 2026-06-20

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
  - final test performance is **pending**; do not claim improvement until watcher comparisons exist.

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
