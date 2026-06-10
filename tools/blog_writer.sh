#!/usr/bin/env bash
# 워크스페이스별 기술 블로그형 OVERVIEW 생성 (에이전트 방식).
#
# claude -p 가 /home/vlm/<ws> 를 Read/Glob/Grep 으로 직접 탐색해 실제 내용을 파악하고,
# 출처(파일 경로)를 명시한 기술 블로그 글을 작성한다. 이어 critic 이 같은 파일과 대조해 검증한다.
# 쓰기/실행 도구는 차단(읽기 전용 탐색) — 출력은 stdout 으로 받아 이 스크립트가 파일에 쓴다.
#
# 사용:
#   tools/blog_writer.sh                       # 5개 전부, commit (push 안 함)
#   ONLY_WS=minyoung2 tools/blog_writer.sh     # 한 곳만
#   SKIP_CRITIC=1 ONLY_WS=plant tools/blog_writer.sh
#   DO_PUSH=1 tools/blog_writer.sh             # commit + push
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:/home/jovyan/.local/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

HUB="/home/vlm/minyoung/OBSERVATORY"
ROOT="/home/vlm"
CLAUDE="/home/jovyan/.local/bin/claude"
DATE="${DATE:-$(date +%F)}"
DO_PUSH="${DO_PUSH:-0}"
ALL_WS=(minyoungi minyoung2 minyoung3 minyoung4 plant)
read -ra WS <<< "${ONLY_WS:-${ALL_WS[*]}}"
GEN_MODEL="${GEN_MODEL:-claude-opus-4-8}"
CRITIC_MODEL="${CRITIC_MODEL:-claude-sonnet-4-6}"
SKIP_CRITIC="${SKIP_CRITIC:-0}"
MAX_TURNS="${MAX_TURNS:-60}"
CALL_TIMEOUT="${CALL_TIMEOUT:-1200}"
LOG="$HUB/.synthesize.log"

log() { echo "[blog $(date '+%F %T %Z')] $*" >> "$LOG"; }
git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

ws_dir() {
  local ws="$1" hit
  hit=$(find "$HUB/workspaces" -maxdepth 1 -type d -name "*_${ws}" 2>/dev/null | head -1)
  [ -n "$hit" ] && echo "$hit" || echo "$HUB/workspaces/$ws"
}

# 에이전트 호출: $1=model $2=add-dir(읽기 허용) $3=system ; task 는 stdin ; stdout 반환
agent_call() {
  local model="$1" add="$2" sys="$3"
  timeout "$CALL_TIMEOUT" "$CLAUDE" -p \
    --model "$model" --add-dir "$add" \
    --allowedTools Read Glob Grep \
    --disallowedTools Bash Edit Write WebFetch WebSearch Task NotebookEdit \
    --dangerously-skip-permissions \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --max-turns "$MAX_TURNS" \
    --append-system-prompt "$sys" \
    2>>"$LOG"
}

SYS_BLOG='너는 뇌 MRI 치매진단 VLM 연구를 정확히 전달하는 기술 블로그 작가다. 제공된 워크스페이스 디렉토리를 Read/Glob/Grep으로 직접 탐색해 실제 내용을 파악하라(README/SCRATCHPAD/SPEC/docs/reports/핵심 코드부터, 필요한 만큼 읽어라). 추측 금지 — 읽은 것만 근거로 쓰고, 각 주요 사실 끝에 (출처: 상대경로) 표기. 미확인은 [VERIFY]. STYLE.md 준수: 비판적·정밀, 장식용 이모지 금지, 과장·미사여구 금지. 한국어 기술 블로그 형식:
# <워크스페이스> — <한 줄 주제>
## 한눈에 (3~5줄: 무엇을, 왜, 지금 어디까지)
## 배경·문제 정의
## 데이터
## 접근·방법
## 현재 상태와 결과 (확정 ✅ / 반증 ❌ / 잠정 🟡 구분, 수치는 출처와 함께)
## 폐기·전환된 시도 (있으면)
## 남은 과제·다음 단계
## 출처 맵 (참조한 핵심 파일 목록)
블로그 마크다운 전문만 출력하라(메타발언·도구설명 금지).'

SYS_CRITIC='너는 사실 검증자다. 같은 워크스페이스 디렉토리를 Read/Glob/Grep으로 직접 확인해, 주어진 블로그 초안의 각 주장을 파일과 대조하라. 틀린 수치·경로·커밋해시·해석은 수정하고, 파일로 뒷받침 안 되는 문장은 삭제하거나 [근거부족] 표기. 과장·미사여구는 정제. STYLE.md 준수. 검증·수정된 블로그 전문만 출력(메타발언 금지).'

echo "[blog] DATE=$DATE WS=(${WS[*]}) gen=$GEN_MODEL critic=$([ "$SKIP_CRITIC" = 1 ] && echo skip || echo "$CRITIC_MODEL")"
log "start WS=(${WS[*]})"
made=0
for ws in "${WS[@]}"; do
  src="$ROOT/$ws"; [ -d "$src" ] || { echo "[blog] $ws 없음"; continue; }
  out="$(ws_dir "$ws")/OVERVIEW.md"
  echo "[blog] $ws — generator (에이전트 탐색)..."
  task="다음 디렉토리를 직접 탐색해 기술 블로그형 OVERVIEW를 작성하라: ${src}
시작점 후보: README.md · SCRATCHPAD.md · SPEC.md · docs/ · reports/ · note/. 필요하면 핵심 코드도 읽어라.
대용량 데이터(results/·manifests/·data/·*.npy·*.csv)는 열지 말 것. 블로그 마크다운 전문만 출력."
  draft="$(printf '%s' "$task" | agent_call "$GEN_MODEL" "$src" "$SYS_BLOG")"
  if [ -z "$draft" ]; then echo "[blog] $ws — generator 실패"; log "$ws gen EMPTY"; continue; fi

  if [ "$SKIP_CRITIC" = "1" ]; then
    final="$draft"
  else
    echo "[blog] $ws — critic (에이전트 검증)..."
    ctask="아래 블로그 초안을 ${src} 의 실제 파일과 대조해 검증·수정하라. 블로그 전문만 출력.

[초안]
${draft}"
    final="$(printf '%s' "$ctask" | agent_call "$CRITIC_MODEL" "$src" "$SYS_CRITIC")"
    [ -z "$final" ] && { echo "[blog] $ws — critic 실패, 초안 사용"; log "$ws critic EMPTY"; final="$draft"; }
  fi

  # gen/critic 이 H1 제목 앞에 메타발언을 붙이면 제거 (블로그는 '# <ws>' 로 시작)
  stripped="$(printf '%s\n' "$final" | awk 'f||/^# /{f=1} f')"
  [ -n "$stripped" ] && final="$stripped"

  mkdir -p "$(dirname "$out")"
  {
    echo "$final"
    echo
    echo "---"
    echo "> 자동 생성: LLM 에이전트가 \`${src#$ROOT/}\` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=\`$GEN_MODEL\`$([ "$SKIP_CRITIC" = 1 ] || echo " critic=\`$CRITIC_MODEL\`") · 갱신 ${DATE}."
  } > "$out"
  echo "[blog] $ws — 작성: ${out#$HUB/} ($(wc -l < "$out")줄)"
  log "$ws wrote ${out#$HUB/}"
  made=$((made+1))
done

[ "$made" -eq 0 ] && { echo "[blog] 생성 0건"; exit 0; }
cd "$HUB" || exit 1
git_id add workspaces/*/OVERVIEW.md
if git_id diff --cached --quiet; then
  echo "[blog] 변경 없음 — commit 생략"
else
  git_id commit -q -m "docs: 워크스페이스별 기술 블로그 OVERVIEW (${DATE})" -- 'workspaces/*/OVERVIEW.md'
  echo "[blog] commit 완료"
  [ "$DO_PUSH" = "1" ] && { git_id push origin HEAD 2>/dev/null && echo "[blog] push 완료" || echo "[blog] push 실패"; }
fi
