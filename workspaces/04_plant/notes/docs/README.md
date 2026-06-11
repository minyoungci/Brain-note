# docs/ — 문서 인덱스 (헷갈리지 않게 여기부터)

> 이 디렉토리의 모든 문서와 **현재 상태**. 처음 들어오면 ①→②→③ 순서로 읽는다.
> 결론은 항상 `RESEARCH_PROPOSAL.md`(현재 방향)와 `DECISION_LOG.md`(왜 그렇게 됐나)에 있다.

## 읽는 순서

| 순서 | 문서 | 무엇 | 상태 |
|---|---|---|---|
| ① | `../RESEARCH_BRIEF.md` | 라인 전체 설계(SoT) — 임무·과거실패·게이트 | **canonical** |
| ② | `RESEARCH_PROPOSAL.md` | **★ 현재 제안** — 우리 상황에 맞는 연구 + 근거 사슬 | **★ CURRENT** |
| ③ | `DECISION_LOG.md` | 모든 결정·NO-GO·폐기 (왜 여기까지 왔나) | live |

## 문서별 역할

**루트 (의사결정·규약)**
- `RESEARCH_PROPOSAL.md` — **현재 연구 방향**(morph-weak regime cross-site decidability). 바뀌면 여기 갱신.
- `DECISION_LOG.md` — 피벗·NO-GO·폐기 추적. 되돌리기 근거.
- `REPO_STRUCTURE.md` — 디렉토리 규약(생성 src ↔ 평가 experiments/tests).
- `P0_bias_audit_plan.md` — P0 단계 설계서(실행 완료, 결과는 `../results/P0/P0_AUDIT_REPORT.md`).
- (예정) `P1_plan.md` · `P2_plan.md` — 다음 단계 설계서. **코드 전 합의·승인.**

**investigations/ (탐색·근거 — 참조용. 결론은 PROPOSAL/DECISION_LOG에 반영됨)**
- `novelty_deep_research.md` — deep-research(104 agents) + 혈액바이오마커 직접 반증(+0.00). D5 종결 근거.
- `harmonization_scout_review.md` — harmonization 방법 scout. IGUANe = Arm C 대조만, 바 초과 증거 없음.
- `multisite_RL_strategy.md` — 초기 다기관 RL 전략(within-cohort vendor invariance). **부분 SUPERSEDED**: vendor-lever 분석은 유효하나, target은 PROPOSAL에서 AD/CN→morph-weak로 이동.

**ledgers/** — 음성 결과(NO-GO) 상세 기록.

## 산출물 (docs 밖)
- `../results/P0/` — P0 audit 보고서·요약·그림. `../notebooks/01~06` — 실행된 EDA/마이크로 분석.
- `../src/microbrain/audit.py` — 재사용 통계 primitives.

## 한 줄 현황 (2026-06-11)
P0 완료(bias 실재+분리가능). 5각도 수렴 → morphometry가 AD/CN 천장(0.94). 제안 = **morph-weak regime(MCI/amyloid)에서 micro-표현이 transport하는가**. 혈액·harmonization·멀티모달 fusion은 control/대조로 강등.
