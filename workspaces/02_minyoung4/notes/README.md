# minyoung4 — Fresh Brain Image AI Research Workspace

상태: Min 요청에 따라 기존 연구 디렉토리를 삭제하고 처음부터 다시 시작할 준비를 한 workspace.

## 현재 원칙

- 특정 연구 방향은 아직 확정하지 않는다.
- VLM/MLLM, JEPA, PET transfer, longitudinal modeling 등은 모두 후보일 뿐 기본 전제로 두지 않는다.
- 새 연구는 데이터 contract, leakage risk, baseline, validation design을 먼저 정의한 뒤 시작한다.
- 오래된 scaffold나 실험 산출물은 현재 연구 근거로 사용하지 않는다.

## 현재 유지 파일/디렉토리

```text
.git/
.gitignore
AGENTS.md
README.md
docs/
  README.md
  context/
    RESET_DELETION_INVENTORY.tsv
    cleanup_counts.json
    WORKSPACE_STATE.md
    VALIDATION_LOG.md
```

## 데이터 안전

- `/home/vlm/data/raw/` write/delete/move/rename 금지
- shared data, preprocessing outputs, checkpoint, log, experiment output은 명시 승인 없이 삭제하지 않는다.
- 새 실험 디렉토리, config, code는 연구 질문과 validation 기준이 확정된 뒤 만든다.

## 다음 단계

새 연구 시작 전 최소 정의:

```text
Research question:
Outcome:
Input / exposure:
Unit of analysis:
Cohort / filters:
Split policy:
Leakage risks:
Baseline:
Expected artifact:
Validation:
```
