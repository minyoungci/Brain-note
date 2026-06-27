# Run Aborted

This directory was created by an interrupted scores-only bootstrap command:

```text
python research_gsure/03_baselines/scripts/evaluate_reliability_calibration_gate.py \
  --scores-csv research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_test_scores.csv \
  --bootstrap-reps 5000 \
  --bootstrap-seed 20260624 \
  --out-dir research_gsure/03_baselines/outputs/20260624_1125_reliability_calibration_gate_scores_only_bootstrap
```

The process was stopped after user interruption. Do not treat this directory as
a completed analysis artifact.

Use the completed bootstrap output instead:

```text
research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_bootstrap_summary.csv
```

