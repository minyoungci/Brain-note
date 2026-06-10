# Baseline 02 Protocol — ROI mean voxel feature logistic regression CN vs AD

## Baseline ID

`baseline_02_roi_mean_logreg_cn_vs_ad`

## 목적

3D representation learning 또는 CNN을 쓰기 전에, ROI mask와 final tensor만으로 얻을 수 있는 가장 단순한 handcrafted scalar feature가 CN vs AD 구분 신호를 갖는지 확인한다.

이 baseline은 novelty 모델이 아니라 **하한선 sanity-check**다. 이후 ROI-supervised encoder, tiny 3D CNN, representation probe와 비교할 기준점으로 사용한다.

## 입력 데이터

### MRI manifest

```text
/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_mri_manifest.csv
```

SHA256:

```text
1b500b9c2c3d65c59f886e5ed807dad506eb96f2ef38913ac26e2fa1e86843ad
```

### ROI-pair manifest

```text
/home/vlm/data/preprocessed_official/v2/_reports/roi_transfer_option_b_full_subjectlocal_20260522T034648Z/voxelwise_roi_readiness_draft_20260523T143000Z/v2-QCpass/visual_qc_policy_v1/final_pass_only_training_manifest_v1/final_labeled_manifest_v1/voxelwise_pass_only_labeled_classifiable_roi_pair_manifest.csv
```

SHA256:

```text
dd61c3816e0a36fad60f42257c8bba0a57c524f47e0904e38af6e1b27073861f
```

## Inclusion / exclusion

- Include diagnosis: `CN`, `AD`
- Exclude diagnosis: `MCI`
- Require `is_classifiable=True`
- Require complete ROI set for each MRI
- Unit of analysis: subject/session MRI row
- Split grouping key: `cohort::subject_id`

## ROI set

다음 5개 ROI를 사용한다.

1. `hippocampus`
2. `amygdala`
3. `thalamus`
4. `lateral_ventricle`
5. `parahippocampal_cortex`

## Feature definition

각 MRI에 대해 다음을 계산한다.

```text
roi_mean__<roi> = mean(final_tensor voxels where candidate ROI mask > 0)
```

즉 한 MRI당 feature는 5개다.

```text
roi_mean__hippocampus
roi_mean__amygdala
roi_mean__thalamus
roi_mean__lateral_ventricle
roi_mean__parahippocampal_cortex
```

`final_tensor`는 v2 official preprocessing의 z-scored T1w NIfTI다. 따라서 feature는 absolute raw intensity가 아니라 preprocessing 후 z-scored grid에서의 ROI 평균이다.

## Model

scikit-learn pipeline:

```python
make_pipeline(
    StandardScaler(),
    LogisticRegression(
        max_iter=1000,
        class_weight="balanced",
        solver="liblinear",
        random_state=42,
    ),
)
```

Positive class: `AD`

Label mapping:

```text
CN -> 0
AD -> 1
```

## Training / evaluation method

- Split: subject-disjoint `GroupShuffleSplit`
- `test_size=0.2`
- `random_state=42`
- Group key: `cohort::subject_id`
- Train rows: 5574
- Test rows: 1436
- Train subject groups: 3127
- Test subject groups: 782

Class counts:

```text
Train: CN=4536, AD=1038
Test:  CN=1180, AD=256
```

## Results

Primary metric:

```text
test ROC-AUC = 0.7017578125
```

Other metrics:

```text
test balanced accuracy = 0.6805746822
test accuracy          = 0.7012534819
test average precision AD = 0.3825200626
```

Confusion matrix labels: `[CN, AD]`

```text
[[841, 339],
 [ 90, 166]]
```

Interpretation:

- CN recall: 0.7127
- AD recall: 0.6484
- AD precision: 0.3287
- Because AD is minority class, AD precision remains low.
- Still, AUC ~0.70 means ROI scalar signal is present and usable as a minimal lower-bound baseline.

## Artifacts

Baseline folder:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad/
```

Files:

```text
config.json
summary.json
REPORT.md
features.csv
predictions.csv
metrics.csv
visuals/roi_mean_by_class.png
visuals/roc_curve_cn_vs_ad.png
visuals/logreg_coefficients.png
```

Original run result folder preserved at:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_02_roi_mean_logreg_cn_vs_ad/
```

## Reproduction command

```bash
cd /home/vlm/minyoungi
python experiments/voxelwise_feature_learning_v1/scripts/baseline_02_roi_mean_logreg_cn_vs_ad.py --workers 12
```

## Limitations

- This is not representation learning.
- It uses only 5 scalar ROI means.
- It ignores voxel pattern, ROI shape, texture, and cross-ROI spatial interactions.
- Since final tensors are z-scored, intensity interpretation should be treated cautiously.
- Evaluation is one fixed random subject-disjoint split, not repeated CV or leave-one-cohort-out.

## Next comparisons

Recommended next baselines:

1. ROI mean + std + quantiles + voxel count logistic regression
2. Leave-one-cohort-out evaluation of the same 5 ROI means
3. Tiny 3D CNN image-only baseline
4. ROI-supervised encoder probe
