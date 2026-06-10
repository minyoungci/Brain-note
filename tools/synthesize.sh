#!/usr/bin/env bash
# OBSERVATORY 일일 LLM 종합 — Generator → Critic → Synthesizer.
#
# 각 워크스페이스의 당일 git diff(코드/문서, 데이터 제외) + daily 활동요약 + 워크스페이스 자체 노트를
# 읽어, 워크스페이스별 (1)진행요약 (2)코드리뷰 (3)놓친것/결정 (4)미해결질문 초안을 만들고,
# 독립 Critic이 diff와 대조해 근거없는/과장된 주장을 거른 뒤, cross-workspace로 종합한다.
#
# 핵심 원칙(사용자 harness.md): 생성과 검증을 분리. 출력은 "검토용 초안"이며 정답이 아니다.
#
# 사용:
#   tools/synthesize.sh                      # 오늘(KST), commit (push 안 함)
#   DATE=2026-06-10 tools/synthesize.sh      # 특정일
#   ONLY_WS=minyoungi tools/synthesize.sh    # 한 워크스페이스만(검증용)
#   DO_PUSH=1 tools/synthesize.sh            # commit + push
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

# 모델 (env로 override). gen/critic는 다회 호출 → Sonnet, 최종 종합 1회 → Opus.
GEN_MODEL="${GEN_MODEL:-claude-sonnet-4-6}"
CRITIC_MODEL="${CRITIC_MODEL:-claude-sonnet-4-6}"
SYNTH_MODEL="${SYNTH_MODEL:-claude-opus-4-8}"
CAP_BYTES="${CAP_BYTES:-30000}"     # 워크스페이스당 patch 상한
CALL_TIMEOUT="${CALL_TIMEOUT:-360}" # claude -p 1회 타임아웃(초)

OUT_DIR="$HUB/synthesis"
OUT="$OUT_DIR/${DATE}.md"
WORK="$(mktemp -d)"
LOG="$HUB/.synthesize.log"
mkdir -p "$OUT_DIR"
trap 'rm -rf "$WORK"' EXIT

log() { echo "[synth $(date '+%F %T %Z')] $*" >> "$LOG"; }
git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

# claude -p 호출: $1=model $2=system-prompt ; user 내용은 stdin ; stdout 반환
claude_call() {
  local model="$1" sys="$2"
  timeout "$CALL_TIMEOUT" "$CLAUDE" -p \
    --model "$model" \
    --append-system-prompt "$sys" \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --disallowedTools Bash Edit Write Read Glob Grep WebFetch WebSearch Task NotebookEdit \
    2>>"$LOG"
}

# 워크스페이스 당일 컨텍스트 묶음 → stdout
gather() {
  local ws="$1" d="$ROOT/$ws"
  echo "## WORKSPACE: $ws"
  if [ ! -d "$d/.git" ]; then echo "(git 저장소 아님 — diff 없음)"; return; fi
  local commits earliest latest base
  commits=$(git -C "$d" log --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" --pretty=%H --reverse 2>/dev/null)
  if [ -z "$commits" ]; then echo "(당일 커밋 없음)"; return; fi
  earliest=$(echo "$commits" | head -1); latest=$(echo "$commits" | tail -1)
  base=$(git -C "$d" rev-parse "${earliest}^" 2>/dev/null) || base=$(git -C "$d" hash-object -t tree /dev/null)
  echo "### commits"
  git -C "$d" log --since="${DATE} 00:00:00" --until="${DATE} 23:59:59" --pretty='- %h %s' 2>/dev/null
  echo; echo "### diff --stat (코드/문서, 데이터 제외)"
  git -C "$d" diff --stat "$base" "$latest" -- '*.py' '*.md' '*.yaml' '*.yml' '*.toml' '*.sh' '*.txt' '*.cfg' '*.ini' \
      ':(exclude)*results*' ':(exclude)*manifests*' ':(exclude)data/*' 2>/dev/null | tail -40
  echo; echo "### diff patch (상한 ${CAP_BYTES}B)"
  echo '```diff'
  git -C "$d" diff "$base" "$latest" -- '*.py' '*.md' '*.yaml' '*.yml' '*.toml' '*.sh' '*.txt' \
      ':(exclude)*results*' ':(exclude)*manifests*' ':(exclude)data/*' 2>/dev/null | head -c "$CAP_BYTES"
  echo; echo '```'
  # 워크스페이스 자체 당일 노트
  for nd in research_notes/daily note/daily research_notes notes; do
    if [ -f "$d/$nd/${DATE}.md" ]; then echo; echo "### 워크스페이스 노트 ($nd/${DATE}.md)"; head -c 8000 "$d/$nd/${DATE}.md"; fi
  done
}

# ── 시스템 프롬프트 ──
SYS_GEN='너는 뇌 MRI 치매진단 VLM 연구의 일일 진행 분석가다. 주어진 한 워크스페이스의 당일 git diff·커밋·노트만 근거로, 추측을 사실로 적지 말고 아래 4섹션 한국어 마크다운으로 작성하라. 근거가 약하면 "[불확실]"을 붙여라. 도구 쓰지 말고 제공된 자료만 사용.
## 진행 요약
## 코드 리뷰 (diff 기반 — 버그/데이터누수/테스트누락/수치불안정/재현성, 각 항목에 파일:대략위치)
## 놓친 것·결정 필요 (커밋과 노트 불일치, 선언했으나 미실행, 미해결 risk)
## 미해결 질문'
SYS_CRITIC='너는 비판적 검증자(Reviewer 2)다. 아래에 [원본 diff/노트]와 [분석 초안]이 있다. 초안의 각 주장을 diff와 대조해 검증하라. diff로 뒷받침되지 않거나 과장된 주장은 삭제하거나 "[근거부족]"으로 표시하라. 초안이 놓친 명백한 항목이 diff에 있으면 추가하라. 도구 쓰지 말고 제공된 자료만 사용. 검증·수정된 동일 4섹션 구조의 한국어 마크다운만 출력.'
SYS_SYNTH='너는 연구 전체를 조망하는 종합가다. 아래 여러 워크스페이스의 (검증된) 일일 분석을 받아, 한국어 마크다운으로 cross-workspace 종합을 작성하라. 과장 금지, 근거 약하면 [불확실]. 형식:
## 오늘 한 줄 요약
## 워크스페이스별 핵심 (각 1~3줄)
## 🔴 주목·결정 필요 (우선순위순, 왜 중요한지 + 당신이 놓쳤을 가능성)
## 코드 리뷰 종합 (반복되는/심각한 결함)
## 미해결 질문 (연속 추적 — 어제 대비 신규/해소)
## 워크스페이스 간 연결·시너지'

log "start DATE=$DATE WS=(${WS[*]}) gen=$GEN_MODEL critic=$CRITIC_MODEL synth=$SYNTH_MODEL"
echo "[synth] DATE=$DATE  workspaces=(${WS[*]})"

# ── 워크스페이스별 Generator → Critic ──
APPROVED="$WORK/approved.md"; : > "$APPROVED"
active=0
for ws in "${WS[@]}"; do
  g="$(gather "$ws")"
  if echo "$g" | grep -qE '당일 커밋 없음|git 저장소 아님'; then
    echo "[synth] $ws — 활동 없음, skip"; log "$ws skip (no activity)"; continue
  fi
  active=$((active+1))
  echo "[synth] $ws — generator..."
  draft="$(printf '%s' "$g" | claude_call "$GEN_MODEL" "$SYS_GEN")"
  if [ -z "$draft" ]; then echo "[synth] $ws — generator 실패"; log "$ws generator EMPTY"; continue; fi
  echo "[synth] $ws — critic..."
  crit_in=$(printf '[원본 diff/노트]\n%s\n\n[분석 초안]\n%s' "$g" "$draft")
  verified="$(printf '%s' "$crit_in" | claude_call "$CRITIC_MODEL" "$SYS_CRITIC")"
  [ -z "$verified" ] && { echo "[synth] $ws — critic 실패, 초안 사용"; verified="$draft (※critic 실패, 미검증)"; log "$ws critic EMPTY"; }
  { echo "# === $ws ==="; echo "$verified"; echo; } >> "$APPROVED"
done

if [ "$active" -eq 0 ]; then
  echo "[synth] 활동 워크스페이스 0 — 종합 생략"; log "no active ws"; exit 0
fi

# ── Synthesizer (cross-workspace) ──
echo "[synth] synthesizer..."
prev="$OUT_DIR/$(date -d "${DATE} -1 day" +%F).md"
synth_in="[오늘 검증된 워크스페이스별 분석]
$(cat "$APPROVED")

[참고: 어제 종합 (연속 추적용, 없으면 생략)]
$( [ -f "$prev" ] && head -c 6000 "$prev" || echo '(없음)')

[참고: OPEN_QUESTIONS.md]
$( [ -f "$HUB/OPEN_QUESTIONS.md" ] && head -c 4000 "$HUB/OPEN_QUESTIONS.md" || echo '(없음)')"
final="$(printf '%s' "$synth_in" | claude_call "$SYNTH_MODEL" "$SYS_SYNTH")"
[ -z "$final" ] && { echo "[synth] synthesizer 실패 — 중단"; log "synth EMPTY"; exit 1; }

# ── 파일 작성 ──
{
  echo "# 🧭 일일 종합 — ${DATE} (KST)"
  echo
  echo "> 🤖 LLM 자동 종합(gen→critic→synth). **검토용 초안이며 미검증 주장이 있을 수 있음.**"
  echo "> 모델: gen=\`$GEN_MODEL\` critic=\`$CRITIC_MODEL\` synth=\`$SYNTH_MODEL\` · 활동 WS ${active}개"
  echo
  echo "$final"
  echo
  echo "---"
  echo "<details><summary>워크스페이스별 검증 분석 (펼치기)</summary>"
  echo
  cat "$APPROVED"
  echo
  echo "</details>"
} > "$OUT"
echo "[synth] 작성: $OUT ($(wc -l < "$OUT")줄)"
log "wrote $OUT"

# ── commit (+push) ──
cd "$HUB" || exit 1
git_id add "synthesis/${DATE}.md"
if git_id diff --cached --quiet -- "synthesis/${DATE}.md"; then
  echo "[synth] 변경 없음 — commit 생략"
else
  git_id commit -q -m "chore: 일일 LLM 종합 ${DATE}" -- "synthesis/${DATE}.md"
  echo "[synth] commit 완료"
  if [ "$DO_PUSH" = "1" ]; then
    git_id push origin HEAD 2>/dev/null && echo "[synth] push 완료" || echo "[synth] push 실패"
  fi
fi
