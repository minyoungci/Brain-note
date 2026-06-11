# daily · 자동 연구 일지

> **목적:** 5개 워크스페이스의 당일 활동을 자동 집계한 연구 일지 보관  ·  **갱신:** 2026-06-02

## 구성

- `YYYY-MM-DD.md` — 하루치 일지. `tools/daily_note.sh`가 생성·commit.
- 각 워크스페이스의 당일(KST) **git 커밋**(git repo) 또는 **변경 파일 mtime**(git 없는 minyoung3·plant)을 집계.

## 동작

```bash
tools/daily_note.sh                  # 오늘(KST) 노트 생성·commit
DATE=2026-06-01 tools/daily_note.sh  # 특정일 재생성(멱등 — 같은 날 재실행 시 내용 동일하면 commit 생략)
DO_PUSH=1 tools/daily_note.sh        # commit 후 origin push
```

- 시간대 KST(`TZ=Asia/Seoul`) 기준 하루 경계. cron 최소환경 대비 절대경로·PATH·SSH 옵션 내장.
- 일지는 **기계 집계**다. 해석·인사이트는 각 노트 하단 `## 메모 (수동 보강)`에 사람이 추가한다.

## 한계 (인지)

- ⚠️ git 없는 워크스페이스(minyoung3·plant)는 "무엇을 했는지"가 아니라 "어떤 파일이 바뀌었는지"만 보인다.
  → 두 워크스페이스에 git을 도입하면 커밋 메시지 기반의 의미 있는 일지가 된다.
- ⚠️ 기계 집계는 "왜"를 모른다. 연구적 판단은 수동 메모 또는 별도 narrative 보강이 필요하다.
- 자동화 스케줄러 설정은 `tools/CRON_SETUP.md` 참조.
