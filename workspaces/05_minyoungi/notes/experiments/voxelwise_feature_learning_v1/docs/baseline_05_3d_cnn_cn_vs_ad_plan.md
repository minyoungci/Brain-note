# Baseline 05 plan/result — image-only 3D CNN CN vs AD

## 목적

ROI handcrafted baseline을 통과한 뒤, 같은 CN vs AD task에서 **final_tensor T1w image-only 3D CNN**이 ROI-volume shortcut 없이 어느 정도 표현을 학습하는지 확인한다.

## 직전 gate 결과

- `baseline_03_roi_summary_logreg_cn_vs_ad`: full ROI summary random ROC-AUC ≈ 0.9004, LOCO mean ROC-AUC ≈ 0.8732.
- `baseline_04_roi_summary_ablation_logreg_cn_vs_ad`: voxel_count-only random ROC-AUC ≈ 0.8913, intensity-only random ROC-AUC ≈ 0.8655.
- 해석: CN vs AD signal은 강하지만, handcrafted ROI volume/morphology proxy가 매우 큰 부분을 설명한다. 3D CNN은 image-only representation baseline으로 별도 기록한다.

## 실험 질문

CN vs AD를 고정했을 때, final_tensor T1w만 입력한 작은 3D CNN이 subject-disjoint random split에서 안정적으로 학습되는가?

## 입력 정책

- Source features/manifest: `results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
- Classes: CN=0, AD=1, MCI excluded.
- Image input: `final_tensor_path` only.
- Forbidden model inputs: diagnosis-derived text, ROI masks/features, cohort/scanner metadata, age/sex.

## Throughput profiling 결과

초기 `batch_size=2`는 너무 보수적이었다. B200 단일 GPU에서 `downsample=2`, `width=32`, AMP 기준 batch 128이 안정적이었다.

- batch 64: 약 41 samples/sec, peak allocated 약 13.0GB
- batch 96: 약 62 samples/sec, peak allocated 약 19.5GB
- batch 128: 약 80 samples/sec, peak allocated 약 25.9GB

실제 cache 생성 이후 epoch당 학습 속도는 약 500–600 samples/sec였다.

## 실행 설정

```bash
cd /home/vlm/minyoungi
CUDA_VISIBLE_DEVICES=0 python experiments/voxelwise_feature_learning_v1/scripts/baseline_05_3d_cnn_cn_vs_ad_smoke.py \
  --epochs 20 \
  --batch-size 128 \
  --num-workers 12 \
  --downsample 2 \
  --width 32 \
  --lr 0.001 \
  --weight-decay 0.0001 \
  --amp \
  --register-baseline
```

## 결과

저장 위치:

```text
results/baseline_05_3d_cnn_cn_vs_ad_smoke/
baselines/baseline_05_3d_cnn_cn_vs_ad_smoke/
```

주요 수치:

- best epoch: 14
- random split ROC-AUC: 0.8906
- balanced accuracy: 0.8314
- accuracy: 0.8788
- AP(AD): 0.7508
- confusion matrix `[CN, AD]`: `[[1068, 112], [62, 194]]`

Cohort-wise random-test ROC-AUC:

- ADNI: 0.8661
- AIBL: 0.8966
- AJU: 0.7674
- KDRC: 0.8601
- NACC: 0.9204
- OASIS: 0.8033

## 해석

Image-only 3D CNN이 ROI feature를 직접 보지 않고도 random split AUC 0.89까지 도달했다. 이는 baseline_03 handcrafted full ROI summary AUC 0.9004에 근접하지만, 아직 leave-one-cohort-out은 실행하지 않았다. 다음 단계는 이 image-only 모델에 대해 LOCO 또는 cohort-held-out 학습을 별도 job으로 돌려 일반화 한계를 확인하는 것이다.

## 산출물

```text
scripts/baseline_05_3d_cnn_cn_vs_ad_smoke.py
results/baseline_05_3d_cnn_cn_vs_ad_smoke/summary.json
results/baseline_05_3d_cnn_cn_vs_ad_smoke/REPORT.md
results/baseline_05_3d_cnn_cn_vs_ad_smoke/training_history.csv
results/baseline_05_3d_cnn_cn_vs_ad_smoke/predictions_random_split.csv
results/baseline_05_3d_cnn_cn_vs_ad_smoke/metrics_by_cohort_random_split.csv
results/baseline_05_3d_cnn_cn_vs_ad_smoke/best_model.pt
results/baseline_05_3d_cnn_cn_vs_ad_smoke/visuals/training_curve.png
results/baseline_05_3d_cnn_cn_vs_ad_smoke/visuals/confusion_matrix.png
```

## Cache note

학습 속도를 위해 downsampled final_tensor FP16 cache를 생성했다.

```text
cache/final_tensor_downsampled_ds2_fp16/  # 약 14GB
```

이 cache는 canonical data가 아니라 재생성 가능한 speed artifact다.
