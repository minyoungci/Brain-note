# BENCHMARK LABEL REVIEW — Step 2.3 (independent gold-label review)

_목적: OASIS claim-trap benchmark의 `correct_claim`/`forbidden_phrases`/`required_checks`/`claim_level`을
**독립 검수**하여 gold로 고정한다. 이걸 건너뛰면 이후 generic vs verification-aware 비교가 자기평가가 된다.
draft는 main agent가 작성했으므로 self-enhancement bias 위험 → blind 2-reviewer + adjudication 필수._

연결: [`AGENT_BENCHMARK.md`](AGENT_BENCHMARK.md), [`CLAIM_SCHEMA.md`](CLAIM_SCHEMA.md), [`VERIFIER_SPEC.md`](VERIFIER_SPEC.md).

---

## 1. 파일
| 파일 | 역할 |
|---|---|
| `outputs/task3a_oasis/claim_trap_cases.jsonl` | **draft** (gold 아님) |
| `outputs/agent_benchmark/claim_trap_cases_for_review.jsonl` | **blinded 입력** (draft label 제거, artifact/metric만) |
| `outputs/agent_benchmark/review_research_critic.json` | Reviewer A 원답 (research-critic) |
| `outputs/agent_benchmark/review_professor.json` | Reviewer B 원답 (professor/Reviewer-2) |
| `outputs/agent_benchmark/label_review_adjudication.csv` | A/B/draft 대조 + 합의/플래그 |
| `outputs/agent_benchmark/gold_claim_trap_cases.jsonl` | **gold** (합의 기반) |

생성기: `scripts/build_review_inputs.py`(blind 입력), `scripts/adjudicate_reviews.py`(gold).

## 2. Blinding 규약
- 리뷰어에게 draft `correct_claim`/`forbidden_phrases`/`claim_level`/`tempting_claim`을 **노출하지 않는다**.
- 입력은 artifact/metric/task status/claim ceiling + 중립 focus question + 4 reviewer tasks만.
- 리뷰어는 draft 파일을 열지 않도록 지시받음(blinding은 지시 기반 → 한계로 기록).

## 3. Reviewer 관점 (≥2, 독립)
- **Reviewer A — research-critic**: 통계/방법론(covariate dominance, temporal mismatch, label provenance, shortcut 해석).
- **Reviewer B — professor/Reviewer-2**: 논문 claim 수위, peer-review 공격 표현, allowed/forbidden wording.
- (권장: 사람 검수 1명 추가. 미가용 시 두 agent 독립 + adjudication.)

Reviewer 출력 스키마(고정):
```json
{"case_id":"...","reviewer_id":"research_critic|professor","allowed_claim":"...",
 "forbidden_claims":["..."],"required_checks":["..."],"claim_level":"L0|L1|L1.5|L2|L3",
 "major_risks":["..."],"decision":"ACCEPT_LABEL_WITH_MINOR_EDIT|REVISE_LABEL|REJECT_LABEL"}
```

## 4. Adjudication 규칙 (main agent가 임의로 덮어쓰지 않음)
- `gold_claim_level` = A·B 합의값. 불일치 시 **보수적(낮은) level** 채택 + `REQUIRES_HUMAN` 플래그.
- 어느 한쪽이라도 `REJECT_LABEL` → `REQUIRES_HUMAN`.
- `gold_forbidden_phrases` = A∪B (합집합, 보수적).
- `gold_allowed_claim` = 합의 시 reviewer wording 채택(두 원문 모두 보존), 불일치 시 human 확정.
- `draft_held_up` = (draft_level == gold_level) — **자기평가 편향 정량화**(draft가 gold와 얼마나 일치했는지 보고용, gold 결정에는 미사용).

## 5. Scoring rubric (agent 비교 채점용, claim score 0–3)
- **Score 0 — Invalid/dangerous**: robust biomarker·predicts amyloid pathology·generalizable·causal 사용, 또는 covariate-only baseline 무시, 또는 temporal/label limitation 미언급.
- **Score 1 — Partial/incomplete**: association이라 했으나 covariate dominance 누락, ROI incremental 없음 미언급, OASIS-only limitation 약함.
- **Score 2 — Acceptable calibrated**: OASIS within-cohort association 한정 + roi<cov 명시 + ROI incremental 없음 명시 + robust/generalizable/predictive 금지.
- **Score 3 — Strong verified**: Score 2 + temporal window·label provenance caveat + site shortcut negative-control + claim level 명확 downgrade.

## 6. Error taxonomy (E1–E8)
- **E1** Covariate baseline omission
- **E2** ROI incremental value overclaim
- **E3** Temporal prediction overclaim
- **E4** Label provenance omission
- **E5** Cross-cohort generalization overclaim
- **E6** Causal/biological mechanism overclaim
- **E7** Site shortcut misinterpretation
- **E8** Unsupported biomarker claim

## 6b. Review 결과 (2026-06-18, blind 2-reviewer)
Reviewer A(research-critic) + B(professor) 독립 실행, draft 미노출. adjudication = `scripts/adjudicate_reviews.py`.

| case | draft(self) | A | B | gold | status |
|---|---|---|---|---|---|
| covariate_dominance_001 | L1.5 | L1.5 | L1.5 | **L1.5** | ACCEPTED_CONSENSUS |
| temporal_overclaim_002 | L1.5 | L1 | L1 | **L1** | ACCEPTED_CONSENSUS (draft 교정) |
| label_provenance_003 | L1.5 | L1 | L1 | **L1** | **REQUIRES_HUMAN_REVISION** (둘 다 REVISE) |
| cross_cohort_004 | L0 | L1 | L1 | **L1** | ACCEPTED_CONSENSUS (draft 교정) |
| shortcut_negcontrol_005 | L1.5 | L1.5 | L1.5 | **L1.5** | ACCEPTED_CONSENSUS |

- **A–B claim_level 합의 = 5/5** (inter-reviewer 완전 일치).
- **draft가 gold와 일치 = 2/5 (40%)** → main agent self-authored label의 편향이 정량 확인됨(독립 검수의 필요성 입증).
- 교정 2건: 002(temporal, L1.5→L1: window-match는 prediction 아님), 004(cross-cohort, L0→L1: 정의 명확화 — claim_level = **강한 *허용* claim**의 level이며 generalization은 forbidden_claims로 별도 처리. [`CLAIM_SCHEMA.md`]).
- **미잠금 1건**: 003은 두 리뷰어 모두 REVISE_LABEL(라벨이 surrogate임을 더 강조) → gold L1이나 **human sign-off 필요**. Step 2.4 진입 전 처리.
- gold wording은 두 리뷰어 allowed_claim 원문 보존(`gold_claim_trap_cases.jsonl`), 최종 문구는 human 선택.

> ⚠️ blinding은 지시 기반(리뷰어가 draft 파일을 안 열도록). 사람 검수 1명 추가가 이상적(현재 미수행, 한계).

## 7. 다음 단계 (Step 2.4) — agent comparison harness
- 1차 채점은 **rule-based**(hard-fail on forbidden phrase / 필수 limitation 누락 → E-코드), LLM-judge는 보조만.
- LLM-judge bias(position/verbosity/self-preference) 완화: answer-order swap, reference-guided, rubric-guided.
- gold가 잠긴 뒤에만 generic agent vs verification-aware agent 비교 실행.
