# minyoungi — Literature Workspace

역할: 문헌 검색, PET/MRI background task 정리, paper triage, 연구 노트 전용 workspace.

> **📑 데이터셋·manifest·site-bias 작업 전체 색인(중요도 순): [`docs/INDEX.md`](docs/INDEX.md)** — 최종 manifest, 분석 로그, figure, 빌드 스크립트, 도구를 한곳에서 탐색.

최상위는 의도적으로 작게 유지한다.

```text
AGENTS.md          # agent guardrail
.codex/            # Codex 설정
literature/        # 논문 index, notes, scripts, API example
notes/context/     # workspace cleanup / validation 기록
links/             # 필요 시 데이터 symlink 설명만 보관
```

운영 원칙:

- 논문/문헌 관련 산출물은 `literature/` 아래에만 둔다.
- 실제 API key는 commit하지 않는다. `literature/config/env.literature.example`만 추적한다.
- 공유 데이터 symlink target과 raw/preprocessed data는 commit하지 않는다.
- 실험 코드는 여기 두지 않는다. 실험은 `/home/vlm/minyoung2`, `/home/vlm/minyoung4`에서 한다.
