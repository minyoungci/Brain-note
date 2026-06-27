# Task5 Polymicrogyria Classification

## 제출 계약

- 입력 CLI: `--t1`
- 출력 CLI: `--output <path>.txt`
- 출력 형식: `.txt` 확률값 하나

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained AUROC 0.986 [0.952, 1.000]
scratch    AUROC 0.997 [0.983, 1.000]
Delta -0.010
```

## 해석

점수는 높지만 scratch도 천장에 가까워 site confound 또는 쉬운 split 가능성을 조심해야 한다. 제출은 가능하지만 연구적 주장에서는 강한 foundation gain으로 쓰지 않는다.

## 제출용 final 학습 상태

2026-06-27 완료:

```text
script=Challenge_Submission/task5_polymicrogyria_cls/train_task5_final.py
checkpoints:
  Challenge_Submission/task5_polymicrogyria_cls/checkpoints/task5_polymicro_seed0.pt
  Challenge_Submission/task5_polymicrogyria_cls/checkpoints/task5_polymicro_seed1.pt
  Challenge_Submission/task5_polymicrogyria_cls/checkpoints/task5_polymicro_seed2.pt
manifest=Challenge_Submission/task5_polymicrogyria_cls/checkpoints/task5_polymicro_manifest.json
```

checkpoint SHA256:

```text
6ff4005e53d9a638bbb089fce505d92b047434c7668b9185f9b5a1db66082e0b  task5_polymicro_seed0.pt
e75775138e819b71f8f44fcf7af8683e898f46e3d6f989586b00dd664cde2967  task5_polymicro_seed1.pt
01fed3d71e71e3b402c6e9fadc8b1bf0e47bded82f2796fc388339e115ce8be2  task5_polymicro_seed2.pt
```

SIF:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

host smoke:

```text
input=sub_01 t1
output=0.000346
strict_load=3 cls checkpoints
validator=Phase 0/1 PASS, Phase 2 blocked by host Apptainer mount propagation
log=Challenge_Submission/common/validator/logs/20260627_132516_task5_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
```

## 제출 전 체크리스트

- [x] Task5 classifier head checkpoint 확정
- [x] `/app/predict.py` Task5 route 구현
- [x] Task3와 같은 `--t1` CLI를 쓰므로 route 구분 방식 확정
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] output `.txt` 숫자 하나 확인
- [ ] container-validator pass
- [x] 120초/case timing pass(host smoke)
