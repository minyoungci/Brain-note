# CLAUDE.md — Medical Biomarker Agent Research

이 디렉토리는 FastSurfer 기반 MRI 정량 지표와 임상/바이오마커 테이블을 활용하여
검증 가능한 medical biomarker discovery agent를 개발하기 위한 연구 공간이다.

최상위 CLAUDE.md의 공통 규칙을 항상 따른다. 이 파일은 해당 규칙을 대체하지 않고,
medical agent 연구에 필요한 세부 규칙만 추가한다.

---

## 1. 연구 목적

이 프로젝트의 목표는 단순한 medical chatbot이나 일반적인 LangGraph demo가 아니다.

목표는 다음과 같다.

FastSurfer-derived MRI quantitative features, clinical variables, biomarker variables,
site/scanner metadata를 이용하여 Alzheimer’s disease 관련 biomarker 후보를 찾되,
agent가 leakage, confounding, site/scanner shortcut, unsupported scientific claim을 자동으로 검증하고
근거 기반 biomarker claim을 생성하는 시스템을 개발한다.

핵심 연구 질문:

- Agent가 biomedical tabular data에서 biomarker discovery workflow를 일관되게 수행할 수 있는가?
- Agent가 leakage, confounding, shortcut, overclaim을 기존 generic LLM agent보다 더 잘 탐지할 수 있는가?
- Agent가 생성한 biomarker claim이 evidence graph와 verifier 결과로 추적 가능한가?
- Agent 실행 trajectory를 valid/invalid analysis data로 축적하여 agent learning에 사용할 수 있는가?

---

## 2. 하지 말아야 할 연구 방향

다음 방향으로 흐르면 안 된다.

- “LangGraph로 medical agent를 만들었다” 수준의 단순 구현
- LLM에게 CSV를 던지고 biomarker를 찾아달라고 하는 방식
- AUC만 높이는 모델 개발
- SHAP 상위 feature를 곧바로 biomarker라고 주장하는 방식
- external validation 없이 robust biomarker라고 표현하는 방식
- clinical label과 너무 가까운 변수를 predictor로 사용해 성능을 높이는 방식
- site/scanner shortcut을 확인하지 않고 imaging biomarker라고 주장하는 방식
- p-value 또는 feature importance만으로 biological relevance를 주장하는 방식
- LLM이 직접 통계량, p-value, confidence interval, AUC를 계산하게 하는 방식

LLM은 분석 계획, 도구 선택, 결과 해석, claim calibration을 담당한다.
수치 계산은 반드시 Python/R/statistical tool로 수행한다.

---

## 3. 데이터 사용 규칙

데이터 로딩은 최상위 CLAUDE.md의 manifest 규칙을 따른다.

반드시 아래 manifest를 통해 데이터를 참조한다.

- `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`
- `/home/vlm/data/preprocessed_official/korean_multimodal_manifest.csv`

디렉토리 glob, hard-coded image path, 임의 subject list 생성은 금지한다.

이 프로젝트에서는 특히 다음 정보를 명시적으로 확인한다.

- subject ID
- visit ID 또는 visit date
- diagnosis 시점
- outcome 정의 시점
- MRI acquisition 시점
- FastSurfer output version
- site
- scanner
- age
- sex
- ICV
- cognitive score
- PET/CSF/plasma biomarker
- APOE
- train/validation/test split 기준

subject-level split과 visit-level split을 혼동하지 않는다.
longitudinal data에서는 같은 subject가 train/test에 동시에 들어가지 않도록 검증한다.

---

## 4. 현재 우선 연구 task

초기 task는 하나로 고정한다.

Primary Task v0:

FastSurfer-derived MRI ROI features를 이용하여 amyloid PET positivity와 관련된
candidate biomarker를 찾는 verification-aware agent workflow를 구축한다.

권장 설정:

- Outcome: amyloid PET positivity
- Primary predictors: FastSurfer ROI volume/thickness features
- Mandatory covariates: age, sex, ICV, site/scanner
- Optional predictors: clinical variables, APOE, CSF/plasma biomarkers
- Forbidden or high-risk predictors: outcome 이후 측정된 변수, diagnosis-derived 변수, amyloid label과 직접적으로 중복되는 변수

Task 확장은 baseline workflow와 verifier가 통과한 뒤에만 진행한다.

후보 확장 task:

- MCI-to-AD conversion prediction
- cognitive decline slope prediction
- multimodal biomarker discovery
- external cohort validation
- longitudinal biomarker stability analysis

---

## 5. Feature 사용 정책

모든 feature는 아래 유형 중 하나로 분류한다.

- outcome
- predictor
- covariate
- confounder
- metadata
- leakage-risk variable
- forbidden variable
- unknown

분류가 불명확한 column은 임의로 predictor에 넣지 않는다.
`docs/DATASET_CARD.md` 또는 schema audit 결과에 unknown으로 기록하고,
분석에서 제외하거나 사용자 확인이 필요하다고 표시한다.

특히 다음 변수는 주의한다.

- diagnosis
- future diagnosis
- conversion label
- post-baseline cognitive score
- PET-derived label과 직접 연결된 SUVR 또는 threshold variable
- CSF Aβ/tau 변수
- site/scanner/acquisition protocol
- preprocessing-derived QC variable

CSF/PET/plasma biomarker는 task 목적에 따라 predictor가 될 수도 있고
label-proximal leakage variable이 될 수도 있다.
무조건 사용하는 것이 아니라 task card에서 허용 여부를 먼저 확인한다.

---

## 6. Baseline-first 원칙

Agent 구현 전에 반드시 non-agent baseline을 만든다.

최소 baseline:

- Logistic regression
- ElasticNet logistic regression
- Random forest 또는 XGBoost
- covariate-adjusted model
- site-held-out validation
- bootstrap feature stability

Agent가 baseline보다 반드시 AUC가 높아야 하는 것은 아니다.
이 연구의 핵심은 성능 향상만이 아니라 잘못된 biomarker claim을 줄이는 것이다.

Baseline 결과 없이 agent report를 생성하지 않는다.

---

## 7. Agent workflow

LangGraph는 agent orchestration 용도로 사용한다.
LangGraph 자체가 연구 novelty가 아니다.

기본 workflow:

1. Schema Agent
   - column list 확인
   - feature type 후보 분류
   - outcome/covariate/leakage-risk variable 후보 제시

2. Data QC Agent
   - row count 확인
   - subject count 확인
   - missingness 확인
   - outlier 확인
   - site/scanner distribution 확인
   - class imbalance 확인

3. Cohort Agent
   - inclusion/exclusion criteria 생성
   - baseline visit 정의
   - subject-level split 생성
   - site-held-out split 가능성 확인

4. Modeling Agent
   - baseline model 실행
   - covariate-adjusted model 실행
   - bootstrap stability 분석
   - feature importance/effect size 산출

5. Verification Agent
   - leakage check
   - confounding check
   - site/scanner shortcut check
   - split validity check
   - claim validity check

6. Literature Agent
   - candidate biomarker와 기존 문헌 연결
   - claim을 지지/반박/불충분으로 분류
   - citation hallucination을 방지하기 위해 실제 근거 여부 확인

7. Claim Agent
   - biomarker ranking 생성
   - evidence graph 생성
   - confidence level 부여
   - unsupported claim 제거 또는 downgrade

8. Critic Agent
   - 연구 설계 약점 비판
   - reviewer 관점의 rejection risk 작성
   - 다음 실험 제안

---

## 8. Verifier 규칙

이 프로젝트의 핵심 technical novelty는 verifier다.
아래 verifier를 우선 구현한다.

### Leakage Verifier

반드시 확인한다.

- 동일 subject가 train/test에 동시에 존재하는가?
- baseline prediction에 future visit 변수가 들어갔는가?
- outcome 생성에 사용된 변수가 predictor에 들어갔는가?
- diagnosis-derived variable이 predictor에 들어갔는가?
- preprocessing 또는 QC label이 disease label과 비정상적으로 연결되어 있는가?

### Confounding Verifier

반드시 확인한다.

- age 보정 여부
- sex 보정 여부
- ICV 보정 여부
- site/scanner 보정 여부
- education 또는 cognitive reserve 관련 변수 필요 여부
- ROI volume이 ICV 보정 없이 biomarker로 해석되었는지 여부

### Shortcut Verifier

반드시 확인한다.

- selected biomarker가 disease label보다 site/scanner를 더 잘 예측하는가?
- random split 성능과 site-held-out 성능 차이가 큰가?
- 특정 site에서만 feature importance가 유지되는가?
- scanner/protocol별 feature distribution shift가 존재하는가?

### Stability Verifier

반드시 확인한다.

- bootstrap selection frequency
- fold-wise feature ranking stability
- model family별 biomarker ranking consistency
- covariate adjustment 전후 ranking 변화

### Claim Verifier

반드시 확인한다.

- external validation 없이 robust/generalizable이라고 표현했는가?
- association을 causation처럼 표현했는가?
- SHAP/feature importance를 biological mechanism으로 과대해석했는가?
- literature evidence가 실제 claim을 지지하는가?
- claim confidence가 evidence level에 비해 과도한가?

---

## 9. Evidence graph 출력 형식

모든 biomarker claim은 아래 정보를 포함해야 한다.

- claim_id
- biomarker_name
- feature_source
- cohort_definition
- outcome
- model
- covariates
- split_strategy
- performance
- effect_size_or_importance
- stability_result
- leakage_verifier_result
- confounding_verifier_result
- shortcut_verifier_result
- literature_support
- confidence_level
- limitations
- allowed_claim_sentence
- forbidden_overclaim_sentence

예시:

Claim:
Left hippocampal volume is associated with amyloid PET positivity.

Allowed:
Left hippocampal volume showed a reproducible association with amyloid PET positivity
after adjustment for age, sex, ICV, and site in the current cohort.

Forbidden:
Left hippocampal volume is a robust causal biomarker of amyloid pathology.

---

## 10. 평가 지표

Agent 평가는 AUC만으로 하지 않는다.

Prediction metrics:

- AUC
- AUCPR
- calibration
- site-held-out AUC
- external validation AUC, if available

Biomarker validity metrics:

- bootstrap selection frequency
- ranking stability
- known biomarker recovery
- cross-split consistency
- cross-site consistency

Agent reliability metrics:

- leakage detection rate
- confounding detection rate
- shortcut detection rate
- unsupported claim rate
- hallucinated citation rate
- claim-evidence consistency

Workflow metrics:

- number of invalid analyses prevented
- number of human corrections needed
- time to valid analysis
- number of verifier failures before final report

---

## 11. 코드 작성 규칙

코드는 연구 재현성을 최우선으로 작성한다.

- 모든 실험은 config 기반으로 실행한다.
- random seed를 고정한다.
- split file을 저장한다.
- output directory에 config, metrics, logs, figures를 함께 저장한다.
- notebook에서만 끝나는 분석은 금지한다.
- notebook을 쓰더라도 최종 분석 로직은 `src/` 또는 `scripts/`로 분리한다.
- 모든 주요 함수는 입력/출력 schema를 명확히 한다.
- 데이터 row가 drop될 때는 이유와 개수를 로그로 남긴다.
- 모델 결과는 단일 run이 아니라 반복 split 또는 bootstrap 결과를 함께 보고한다.

권장 실행 흐름:

1. `scripts/audit_schema.py`
2. `scripts/run_baseline.py`
3. `scripts/run_verifiers.py`
4. `scripts/run_agent_workflow.py`

---

## 12. 결과 보고 규칙

결과 보고는 항상 다음 순서로 작성한다.

1. 실험 목적
2. 데이터 및 cohort 정의
3. outcome과 predictor 정의
4. split strategy
5. baseline 결과
6. verifier 결과
7. agent 결과
8. biomarker claim
9. 실패 사례
10. 한계
11. 다음 실험

좋은 결과만 보고하지 않는다.
실패한 split, 무너진 external validation, 불안정한 feature ranking도 반드시 기록한다.

---

## 13. SCRATCHPAD.md 기록 규칙

세션 시작 시 반드시 `SCRATCHPAD.md`를 먼저 읽는다.

작업 후 반드시 다음을 기록한다.

- 날짜
- 작업 목적
- 수정한 파일
- 실행한 명령어
- 사용한 데이터/config
- 주요 결과
- verifier 통과/실패 여부
- 발견한 문제
- 다음 할 일

기록은 새 세션이 맥락 없이도 이어받을 수 있을 정도로 구체적으로 남긴다.

---

## 14. Research critic 호출 조건

다음 상황에서는 반드시 research-critic 또는 professor 관점의 비판 검토를 수행한다.

- 새로운 task를 정의했을 때
- baseline 결과가 나온 뒤
- agent 결과가 baseline보다 좋아 보일 때
- biomarker claim을 작성하기 전
- 논문화 가능성을 판단할 때
- external validation이 실패했을 때
- leakage/confounding 가능성이 발견되었을 때

비판 검토에서는 다음 질문을 반드시 다룬다.

- 이 결과가 shortcut일 가능성은?
- reviewer가 가장 먼저 공격할 약점은?
- 기존 연구 대비 novelty가 충분한가?
- claim이 evidence보다 강하지 않은가?
- 같은 결과를 더 단순한 방법으로 설명할 수 있는가?
- top-tier conference에 제출하려면 어떤 기술적 기여가 부족한가?

---

## 15. 논문화 기준

이 프로젝트가 논문화되려면 최소한 다음 중 2개 이상을 만족해야 한다.

- verification-aware agent workflow가 generic agent보다 invalid claim을 유의하게 줄임
- leakage/confounding/site shortcut detection에서 정량적 개선을 보임
- biomarker claim을 evidence graph로 추적 가능하게 구조화함
- valid/invalid trajectory dataset을 구축함
- agent learning 또는 preference optimization으로 verifier 통과율을 개선함
- external cohort 또는 site-held-out setting에서 biomarker ranking 안정성을 보임

단순히 “의료 agent를 만들었다”는 이유만으로 논문화하지 않는다.

---

## 16. 세션 시작 체크리스트

작업 시작 전 순서:

1. `SCRATCHPAD.md` 읽기
2. 현재 task 확인
3. 관련 config 확인
4. manifest 기반 데이터 경로 확인
5. 기존 output 확인
6. 오늘 수행할 작업을 짧게 계획
7. 코드 수정 또는 실험 수행

---

## 17. 세션 종료 체크리스트

작업 종료 전 순서:

1. 실행 결과 저장 여부 확인
2. 로그 저장 여부 확인
3. verifier 결과 저장 여부 확인
4. 실패/예외 기록 여부 확인
5. `SCRATCHPAD.md` 갱신
6. 다음 작업 명시