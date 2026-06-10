# Failed 3D CN/AD Representation Study Closure - 2026-06-07

## 1. 최종 판정

이 문서는 `/home/vlm/minyoung4`에서 수행한 3D T1w MRI CN/AD representation 실험군을 실패한 연구 방향으로 닫기 위한 최종 정리다.

최종 결론:

```text
ROI summary feature 계열: 중단
Residualized feature 계열: 실패
3D encoder smoke 계열: 실행 가능성만 확인
Representation claim: 금지
Performance claim: 금지
모델/산출물 보존 필요성: 없음
```

이 연구군은 "좋은 MRI representation을 학습했다"는 근거를 만들지 못했다. 일부 수치가 계산되었지만, 대부분은 smoke, probe availability, 또는 shortcut audit 수준이며 논문 claim으로 사용할 수 없다.

## 2. 처음의 연구 가설

초기 가설은 다음과 같았다.

1. 3D T1w MRI의 ROI intensity/tissue-distribution 정보가 morphometry보다 세밀한 disease-relevant representation을 줄 수 있다.
2. ROI 또는 local region 기반 contrastive/representation learning이 CN/AD 구분에 도움이 될 수 있다.
3. Site/scanner bias를 직접 제거하거나 조건화하면 MRI representation의 일반화 가능성을 높일 수 있다.
4. 최종적으로 morphometry baseline을 넘고, cohort/scanner shortcut이 낮은 3D representation을 만들 수 있다.

이 가설은 현재 실험군에서는 지지되지 않았다.

## 3. 사용 데이터와 실험 단위

주요 데이터 설정:

```text
Data root: data/v2/official 계열 manifest 기반
Image type: 3D T1w, N4 기반 전처리 volume
Primary task: CN vs AD 2-class
Unit of analysis: subject-level
Primary balanced cohorts: ADNI, AIBL, KDRC
Strict balanced subject count: 890
```

Strict balanced 구성:

```text
ADNI: AD 126 / CN 126
AIBL: AD 70  / CN 70
KDRC: AD 249 / CN 249
```

3D preflight에서 확인한 상태:

```text
unique subjects: 890
missing image paths: 0
bounded header audit shape: 192 x 224 x 192
bounded header audit spacing: 1.0 x 1.0 x 1.0 mm
```

## 4. 주요 실험 흐름

### 4.1 Full N4 ROI summary feature

ROI intensity/tissue-distribution, morphometry, local ROI summary feature를 이용해 CN/AD LOCO 평가를 수행했다.

Full extraction 상태:

```text
subjects processed: 1857
feature rows: 9285
ROI per subject: 5
duplicate subject/ROI keys: 0
non-ok feature rows: 0
```

ROI:

```text
amygdala
hippocampus
lateral_ventricle
parahippocampal_cortex
thalamus
```

핵심 LOCO 결과:

```text
all_source:
  F0 morphometry weighted AUC: 0.9072
  F1 morphometry + intensity weighted AUC: 0.9041
  F3 intensity-only weighted AUC: 0.8825

both_class_source_cohorts_only:
  F0 morphometry weighted AUC: 0.9104
  F1 morphometry + intensity weighted AUC: 0.9181
  F3 intensity-only weighted AUC: 0.8866
```

해석:

- intensity-only는 morphometry baseline보다 약했다.
- morphometry + intensity는 일부 조건에서만 소폭 개선됐다.
- all-source에서는 오히려 morphometry보다 낮았다.
- 따라서 "intensity/tissue feature가 더 좋은 MRI representation"이라는 주장은 불가능하다.

### 4.2 Shortcut / site bias audit

Feature-level shortcut audit 결과:

```text
consortium macro AUC: 0.8733
scanner macro AUC: 0.9529
scanner NN purity k=5: 0.7938
diagnosis NN purity k=5: 0.8774
```

해석:

- ROI feature space에서 scanner/acquisition 정보가 매우 강하게 남아 있다.
- disease signal도 일부 존재하지만 scanner/site signal이 더 위험한 수준으로 decodable하다.
- 성능 개선처럼 보이는 수치가 실제 disease representation인지 확신할 수 없다.

### 4.3 Residual disease-signal validation

Stage236 strict balanced residual evaluation:

```text
overall decision: fail
mean residual delta AUC vs morphometry: +0.00013
scanner AUC with morphometry + intensity: 0.925
```

해석:

- morphometry를 넘어서는 residual disease signal은 사실상 없었다.
- scanner signal은 여전히 높았다.

### 4.4 Acquisition residualization

Stage237 acquisition residualized feature evaluation:

```text
overall decision: fail
best residualized feature variant mean delta AUC: +0.00037
scanner AUC after best residualization: 0.586
```

해석:

- scanner decodability는 낮출 수 있었다.
- 그러나 disease prediction gain이 거의 0이었다.
- 즉, acquisition 축을 제거하면 남는 disease-relevant gain이 약했다.

### 4.5 3D encoder smoke

3D encoder는 full training이 아니라 smoke/probe availability 수준으로만 검증했다.

CPU smoke:

```text
embedding rows: 8
embedding dim: 64
checkpoint saved: true
probe claim allowed: false
```

GPU smoke:

```text
device: cuda:1
held cohort: AIBL
train cohorts: ADNI + KDRC
epochs: 2
batch size: 2
downsample: 4
train subjects: 80
val subjects: 80
prediction rows: 160
embedding rows: 160
embedding dim: 64
checkpoint saved: true
gpu_training_executed: true
performance_claim_allowed: false
```

GPU smoke metric:

```text
epoch 1 val AUC: 0.6025
epoch 2 val AUC: 0.6300
epoch 2 val balanced accuracy: 0.5
```

해석:

- GPU image loading, forward, loss, checkpoint, embedding export 경로는 동작했다.
- 하지만 smoke 설정이므로 성능 claim은 금지다.

### 4.6 Embedding probe on GPU smoke

Stage240 GPU smoke embedding probe:

```text
embedding rows: 160
embedding dim: 64
probe claim allowed: true
performance claim allowed: false
```

Probe 결과:

```text
all disease AUC: 0.6763
all disease balanced accuracy: 0.6142
all consortium AUC: 0.9216
all scanner AUC: 0.8948

train disease AUC: 0.6483
train consortium AUC: 0.6727
train scanner AUC: 0.7209

val disease AUC: 0.7919
val consortium/scanner probe: not evaluable, single cohort/scanner
```

해석:

- embedding에서 disease도 decode되지만 consortium/scanner도 강하게 decode된다.
- 특히 all split의 consortium AUC 0.9216, scanner AUC 0.8948은 shortcut risk가 여전히 핵심 문제임을 보여준다.
- val AIBL은 단일 cohort, 단일 scanner라 site/scanner 분리 검증이 불가능하다.
- 이 결과는 3D encoder가 좋은 representation을 배웠다는 근거가 아니라, 앞으로 반드시 shortcut probe를 동반해야 한다는 경고 신호다.

## 5. 왜 실패로 판정하는가

실패 판정 근거:

1. Morphometry baseline이 이미 강하다.
   - 단순 morphometry 기준이 약 0.91 AUC 수준이다.
   - image/ROI summary 계열은 이 기준을 안정적으로 넘지 못했다.

2. Intensity/tissue feature의 disease gain이 작고 불안정하다.
   - intensity-only는 morphometry보다 낮다.
   - morphometry + intensity의 개선은 조건 의존적이다.

3. Scanner/site shortcut이 너무 강하다.
   - ROI feature scanner AUC는 0.95 수준이었다.
   - GPU smoke embedding에서도 consortium/scanner가 강하게 decode됐다.

4. Residualization은 shortcut을 줄여도 disease gain을 만들지 못했다.
   - residual delta AUC는 +0.00013 또는 +0.00037 수준이었다.

5. 3D encoder 결과는 smoke일 뿐이다.
   - 실행 가능성은 확인했지만 full LOCO, calibration, shortcut-controlled validation이 없다.
   - 따라서 SCI/top-tier claim으로 이어질 증거가 없다.

## 6. 깨달은 점

이번 실패에서 얻은 핵심 교훈:

1. "MRI를 더 많이 본다"는 것만으로 representation이 좋아지지 않는다.
2. CN/AD에서는 morphometry가 매우 강한 baseline이며, image encoder는 이 기준을 명시적으로 넘어야 한다.
3. Scanner/site/acquisition 정보는 MRI intensity와 embedding에 쉽게 들어간다.
4. Shortcut을 지우는 것과 disease signal을 남기는 것은 별개 문제다.
5. Smoke run의 AUC는 연구 결과가 아니라 pipeline health check다.
6. 앞으로의 연구는 성능 상승보다 "disease signal과 acquisition signal의 분리 가능성"을 먼저 증명해야 한다.

## 7. 폐기 범위

다음은 실패 연구 산출물로 간주해 삭제한다.

```text
docs/context/stage236_* script and output
docs/context/stage237_* script and output
docs/context/stage238_* script and output
docs/context/stage239_* script and output, including model checkpoints
docs/context/stage240_* script and output
docs/context/stage241_* script and output
docs/context/stage242_* script and output
docs/context/stage243_* script and output
docs/context/stage244_current_state_table_20260607.csv
docs/context/STAGE236_*.md
docs/context/STAGE238_*.md
docs/context/STAGE244_*.md
docs/context/NEXT_EXPERIMENT_START_HERE_20260607_KO.md
docs/context/CLOSED_FULL_N4_ROI_EXPERIMENT_20260607_KO.md
```

보존:

```text
docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md
```

삭제 금지:

```text
/home/vlm/data/raw/
shared raw/preprocessed data roots
```

## 8. 다음 연구를 시작할 때의 조건

새 연구를 시작할 때는 이 실패 실험의 산출물을 재사용하지 않는다.

다음 연구는 최소한 아래를 먼저 정의해야 한다.

```text
Task:
Research question:
Outcome:
Input / exposure:
Unit of analysis:
Cohort / filters:
Split policy:
Leakage risks:
Files to change:
Expected artifact:
Validation:
Unclear assumptions:
Needs Min approval:
```

다음 연구 방향은 아직 확정하지 않는다. 특히 VLM/MLLM, JEPA, PET transfer, longitudinal modeling, multimodal fusion은 현재 기본 방향이 아니다.

현재 별도의 다음 연구 계획은 확정하지 않는다.

특히 이전의 다중 컨소시엄 평가 계획은 현재 진행 계획에서 제외한다. 새 연구를 시작할 때는 사용할 cohort, label, split, metric을 manifest audit 이후 다시 정의해야 하며, 이전 실패 실험의 계획 문구를 그대로 승계하지 않는다.

성능이 좋아 보여도 cohort/site/scanner shortcut을 분리 검증하지 못하면 연구 claim으로 사용하지 않는다.
