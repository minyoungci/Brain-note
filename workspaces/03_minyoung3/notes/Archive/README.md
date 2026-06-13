# Archive — 구 FreeSurfer-percentile ROI-VQA 방향 (2026-05-27 ~ 06-13)

2026-06-13 분리. 이 폴더는 **종료된** 방향의 산출물이다. 종료 근거는 루트
`FAILURE_AND_NOVELTY_ANALYSIS.md` 참조(핵심 negative는 독립 재현됨).

## 종료 사유 (한 줄)
정답 레이블 = threshold(FreeSurfer morphometry) → morphometry가 oracle(AUC→1.0)이고,
grounding GT = FS mask → conform 후 상수 prior가 grounding을 이김. **2단계 circularity로
vision novelty 구조적 불가.**

## 내용물
- `ACCV/` — ACCV 제출 패키지(PAPER_DRAFT 등). C2(grounding)는 circularity로 철회됨.
- `reports/` — 구 실험 리포트 18종(Q-ROUTE/multiview/reliability/ventricle/score-meta/brainage 등).
- `scripts/old_freesurfer_vqa/` — 구 실험 스크립트 255종(run_f04_v6_* audit suite, qroute,
  grounding, brainage, control_circularity.py, resolution_sweep.py, research_audit/ 등).

## 재사용 가능 자산 (루트에 유지, 여기로 옮기지 않음)
- `results/` (75GB): 3D image cache(global64/mtl80/roiunion80), grounding GT 등 — 신규 amyloid
  방향에서 일부 재사용 가능하므로 루트에 보존.
- 데이터: `/home/vlm/data` (read-only) 그대로.

## 주의
- 여기 코드의 상대경로는 루트 기준(`results/...`, `/home/vlm/data/...`)이라, Archive 안에서
  직접 재실행하려면 경로를 루트로 맞춰야 함. 검증 목적의 재현은 이미 완료(로그 참조).
