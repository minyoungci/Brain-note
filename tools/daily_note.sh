#!/usr/bin/env bash
# OBSERVATORY daily research-log 생성기.
# 5개 워크스페이스의 당일(KST) git 활동/파일 변경을 모아 daily note를 쓰고 commit(+옵션 push).
#
# 사용:
#   tools/daily_note.sh                # 오늘(KST) 노트 생성·commit
#   DATE=2026-06-01 tools/daily_note.sh  # 특정일 재생성
#   DO_PUSH=1 tools/daily_note.sh      # commit 후 origin push 시도
#
# cron 최소환경 대비: 절대경로·PATH·TZ·HOME 명시.
set -uo pipefail

export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"
export TZ="Asia/Seoul"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

HUB="/home/vlm/minyoung/OBSERVATORY"
ROOT="/home/vlm"
WORKSPACES=(minyoungi minyoung2 minyoung3 minyoung4 plant)
DATE="${DATE:-$(date +%F)}"
NEXT="$(date -d "${DATE} +1 day" +%F)"   # 다음날 자정 = 당일 상한 (inline '+1 day'는 오파싱됨)
DO_PUSH="${DO_PUSH:-0}"

OUT_DIR="$HUB/log/daily"
OUT="$OUT_DIR/${DATE}.md"
mkdir -p "$OUT_DIR"

git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

# 워크스페이스별 당일 활동 수집
collect() {
  local ws="$1" dir="$ROOT/$1" had=0
  echo "### $ws"
  if [ ! -d "$dir" ]; then echo "- (디렉토리 없음)"; echo; return; fi
  if [ -d "$dir/.git" ]; then
    local commits
    commits=$(git -C "$dir" log --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" \
              --date=local --pretty=format:'  - %h %s' 2>/dev/null)
    if [ -n "$commits" ]; then
      echo "**commits:**"; echo "$commits"; had=1
      # 당일 변경 파일 수
      local files
      files=$(git -C "$dir" log --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" \
              --name-only --pretty=format: 2>/dev/null | sed '/^$/d' | sort -u | wc -l)
      echo "  - (변경 파일 $files개)"
    fi
  else
    echo "_(git 없음 — 파일 mtime 기준)_"
    local changed
    changed=$(find "$dir" \( -path '*/.git/*' -o -path '*/__pycache__/*' \) -prune -o \
              -type f -newermt "${DATE} 00:00:00" ! -newermt "${NEXT} 00:00:00" -print 2>/dev/null \
              | grep -vE '\.(pyc|npz|pt|ckpt|png|jpg|svg|nii|nii\.gz)$' \
              | sed "s#$dir/##" | head -25)
    if [ -n "$changed" ]; then
      echo "**변경/생성 파일(상위 25):**"
      echo "$changed" | sed 's/^/  - /'; had=1
    fi
  fi
  [ "$had" = 0 ] && echo "- 기록된 활동 없음"
  echo
}

{
  echo "# Daily Note — ${DATE} (KST)"
  echo
  echo "> 자동 생성: \`tools/daily_note.sh\` · 5개 워크스페이스 당일 git/파일 활동 집계."
  echo "> 이 노트는 기계 집계다. 해석·인사이트는 사람이 아래 '메모'에 보강한다."
  echo
  echo "## 워크스페이스 활동"
  echo
  for ws in "${WORKSPACES[@]}"; do collect "$ws"; done
  echo "## 메모 (수동 보강)"
  echo
  echo "- "
  echo
} > "$OUT"

echo "[daily_note] 작성: $OUT ($(wc -l < "$OUT")줄)"

# commit — daily 파일 경로로만 스코프(무관한 staged 변경 휩쓸림 방지)
cd "$HUB" || exit 1
git_id add "log/daily/${DATE}.md"
if git diff --cached --quiet -- "log/daily/${DATE}.md"; then
  echo "[daily_note] 변경 없음 — commit 생략"
else
  git_id commit -q -m "chore: daily note ${DATE} 자동 생성" -- "log/daily/${DATE}.md"
  echo "[daily_note] commit 완료"
  if [ "$DO_PUSH" = "1" ]; then
    if git_id push origin HEAD 2>/dev/null; then echo "[daily_note] push 완료"; else echo "[daily_note] push 실패(네트워크/인증)"; fi
  fi
fi
