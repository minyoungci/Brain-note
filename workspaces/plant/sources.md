# plant — sources

_갱신: 2026-06-02 · 읽은 날짜: 2026-06-02 · git 부재 → mtime 기준_

## 1. 1차 근거 파일 (경로 | mtime | 읽음)

| 경로 | mtime | 읽은날 |
|---|---|---|
| /home/vlm/plant/note/SCRATCHPAD.md | 2026-06-01 14:21 | 2026-06-02 |
| /home/vlm/plant/docs/plans/2026-06-01-longitudinal-incremental-transport-prereg.md | 2026-06-01 14:21 | 2026-06-02 |
| /home/vlm/plant/note/daily/2026-06-01.md | 2026-06-01 14:16 | 2026-06-02 |
| /home/vlm/plant/CLAUDE.md | 2026-06-01 13:10 | 2026-06-02 |
| /home/vlm/plant/scripts/build_longitudinal_cases.py | 2026-06-01 14:19 | 2026-06-02 (부분) |
| /home/vlm/plant/tests/test_build_longitudinal_cases.py | 2026-06-01 14:20 | 2026-06-02 |
| /home/vlm/plant/data/derived/longitudinal_progression/longitudinal_summary.json | 2026-06-01 14:20 | 2026-06-02 |
| /home/vlm/plant/data/derived/longitudinal_progression/longitudinal_cases.csv | 2026-06-01 14:20 | 2026-06-02 (헤더+표본) |
| /home/vlm/plant/data/derived/longitudinal_progression/longitudinal_sessions.csv | 2026-06-01 14:20 | 2026-06-02 (행수만) |

## 2. 데이터 자산 (read-only canonical)
- /home/vlm/data/preprocessed_official/official_manifest_full.parquet | 2026-06-01 12:11 | 13,022 세션 × 75 컬럼, join key tag=consortium_subject_session.
- Dict: official_manifest_full.README.md (SCRATCHPAD 참조, 미직접확인 [VERIFY]).
- baseline tensor/mask 경로: /home/vlm/data/preprocessed_official/v2/<COHORT>/subjects/.../final_tensor/ (cases.csv에 절대경로 기재).

## 3. 워크스페이스 구조 사실 (확인됨)
- `configs/` 비어 있음, `results/` 비어 있음 → 모델링 미실행.
- `scripts/`: build_longitudinal_cases.py 1개만. `tests/`: test 1개만.
- `.git` 없음 → 버전관리 부재(risks R3).

## 4. 재사용 예정 코드 자산 (SCRATCHPAD §3 — 본 task에서 미직접확인, 경로만 인용)
### minyoung2 (EXP01) — [VERIFY 경로 존재]
- build_exp01_cdr_split.py — subject-level + LOCO split (tested). longitudinal split 토대로 적응.
- run_exp01_nuisance_baseline.py — "the bar" baseline 패턴.
- exp01_regional_volume_baseline.py — F9 5-ROI 부피 baseline (deep이 이겨야 할 대상).
- exp01_incremental_value.py — paired bootstrap ΔAUROC → Δc-index로 변환 필요.
- train_roi2p5d_mil_smoke.py — 2.5D MIL trainer (deep arm 후보).
- train_exp01_3dcnn.py — 3D CNN (full-res deep arm 후보).
- 데이터: minyoung2/data/derived/exp01_cdr_multicohort/.

### minyoung3 (F04) — [VERIFY 경로 존재]
- train_f04_roi_evidence_cached.py, ROI slab cache builders.
- audit_*_leakage.py — leakage audit 게이트 재사용.
- MAE DDP trainer (스케일 미검증).
- 데이터셋: minyoung3/results/f04_roi_evidence_encoder/20260531_235859_roi_evidence_dataset/
  (18,815 세션 / 56,445 slab / 10,564 longitudinal pair — 단 consecutive-visit이라 baseline-anchored 재빌드 필요).

## 5. 외부 문헌 (전부 [VERIFY] — 본 task에서 DOI 미검증)
- Bron et al. 2021, NeuroImage:Clinical — deep CNN이 MCI→AD conversion에서 구조적 feature 비우위. [VERIFY DOI 10.1016/j.nicl.2021.102712]
- Li/Habes/Wolk/Fan 2019, Alzheimer's & Dementia. [VERIFY]
- TRIPOD 2015 (예측모델 보고 가이드). [VERIFY]
- 출처: SCRATCHPAD §4b literature-scout(2026-06-01). deep-research 웹워크플로우는 실패(StructuredOutput 비호환, ~1.36M 토큰 낭비, 재시도 안 함).

## 6. 미확인/주의
- session_time_years 파서의 cohort별 의미 정확성: 외부 ground-truth 대조 미수행 (risks R2).
- "A4 96/total 270"(SCRATCHPAD §4) vs "A4 98/total 272"(summary.json·prereg) 불일치 — 후자가 산출물 기준 (findings §4).
