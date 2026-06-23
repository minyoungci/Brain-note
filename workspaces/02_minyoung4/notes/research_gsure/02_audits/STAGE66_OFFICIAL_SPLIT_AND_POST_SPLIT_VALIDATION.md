# Stage 66 - Official Split and Post-Split Validation

## Task

Create the approved official LOCO split and run post-split CPU validation.

## Research Question

Can the approved subject-level G-SURE cohort be locked into official LOCO split
artifacts, and do the post-split loader/tile assumptions pass before GPU
training?

## Approval

Min approved:

```text
Approve official LOCO split creation for the subject-level G-SURE cohort.
```

## What Ran

```bash
python research_gsure/02_audits/scripts/check_pre_split_readiness.py
python research_gsure/02_audits/scripts/check_official_split_artifacts.py --expect-missing
python research_gsure/02_audits/scripts/build_loco_split_manifest.py --write
python research_gsure/02_audits/scripts/check_official_split_artifacts.py
python research_gsure/02_audits/scripts/run_post_split_validation.py --run
```

## Artifacts Created

Official split artifacts:

```text
research_gsure/02_audits/outputs/loco_split_manifest.csv
research_gsure/02_audits/outputs/loco_split_summary.csv
research_gsure/02_audits/outputs/loco_split_audit_report.md
```

Post-split validation artifacts:

```text
research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test.csv
research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_by_dataset.csv
research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_oof_estimate.csv
research_gsure/02_audits/outputs/20260623_061921_sliding_window_tile_budget_loco_test_report.md
research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test.csv
research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test_summary.csv
research_gsure/02_audits/outputs/20260623_061921_tile_grid_dry_run_loco_test_report.md
```

## Results

Official split builder:

```text
Subject rows: 1614
Split rows to write: 6456
Fold rows: 4
Validation: ok
```

Official split checker:

```text
Official split artifact check: PASS
Split manifest rows: 6456
Fold summaries: 4
Subject overlap: 0
Duplicate train/test subjects: 0
Missing path rows: 0
Lesion-burden summary fields: validated
Timing-warning summary fields: validated
```

Post-split validation runner:

```text
Post-split validation runner: PASS
Coverage failures: 0
```

All-consortium bounded loader smoke passed for:

```text
MU-Glioma-Post
UCSD-PTGBM
UPENN-GBM
UTSW
```

## Interpretation

The official split is now created and validated. The project may proceed to the
first segmentation baseline command preview. This still does not authorize GPU
training, preprocessing cache creation, OOF prediction generation, reliability
label generation, G-SURE method training, or performance claims.

## Next Gate

Prepare the first-baseline GPU command preview with:

- model,
- input shape,
- tensor convention,
- normalization,
- augmentation,
- loss,
- optimizer,
- batch size,
- epochs,
- checkpoint policy,
- expected runtime,
- exact files to be written,
- stop criteria.

GPU execution still requires separate explicit approval.
