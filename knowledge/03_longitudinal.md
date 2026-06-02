# 03 · 종단(longitudinal) 진행 예측 설계 (plant)

_plant의 연구 축. EXP01을 시간축으로 확장. 가장 어렵고 표본이 작다._
_출처: plant SCRATCHPAD §4, docs/plans/2026-06-01-...prereg.md. (2026-06-02)_

## 1. 과제 정의

> **단일 baseline scan** 한 장에서 **미래 CDR 진행(progression)**을 cross-cohort로 예측.

- EXP01(cross-sectional: 지금 상태 분류)의 **시간축 확장**(미래 변화 예측).
- **H1**: 학습된 baseline-scan 표현이 baseline FreeSurfer regional volumetry + clinical 공변량 대비
  미래 CDR 진행을 **incremental**하게 예측하고, held-out cohort로 **transport**된다.
- 양쪽 답 모두 출판 가능: positive=더 어려운 시간 task에서 deep이 값을 한다 / negative=EXP01의
  "deep≈volumetry"를 강화하는 cautionary 확장.

## 2. ⚠️ feasibility 제약이 설계를 강제한다 (2026-06-01 agent 검증)

### (a) 시간 정보 부재 → 코호트 선별
time-interval 컬럼이 없어 session_id 파싱으로만 interval 복원:

| cohort | 시간키 | 정렬 가능? |
|---|---|---|
| ADNI | 달력 날짜 | ✅ |
| AIBL | 달력 날짜 | ✅ |
| A4 | VISCODE month | ✅ |
| OASIS | days-from-baseline | ✅ |
| NACC | 이미지 ID | ❌ 시간 아님, 정렬 불가 |
| AJU | V1/V2 | 순서형만, CN baseline 없음 |
| KDRC | 단일 세션 | ❌ 종단 불가 |

→ **DESIGN DECISION: 시간정렬 가능 4코호트(ADNI/AIBL/A4/OASIS)만.** LOCO held-out = ADNI·A4.

### (b) clin_dx_label은 subject-level 상수 → conversion 인코딩 불가
endpoint는 **session-level `cdr_global`/`cdrsb`만** 써야 한다(→ `00_data_manifest.md` §3).

### (c) converter 희소성 (가장 큰 위협)
CN baseline → 이후 CDR≥0.5 전환자 수:

| cohort | converters |
|---|---:|
| ADNI | 130 |
| A4 | 96~98 [VERIFY: §4=96, summary.json=98] |
| OASIS | 30 |
| AIBL | 14 |
| NACC | 16 (정렬 불가라 제외) |
| AJU | 0 |

→ 충분한 양성은 ADNI·A4뿐. **총 ~270~272 converter.** 통계력이 빈약 → MDE(최소검출효과) 분석이 deliverable.

## 3. 왜 H1 positive의 사전확률이 낮은가 (냉정한 시각)

EXP01에서 deep은 **더 쉬운** cross-sectional task에서 **더 큰** 표본으로도 부피 baseline과 동률이었다.
progression은 **더 어렵고** 표본(converter ~270)은 **훨씬 작다**. → null(음성)이 1순위 결과로 사전 수용됨.
prereg가 이를 못박았고, 최대 위협은 converter sparsity로 인한 **통계력 부족**(음성 vs power-부족 구분).

## 4. 설계가 반드시 못박을 것

1. **부피 + clinical baseline**을 깔고 그 위 증분만 주장(EXP01 프로토콜 계승).
2. **부트스트랩 CI / MDE**를 prereg에 명시 — 작은 양성 표본에서 "음성"과 "검출 불가"를 분리.
3. **시간정렬 파서 검증** — session_id 파싱 오류는 라벨 자체를 오염시킴. 외부 ground-truth 스폿체크.
4. **survival/Cox 관점** 고려 — converter 이진분류보다 time-to-event가 희소 양성을 더 잘 쓴다.
