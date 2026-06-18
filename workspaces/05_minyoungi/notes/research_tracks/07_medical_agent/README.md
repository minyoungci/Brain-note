# Track 07 — Medical Agent (Korean multimodal AD cohort)

_2026-06 pivot. 이전 imaging-marker 연구(04 vascular SNAP / 06 WMH benchmark)는 negative/cautionary로
종결 → AI 기여를 **방법(LLM agent)** 으로 전환. 복구: `git tag pre-agent-pivot`._

## 왜 이 pivot
04/06에서 "A− WMH→해마는 위축 artifact"(robust negative)를 확정했고, 혈액-인지 신호도 약함(p-hacking 거부).
→ **데이터 풍부함은 강하나 단일 epidemiological 신호는 약함.** 그 풍부함을 *에이전트의 입력*으로 쓰면
기여가 **방법(agentic multimodal reasoning)** 이 되어 약한 신호에 의존하지 않는다.

## 데이터 자산 (전부 보유·검증됨)
| 모달리티 | 내용 | 커버리지 |
|---|---|---|
| 임상 | MMSE·CDR(global/SB)·GDS·dx(CN/MCI/dementia/AD), 교육·인구 | 97-100% |
| 혈액 바이오마커 | CBC·간신장·glucose/HbA1c·지질·TSH/ft4·B12/folate | 88-100% |
| amyloid | visual 84%(A−866/A+732), SUVR 27% | — |
| 유전 | APOE genotype·e4 count | 100% |
| **정량 FastSurfer** | **35지표**(해마·편도·내후각·parahippo·뇌실·시상·피질 등) | **100% (한국 2196)** |
| 혈관 | HTN/DM/dyslipidemia·BP·BMI | 98-100% |
- 정본: `Clinical/consortiums/Korean/korean_clinical_subject_level.parquet`(1898) + manifest FastSurfer.

## 연구 질문
> 임상 + 혈액 바이오마커 + **정량 FastSurfer 형태계측**을 통합해 [task]를 수행하는 **LangGraph 멀티스텝
> tool-use 에이전트**가, 단일 LLM 호출 · tabular ML · 임상 휴리스틱보다 나은가? (정확도 + 해석가능성)

**Novelty**: LLM 의료연구 대부분 텍스트 기반. **구조화 혈액 바이오마커 + *정량 뇌 형태계측을 agent tool*로**
추론하는 멀티모달 임상 에이전트는 덜 탐구됨.

## 아키텍처 (LangGraph)
- **State**: 환자 멀티모달 레코드
- **Tools**: ①lab 조회+참조범위 ②FastSurfer 위축 z-score(연령정규화 해마/피질/뇌실) ③biomarker cutoff(APOE/amyloid) ④혈관위험 점수
- **Nodes**: 수집 → 단계 추론(혈액 이상? 위축 패턴? 혈관 vs 퇴행?) → 종합
- **백엔드**: Claude — 추론 `claude-opus-4-8`, 저비용 노드 `claude-haiku-4-5`. `langchain-anthropic.ChatAnthropic`.

## Task 후보 (결정 필요)
- **A. amyloid 사전선별** (PET 회피): GT=amyloid_visual, binary, 임상가치↑
- **B. 감별진단** (CN/MCI/dementia): GT=dx_3class 100%, multi-class, 풍부

## 평가
에이전트 vs (a)단일 LLM (b)XGBoost (c)휴리스틱 — held-out 정확도/AUC + 추론 trace 해석.

## 환경
- `.venv_agent` (uv): langgraph + langchain 1.3.9 + langchain-anthropic ✓
- 디렉토리: `data/`(어셈블) `tools/`(FastSurfer z-score 등) `agent/`(graph) `eval/`(벤치)
- ⚠️ `ANTHROPIC_API_KEY` 필요(LLM 호출).

## 다음
1. Task A/B 결정 2. API 키 3. data/ 멀티모달 레코드 어셈블 4. tools 구현 5. agent graph 6. eval
