# BLOCKER LOG

_endpoint를 막는 blocker와 그 복구(external join) 계획. audit = [`ENDPOINT_FEASIBILITY.md`](ENDPOINT_FEASIBILITY.md),
status 기계판 = [`../configs/task_status.yaml`](../configs/task_status.yaml)._

원칙: **manifest 내부에서 가능한 것**과 **외부 원자료 요청/조인 후 가능한 것**을 엄격히 분리한다.
조인이 "가능할 것이다"라는 낙관은 금지 — 각 plan은 needed keys와 risk를 명시하고, 성공은 별도 검증으로만 확정.

---

## B-1. MCI-to-AD conversion — per-visit diagnosis 부재
- **증상**: `clin_dx_label`이 subject-level backfill(`clin_level=subject_firstnonnull`). 세션 간 변동 ADNI/NACC/A4/AIBL=0. ADNI MCI→AD sequence 0건.
- **영향**: Task 2 전체 L0(forbidden). Korean(KDRC 단일세션·AJU 2세션)은 복구 불가.
- **복구**: Join Plan A.

## B-2. Amyloid positivity — ADNI/AIBL manifest 부재 + pooled 라벨 비호환
- **증상**: ADNI·AIBL amyloid 컬럼 자체가 manifest에 없음. A4는 single-class(전원 positive, 설계상 정상). visual(AJU·KDRC) vs 정량 centiloid(OASIS·NACC·A4) 임계값 비호환.
- **영향**: pooled/ADNI-anchored transportability L0. *(within-cohort AJU·KDRC·OASIS·NACC는 영향 없음 — 지금 실행 가능.)*
- **복구**: Join Plan B (+ 라벨 조화).

## B-3. A4 amyloid single-class — 복구 불가(설계)
- **증상**: `a4_amyloid_positive` n_unique=1(positive 1811/negative 0).
- **판정**: 데이터 오류 아님. A4는 amyloid-positive cognitively-normal을 모집한 연구 → 자연스러운 구조.
- **복구 없음**: A4 단독 amyloid 분류는 FORBIDDEN 영구. (A4 screening 데이터에 접근하면 음성군 확보 가능성 있으나 현 manifest 범위 밖.)

---

## Join Plan A — ADNI DXSUM (per-visit diagnosis)
- **Purpose**: per-visit diagnosis reconstruction → MCI→AD conversion endpoint.
- **Needed keys**: `RID`, `VISCODE`(또는 `VISCODE2`), `EXAMDATE`. manifest 측 `subject_id`(ADNI는 `002_S_0413` 형식)→RID 매핑, `session_id`(날짜)→EXAMDATE 매칭.
- **Risk**: visit code mismatch, duplicate visit, diagnosis rule inconsistency(DXCHANGE vs DXCURREN 정의), MRI 세션과 dx visit의 시점 정렬.
- **확장**: NACC UDS(`NACCALZD`), OASIS `UDSd1`도 동일 패턴(Plan C 참조).
- **Status**: NOT STARTED.

## Join Plan B — ADNI amyloid PET / biomarker table
- **Purpose**: amyloid positivity endpoint (ADNI 추가 + pooled).
- **Needed keys**: `RID`, `VISCODE`/scan date. 원천 = `UCBERKELEY_AMY*`(SUVR/centiloid), threshold(예 centiloid≥20 또는 SUVR cutoff) 정의 필요.
- **Risk**: MRI–PET 시점 불일치, threshold 모호성, missingness, manifest 외부조인 검증(과거 ~1,203 매칭, [[manifest-real-final]]).
- **라벨 조화 선행**: AJU/KDRC visual ↔ OASIS/NACC/A4 centiloid를 공통 positivity 정의로 통일(사전등록).
- **Status**: NOT STARTED.

## Join Plan C — NACC clinical visit data (external validation/보강)
- **Purpose**: visit-level clinical diagnosis/progression 검증, 추가 clinical visit label.
- **Needed keys**: `NACCID`, visit date/number.
- **Risk**: 데이터 접근 정책(요청 절차), variable harmonization, diagnosis 정의 불일치.
- **참고**: NACC는 데이터 요청 절차·multimodal query/MRI preview 자원 제공 → external 후보로 보존. **현 manifest 내 가능분 vs NACC 원자료 요청 후 가능분 구분 필수**.
- **Status**: NOT STARTED.

---

## 복구 후 활성화 게이트 (공통)
어떤 plan이든 성공 선언 전:
1. join key 매칭률·중복·결측 보고(검증 분리 — 자기평가 금지).
2. temporal ordering(visit time) 정합성 확인.
3. baseline predictor ↔ future outcome 분리 확인(V1.4).
4. subject-level split 무결성(V1.3, AJU 중복쌍 collapse).
→ 통과 시 [`configs/task_status.yaml`] status 갱신 + 본 로그에 활성화 일자·검증 결과 append.

| blocker | plan | status | activated_on |
|---|---|---|---|
| B-1 conversion | A (DXSUM) | NOT STARTED | — |
| B-2 amyloid pooled | B (UCBERKELEY) | NOT STARTED | — |
| B-3 A4 single-class | (none) | UNRECOVERABLE | — |
| external validation | C (NACC) | NOT STARTED | — |
