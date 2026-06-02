# OBSERVATORY — minyoung 연구 감시·지식 허브

> **목적:** `/home/vlm`의 5개 연구 워크스페이스를 상시 추적하고, 연구 이해에 필요한 지식·인사이트·학습자료를 집약  ·  **갱신:** 2026-06-02

`/home/vlm`의 5개 연구 워크스페이스(minyoungi, minyoung2, minyoung3, minyoung4, plant)를
상시 추적하고, 그 연구를 이해하는 데 필요한 지식·인사이트·학습자료를 한곳에 모은 허브.
문서 작성 규약은 `STYLE.md`를 따른다.

> ⚠️ 이 허브는 **2차 자료**다. 진실의 원천(source of truth)은 항상 각 워크스페이스의
> SCRATCHPAD / report / 코드다. 모든 카드는 출처(`경로@상태`)를 박아 추적 가능해야 한다.

## 진입점

- **`DASHBOARD.md`** — 한 장 요약. 5개 워크스페이스 상태·blocker·다음 게이트. **여기서 시작.**
- `workspaces/<dir>/` — 워크스페이스별 상세 카드(폴더 안에 여러 문서로 분리).
- `knowledge/` — 연구 지식 저장(개념 설명, 공부 자료).
- `insights/MUST_KNOW.md` — 반드시 알아야 하는 횡단 인사이트.
- `study/curriculum.md` — 무엇을 어떤 순서로 공부할지.

## 디렉토리 의미 분담

| 디렉토리 | 역할 | 답하는 질문 |
|---|---|---|
| `workspaces/` | **실험별 정리** | "이 워크스페이스에서 지금 뭐가 돌아가고 뭐가 막혔나?" |
| `knowledge/` | **지식 저장** | "이 개념/데이터가 뭔지 처음부터 이해하려면?" |
| `insights/` | **횡단 인사이트** | "5개 연구를 관통하는, 내가 꼭 알아야 할 교훈은?" |
| `study/` | **공부 커리큘럼** | "무엇을 어떤 순서로 학습할까?" |

## 워크스페이스별 카드 골격 (`workspaces/<dir>/`)

| 파일 | 내용 |
|---|---|
| `README.md` | 한 장 카드: 주제·1줄 가설·현재 상태·다음 게이트 |
| `findings.md` | 핵심 결과/수치(확정·반증 포함), 실험 라인 흐름 |
| `risks.md` | blocker·실패 모드·열린 약점 |
| `sources.md` | 원본 경로/커밋 추적(이 카드가 무엇을 근거로 했나) |

휴면 워크스페이스(minyoung4)는 `README.md` 한 장만.

## 갱신 규칙 (stale 방지)

이 허브의 최대 적은 **노후화**다. 5개 repo가 매일 커밋된다. 다음을 지킨다.

1. **갱신 트리거**: 각 워크스페이스를 다룬 세션 종료 시, 또는 주 1회, 아래로 변경분 확인.
   ```bash
   for d in minyoungi minyoung2 minyoung3 minyoung4 plant; do
     echo "=== $d ==="; git -C /home/vlm/$d log --oneline -5 2>/dev/null || echo "(no git)"
   done
   ```
   minyoung3·plant는 git이 없으니 SCRATCHPAD/report의 mtime과 `Last updated` 줄을 확인.
2. **출처 우선**: 카드 수정 전 원본 SCRATCHPAD/report를 다시 읽고, 바뀐 사실만 surgical하게 갱신.
3. **확정/반증 표기**: 결과는 ✅확정 / ❌반증(falsified) / 🟡잠정 으로 명시. "잘 됐다" 금지.
4. **날짜 박기**: 카드 상단 `_갱신: YYYY-MM-DD (커밋/리포트 기준)_`.

## 버전관리

이 허브는 **독립 git repo** (`OBSERVATORY/.git`). 부모 `/home/vlm`은 `minyoung/*`를 ignore하므로
여기 두지 않으면 버전관리가 안 된다. 단, **같은 디스크**라 진짜 백업은 아니다 — 중요 시 원격 push 권장.
