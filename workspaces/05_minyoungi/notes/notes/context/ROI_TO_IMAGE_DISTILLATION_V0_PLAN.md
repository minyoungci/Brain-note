# ROI→3D Image Distillation v0 Plan

Generated: 2026-05-21
Workspace: `/home/vlm/minyoungi`

## 결론

진행 방향은 **ROI teacher가 가진 해부학적 morphology signal을 3D T1w image encoder student에 먼저 distill**하는 것이다. 이 단계는 VLM 본 실험 전, image encoder가 hippocampus/entorhinal/ventricle 등 dementia-relevant ROI signal을 실제로 담는지 확인하는 representation-learning gate다.

## 배경 근거

최근 image-only tiny 3D CNN smoke 결과:

- class-balanced internal_test에서도 MCI 과예측 반복.
- repeat seed 2개에서 CN prediction이 0개로 붕괴.
- 같은 sample에서 ROI+age/sex probe는 CN/AD recall을 훨씬 잘 유지.

해석:

```text
MRI morphology signal 자체가 없는 것은 아니다.
현재 tiny downsampled voxel CNN이 ROI morphology signal을 안정적으로 representation하지 못한다.
```

## v0 Research Question

```text
3D T1w image encoder가 label supervision 없이 FastSurfer ROI morphology teacher signal을 예측/정렬하도록 학습하면,
기존 image-only tiny CNN보다 CN/MCI/AD downstream probe가 안정화되는가?
```

## v0 목표

1. Diagnosis label을 직접 training target으로 쓰지 않고, image-derived ROI morphology를 teacher로 사용한다.
2. Student image encoder가 16개 ROI z-score/status를 예측하도록 학습한다.
3. 학습된 frozen image embedding으로 CN/MCI/AD linear probe를 평가한다.
4. ROI teacher signal을 실제로 배웠는지 ROI prediction metrics를 먼저 보고, 그 다음 diagnosis probe를 본다.

## 입력 산출물

### Image input

- Manifest: `/home/vlm/minyoungi/manifests/v2_integrated/canonical/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`
- Split: `/home/vlm/minyoungi/manifests/v2_integrated/splits/subject_disjoint_split_v0.csv`
- T1w: `t1w_preproc_path`
- Mask: `brain_mask_path`

### ROI teacher input

- ROI captions/features: `/home/vlm/minyoungi/manifests/v2_integrated/captions/roi_v0/roi_captions_v0.csv`
- ROI subset: 16 primary ROIs
- Numeric target: `roi_z_train_reference`
- Optional categorical target: `roi_status` with `{lower_than_reference, within_reference_range, higher_than_reference}`
- Normalization: `Volume_mm3 / MaskVol * 1000`
- Reference: train split only

### Existing baseline reference

- ROI probe results: `/home/vlm/minyoungi/manifests/v2_integrated/probes/roi_feature_probe_v0/roi_feature_probe_v0_results.csv`
- Image-only smoke: `/home/vlm/minyoungi/experiments/image_only_smoke_v0/seed_repeat_diagnostic_v0/SEED_REPEAT_REPORT.md`

## Leakage policy

Training objective may use:

```text
T1w image
brain mask
FastSurfer ROI z/status derived from the same T1w segmentation
```

Training objective must not use:

```text
diagnosis_3class
CDR/CDRSB/MMSE
amyloid/tau/PET/CSF/APOE
cohort/site/scanner/field_strength
age/sex in v0 distillation loss
```

Diagnosis labels are allowed only for downstream evaluation/probe.

## v0 Model Design

### Student encoder

Start from small but not too tiny 3D encoder:

```text
Input: 1 x D x H x W T1w brain-masked volume
Downsample smoke: 64 x 80 x 64 preferred if memory allows
Fallback: 48 x 56 x 48
Embedding dim: 128 or 256
```

Important: avoid repeating the failed `32x40x32` tiny-only setup as the main v0, because it likely discards anatomical detail.

### Distillation heads

```text
embedding -> ROI z regression head: 16 outputs
embedding -> ROI status classification head: 16 x 3 outputs optional
```

Loss v0:

```text
L = MSE(predicted_roi_z16, teacher_roi_z16)
  + lambda_status * CE(predicted_status_16x3, teacher_status_16x3)
```

Initial conservative setting:

```text
lambda_status = 0.25
clip roi_z target to [-5, 5]
```

No diagnosis CE in distillation phase.

## Evaluation

### Stage A: ROI reconstruction/teacher imitation

Report on val/internal_test:

```text
ROI z MAE / RMSE per ROI
ROI z Pearson/Spearman per ROI if available
ROI status macro F1 per ROI
mean ROI reconstruction score
```

This must pass before diagnosis claims.

### Stage B: Frozen embedding diagnosis probe

Freeze encoder, train small linear/logistic probe on train split only.

Report:

```text
balanced accuracy
macro F1
CN/MCI/AD recall and F1
confusion matrix
cohort-wise metrics
age-bin metrics
```

Compare against:

```text
1. image-only tiny CNN smoke
2. ROI-only probe
3. ROI+age/sex probe
4. dummy majority
```

### Stage C: Optional fine-tune probe

Only after frozen probe works, run supervised fine-tuning with diagnosis CE and report separately as not pure representation probe.

## v0 Smoke Size

Because this is first implementation, use staged sizes:

### Smoke-0 CPU/schema check

```text
train: 8 rows
val: 4 rows
internal_test: 4 rows
no GPU claim
verify dataloader, target pivot, loss shapes
```

### Smoke-1 GPU minimal

```text
train: 80/class or 240/class if balanced diagnosis sampling is reused only for comparable smoke
val: 80/class
internal_test: 80/class
epochs: 5-8
```

Note: diagnosis-balanced sampling is acceptable for comparable smoke, but distillation target remains ROI-only.

### Scale v0

After smoke success:

```text
train: all train rows with ROI captions
val/internal_test: full split or capped full-class-balanced report side-by-side
```

## Artifact layout

Create:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/
  README.md
  run_roi_to_image_distill_v0.py
  run_linear_probe_v0.py
  runs/<run_id>/
    config.json
    sampled_rows.csv
    roi_targets_wide.csv
    metrics.json
    predictions.csv
    embedding_probe_results.csv
    REPORT.md
```

## Success criteria for v0

Minimum success:

```text
1. Dataloader joins image rows with complete 16 ROI targets.
2. ROI regression loss decreases on train and is finite on val.
3. Internal_test ROI z MAE is meaningfully below a train-mean baseline.
4. Frozen embedding diagnosis probe does not collapse CN prediction to 0.
```

Strong success:

```text
1. Frozen embedding probe improves over image-only smoke balanced accuracy/macro F1.
2. CN recall remains non-zero across seeds.
3. MCI recall/AD recall trade-off is less unstable than tiny CNN.
4. Cohort-wise failure is explainable rather than global collapse.
```

## Risks

1. ROI target is derived from FastSurfer segmentation on the same image, so this is not independent clinical supervision. It is anatomical distillation, not disease-label distillation.
2. MaskVol is a proxy, not confirmed eTIV/ICV.
3. ROI status bins use train-reference distribution, not clinical normative abnormality.
4. If the encoder only learns to approximate segmentation-derived volume, diagnosis improvement may remain limited for MCI.

## Next action

Implement `roi_to_image_distill_v0` with a tiny schema/smoke first. Do not launch full GPU scale until the dataloader/target pivot and ROI loss validation pass.
