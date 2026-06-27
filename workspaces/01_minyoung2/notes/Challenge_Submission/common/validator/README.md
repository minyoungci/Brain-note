# FOMO26 Container Validator

이 폴더는 공식 `fomo26/container-validator`를 로컬에서 설치하고, `.sif` 제출 후보를 task별로 검증하는 실행 지점을 제공한다.

## Quick Start

```bash
# 1. validator 설치/업데이트
Challenge_Submission/common/validator/setup_validator.sh

# 2. SIF 빌드
Challenge_Submission/common/container/scripts/build_sif.sh \
  --def Challenge_Submission/common/container/Apptainer.def \
  --out Challenge_Submission/common/container/builds/fomo26_submission.sif

# 3. Task1 검증
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif

# GPU 없는 환경 또는 GPU preflight를 건너뛰는 검증
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --no-gpu
```

커스텀 manifest 또는 timeout을 쓰는 경우:

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --manifest Challenge_Submission/common/validator/container-validator/container_validator/data/manifest.yaml \
  --timeout 120 \
  --no-gpu
```

전체 task 검증:

```bash
Challenge_Submission/common/validator/validate_all_tasks.sh \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --no-gpu
```

## 지원 task 이름

공식 validator task 이름:

```text
task1
task2
task3
task4
task5
task6_and_7
```

## Validator Phase

공식 validator가 확인하는 순서:

| Phase | 체크 |
|---|---|
| Phase 0 Preflight | Linux, Apptainer 설치, `nvidia-smi`, GPU 인식 |
| Phase 1 File | `.sif` 존재/읽기 가능/확장자, 입력 파일 매핑 |
| Phase 2 Container | 컨테이너 실행 가능, GPU 접근 가능 |
| Phase 3 Inference | `/app/predict.py` 실행 rc=0, 출력 파일 존재/비어있지 않음, 포맷 정합성 |

성공 메시지:

```text
================================================================
ALL X TESTS PASSED — container is ready to submit!
================================================================
```

## Validator가 실제로 호출하는 방식

validator는 컨테이너 안에서 아래 형태로 직접 실행한다.

```bash
python /app/predict.py <task-specific input args> --output /output/<subject_id>.<ext>
```

task id는 별도 환경변수나 CLI 인자로 전달되지 않는다. 따라서 공통 `.sif` 하나로 모든 task를 처리하려면 `/app/predict.py`가 입력 인자 조합으로 route를 선택해야 한다.

명확한 route:

- Task1: `--flair --dwi --adc` + one of `--t2s/--swi`
- Task2: `--flair --dwi` + one of `--t2s/--swi`, no `--adc`
- Task4: `--t2`
- Task6/7: `--input`

주의 route:

- Task3과 Task5는 모두 `--t1 --output <txt>` 형태라 CLI만으로는 구분이 약하다. validator fixture에서는 Task3 input basename이 `t1w.nii.gz`, Task5 basename이 `input.nii.gz`라 구분 가능하지만, 실제 Synapse에서도 같은지 제출 전 확인해야 한다.

## 로그 위치

검증 로그는 자동으로 여기에 저장된다.

```text
Challenge_Submission/common/validator/logs/
```

파일명 예:

```text
20260626_031500_task1_fomo26_submission_nogpu.log
```

## 현재 환경 주의

이 워크스테이션에서 `apptainer` 또는 `singularity`가 PATH에 없으면 빌드/검증은 실행할 수 없다. 그 경우 스크립트가 dependency error를 내고 멈춘다. validator 설치 자체는 가능하지만, 실제 container validation은 Apptainer 설치 후 실행한다.

### 2026-06-27 Task1/3/4/5/6/7 validator attempt

프로젝트 내부 conda env에 Apptainer 1.4.2를 설치해 Task1/3/4/5/6/7 통합 SIF를 검증했다.

```text
apptainer=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin/apptainer
sif=Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
manifest=Challenge_Submission/task1_infarct_cls/validation/task1_real_manifest.yaml
task1_log=Challenge_Submission/common/validator/logs/20260627_132554_task1_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
task3_log=Challenge_Submission/common/validator/logs/20260627_132516_task3_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
task4_log=Challenge_Submission/common/validator/logs/20260627_132554_task4_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
task5_log=Challenge_Submission/common/validator/logs/20260627_132516_task5_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
task6_and_7_log=Challenge_Submission/common/validator/logs/20260627_132533_task6_and_7_fomo26_task1_task3_task4_task5_task6_task7_submission_nopost_nogpu.log
```

결과:

```text
Phase 0 PASS: Linux, Apptainer 1.4.2
Phase 1 PASS: SIF file, extension, real task inputs for Task1/3/4/5/6_and_7
Phase 2 FAIL: container_instance_start
error=Failed to set mount propagation: Permission denied
```

추가 확인:

- `apptainer exec`도 같은 mount propagation 오류로 실패했다.
- `sudo -n apptainer instance start`도 같은 오류로 실패했다.
- `--contain`, `--containall`, `--compat`, `--userns`, `--no-mount ...` 옵션도 같은 오류로 실패했다.
- 따라서 현재 호스트에서는 공식 validator의 Apptainer 실행 단계가 환경 권한 문제로 차단된다.

재검증 명령:

```bash
PATH=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin:$PATH \
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest Challenge_Submission/task1_infarct_cls/validation/task1_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

```bash
PATH=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin:$PATH \
Challenge_Submission/common/validator/validate_sif.sh \
  --task task3 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest Challenge_Submission/task3_brain_age/validation/task3_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

```bash
PATH=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin:$PATH \
Challenge_Submission/common/validator/validate_sif.sh \
  --task task4 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest Challenge_Submission/task4_trigeminal_seg/validation/task4_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

```bash
PATH=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin:$PATH \
Challenge_Submission/common/validator/validate_sif.sh \
  --task task5 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest Challenge_Submission/task5_polymicrogyria_cls/validation/task5_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

```bash
PATH=/home/vlm/minyoung2/Challenge_Submission/common/validator/apptainer_env/bin:$PATH \
Challenge_Submission/common/validator/validate_sif.sh \
  --task task6_and_7 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest Challenge_Submission/task6_linear_probe/validation/task6_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

이 명령은 Apptainer `instance start`가 허용된 노드에서 통과해야 Synapse validation attempt를 쓰는 것이 안전하다.
