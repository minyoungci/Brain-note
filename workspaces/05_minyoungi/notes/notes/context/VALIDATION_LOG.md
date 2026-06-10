# VALIDATION_LOG

## 2026-05-18 — lightweight reset

### Scope

- Workspace: `/home/vlm/minyoungi`
- Request: 이전 잔재를 모두 제거하고 디렉토리를 가볍게 유지.

### Pre-delete checks

```bash
pwd
git status --short
git branch --show-current
git rev-parse --show-toplevel
find /home/vlm/minyoungi -maxdepth 2 -type l -ls 2>/dev/null | head -50
du -sh /home/vlm/minyoungi/* /home/vlm/minyoungi/.[!.]* 2>/dev/null | sort -h
```

Observed:

- `pwd`: `/home/vlm/minyoungi`
- branch: `main`
- git top-level: `/home/vlm/minyoungi`
- 기존 dirty/untracked: `docs/`, `reports/2026-05-17_v2_amyloid_pet_background_tasks_benchmark.md`
- symlink는 기존 `data_links/` 아래에만 존재.

### Deleted

- `reports/`
- `registry/`
- `scripts/`
- `notebooks/`
- `data/`
- `.env.literature.example`
- 기존 `data_links/*` link objects 및 old README

Deletion inventory:

- `docs/context/RESET_DELETION_INVENTORY_2026-05-18.tsv`
- `docs/context/reset_counts_2026-05-18.json`

### Preserved

- `.git/`
- `.codex/`
- `.gitignore`
- `AGENTS.md`
- `README.md` rewritten as lightweight workspace README
- `docs/context/`
- `data_links/README.md` recreated as empty lightweight link directory marker

### Safety result

- Raw/shared data touched: no.
- `/home/vlm/data/**` deletion: no.
- Symlink target deletion: no; existing symlink objects were unlinked only.
- Git destructive operations: no commit/push/rebase/reset/checkout.

### Post-delete validation

Run after reset:

```bash
git status --short
find /home/vlm/minyoungi -maxdepth 2 -type l -ls 2>/dev/null
find /home/vlm/minyoungi -maxdepth 2 -mindepth 1 -print | sort
du -sh /home/vlm/minyoungi/* /home/vlm/minyoungi/.[!.]* 2>/dev/null | sort -h
```
