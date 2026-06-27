# Task6 Linear Probe

## 제출 계약

- 입력 CLI: `--input`
- 출력 CLI: `--output <path>.npy`
- 출력 형식: `.npy` 1D fixed-length embedding
- finetune: 금지

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
Task1 data frozen probe AUROC 0.817
```

## 구현 원칙

- supervised head를 넣지 않는다.
- frozen foundation encoder/global vector만 사용한다.
- embedding dimension은 `320`으로 고정한다.
- Task7과 같은 embedding route를 공유한다.

## 제출 route 상태

2026-06-27 완료:

```text
foundation=Challenge_Submission/common/container/app/checkpoints/foundation_resenc_s3d_wg0.5_latest.pt
route=python /app/predict.py --input /input/image.nii.gz --output /output/output.npy
embedding_shape=(320,)
embedding_dtype=float32
```

SIF:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

host smoke:

```text
inputs:
  Task1 sub-01 swi
  Task3 sub-001 t1w
outputs:
  both shape=(320,), dtype=float32, finite=True
  dims_equal=True
validator=Phase 0/1 PASS, Phase 2 blocked by host Apptainer mount propagation
log=Challenge_Submission/common/validator/logs/20260627_132533_task6_and_7_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
```

## 제출 전 체크리스트

- [x] embedding dimension 확정
- [x] frozen-only route 검증
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] `.npy` 1D float output 검증
- [ ] container-validator pass
- [x] 120초/case timing pass(host smoke)
