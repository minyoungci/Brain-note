# plant — risks

> **목적:** 실패 시나리오 우선 — 본 설계의 약점과 확인 경로 정리  ·  **출처:** /home/vlm/plant SCRATCHPAD·prereg·테스트·git 부재 확인  ·  **갱신:** 2026-06-02

각 항목: **왜 문제 / 어떻게 확인**.

## R1. Converter sparsity → 통계력 부족 (#1 위협, ✅ 사전 인지)

- **왜 문제**: held-out 전환자가 ADNI 130 / A4 98뿐. survival c-index의 paired-bootstrap CI가 넓어 진짜 증분 +0.02 Δc-index를 탐지하지 못할 수 있음. 그러면 ACCEPT 불가 + null도 "true null"인지 "underpowered"인지 구분 불가 → 논문 기여(정직한 null) 자체가 무력화.
- **어떻게 확인**: prereg §7/§8이 명령한 **MDE/power 분석을 deliverable로** 선실행. 주어진 converter n에서 최소 탐지가능 Δc-index를 부트스트랩으로 추정. MDE가 ≫0.02면 null 결과를 "no detectable increment within power X"로만 보고(과대주장 금지).
- 추가 함정: A4 follow-up median 1.5y·이산 visit(m48/m66) → event 적고 censoring 무거움. A4 fold의 effective n이 명목 98보다 작을 수 있음.

## R2. 시간정렬 파싱 오류 (session_id → time) (🟡 부분 검증)

- **왜 문제**: time-interval 컬럼이 manifest에 없어 session_id를 코호트마다 **다른 규칙**으로 파싱: ADNI/AIBL=calendar date, A4=VISCODE 개월, OASIS=days-from-baseline. 규칙 하나라도 틀리면 baseline 선정·time_to_event·censoring이 전부 오염되고, 이는 survival c-index를 silent하게 손상시킴.
- **어떻게 확인**: ✅ `test_build_longitudinal_cases.py`가 raw manifest에서 **독립 시간키로** 160 subject 재유도해 일치 확인(PASS). 단 이는 _스크립트의 session_time_years를 재사용_ → **파서 자체의 cohort별 의미 정확성은 미검증**. 권장: 코호트별 5~10 subject의 session_id↔실제 날짜를 원천 메타데이터(ADNI scandate 등)와 대조하는 외부 ground-truth 스폿체크 [VERIFY].

## R3. Git 부재 → 재현성·이력 추적 위험 (✅ 확인)

- **왜 문제**: `/home/vlm/plant/.git` 없음. label table·prereg·스크립트 변경 이력이 mtime/SCRATCHPAD 수기 기록에만 의존. prereg "endpoint 잠금"은 git 커밋 해시로 고정해야 사후수정 의혹을 차단하는데, 버전관리가 없으면 사전등록의 신뢰성(가장 큰 강점)이 약화됨.
- **어떻게 확인**: `git -C /home/vlm/plant log` 실패 확인됨. 최신성은 SCRATCHPAD `Last updated 2026-06-01` + 파일 mtime(전부 2026-06-01)으로 대체. 권장: prereg를 모델링 전 immutable 스냅샷(해시/타임스탬프)으로 고정.

## R4. EXP01 "deep ≈ volumetry" 교훈이 이 task에 주는 함의 (✅ 핵심 제약)

- **왜 문제**: EXP01(cross-sectional, 더 쉬운 task)에서 deep이 5-ROI 부피에 5/5 fold 동률, pooled만 +0.018 AUROC. progression은 **더 어렵고**(미래 예측·신호 약함) 동시에 **표본 훨씬 작음**(전환자 272). 쉬운 task·큰 표본에서도 능가하지 못한 deep이 어려운 task·작은 표본에서 증분을 보일 base rate는 낮음 → H1 positive의 사전확률이 구조적으로 낮음. Bron 2021도 progression에서 deep 비우위 [VERIFY DOI].
- **어떻게 확인**: 이것이 prereg가 **null을 1순위 결과로 사전 수용**한 이유. 확인 경로는 §R1의 MDE 분석 + mask-only/shuffled 통제로 "신호 없음 vs 검출력 없음"을 분리하는 것. positive가 나오면 오히려 leakage를 의심하고 mask-only·shuffled·subject-disjoint split 재감사를 우선한다.

## R5. (부수) 데이터 함정 — 사전 문서화됨, 회귀 위험

- **왜 문제**: cdr_global이 **string 타입** → to_numeric 누락 시 silent mis-sort/TypeError. sex가 A4·ADNI에서 NaN(clin_sex_raw 사용). APOE·MoCA는 NACC 전용(제외 코호트라 다공변량 불가).
- **어떻게 확인**: build 스크립트는 pd.to_numeric 사용 확인(test에서 cdr 캐스팅). 후속 arm 코드에서도 동일 캐스팅·공변량 가용성의 cohort별 점검을 leakage audit 단계에 포함.
