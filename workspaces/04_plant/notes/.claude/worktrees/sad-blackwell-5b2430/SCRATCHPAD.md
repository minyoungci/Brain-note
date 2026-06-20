# SCRATCHPAD — microbrain (live state)

> 현재 라인의 상태·가설·결과를 여기에 누적. 핸드오프 시 이 파일로 상태 전달. 최신이 위.
> 과거 라인(P0·P2·P3·P4) 기록은 `docs/DECISION_LOG.md`·`docs/ledgers/`·`insight/`에 보존됨.

## 현재: micro 분석 5종 완료 — imaging headroom 측정됨, go-forward 판정 대기 (2026-06-20)
- **방향:** morph-약 regime ADNI prognosis로 피벗(전략 결정). 분석 노트북 5종 `notebook/01–05` 실행·검증 완료.
  종합 리포트 = **`docs/PRIOR_FAILURE_AND_GOFORWARD.md`**.
- **⭐ baseline bar(NB05 개정판, research-critic 반영 — CI 측정):** 정정됨.
  - 구조신호 **실재**(morph가 demographics 위 증분 CI>0: 전환 +0.080 [0.010,0.149] · 미래 cdrsb ΔR² +0.222 [0.150,0.291]).
  - **단 baseline 인지(cdrsb)와 중복** → 공짜 임상정보(DEMO+BASE) 위 morph 증분 CI는 **전 spec 0 포함**(전환 +0.001 [−0.049,0.046] · 회귀 +0.027 [−0.004,0.056]).
  - → **신호는 있으나 임상 baseline 대비 imaging 여유 미확립.** (초판 "포화→NO-GO"는 base_cdrsb 미분리로 부정확, 정정.)
- **권고 go-forward(6.0 게이트 먼저):** **image→fs_vol R²** 측정으로 R2 천장 확인 → R²≈1이면 6.2(ceiling benchmark), R²≪1이면 6.1(SSL→finetune, NO-GO: DEMO+BASE bar를 CI하한>0 + ADNI hold-out + scanner LOCO). 입력 1순위 후보=longitudinal-pair(변화율, R2 우회).
- **데이터 상태:** QC-pass 작업셋 `data/derived/manifest_qc_pass/`(12,978×145, 0 flagged). 누수 dup 2쌍 `dup_group` 플래그(미collapse). 코드 `src/microbrain/{qc_base_tensors,build_qc_pass_manifest}.py`, `notebook/_build.py`.
- **함정 메모:** ADNI `clin_dx_label`은 정적 → 깨끗한 전환라벨은 원본 DXSUM 필요. cdr 요동. site×dx Cramér's V 0.421(R1).
- 다음 즉시(CPU): NB05 회귀 타깃 재정의 + baseline bar 재측정 → imaging arm GO/NO-GO 최종 확정.

## per-cohort bias audit + bias-robust 설계 종합 (2026-06-20)
- **NB06 per-cohort audit**: site 식별 2.6×chance(AJU 0.905 최악·CN 2.3%) but within-site disease 0.775=decidable. 코호트별 결측/품질 프로파일 측정.
- **설계 종합** = `docs/COHORT_AUDIT_AND_BIAS_DESIGN.md` (4-lens 설계 + R1–R4 적대검증 9-agent 워크플로).
  - 프레임: bias 제거 아니라 **비결정화**(입력 cordon + nested-LOCO + 음성통제 + per-cohort gate).
  - per-cohort 결정: ADNI=PRIMARY bracket · NACC=audit-only transport · AJU/KDRC=HARD 격리 · A4=clean-vendor source · OASIS=SSL-pool only · AIBL=보조.
  - **최우선 다음 측정 = GATE-3 `image→fs_vol R²` structure-wise(cortical ROI별·CI)** — 전 프로그램을 천장확정(benchmark) vs micro-signal여지(bounded imaging)로 자동 분기. CPU/소, GPU 약속 전.
  - 정직: 가장 현실적 1차 결과는 음성(ceiling benchmark). last_cdrsb는 autoregressive라 GO 타깃서 제외.

## (과거) 활성 라인 없음 기록
- 2026-06-17: P4 라인 폐기(commit `3941cb7`) + 워크스페이스 클린 리셋. dead-line 문서 삭제(git 복구가능).
- 보존 자산: `RESEARCH_BRIEF.md`(설계 SoT) · `docs/DECISION_LOG.md` · `docs/ledgers/` · `insight/` · `src/microbrain/audit.py`.
- 다음: 새 라인 주제 설정 → 코드 전에 `docs/<phase>_plan.md`로 설계 합의 → 승인 후 착수. 여기에 상태 기록 시작.
