#!/usr/bin/env bash
# OBSERVATORY userland scheduler — daily_note.sh를 매일 23:50 KST 실행.
#
# 설계 의도:
#   - cron 패키지·root·apt 불필요 (컨테이너 재시작 때 다 날아가는 문제 회피).
#   - 순수 userland sleep-loop. 컨테이너 재시작 시엔 이 프로세스도 죽지만,
#     SessionStart 훅 / .bashrc 가 ensure_scheduler.sh 로 다시 띄운다.
#   - 시작 시 최근 7일 중 빠진 daily note 를 백필한다(git history 기반이라 과거 날짜도 정확).
#     → 재시작으로 며칠 놓쳐도 다음 기동 때 자동 복구된다.
#
# 절대 직접 두 번 띄우지 말 것 — 반드시 ensure_scheduler.sh 경유(중복 가드 있음).
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"

HUB="/home/vlm/minyoung/OBSERVATORY"
TOOLS="$HUB/tools"
LOG="$HUB/.scheduler.log"
PIDFILE="$HUB/.scheduler.pid"
RUN_HHMM="23:50"          # KST. 변경 시 ensure/문서도 함께 갱신.
BACKFILL_DAYS=7

log() { echo "[scheduler $(date '+%F %T %Z')] $*" >> "$LOG"; }

echo $$ > "$PIDFILE"
log "start (pid $$, 발사시각 ${RUN_HHMM} KST)"

# ── 시작 백필: 최근 BACKFILL_DAYS 일(과거) 중 노트 없는 날 생성·push ──
for i in $(seq "$BACKFILL_DAYS" -1 1); do
  d=$(date -d "-$i day" +%F)
  if [ ! -f "$HUB/daily/$d.md" ]; then
    log "backfill $d (노트 없음 → 생성)"
    DATE="$d" DO_PUSH=1 "$TOOLS/daily_note.sh" >> "$LOG" 2>&1
  fi
done

# ── 시작 시 note 미러 1회 (재시작 직후 최신 note 반영) ──
log "startup mirror_notes"
DO_PUSH=1 "$TOOLS/mirror_notes.sh" >> "$LOG" 2>&1

# ── 메인 루프: 매일 RUN_HHMM 에 발사 ──
while true; do
  now=$(date +%s)
  target=$(date -d "today $RUN_HHMM" +%s)
  [ "$now" -ge "$target" ] && target=$(date -d "tomorrow $RUN_HHMM" +%s)
  sleep_s=$(( target - now ))
  log "다음 발사까지 ${sleep_s}s — $(date -d "@$target" '+%F %T %Z')"
  sleep "$sleep_s"
  log "발사: note 미러 + daily_note + LLM 종합 (오늘)"
  DO_PUSH=1 "$TOOLS/mirror_notes.sh" >> "$LOG" 2>&1
  DO_PUSH=1 "$TOOLS/daily_note.sh" >> "$LOG" 2>&1
  DO_PUSH=1 "$TOOLS/synthesize.sh" >> "$LOG" 2>&1
  # 주간 회고: 일요일(date +%u == 7)에만 추가
  if [ "$(date +%u)" = "7" ]; then
    log "주간 회고 발사 (일요일)"
    DO_PUSH=1 "$TOOLS/weekly_retro.sh" >> "$LOG" 2>&1
  fi
  sleep 70   # 같은 분 재진입 방지
done
