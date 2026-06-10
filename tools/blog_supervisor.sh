#!/usr/bin/env bash
# blog_writer 감시·자가복구 supervisor.
#
# blog_writer.sh 실행을 추적한다:
#   - 진행/완료/정체(stall)/실패 판정
#   - 프로세스가 죽었는데 미완이면 → 남은 워크스페이스만 자동 재개(ONLY_WS, 최대 MAX_RESTART회)
#   - 상태를 .blog_status.md 에 매 주기 기록
# detached(setsid nohup)로 돌려 세션이 끊겨도 감시가 지속되게 한다.
# blog_writer.sh 는 실행 중일 수 있으므로 절대 수정하지 않고, ONLY_WS 인자로만 제어한다.
#
# 사용(반드시 detached 로):
#   setsid nohup tools/blog_supervisor.sh >> .supervisor.log 2>&1 < /dev/null &
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:/home/jovyan/.local/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"

HUB="/home/vlm/minyoung/OBSERVATORY"
TOOLS="$HUB/tools"
read -ra TARGETS <<< "${TARGETS:-minyoungi minyoung3 minyoung4 plant}"
TODAY="$(date +%F)"
POLL="${POLL:-90}"
STALL_MIN="${STALL_MIN:-25}"
MAX_RESTART="${MAX_RESTART:-2}"
LOG="$HUB/.blog.log"
SLOG="$HUB/.supervisor.log"
STATUS="$HUB/.blog_status.md"
LOCK="$HUB/.supervisor.lock"
PAT='tools/blog_writer\.sh'   # blog_writer 만 매칭(blog_supervisor 와 안 겹침)

slog(){ echo "[sup $(date '+%F %T %Z')] $*" >> "$SLOG"; }

# 중복 supervisor 방지
exec 8>"$LOCK"
flock -n 8 || { slog "다른 supervisor 실행 중 — 종료"; exit 0; }

ws_overview(){ local h; h=$(find "$HUB/workspaces" -maxdepth 1 -type d -name "*_$1" 2>/dev/null|head -1); echo "${h:-$HUB/workspaces/$1}/OVERVIEW.md"; }
is_done(){ local f; f=$(ws_overview "$1"); [ -f "$f" ] && [ "$(date -r "$f" +%F 2>/dev/null)" = "$TODAY" ]; }
running(){ pgrep -f "$PAT" >/dev/null 2>&1; }

write_status(){ # $1=state ; uses done_list/miss_list/restarts
  { echo "# blog 생성 감시 상태"
    echo
    echo "> 갱신: $(date '+%F %T %Z') · supervisor pid $$"
    echo
    echo "- 상태: **$1**"
    echo "- 완료 ${#done_list[@]}/${#TARGETS[@]}: ${done_list[*]:-(없음)}"
    echo "- 미완: ${miss_list[*]:-(없음)}"
    echo "- 자동 재개: $restarts/$MAX_RESTART 회"
    echo "- blog_writer 프로세스: $(running && echo 실행중 || echo 없음)"
    echo "- 최근 로그(.blog.log):"
    tail -4 "$LOG" 2>/dev/null | sed 's/^/    /'
  } > "$STATUS"
}

restarts=0
slog "supervisor 시작 targets=(${TARGETS[*]}) pid=$$"
while true; do
  done_list=(); miss_list=()
  for ws in "${TARGETS[@]}"; do is_done "$ws" && done_list+=("$ws") || miss_list+=("$ws"); done

  if [ ${#miss_list[@]} -eq 0 ]; then
    write_status "완료(done) — 전체 ${#TARGETS[@]}개 생성"
    slog "전부 완료 → 종료"; break
  fi

  if running; then
    lastmod=$(date -r "$LOG" +%s 2>/dev/null || echo 0); idle=$(( $(date +%s) - lastmod ))
    if [ "$idle" -gt $((STALL_MIN*60)) ]; then
      write_status "정체(stall) — ${idle}s 무진행 (점검 필요; 자동 kill 안 함)"
      slog "stall ${idle}s (미완: ${miss_list[*]})"
    else
      write_status "진행중(running) — 미완: ${miss_list[*]}"
    fi
  else
    # 프로세스 없는데 미완 → 죽음
    if [ "$restarts" -lt "$MAX_RESTART" ]; then
      restarts=$((restarts+1))
      slog "blog_writer 종료·미완(${miss_list[*]}) → 자동 재개 #$restarts"
      setsid nohup bash -c "ONLY_WS='${miss_list[*]}' DO_PUSH=1 '$TOOLS/blog_writer.sh'" >> "$LOG" 2>&1 < /dev/null &
      write_status "자동 재개 #$restarts — ${miss_list[*]}"
      sleep 12
    else
      write_status "실패(failed) — 재개 ${MAX_RESTART}회 소진, 미완: ${miss_list[*]}"
      slog "재개 소진·미완(${miss_list[*]}) → 종료"; break
    fi
  fi
  sleep "$POLL"
done
