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

## Task1-v2 로컬 빌드 후보

Task1 Synapse validation AUROC 0.658 이후, Task1 route는 full fine-tuning v1 대신 frozen foundation feature + small linear-head ensemble 방식의 v2로 교체했다. 이 서버에는 `apptainer`/`singularity`가 없어 새 `.sif`를 직접 만들 수 없으므로, 로컬 빌드용 clean context를 따로 만들었다.

```text
Challenge_Submission/common/container/local_build_task1v2/
```

단일 다운로드용 tar도 생성해 두었다.

```text
Challenge_Submission/common/container/builds/fomo26_task1v2_local_build_context.tar
sha256=10daadc8d2426b2ed1b610535858ffd3cb51837cf367708c0f828646b4919426
size=1.5G
```

로컬에서 이 폴더를 내려받아 빌드한다.

```bash
cd Challenge_Submission/common/container/local_build_task1v2
mkdir -p builds
apptainer build --fakeroot --arch amd64 \
  builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif \
  Apptainer.def
sha256sum builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif \
  | tee builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif.sha256
```

예상 최종 SIF 경로:

```text
Challenge_Submission/common/container/local_build_task1v2/builds/fomo26_task1v2_task3_task4_task5_task6_task7_submission_nopost.sif
```

서버에서 완료한 v2 host smoke:

```text
Task1-v2 --swi: sub-01 -> 0.985124
Task1-v2 --t2s: sub-03 -> 0.009169
```

상세 절차:

```text
Challenge_Submission/common/container/local_build_task1v2/README_TASK1V2_LOCAL.md
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
