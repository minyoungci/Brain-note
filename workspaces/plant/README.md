# plant — 감시 카드

> **목적:** 단일 baseline T1 스캔으로 미래 CDR 진행을 cross-cohort 예측하는 설계의 현황 요약  ·  **출처:** /home/vlm/plant SCRATCHPAD·prereg·summary.json  ·  **갱신:** 2026-06-02 (SCRATCHPAD mtime 2026-06-01 14:21)

## 주제

**Longitudinal progression**: 단일 baseline T1 스캔 1장으로 미래 CDR 진행을 cross-cohort로 예측. EXP01(minyoung2) LOCO 프로토콜의 시간축 확장. 목표 게재처는 SCI급 저널 / AI top-tier conference. 프레이밍은 advocacy가 아니라 **falsification** — "deep이 부피 baseline을 이긴다"를 가정이 아닌 검정 대상으로 둔다.

## H1 (🟡 잠정 — 검정 대상, 미입증)

> 학습된 baseline-scan 표현이 baseline FreeSurfer regional volumetry + clinical 공변량(age/sex/baseline CDR-SB) 대비 미래 CDR 진행을 **incremental**하게 예측하고, 이 증분이 held-out cohort로 **transport**된다.

- 선행 증거가 H1의 사전확률을 낮춘다: ✅ EXP01에서 deep은 5-ROI 부피 baseline에 5/5 fold 동률(pooled만 +0.018 AUROC). ✅ Bron et al. 2021도 progression task에서 deep이 구조적 feature를 능가하지 못함 [VERIFY DOI 10.1016/j.nicl.2021.102712].
- → **null(증분 없음)도 publishable한 primary outcome**으로 사전 등록됨. 정직한 cautionary extension이 의도된 기여.

## 현재 상태 (설계 단계 — 결과 없음)

- ✅ **데이터 자산 프로파일링 완료**: `official_manifest_full.parquet` (13,022 세션 × 75 컬럼, read-only).
- ✅ **Feasibility 검증 완료** (agent, 2026-06-01): 시간 정렬 가능 코호트만 → ADNI/AIBL/A4/OASIS. NACC(이미지ID·시간정렬 불가)·AJU(CN baseline 없음)·KDRC(단일세션)는 설계상 제외.
- ✅ **Baseline-anchored survival label table 빌드 + 독립 검증 PASS**: `scripts/build_longitudinal_cases.py` + `tests/test_build_longitudinal_cases.py` (160-subject 독립 재유도 일치). 출력 `data/derived/longitudinal_progression/` (cases 2,159행 / sessions 7,178행). 전환자 272명, CN-baseline 1,467명.
- ✅ **Pre-registration 작성** (DRAFT): endpoint·LOCO held-out(ADNI+A4)·5-arm control battery·판정기준·null-is-valid·power threat 잠금.
- ❌ **모델링 결과 없음**: `results/`·`configs/` 비어 있음. Cox baseline("the bar")·deep arm·leakage audit 미실행.

## 다음 게이트

1. LOCO survival split + leakage audit (CPU) — split 분리·shuffled≈0.5 통과 조건.
2. **Volumetry+clinical Cox baseline("the bar")** — fold별 c-index + bootstrap CI. **deep 실행 전 CPU에서 선행**.
3. cohort-ID + shuffled 통제 arm.
4. deep image arm (GPU — **사전 승인 필수**) + 증분 검정.
5. power/MDE 분석 + 종합.

판정(prereg §7): (volumetry+image)−(volumetry) Δc-index의 paired-bootstrap **CI 하한 > 0이 ADNI·A4 두 fold 모두**에서 성립해야 H-incremental ACCEPT. 한 fold라도 0 포함 → null로 보고(+MDE 분석).

## 한 줄 리스크

**통계력**: held-out 전환자 ADNI 130 / A4 98 → CI가 넓어 +0.02 Δc-index를 탐지하지 못할 가능성이 #1 위협. null의 경우 "underpowered" vs "true null" 구분이 MDE 분석에 달림.
