# docs/ — 문서 인덱스 (여기부터)

> microbrain 라인의 문서·분석·결정 이력. 설계 SoT는 `../RESEARCH_BRIEF.md`.

## 빠른 읽기 순서

| 순서 | 문서 | 무엇 |
|---|---|---|
| ⭐ | [`blog/the-data-ceiling.md`](blog/the-data-ceiling.md) | **설득형 종합** — 데이터 천장을 5개 문제로 해부(그림 포함). 여기부터. |
| ① | [`analysis/01_data-and-bias.md`](analysis/01_data-and-bias.md) | 7-코호트 bias audit + bias-robust 학습/평가 설계 |
| ② | [`analysis/02_ceiling-and-baselines.md`](analysis/02_ceiling-and-baselines.md) | 실패 4-사인(R1–R4) + baseline bar + **닫힘/열림 ledger** |
| ③ | [`analysis/03_novelty-and-direction.md`](analysis/03_novelty-and-direction.md) | 문헌 동향 + 진행 가능한 방향(Lane B/A) + kill-test |
| ④ | [`analysis/04_closure-and-priorities.md`](analysis/04_closure-and-priorities.md) | 닫힌 이유 상세(4라인) + **Korean 데이터 역할** + 우선순위 연구 #1–4 |
| ⭐⑤ | [`analysis/05_active-study-differential-dx.md`](analysis/05_active-study-differential-dx.md) | **활성 positive 연구** — 멀티모달 치매 감별(AD vs 혈관), 검증된 비순환 morph 신호 + Tier 설계 (여기가 현재 작업) |
| ⑥ | [`DECISION_LOG.md`](DECISION_LOG.md) | 모든 결정·NO-GO·폐기·롤백 (2026-06-22 다수 항목: #4·#1 kill, 감별-dx GO) |
| ⑦ | [`ledgers/`](ledgers/) | 음성 결과(NO-GO) 상세 |

## 증거 노트북 (데이터 직접 열람)
`../notebook/` — 각 데이터-문제를 수치+그림으로 입증. `01` 클래스·site 교란 · `02` 라벨·누수 · `03` modality⊥label 저주 · `04` morphometry 천장 · `05` 종단 한계 · `06` **진행 가능한 방향**. 재현: `../notebook/README.md`.

## 디렉토리 규약
```
docs/
  blog/        # 설득형 종합 (그림 추적)
  analysis/    # 기술 분석 (01 data&bias · 02 ceiling&baselines · 03 novelty&direction)
  ledgers/     # 음성 NO-GO 상세
  DECISION_LOG.md · REPO_STRUCTURE.md   # 이력·구조 규약
```
상세 구조: [`REPO_STRUCTURE.md`](REPO_STRUCTURE.md). 축적 지식: `../insight/`. 라인-불문 SoT: `../RESEARCH_BRIEF.md`.
