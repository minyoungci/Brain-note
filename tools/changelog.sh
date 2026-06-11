#!/usr/bin/env bash
# OBSERVATORY 변경 이력 기록기 — 허브 "자체"의 의미있는 변경을 블로그형 노트로 남긴다.
#
# 기록 대상: 구조(디렉토리 추가/이동/삭제)·도구 스크립트(tools/)·문서(루트 *.md)·지식(learn/)·설정(.gitignore 등).
# 제외 대상(노이즈): log/(자동 진행기록)·workspaces/*/notes(원본 미러)·workspaces/*/OVERVIEW.md(자동 블로그).
#   → 매일 쌓이는 자동 콘텐츠는 변경 이력에서 빠지고, 사람이 의도적으로 바꾼 것만 남는다.
#
# 트리거: 스케줄러가 매일 23:50 KST에 1회 호출(+수동 즉시 실행 가능). git 훅 아님(재귀·비용 회피).
# 출력은 log/changelog/(제외 경로)에 쓰므로 자기 자신을 다시 트리거하지 않는다.
# 의미있는 변경이 없으면 LLM 호출 없이 조용히 종료(비용 0).
#
# 사용:
#   tools/changelog.sh                 # 마지막 기록 이후 변경을 정리, commit (push 안 함)
#   DO_PUSH=1 tools/changelog.sh       # commit + push
#   BASE=<sha> tools/changelog.sh      # 시작점 수동 지정(재생성용)
#   SKIP_CRITIC=1 tools/changelog.sh   # critic 생략
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:/home/jovyan/.local/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

HUB="/home/vlm/minyoung/OBSERVATORY"
CLAUDE="/home/jovyan/.local/bin/claude"
DATE="${DATE:-$(date +%F)}"
DO_PUSH="${DO_PUSH:-0}"
SKIP_CRITIC="${SKIP_CRITIC:-0}"
GEN_MODEL="${GEN_MODEL:-claude-sonnet-4-6}"
CRITIC_MODEL="${CRITIC_MODEL:-claude-sonnet-4-6}"
CALL_TIMEOUT="${CALL_TIMEOUT:-360}"
PATCH_CAP="${PATCH_CAP:-24000}"

OUT_DIR="$HUB/log/changelog"
OUT="$OUT_DIR/${DATE}.md"
STATE="$HUB/.changelog.state"   # 마지막으로 처리한 HEAD sha (gitignore)
LOG="$HUB/.changelog.log"
mkdir -p "$OUT_DIR"

log() { echo "[changelog $(date '+%F %T %Z')] $*" >> "$LOG"; }
git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

claude_call() {
  local model="$1" sys="$2"
  timeout "$CALL_TIMEOUT" "$CLAUDE" -p \
    --model "$model" --append-system-prompt "$sys" \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --disallowedTools Bash Edit Write Read Glob Grep WebFetch WebSearch Task NotebookEdit \
    2>>"$LOG"
}

cd "$HUB" || exit 1
HEAD_SHA="$(git rev-parse HEAD)"

# 시작점: 명시 BASE > 상태파일 > '1일 전' 마지막 커밋 > 루트 커밋
if [ -n "${BASE:-}" ]; then
  BASE_SHA="$BASE"
elif [ -f "$STATE" ]; then
  BASE_SHA="$(cat "$STATE")"
else
  BASE_SHA="$(git rev-list -1 --before='1 day ago' HEAD 2>/dev/null || true)"
fi
[ -z "${BASE_SHA:-}" ] && BASE_SHA="$(git rev-list --max-parents=0 HEAD | head -1)"

if [ "$BASE_SHA" = "$HEAD_SHA" ]; then
  echo "[changelog] 새 커밋 없음 — 종료"; log "no new commits ($HEAD_SHA)"; exit 0
fi

# 의미있는 변경만: 자동 콘텐츠 제외 pathspec
EXC=( ':(exclude)log' ':(exclude,glob)workspaces/*/notes/**' ':(exclude,glob)workspaces/*/OVERVIEW.md' )

commits="$(git log --pretty='- %h %s' "${BASE_SHA}..${HEAD_SHA}" -- . "${EXC[@]}" 2>/dev/null)"
if [ -z "$commits" ]; then
  echo "[changelog] 의미있는 변경 없음(자동 콘텐츠뿐) — 종료"; log "no meaningful changes ${BASE_SHA}..${HEAD_SHA}"
  echo "$HEAD_SHA" > "$STATE"   # 처리점 전진(다음 실행이 같은 구간 재검사 안 하도록)
  exit 0
fi

diffstat="$(git diff --stat "$BASE_SHA" "$HEAD_SHA" -- . "${EXC[@]}" 2>/dev/null | tail -60)"
patch="$(git diff "$BASE_SHA" "$HEAD_SHA" -- '*.sh' '*.md' '*.json' '*.yaml' '*.yml' '.gitignore' "${EXC[@]}" 2>/dev/null | head -c "$PATCH_CAP")"

SYS_GEN='너는 연구 지원 허브(OBSERVATORY)의 변경 이력 기록자다. 아래는 허브 "자체"(구조·도구 스크립트·문서·지식·설정)의 의미있는 변경에 대한 git 커밋과 diff다(자동 생성 콘텐츠는 이미 제외됨). 이걸 나중에 사람이 읽고 "무엇이·왜 바뀌었는지" 한눈에 파악하도록 블로그형 한국어 마크다운 변경 노트로 정리하라. diff에 없는 내용을 지어내지 말고, 근거가 약하면 "[불확실]"을 붙여라. 도구 쓰지 말고 제공된 자료만 사용. 형식:
## 한 줄 요약
## 무엇이 바뀌었나 (항목별 — 바뀐 파일/디렉토리를 명시)
## 왜 (배경·의도 — 커밋 메시지/diff에서 추론, 불확실하면 표시)
## 알아둘 점·영향 (사용/공부 동선에 미치는 영향, 주의할 점)'
SYS_CRITIC='너는 비판적 검증자다. [원본 git 커밋/diff]와 [변경노트 초안]을 받아, 초안의 각 항목을 diff와 대조해 검증하라. diff로 뒷받침되지 않거나 과장된 주장은 삭제하거나 "[근거부족]"으로 표시하라. diff에 명백히 있으나 초안이 놓친 중요한 변경은 추가하라. 도구 쓰지 말고 제공된 자료만 사용. 검증·수정된 동일 형식의 한국어 마크다운만 출력.'

src="[허브 변경 커밋]
$commits

[변경 통계(diffstat)]
$diffstat

[변경 패치 일부(코드/문서/설정, 상한 ${PATCH_CAP}B)]
\`\`\`diff
$patch
\`\`\`"

log "start ${BASE_SHA}..${HEAD_SHA}"
echo "[changelog] ${BASE_SHA:0:8}..${HEAD_SHA:0:8} — generator..."
draft="$(printf '%s' "$src" | claude_call "$GEN_MODEL" "$SYS_GEN")"
if [ -z "$draft" ]; then echo "[changelog] generator 실패 — 중단"; log "gen EMPTY"; exit 1; fi

if [ "$SKIP_CRITIC" = "1" ]; then
  final="$draft"
else
  echo "[changelog] critic..."
  final="$(printf '[원본 git 커밋/diff]\n%s\n\n[변경노트 초안]\n%s' "$src" "$draft" | claude_call "$CRITIC_MODEL" "$SYS_CRITIC")"
  [ -z "$final" ] && { echo "[changelog] critic 실패 — 초안 사용"; final="$draft (※critic 실패, 미검증)"; log "critic EMPTY"; }
fi

{
  echo "# 변경 노트 — ${DATE} (KST)"
  echo
  echo "> 허브(구조·도구·문서·지식·설정)의 의미있는 변경 기록. 자동 생성 콘텐츠(log·notes·OVERVIEW)는 제외."
  echo "> LLM 생성→검증 초안. 모델: gen=\`$GEN_MODEL\`$([ "$SKIP_CRITIC" = 1 ] || echo " critic=\`$CRITIC_MODEL\`") · 구간 \`${BASE_SHA:0:8}..${HEAD_SHA:0:8}\`."
  echo
  echo "$final"
  echo
  echo "---"
  echo "<details><summary>원본 커밋 목록</summary>"
  echo
  echo "$commits"
  echo
  echo "</details>"
} > "$OUT"
echo "[changelog] 작성: $OUT ($(wc -l < "$OUT")줄)"
log "wrote $OUT"

echo "$HEAD_SHA" > "$STATE"

cd "$HUB" || exit 1
git_id add "log/changelog/${DATE}.md"
if git_id diff --cached --quiet -- "log/changelog/${DATE}.md"; then
  echo "[changelog] 파일 변경 없음 — commit 생략"
else
  git_id commit -q -m "docs: 허브 변경 노트 ${DATE}" -- "log/changelog/${DATE}.md"
  echo "[changelog] commit 완료"
  if [ "$DO_PUSH" = "1" ]; then
    git_id push origin HEAD 2>/dev/null && echo "[changelog] push 완료" || echo "[changelog] push 실패"
  fi
fi
