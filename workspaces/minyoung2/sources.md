# minyoung2 — sources

> **목적:** EXP01 카드의 근거 원본 문서·코드 자산·데이터 자산 목록  ·  **출처:** workspaces/minyoung2 (READ-ONLY, 수정/실행 안 함)  ·  **갱신:** 2026-06-02 (workspace HEAD bb9b29f)

## 근거 원본 문서 (경로 + 최신 커밋)

| 파일 | 마지막 커밋 | 역할 |
|---|---|---|
| `SCRATCHPAD.md` | 2e98be8 | 현재 연구 상태·가설·라인 흐름(가장 중요) |
| `reports/EXP01_OVERVIEW.md` | 7fcd9cc | 종합 리포트 F1~F10 + master table |
| `docs/context/DECISION_LOG.md` | 77f0e72 | 라인 A→B→EXP01 피벗 결정·NO-GO 기록 |
| `docs/plans/2026-05-31-exp01-shortcut-controlled-representation-eval.md` | 77f0e72 | EXP01 설계 lock(D1/D2/D3, control battery, H1 판정기준) |
| `docs/EXP01_REVIEWER2_CRITIQUE.md` | f1b65d1 | research-critic 적대적 비평(F1/F2/F3 fatal + revision 로드맵) |
| `reports/experiment_ledgers/2026-06-01-exp01-regional-volume-baseline-critical.md` | 46b97c4 | F9 중대 negative(deep≈regional) |
| `reports/experiment_ledgers/2026-06-01-exp01-deep-advantage-probes.md` | 61fc43d | F10 pooled +0.018 |
| `reports/experiment_ledgers/2026-06-01-exp01-img-019-erm-vs-gdro-5seed-qualifies-f8.md` | 7fcd9cc | F8 하향(gDRO cohort-의존) |
| `reports/experiment_ledgers/2026-05-31-exp01-nuisance-001-loco-baseline.md` | (ledger) | nuisance bar 설정 |
| `reports/experiment_ledgers/2026-05-31-exp01-img-003-004-resnet18-positive-transport.md` | (ledger) | 첫 양성 전이 |
| `git log --oneline -30` (HEAD bb9b29f) | — | IMG-001~022 실험 흐름 |

직접 확인: `results/exp01_cdr_multicohort/runs/EXP01-IMG-020/021/022-*` 디렉토리 — 비어 있음(3D CNN 결과 미생성).

## 재사용 가능 코드 자산 (스크립트 + 한 줄 설명)

| 스크립트 | 설명 |
|---|---|
| `scripts/build_exp01_cdr_split.py` | subject-level + LOCO split builder (+ `tests/test_exp01_cdr_split.py` 단위테스트) |
| `scripts/build_exp01_cdr_2p5d_manifest.py` | CDR 2.5D whole-brain coronal slice-bag manifest 생성 |
| `scripts/run_exp01_nuisance_baseline.py` | nuisance-only control battery baseline (F1 bar) |
| `scripts/exp01_incremental_value.py` | 공식 H1: nuisance+image vs nuisance, paired bootstrap ΔAUROC (F3b) |
| `scripts/exp01_regional_volume_baseline.py` | 5-ROI 위축 logistic baseline (F9 핵심) |
| `scripts/exp01_incremental_over_regional.py` | regional 위 image 증분 검정 (F10) |
| `scripts/exp01_mci_boundary.py` | CN(0) vs MCI(0.5) 경계 subgroup 분석 (F10) |
| `scripts/exp01_summary_table.py` | 전 fold 결과 집계 → master_summary.md |
| `scripts/exp01_leaderboard.py` | arm/fold 리더보드 |
| `scripts/train_exp01_3dcnn.py` | full-volume 3D resnet(MONAI, bf16), LOCO, --mem-cap-pct RAM 가드 |
| `scripts/make_cohort_val_fold.py` | cohort-out val fold (OOD-aware selection, IMG-015) |
| `scripts/train_roi2p5d_mil_smoke.py` | ConvNeXt-Tiny gated-attention MIL instance encoder (표준 2.5D 백본) |
| `scripts/run_exp01_img0{04..22}*.sh` | 각 IMG 실험 드라이버 (img022_3dcnn_robust.sh = setsid 분리+RAM 캡 최신) |

## 산출물 데이터 자산

- `/home/vlm/data/preprocessed_official/official_manifest.csv` — 7-cohort T1w/CDR (13,022 sessions / 7,231 subjects)
- `data/derived/exp01_cdr_multicohort/exp01_cdr_cases.csv` — 7,231 subjects (CN 3717 / IMPAIRED 3514)
- `data/derived/exp01_cdr_multicohort/exp01_cdr_loco_{ADNI,A4,OASIS,KDRC,NACC,AIBL}.csv` — LOCO fold 6개
- `results/exp01_cdr_multicohort/analysis/master_summary.md` — 집계 표
