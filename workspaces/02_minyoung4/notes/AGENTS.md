# AGENTS.md — minyoung4 Fresh Research Guardrails

이 파일은 `/home/vlm/minyoung4`에서 작업하는 agent를 위한 최소 가드레일이다.

## 0. Current State

Min이 기존 연구 디렉토리를 삭제하고 연구를 처음부터 다시 진행하라고 요청했다.
따라서 이 workspace는 특정 연구 방향을 전제하지 않는다.

중요:
- VLM/MLLM은 현재 기본 방향이 아니다.
- JEPA, PET transfer, longitudinal modeling, multimodal fusion 등도 아직 확정된 방향이 아니다.
- 이전 디렉토리/문서/실험 구조는 삭제되었으며 현재 claim의 근거로 사용하지 않는다.

## 1. Operating Principle

정확하고, 보수적이고, 검증 가능하게 일한다.

코딩 또는 분석 전 반드시 다음을 정의한다.

```text
Task:
Research question:
Outcome:
Input / exposure:
Unit of analysis:
Cohort / filters:
Split policy:
Leakage risks:
Files to change:
Expected artifact:
Validation:
Unclear assumptions:
Needs Min approval:
```

불명확하면 임의로 선택하지 말고 멈춘다.
특히 outcome, cohort, label, split, metric, compute scope는 조용히 정하지 않는다.

## 2. Workspace Safety

현재 workspace:

```text
/home/vlm/minyoung4
```

절대 삭제/수정 금지:

```text
/home/vlm/data/raw/
```

명시 승인 전 금지:
- shared data write/delete/move/rename
- checkpoint/log/output/raw/preprocessed artifact 삭제 또는 덮어쓰기
- GPU training, multi-GPU job, long preprocessing/inference
- 10개 이상 파일 bulk edit/delete
- 다른 workspace source wholesale copy

## 3. Required Inspection Before Edits

파일을 수정하기 전:

```bash
pwd
git status --short
git branch --show-current
```

데이터/연구 작업이면 관련 manifest/config/script를 먼저 읽고 실제 code path와 data flow를 확인한다.

## 4. GPU / Long Job Gate

GPU 또는 장시간 작업 전 반드시 확인하고 보고한다.

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

그 다음 command preview만 제시하고 Min 승인 전 실행하지 않는다.

## 5. Data and Neuroimaging Checks

Brain Image AI 작업에서는 관련 시점에 다음을 확인한다.

- subject/visit split isolation
- cohort/site/scanner leakage
- diagnosis/biomarker label semantics
- missingness and class imbalance
- volume path validity, affine/orientation/spacing when image loading is used
- tensor shape convention, e.g. `[B, C, D, H, W]`
- normalization scope: per-volume, global, cohort/site-specific, train-only statistics
- longitudinal temporal ordering if longitudinal data is used
- PET/MRI timing if PET target is used

## 6. Minimal Structure Policy

새 디렉토리는 필요할 때만 만든다.

허용되는 초기 context:

```text
docs/context/
```

새 연구 방향이 확정되기 전에는 `src/`, `configs/`, `experiments/`, `tests/`를 습관적으로 만들지 않는다.

## 7. Reporting Format

작업 종료 시 다음을 보고한다.

```text
Commands executed:
Files changed:
Artifacts produced:
Validation performed:
Observed results:
Remaining risks:
Next recommended action:
```

검증하지 않은 것은 완료라고 말하지 않는다.
