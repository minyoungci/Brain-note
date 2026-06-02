# minyoung4 — 휴면(리셋된 모델링 워크스페이스)

_갱신: 2026-06-02 (커밋 6f0754d)_

## 상태: ⚪ 휴면 — 활성 연구 없음

Min 요청으로 기존 연구 디렉토리를 삭제하고 **처음부터 다시 시작할 준비만 된** 워크스페이스다.
특정 연구 방향(VLM/MLLM, JEPA, PET transfer, longitudinal)은 **확정되지 않았고**, 모두 후보일 뿐이다.

## 현재 보유

- `AGENTS.md`, `README.md`, `docs/context/`(RESET_DELETION_INVENTORY.tsv, cleanup_counts.json, WORKSPACE_STATE.md, VALIDATION_LOG.md)
- 코드/실험 산출물 없음. 최근 커밋도 ROI-token workspace 잔재 제거(retire)뿐.

## 재시작 전 최소 정의 (README의 contract)

새 연구는 아래를 먼저 못박은 뒤 시작한다 — 이게 채워지기 전엔 감시할 실험이 없다.

```
Research question / Outcome / Input·exposure / Unit of analysis /
Cohort·filters / Split policy / Leakage risks / Baseline / Expected artifact / Validation
```

## 감시 메모

- **우선순위 낮음.** 새 방향이 확정되고 첫 실험 디렉토리/config가 생기면 이 카드를 findings/risks/sources로 확장한다.
- minyoungi README는 "실험은 minyoung2/minyoung4에서 한다"고 적지만, 현재 minyoung4는 비어 있어
  실질 실험 본진은 **minyoung2**다. minyoung4가 깨어나면 역할 중복을 점검할 것.
- 출처: `/home/vlm/minyoung4/README.md`, `docs/context/WORKSPACE_STATE.md` (@커밋 6f0754d, 2026-06-02 확인).
