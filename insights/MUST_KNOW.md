# MUST_KNOW — 횡단 핵심 인지 사항

> **목적:** 5개 연구를 관통하는, 반복 실수를 막는 교훈  ·  **출처:** 각 워크스페이스 SCRATCHPAD/report + 서브에이전트 감사  ·  **갱신:** 2026-06-02

분기마다 재검토한다. 상태 표기는 STYLE.md 규약(✅확정 / ❌반증 / 🟡잠정 / ⚠️주의 / `[VERIFY]`)을 따른다.

## 연구 방향을 좌우하는 사항 (Top 3)

### 1. deep ≈ regional volumetry — 현재 연구 프로그램의 중심 사실
EXP01(minyoung2)에서 deep 2.5D MIL이 5-ROI FreeSurfer 부피 baseline을 5/5 LOCO fold에서
능가하지 못하고 pooled에서만 +0.018 AUROC [+0.011, +0.026]. "deep이 가치를 더한다"는 주장은
현재 근거가 부족하며, 정직한 thesis는 parsimony/cautionary다.
- 함의: plant·minyoung3도 부피 baseline을 반드시 깔아야 하고, 이를 능가하지 못하면 novelty 주장 불가.
- 단, 이는 "deep이 무용하다"가 아니라, 더 어려운 task(progression, plant)나 다른 산출물
  (ROI-evidence 기반 해부학 QA/VQA 생성, minyoung3)에서 비로소 가치를 입증할 수 있다는
  연구 기회의 정의이기도 하다(plant·minyoung3의 존재 근거).

### 2. LOCO transport은 seed 불안정 — 단일 run 주장은 위험
NACC/AIBL 일부 seed에서 held-out 성능 붕괴(ADNI seed2=0.522, OASIS 0.511↔0.810). 원인 후보는
in-dist val 체크포인트 → OOD gap. grad-accum·warmup·group-DRO 모두 보편적 해결에 실패.
- 함의: multi-seed 필수, 코호트별 보고 필수, 단일 fold 성공을 결과로 사용하지 않는다.

### 3. 음성 결과를 출판 가능하게 설계한다
본 프로그램의 1차 기여는 SOTA 성능이 아니라 재사용 가능한 음성-내성 평가 프로토콜이다(EXP01).
통제군(shuffled/nuisance/mask/volumetry)을 사전 등록해 "신호 없음"이 버그가 아닌 결과가 되게 한다.

## 데이터 취급 시 상시 확인 (반복 오류 지점)

- ⚠️ **`cdr_global`은 string** → `pd.to_numeric()` 선행. 누락 시 silent 오정렬/TypeError.
- ⚠️ **single-cohort 함정**: MoCA=NACC only / MMSE=ADNI final 테이블 없음 / sex NaN=A4·ADNI(→`clin_sex_raw`).
  (정정: APOE는 NACC-only 아님 — A4도 `APOEGN` 보유. `knowledge/data/cohorts/`의 코호트별 검증 참조.)
- ⚠️ **ROI는 fail-closed 잠정**(`roi_final_ready` 전부 False). ROI 기반 정량 결론은 확정이 아닌 후보.
- ⚠️ **종단 시간정보는 session_id 파싱으로만** 존재. NACC 정렬 불가, KDRC 단일세션, AJU CN 없음.
- ⚠️ **데이터 의심을 존중한다**: "39% 결측"이 실제로는 경로 정규화 버그였던 전례가 있다. 생성과 검증은
  분리된 단계이며, 노트북 구조가 맞아도 실행이 깨질 수 있다.

## 운영·인프라 (비-과학적 실패 요인)

- ⚠️ **RAM 1TB 절대 상한.** 초과 시 SSH 세션까지 종료된다. minyoung2가 disconnect 생존(setsid 분리)
  + RAM 90% 앱레벨 캡을 도입한 것은 학습이 SIGHUP/메모리로 종료된 이력의 방증. 대형 run 전 `/sysmon` 확인.
- bf16 필수, fp16 금지(B200).
- ⚠️ **git 안전망 부재**: minyoung3·plant에 `.git` 없음 → 대규모 삭제가 비가역. init 권장.
- `/home/vlm/data`는 read-only canonical. 쓰기 금지.

## 연구 계보 (요약)

minyoung2(EXP01 cross-sectional 프로토콜·성숙)가 척추이며, plant(종단 확장)·minyoung3(ROI-evidence
기반 해부학 QA/VQA 생성)·minyoung4(full_n4 nuisance-aware 3D domain-adversarial 표현학습)가 각각
시간축·데이터 생성·표현학습 축으로 확장한다. minyoungi가 데이터·문헌·ROI QC·figure를 공급한다.
(2.5D MAE SSL 라인 폐기, minyoung4 재가동 — 모두 2026-06-03. minyoung2·3·4는 N4 보정 manifest 공유.)

## 미해결 항목 (추적 대상 `[VERIFY]`)

- minyoung2: 3D CNN IMG-020/022 결과 미생성(run 디렉토리 빔), F10 +0.018의 pooled exchangeability 가정,
  equivalence test(TOST) 미구현 → "음성"과 "검정력 부족" 미분리.
- plant: converter 수치 불일치(A4 96 vs 98), 시간 파서 외부 검증 미수행.
- minyoung3: 생성 QA의 외부 anchor(MTA·progression·within-cohort) 부합 미검증, ROI evidence hippo/MTL 약(R²≈0.19), git 부재.
- minyoungi: ROI BLOCKED_PROVISIONAL, `cdrsb` 실값/placeholder 여부 미해결, experiments/ GPU 산출물과
  minyoung2/4 본진 간 역할 경계 모호.
