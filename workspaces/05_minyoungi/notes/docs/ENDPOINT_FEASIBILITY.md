# ENDPOINT FEASIBILITY AUDIT v1

_2026-06-18. 목적: planned medical agent task가 **현재 manifest로 실행 가능한지** 판정.
기계가독 표 = [`../outputs/endpoint_audit/endpoint_feasibility_table.csv`](../outputs/endpoint_audit/endpoint_feasibility_table.csv)
(스크립트 `/tmp/endpoint_audit.py`로 live parquet에서 직접 산출). status 기계판 = [`../configs/task_status.yaml`](../configs/task_status.yaml)._

데이터 사실 = [`DATASET_CARD.md`](DATASET_CARD.md), task 정의 = [`TASK_CARD.md`](TASK_CARD.md), blocker 상세 = [`BLOCKER_LOG.md`](BLOCKER_LOG.md).

---

## 1. 결론 요약

| endpoint | 결론 |
|---|---|
| Cross-sectional severity association | **EXECUTABLE** (7/7 코호트) |
| MCI-to-AD conversion | **BLOCKED_RECOVERABLE** (Western, per-visit dx 재조인 필요) / **FORBIDDEN** (Korean) |
| Amyloid PET positivity | **COHORT-DEPENDENT**: AJU·KDRC·OASIS·NACC EXECUTABLE / A4 FORBIDDEN(single-class) / ADNI·AIBL BLOCKED |
| CDR-based progression proxy | **CANDIDATE** (ADNI·A4·OASIS·NACC·AIBL) — AD conversion 아님 |

핵심: 현재 repo의 1차 작업은 biomarker discovery agent 구현이 아니라 **이 feasibility audit 자체**다.

---

## 2. Endpoint feasibility table (실측, 28행)

cohort | endpoint | n_subject | n_visit | n_positive | n_negative | n_transition | status | blocker

| cohort | endpoint | n_subj | n_visit | pos | neg | trans | status | blocker |
|---|---|--:|--:|--:|--:|--:|---|---|
| ADNI | xsec_severity | 1580 | 4742 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx; cross-sectional only |
| ADNI | mci_to_ad_conversion | 594 | 4742 | – | – | **0** | BLOCKED_RECOVERABLE | dx subject-level backfilled; need DXSUM |
| ADNI | amyloid_positivity | 1580 | 4742 | – | – | – | BLOCKED_RECOVERABLE | amyloid absent; need UCBERKELEY_AMY join |
| ADNI | cdr_progression_proxy | 1580 | 4742 | – | – | 339 | CANDIDATE | CDR change proxy; NOT AD conversion |
| NACC | xsec_severity | 1414 | 1866 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx |
| NACC | mci_to_ad_conversion | 309 | 1866 | – | – | **0** | BLOCKED_RECOVERABLE | need per-visit UDS dx |
| NACC | amyloid_positivity | 1414 | 1866 | 201 | 314 | – | **EXECUTABLE_W_CAUTION** | within-cohort (quant) |
| NACC | cdr_progression_proxy | 1414 | 1866 | – | – | 51 | CANDIDATE | proxy only |
| A4 | xsec_severity | 992 | 1811 | – | – | – | EXECUTABLE_W_CAUTION | all CN_preclinical |
| A4 | mci_to_ad_conversion | 0 | 1811 | – | – | 0 | **FORBIDDEN** | no MCI baseline |
| A4 | amyloid_positivity | 992 | 1811 | 1811 | **0** | – | **FORBIDDEN** | single-class outcome |
| A4 | cdr_progression_proxy | 992 | 1811 | – | – | 166 | CANDIDATE | proxy only |
| OASIS | xsec_severity | 718 | 1420 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx |
| OASIS | mci_to_ad_conversion | 108 | 1420 | – | – | 8† | BLOCKED_RECOVERABLE | verify per-visit dx ordering (UDSd1) |
| OASIS | amyloid_positivity | 718 | 1420 | 330 | 718 | – | **EXECUTABLE_W_CAUTION** | within-cohort (quant centiloid) |
| OASIS | cdr_progression_proxy | 718 | 1420 | – | – | 56 | CANDIDATE | proxy only |
| AIBL | xsec_severity | 617 | 987 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx |
| AIBL | mci_to_ad_conversion | 95 | 987 | – | – | **0** | BLOCKED_RECOVERABLE | need per-visit dx |
| AIBL | amyloid_positivity | 617 | 987 | – | – | – | BLOCKED_RECOVERABLE | amyloid absent (raw has PIB/AV45 meta) |
| AIBL | cdr_progression_proxy | 617 | 987 | – | – | 44 | CANDIDATE | proxy only |
| AJU | xsec_severity | 1001 | 1287 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx (aju_dx3 권위) |
| AJU | mci_to_ad_conversion | 752 | 1287 | – | – | 23† | **FORBIDDEN** | insufficient follow-up (max 2 sessions) |
| AJU | amyloid_positivity | 1001 | 1287 | 435 | 851 | – | **EXECUTABLE_W_CAUTION** | within-cohort (visual read) |
| AJU | cdr_progression_proxy | 1001 | 1287 | – | – | **0** | **FORBIDDEN** | no within-subject CDR variation |
| KDRC | xsec_severity | 909 | 909 | – | – | – | EXECUTABLE_W_CAUTION | subject-level dx |
| KDRC | mci_to_ad_conversion | 239 | 909 | – | – | 0 | **FORBIDDEN** | single session (no longitudinal) |
| KDRC | amyloid_positivity | 909 | 909 | 417 | 492 | – | **EXECUTABLE_W_CAUTION** | within-cohort (visual read) |
| KDRC | cdr_progression_proxy | 909 | 909 | – | – | 0 | **FORBIDDEN** | single session |

† n_transition은 `clin_dx_label`을 `session_id` 순으로 정렬한 **휴리스틱**값(OASIS 8·AJU 23). session_id가 진짜 visit-time 순이 아닐 수 있고, AJU는 `aju_dx3`가 권위 dx → **검증 안 된 artifact, 신뢰 금지**. ADNI/NACC/AIBL는 0(subject-level backfill).

---

## 3. 함의
- **MCI-to-AD conversion**은 현재 manifest 어느 코호트에서도 valid 전환을 제공하지 않는다(Western=재조인 필요, Korean=구조적 불가).
- **Amyloid positivity**는 단일 status로 말할 수 없다 — 4개 코호트는 지금 실행 가능, A4는 영구 불가(설계), ADNI/AIBL는 join 후 복구.
- **A4 single-class는 데이터 오류가 아니라 연구설계(amyloid+ CN 모집)** 의 자연스러운 결과 → FORBIDDEN은 정상.
- **CDR proxy**를 만들 수 있으나 conversion으로 부르면 안 된다(Task 4 규칙).

---

## 4. Next steps (우선순위)
1. (본 audit) feasibility table·status·blocker log 확정 — **완료**.
2. Amyloid label audit([`AMYLOID_LABEL_AUDIT.md`]) — **완료** (Task3A 선행).
3. Task3A cohort별 non-agent baseline → leakage/shortcut/confounding verifier 구현 → LangGraph agent (project [`../CLAUDE.md`] §4).
4. External join plan([`BLOCKER_LOG.md`] Plan A/B/C)은 Task2·Task3B 활성화용 — manifest 내부 가능 vs 외부조인 후 가능 구분.

---

## 5. 검증 로그 (generation ≠ verification)
- 모든 카운트 = `pd.read_parquet` 직접 산출(`/tmp/endpoint_audit.py`, 2026-06-18). status는 계산값에서 규칙 파생(하드코딩 아님).
- ⚠️ 미검증: n_transition 휴리스틱(†), 외부조인 가용성, OASIS/NACC raw 접근정책. 이들은 본 audit **범위 밖** → Plan 단계에서 검증.
