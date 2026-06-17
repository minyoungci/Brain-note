# docs/ — 문서 인덱스 (여기부터)

> 이 디렉토리의 문서와 **현재 상태**. 설계 SoT는 `../RESEARCH_BRIEF.md`, 결정·이력은 `DECISION_LOG.md`.

## 현재 상태 (2026-06-17)
활성 연구 라인 없음. P0·P2·P3·P4 종료(상세는 `DECISION_LOG.md`). **워크스페이스 클린 리셋 — 다음 주제 대기.**

## 읽는 순서
| 순서 | 문서 | 무엇 |
|---|---|---|
| ① | `../RESEARCH_BRIEF.md` | 라인 전체 설계(SoT) — 임무·과거실패·게이트 |
| ② | `DECISION_LOG.md` | 모든 결정·NO-GO·폐기·롤백 (왜 여기까지 왔나) |
| ③ | `../insight/` | 라인-불문 축적 지식(실패 사인·방법론 함정·경험적 발견) |

## 문서별 역할
- `DECISION_LOG.md` — 피벗·NO-GO·폐기 추적. 되돌리기 근거.
- `REPO_STRUCTURE.md` — 디렉토리 규약(생성 `src` ↔ 평가 `experiments`/`tests`).
- `ledgers/` — 음성 결과(NO-GO) 상세 기록.
- (예정) `<phase>_plan.md` — 새 라인 단계 설계서. **코드 전 합의·승인.**

## 축적 지식 (docs 밖)
- `../insight/` — `failure_root_causes` · `methodological_traps` · `empirical_findings`.
- `../src/microbrain/audit.py` — 재사용 통계 primitives.
