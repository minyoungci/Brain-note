# HUMAN SIGN-OFF — case 003 (label_provenance)

_case `oasis_task3a_label_provenance_003`은 blind 2-reviewer가 모두 `REVISE_LABEL`을 반환해
`REQUIRES_HUMAN_REVISION` 상태다. **scoring에서 기본 제외**되며(`include_by_default=false`),
full 5-case benchmark는 이 sign-off 후에만 가능. 그 전 결과는 전부 PILOT(locked 4-case)._

연결: [`BENCHMARK_LABEL_REVIEW.md`](BENCHMARK_LABEL_REVIEW.md), [`AGENT_BENCHMARK.md`](AGENT_BENCHMARK.md).
템플릿: [`../outputs/agent_benchmark/case003_human_signoff_template.json`](../outputs/agent_benchmark/case003_human_signoff_template.json).

## 왜 보류인가
- 두 리뷰어 claim_level 합의 = **L1**, 내용도 일치(label은 surrogate, ground-truth 아님).
- 그러나 둘 다 `decision=REVISE_LABEL` → 라벨 문구를 더 보수적으로 다듬어야 한다는 신호.
- label provenance는 본 프로젝트 핵심 주장과 직결 → 애매한 채 scoring에 넣으면 "gold가 흔들리는 benchmark로 평가했다"는 공격을 받음.

## 검수자가 할 일 (긴 새 문장 작성 금지)
아래 셋 중 하나만 선택:
- **A** — Reviewer A(research-critic) claim 채택
- **B** — Reviewer B(professor) claim 채택
- **C** — 보수적 merged claim 채택 (권장: 가장 짧고 보수적)

세 후보 원문은 템플릿 JSON `options`에 있음. 선택 후 `decision`/`decided_by`/`decided_on`/`rationale` 기입.

## sign-off 후 적용
1. 템플릿의 `on_signoff_apply` 블록을 `gold_claim_trap_cases.jsonl`의 003 레코드에 반영:
   `lock_status=LOCKED_HUMAN_ADJUDICATED`, `include_by_default=true`, `scoring_allowed=true`,
   `adjudication_source=human_signoff`, 선택한 allowed_claim을 gold로 고정.
2. `uv run python scripts/run_agent_benchmark.py` 재실행 → 5-case로 자동 승격(003이 LOCKED이므로 포함됨).
3. 그때부터 "full 5-case benchmark"라 부를 수 있음. 그 전에는 금지.

## 현재 상태 — ✅ 완료 (2026-06-18)
- [x] case 003 human decision = **C (conservative merged)** — user가 AskUserQuestion으로 명시 선택. 근거: 가장 짧고 보수적, association-only, surrogate≠ground truth, prediction/robust/generalizable/cross-cohort/causal 없음.
- [x] gold 업데이트 + lock: `lock_status=LOCKED_HUMAN_ADJUDICATED`, `include_by_default=true`, `scoring_allowed=true`, `adjudication_source=human_signoff`, `gold_allowed_claim`=C 문구. (재현: 결정이 `case003_human_signoff_template.json`에 기록 → `scripts/adjudicate_reviews.py`가 적용)
- [x] 5-case full benchmark 재실행: `outputs/agent_benchmark/runs/pilot_locked5/` (5/5 included, 0 excluded). ⚠️여전히 PILOT(stub backend) — 실제 LLM 비교 아님.

> gold set 완성(5/5 locked). 다음은 `--backend llm` 실제 generic vs verification-aware 비교.
