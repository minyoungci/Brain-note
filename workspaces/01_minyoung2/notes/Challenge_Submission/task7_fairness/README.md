# Task7 Fairness

## 제출 계약

- 입력 CLI: `--input`
- 출력 CLI: `--output <path>.npy`
- 출력 형식: `.npy` 1D fixed-length embedding
- finetune: 금지

## 현재 상태

로컬에는 그룹/인구통계 메타가 없어 fairness metric을 내부에서 계산할 수 없다. 챌린지 서버가 Task6과 같은 embedding을 받아 그룹별 OvR AUROC/F1을 평가한다.

## 구현 원칙

- Task6 embedding route와 동일하게 유지한다.
- task-specific supervised adaptation을 넣지 않는다.
- embedding preprocessing은 Task6과 동일해야 한다.

## 제출 route 상태

Task7은 공식 validator task 이름과 출력 계약이 Task6과 동일한 `task6_and_7`이다. 현재 route는 Task6과 같은 frozen foundation embedding을 저장한다.

```text
route=python /app/predict.py --input /input/image.nii.gz --output /output/output.npy
embedding_shape=(320,)
embedding_dtype=float32
finetune=False
SIF=Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
validator=Phase 0/1 PASS, Phase 2 blocked by host Apptainer mount propagation
```

## 제출 전 체크리스트

- [x] Task6/7 common embedding route 확정
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] `.npy` 1D fixed-length output 검증
- [x] no-finetune 위반 여부 코드 리뷰
- [ ] container-validator pass
- [x] 120초/case timing pass(host smoke)
