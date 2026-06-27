# Threshold-Free and Size-Control Analysis

Created: 2026-06-24T10:41:11.118549+00:00

## Scope

- CPU-only analysis from existing subject-level reliability scores.
- No NIfTI loading, model training, inference, or GPU use.
- Input: `research_gsure/03_baselines/outputs/20260624_1115_reliability_calibration_gate/reliability_calibration_test_scores.csv`
- Current evidence remains MU+UCSD only.

## B1B Pooled Primary Scores

| score                       |   n |   n_pos |   prevalence |      auc |       ap | metric_status   |
|:----------------------------|----:|--------:|-------------:|---------:|---------:|:----------------|
| V0_neg_pred_volume          | 381 |     169 |      0.44357 | 0.735347 | 0.671089 | ok              |
| U0_mean_entropy_pred_mask   | 381 |     169 |      0.44357 | 0.698588 | 0.689404 | ok              |
| C0_z_mean_entropy_pred_mask | 381 |     169 |      0.44357 | 0.82229  | 0.813125 | ok              |
| C1_volume_only              | 381 |     169 |      0.44357 | 0.735319 | 0.666592 | ok              |
| C1_entropy_plus_volume      | 381 |     169 |      0.44357 | 0.90968  | 0.907806 | ok              |

## Threshold Sensitivity

|   dice_cutoff |   C0_z_mean_entropy_pred_mask |   C1_entropy_plus_volume |   V0_neg_pred_volume |
|--------------:|------------------------------:|-------------------------:|---------------------:|
|          0.7  |                      0.837281 |                 0.909466 |             0.763596 |
|          0.75 |                      0.830618 |                 0.906954 |             0.757682 |
|          0.8  |                      0.82229  |                 0.90968  |             0.735347 |
|          0.85 |                      0.841682 |                 0.913832 |             0.69264  |
|          0.9  |                      0.90201  |                 0.953938 |             0.677839 |

## Continuous Dice Association

| score                       |   n |   spearman_error |   pearson_error |
|:----------------------------|----:|-----------------:|----------------:|
| V0_neg_pred_volume          | 381 |         0.433036 |        0.37893  |
| U0_mean_entropy_pred_mask   | 381 |         0.360393 |        0.428357 |
| C0_z_mean_entropy_pred_mask | 381 |         0.68127  |        0.652056 |
| C1_volume_only              | 381 |         0.430134 |        0.380954 |
| C1_entropy_plus_volume      | 381 |         0.822712 |        0.66478  |

## Site/Fold Diagnostics

| model   | fold   | dataset        |   n |   failure_rate_dice_le_0_8 |   mean_dice |   median_dice |   median_gt_voxels |   median_pred_voxels |
|:--------|:-------|:---------------|----:|---------------------------:|------------:|--------------:|-------------------:|---------------------:|
| B1A     | MU     | MU-Glioma-Post | 203 |                   0.448276 |    0.737749 |      0.809612 |            68417   |              68209   |
| B1A     | UCSD   | UCSD-PTGBM     | 178 |                   0.449438 |    0.752527 |      0.816938 |            63389.5 |              49961   |
| B1B     | MU     | MU-Glioma-Post | 203 |                   0.438424 |    0.750465 |      0.809911 |            68417   |              60849   |
| B1B     | UCSD   | UCSD-PTGBM     | 178 |                   0.449438 |    0.751108 |      0.822229 |            63389.5 |              46490.5 |

Score separability of the two available held-out folds; high absolute AUC means the score is site-scale sensitive.

| model   | score                       | site_target_positive   |   site_auc |   site_auc_abs |   site_ap | metric_status   |   median_MU |   median_UCSD |
|:--------|:----------------------------|:-----------------------|-----------:|---------------:|----------:|:----------------|------------:|--------------:|
| B1B     | V0_neg_pred_volume          | UCSD                   |   0.591299 |       0.591299 |  0.580191 | ok              | -11.0162    |    -10.747    |
| B1B     | U0_mean_entropy_pred_mask   | UCSD                   |   0.962362 |       0.962362 |  0.956817 | ok              |   0.0986484 |      0.182447 |
| B1B     | C0_z_mean_entropy_pred_mask | UCSD                   |   0.387668 |       0.612332 |  0.42409  | ok              |   0.702525  |      0.412847 |
| B1B     | C1_volume_only              | UCSD                   |   0.597    |       0.597    |  0.546885 | ok              |   0.469987  |      0.538496 |
| B1B     | C1_entropy_plus_volume      | UCSD                   |   0.47465  |       0.52535  |  0.500842 | ok              |   0.614626  |      0.568222 |

## Lesion-Size Stratification

| size_bin   | score                       |   n |   n_pos |   prevalence |   size_median |   mean_dice |      auc |       ap | metric_status   |
|:-----------|:----------------------------|----:|--------:|-------------:|--------------:|------------:|---------:|---------:|:----------------|
| mid        | V0_neg_pred_volume          | 127 |      49 |     0.385827 |         66124 |    0.774761 | 0.800628 | 0.768148 | ok              |
| mid        | C0_z_mean_entropy_pred_mask | 127 |      49 |     0.385827 |         66124 |    0.774761 | 0.879644 | 0.860778 | ok              |
| mid        | C1_entropy_plus_volume      | 127 |      49 |     0.385827 |         66124 |    0.774761 | 0.918106 | 0.900322 | ok              |
| large      | V0_neg_pred_volume          | 127 |      40 |     0.314961 |        139453 |    0.815328 | 0.770977 | 0.730756 | ok              |
| large      | C0_z_mean_entropy_pred_mask | 127 |      40 |     0.314961 |        139453 |    0.815328 | 0.76523  | 0.616924 | ok              |
| large      | C1_entropy_plus_volume      | 127 |      40 |     0.314961 |        139453 |    0.815328 | 0.883046 | 0.808182 | ok              |
| small      | V0_neg_pred_volume          | 127 |      80 |     0.629921 |         24172 |    0.662208 | 0.60266  | 0.721266 | ok              |
| small      | C0_z_mean_entropy_pred_mask | 127 |      80 |     0.629921 |         24172 |    0.662208 | 0.879521 | 0.936539 | ok              |
| small      | C1_entropy_plus_volume      | 127 |      80 |     0.629921 |         24172 |    0.662208 | 0.920479 | 0.958259 | ok              |

## Interpretation

- These are diagnostic controls, not new method results.
- Any GT-size stratification is diagnostic only and cannot be used as a deployable input.
- The main claim still requires UPENN/UTSW reproduction before becoming four-consortium evidence.
- If C1 remains strong only in specific lesion-size bins, the benchmark should present that as a limitation rather than a method win.

