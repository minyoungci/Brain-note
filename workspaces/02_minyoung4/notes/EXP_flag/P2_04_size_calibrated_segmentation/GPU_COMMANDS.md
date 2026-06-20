# P2.04 GPU Commands

Run from `/home/vlm/minyoung4`.

## Full Nohup LOCO Launch

```bash
CONFIRM_LONG_GPU_RUN=yes bash EXP_flag/P2_04_size_calibrated_segmentation/scripts/launch_all_nohup_size_calibrated.sh
```

This starts four held-out-consortium folds under `setsid nohup` and a watcher that summarizes and compares against P2.02 after all folds finish.

## Monitor

```bash
bash EXP_flag/P2_04_size_calibrated_segmentation/scripts/monitor_nohup_size_calibrated.sh
```

## Expected Outputs

```text
EXP_flag/P2_04_size_calibrated_segmentation/runs/
EXP_flag/P2_04_size_calibrated_segmentation/reports/loco_full_v1/
EXP_flag/P2_04_size_calibrated_segmentation/reports/compare_vs_p202_loco_full_v1/
```
