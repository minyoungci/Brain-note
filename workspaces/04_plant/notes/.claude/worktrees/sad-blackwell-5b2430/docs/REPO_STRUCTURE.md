# REPO STRUCTURE — microbrain (plant)

> 목적별 디렉토리 규약. **생성(src) ↔ 평가(experiments/tests) 분리**가 핵심 원칙
> (CLAUDE.md "생성과 검증은 분리된 단계"의 구조적 구현). 작성 2026-06-11.

```
plant/
├── RESEARCH_BRIEF.md          # 설계 단일 진실(SoT)
├── CLAUDE.md                  # 운영 규칙
├── SCRATCHPAD.md              # live 상태 / 핸드오프
├── docs/
│   ├── README.md              # ★ 문서 인덱스 — 여기부터 읽는다
│   ├── blog/                  # 설득형 종합(the-data-ceiling.md) + figures/ (추적)
│   ├── analysis/              # 기술 분석 — 01 data&bias · 02 ceiling&baselines · 03 novelty&direction
│   ├── DECISION_LOG.md        # 피벗·NO-GO·롤백 (되돌리기 근거)
│   ├── REPO_STRUCTURE.md      # 이 파일 (디렉토리 규약)
│   ├── <phase>_plan.md        # 새 라인 단계 설계서(승인 게이트). 코드 전 합의
│   └── ledgers/               # 음성 결과 상세 ledger (실험별 NO-GO 기록)
├── notebook/                  # 데이터-문제 증거 + feasible 방향 (01–06, _build.py, figures/)
├── src/microbrain/            # 재사용 라이브러리 (테스트됨, 실험이 import)
│   └── audit.py              #   재사용 통계 primitives (bias/confound audit)
│                             #   (로더·split·metric 등은 새 라인에서 필요 시 추가)
├── experiments/              # 실험별 얇은 스크립트 (src 호출, 1실험=1질문). 현재 빈 스캐폴드
│                             #   새 라인 착수 시 <phase>/ 디렉토리 생성 (docs/<phase>_plan.md 와 1:1)
├── tests/                    # 단위테스트: split disjointness · 입력누수 · label timestamp
├── results/                  # 실험 산출물 (생성 시). 작은 report(.md/.csv)만 commit, 무거운 건 .gitignore
└── data/derived/            # 파생 feature — gitignore (manifest에서 재생성 가능). 현재 비어있음
```

## 규약

1. **src = 생성, experiments = 사용.** 실험 스크립트는 로직을 담지 않고 `src/microbrain`을 호출만 한다. 같은 로더·split·metric을 모든 실험이 공유 → 누수 경로가 한 곳에 모여 audit 가능.
2. **1 실험 = 1 falsifiable 질문 = 1 디렉토리.** 각 실험 디렉토리는 `run.py`(또는 `.sh`) + `REPORT.md`(숫자 결과 + 사전등록 판정) + 산출 CSV를 담는다. REPORT.md는 commit, 무거운 산출물은 ignore.
3. **평가 분리.** `tests/`의 split/누수 단위테스트가 통과해야 실험 결과를 "유효"로 친다 (자기평가 금지).
4. **음성 결과 보존.** NO-GO는 `docs/ledgers/`에 `[날짜·실험·왜·되돌아갈 commit]`으로 기록. DECISION_LOG.md에 한 줄 요약.
5. **데이터 read-only.** `/home/vlm/data` 쓰기 금지. 파생물은 `data/derived/`·`results/`만.
6. **승인 게이트.** `src/`·`experiments/`의 **코드 작성·실행은 해당 단계 설계서(docs/<phase>_plan.md) 승인 후.** 현재 활성 라인 없음(2026-06-17 클린 리셋) → `experiments/`는 *빈 스캐폴드*, 다음 주제 대기.
