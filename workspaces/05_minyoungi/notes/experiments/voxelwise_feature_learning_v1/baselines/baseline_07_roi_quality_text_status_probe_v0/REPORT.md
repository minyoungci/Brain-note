# Baseline 07 ROI quality/text/status-only probe v0

Generated: `2026-05-27T15:01:35Z`

## Purpose

ROI quality text and ROI text statuses can themselves carry diagnosis signal. This baseline quantifies that shortcut before any VLM/image model claim.
This is not image-model evidence and not VLM performance.

## Inputs

- ROI quality text: `/home/vlm/minyoungi/manifests/v2_integrated/captions/roi_quality_text_v0/official_roi_quality_text_v0.csv`
- ROI text v1 local rows: `/home/vlm/minyoungi/manifests/v2_integrated/captions/roi_text_v1/roi_local_text_v1.csv`
- Split manifest: `/home/vlm/minyoungi/manifests/v2_integrated/splits/subject_disjoint_split_v0.csv`

## Feature sets

- `dummy_most_frequent`: 0 features
- `roi_quality_gate_and_mask_status`: 45 features
- `roi_text_v1_severity_scores`: 16 features
- `roi_text_v1_severity_onehot`: 80 features
- `quality_plus_severity_scores`: 61 features
- `quality_plus_severity_onehot`: 125 features

## Internal subject-disjoint test metrics

                     feature_set  accuracy  balanced_accuracy  macro_f1  macro_ovr_auc  train_rows  test_rows
             dummy_most_frequent  0.535714           0.333333  0.232558       0.500000        7838       1680
roi_quality_gate_and_mask_status  0.502976           0.512745  0.446917       0.693273        7838       1680
     roi_text_v1_severity_scores  0.498214           0.511204  0.484804       0.691471        7838       1680
     roi_text_v1_severity_onehot  0.556548           0.532681  0.506415       0.703428        7838       1680
    quality_plus_severity_scores  0.556548           0.555761  0.523889       0.713061        7838       1680
    quality_plus_severity_onehot  0.572024           0.549421  0.525727       0.721156        7838       1680

## LOCO mean metrics

                     feature_set  mean_balanced_accuracy  std_balanced_accuracy  mean_macro_f1  mean_macro_ovr_auc  n_folds
             dummy_most_frequent                0.333333               0.000000       0.209799            0.500000        6
    quality_plus_severity_onehot                0.541138               0.029862       0.463608            0.702750        6
    quality_plus_severity_scores                0.537397               0.037242       0.464929            0.703407        6
roi_quality_gate_and_mask_status                0.526950               0.031751       0.443862            0.701719        6
     roi_text_v1_severity_onehot                0.526070               0.027650       0.451810            0.690994        6
     roi_text_v1_severity_scores                0.527874               0.031571       0.450691            0.687740        6

## Interpretation guardrail

If ROI text/status features perform well, later ROI-language/VLM runs must beat this under identical splits; otherwise they may only be repackaging deterministic ROI status text.
Quality/mask-status features include ROI availability and voxel-count-like information, so they are a shortcut audit, not a biologically clean representation baseline.
