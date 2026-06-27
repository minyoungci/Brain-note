# Task1 Infarct Classification

## 제출 계약

- 입력 CLI: `--flair`, `--dwi`, `--adc`, one of `--t2s`/`--swi`
- 출력 CLI: `--output <path>.txt`
- 출력 형식: `.txt` 숫자 하나
- 의미: infarct positive probability
- 예: `0.750`

## 현재 내부 성능

`experiments/phase_b/downstream_all/SUMMARY.md` 기준:

```text
pretrained AUROC 0.942 [0.818, 1.000]
scratch    AUROC 0.596 [0.345, 0.836]
Delta +0.346
```

## 제출용 final checkpoint

2026-06-26에 기존 `eval_finetune.py`와 동일한 Task1 finetune recipe로 전체 Task1 학습셋 21명을 사용해 final 3-seed ensemble을 학습했다.

```text
Challenge_Submission/task1_infarct_cls/checkpoints/task1_infarct_seed0.pt
Challenge_Submission/task1_infarct_cls/checkpoints/task1_infarct_seed1.pt
Challenge_Submission/task1_infarct_cls/checkpoints/task1_infarct_seed2.pt
Challenge_Submission/task1_infarct_cls/checkpoints/task1_infarct_manifest.json
Challenge_Submission/task1_infarct_cls/checkpoints/task1_infarct_checkpoints.sha256
```

학습 설정:

```text
size=128
epochs=40
batch_size=4
lr=1e-4
seeds=0,1,2
n=21, positive=13
modalities=adc,dwi_b1000,flair,t2star
```

주의: final fit의 train AUROC=1.0은 제출용 전체 학습셋 fit 결과다. 일반화 성능 주장은 OOF 평가 `AUROC 0.942 [0.818,1.000]`를 기준으로 한다.

## 구현 원칙

- 공통 foundation: `resenc_s3d_wg0.5/latest.pt`
- 모달: `adc`, `dwi_b1000`, `flair`, `t2star = swi | t2s`
- 전처리: pretrain과 같은 Yucca-compatible path
- 출력: 확률값 하나만 포함하는 text

## 제출 전 체크리스트

- [x] Task1 finetuned checkpoint 확정
- [x] `/app/predict.py` Task1 route 구현
- [x] `--t2s` 케이스와 `--swi` 케이스 둘 다 처리
- [x] sample input dry-run
- [x] `args.output` 경로에 그대로 저장, 파일명 하드코딩 금지
- [x] output `.txt` 숫자 하나 확인
- [ ] container-validator pass
- [x] 120초/case timing pass
- [x] final `.sif` sha256 기록

## 2026-06-27 SIF/validator 상태

제출 후보 SIF:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

SIF 빌드 방식:

```text
Challenge_Submission/common/container/Apptainer.nopost.def
base=pytorch/pytorch:2.11.0-cuda12.6-cudnn9-runtime
```

공식 validator 실행 결과:

```text
log=Challenge_Submission/common/validator/logs/20260626_053516_task1_fomo26_task1_submission_nopost_nogpu.log
Phase 0 PASS
Phase 1 PASS
Phase 2 FAIL: Apptainer instance start failed on this host
error=Failed to set mount propagation: Permission denied
```

위 로그는 Task1-only SIF로 처음 확인한 기록이다. 동일한 Apptainer 런타임 문제가 현재 Task1/3/4/5/6/7 통합 SIF에서도 재현되므로, 최종 제출 전에는 통합 SIF로 Apptainer가 허용된 Linux 노드에서 validator를 다시 실행해야 한다.

판단:

- 실패 지점은 `/app/predict.py`나 모델 출력이 아니라 현재 호스트의 Apptainer 런타임 권한 문제다.
- 이 워크스테이션은 rootless/sudo Apptainer 모두 `instance start`와 `exec`에서 같은 mount propagation 오류가 난다.
- Synapse 제출 전에는 Apptainer가 정상 동작하는 노드에서 동일 SIF로 공식 validator를 다시 통과시켜야 한다.

host-level predict 검증:

```text
sub_01_swi: 0.999968, elapsed 9s, PASS probability txt
sub_03_t2s: 0.002578, elapsed 8s, PASS probability txt
outputs=Challenge_Submission/task1_infarct_cls/validation/host_predict_outputs/
```
