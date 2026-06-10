# VLM Gate 02 — ROI→Image Distillation v0 Plan

작성 시점: 2026-05-26

## 왜 이 gate가 필요한가

VLM으로 바로 넘어가기 전에 image encoder가 ROI morphology 신호를 실제 이미지에서 학습할 수 있는지 확인해야 한다.

Gate 01 결과:

- image-only LOCO pooled ROC-AUC: 0.7351
- ROI-summary LOCO pooled ROC-AUC: 0.8809
- image/ROI score correlation: 0.5750
- row-level agreement:
  - both correct: 4588 / 7010
  - ROI only correct: 1354 / 7010
  - image only correct: 363 / 7010
  - both wrong: 705 / 7010

해석:

- image-only signal은 존재한다.
- 하지만 ROI-summary가 훨씬 강하다.
- 특히 `ROI only correct` row가 1354개로 많다.
- 따라서 다음 핵심 질문은 “ROI morphology teacher의 정보를 T1w image encoder로 옮길 수 있는가?”이다.

## 연구 질문

> T1w final_tensor만 입력받는 3D image encoder가 FastSurfer/ROI-summary teacher의 morphology signal을 학습하고, 그 representation이 CN/AD LOCO probe에서 image-only baseline보다 더 일반화되는가?

## 입력

### Student input

- `final_tensor_path`
- T1w brain 1mm RAS zscore tensor
- image-only

금지 입력:

- diagnosis label as input
- ROI masks or ROI feature values as input
- cohort/scanner/site metadata as input
- age/sex as input
- PET/CDR/biomarker as input

### Teacher target 후보

v0에서는 baseline_03 ROI summary features를 사용한다.

- source: `/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/baseline_03_roi_summary_logreg_cn_vs_ad/features.csv`
- allowed target: image-derived ROI summary values only
- target columns:
  - `roi_mean__*`
  - `roi_std__*`
  - `roi_median__*`
  - `roi_q05__*`
  - `roi_q25__*`
  - `roi_q75__*`
  - `roi_q95__*`
  - `roi_voxel_count__*`

주의:

- `voxel_count`는 강한 volume/mask-size shortcut일 수 있다.
- v0에서는 포함하되, ablation에서 `no_voxel_count`를 반드시 비교한다.

## Split

baseline_06과 동일한 leave-one-cohort-out을 사용한다.

- train cohorts: heldout cohort 제외
- test cohort: heldout one consortium
- subject/path/cohort overlap: 0이어야 함

## Model

v0는 baseline_06 Small3DCNN encoder를 재사용한다.

- input: downsampled T1w tensor
- encoder: Small3DCNN body
- heads:
  1. ROI regression head
  2. optional teacher-logit distillation head
  3. frozen-probe embedding export

## Loss 후보

### v0a — ROI z regression

- train split에서 teacher feature mean/std fit
- train/val/test 모두 train stats로 z-transform
- loss: MSE over ROI summary target vector

### v0b — no-voxel-count ROI z regression

- `roi_voxel_count__*` 제외
- morphology/intensity summary만 사용

### v0c — ROI teacher logit distillation

- baseline_03 ROI-summary logreg의 AD probability/logit을 teacher signal로 사용
- loss: BCE/KL on teacher probability
- diagnosis hard label은 evaluation/probe용이지 representation pretraining target으로 남용하지 않음

## Evaluation

### 1. ROI imitation

- target z vector MSE / MAE
- train-mean predictor 대비 improvement
- per-ROI/per-stat error
- heldout cohort별 imitation metric

통과 기준:

- train-mean baseline보다 명확히 좋아야 함.

### 2. Frozen embedding probe

- encoder freeze
- train cohort embedding으로 logistic regression probe fit
- heldout cohort evaluation
- metrics:
  - ROC-AUC
  - balanced accuracy
  - AP-AD
  - confusion matrix

비교 기준:

- baseline_06 image-only LOCO mean ROC-AUC: 0.8087
- baseline_06 image-only mean balanced accuracy: 0.7146
- ROI-summary LOCO mean ROC-AUC: 0.8732

### 3. Row-level comparison

- Gate 01의 `ROI only correct` subset에서 개선되는지 확인
- ADNI/AJU에서 threshold/class-prior 취약성이 줄어드는지 확인

## Success / fail criteria

### Pass

- ROI imitation beats train-mean baseline
- frozen probe improves over baseline_06 or narrows ROI/image gap
- cohort-wise collapse 없음
- leakage audit pass 유지

### Partial pass

- ROI imitation은 좋지만 frozen CN/AD probe가 개선되지 않음
- 이 경우 representation이 task-relevant하게 정렬되지 않았다는 뜻이므로 teacher-latent/logit objective로 pivot

### Fail

- ROI imitation도 train-mean baseline과 비슷함
- 또는 특정 cohort에서 collapse
- 이 경우 VLM scaling 금지. image encoder architecture/optimization diagnostic으로 돌아감.

## 산출물 위치

예정:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/results/vlm_gate_02_roi_to_image_distillation_v0/
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_02_roi_to_image_distillation_v0.py
```

## 실행 전 gate

GPU/long job이므로 실행 전 반드시 확인:

```bash
nvidia-smi
pwd
git status --short
ps -eo pid,ppid,stat,etime,pcpu,pmem,args | grep -E 'vlm_gate_02|baseline_06|torchrun|python' | grep -v grep || true
```

Min 승인 없이 장시간 학습은 실행하지 않는다.

## 바로 다음 coding step

1. `vlm_gate_02_roi_to_image_distillation_v0.py` 작성
2. `--dry-run --heldout-cohort KDRC --max-samples 32` CPU/GPU smoke
3. ROI target z-transform 및 train-mean baseline 검증
4. Min 승인 후 selected folds부터 GPU 실행
