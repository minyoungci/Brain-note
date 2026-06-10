#!/usr/bin/env bash
# scheduler.sh 가 떠 있지 않으면 띄운다 (멱등).
# SessionStart 훅(~/.claude/settings.json)·.bashrc·수동 어디서 불려도 안전하게 한 인스턴스만 유지.
#
# 동작:
#   1) flock 으로 동시 호출 직렬화 (훅 + 셸 로그인 경합 방지)
#   2) scheduler.sh 가 이미 실행 중이면 아무것도 안 함
#   3) 없으면 detached(setsid+nohup)로 기동. 부모(셸/훅)가 끝나도 살아남음.
#      단 컨테이너 재시작은 못 버팀 → 다음 기동 트리거가 다시 호출.
set -uo pipefail
HUB="/home/vlm/minyoung/OBSERVATORY"
TOOLS="$HUB/tools"
LOG="$HUB/.scheduler.log"
LOCK="$HUB/.scheduler.lock"
PAT="OBSERVATORY/tools/scheduler.sh"   # ensure_scheduler.sh 와 겹치지 않는 패턴

# 1) 직렬화 — 락 못 잡으면 다른 ensure 가 처리 중이므로 조용히 종료
exec 9>"$LOCK"
flock -n 9 || { echo "[ensure_scheduler] 다른 인스턴스 진행 중 — skip"; exit 0; }

# 2) 이미 실행 중?
if pgrep -f "$PAT" >/dev/null 2>&1; then
  echo "[ensure_scheduler] 이미 실행 중 (pid $(pgrep -f "$PAT" | tr '\n' ' '))"
  exit 0
fi

# 3) 기동 — 9>&- 로 락 fd 를 자식에 넘기지 않음(안 그러면 데몬이 락을 영구 점유)
setsid nohup "$TOOLS/scheduler.sh" >> "$LOG" 2>&1 < /dev/null 9>&- &
sleep 1
if pgrep -f "$PAT" >/dev/null 2>&1; then
  echo "[ensure_scheduler] scheduler.sh 기동 완료 (pid $(pgrep -f "$PAT" | tr '\n' ' '))"
else
  echo "[ensure_scheduler] 기동 실패 — $LOG 확인"
  exit 1
fi
