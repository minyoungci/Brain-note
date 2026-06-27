# Task3 Brain Age Regression

## 제출 계약

- 입력 CLI: `--t1`
- 출력 CLI: `--output <path>.txt`
- 출력 형식: `.txt` 숫자 하나
- 의미: predicted age
- 예: `35`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained Pearson 0.947 [0.937, 0.955]
scratch    Pearson 0.910 [0.891, 0.927]
Delta +0.037
```

## 구현 원칙

- Task1/5와 같은 cls/reg inference route를 재사용한다.
- final fit에서는 age target을 전체 training set mean/std로 표준화해 학습하고, predict 시 실제 나이 단위로 복원한다.
- 출력 text에는 나이 값 하나만 쓴다.

## 제출용 final 학습 상태

2026-06-27 완료:

```text
script=Challenge_Submission/task3_brain_age/train_task3_final.py
checkpoints:
  Challenge_Submission/task3_brain_age/checkpoints/task3_brainage_seed0.pt
  Challenge_Submission/task3_brain_age/checkpoints/task3_brainage_seed1.pt
  Challenge_Submission/task3_brain_age/checkpoints/task3_brainage_seed2.pt
manifest=Challenge_Submission/task3_brain_age/checkpoints/task3_brainage_manifest.json
```

checkpoint SHA256:

```text
2a9c90c22d8d1bbd94ffd8e13112398515ca30dc55a90a1eaed11e8de9abb2f5  task3_brainage_seed0.pt
fb53d683c046fdbf04028a50d8fc6d1440e76d468c6fe069a019d3a45f55d5dd  task3_brainage_seed1.pt
2c83c3da08898bb967aaf0d124f708621fb92945eeb9fd792b27a73119c6c061  task3_brainage_seed2.pt
```

SIF:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

host smoke:

```text
input=sub-001 t1w
output=71.259161
label=72
strict_load=3 reg checkpoints
validator=Phase 0/1 PASS, Phase 2 blocked by host Apptainer mount propagation
log=Challenge_Submission/common/validator/logs/20260627_132516_task3_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
```

## 제출 전 체크리스트

- [x] Task3 regression head checkpoint 확정
- [x] `/app/predict.py` Task3 route 구현
- [x] Task5와 같은 `--t1` CLI를 쓰므로 route 구분 방식 확정
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] output `.txt` 숫자 하나 확인
- [ ] container-validator pass
- [x] 120초/case timing pass(host smoke)
