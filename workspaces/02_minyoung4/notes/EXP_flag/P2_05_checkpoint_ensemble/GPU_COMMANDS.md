# P2.05 GPU Commands

Run from `/home/vlm/minyoung4`.

## Evaluate Ensemble

```bash
python EXP_flag/P2_05_checkpoint_ensemble/scripts/evaluate_checkpoint_ensemble.py \
  --out-dir EXP_flag/P2_05_checkpoint_ensemble/reports/p202_p203_tta_single_v1 \
  --device cuda:2 \
  --batch-size 1 \
  --num-workers 4 \
  --tta-mode single
```

## Compare vs P2.02

```bash
python EXP_flag/P2_03_tail_robust_segmentation/scripts/compare_to_p202_baseline.py \
  --baseline-report-dir EXP_flag/P2_02_segmentation_loco_baseline/reports/loco_full_v2_validseg \
  --candidate-report-dir EXP_flag/P2_05_checkpoint_ensemble/reports/p202_p203_tta_single_v1 \
  --out-dir EXP_flag/P2_05_checkpoint_ensemble/reports/compare_vs_p202_p202_p203_tta_single_v1 \
  --bootstrap-iters 5000
```
