# Voxel-wise Feature Learning v1 실험 정리 원칙

## 목적

PASS-only labeled voxel-wise ROI manifest를 기준으로 baseline부터 차근차근 실험한다. 실험 결과는 재현 가능하고, 시각화는 바로 확인 가능하며, 불필요한 timestamp 중복 파일은 만들지 않는다.

## Layer 구조

```text
voxelwise_feature_learning_v1/
  README.md
  EXPERIMENT_INDEX.md
  configs/
  scripts/
  results/
    LATEST.json
    baseline_00_manifest_contract/
      summary.json
      REPORT.md
      *.csv
      visuals/*.png
    baseline_03_roi_summary_logreg_cn_vs_ad/
      summary.json
      REPORT.md
      metrics_random_split.csv
      metrics_leave_one_cohort_out.csv
      predictions_random_split.csv
      predictions_leave_one_cohort_out.csv
      visuals/*.png
  baselines/
    BASELINE_INDEX.json
    <baseline_id>/
      BASELINE_PROTOCOL.md
      summary.json
      REPORT.md
      features.csv
      metrics*.csv
      predictions*.csv
      visuals/*.png
  comparisons/
    baseline_comparison.csv
    baseline_comparison.md
  docs/
  registry/
```

## 결과 저장 규칙

1. 같은 실험 ID를 재실행하면 같은 디렉토리를 업데이트한다.
2. 새 디렉토리는 method/objective/split이 바뀔 때만 만든다.
3. 모든 실험은 최소한 다음을 가진다.
   - `summary.json`
   - `REPORT.md`
   - 필요한 경우 `metrics.csv` 또는 `predictions.csv`
   - 최종 해석용 `visuals/*.png`
4. 최신 결과는 항상 `results/LATEST.json`에서 찾는다.
5. checkpoint/log/raw data는 이 디렉토리에 대량 복사하지 않는다.
6. GPU 학습은 `nvidia-smi`, `pwd`, `git status`, command preview 후 Min 승인 뒤 실행한다.

## 비교 가능성 보존 규칙

1. 각 실험은 반드시 독립된 `results/<run_id>/` 디렉토리에 저장한다.
2. Min이 baseline으로 인정한 결과만 `baselines/<baseline_id>/`에 snapshot으로 복사한다.
3. baseline snapshot은 원본 `results/<run_id>/`를 지우거나 이동하지 않는다.
4. 비교용 핵심 metric은 `summary.json`에 공통 key로 둔다.
   - `run_id`
   - `config.class_filter`
   - `config.feature_definition`
   - `config.split`
   - `metrics.n_train`, `metrics.n_test`
   - `metrics.test_roc_auc`
   - `metrics.test_balanced_accuracy`
   - `metrics.test_accuracy`
   - leave-one-cohort-out이 있으면 cohort별 AUC/balanced accuracy
5. 여러 평가 split이 있으면 파일명을 분리한다.
   - `metrics_random_split.csv`
   - `predictions_random_split.csv`
   - `metrics_leave_one_cohort_out.csv`
   - `predictions_leave_one_cohort_out.csv`
6. baseline 간 비교표는 `comparisons/baseline_comparison.csv`와 `comparisons/baseline_comparison.md`에 누적한다.
7. run마다 `BASELINE_PROTOCOL.md` 또는 `REPORT.md`에 데이터/모델/학습방법/평가방법/제한점을 기록한다.

## Baseline 순서

1. `baseline_00_manifest_contract`: manifest/label/ROI 완결성 검증 + 분포 시각화. 완료.
2. `baseline_02_roi_mean_logreg_cn_vs_ad`: 5개 ROI mean feature + CN vs AD logistic regression. 완료 및 `baselines/` 등록.
3. `baseline_03_roi_summary_logreg_cn_vs_ad`: CN vs AD 고정, ROI mean/std/quantile/volume feature + logistic regression, random split + leave-one-cohort-out.
4. `baseline_04_tiny_3d_cnn_image_only_cn_vs_ad`: GPU gated image-only baseline.
5. `baseline_05_voxelwise_roi_supervised_encoder_cn_vs_ad`: ROI mask를 쓰는 voxel-wise objective.

## 시각화 정책

- 분포 확인: class counts, cohort × class, ROI counts.
- supervised result: confusion matrix, class-wise recall/F1, cohort-wise metrics.
- ROI objective: ROI-wise loss/metric plot.
- 개선된 그림은 같은 안정 파일명을 overwrite하고 `REPORT.md`를 업데이트한다.

## 현재 canonical input

- 최신 labeled pointer: `/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/LATEST_LABELED_PASS_ONLY_MANIFEST.json`
- 추천 ROI-pair manifest: `voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv`
- 추천 MRI manifest: `voxelwise_pass_only_labeled_classifiable_mri_manifest.csv`
