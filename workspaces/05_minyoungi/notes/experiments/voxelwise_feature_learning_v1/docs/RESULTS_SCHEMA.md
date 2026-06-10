# Results schema

Each experiment result directory should contain only:

- `config.json` or a pointer to `../../configs/<name>.json`
- `summary.json` — machine-readable metrics and validation flags
- `REPORT.md` — human-readable Korean/English summary
- `metrics.csv` or `metrics.jsonl` only when training produces per-epoch metrics
- `predictions.csv` only for evaluation/probe runs
- `visuals/*.png` for final figures only

Baseline snapshots under `baselines/<baseline_id>/` additionally contain:

- `README.md` — short baseline summary
- `BASELINE_PROTOCOL.md` — data, feature, model, training/evaluation protocol, metrics, limitations

Comparison artifacts under `comparisons/` contain:

- `baseline_comparison.csv` — one row per registered baseline using common metric columns
- `baseline_comparison.md` — human-readable comparison summary

Avoid repeated timestamped copies. Use `results/LATEST.json`, `baselines/BASELINE_INDEX.json`, `comparisons/baseline_comparison.csv`, and stable per-experiment names.
