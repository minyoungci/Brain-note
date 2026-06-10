# Experiment question — baseline_03_roi_summary_logreg_cn_vs_ad

## Question

CN vs AD를 고정했을 때, 5개 ROI의 mean-only feature보다 mean/std/median/quantile/voxel_count summary feature가 random subject-disjoint split과 leave-one-cohort-out 평가에서 성능과 일반화를 개선하는가?

## Hypothesis

ROI mean-only baseline보다 ROI 내부 분포 통계(mean/std/median/q05/q25/q75/q95/voxel_count)를 추가하면 CN vs AD random split 성능은 상승할 수 있다. 그러나 leave-one-cohort-out 성능이 낮으면 향상분은 cohort/scanner/site confound일 가능성이 있다.

## Decision rule

- Mean-only baseline_02 random split ROC-AUC: 0.7018
- baseline_03 random split ROC-AUC가 0.72 이상이면 feature 확장 효과 후보로 본다.
- leave-one-cohort-out 평균 ROC-AUC와 cohort별 편차를 함께 확인한다.
