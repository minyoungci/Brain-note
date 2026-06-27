# Threshold-Free and Size-Control Analysis

Created: 2026-06-24T10:41:03.687833+00:00

## Scope

- CPU-only analysis from existing subject-level reliability scores.
- No NIfTI loading, model training, inference, or GPU use.
- Input: `research_gsure/03_baselines/outputs/20260624_1205_threshold_size_controls_synthetic/synthetic_scores.csv`
- Current evidence remains MU+UCSD only.

## B1B Pooled Primary Scores

| score                       |   n |   n_pos |   prevalence |      auc |       ap | metric_status   |
|:----------------------------|----:|--------:|-------------:|---------:|---------:|:----------------|
| V0_neg_pred_volume          |  60 |      34 |     0.566667 | 0        | 0.376877 | ok              |
| U0_mean_entropy_pred_mask   |  60 |      34 |     0.566667 | 0.804864 | 0.86083  | ok              |
| C0_z_mean_entropy_pred_mask |  60 |      34 |     0.566667 | 1        | 1        | ok              |
| C1_volume_only              |  60 |      34 |     0.566667 | 0        | 0.376877 | ok              |
| C1_entropy_plus_volume      |  60 |      34 |     0.566667 | 0.99095  | 0.991804 | ok              |

## Threshold Sensitivity

|   dice_cutoff |   C0_z_mean_entropy_pred_mask |   C1_entropy_plus_volume |   V0_neg_pred_volume |
|--------------:|------------------------------:|-------------------------:|---------------------:|
|          0.7  |                             1 |                 0.990079 |                    0 |
|          0.75 |                             1 |                 0.989819 |                    0 |
|          0.8  |                             1 |                 0.99095  |                    0 |
|          0.85 |                             1 |                 0.988757 |                    0 |
|          0.9  |                             1 |                 0.984    |                    0 |

## Continuous Dice Association

| score                       |   n |   spearman_error |   pearson_error |
|:----------------------------|----:|-----------------:|----------------:|
| V0_neg_pred_volume          |  60 |        -1        |       -0.987725 |
| U0_mean_entropy_pred_mask   |  60 |         0.626051 |        0.654446 |
| C0_z_mean_entropy_pred_mask |  60 |         0.999944 |        1        |
| C1_volume_only              |  60 |        -1        |       -0.99254  |
| C1_entropy_plus_volume      |  60 |         0.975197 |        0.974327 |

## Site/Fold Diagnostics

| model   | fold   | dataset   |   n |   failure_rate_dice_le_0_8 |   mean_dice |   median_dice |   median_gt_voxels |   median_pred_voxels |
|:--------|:-------|:----------|----:|---------------------------:|------------:|--------------:|-------------------:|---------------------:|
| B1A     | MU     | MU        |  30 |                   0.566667 |       0.776 |         0.776 |               1925 |                 2160 |
| B1A     | UCSD   | UCSD      |  30 |                   0.566667 |       0.776 |         0.776 |               1925 |                 2160 |
| B1B     | MU     | MU        |  30 |                   0.566667 |       0.776 |         0.776 |               1925 |                 2160 |
| B1B     | UCSD   | UCSD      |  30 |                   0.566667 |       0.776 |         0.776 |               1925 |                 2160 |

Score separability of the two available held-out folds; high absolute AUC means the score is site-scale sensitive.

| model   | score                       | site_target_positive   |   site_auc |   site_auc_abs |   site_ap | metric_status   |   median_MU |   median_UCSD |
|:--------|:----------------------------|:-----------------------|-----------:|---------------:|----------:|:----------------|------------:|--------------:|
| B1B     | V0_neg_pred_volume          | UCSD                   |   0.5      |       0.5      |  0.5      | ok              |   -7.67816  |     -7.67816  |
| B1B     | U0_mean_entropy_pred_mask   | UCSD                   |   0.946111 |       0.946111 |  0.948142 | ok              |    0.39     |      0.79     |
| B1B     | C0_z_mean_entropy_pred_mask | UCSD                   |   0.498889 |       0.501111 |  0.516667 | ok              |    0.39     |      0.39     |
| B1B     | C1_volume_only              | UCSD                   |   0.5      |       0.5      |  0.5      | ok              |    0.579767 |      0.579767 |
| B1B     | C1_entropy_plus_volume      | UCSD                   |   0.625556 |       0.625556 |  0.649593 | ok              |    2.55     |      2.95     |

## Lesion-Size Stratification

| size_bin   | score                       |   n |   n_pos |   prevalence |   size_median |   mean_dice |        auc |         ap | metric_status             |
|:-----------|:----------------------------|----:|--------:|-------------:|--------------:|------------:|-----------:|-----------:|:--------------------------|
| small      | V0_neg_pred_volume          |  20 |       0 |          0   |          1425 |       0.896 | nan        | nan        | undefined_low_class_count |
| small      | C0_z_mean_entropy_pred_mask |  20 |       0 |          0   |          1425 |       0.896 | nan        | nan        | undefined_low_class_count |
| small      | C1_entropy_plus_volume      |  20 |       0 |          0   |          1425 |       0.896 | nan        | nan        | undefined_low_class_count |
| mid        | V0_neg_pred_volume          |  20 |      14 |          0.7 |          1925 |       0.776 |   0        |   0.530442 | ok                        |
| mid        | C0_z_mean_entropy_pred_mask |  20 |      14 |          0.7 |          1925 |       0.776 |   1        |   1        | ok                        |
| mid        | C1_entropy_plus_volume      |  20 |      14 |          0.7 |          1925 |       0.776 |   0.910714 |   0.957846 | ok                        |
| large      | V0_neg_pred_volume          |  20 |      20 |          1   |          2425 |       0.656 | nan        | nan        | undefined_low_class_count |
| large      | C0_z_mean_entropy_pred_mask |  20 |      20 |          1   |          2425 |       0.656 | nan        | nan        | undefined_low_class_count |
| large      | C1_entropy_plus_volume      |  20 |      20 |          1   |          2425 |       0.656 | nan        | nan        | undefined_low_class_count |

## Interpretation

- These are diagnostic controls, not new method results.
- Any GT-size stratification is diagnostic only and cannot be used as a deployable input.
- The main claim still requires UPENN/UTSW reproduction before becoming four-consortium evidence.
- If C1 remains strong only in specific lesion-size bins, the benchmark should present that as a limitation rather than a method win.

