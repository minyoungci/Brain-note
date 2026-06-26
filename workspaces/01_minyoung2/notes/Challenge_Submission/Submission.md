# FOMO26 Challenge Submission 준비 문서

> 이 파일은 제출 작업을 시작하기 전에 항상 먼저 읽는다.  
> 목적은 Synapse 제출 규칙, 컨테이너 구조, task별 준비 상태, validation attempt 사용 조건을 한 곳에 고정하는 것이다.

## 0. 현재 제출 규칙 스냅샷

기준일: 2026-06-26, Synapse guideline 사용자 확인 내용.

제출 산출물:

- Synapse에 올리는 파일은 Apptainer/Singularity `.sif` 컨테이너다.
- 컨테이너 내부에는 반드시 `/app/predict.py`가 있어야 한다.
- `/input`과 `/output`은 런타임에 마운트된다. `.sif` 안에 실제 데이터로 포함하지 않는다.
- 빌드 예:

```bash
apptainer build --fakeroot my_model.sif Apptainer.def --arch amd64
```

중요 규칙:

- 반드시 **Submit as a Team**으로 제출한다. 개인 제출은 INVALID 처리될 수 있다.
- 제출 전 `container-validator` 로컬 검증을 통과해야 한다.
- task당/track당 유효 validation attempt는 최대 3회다.
- 모든 task는 동일한 foundation checkpoint에서 출발해야 한다.
- 현재 해석은 **track당 하나의 공통 `.sif`를 만들고, 7개 task에 같은 `.sif`를 사용**하는 것이다. 각 task 폴더는 task별 구현/검증/로그를 정리하는 staging 영역이다.

## 1. 디렉토리 역할

```text
Challenge_Submission/
├── Submission.md                    # 항상 먼저 읽는 운영 문서
├── common/
│   ├── checkpoints/                 # 공통 foundation ckpt, task head ckpt 포인터/복사본
│   ├── container/                   # 공통 Apptainer.def, /app/predict.py, 패키징 스크립트
│   ├── validator/                   # container-validator 실행 로그와 결과
│   └── logs/                        # 공통 빌드/검증 로그
├── task1_infarct_cls/
├── task2_meningioma_seg/
├── task3_brain_age/
├── task4_trigeminal_seg/
├── task5_polymicrogyria_cls/
├── task6_linear_probe/
└── task7_fairness/
```

각 task 폴더의 하위 구조:

```text
container/      task별 predict route, 샘플 I/O, validator fixture
checkpoints/    task head 또는 adapter ckpt 포인터
validation/     local validator 결과, dry-run 출력
logs/           train/inference/timing 로그
notes/          실패 사례, Synapse 이슈, TODO
```

## 2. 공통 컨테이너 원칙

컨테이너 내부 목표 구조:

```text
/
├── app/
│   ├── predict.py                   # 필수 entrypoint
│   ├── pretrain/                    # ResEnc/S3D/InfoNCE 모델 코드 최소 복사
│   ├── downstream/                  # Yucca 전처리, loader, inference 코드 최소 복사
│   └── checkpoints/
│       ├── foundation_latest.pt     # wg0.5 foundation checkpoint
│       ├── task1_head.pt
│       ├── task2_seg.pt
│       ├── task3_head.pt
│       ├── task4_seg.pt
│       ├── task5_head.pt
│       └── embedding_config.json
├── input/                           # runtime mount
└── output/                          # runtime mount
```

공통 foundation checkpoint:

```text
experiments/phase_b/resenc_s3d_wg0.5/latest.pt
```

주의:

- checkpoint partial load는 금지한다. missing/unexpected key가 있으면 실패해야 한다.
- Task1/2의 `swi`와 `t2s`는 논리 모달 `t2star = swi | t2s`로 처리한다.
- Task1-5는 finetune 가능하다.
- Task6/7은 finetune 금지다. frozen embedding만 출력한다.
- segmentation task는 모델 공간 출력이 아니라 원본 NIfTI 공간으로 resample-back 해야 한다.

## 3. Task별 입출력 계약

공식 validator commit `d442af2e9bdade58be20c2ee0cbabf8d0439e32b` 기준이다. `predict.py`는 아래 CLI 인자를 받아야 한다. `--output` 값은 evaluator가 넘겨주는 경로에 그대로 저장해야 하며, 파일명을 하드코딩하지 않는다.

| Task | 유형 | 입력 CLI | 출력 CLI / 파일 |
|---|---|---|---|
| Task1 Infarct | binary cls | `--flair`, `--dwi`, `--adc`, one of `--t2s`/`--swi` | `--output <path>.txt`, 확률값 `[0,1]` 하나 |
| Task2 Meningioma | binary seg | `--flair`, `--dwi`, one of `--t2s`/`--swi` | `--output <path>.nii.gz`, binary mask `{0,1}` |
| Task3 Brain Age | regression | `--t1` | `--output <path>.txt`, scalar 하나 |
| Task4 Trigeminal | multiclass seg | `--t2` | `--output <path>.nii.gz`, multiclass mask `{0,1,2}` |
| Task5 Polymicrogyria | binary cls | `--t1` | `--output <path>.txt`, 확률값 `[0,1]` 하나 |
| Task6 Linear Probe | embedding | `--input` | `--output <path>.npy`, 1D fixed-length embedding |
| Task7 Fairness | embedding | `--input` | `--output <path>.npy`, 1D fixed-length embedding |

주의: validator는 task마다 실제 입력 fixture를 여러 케이스로 호출한다. Task1/2는 `swi` 케이스와 `t2s` 케이스가 모두 있으므로 둘 다 처리해야 한다.

공통 `.sif` 라우팅 리스크:

- validator는 `python /app/predict.py ...`만 실행하고 task id를 별도 인자나 환경변수로 넘기지 않는다.
- Task1/2/4/6은 CLI 조합으로 구분 가능하다.
- **Task3와 Task5는 둘 다 `--t1 --output <txt>`라 CLI만으로는 모호하다.** validator fixture에서는 Task3 입력 basename이 `t1w.nii.gz`, Task5 입력 basename이 `input.nii.gz`라 구분 가능하지만, Synapse 실환경도 같은지 확인 전까지는 제출 리스크로 둔다.
- 해결 후보: `--t1` 파일 basename/path 기반 route, 이미지 shape/spacing 기반 route, 또는 주최측에 task id 전달 여부 문의.

## 4. 현재 내부 성능 근거

출처: `experiments/phase_b/downstream_all/SUMMARY.md`.

| Task | 현재 결과 | 제출 판단 |
|---|---|---|
| Task1 Infarct | pretrained AUROC 0.942 vs scratch 0.596, Delta +0.346 | 우선 제출 준비 대상 |
| Task2 Meningioma | Dice 0.127 vs scratch 0.107, CI 겹침 | 멀티모달 개선 필요 |
| Task3 Brain Age | Pearson 0.947 vs scratch 0.910, Delta +0.037 | 제출 가능, 차이는 작음 |
| Task4 Trigeminal | Dice 0.413/NSD 0.786 vs scratch 0.164/0.344 | 우선 제출 준비 대상 |
| Task5 Polymicrogyria | AUROC 0.986 vs scratch 0.997 | 제출 가능하나 ceiling/site confound 주의 |
| Task6 Linear Probe | AUROC 0.817 | embedding route 준비 필요 |
| Task7 Fairness | 로컬 그룹 메타 없음 | Task6와 같은 embedding route, 주최측 평가 |

## 5. 제출 전 게이트

Synapse validation attempt를 쓰기 전에 아래를 모두 통과해야 한다.

- [ ] `/app/predict.py`가 컨테이너 내부에서 직접 실행된다.
- [ ] `/input` read-only, `/output` write-only 가정으로 동작한다.
- [ ] task별 샘플 입력에 대해 출력 파일이 생성된다.
- [ ] 출력 형식이 validator 요구와 일치한다.
- [ ] classification/regression `.txt`는 숫자 하나만 포함한다.
- [ ] segmentation `.nii.gz`는 원본 입력 공간 shape/affine/header와 일치한다.
- [ ] Task4 label range가 `{0,1,2}`를 넘지 않는다.
- [ ] Task2 label range가 `{0,1}`를 넘지 않는다.
- [ ] Task6/7 `.npy`는 1D fixed-length float embedding이다.
- [ ] 120초/case 제한 안에서 추론된다.
- [ ] CPU-only validator 또는 no-gpu validator가 통과한다.
- [ ] 가능하면 GPU local dry-run도 통과한다.
- [ ] final `.sif` sha256, build log, validator log가 저장되어 있다.

현재 Task1 상태(2026-06-26):

- SIF 빌드 성공:
  `Challenge_Submission/common/container/builds/fomo26_task1_submission_nopost.sif`
- SHA256:
  `6d77abf9052149f3c6b3e1b27157987a63e02b2c34612160976f6d608c5d370a`
- 공식 validator no-gpu 실행은 Phase 0/1까지 통과했지만 Phase 2에서 호스트 Apptainer 권한 문제로 실패:
  `Failed to set mount propagation: Permission denied`
- 실패 로그:
  `Challenge_Submission/common/validator/logs/20260626_053516_task1_fomo26_task1_submission_nopost_nogpu.log`
- 같은 `predict.py`와 checkpoint를 host Python에서 manual preprocessing 경로로 실행한 Task1 real-data smoke는 통과:
  `sub_01_swi=0.999968`, `sub_03_t2s=0.002578`, 각각 120초 제한 이내.

해석: Task1 모델/출력 포맷은 준비됐지만, 이 워크스테이션에서는 Apptainer `instance start` 자체가 막혀 local validator 최종 통과를 증명하지 못했다. Synapse 제출 전 Apptainer가 정상 동작하는 별도 노드에서 동일 SIF로 공식 validator를 재실행해야 한다.

## 6. 우선순위

1. **Task1 route 구현**  
   가장 단순한 `.txt` 출력이고 현재 성능이 좋다. 공통 `predict.py`의 첫 route로 만든다.

2. **Task4 route 구현**  
   리더보드 가중치 25%이고 foundation 이득이 가장 명확하다. 다만 resample-back과 multiclass 출력 검증이 필요하다.

3. **Task3/5 route 구현**  
   Task1과 같은 cls/reg 계열이라 공통 head 추론 경로를 재사용한다.

4. **Task6/7 embedding route 구현**  
   finetune 금지 조건을 위반하지 않도록 frozen encoder only로 고정한다.

5. **Task2 개선 및 route 구현**  
   현재 가장 약한 task다. 멀티모달 stem widening 또는 late fusion 개선 후 제출 후보를 다시 정한다.

## 7. Task1 즉시 작업 계획

Task1은 제출 준비의 첫 target이다.

필요 작업:

- [x] `common/container/app/predict.py` 작성
- [x] Task 감지/라우팅 설계: Task1 입력 모달 조합이면 infarct route 실행
- [x] `adc`, `dwi_b1000`, `flair`, `t2star(swi|t2s)` 로딩
- [x] Yucca-compatible/manual preprocessing 적용
- [x] `wg0.5` 기반 Task1 final checkpoint 로드
- [x] Task1 final 3-seed checkpoint 생성
- [x] Task1 final 3-seed checkpoint를 `/app/predict.py`에서 로드
- [x] 확률값 하나를 `.txt`로 저장
- [x] sample case dry-run
- [x] SIF build
- [ ] official validator pass
- [x] 120초/case timing

Synapse에 바로 올리는 조건:

- local validator pass
- output numeric text 확인
- task1 timing pass
- `.sif` sha256 기록
- Team submission 설정 확인

## 8. 로컬 검증 시스템

공식 `fomo26/container-validator`는 `Challenge_Submission/common/validator/` 아래에서 관리한다.

### 8.1 Validator 설치/업데이트

```bash
Challenge_Submission/common/validator/setup_validator.sh
```

이 스크립트는 다음을 수행한다.

- `https://github.com/fomo26/container-validator` clone/update
- `.venv-validator` 생성
- `requirements.txt` 설치
- `VALIDATOR_VERSION.txt`에 commit 기록

현재 설치된 validator:

```text
repo=https://github.com/fomo26/container-validator
commit=d442af2e9bdade58be20c2ee0cbabf8d0439e32b
```

### 8.2 SIF 빌드

```bash
Challenge_Submission/common/container/scripts/build_sif.sh \
  --def Challenge_Submission/common/container/Apptainer.def \
  --out Challenge_Submission/common/container/builds/fomo26_submission.sif
```

성공하면 다음이 생성된다.

```text
Challenge_Submission/common/container/builds/fomo26_submission.sif
Challenge_Submission/common/container/builds/fomo26_submission.sif.sha256
Challenge_Submission/common/container/builds/fomo26_submission.sif.build.log
```

### 8.3 Task별 검증

GPU 환경:

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif
```

GPU가 없거나 GPU preflight를 건너뛸 때:

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --no-gpu
```

지원 task 이름:

```text
task1
task2
task3
task4
task5
task6_and_7
```

전체 task 검증:

```bash
Challenge_Submission/common/validator/validate_all_tasks.sh \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --no-gpu
```

120초/case 제한에 맞춘 단일 task 검증:

```bash
Challenge_Submission/common/validator/validate_sif.sh \
  --task task1 \
  --sif Challenge_Submission/common/container/builds/fomo26_submission.sif \
  --timeout 120 \
  --no-gpu
```

검증 로그:

```text
Challenge_Submission/common/validator/logs/
```

성공 기준:

```text
================================================================
ALL X TESTS PASSED — container is ready to submit!
================================================================
```

현재 이 머신에서 `apptainer`/`singularity`가 PATH에 없으면 빌드와 검증은 실행할 수 없다. 그 경우 스크립트가 dependency error로 멈춘다. validator 설치 자체는 가능하다.

## 9. 금지/주의

- validation attempt로 디버깅하지 않는다.
- task별로 다른 foundation checkpoint를 쓰지 않는다.
- Task6/7에 supervised finetune head를 넣지 않는다.
- `swi`/`t2s` 중 하나만 있다고 누락 처리하지 않는다.
- segmentation 출력은 전처리 공간 그대로 저장하지 않는다.
- 성능표만 보고 제출하지 않는다. validator log가 없는 제출물은 제출 후보가 아니다.
