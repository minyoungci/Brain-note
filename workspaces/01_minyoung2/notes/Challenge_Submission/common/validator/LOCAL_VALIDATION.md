# Local Validator 실행 가이드

## 결론

현재 클라우드 서버는 Kubernetes 컨테이너 내부라 Apptainer `instance start`가 권한 문제로 막힌다.
따라서 FOMO26 제출 전 validator는 **Apptainer/Singularity가 정상 동작하는 Linux 로컬 머신 또는 별도 Linux VM/HPC 노드**에서 실행한다.

macOS/Windows 네이티브에서는 권장하지 않는다. 가능하면 Linux bare-metal, Linux VM, 또는 Apptainer가 검증된 WSL2 환경을 사용한다.

## 로컬로 가져갈 파일

필수:

```text
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
Challenge_Submission/common/container/builds/fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif.sha256
```

현재 SHA256:

```text
3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d
```

선택:

```text
Challenge_Submission/task1_infarct_cls/validation/task1_real_manifest.yaml
Challenge_Submission/task3_brain_age/validation/task3_real_manifest.yaml
Challenge_Submission/task4_trigeminal_seg/validation/task4_real_manifest.yaml
Challenge_Submission/task5_polymicrogyria_cls/validation/task5_real_manifest.yaml
Challenge_Submission/task6_linear_probe/validation/task6_real_manifest.yaml
Challenge_Submission/common/validator/validate_sif.sh
```

단, `*_real_manifest.yaml`은 현재 클라우드 서버의 절대 경로를 가리키므로, 로컬에서 쓰려면 입력 NIfTI 파일도 함께 복사하고 manifest 경로를 수정해야 한다.

## 권장 방법 A: 공식 validator fixture로 검증

로컬 Linux에서 실행:

```bash
mkdir -p ~/fomo26_validation
cd ~/fomo26_validation

# 1. SIF 복사 후 해시 확인
sha256sum fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif

# 기대값:
# 3e4d459a011ecd90187d6a6ce5a3c37915350afb303e2492993a2e5b9437a45d

# 2. validator clone. fixture가 Git LFS일 수 있으므로 git-lfs 필요.
git lfs install
git clone https://github.com/fomo26/container-validator
cd container-validator
git lfs pull

# 3. Python env
python3 -m venv .venv-validator
source .venv-validator/bin/activate
pip install -r requirements.txt

# 4. Apptainer smoke
apptainer exec ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif python --version

# 5. no-gpu validator
python3 container_validator/validate.py \
  --task task1 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu
```

성공 기준:

```text
ALL X TESTS PASSED - container is ready to submit!
```

GPU가 있는 Linux 로컬이면 no-gpu 통과 후 GPU validator도 실행한다.

```bash
python3 container_validator/validate.py \
  --task task1 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif
```

Task3/4/5/6_and_7도 같은 SIF로 검증한다.

```bash
python3 container_validator/validate.py \
  --task task3 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu

python3 container_validator/validate.py \
  --task task4 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu

python3 container_validator/validate.py \
  --task task5 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu

python3 container_validator/validate.py \
  --task task6_and_7 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --no-gpu
```

## 권장 방법 B: 우리 real Task1 샘플로 검증

공식 fixture 대신 우리가 이미 smoke에 쓴 real Task1 2건을 로컬로 복사해 검증할 수 있다.

로컬에 복사할 입력:

```text
sub-01/ses-01/flair.nii.gz
sub-01/ses-01/dwi_b1000.nii.gz
sub-01/ses-01/adc.nii.gz
sub-01/ses-01/swi.nii.gz
sub-03/ses-01/flair.nii.gz
sub-03/ses-01/dwi_b1000.nii.gz
sub-03/ses-01/adc.nii.gz
sub-03/ses-01/t2s.nii.gz
```

그 다음 `task1_real_manifest.yaml`의 절대 경로를 로컬 경로로 수정하고 실행한다.

```bash
python3 container_validator/validate.py \
  --task task1 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest /path/to/task1_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

Task4 real sample:

```text
sub-01/ses-01/t2w.nii.gz
sub-02/ses-01/t2w.nii.gz
```

Task3/5/6 real sample:

```text
Task3:
  sub-001/ses-01/t1w.nii.gz
  sub-002/ses-01/t1w.nii.gz
Task5:
  sub_01/ses_01/t1.nii.gz
  sub_02/ses_01/t1.nii.gz
Task6/7:
  Task1 sub-01/ses-01/swi.nii.gz
  Task3 sub-001/ses-01/t1w.nii.gz
```

Task4 real manifest 실행:

```bash
python3 container_validator/validate.py \
  --task task4 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest /path/to/task4_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

Task3/5/6 real manifest도 같은 방식이다.

```bash
python3 container_validator/validate.py \
  --task task3 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest /path/to/task3_real_manifest.yaml \
  --timeout 120 \
  --no-gpu

python3 container_validator/validate.py \
  --task task5 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest /path/to/task5_real_manifest.yaml \
  --timeout 120 \
  --no-gpu

python3 container_validator/validate.py \
  --task task6_and_7 \
  --sif ../fomo26_task1_task3_task4_task5_task6_task7_submission_nopost.sif \
  --manifest /path/to/task6_real_manifest.yaml \
  --timeout 120 \
  --no-gpu
```

## 제출 판단

로컬에서 다음이 완료되기 전에는 Synapse 제출하지 않는다.

1. `apptainer exec ... python --version` 통과
2. `container-validator --task task1 --no-gpu` 통과
3. `container-validator --task task3 --no-gpu` 통과
4. `container-validator --task task4 --no-gpu` 통과
5. `container-validator --task task5 --no-gpu` 통과
6. `container-validator --task task6_and_7 --no-gpu` 통과
7. 가능하면 GPU validator 통과
8. validator log 저장
9. SIF SHA256 재확인
10. Synapse에서 반드시 team submission으로 제출
