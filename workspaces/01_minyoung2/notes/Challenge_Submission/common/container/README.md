# Common Container Build Area

이 폴더는 최종 제출 `.sif`를 만들기 위한 공통 컨테이너 작업 공간이다.

## 예상 파일

```text
container/
├── Apptainer.def          # 표준 빌드 정의, %post 포함
├── Apptainer.nopost.def   # 현재 Task1/3/4/5/6/7 제출 후보 빌드 정의, %post 없이 vendor 사용
├── app/
│   ├── predict.py         # 컨테이너 내부에서는 /app/predict.py
│   ├── pretrain/models.py
│   ├── vendor/            # nopost 빌드용 pure-python deps
│   └── checkpoints/       # Task1/3/4/5 ckpt + Task6/7 foundation ckpt
├── scripts/
│   └── build_sif.sh       # SIF 빌드 래퍼
└── builds/                # local build output, gitignore
```

## 빌드

```bash
Challenge_Submission/common/container/scripts/build_sif.sh \
  --def Challenge_Submission/common/container/Apptainer.def \
  --out Challenge_Submission/common/container/builds/fomo26_submission.sif
```

성공 시 `.sif.sha256` 파일이 함께 생성된다.

현재 Task1/3/4/5/6/7 제출 후보는 이 환경의 Apptainer `%post` 실행 제약을 피하기 위해 no-post 정의로 빌드했다.

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
sha256=3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
size=5.2G
```

## 검증

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu
```

Task3/4/5/6_and_7도 같은 SIF로 검증한다.

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task4 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu

Challenge_Submission/common/validator/validate_sif.sh \
  --task task6_and_7 \
  --sif Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu
```

현재 워크스테이션에서는 Apptainer `instance start`가 `Failed to set mount propagation: Permission denied`로 실패한다. 따라서 공식 validator 최종 통과는 Apptainer 실행이 허용된 별도 노드에서 같은 SIF로 재확인해야 한다.
