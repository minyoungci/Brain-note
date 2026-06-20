# P2.03 GPU Command Preview

Do not launch without explicit Min approval.

Preflight:

```bash
cd /home/vlm/minyoung4
python EXP_flag/P2_03_tail_robust_segmentation/scripts/preflight_tail_robust.py \
  --json-out EXP_flag/P2_03_tail_robust_segmentation/reports/preflight_latest.json
```

Single-command launch after approval:

```bash
cd /home/vlm/minyoung4
CONFIRM_LONG_GPU_RUN=yes \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_all_nohup_tail_robust.sh
```

The commands below run the same LOCO protocol as P2.02 but with
`--loss-mode size_weighted_tversky`.

Manual per-fold launch, equivalent to the launch-all script:

```bash
cd /home/vlm/minyoung4

HELDOUT_DATASET=UCSD-PTGBM GPU=2 RUN_ID=seg_tail_tversky_loco_ucsd_full_v1 \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_nohup_tail_robust.sh

HELDOUT_DATASET=MU-Glioma-Post GPU=3 RUN_ID=seg_tail_tversky_loco_mu_full_v1 \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_nohup_tail_robust.sh

HELDOUT_DATASET=UPENN-GBM GPU=2 RUN_ID=seg_tail_tversky_loco_upenn_full_v1 \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_nohup_tail_robust.sh

HELDOUT_DATASET=UTSW GPU=3 RUN_ID=seg_tail_tversky_loco_utsw_full_v1 \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_nohup_tail_robust.sh
```

Manual watcher launch after the four folds are started:

```bash
cd /home/vlm/minyoung4
POLL_SECONDS=300 FINAL_DIR_NAME=loco_full_v1 \
  COMPARE_DIR_NAME=compare_vs_p202_loco_full_v1 BOOTSTRAP_ITERS=5000 \
  bash EXP_flag/P2_03_tail_robust_segmentation/scripts/launch_nohup_watcher.sh
```

Manual status check:

```bash
cd /home/vlm/minyoung4
bash EXP_flag/P2_03_tail_robust_segmentation/scripts/monitor_nohup_tail_robust.sh
```

Manual summary if the watcher is not running:

```bash
python EXP_flag/P2_02_segmentation_loco_baseline/scripts/summarize_loco_segmentation.py \
  --runs-root EXP_flag/P2_03_tail_robust_segmentation/runs \
  --out-dir EXP_flag/P2_03_tail_robust_segmentation/reports/loco_full_v1 \
  --pattern 'seg_tail_tversky_loco_*_full_v1'
```

After summary, compare against P2.02:

```bash
python EXP_flag/P2_03_tail_robust_segmentation/scripts/compare_to_p202_baseline.py \
  --candidate-report-dir EXP_flag/P2_03_tail_robust_segmentation/reports/loco_full_v1 \
  --out-dir EXP_flag/P2_03_tail_robust_segmentation/reports/compare_vs_p202_loco_full_v1 \
  --bootstrap-iters 5000
```
