# literature

문헌 정리 전용 폴더다.

```text
config/   # env example only; real secrets are ignored
index/    # CSV/JSON literature index and graph; detailed raw/expanded records live here
notes/    # curated human-readable summaries and current reading/research notes
scripts/  # literature collection/triage/extraction scripts
```

## 보존 원칙

- 상세 수집/추출 원본은 `index/external_index/YYYYMMDD/`의 CSV/JSON을 canonical artifact로 둔다.
- `notes/`에는 사람이 계속 읽고 갱신할 curated note만 남긴다.
- 자동 추출 markdown, 중복 seed list, command dump는 필요 시 index/scripts에서 재생성한다.

## 현재 보존된 주요 수집물

- `index/external_index/20260516/literature_seed_records.*`
- `index/external_index/20260516/expanded_literature_graph.*`
- `index/external_index/20260516/manual_review_anchor_records.*`
- `index/external_index/20260516/pmc_fulltext_snippets.json`

## 현재 유지하는 notes

### 읽기/문헌 우선순위

- `notes/direct_reading_priority_2026-05-18.md` — Min이 원문으로 먼저 읽을 핵심 논문 우선순위
- `notes/manual_review_queue.md` — full-review queue와 extraction fields
- `notes/manual_review_anchor_synthesis.md` — manual review anchor 종합과 reviewer objection

### 연구 framing / novelty

- `notes/research_task_novelty_definition_v0.md` — 문헌 기반 연구 task/novelty/claim gate 초안
- `notes/2026-05-18_vlm_research_feasibility.md` — PET 예측을 넘는 VLM/MLLM 연구 가능성 판단
- `notes/2026-05-18_vlm_brain_mri_text_alignment_plan.md` — Brain MRI VLM 선행연구, report 없는 text alignment, ROI-grounded CLIP 설계 메모

### 데이터 readiness / modality audit

- `notes/2026-05-17_pet_learning_readiness_audit.md` — PET-learning readiness audit
- `notes/2026-05-17_official_v2_preprocessing_research_opportunities.md` — official v2 preprocessing research opportunities
- `notes/2026-05-18_six_consortium_modality_status.md` — 6개 컨소시엄 raw/current modality status audit
