# Baseline 02 — ROI Mean Logistic Regression CN vs AD

## 한 줄 요약

5개 ROI 각각의 평균 voxel intensity만 사용한 logistic regression baseline에서 CN vs AD test ROC-AUC 0.7018을 얻었다.

## 위치

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad/
```

## 핵심 결과

- Validation: PASS
- Feature rows: 7010
- Feature extraction error rows: 0
- Train rows: 5574
- Test rows: 1436
- Test ROC-AUC: 0.7018
- Test balanced accuracy: 0.6806
- Test accuracy: 0.7013

## 문서

자세한 데이터/모델/학습방법/평가방법은 다음 파일에 기록했다.

```text
BASELINE_PROTOCOL.md
summary.json
REPORT.md
config.json
```

## 산출물

```text
features.csv
predictions.csv
metrics.csv
visuals/roi_mean_by_class.png
visuals/roc_curve_cn_vs_ad.png
visuals/logreg_coefficients.png
```
