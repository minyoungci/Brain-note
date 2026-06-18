# AMYLOID LABEL AUDIT (Task3A 선행 작업)

_2026-06-18. 목적: Task3A(within-cohort amyloid positivity)를 agent workflow/baseline에 넣기 전,
코호트별 amyloid label의 **정의·출처·시점정합·leakage 위험**을 확정한다.
이 audit 없이 pooled analysis나 cross-cohort 비교를 하면 안 된다._

기계가독: [`../outputs/endpoint_audit/amyloid_label_audit.csv`](../outputs/endpoint_audit/amyloid_label_audit.csv)
(정량값 = live parquet 실측; 정성값(method/threshold) = `MANIFEST_FINAL_DATA_SPEC.md` 디스크 전수조사 근거, manifest 미인코딩분은 `[VERIFY]`).
연결: [`TASK_CARD.md`](TASK_CARD.md) Task3A/3B, [`CLAIM_SCHEMA.md`](CLAIM_SCHEMA.md), [`BLOCKER_LOG.md`](BLOCKER_LOG.md) B-2.

---

## 1. 코호트별 요약 (Step 2.0 label hardening 반영, 2026-06-18)

label_status는 baseline gating 용도(§Formal Baseline Activation Rule). empirical cutoff = manifest 내
연속값↔이진라벨 분리로 역산(실측). 생성기 = [`../scripts/build_amyloid_label_audit.py`](../scripts/build_amyloid_label_audit.py).

| cohort | label_column | n_total | pos | neg | pos_rate | method | empirical cutoff (실측) | temporal | **label_status** | allowed_run |
|---|---|--:|--:|--:|--:|---|---|---|---|---|
| OASIS | oasis_amyloid_positive | 1,048 | 330 | 718 | 0.315 | centiloid (PIB/AV45) | **clean ~20 CL** (neg_max 19.9 / pos_min 20.2, no overlap) | gap_days (median 0d, **max 729d**) | **LABEL_PARTIAL_TEMPORAL_CHECK_REQUIRED** | FORMAL after temporal-window rule |
| NACC | nacc_amyloid_positive | 515 | 201 | 314 | 0.390 | GAAIN centiloid 0/1 | **overlap** (pos_min 10 < neg_max 17 CL) → 단순 threshold 아님 (4 tracer) | UNKNOWN (no gap col) | **LABEL_UNVERIFIED** | SMOKE_TEST_ONLY |
| KDRC | kdrc_amyloid_visual | 909 | 417 | 492 | 0.459 | visual (SUVR avail) | **heavy overlap** SUVR↔visual → clean cutoff 없음 | UNKNOWN (single session) | **LABEL_UNVERIFIED** | SMOKE_TEST_ONLY |
| AJU | aju_amyloid | 1,286 | 435 | 851 | 0.338 | visual | 연속 anchor 없음 (역산 불가) | PARTIAL (bl/tfu, no scan date) | **LABEL_UNVERIFIED** | SMOKE_TEST_ONLY |
| A4 | a4_amyloid_positive | 1,811 | 1,811 | **0** | 1.000 | florbetapir SUVR+visual | single-class | UNKNOWN | **FORBIDDEN** | NONE |
| ADNI | (부재) | 0 | – | – | – | external UCBERKELEY_AMY | – | N/A | **NA_BLOCKED** (Task3B) | NONE |
| AIBL | (부재) | 0 | – | – | – | external join | – | N/A | **NA_BLOCKED** (Task3B) | NONE |

> 실측 해석: **OASIS만** 이진라벨이 centiloid ≈20 CL로 깔끔히 분리(표준 centiloid cutoff와 일치) → 정의 부분확정.
> NACC는 AMYLOID_STATUS가 centiloid 단순임계가 아님(10–17 CL 중첩, tracer 4종) → 정의 미상.
> KDRC visual은 제공된 SUVR와 정합하지 않음(중첩) → rater 기준 필요. AJU는 연속 anchor 자체가 없음.
> ⇒ 어떤 코호트도 아직 **LABEL_LOCKED 아님**. OASIS만 temporal-window rule 정의 후 (downgrade된) formal 허용.

---

## 2. 핵심 발견 (pooling/transportability를 막는 근거)

1. **Label 정의가 코호트 간 비호환**: AJU·KDRC = PET **visual read**, OASIS·NACC = **centiloid threshold**, A4 = SUVR. 동일 `positive`가 같은 의미라는 보장 없음 → **pooled = Task3B(BLOCKED)**.
2. **임계값이 manifest에 없음**: visual rater 기준·centiloid cutoff 모두 미인코딩(`[VERIFY]`). cross-cohort harmonization 전엔 라벨을 하나로 합치면 안 됨.
3. **Base-rate 상이**: pos_rate 0.315~0.459. 단일 코호트 분류는 OK이나 pooled AUC는 prevalence 차이로 부풀려짐 → cohort별 보고 + prevalence 보정 필수.
4. **Temporal matching 불균일**: OASIS만 `oasis_amyloid_gap_days`로 정량(일부 **max 729d** = MRI↔PET 2년 차이 → window cutoff 필요). AJU/KDRC/NACC는 amyloid scan date 자체가 manifest에 없어 시점 정합 검증 불가 → "baseline에 가깝다" 가정은 `[VERIFY]`.
5. **Scanner 정보 비대칭**: OASIS·A4 model 0%(vendor만), KDRC field_strength 0%. shortcut 점검(V3)을 코호트마다 가용 정보로 조정해야 함.

---

## 2b. Formal Baseline Activation Rule

Task3A baseline results can be interpreted **only** when the cohort label status is one of:
- `LABEL_LOCKED`
- `LABEL_PARTIAL_TEMPORAL_UNKNOWN` (= `LABEL_PARTIAL_TEMPORAL_CHECK_REQUIRED`), **with claim downgraded**

If label status is `LABEL_UNVERIFIED`, only **smoke-test** execution is allowed.
Smoke-test outputs must **not** be used for biomarker ranking, manuscript claims, or agent evaluation.

이 규칙은 코드로 강제된다: [`../scripts/run_task3a_baseline.py`](../scripts/run_task3a_baseline.py) `--mode formal`은
`amyloid_label_audit.csv`의 `label_status`/`allowed_run`을 읽어, 허용 상태가 아니면 **exit code 1로 중단**한다.
(검증: AJU/KDRC formal → ABORT, OASIS smoke → run, leakage check 26 features clean.)

## 2c. Claim Restriction by Label Status

### LABEL_LOCKED
- Allowed: within-cohort internal prediction/association · **L2 internal-only** claim.

### LABEL_PARTIAL_TEMPORAL_UNKNOWN (OASIS 현재)
- Allowed: within-cohort **association** with cohort-specific amyloid label.
- Forbidden: baseline **prediction** · temporal prediction · robust amyloid biomarker claim.
- (이유: label date/temporal window 미확정 → "baseline MRI predicts amyloid"는 temporal-ordering 공격 대상. "MRI ROI features were associated with cohort-specific amyloid positivity labels" 수준만 안전.)

### LABEL_UNVERIFIED (AJU·KDRC·NACC 현재)
- Allowed: pipeline **smoke test only**.
- Forbidden: **all scientific interpretation**.

## 2d. OASIS cutoff hardening (실측 2026-06-18, Step 2.2)
`outputs/task3a_oasis/cutoff_hardening.json` (생성 `scripts/build_oasis_benchmark.py`).
- manifest `oasis_amyloid_positive` = **균일 ~20 CL 이진화**: centiloid≥20 vs label_positive **discordance 0**(global + PIB + AV45 각각 clean gap). 즉 manifest는 uniform 20 CL을 썼고 tracer-specific이 아님.
- OASIS-3 문서의 tracer/protocol-specific cutoff = **16.4–21.9 CL** 범위. 이 구간에 **34건(3.2%)** ambiguous (16.4 적용 시 21건 / 21.9 적용 시 13건 라벨 flip).
- ⇒ label은 "**대략 20 CL로 경험적 일치**"까지만. "canonical OASIS amyloid status"·"universal 20 CL"라 쓰면 안 됨(association-only, mandatory caveat [`CLAIM_SCHEMA.md`]). tracer 매핑은 `[VERIFY OASIS-3 data dictionary]`.
- ⇒ status는 무리하게 LABEL_LOCKED로 올리지 않음 — `LABEL_PARTIAL_TEMPORAL_CHECK_REQUIRED` 유지(association-only로 잠금).

## 3. Label leakage / shortcut 위험 변수 (Task3A predictor에서 제외/통제)

- **직접 라벨**: 해당 코호트 amyloid 컬럼 전부 + 타 코호트 amyloid 컬럼(`*_amyloid_*`,`*_centiloid`,`*_suvr`,`*_tracer`).
- **시점 메타**: `*_amyloid_gap_days`, `*_mmse_gap_days` (스캔-라벨 시차 = 코호트/프로토콜 지문).
- **shortcut**: `acq_scanner*`, `acq_field_strength`, `vox_*`, `consortium` — predictor 금지, V3에서 통제·보고.
- **proxy**: `clin_dx_label`, `clin_mmse`, `cdr_global`, `cdrsb` (질병 중증도 ↔ amyloid 상관). 이미지-단독 모델과 분리.
- **선택 bias**: 코호트별 모집기준(예 A4 = amyloid+ CN)이 positivity와 엮임 → 코호트 내부에서도 해석 주의.

---

## 4. Task3A 활성화 체크리스트 (baseline 실행 전)
- [ ] 각 코호트 amyloid 라벨 **source 문서 확인**([VERIFY] 제거: visual rater 기준 / centiloid cutoff 명문화)
- [ ] class balance 기록(완료: §1)
- [ ] temporal alignment: OASIS gap window 정의, AJU/KDRC/NACC scan-date 확보 가능성 확인
- [ ] site/scanner 가용성에 맞춘 V3 shortcut 점검 설계
- [ ] subject-level split + 중복쌍 collapse(AJU 2쌍)
- [ ] cohort별 분리 보고(pool 금지)

---

## 5. 다음 단계 (gated execution order)
baseline 코드 = [`../scripts/run_task3a_baseline.py`](../scripts/run_task3a_baseline.py) (default `--mode smoke_test`).
feature 위계: ROI-only → +age/sex/ICV → +site/scanner, 모델 ElasticNet·XGBoost, bootstrap stability, leakage/shortcut check.

1. **OASIS first**: temporal-window rule(gap_days cutoff, 예 ±90d) 정의 → `--mode formal` 가능(claim downgraded = association). gap_days sensitivity 동반.
2. **NACC**: AMYLOID_STATUS 원천(SCAN 변수) 정의 확인 전까지 smoke_test only. centiloid 단순임계 아님(실측).
3. **AJU/KDRC**: visual rater 기준·scan date 확정 전까지 smoke_test only.
4. 이후 leakage/confounding/shortcut **verifier 구현** → LangGraph agent.

> ⚠️ 높은 AUC = 성공 아님, **의심 신호**. 먼저 age/severity leakage·site shortcut·label-인접 변수·selection bias를 점검한다. 이걸 검증하는 게 본 연구의 novelty.
> (참고 smoke diagnostic: OASIS ROI-only AUROC≈0.70 — **해석/인용 금지**, 파이프라인 동작 확인용.)

## 6. 검증 로그
- 정량(n/pos/neg/rate/coverage/gap_days) = `pd.read_parquet` 실측(`/tmp/amyloid_label_audit.py`).
- 정성(method/threshold) = `MANIFEST_FINAL_DATA_SPEC.md`(디스크 전수조사) 인용; manifest 미인코딩분 `[VERIFY]`.
- 미검증: 코호트별 정확한 amyloid 임계값/visual rater 프로토콜, AJU/KDRC/NACC scan date 확보 가능성.
