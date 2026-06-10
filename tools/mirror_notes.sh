#!/usr/bin/env bash
# OBSERVATORY note 미러 — 5개 워크스페이스의 *.md note 를 Brain-note 로 복사.
#
#   /home/vlm/<ws>/**/*.md  →  OBSERVATORY/workspaces/<NN_ws>/notes/<상대경로>
#
# 규칙:
#   - *.md 전부 (어느 깊이든). 단 무거운/무관 디렉토리 제외, ≤2MB 만.
#   - 깨끗한 미러: 매 실행마다 notes/ 를 비우고 다시 채움 → 원본 삭제·이름변경이 그대로 반영.
#   - 수동 큐레이션 카드(workspaces/<NN_ws>/{README,findings,risks,sources}.md)는 notes/ 밖이라 안 건드림.
#   - rsync 없음(컨테이너) → find + cp.
#
# 사용:
#   tools/mirror_notes.sh           # 미러 + commit (push 안 함)
#   DO_PUSH=1 tools/mirror_notes.sh # 미러 + commit + push
set -uo pipefail
export TZ="Asia/Seoul"
export PATH="/usr/bin:/bin:/usr/local/bin:/opt/conda/bin:${PATH:-}"
export HOME="${HOME:-/home/jovyan}"
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"

HUB="/home/vlm/minyoung/OBSERVATORY"
ROOT="/home/vlm"
WORKSPACES=(minyoungi minyoung2 minyoung3 minyoung4 plant)
MAX_KB=2048
DATE="${DATE:-$(date +%F)}"
DO_PUSH="${DO_PUSH:-0}"
# 제외 디렉토리 이름 (데이터/산출물/캐시 — git init 시 제외한 것과 동일 철학)
PRUNE_NAMES=(.git results manifests __pycache__ .venv node_modules .ipynb_checkpoints data archive cache outputs runs sample)

git_id() { git -c user.name="minyoung-observatory" -c user.email="dbssus123@gmail.com" "$@"; }

# 워크스페이스명 → workspaces/<NN_ws> 디렉토리 (번호 prefix 동적 해석)
ws_dir() {
  local ws="$1" hit
  hit=$(find "$HUB/workspaces" -maxdepth 1 -type d -name "*_${ws}" 2>/dev/null | head -1)
  [ -n "$hit" ] && echo "$hit" || echo "$HUB/workspaces/$ws"
}

# prune 식 구성
prune=""
for n in "${PRUNE_NAMES[@]}"; do prune="$prune -name $n -o"; done
prune="${prune% -o}"

cd "$HUB" || exit 1
total=0
for ws in "${WORKSPACES[@]}"; do
  src="$ROOT/$ws"
  [ -d "$src" ] || { echo "[mirror] $ws — 디렉토리 없음, skip"; continue; }
  dst="$(ws_dir "$ws")/notes"
  rm -rf "$dst"; mkdir -p "$dst"
  cnt=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    rel="${f#"$src"/}"
    mkdir -p "$dst/$(dirname "$rel")"
    cp -p "$f" "$dst/$rel" && cnt=$((cnt+1))
  done < <(eval "find \"$src\" -type d \( $prune \) -prune -o -type f -name '*.md' -size -${MAX_KB}k -print" 2>/dev/null)
  echo "[mirror] $ws → ${dst#$HUB/} (${cnt}개)"
  total=$((total+cnt))
done
echo "[mirror] 총 ${total}개 .md 미러"

# commit (workspaces/ 스코프, -A 로 삭제도 반영)
git_id add -A workspaces/
if git_id diff --cached --quiet -- workspaces/; then
  echo "[mirror] 변경 없음 — commit 생략"
else
  git_id commit -q -m "chore: 워크스페이스 note 미러 ${DATE}" -- workspaces/
  echo "[mirror] commit 완료"
  if [ "$DO_PUSH" = "1" ]; then
    if git_id push origin HEAD 2>/dev/null; then echo "[mirror] push 완료"; else echo "[mirror] push 실패(네트워크/인증)"; fi
  fi
fi
