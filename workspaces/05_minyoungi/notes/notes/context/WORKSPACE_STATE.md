# WORKSPACE_STATE — VLM literature/task-design workspace

Updated: 2026-05-19

## 현재 상태

`/home/vlm/minyoungi`는 **VLM/MLLM brain MRI 연구의 문헌 정리, task 설계, context 기록 전용 workspace**다.

실험 실행/모델링 workspace가 아니다.

- 문헌/설계 산출물: `/home/vlm/minyoungi/literature/`
- durable context: `/home/vlm/minyoungi/notes/context/`
- 실제 모델링/실험: `/home/vlm/minyoung4` 또는 별도 승인된 실험 workspace

## 현재 연구 초점

이번 연구는 **VLM에 집중**한다.

Main framing:

> 3D brain MRI + ROI/segmentation grounding + structured clinical language supervision을 이용한 dementia VLM/MLLM representation learning.

PET/ATN은 중요하지만 **main PET-only prediction task가 아니라 privileged validation/supervision branch**다.

## 보존된 주요 구조

```text
.git/                  # 독립 git repo
.codex/                # Codex 설정, hooks, custom agents
.gitignore
AGENTS.md              # workspace operating rules
README.md              # lightweight workspace 설명
literature/            # paper index, notes, scripts, reading queue
notes/context/         # durable workspace/research context
links/                 # 필요 시 데이터 symlink 설명만 보관
```

## 핵심 source-of-truth 파일

- `notes/context/PROJECT_GOAL.md` — 현재 VLM 연구 목표와 task hierarchy
- `literature/notes/2026-05-18_vlm_research_feasibility.md` — VLM 가능성 판단
- `literature/notes/2026-05-18_vlm_brain_mri_text_alignment_plan.md` — ROI-grounded text alignment 설계
- `literature/notes/direct_reading_priority_2026-05-18.md` — 읽기 우선순위
- `literature/notes/manual_review_queue.md` — full review queue

## 정리 원칙

- PET-only task note가 main context처럼 보이면 정리하거나 branch note로 격하한다.
- 새 task 정의는 VLM 중심이어야 한다.
- caption/template 설계에서는 task별 allowed/forbidden fields를 명시한다.
- 실험 코드는 이 workspace에 두지 않는다.
- raw/preprocessed/shared data는 이 workspace에서 수정하지 않는다.

## 다음 context 작업

- `PAPER_READING_MATRIX.md` 생성: ADLIP / NeuroVLM / Natural Text Supervision MRI / M3D / CT-CLIP 계열 비교.
- `CAPTION_FIELD_POLICY.md` 생성: task별 label leakage 방지 규칙.
- `VLM_READY_MANIFEST_SCHEMA.md` 생성: v2 preprocessing 이후 manifest column contract.
- 이 workflow의 작업 산출물은 `/home/vlm/minyoungi`에만 둔다. `/home/vlm/minyoung4`에는 Min이 명시적으로 요청하기 전까지 새 manifest/note/runbook을 만들지 않는다.
- 현재 integrated manifest 기준 파일은 `/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv`이다.

## Post-v2 preprocessing handoff

v2 preprocessing 완료 후 첫 단계는 모델 학습이 아니라 전체 데이터 정렬/alignment audit이다.

Canonical workspace note:

```text
/home/vlm/minyoungi/notes/context/POST_V2_DATA_ALIGNMENT_HANDOFF.md
```

Current integrated manifest:

```text
/home/vlm/minyoungi/manifests/v2_integrated/vlm_ready_manifest_v2_integrated_oasis_included_v0.csv
```
