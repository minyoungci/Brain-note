# SCRATCHPAD — minyoung3 / ClaimTrap-AD

> **Repo 방향 전환 (2026-06-22).** 기존 Korean AD–SVD generative/conversion 방향은 종료(아카이브 tag, §9).
> 이 repo는 이제 **ClaimTrap-AD** — 의료 연구 에이전트의 claim-safety 벤치마크 + Claim Safety Controller —
> 작업 공간이다. 코드/산출물/문서는 minyoungi에서 **agent-only 범위로 이동**(2026-06-22, import+단위테스트 검증 후).
> minyoungi에는 상류 data-feasibility audit(endpoint/amyloid)·multi-cohort 자산이 그대로 남아 있다(복구원).
>
> **➜ 방향 진화 (2026-06-22): D1+M-a 연구계획 확정.** ClaimTrap-AD(벤치마크+E1–E8 traps+controller)를 *substrate*로
> 재활용해, **scanner/confound-aware rigor 신경영상 agent(D1) + verifier-pruned 효율(M-a)** 로 확장.
> 트렌드 4-scout 종합(`docs/AGENT_DIRECTION_RECOMMENDATION.md`) + 연구계획(`docs/RESEARCH_PLAN_RIGOR_AGENT.md`).
> novelty=조건부(falsifiable artifact-killing 데모). ClaimTrap-AD 논문 산출물(paper/·docs/PAPER_*)은 보존.

---

## 0. 한 줄 정의
의료 연구 에이전트(구조화 분석 artifact를 읽고 결론을 쓰는 LLM)가 **근거 없는 biomarker over-claim**을
내지 않도록: (1) **dual-view 벤치마크 ClaimTrap30** + (2) **inference-time Claim Safety Controller**.
→ AD biomarker 발견이 아니라 **claim-safety for research agents** 가 기여 축.

## 1. 현재 상태 (2026-06-22)

### 🔒 FROZEN — Claim Safety Controller v4 (최종 STOP POINT)
- 파이프라인: artifact → LLM **propose** → 결정적 **evidence 추출** → **verifier E1–E8** → claim ceiling **L\*(e)=strictest cap** → over-claim 탐지(λ(c)>L\*) → **ceiling-dependent routing** → enforce_strict → trace.
- **핵심 발견(v4)**: routing이 ceiling에 의존해야 함.
  - **L0 → hard block** (semantic-preserving rewrite는 "conditionally supportable" 같은 약한 보증을 남겨 no-claim ceiling을 위반).
  - **L1+ → semantic-preserving rewrite** (completeness 보존).
  - enforce_strict = explicit **multi-word** assertive 패턴 + fired-verifier multi-word forbidden 패턴, **clause-level negation 인지**. bare single-token(deployable/predict/causal) 제외.
- **결과 (n=3, 90 outputs/arm, GPT-5.5 judge, PILOT)**: over-claim **0/90** · hard-fail **0/90** · fallback_strict **0/90** · completeness **1.878**. over-suppression ~14/rep 잔존(=논문 thesis인 trade-off).
- **human spot-check 전건 ACCEPT** (e4_04=VALID_SAFETY_FIX 포함). → **controller 수정 중단. v5/Gemini/DPO/provider 비교 없음.**

### 진화 경로 (development narrative)
| ver | policy | n | over-claim | completeness | lesson |
|---|---|--:|--:|--:|---|
| v1 | hard fallback | 30(n=1) | 0/30 | 1.633 | safe but over-suppressed |
| v2 | soft rewrite | 30(n=1) | 0/30 | 1.80 | strict-enforce negation 버그 |
| v3 | bugfix(multi-word+clause-neg) | 30(n=1) | 0/30 | 1.833 | n=1엔 통과… |
| v3 | same | 90(n=3) | **2/90** | 1.878 | …n=3가 L0 soft-rewrite 구멍(e4_04) 노출 |
| **v4** | **L0 hard block + L1+ rewrite** | 90(n=3) | **0/90** | 1.878 | ceiling-dependent routing (최종) |

### 📊 3-way 메인 결과 (n=3, 90 outputs/arm)
| Arm | over-claim | hard-fail | completeness |
|---|--:|--:|--:|
| Generic | 19/90 | 14/90 | 1.678 |
| Checklist (global verification) | 3/90 | 1/90 | **2.622** |
| Controller v4 | **0/90** | **0/90** | 1.878 |

→ **thesis = persistent safety↔completeness trade-off.** controller가 safety는 최대화하나 completeness는 checklist를 **못 이김**.

## 2. 정직성 footnote (논문에 반드시 명시, 유지)
1. **3-way generation-base mismatch**: generic/checklist = 독립 3-draw, controller arm = 고정 generic-n1 propose + 3 rewrite resample (→ rewrite-stability이지 3 independent generations 아님).
2. **evolution n 혼용**: v1–v3=n=1, v3n3/v4=n=3 (constant-n head-to-head 아님, development narrative).

## 3. ⛔ 금지 주장 (verbatim 유지)
- "controller outperforms checklist" (completeness 2.622 > 1.878) · "controller proves safety" · "benchmark complete" · "Sonnet worse than GPT" · "DPO applied" · solves/guarantees/clinical-grade/discovers biomarkers/outperforms all baselines.
- **ClaimTrap30 gold + runs = held-out, training 후보 분류 금지.**
- raw 임상 free-text를 외부 API로 전송 금지 · artifact에 PHI 금지.
- **"first"/novelty 주장은 전부 `[VERIFY]`** (literature-scout 미완료 — 아래 §7 참조).

## 4. 데이터 자산 audit 결론 (read-only, 2026-06-21)
- **raw 임상 free-text 전무** (모든 text = 구조화 파생 템플릿 캡션) → real-clinical-text DPO 불가, **structured-artifact 경로만**.
- DPO 판정 = **DPO_POSSIBLE_AFTER_AUDIT** (source 풍부하나 pair 미생성·생성에 LLM 필요·ClaimTrap-disjoint pool 필요). future-work.
- AJU raw(aju_final_v2_3841.csv, 976×1350, NACC-UDS, visit date + per-visit dx NPPDX) = 종단/E3 unlock 핵심이나 PHI+temporal leak로 NEEDS_AUDIT. (원본은 minyoungi/data 측.)

## 5. repo 레이아웃 (minyoung3 현재)
```
src/controllers/   claim_safety_controller · evidence_extractor · verifier_modules
                   · claim_ceiling_estimator · overclaim_detector · claim_rewriter
src/agents/        generic_claim_agent · verification_claim_agent · llm_client
src/benchmark/     claimtrap30_adapter  (dual-view: generation_view vs scoring_view)
src/evaluation/    rule_based_claim_scorer · llm_claim_judge (non-self GPT-5.5)
configs/           claim_safety_controller.yaml · llm_backend.yaml · llm_judge.yaml
scripts/           run_controller_arm{,_v2,_v3,_v3_n3,_v4_n3} · build_controller_*_analysis
                   · run_agent_benchmark · judge_agent_outputs · test_controller_precision …
tests/             test_evidence_extractor.py
outputs/agent_benchmark/   claimtrap30_gold.jsonl(LOCKED) · runs/claimtrap30_controller_v4_n3(FROZEN) …
outputs/data_audit/        4 CSV
outputs/controllers/       evidence_extraction_audit · dryrun
docs/              PAPER_DRAFT_CLAIMTRAP_AD · PAPER_DRAFT_METHODS_RESULTS · FIGURE_TABLE_PLAN
                   · CLAIMTRAP30_PAPER_OUTLINE(positioning LOCKED) · CLAIM_SAFETY_CONTROLLER_DESIGN(§15 FROZEN)
                   · CLAIM_SCHEMA · VERIFIER_SPEC · EVALUATION_PROTOCOL · data-audit 4종
```
- 실행: cwd=repo root에서 `python scripts/...` (import은 `from src.*`). 절대경로/manifest 의존 없음 — 상대경로 자족적.
- 진입점: 소스=`src/controllers/claim_safety_controller.py`, 설정=`configs/claim_safety_controller.yaml`, 최종 결과=`outputs/agent_benchmark/runs/claimtrap30_controller_v4_n3/`, 논문=`docs/PAPER_DRAFT_METHODS_RESULTS.md`.

## 6. 논문 포지셔닝 (LOCKED)
- title: **"ClaimTrap-AD: A Dual-View Benchmark and Claim Safety Controller for Claim-Safe Medical Research Agents"**
- novelty 4축: dual-view benchmark / ClaimTrap-AD benchmark / hybrid evaluator(rule→non-self judge→human) / Claim Safety Controller.
- venue: workshop·D&B·BioNLP·ML4H (AAAI main = stretch).
- 상세: `docs/CLAIMTRAP30_PAPER_OUTLINE.md` "NOVELTY DEFENSE & POSITIONING (LOCKED)".

## 7. ⛔ 다음 (우선순위)
### ✅ literature-scout 완료 (2026-06-22) — 4묶음 live 검증. 산출물:
`docs/RELATED_WORK_SCOUT.md` · `docs/NOVELTY_POSITIONING_MATRIX.md` · `docs/CLAIMTRAP_AD_CITATION_CANDIDATES.bib`.
**핵심 판정(중요 — positioning 바뀜):**
- **C1 중심 formulation("claim-ceiling control")의 "first" = DEAD.** 선행 preprint 2건이 이미 claim을 자기
  evidence에 calibrate: **RIGOURATE**(arXiv:2601.04350, Jan'26) · **CSS/Huang**(arXiv:2604.17487, Apr'26).
  → "first/among the first" 문구 전부 삭제, 두 논문 cite+contrast 필수.
- **C4 hybrid evaluator = novelty 약함**(PoLL·Wang·G-Eval = 기존 관행). contribution에서 강등 → Methods 엔지니어링.
- **C2 benchmark = 생존**(claim-calibration scored axis + fixed structured artifact + AD = 조합 gap; peer-reviewed
  대비 깨끗). EHR bench(MedAgentBench/NEJM AI·AgentClinic/npj)는 task-execution이라 위협 안 됨. 단 BixBench·
  GIScholarBench·**BiomniBench(PARTIAL_OVERLAP, resolved 2026-06-22 — process-trajectory 채점, claim-ceiling/E1–E8 없음)** 대비 구분 명시.
- **C5 controller = 생존하나 mechanistic**(AgentSpec ICSE'26 peer-reviewed가 구조적 쌍둥이). "first/only" 금지,
  "검증된 framework 중 evidence-grounded claim-ceiling+routing은 없다" 식으로.
- **C3 dual-view = scout 완료(2026-06-22).** 판정 = **known family, novel channel**. 누출 일반현상은 occupied
  (BenchJack 2605.12673 = agent/evaluator 환경공유 · contamination line = pretraining channel · Li DASFAA'26 =
  judge-side ref bias). 주장 가능 = *verification-aware→answer-aware* 특정 채널 + generation/scoring view fix
  (zero-gold scan)만. ❌ "first leakage-free benchmark / first info-separation" 금지. → 깨끗한 기둥 아님,
  C2(benchmark) 보조. 최강 정직 문구 = RELATED_WORK_SCOUT §Cluster 5.

### 진행 완료
- ✅ **draft 수정(step 2)** — commit ce68263 (contribution 재배치 benchmark→leakage→controller→finding, "first" 삭제, hybrid evaluator 강등).
- ✅ **잔여 `[VERIFY]` 마감(2026-06-22)** — `docs/VERIFY_CLOSURE_REPORT.md`. BiomniBench=PARTIAL_OVERLAP(C2 생존, 차별화 문장 추가),
  AlpacaEval=COLM'24 peer-reviewed, PoLL/BenchJack=preprint, MedAgentBench DOI·AgentSpec(accepted)·CliniFact·FHIR-AgentBench·
  2402.08115·2506.08235(=ijcnlp-long.127) 확정. §6 reproducibility(deterministic vs replicable 분리) 갱신.

### 다음 우선순위
1. **full draft 통합** — abstract/intro/methods/results를 단일 제출본으로 (BiomniBench resolve됨 → gate 해제, 진행 가능).
2. **figure/table 실제 제작** (FIGURE_TABLE_PLAN 기준; paperbanana 등).
3. **AAAI-style reviewer attack checklist** 작성.
4. **venue 확정**: scout이 D&B/BioNLP/ML4H 강화·AAAI-main 약화 → benchmark+protocol primary.
5. **residual [VERIFY]**(camera-ready): BiomniBench full-text/author 브라우저 확인 · AgentSpec ICSE proc. page · PoLL/BenchJack workshop 배제.
6. (deferred) DPO = future-work only. 실험 추가 없음(v4 동결).

## 8. 검증 노트 (생성 ≠ 검증)
- 모든 수치 = committed run 산출물에서 직접 산출(read_parquet/csv). controller arm propose = 재사용 generic n1(고정), rewrite = 재샘플.
- minyoung3 이동 검증(2026-06-22): import 12모듈 OK + 단위테스트 3스위트(precision·controller·extractor) 전건 PASS, **LLM 0 호출**.

## 9. 이전 방향 복구원 (지우지 말 것)
- 이전 Korean AD–SVD generative/conversion 방향은 종료. 코드/산출물 복구: git tag `archive/generative-2026-06-20`, `archive/conversion-2026-06-20`.
- dead-ends map: memory `minyoung3-direction-state`.
- 데이터 자산(read-only `/home/vlm/data`): AJU Korean AD–SVD co-reg 192³ (T1 1001 / FLAIR 985 / T2 ~502 / amyloid-PET 992 + clinical ~1000).
