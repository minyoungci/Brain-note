# Code Review Protocol for Experiment Implementations

Created: 2026-06-18

Every experiment must be reviewed before its results can be used in a paper, report, or
model-selection decision.

## Review Roles

Use sub-agents only for bounded review tasks with explicit file ownership.

1. **Leakage reviewer**
   - Reviews data flow, split isolation, normalization scope, label handling, and metric aggregation.
   - Must confirm the held-out consortium is never used for model selection, threshold selection,
     normalization statistics, temperature scaling, or augmentation tuning.

2. **Code correctness reviewer**
   - Reviews model, loader, config, metric, run-output, and reproducibility code.
   - Must confirm config values are explicit, run outputs are non-overwriting, and metrics are
     computed at subject level.

3. **Experiment-owner integration**
   - The main agent resolves review findings.
   - Findings are written into `reviews/<stable_id>_review.md` inside the experiment directory.

## Required Review Checklist

- No random unit-level split.
- No multi-unit subject crosses train/validation/test.
- No held-out consortium appears in training transforms or model selection.
- No train-time class balancing is applied to validation/test.
- No global normalization statistics use validation/test.
- No test-consortium calibration or threshold tuning.
- Dataset/site/scanner variables are used only in approved roles.
- Segmentation availability cannot define the positive/negative label.
- Missing masks and zero-byte masks follow the approved mask policy.
- Metrics are subject-level, not file-level or visit-level unless explicitly justified.
- Runs are keyed by stable experiment ID, fold, seed, config hash, and git commit.
- Outputs are experiment-local and do not overwrite previous runs by default.
- Shared directories with multiple stable IDs must namespace `runs/`, `reports/`, and `reviews/`
  by stable ID.

## Review Record Template

```text
Experiment ID:
Files reviewed:
Reviewer role:
Summary:
Blocking findings:
Non-blocking findings:
Leakage status:
Reproducibility status:
Required fixes:
Approval for reported results: yes/no
```

## Sub-Agent Usage Pattern

For each implementation:

1. Main agent implements a bounded experiment slice.
2. Spawn one leakage reviewer for the changed data/split/eval files.
3. Spawn one code correctness reviewer for model/config/run files.
4. Main agent applies fixes.
5. Re-run smoke tests.
6. Write `reviews/<stable_id>_review.md` in that experiment directory.

Do not ask reviewers to train models or modify raw data.
