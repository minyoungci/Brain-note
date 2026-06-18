# CLAIM_SCHEMA.md — Claim Levels

_무엇을 주장해도 되는지를 endpoint validity + verifier verdict로 **자동 결정**한다. 저자가 임의로 올릴 수 없다.
근거: [`EVALUATION_PROTOCOL.md`](EVALUATION_PROTOCOL.md), [`VERIFIER_SPEC.md`](VERIFIER_SPEC.md), task 정의 [`TASK_CARD.md`](TASK_CARD.md).
CLAUDE.md "낙관적 추정 금지 · 자기평가 편향 금지"의 운영판._

---

## L0 — Forbidden Claim

A claim is **L0** if the required endpoint is unavailable, invalid, or only proxy-defined.

Examples:
- Claiming MCI-to-AD conversion when diagnosis is subject-level backfilled. *(현 manifest: ADNI MCI→AD sequence 0건)*
- Claiming amyloid PET prediction when amyloid label is missing or single-class. *(ADNI 부재, A4 single-class)*
- Claiming longitudinal progression from cross-sectional diagnosis.
- Claiming AD conversion from CDR change alone. *(Task 4 ≠ Task 2)*

Required action:
- **Do not report as scientific result.** Report only as blocker or failed feasibility check ([`BLOCKER_LOG.md`]).

---

## L1 — Descriptive Association

Allowed when:
- outcome is cross-sectional or proxy-defined
- temporal ordering is weak
- no external validation exists

Allowed wording:
- "associated with"
- "showed a cross-sectional relationship with"
- "may reflect clinical severity"

Forbidden wording:
- "predicts conversion"
- "robust biomarker"
- "disease progression biomarker"
- "causal marker"

---

## L1.5 — Association with Negative Incremental Finding (`L1_ASSOCIATION_WITH_NEGATIVE_INCREMENTAL_FINDING`)

_OASIS Task3A에서 신설(2026-06-18). imaging feature가 association은 보이나 **demographic/confounder baseline(B1)을 못 넘는** 경우 전용._

Allowed when:
- within-cohort association 존재 (cross-sectional, proxy/label-specific)
- 그러나 ROI-only AUROC < covariate-only(age/sex/ICV) AND incremental gain ≈ 0
- site shortcut 없음(B3 ≈ chance), temporal/label 한계 명시

Allowed wording:
- "showed modest within-cohort association but did **not** add incremental value beyond age/sex/ICV"
- "this is why imaging features must be compared against demographic baselines before any biomarker claim"

Forbidden wording:
- "predicts", "biomarker", "useful for amyloid", "robust", "generalizes"

> 이 level이 사실상 OASIS Task3A의 권장 수위. "L2 internal prediction"은 ROI가 covariate를 못 이겼으므로 부적격.

## L2 — Predictive Association

Allowed when:
- valid train/test split exists (subject-level)
- endpoint is well-defined
- leakage verifier passes (V1)
- covariate adjustment is performed (V2)

Allowed wording:
- "predicted the predefined endpoint in internal validation"

Forbidden wording:
- "generalizable"
- "clinically deployable"
- "causal"

---

## L3 — Robust Candidate Biomarker

Allowed when:
- endpoint is valid
- leakage / confounding / site verifier passes (V1·V2·V3)
- bootstrap stability is acceptable (subject-level resample)
- site-held-out or external validation supports the result (LOCO)
- claim is literature-grounded

Allowed wording:
- "candidate biomarker supported by internal and external validation"

Forbidden wording:
- "definitive biomarker"
- "causal biomarker"
- "clinical-grade biomarker"

---

## Task3A — Within-cohort amyloid (전용 문구)

_Task3A는 internal-only이므로 L2가 상한. 아래 문구만 허용._

**Allowed:**
- "FastSurfer-derived ROI features showed within-cohort association with amyloid positivity under the cohort-specific amyloid label definition."
- "The model predicted amyloid positivity in internal validation within [cohort name], after adjustment for age, sex, ICV, and site/scanner when available."

**Forbidden:**
- "The biomarker generalizes across cohorts."
- "The feature is a robust amyloid biomarker."
- "The result is ADNI-anchored or externally validated."
- "The amyloid label is harmonized across cohorts."
- "The model predicts amyloid pathology in a clinically deployable way."

**OASIS label-provenance caveat (mandatory, 실측 2026-06-18):**
- OASIS `oasis_amyloid_positive` = 균일 **~20 CL** 이진화(discordance 0). OASIS-3 문서의 tracer/protocol-specific cutoff(16.4–21.9 CL)와 다르고 **~3.2%가 cutoff-ambiguous** → "canonical OASIS amyloid status"·"universal 20 CL threshold" 주장 금지. 근거 `outputs/task3a_oasis/cutoff_hardening.json`.

---

## claim_level 정의 (모호성 제거, Step 2.3 review에서 확정)
`claim_level` = **그 case에서 가장 강하게 *허용*되는 claim의 level**. 유혹적(tempting)/금지(forbidden) claim의 level이 아니다.
- 예: cross-cohort case에서 "일반화한다"는 **forbidden_claims**에 들어가고, 허용되는 최강 claim은 "within-cohort association"=**L1** → 따라서 claim_level=L1 (L0 아님). (draft L0 오류를 blind 리뷰 2인이 L1로 교정.)

## Level 자동 결정 규칙
- endpoint 자체가 unavailable/invalid/single-class/proxy-as-target → **L0** (verifier 무관).
- WARN(VERIFIER) 1건당 confidence **1단계 강등**.
- external(LOCO) 미수행 → 최대 **L2**.
- baseline(B1/B2, [`EVALUATION_PROTOCOL.md`]) 미초과 → "영상/모델 기여" 계열 최대 **L1**.
- 독립 verifier PASS 로그 없이 "verified/완료" 선언 → **금지**(CLAUDE.md 자기평가 편향).

## 현재 task별 claim 상한 (2026-06-18 audit 기준)
| task | 현재 상한 | 조건 |
|---|---|---|
| Task1 cross-sectional severity | **L2** | subject-level split + covariate adjust 시. longitudinal wording 금지 |
| Task2 MCI→AD conversion | **L0** | per-visit dx 재조인·검증 전까지 |
| Task3A amyloid within-cohort (AJU/KDRC/OASIS/NACC) | **L2 internal only** (상한) | cohort별 분리 보고; "generalizable/robust biomarker" 금지 |
| Task3A-OASIS (실측 2026-06-18) | **L1.5** (negative incremental) | ROI < covariate baseline → "association, no incremental value"로만. 결과·근거: `outputs/task3a_oasis/`, 설계: [`AGENT_BENCHMARK.md`] |
| Task3B amyloid transportability (pooled/ADNI) | **L0** | ADNI join + 라벨 조화 + temporal matching 전까지 |
| Task4 CDR progression proxy | **L1** | "proxy"로만; "AD conversion" 표기 금지 |

## Claim → 근거 추적 (제출 전 자기점검)
```
claim: "<문장>"
level: L0–L3
endpoint_validity: <available | proxy | invalid | single-class>
evidence: <표/그림, ΔAUC+CI, 검정 p>
verifier: V1=PASS V2=PASS V3=PASS (or WARN/FAIL 사유)
caveats: <amyloid label heterogeneity | ADNI external join | Korean conversion 부재 | 횡단 confound>
```
하나라도 비면 강등 또는 삭제.
