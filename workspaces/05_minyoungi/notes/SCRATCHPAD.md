# SCRATCHPAD — 현재 실험 상태 / 핸드오프

## 2026-06-18 — Endpoint feasibility audit

### Purpose
Evaluate whether current manifest supports planned medical agent tasks.

### Key findings
- MCI-to-AD conversion is not supported by current manifest because `clin_dx_label` is subject-level backfilled (`clin_level=subject_firstnonnull`; within-subject dx variation ADNI/NACC/A4/AIBL = 0; ADNI MCI→AD sequences = 0).
- ADNI per-visit diagnosis requires external DXSUM join.
- A4 amyloid positivity is single-class in current manifest (1811 positive / 0 negative) and cannot be used for classification — natural given A4 design (amyloid-positive CN), not a data error.
- ADNI amyloid status is absent from manifest and requires external join (UCBERKELEY_AMY).
- Korean cohorts are not suitable for conversion task under current longitudinal availability (KDRC single-session; AJU max 2 sessions).
- **Refinement**: amyloid positivity is NOT globally blocked — EXECUTABLE within AJU(435/851)·KDRC(417/492)·OASIS(330/718)·NACC(201/314). Only ADNI/AIBL blocked, A4 forbidden.

### Decision
- Mark MCI-to-AD conversion as BLOCKED_RECOVERABLE (Western) / FORBIDDEN (Korean).
- Mark A4 amyloid classification as FORBIDDEN under current manifest.
- Mark ADNI/AIBL amyloid positivity as BLOCKED_RECOVERABLE; within-cohort amyloid positivity EXECUTABLE_WITH_CAUTION.
- Allow CDR-based progression only as proxy task (CANDIDATE), not AD conversion.
- Next step: external join plan (DXSUM / amyloid / NACC) — manifest-internal vs post-join 구분.

### Artifacts produced
- docs/DATASET_CARD.md, docs/TASK_CARD.md (3-status 재정의), docs/VERIFIER_SPEC.md, docs/EVALUATION_PROTOCOL.md, docs/CLAIM_SCHEMA.md (L0–L3)
- docs/ENDPOINT_FEASIBILITY.md, docs/BLOCKER_LOG.md
- outputs/endpoint_audit/endpoint_feasibility_table.csv (28행, live parquet 실측)
- configs/task_status.yaml (기계가독 status)
- CLAUDE.md (project-local 신규; §4 현재 우선 task = endpoint feasibility audit)

### 2026-06-18 (update) — Task3 분리 + amyloid label audit
- 결정: Task3 amyloid를 **3A(within-cohort, EXECUTABLE, L2 internal only)** / **3B(transportability, BLOCKED, L0)** 로 분리. 전체 봉인 안 함.
  - 3A allowed_cohorts: AJU·KDRC·OASIS·NACC. A4=FORBIDDEN(single-class). 3A는 "논문 main claim"이 아니라 **agent-dev executable benchmark**.
- AMYLOID_LABEL_AUDIT 작성(docs/ + outputs/endpoint_audit/amyloid_label_audit.csv). 핵심 위험:
  - label 정의 비호환(AJU/KDRC visual ↔ OASIS/NACC centiloid), 임계값 manifest 부재([VERIFY]).
  - base-rate 상이(0.315~0.459) → pooling 시 prevalence 보정.
  - temporal matching: OASIS만 gap_days(max 729d), 나머지 scan-date 부재.
  - scanner: OASIS·A4 model 0%, KDRC field_strength 0%.
- 반영 파일: TASK_CARD(3A/3B), CLAIM_SCHEMA(Task3A 전용 문구+ceiling표), configs/task_status.yaml(subtasks), CLAUDE.md §4, docs/README.

### 2026-06-18 (update) — Step 2.0 label source hardening + gated baseline
- 경험적 cutoff 역산(연속↔이진 분리, 실측):
  - **OASIS**: centiloid↔positive **clean ~20 CL**(neg_max 19.9/pos_min 20.2, no overlap) → `LABEL_PARTIAL_TEMPORAL_CHECK_REQUIRED`(temporal-window rule만 남음, claim downgrade).
  - **NACC**: centiloid↔positive **overlap 10–17 CL**(4 tracer) → 단순 threshold 아님 → `LABEL_UNVERIFIED`.
  - **KDRC**: SUVR↔visual heavy overlap → `LABEL_UNVERIFIED`. **AJU**: 연속 anchor 없음 → `LABEL_UNVERIFIED`. **A4**: FORBIDDEN.
  - ⇒ 아직 어느 코호트도 LABEL_LOCKED 아님.
- baseline 코드 작성: `scripts/run_task3a_baseline.py` (default `--mode smoke_test`; `--mode formal`은 amyloid_label_audit.csv의 allowed_run 읽어 게이팅, 미허용 시 exit 1). `scripts/build_amyloid_label_audit.py`(CSV 생성기).
- 검증 완료: AJU/KDRC formal → ABORT(exit 1), OASIS smoke → run(26 feat leakage-clean, split 저장, row-drop 로깅). formal 실측 run은 **보류**(label lock 전).
- 반영: AMYLOID_LABEL_AUDIT(label_status+Activation Rule+Claim Restriction), task_status.yaml(baseline_policy+cohort_label_status), CSV(label_status/allowed_run 컬럼).

### 2026-06-18 (update) — OASIS formal association baseline (Step 2.1)
- governance 커밋: `fe7be21` (baseline 실행 전 checkpoint).
- OASIS temporal-window rule 고정: `configs/task3a_oasis_temporal.yaml` (primary |MRI-PET gap|≤365d, strict 180d, lenient 730d=retention only). 실측: 365d → n=995/500subj, pos311/neg684, gap p50=0·p90=96.
- `scripts/run_task3a_oasis_formal.py` (7-condition hard gate, association-only). 실행 결과(primary 365d, 20 subject-split):
  - **roi_only AUROC 0.658 < covariate_only_B1(age/sex/ICV) 0.684 → image_beats_covariate=False**. roi+cov(0.684)=cov 단독 → **ROI 증분 0**.
  - site_only_B3 0.497(chance) → scanner shortcut 없음. bootstrap stability: clin_age 100% 선택(신호=age 지배).
  - ⇒ "ROI가 amyloid positivity 예측" 주장은 demographic baseline 미초과로 **자동 기각**. 정직한 **null/association** 결과(CLAIM_SCHEMA 허용·권장). claim_report.md 첫 2줄=의무 disclaimer.
- 산출물(gitignored): outputs/task3a_oasis/{temporal_matching_audit,baseline_metrics,bootstrap_stability}.csv, verifier_report.json, claim_report.md.

### 2026-06-18 (update) — Step 2.2 OASIS Verification Benchmark Pack
- cutoff hardening(실측): OASIS binary = **uniform 20 CL**(discordance 0, PIB·AV45 clean). published tracer-specific 16.4–21.9 CL과 다름, **3.2% ambiguous** → "canonical status"·"universal 20 CL" 금지(association-only caveat). LABEL_LOCKED 미승격(PARTIAL 유지).
- covariate dominance가 모든 window robust: incremental(roi+cov − cov) = 180d +0.006 / 365d +0.000 / 730d +0.022. roi never beats cov.
- 신설 claim level **`L1_ASSOCIATION_WITH_NEGATIVE_INCREMENTAL_FINDING`**(L1.5) — OASIS Task3A 권장 수위.
- benchmark artifacts(gitignored): outputs/task3a_oasis/{cutoff_hardening.json, verifier_scorecard.json, claim_trap_cases.jsonl}. 5 claim-trap cases(covariate dominance / temporal overclaim / label provenance / cross-cohort=L0 / shortcut neg-control).
- 생성기: scripts/build_oasis_benchmark.py. docs: VERIFIER_SPEC(V4 scorecard), CLAIM_SCHEMA(L1.5+caveat), TASK_CARD(Step2.2), AMYLOID_LABEL_AUDIT(§2d), 신규 docs/AGENT_BENCHMARK.md(generic vs verification-aware 평가 설계).
- 가드레일: AJU/KDRC/NACC formal 안 함(smoke-only), A4 forbidden, **LangGraph 미착수**(benchmark 완성 후).

### 2026-06-18 (update) — Step 2.3 independent benchmark label review
- draft claim_trap_cases는 main agent 작성 → self-bias 위험. blind 2-reviewer로 gold 잠금.
- blind 입력 생성(`scripts/build_review_inputs.py`, draft label 제거), 리뷰어 2명 독립 실행: Reviewer A=research-critic, B=professor(claude). draft 미노출.
- adjudication(`scripts/adjudicate_reviews.py`): gold=합의, 불일치→보수적+REQUIRES_HUMAN, REVISE/REJECT→REQUIRES_HUMAN. draft는 비교만(미반영).
- 결과: **A–B 합의 5/5**, **draft 일치 2/5(40%)** → self-eval 편향 정량 확인. gold: 001 L1.5 / 002 L1(교정) / 003 L1(REQUIRES_HUMAN_REVISION) / 004 L1(교정, 정의 명확화) / 005 L1.5.
- 정의 확정: claim_level = 강한 *허용* claim의 level (forbidden claim의 level 아님). 004 draft L0→gold L1.
- 산출(version-controlled, 비재현 expert verdict이라 -f): outputs/agent_benchmark/{claim_trap_cases_for_review.jsonl, review_research_critic.json, review_professor.json, gold_claim_trap_cases.jsonl, label_review_adjudication.csv}.
- docs: BENCHMARK_LABEL_REVIEW(프로토콜+rubric 0-3+error taxonomy E1-E8+결과), AGENT_BENCHMARK/CLAIM_SCHEMA 갱신.

### 2026-06-18 (update) — Step 2.4 agent benchmark harness (locked-only PILOT)
- gold에 lock 필드 추가(adjudicate 수정): 4 LOCKED + 003 REQUIRES_HUMAN_REVISION(include_by_default=false, scoring_allowed=false).
- harness 구현: src/agents/{generic,verification}_claim_agent.py(stub backend), src/evaluation/rule_based_claim_scorer.py(E1-E8 + negation guard, self-test 7/7), scripts/{run_agent_benchmark,score_agent_outputs}.py.
- 게이트: locked-only 기본, --include_unlocked 시 WARN(비보고용). 모든 결과 PILOT 표기. benchmark_report.md 첫 줄=disclaimer.
- PILOT 결과(locked 4, backend=stub=pipeline검증): generic mean 0.25/pass 0.0(hard-fail E3·E3·E5 + omission E7) vs verification mean 3.0/pass 1.0. scorer가 over-claim 분리 검증. ⚠️stub=pipeline 검증, LLM 비교 아님(backend=llm 후속).
- scorer tense 갭 수정(predicted/predicts 모두 캐치).
- case 003 sign-off 자산: docs/HUMAN_SIGNOFF_CASE003.md + outputs/agent_benchmark/case003_human_signoff_template.json(옵션 A/B/C, 보수적 선택).

### 2026-06-18 (update) — case 003 human sign-off + 5-case pilot
- user가 AskUserQuestion으로 **C(conservative merged)** 명시 선택(agent 임의 결정 금지 준수). 결정은 case003_human_signoff_template.json에 기록 → adjudicate_reviews.py가 적용(재현 가능, gold 손edit 아님).
- gold 003: `LOCKED_HUMAN_ADJUDICATED`, include/scoring=true, gold_allowed_claim=C. **gold set 5/5 완성**.
- 5-case pilot(`runs/pilot_locked5/`, stub): generic mean **0.2**/pass 0.0 (hard-fail E3·E3·E4·E5 + omission E7) vs verification **3.0**/1.0. report banner 동적화(003 포함 시 "PILOT=stub backend" 명시). scorer에 canonical/the-standard(E4) 추가, self-test 7/7.
- ⚠️ stub=pipeline 검증, LLM 비교 아님.

### 2026-06-18 (update) — Step 2.5 `--backend llm` harness (구현+offline 검증, 실행 BLOCKED)
- within-model prompt ablation 구현: 동일 모델/temp/max_tokens, 프롬프트만 다름(generic=raw metrics / verification=+verifier 규칙·schema·forbidden·ceiling·caveats).
- 파일: configs/llm_backend.yaml(provider=anthropic, model=claude-sonnet-4-6, temp0, max800, n_repeats3, cost), src/agents/llm_client.py(Anthropic verified — claude-api 레퍼런스 기반; openai/gemini NotImplemented), generic/verification agents에 llm 프롬프트+respond() 추가, run_agent_benchmark.py에 --backend llm/--dry_run/--n_repeats + blinding guard + raw_prompts/responses + token_usage/cost.
- ⚠️ 자기 harness에서 leak 발견·수정: generic 프롬프트에 claim_ceiling·"do NOT claim" guardrail이 섞여 있었음 → raw metrics만으로 제한(guardrail은 verification에만). blinding guard 강화.
- dry-run 검증(키 불필요): 5 cases blinding PASS, est ~16k input tokens, **호출 0**.
- 🔴 실행 BLOCKER: anthropic/openai SDK 미설치 + ANTHROPIC/OPENAI 키 없음, GOOGLE_API_KEY만. provider 선택 + SDK 설치(승인) + 키 필요 → user 결정 대기.

### 2026-06-18 (update) — 3 provider 모두 wiring (user 결정)
- user 선택: "3개 모두 설치해서 사용 가능하도록". `pip install anthropic openai google-genai`(conda base) 완료.
- llm_client.py에 3 provider 연결: anthropic(ref-verified), gemini(**runtime-verified** google-genai), openai(구조구현, GPT-5.x 파라미터 [VERIFY]·키없어 미실행). --provider/--model override + .env 자동로드(*_API_KEY) 추가. run_llm 산출물 stub 경로와 parity(rule_based_scores/error_taxonomy/outputs.jsonl 등 누락 수정).
- Gemini end-to-end 실제 검증: gemini-flash-lite-latest, n=1, cost $0.0074, 전체 파이프라인 동작. ⚠️wiring smoke(비-primary, n=1) — generic 1.8/verification 2.4(verification도 case004 E5 1건). 과학결과 아님.
- 실행 가능: Gemini 즉시. Anthropic/OpenAI는 키만 설정하면 가능.

### 2026-06-18 (update) — OpenAI 연결 + GPT-5.5 pilot → scorer 신뢰도 한계 발견
- ⚠️ 보안: user가 OpenAI·Anthropic 라이브 키를 채팅에 평문 입력 → .env(gitignore) 저장, **회전/폐기 권고**.
- OpenAI **gpt-5.5 verified & 실행**(reasoning: temp1 고정, max_completion_tokens, 4k floor). llm_client openai 경로 수정. $0.40/10calls.
- Anthropic 키 초기 $0 credit이었으나 **2026-06-18 충전 확인 → Sonnet 4.6 실행 가능**. ⇒ **3 provider(OpenAI gpt-5.5 / Gemini / Anthropic Sonnet 4.6) 모두 runnable**.
- GPT-5.5 within-model pilot n=1: raw 점수 generic 1.2/verification 2.4. **그러나 응답 정독 결과 scorer false-positive 다수** — gpt-5.5는 calibrated 답변("not canonical","prediction language not justified","may overestimate generalizability")인데 regex가 forbidden 키워드 부정/메타 용법을 over-claim으로 오판.
- ⇒ rule-based scorer = blatant over-claim용 coarse gate로만 신뢰. fine-grained 채점엔 LLM-judge(rubric/order-swap)±human 필요. _find_forbidden 전체-occurrence negation fix 적용했으나 잔여 FP는 semantic(regex 불가) → band-aid 안 함.
- ⇒ 실제 generic vs verification 비교는 LLM-judge/human 채점 도입 후 보고. n=1 raw는 scorer-한계 데모로만.

### 2026-06-18 (update) — Step 2.5b hybrid scorer (rule screen + LLM judge) 구현
- user 결정: Option 1(judge 먼저). generation 아니라 evaluation contamination이 본질.
- 구현: screen_claim(문장-cue verdict pass/judge_required/hard_fail; long-range negation·heading·caution FP 해결), src/evaluation/llm_claim_judge.py(reference-guided, agent-id 숨김, judge≠gen model, temp0), scripts/judge_agent_outputs.py(--dry_run/--judge_all), configs/llm_judge.yaml. VERIFIER_SPEC V5.
- offline 검증(호출0): GPT-5.5 저장응답 재screen → **4 old hard-fail→judge_required 정정**(FP), 9 judge 프롬프트 빌드, scorer_false_positive_report.md. blatant stub-claim은 여전히 hard_fail(검증).
- ⛔ 실제 judge run(judge_required→점수) = **key rotation 후**. 키 채팅노출 → 회전 필수. judge default model=sonnet(≠gen gpt-5.5, self-preference).
- 다음(rotation 후): GPT-5.5 hybrid 재채점 → FP유형분석 → hybrid확정 → Sonnet raw gen → GPT vs Sonnet 비교.

### 2026-06-18 (update) — GPT-5.5 hybrid 재채점 완료 (user가 rotation 보류·진행 승인)
- judge=Sonnet 4.6(≠gen gpt-5.5), temp0, agent-id 숨김, $0.0738/9건.
- **hybrid: generic 2.4 / verification 3.0 (둘 다 pass=1.0), true over-claim 0.** 기존 rule-based generic 1.2 = **scorer 오염 artifact 확인**. judge가 8/9 flag을 rule_based_FP로 확인. 유일 실감점=generic-003 score2(required check 일부 omission, over-claim 아님).
- judge rationale 3건 spot-check → calibrated-rejection vs over-claim 정확 구별(quality OK, but 전수 human 미검증).
- 해석: 강한 모델은 verifier 없이도(generic) over-claim 안 함; verifier는 caveat 완결성(2→3) 개선. **"verification outperforms" 금지**(n=1·단일모델·judge 미전수검증).
- ⚠️ 키 rotation 미완(user 추후 처리) — 노출 키로 호출함.
- 다음: (a) judge 전수 human spot-check, (b) Sonnet 4.6 raw generation → GPT vs Sonnet hybrid 비교, (c) Step 2.6 case scale-up(+judge_required 비율↓ rule refine/calibration set).

### 2026-06-18 (update) — Step 2.5d human spot-check 자료 준비 + framing 정밀화
- `scripts/build_human_spotcheck.py`(offline, 호출0) → human_spotcheck_table.csv(9건, **human_decision 공란 — agent 미판정**), human_spotcheck_summary.md(case별 output+judge rationale+gold+review checks), judge_acceptance_report.md(accept gate template). **판정·accept gate는 human 몫**(self-eval 금지).
- generic-003: judge score2(E4) rationale가 누락된 required check를 구체 열거(per-tracer N, discordance-artifact 설명, re-derived labels) → "over-claim 아님(safety OK)이나 incomplete" 뒷받침. = safety≠completeness.
- ⚠️ framing 교정: "generic이 위험 over-claim→verification 방지"는 부분 scorer artifact. 정확히=GPT-5.5 generic도 over-claim 없음(safety), verification은 caveat/completeness↑. → 지표 **safety/completeness/usefulness 분리**(VERIFIER_SPEC V6). 단일 우열 금지.
- Step 2.6 trap 8유형 기록(shortcut·covariate-vanish·temporal-window·label-provenance·base-rate pooled·small-effect·SHAP-leakage·external-rank-flip).
- ⛔ 다음 LLM 호출(Sonnet gen 등)은 **human spot-check 후 + key rotation 후**.

### Status
- endpoint feasibility audit: **DONE**. amyloid label audit + hardening: **DONE**. OASIS formal association: **DONE (null)**. OASIS verification benchmark pack: **DONE**. Benchmark gold review + case003 sign-off: **DONE (5/5 LOCKED)**. Step 2.4 stub PILOT: **DONE**. Step 2.5 LLM harness: **BUILT + dry-run verified; execution BLOCKED on credentials**.
- Next: provider/key 결정 → SDK 설치 → `--backend llm` 실제 비교(n=3 smoke → n=5 pilot). 그 다음 Step 2.5C 다중모델 robustness, Step 2.6 case scale-up(5→30→50+). LangGraph는 그 이후. AJU/KDRC/NACC smoke-only, A4 forbidden.
- Next: (1) case 003 human sign-off(A/B/C) → gold lock → 5-case full benchmark. (2) backend=llm로 generic vs verification-aware **실제** 비교(현재는 pipeline 검증만). LangGraph는 그 이후. AJU/KDRC/NACC smoke-only, A4 forbidden.
- Next: (1) case 003 human sign-off로 gold 완전 잠금. (2) Step 2.4 generic vs verification-aware agent harness (rule-based 1차 채점 + LLM-judge 보조, gold 기준). LangGraph는 그 이후. AJU/KDRC/NACC smoke-only, A4 forbidden 유지.
- Next: (option) published cutoff tracer-매핑 [VERIFY] → LABEL_LOCKED 검토; **generic vs verification-aware agent 비교 설계 구현**(AGENT_BENCHMARK §3). 그 다음 LangGraph. AJU/KDRC/NACC는 label lock 순서대로 external stress test.
- Agent dev: GATED — activation criteria(CLAUDE.md §4) 충족 전 진행 금지. formal baseline = label lock 전 보류.
- Next: (1) OASIS temporal-window rule 정의 → OASIS formal(association). (2) NACC SCAN provenance / AJU·KDRC rater 기준 확정. (3) verifier 구현 → LangGraph. Task2·3B는 external join(Plan A/B) 후.

### Verification note (generation ≠ verification)
- 모든 수치 = pd.read_parquet 직접 산출(/tmp/inspect_manifest.py, inspect2.py, inspect3.py, endpoint_audit.py).
- 미검증(범위 밖): n_transition 휴리스틱(OASIS 8/AJU 23, session_id 정렬 기반), 외부조인 실제 가용성, NACC/OASIS raw 접근정책.
