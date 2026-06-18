# TASK_CARD.md — Medical Biomarker Agent Tasks

_endpoint-first / claim-safety-first. 모든 수치는 manifest live parquet 실측(2026-06-18,
`outputs/endpoint_audit/endpoint_feasibility_table.csv`). 데이터 사실 = [`DATASET_CARD.md`](DATASET_CARD.md),
검증 게이트 = [`VERIFIER_SPEC.md`](VERIFIER_SPEC.md), 주장 수위 = [`CLAIM_SCHEMA.md`](CLAIM_SCHEMA.md),
가용성 audit = [`ENDPOINT_FEASIBILITY.md`](ENDPOINT_FEASIBILITY.md)._

> ⚠️ 이전 버전은 task를 "Task1=amyloid / Task2=conversion"으로 **primary 고정**했으나, audit 결과
> 둘 다 현재 manifest로는 (전부 또는 일부) 실행 불가. 따라서 task를 **3-status 체계**로 재정의한다.

---

## Task Status Definition

| status | 의미 |
|---|---|
| **EXECUTABLE** | 현재 manifest + 보유 feature만으로 실행 가능 (cross-sectional). |
| **BLOCKED_RECOVERABLE** | 현재 manifest로는 불가하나, 외부 테이블 조인/per-visit label 재구성으로 복구 가능. |
| **FORBIDDEN** | 현재 데이터 구조에서는 해당 claim을 만들면 안 됨(복구 불가 또는 단일클래스). |
| **CANDIDATE** | proxy로는 실행 가능하나, 본래 endpoint와 동일시하면 안 됨. |

기계가독 버전: [`configs/task_status.yaml`](../configs/task_status.yaml). 각 BLOCKER 상세: [`BLOCKER_LOG.md`](BLOCKER_LOG.md).

---

## Task 1: Cross-sectional Clinical Severity Association

**Status: EXECUTABLE_WITH_CAUTION** (7/7 코호트, n=13,022 세션)

Goal: FastSurfer-derived MRI ROI features와 clinical severity marker 사이의 횡단 association 분석.

Candidate outcomes:
- `cdr_global`, `cdrsb` (visit-level이나 본 task에서는 횡단으로만 사용)
- baseline clinical diagnosis — **subject-level label로만** 사용

Allowed claim:
- MRI ROI features are associated with cross-sectional clinical severity markers.
- MRI ROI features show association with baseline diagnosis under subject-level analysis.

Forbidden claim:
- MRI ROI features predict MCI-to-AD conversion.
- MRI ROI features predict future AD onset.
- The model captures longitudinal disease progression.

Required verifiers ([`VERIFIER_SPEC.md`]):
- subject-level split verifier (V1.3)
- visit leakage verifier (V1.3 — 같은 subject 다른 visit이 train/test 분산 금지)
- age/sex/ICV(=`fs_MaskVol` proxy)/site adjustment verifier (V2.1–V2.3)
- repeated subject / 중복쌍 verifier (V1.3 — AJU cross-subject 2쌍 collapse)
- claim calibration verifier ([`CLAIM_SCHEMA.md`])

---

## Task 2: MCI-to-AD Conversion Prediction

**Status: BLOCKED_RECOVERABLE** (Western 코호트) / **FORBIDDEN** (Korean 코호트)

Current blocker (실측):
- `clin_dx_label` is subject-level backfilled (`clin_level=subject_firstnonnull`) and does **not** vary across visits. Within-subject dx variation: ADNI 0 / NACC 0 / A4 0 / AIBL 0. ADNI MCI→AD sequence = **0** from manifest.
- ⇒ 현재 manifest는 valid per-visit diagnostic transition을 담고 있지 않다.
- Korean: KDRC 단일세션(전환 정의 불가, FORBIDDEN), AJU 최대 2세션·sparse(FORBIDDEN). → **한국 코호트 전환은 복구 불가**.
- (참고: clin_dx_label 순서 휴리스틱으로 OASIS 8·AJU 23건이 잡히나, session_id 시간순·AJU는 `aju_dx3`가 권위라 **검증 안 된 artifact** — 신뢰 금지.)

Required data before activation (Western, [`BLOCKER_LOG.md`] Join Plan A):
- ADNI `DXSUM`(또는 동등 per-visit diagnosis table), NACC UDS, OASIS `UDSd1`
- visit date 또는 visit code, baseline MCI 정의, follow-up AD/dementia 전환 정의, censoring rule, 최소 추적기간

Activation criteria:
1. ≥1 코호트가 valid MCI→AD transition sequence 보유
2. same-subject 종단 레코드가 visit time으로 정확히 정렬됨
3. baseline predictor가 future outcome과 분리됨
4. train/test split이 subject-level

Allowed claim **after activation only**:
- The model predicts MCI-to-AD conversion under a predefined longitudinal endpoint.

Forbidden claim **before activation**:
- 어떤 conversion / progression-to-AD / future dementia 예측 주장도 금지.

**Current claim level: L0 — forbidden until blocker resolved.**

---

## Task 3: Amyloid PET Positivity Prediction

**Overall status: COHORT-DEPENDENT** → 혼란 방지를 위해 **반드시 3A/3B로 분리**. label audit = [`AMYLOID_LABEL_AUDIT.md`](AMYLOID_LABEL_AUDIT.md).

> 전체를 BLOCKED로 내리면 실행 가능한 데이터를 버리고, 전체를 EXECUTABLE로 두면 "코호트 내부 분류를 robust amyloid biomarker로 과대주장"하는 위험. 분리가 균형점.

### Task 3A — Within-cohort amyloid positivity
**Status: EXECUTABLE_WITH_CAUTION** · Cohorts: AJU·KDRC·OASIS·NACC · **Claim ceiling: L2 internal predictive association**

| 코호트 | label | pos | neg | pos_rate | method |
|---|---|--:|--:|--:|---|
| AJU | aju_amyloid | 435 | 851 | 0.338 | PET visual |
| KDRC | kdrc_amyloid_visual | 417 | 492 | 0.459 | PET visual |
| OASIS | oasis_amyloid_positive | 330 | 718 | 0.315 | PET centiloid |
| NACC | nacc_amyloid_positive | 201 | 314 | 0.390 | PET centiloid |

- **위치 규정**: 논문 main claim이 아니라 **agent 개발용 executable benchmark + verifier benchmark**. (label 정의 비호환·shortcut 위험·external 부재 → §AMYLOID_LABEL_AUDIT.)
- Allowed: FastSurfer ROI + 임상변수로 **각 코호트 내부** amyloid positivity association/prediction. age/sex/ICV/site 보정, subject-level split, **코호트별 분리 보고**.
- Forbidden: 결과를 ADNI까지 일반화 / cross-cohort transportability 검증됐다 / visual·centiloid·CSF·cohort-specific 정의를 동일 label로 취급 / within-cohort만으로 robust amyloid biomarker 주장.
- Required checks: class_balance · amyloid_label_source([VERIFY] 제거) · temporal_alignment(OASIS gap_days max 729d) · age/sex/ICV/site adjust · subject-split(+AJU 중복쌍 collapse) · cohort-specific report.
- A4: **FORBIDDEN**(single-class, 전원 amyloid+ — 연구설계상 정상).

### Task 3B — Cross-cohort / ADNI-anchored transportability
**Status: BLOCKED_RECOVERABLE** · **Claim ceiling before activation: L0**

- Blocked reason: ADNI amyloid label 부재 · label harmonization 미완 · visual↔centiloid 매핑 미검증 · temporal matching 미검증.
- Required before activation: ADNI amyloid external join(UCBERKELEY_AMY) · label 정의 조화 · MRI–PET temporal window 정의 · cross-cohort split protocol. ([`BLOCKER_LOG.md`] Join Plan B)
- Forbidden before activation: "MRI biomarkers predict amyloid positivity"(무한정 일반화) · "Agent discovers amyloid biomarkers" · A4 기반 분류 성능.

**Current claim level: 3A = L2 internal only (상한) / 3B = L0 until joined & validated.**

#### Step 2.2 — OASIS Verification Benchmark (실측 2026-06-18)
OASIS만 formal association으로 실행([`../configs/task3a_oasis_temporal.yaml`], gate 통과). 결과: **roi_only AUROC 0.658 < covariate-only(age/sex/ICV) 0.684, incremental ≈ 0 (모든 window), site shortcut 없음(0.497)** → ROI는 demographic baseline 위 추가가치 없음. 권장 claim = **`L1_ASSOCIATION_WITH_NEGATIVE_INCREMENTAL_FINDING`**([`CLAIM_SCHEMA.md`]). 이 결과는 성능이 아니라 **agent claim-safety benchmark**로 사용 → [`AGENT_BENCHMARK.md`](AGENT_BENCHMARK.md) (claim-trap cases + verifier scorecard). AJU/KDRC/NACC = smoke-only 유지(label lock 전), A4 = forbidden.

---

## Task 4: CDR-based Clinical Progression Proxy

**Status: CANDIDATE** (longitudinal CDR 변동 보유 코호트: ADNI 339 · A4 166 · OASIS 56 · NACC 51 · AIBL 44 subjects)

Goal: `cdr_global`/`cdrsb`의 종단 변화를 clinical worsening의 **proxy endpoint**로 사용.

Candidate endpoint:
- predefined follow-up 내 CDR-SB 증가 / `cdr_global` 범주 전이 / CDR-SB slope

Allowed claim:
- MRI ROI features are associated with **CDR-based clinical worsening proxy**.

Forbidden claim:
- CDR proxy **equals** AD conversion.
- CDR progression is equivalent to amyloid or tau pathology progression.
- CDR proxy proves disease-modifying biomarker validity.

> 🔴 **가장 중요한 규칙**: CDR로 만든 endpoint는 "clinical progression proxy"이지 "MCI-to-AD conversion"이 아니다. 둘을 섞으면 논문 전체가 무너진다. Task 4 결과는 절대 Task 2 라벨로 표기 금지.

Required verifiers:
- minimum follow-up verifier
- baseline-only predictor verifier (V1.4 temporal)
- future information leakage verifier (V1.4 — outcome 정의에 쓴 CDR 추적값은 predictor 금지)
- repeated-measure handling verifier
- claim calibration verifier
- (FORBIDDEN: AJU·KDRC — CDR 변동 0/단일세션)

---

## 공통 규약
- 모든 task는 사전등록 후 분석([`EVALUATION_PROTOCOL.md`]). forbidden feature는 allow-list로 코드 강제(V1.1).
- status는 audit 산출물에서 파생([`configs/task_status.yaml`]); 임의 승격 금지.
- 현재 repo 우선순위는 biomarker discovery agent가 아니라 **endpoint feasibility audit**(project [`../CLAUDE.md`] §4).
