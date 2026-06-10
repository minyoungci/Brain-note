# SCHEDULER_SETUP — daily note 자동화 (userland, 재시작 생존형)

> **목적:** `daily_note.sh`를 매일 **23:50 KST** 자동 실행·commit·push 한다.
> **갱신:** 2026-06-10 · **대체 대상:** `CRON_SETUP.md`(OS cron 방식, 컨테이너 재시작 때 소멸 → 폐기)

## 왜 바꿨나 (이전 방식의 실패)

OS cron(`cron` .deb + `sudo /usr/sbin/cron`)은 **컨테이너 재시작 한 번에 통째로 사라졌다.**
- 이 서버는 s6-overlay 컨테이너(PID1 = `s6-svscan`). `/home/vlm`·`/home/jovyan/.claude` 외의
  파일·설치 패키지·`/etc/services.d`는 **재시작 시 전부 휘발**한다.
- 2026-06-09 11:10 UTC 재시작 → cron 패키지·데몬·crontab·s6 서비스 전부 소멸 → 6/9 노트 누락.

→ **root·apt·cron 패키지에 의존하지 않는 순수 userland 방식**으로 재설계.

## 구성

| 구성요소 | 역할 |
|---|---|
| `tools/scheduler.sh` | sleep-loop 데몬. 기동 시 최근 7일 누락분 **백필**, 이후 매일 23:50 KST 발사. |
| `tools/ensure_scheduler.sh` | 데몬이 없으면 띄움(멱등, flock+pgrep 가드). **재무장 진입점.** |
| `~/.claude/settings.json` `SessionStart` 훅 | Claude Code 세션 시작 때마다 ensure 호출. |
| `~/.bashrc` 한 줄 | SSH/셸 로그인 때마다 ensure 호출. |

두 트리거(Claude 세션 / 셸 로그인) 중 **먼저 일어나는 쪽**이 재시작 후 데몬을 부활시킨다.

## 동작 원리 — 재시작 생존

```
컨테이너 재시작 → scheduler.sh 죽음 (모든 프로세스가 죽음)
        ↓
다음에 Min이 ① Claude Code 세션 시작  또는  ② SSH 로그인
        ↓
SessionStart 훅 / .bashrc → ensure_scheduler.sh → scheduler.sh 재기동
        ↓
scheduler.sh 기동 즉시 backfill: 누락된 날(최근 7일) daily note 생성·push
```

**핵심:** 며칠 놓쳐도 git history 기반 백필로 과거 날짜 노트를 정확히 복구한다(끊긴 날 영구 손실 없음).
단 `minyoung3`·`plant`는 git이 아니라 **파일 mtime 기반**이라, 한참 뒤 백필 시 과거 활동 집계가 부정확할 수 있다(`[VERIFY]`).

## 한계 (정직하게)

- **완전 무인은 아니다.** 23:50 KST 시점에 서버가 살아있고 데몬이 떠 있어야 정시 발사된다.
  재시작 후 Min이 그날 Claude/셸을 한 번도 안 열면 그날 정시 발사는 건너뛴다 → **다음 기동 때 백필로 보충.**
- 진짜 무인 상시가 필요하면 → 5개 워크스페이스를 GitHub(private)에 올리고 cloud `/schedule`로 이전해야 한다
  (현재 5개 중 GitHub 연결 0개, `minyoung3`·`plant`는 git repo도 아님 → 큰 작업).

## 헬스체크 / 수동 조작

```bash
# 데몬 살아있나
pgrep -af 'OBSERVATORY/tools/scheduler.sh'

# 죽었으면 재기동 (멱등 — 떠 있으면 아무 일 안 함)
tools/ensure_scheduler.sh

# 로그
tail -20 .scheduler.log

# 강제 종료 후 재기동
kill "$(cat .scheduler.pid)"; tools/ensure_scheduler.sh

# cron 없이 수동 1회 실행
DO_PUSH=1 tools/daily_note.sh                 # 오늘
DATE=2026-06-09 DO_PUSH=1 tools/daily_note.sh # 특정일(멱등)
```

## 검증 기록 (2026-06-10)

- ✅ ensure → 데몬 1개 기동, 2차 호출 시 중복 미발생(멱등).
- ✅ 백필: 누락된 2026-06-09 노트 생성·commit(`ffb9720`)·**push** 성공, `origin/main` 동기화 확인.
- ✅ `.bashrc` 트리거가 셸 init에서 데몬 기동함을 실측.
- ⏳ `SessionStart` 훅 발사는 다음 Claude 세션 시작 시 확인(설정 JSON 유효성·스크립트 멱등성은 검증됨).
