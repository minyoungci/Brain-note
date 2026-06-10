# minyoung2 Codex Entrypoint

This is a clean Codex research/development workspace.

Codex should automatically load:

- `AGENTS.md` for project instructions.
- `.codex/config.toml` because `/home/vlm/minyoung2` is trusted.
- `.codex/hooks.json` and `.codex/hooks/*` for safety hooks.
- `.codex/agents/*.toml` when subagents are explicitly spawned.
- `.agents/skills/*/SKILL.md` when a task matches or a skill is invoked.

Recommended first prompt:

```text
Read AGENTS.md and .codex/README.md. Use the relevant skill or subagent for this task. This is a clean workspace; do not assume existing project code.
```
