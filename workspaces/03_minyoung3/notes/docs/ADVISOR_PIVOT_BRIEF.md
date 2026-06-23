# Advisor Brief — minyoung3: 현 위치, 달성 가능한 산출물, top-tier를 위한 전략 결정

작성 2026-06-22, 갱신 2026-06-23 (P1 positive가 독립검증서 parroting으로 사망 — 반영함). 목적: (1) 지금까지 *무엇이 robust하게 확정됐는가*, (2) 이 작업에서 *지금 확보 가능한 정직한 논문*, (3) **top-tier positive를 원하면 무엇을 바꿔야 하는가** — advisor 결정 사안.

---

## 1. 한 문단 요약
ClaimTrap-AD(medical research agent의 claim-calibration 벤치마크 + replication-grounded auto-gold, 2888 cases)는 **정직한 D&B/ML4H 자원**으로 성립한다. 그러나 *top-tier AI conference용 positive method*는 이 데이터/문제에서 **구조적으로 나오지 않는다** — 5개 cheap probe + 직전 5개 실험 + 4건 literature-scout가 일관되게 같은 결론. 원인은 알고리즘 격차가 아니라 **winner's curse + cohort heterogeneity**(둘 다 known, 둘 다 algorithm-proof). 한때 positive로 보였던 P1("replication-tool agent ≫ naked LLM")은 **독립 research-critic 검증 + 데이터로 parroting임이 확정**(agent가 gold와 어긋나는 주입 숫자를 97% 따라감 = controller의 LLM 코스튬). 즉 **positive는 없다.** 확보 가능한 건 *negative/benchmark* D&B 논문 하나. **top-tier positive의 진짜 lever = 다른 문제/데이터** → advisor 결정 필요.

## 2. Robust하게 확정된 것 (실사 증거)
- **생성·conversion 방향:** dead (7건 citation-backed preemption; AD modest-N 공간 소진). [memory: minyoung3-direction-state]
- **ClaimTrap-AD 벤치마크 + Claim Safety Controller:** 성립하나 safety–completeness trade-off(clean win 아님). 벤치마크 "first"는 CliniFact(Sci Data'25)/SciFact/BiomniBench/RIGOURATE 등에 의해 broad-tier preempted. **hedged narrow-first만 생존**: "replication을 claim-ceiling gold로 쓴 첫 peer-reviewed 벤치마크"(CliniFact은 in-cohort p<0.05를 gold로 박음 = 우리가 깨는 신호 = 정반대 stance → sharp positioning이나 tier는 여전히 D&B).
- **Rigor/LLM-agent 학습 방향:** 5 실험 전부 real data에서 baseline 못 이김 [docs/HONEST_SYNTHESIS.md].
- **Top-tier method 각도 (2026-06-22 신규):**
  - *replication-as-reward*: 메커니즘이 **Rewarding-Doubt(2503.02623)+RLCR(2507.16806)에 선점**(proper-scoring 대칭 보상; 그들=in-dist correctness, 우리=replication = label swap → incremental reject 위험).
  - *probe 1*: trap 탐지 feature 천장 ≈ controller 43%(`tool_repl≤0.58` 규칙). 학습 모델이 못 이김.
  - *probe 2*: discovery-time 정보만으론 trap recall ~0–9%@high-precision — **trap은 정의상 replication 전엔 안 보임** → "artifact에서 ceiling 예측" RL 사망(정보가 입력에 없음).
  - *probe 3*: breadth로 recall 0.43→0.84 가능하나 false-flag 0.09→0.49 + ~19–31% irreducible.
  - *probe 4*: informed/adaptive cohort 선택이 random 대비 +6pt뿐, per-finding adaptivity ~0 → active-probing agent에 학습할 policy 없음.
  - *probe 5*: 풍부한 discovery metadata(d,n,SE,endpoint,region) → disc_auc 너머 +0.001. 0.906 trap-AUROC은 **winner's curse**(문턱 근접; CN_MCI 39%·asym-feature 75% trap)이고 deployable precision서 9% recall = 무용.
  - *framing 팩토리얼(Atom 2)*: open 모델 모든 arm ~0–6% affirm → sign-reversal 없음(uniform over-rejection collapse). (pilot의 over-claim은 Sonnet/closed prose-judged 한정.)
  - *P1 (replication-tool agent, 2026-06-23)*: Qwen disc 0→+0.547로 positive처럼 보였으나 **parroting 확정** — agent_affirm이 주입 숫자(tool_repl≥0.6)와 0.88 일치, gold와 어긋나는 35케이스서 97% 숫자 추종; ceiling_acc는 오히려 하락(0.560→0.487); MedGemma +0.153(기준 미달). = controller(`tool_repl≤0.58`)의 LLM 코스튬. **independent research-critic: C1 KILL-as-positive / C2·C3 REVISE.**

## 3. 지금 확보 가능한 정직한 논문 (negative/benchmark, ML4H / D&B)
positive가 아니라 **negative-result/benchmark**로서 하나의 일관 서사:
> ClaimTrap-AD(replication-grounded 벤치마크) + *open LLM은 scientific claim을 calibrate하지 못한다 — 프롬프트의 salient cue를 pattern-match할 뿐(rigor caveat→일괄 "no"; 숫자→thresholding), 정보 천장 근처의 one-line replication-threshold 규칙으로 붕괴하며 그조차 못 이긴다.*
- 구성: ClaimTrap-AD(2888, replication-as-gold) + 5-probe limits + P1을 **parroting negative로** + factorial을 cue-induced under-claiming으로.
- 제출 전 필수(critic): probe 출력 영속화, trap을 margin으로 de-circularize, power/learning-curve, placebo-number control.
- tier: **ML4H / NeurIPS D&B / ACL-BioNLP**, 잘해야 top-tier *workshop*. top-tier main-method splash 아님.

## 4. Advisor 결정 사안 — top-tier POSITIVE의 lever
이건 내가(claude) 결정할 수 없음 (출판 압박/타임라인/데이터 공유 권한을 모름). 후보 *유형*:
1. **답이 UNKNOWN인 다른 과학 질문** (현 instrument의 known-biology 재진술이 아니라). modest-N AD 구조 MRI는 소진.
2. **Dataset/benchmark로서 data novelty가 currency인 길** — **HARD GATE: AJU 임상 cohort를 IRB/소유권상 공개·공유 가능한가?** 불가면 이 길은 출발 불가.
3. **Longitudinal-outcome / prognosis** (시간이 답을 만드는 질문; follow-up 데이터 필요).
4. (현 자산 재활용) replication-grounded claim-calibration을 **다른, 더 풍부한 데이터 modality**(텍스트/논문/EHR 등 winner's-curse가 알고리즘으로 다룰 신호를 남기는)로 옮길 수 있는가 — 단 RLCR/CliniFact 선점 회피 필요.

## 5. Advisor에게 가져갈 질문
1. 목표 tier/타임라인이 무엇인가? (ML4H/D&B를 지금 확보 vs top-tier를 위해 pivot)
2. **AJU cohort 공개/공유가 IRB·소유권상 가능한가?** (벤치마크-as-contribution 길의 생사 결정)
3. follow-up/longitudinal 데이터에 접근 가능한가? (prognosis 길)
4. "답이 unknown인" 임상 질문 중 advisor가 가치 있다고 보는 것은?

---
*근거 파일: scripts/probe_*.py(5 probe), scripts/run_framing_factorial.py, scripts/run_tool_agent.py(P1), docs/HONEST_SYNTHESIS.md, docs/RESULTS_PUBLICATION.md, memory: minyoung3-direction-state.*
