#!/usr/bin/env bash
# OBSERVATORY 주간 회고 — 지난 7일의 일일 종합 + 주간 git 활동을 받아
# 디렉토리(워크스페이스)별 실험 종합 회고 + 주간 cross-workspace 종합을 만든다.
#
# 입력은 이미 critic 검증된 daily synthesis 가 주력 → 효율적이고 신뢰도 높음.
# 한 번 더 critic 으로 주간 초안을 git 활동과 대조해 거른다.
#
# 사용:
#   tools/weekly_retro.sh              # 오늘 기준 지난 7일, commit (push 안 함)
#   DO_PUSH=1 tools/weekly_retro.sh    # commit + push
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:/home/jovyan/.local/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

HUB="/home/vlm/minyoung/OBSERVATORY"
ROOT="/home/vlm"
CLAUDE="/home/jovyan/.local/bin/claude"
DATE="${DATE:-$(date +%F)}"
WSTART="$(date -d "${DATE} -6 day" +%F)"
DO_PUSH="${DO_PUSH:-0}"
WORKSPACES=(minyoungi minyoung2 minyoung3 minyoung4 plant)
GEN_MODEL="${GEN_MODEL:-claude-opus-4-8}"
CRITIC_MODEL="${CRITIC_MODEL:-claude-sonnet-4-6}"
CALL_TIMEOUT="${CALL_TIMEOUT:-600}"

OUT_DIR="$HUB/log/weekly"; OUT="$OUT_DIR/${DATE}.md"
LOG="$HUB/.synthesize.log"
mkdir -p "$OUT_DIR"
log() { echo "[weekly $(date '+%F %T %Z')] $*" >> "$LOG"; }
git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

claude_call() {
  local model="$1" sys="$2"
  timeout "$CALL_TIMEOUT" "$CLAUDE" -p \
    --model "$model" --append-system-prompt "$sys" \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --disallowedTools Bash Edit Write Read Glob Grep WebFetch WebSearch Task NotebookEdit \
    2>>"$LOG"
}

# 주간 git 활동(워크스페이스별, 코드/문서, --stat 압축)
week_activity() {
  local ws d="$ROOT/$1"
  echo "### $1"
  [ -d "$d/.git" ] || { echo "(git 아님)"; return; }
  local c; c=$(git -C "$d" log --since="${WSTART} 00:00:00" --until="${DATE} 23:59:59" --pretty='- %h %ad %s' --date=short 2>/dev/null)
  [ -z "$c" ] && { echo "(주간 커밋 없음)"; return; }
  echo "$c"
  echo "변경 통계:"; git -C "$d" log --since="${WSTART} 00:00:00" --until="${DATE} 23:59:59" --stat --pretty=format: -- \
     '*.py' '*.md' '*.yaml' '*.yml' '*.sh' ':(exclude)*results*' ':(exclude)*manifests*' 2>/dev/null \
     | grep -E '\|' | sed 's/^ *//' | sort | uniq -c | sort -rn | head -25
}

# 지난 7일 daily synthesis 모음 (critic 검증된 분석)
week_syntheses() {
  local d
  for i in $(seq 6 -1 0); do
    d=$(date -d "${DATE} -${i} day" +%F)
    [ -f "$HUB/log/synthesis/$d.md" ] && { echo "===== daily synthesis $d ====="; head -c 4000 "$HUB/log/synthesis/$d.md"; echo; }
  done
}

SYS_GEN='너는 뇌 MRI 치매진단 VLM 연구의 주간 회고가다. 아래 지난 7일 "일일 종합"(이미 검증됨)과 "주간 git 활동"만 근거로, 한국어 마크다운 주간 회고를 써라. 추측을 사실로 쓰지 말고 근거 약하면 [불확실]. 형식:
## 주간 한 줄 요약
## 디렉토리별 실험 회고 (워크스페이스마다: 이번 주 진행한 실험/작업, 결과·결론, 폐기·전환, 교훈)
## 주간 핵심 이슈·결정 필요 (우선순위, 왜 중요한지)
## 미해결 질문 — 주간 연속 추적 (이번 주 신규/해소/지속)
## 다음 주 제언'
SYS_CRITIC='너는 비판적 검증자다. [주간 git 활동]과 [주간 회고 초안]을 받아, 초안의 주장을 git 활동과 대조해 근거 없는/과장된 것을 삭제하거나 [근거부족] 표시하라. git 활동에 명백히 있으나 누락된 건 추가. 검증·수정된 동일 구조 한국어 마크다운만 출력.'

log "start weekly ${WSTART}..${DATE}"
echo "[weekly] 기간 ${WSTART} ~ ${DATE}"
ACT="$(for ws in "${WORKSPACES[@]}"; do week_activity "$ws"; echo; done)"
SYN="$(week_syntheses)"

gen_in="[지난 7일 일일 종합]
${SYN:-(없음 — 이번 주 daily synthesis 미생성)}

[주간 git 활동]
$ACT"
echo "[weekly] generator..."
draft="$(printf '%s' "$gen_in" | claude_call "$GEN_MODEL" "$SYS_GEN")"
[ -z "$draft" ] && { echo "[weekly] generator 실패 — 중단"; log "gen EMPTY"; exit 1; }
echo "[weekly] critic..."
final="$(printf '[주간 git 활동]\n%s\n\n[주간 회고 초안]\n%s' "$ACT" "$draft" | claude_call "$CRITIC_MODEL" "$SYS_CRITIC")"
[ -z "$final" ] && { echo "[weekly] critic 실패 — 초안 사용"; final="$draft (※critic 실패, 미검증)"; log "critic EMPTY"; }

{
  echo "# 주간 회고 — ${WSTART} ~ ${DATE} (KST)"
  echo
  echo "> LLM 주간 종합(gen→critic). 입력: 지난 7일 일일 종합 + 주간 git 활동. **검토용 초안.**"
  echo "> 모델: gen=\`$GEN_MODEL\` critic=\`$CRITIC_MODEL\`"
  echo
  echo "$final"
} > "$OUT"
echo "[weekly] 작성: $OUT ($(wc -l < "$OUT")줄)"; log "wrote $OUT"

cd "$HUB" || exit 1
git_id add "log/weekly/${DATE}.md"
if git_id diff --cached --quiet -- "log/weekly/${DATE}.md"; then
  echo "[weekly] 변경 없음 — commit 생략"
else
  git_id commit -q -m "chore: 주간 회고 ${WSTART}~${DATE}" -- "log/weekly/${DATE}.md"
  echo "[weekly] commit 완료"
  [ "$DO_PUSH" = "1" ] && { git_id push origin HEAD 2>/dev/null && echo "[weekly] push 완료" || echo "[weekly] push 실패"; }
fi
