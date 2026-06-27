# Task4 Trigeminal Segmentation

## 제출 계약

- 입력 CLI: `--t2`
- 출력 CLI: `--output <path>.nii.gz`
- 출력 형식: `.nii.gz` multiclass mask `{0,1,2}`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained Dice 0.413 / NSD 0.786
scratch    Dice 0.164 / NSD 0.344
Delta Dice +0.249, NSD +0.442
```

## 구현 원칙

- Task1과 함께 우선 제출 준비 대상이다.
- 리더보드 가중치가 큰 voxel-level task다.
- multiclass 출력 `{0,1,2}`와 원본 공간 resample-back이 핵심 검증 포인트다.
- 제출용 모델은 `seg_v2` 최고 검증 recipe를 multiclass로 확장한다.
  - Yucca-compatible 1mm preprocessing
  - crop128 foreground-biased patch training
  - pretrained ResEnc-S3D U-Net stem/encoder/decoder transfer
  - final head만 3-class `{0,1,2}`로 새로 학습

## 제출용 final 학습 상태

2026-06-27 완료:

```text
script=Challenge_Submission/task4_trigeminal_seg/train_task4_final.py
logs=Challenge_Submission/task4_trigeminal_seg/logs/task4_final_seed{0,1,2}.log
target checkpoints:
  Challenge_Submission/task4_trigeminal_seg/checkpoints/task4_trigeminal_seed0.pt
  Challenge_Submission/task4_trigeminal_seg/checkpoints/task4_trigeminal_seed1.pt
  Challenge_Submission/task4_trigeminal_seg/checkpoints/task4_trigeminal_seed2.pt
```

checkpoint SHA256:

```text
57ae96c5287085c6e6d1b7270d5a121223c931c656588b8732d678a81b9eeeae  task4_trigeminal_seed0.pt
80c960ae3bded3728e74c26524c1d9eade38e83f91736e5692c49f9f6aaf7190  task4_trigeminal_seed1.pt
0a2ad65d5a46c939d3515e7d949c1f7420511f100ec7220ea9a2dac58fb60727  task4_trigeminal_seed2.pt
```

SIF:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

## 제출 route 상태

`Challenge_Submission/common/container/app/predict.py`에 Task4 route를 추가했다.

입력:

```bash
python /app/predict.py --t2 /input/t2w.nii.gz --output /output/output.nii.gz
```

동작:

- nibabel/torch-only manual preprocessing
- crop_to_nonzero + volume-wise z-norm/rescale + 1mm trilinear resample
- 자체 sliding-window softmax ensemble
- 원본 shape로 restore
- `uint8` NIfTI label `{0,1,2}` 저장

검증 완료:

```text
fake restore smoke:
  input shape=(360,512,512)
  preprocessed shape=(180,250,234)
  restored shape=(360,512,512)
  label range subset {0,1,2}

trained host predict smoke:
  input=sub-01 t2w
  elapsed=14s
  output shape=(360,512,512)
  label range=[0,1,2]
  output=Challenge_Submission/task4_trigeminal_seg/validation/host_predict_sub01.nii.gz
```

Task4 real-data validator manifest:

```text
Challenge_Submission/task4_trigeminal_seg/validation/task4_real_manifest.yaml
```

## 제출 전 체크리스트

- [x] Task4 seg checkpoint 확정
- [x] sliding-window inference 구현
- [x] multiclass argmax 출력 구현
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] 원본 공간 resample-back smoke 검증
- [x] label range `{0,1,2}` smoke 검증
- [x] trained checkpoint로 real-case inference 검증
- [x] SIF rebuild
- [ ] container-validator pass
- [x] 120초/case timing pass(host smoke 14s)
