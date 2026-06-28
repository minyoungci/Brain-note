# Task1-v2 Local Build and Validator

이 폴더는 Task1-v2가 반영된 FOMO26 제출 컨테이너를 로컬에서 빌드하기 위한 clean build context다.

## 포함 내용

- `/app/predict.py`: Task1-v2 route 포함
- `/app/pretrain/models.py`: ResEnc/S3D foundation model 정의
- `/app/vendor`: no-post 빌드용 vendored Python dependency
- `/app/checkpoints/foundation_resenc_s3d_wg0.5_latest.pt`
- `/app/checkpoints/task1_v2_frozen_seed0.pt` ... `seed4.pt`
- Task3/4/5/6/7 기존 route용 checkpoint

Task1-v2는 `DWI + ADC + FLAIR`를 각각 foundation encoder에 통과시킨 뒤 global vector를 mean-fusion하고, 5-seed linear head ensemble로 확률을 낸다. 공식 Task1 interface 때문에 `--swi` 또는 `--t2s`는 입력으로 받지만, v2 모델에서는 내부 feature로 사용하지 않는다.

## 로컬 빌드

이 폴더를 로컬 Linux/Apptainer 가능 환경으로 다운로드한 뒤, 이 폴더의 상위 경로에서 실행한다.

```bash
cd Challenge_Submission/common/container/local_build_task1v2
mkdir -p builds
apptainer build --fakeroot --arch amd64 \
  builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif \
  Apptainer.def
sha256sum builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif \
  | tee builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif.sha256
```

빌드 산출물:

```text
Challenge_Submission/common/container/local_build_task1v2/builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif
```

## Validator

`container-validator`가 설치된 로컬 환경에서 실행한다.

```bash
python3 container_validator/validate.py \
  --task task1 \
  --sif /path/to/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif
```

GPU 없이 포맷만 확인할 때:

```bash
python3 container_validator/validate.py \
  --task task1 \
  --sif /path/to/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu
```

성공 기준:

```text
================================================================
ALL X TESTS PASSED — container is ready to submit!
================================================================
```

## 서버에서 완료한 사전 확인

- Host Python Task1-v2 `--swi` smoke: `sub-01 -> 0.985124`
- Host Python Task1-v2 `--t2s` smoke: `sub-03 -> 0.009169`
- `predict.py` syntax check 통과
- 이 서버에는 `apptainer`/`singularity`가 없어 SIF 생성과 최종 validator는 로컬에서 실행해야 한다.
