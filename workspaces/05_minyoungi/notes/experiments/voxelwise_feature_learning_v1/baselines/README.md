# Baselines — voxelwise_feature_learning_v1

이 폴더는 `voxelwise_feature_learning_v1` 실험군에서 비교 기준으로 사용할 baseline 결과를 고정 저장하는 위치다.

## 저장 정책

- `results/`는 각 run의 일반 결과 위치다.
- `baselines/`는 Min이 baseline으로 인정한 결과를 복사해 고정 보관한다.
- 각 baseline은 stable run id 디렉토리를 사용한다. 불필요한 timestamp 디렉토리를 만들지 않는다.
- 최신 baseline 목록은 `BASELINE_INDEX.json`을 본다.

## 현재 등록 baseline

### `baseline_02_roi_mean_logreg_cn_vs_ad`

가장 단순한 ROI scalar baseline이다.

- 데이터: PASS-only labeled classifiable v2 MRI/ROI-pair manifest
- 입력: `final_tensor` T1w z-scored 3D NIfTI + candidate ROI masks
- feature: 5개 ROI 각각의 mask 내부 voxel 평균값
- task: CN vs AD binary classification
- 제외: MCI
- model: scikit-learn `StandardScaler` + `LogisticRegression(class_weight="balanced", solver="liblinear")`
- split: subject-disjoint `GroupShuffleSplit(test_size=0.2, random_state=42)`
- primary metric: test ROC-AUC
- 결과: ROC-AUC 0.7018, balanced accuracy 0.6806

결과 위치:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad/
```
