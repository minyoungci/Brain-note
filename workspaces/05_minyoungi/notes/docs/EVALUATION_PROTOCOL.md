# EVALUATION PROTOCOL

_사전등록 평가 규약. task 정의 [`TASK_CARD.md`](TASK_CARD.md), 데이터 [`DATASET_CARD.md`](DATASET_CARD.md), 게이트 [`VERIFIER_SPEC.md`](VERIFIER_SPEC.md)._

원칙: **baseline을 못 넘으면 모델 주장 없음**. 모든 metric은 신뢰구간과 함께, 모든 비교는 사전 지정 통계검정으로.

---

## 1. Baseline 비교군 (위계)

모델은 아래를 **순서대로** 넘어야 한다. 한 단계라도 유의하게 못 넘으면 그 위 주장 금지.

| ID | baseline | 의미 | "넘었다"의 정의 |
|---|---|---|---|
| **B0** | 무작위/다수클래스 | 하한 | AUC>0.5, prevalence 보정 |
| **B1** | covariate-only (`age,sex,APOE,education`) 로지스틱 | 임상 기본정보만 | 이미지/morph 모델이 B1을 유의 초과해야 "영상이 기여" 주장 가능(VERIFIER V2.4) |
| **B2** | morphometry-only (`fs_*`, 특히 해마·내후각·뇌실) 로지스틱/GBM | 정량 부피 | 이미지(딥) 모델이 B2를 넘어야 "raw T1이 morphometry 이상 정보" 주장 가능 |
| **B3** | site/cohort-dummy only (`consortium` one-hot) | **shortcut 상한** | 모델이 B3 수준이면 site만 학습한 것 → shortcut(VERIFIER V3) |
| **B4** | image 모델(`final_tensor_n4`) | 본 모델 | B1·B2 대비 증분으로 평가 |

> B3는 "넘어야 할" baseline이 아니라 **경고선**: B4가 B3와 비슷하면 위험. 코호트별 amyloid 유병률 차이([`DATASET_CARD.md`]§4) 때문에 cohort-dummy만으로도 pooled AUC가 부풀려짐 → B3를 반드시 같이 보고.

---

## 2. Evaluation metric

### Task 1 (amyloid positivity, 이진)
- **Primary**: AUROC (LOCO 평균 + 코호트별).
- **Secondary**: AUPRC(유병률 불균형 대응), balanced accuracy, sensitivity@fixed-specificity(0.90), **calibration**(ECE, calibration plot — transportability에서 핵심).
- 코호트마다 base-rate 다르므로 **prevalence 고정/보정** 후 비교. accuracy 단독 보고 금지.

### Task 2 (MCI→AD 전환, 예후) — *BLOCKER 해소 후에만*
- 전환을 이진으로 정의 시: AUROC + AUPRC.
- 권장: **time-to-conversion 생존분석** — Harrell's C-index, time-dependent AUC, 추적창 명시. censoring 처리 보고.
- ⚠️ BLOCKER([`TASK_CARD.md`] Task2) 미해소 시 어떤 metric도 산출/보고하지 않음.

### 공통
- 모든 지표에 **95% CI** (bootstrap, **subject 단위 resampling** — 세션이 아니라). 
- 점추정만 보고 금지.

---

## 3. Statistical test

| 비교 | 검정 | 비고 |
|---|---|---|
| 두 모델 AUROC(같은 test set) | DeLong test | 상관표본 |
| 모델 vs baseline 증분 | bootstrap ΔAUC 95% CI (subject resample) | CI가 0 불포함 → 유의 |
| 코호트 간 성능차 | 코호트별 CI 겹침 + 층화 분석 | LOCO 매트릭스 |
| effect(회귀계수) 보정 전후 | nested 모델 비교, 부호·유의성 안정성 | 뇌실 보정(VERIFIER V2.2) |
| 다중비교 | 사전 지정 primary 1개 + 나머지 BH-FDR 보정 | p-hacking 방지 |
| 분포 shift | SMD, KS (train vs test covariate) | VERIFIER V2.3 |

- **사전등록**: primary endpoint·primary 비교 1개를 분석 전 고정. 나머지는 exploratory로 명시.
- 가정 명시(CLAUDE.md): DeLong=정규근사, bootstrap=교환가능성(중복쌍 collapse 후), 생존분석=비례위험/censoring 무정보성.

---

## 4. External validation 계획

핵심 과학 질문 = **transportability**(서구↔한국). 평가축:

### Task 1
- **Primary external**: leave-one-cohort-out. 특히 **train = Western(ADNI*/OASIS/NACC/A4) → test = Korean(AJU, KDRC)** 및 역방향.
  - *ADNI amyloid는 manifest 부재 → UCBERKELEY_AMY 외부조인·검증 선행*([`TASK_CARD.md`]).
- 라벨 조화 선행: visual(AJU·KDRC) vs 정량 centiloid(OASIS·NACC·A4) 임계값 통일 사전등록. 미조화 시 pool 금지.
- 보고: 코호트별 AUROC·calibration + V3 site-probe(외부 코호트에서 site 지문 의존 여부).

### Task 2
- ADNI 내부 hold-out(또는 시계열 분할) + NACC/OASIS/AIBL external.
- ⚠️ **Korean external 불가**(KDRC 종단 0, AJU 최대 2세션 — [`DATASET_CARD.md`]§5.2). 이 한계를 결과·초록에 명시. "Korean 전환 일반화" 주장 [`CLAIM_SCHEMA.md`]에서 금지.

### external 공통 규약
- external test는 **한 번만** 평가(모델·하이퍼파라미터 동결 후). 반복 접근으로 과적합 금지.
- external에서 성능 하락은 **결과**이지 실패가 아님 — 정직히 보고(transportability 정량화가 목적).
- 모든 external 실행 전 [`VERIFIER_SPEC.md`] V1·V3 통과 필수.

---

## 5. 보고 체크리스트 (제출 전)
- [ ] B0–B4 baseline 표 + 증분 CI
- [ ] 코호트별 + LOCO 성능 매트릭스, calibration plot
- [ ] V1/V2/V3 검증기 PASS 로그(+ 주입 테스트로 검증기 자체 동작 확인)
- [ ] 뇌실 보정 전/후 effect 안정성(해당 시)
- [ ] covariate-shift(SMD/KS) 표
- [ ] 결측·제외 흐름도(중복쌍 collapse 포함), subject/세션 수 명시
- [ ] 한계: ADNI amyloid 외부조인 의존 / Korean 전환 부재 / visual-vs-quant 라벨
