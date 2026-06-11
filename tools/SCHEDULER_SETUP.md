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
| `tools/scheduler.sh` | sleep-loop 데몬. 기동 시 7일 누락 **백필**+**note 미러**, 이후 매일 23:50 KST에 미러·요약·**LLM 종합** 발사(일요일 **주간 회고**). |
| `tools/mirror_notes.sh` | 5개 워크스페이스 `*.md` note 를 `workspaces/<ws>/notes/` 로 복사·commit·push(데이터/대형 제외, ≤2MB). |
| `tools/synthesize.sh` | **매일 LLM 종합** — headless `claude -p`로 gen→critic→synth. 워크스페이스별 diff 검증 분석 → cross-workspace 종합 → `log/synthesis/<date>.md`. |
| `tools/weekly_retro.sh` | **주 1회(일) 주간 회고** — 지난 7일 일일 종합+git 활동 → 디렉토리별 실험 종합 → `log/weekly/<date>.md`. |
| `tools/changelog.sh` | **허브 변경 노트** — 허브 자체(구조·도구·문서·지식·설정) 변경을 블로그형으로 → `log/changelog/<date>.md`. 자동 콘텐츠(log·notes·OVERVIEW) 제외, 변경 없으면 LLM 호출 0. |
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
(2026-06-10부터 5개 워크스페이스 모두 git이라 활동 집계·diff·LLM 종합이 git 기반으로 정확하다.)

## 한계 (정직하게)

- **완전 무인은 아니다.** 23:50 KST 시점에 서버가 살아있고 데몬이 떠 있어야 정시 발사된다.
  재시작 후 Min이 그날 Claude/셸을 한 번도 안 열면 그날 정시 발사는 건너뛴다 → **다음 기동 때 백필로 보충.**
- 진짜 무인 상시가 필요하면 → 5개 워크스페이스를 GitHub(private)에 올리고 cloud `/schedule`로 이전해야 한다
  (현재 5개 모두 로컬 git이나 **remote 0개** → 큰 작업).
- **LLM 종합(`synthesize.sh`/`weekly_retro.sh`)은 검토용 초안이다.** gen→critic으로 환각을 거르지만
  완벽하지 않다. 기계적·텍스트적 누락은 잡아도 텍스트에 안 드러난 연구적 사각은 못 잡는다.
  매일 `claude -p` 다회 호출 → **구독 토큰 비용이 매일 발생**(워크스페이스당 ~5분, 5개 ~25–40분).
  무인 품질저하 대비: `.synthesize.log` 로깅 + 출력에 "미검증 초안" 라벨 + critic 게이트.

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
