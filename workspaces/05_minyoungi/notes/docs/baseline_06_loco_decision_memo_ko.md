# Baseline 06 LOCO 이후 판단 메모

작성 시점: 2026-05-26

## 결론

`voxelwise_feature_learning_v1`의 현재 실험들은 다음을 보여준다.

1. 단순한 ROI 평균 하나만으로는 CN/AD 분리가 제한적이다.
2. ROI summary feature, 특히 mask/volume 계열 정보가 들어가면 성능이 크게 오른다.
3. image-only 3D CNN도 random subject-disjoint split에서는 ROI summary baseline에 근접한다.
4. 그러나 leave-one-cohort-out으로 바꾸면 image-only 3D CNN 성능이 의미 있게 떨어진다.
5. 따라서 현재 단계의 핵심 병목은 “이미지에 신호가 전혀 없다”가 아니라, **cohort/site shift와 ROI/형태학 shortcut을 분리해서 representation으로 일반화시키는 문제**다.

## 현재까지 baseline 비교

- baseline_02 ROI mean logreg CN vs AD
  - split: subject-disjoint random
  - ROC-AUC: 0.7018
  - balanced accuracy: 0.6806

- baseline_03 ROI summary logreg CN vs AD
  - split: random + LOCO
  - random ROC-AUC: 0.9004
  - random balanced accuracy: 0.8486
  - LOCO mean ROC-AUC: 0.8732

- baseline_04 ROI summary ablation logreg CN vs AD
  - split: random + LOCO
  - random ROC-AUC: 0.9004
  - random balanced accuracy: 0.8486
  - LOCO mean ROC-AUC: 0.8732
  - 해석: ROI summary의 강한 정보가 유지됨. 특히 `voxel_count`/형태학 shortcut 가능성을 계속 경계해야 한다.

- baseline_05 image-only 3D CNN CN vs AD smoke
  - split: random subject-disjoint
  - ROC-AUC: 0.8906
  - balanced accuracy: 0.8314
  - 해석: final_tensor T1w image-only에서도 CN/AD 신호는 분명히 잡힌다.

- baseline_06 image-only 3D CNN LOCO CN vs AD
  - split: leave-one-cohort-out
  - folds: 6/6
  - mean ROC-AUC: 0.8087
  - mean balanced accuracy: 0.7146
  - leakage audit: pass
  - 해석: cohort-held-out에서도 chance보다 확실히 높지만, random split 대비 일반화 gap이 크다.

## Baseline 06 fold별 결과

- ADNI held-out
  - n=2666, CN=2403, AD=263
  - ROC-AUC: 0.7572
  - balanced accuracy: 0.6952
  - 특징: AD prevalence가 낮아 AP는 낮고, FP가 많다.

- AIBL held-out
  - n=817, CN=692, AD=125
  - ROC-AUC: 0.8576
  - balanced accuracy: 0.7827
  - 특징: 가장 안정적인 fold 중 하나.

- AJU held-out
  - n=238, CN=23, AD=215
  - ROC-AUC: 0.8081
  - balanced accuracy: 0.6495
  - 특징: class prior가 반대로 심하게 치우쳐 accuracy는 낮고, threshold calibration이 취약하다.

- KDRC held-out
  - n=581, CN=307, AD=274
  - ROC-AUC: 0.8395
  - balanced accuracy: 0.7543
  - 특징: class balance가 상대적으로 좋고 결과도 양호하다.

- NACC held-out
  - n=1173, CN=1004, AD=169
  - ROC-AUC: 0.7968
  - balanced accuracy: 0.7275

- OASIS held-out
  - n=1535, CN=1287, AD=248
  - ROC-AUC: 0.7932
  - balanced accuracy: 0.6786

## 해석

### 1. 이미지 신호는 있다

Random split image-only CNN이 ROC-AUC 0.8906까지 올라갔고, LOCO에서도 평균 ROC-AUC 0.8087을 유지했다. 따라서 T1w final_tensor 자체에 CN/AD 관련 형태학적 신호가 존재한다는 가설은 지지된다.

### 2. 하지만 일반화 gap이 있다

Random image-only AUC 0.8906에서 LOCO mean AUC 0.8087로 떨어졌다. 이 차이는 subject-level leakage만으로 설명되기 어렵고, cohort/site/protocol/domain shift 또는 class-prior/threshold 문제가 크다는 뜻이다.

### 3. ROI summary baseline이 여전히 상한/shortcut baseline이다

ROI summary LOCO mean AUC 0.8732가 image-only LOCO 0.8087보다 높다. 이는 FastSurfer/ROI summary가 CN/AD에 강한 형태학 정보를 제공한다는 뜻이지만, 동시에 `voxel_count`/mask-size shortcut을 조심해야 한다. 이것은 VLM 주장의 결과가 아니라 baseline gate다.

### 4. VLM으로 바로 크게 가면 안 된다

현재 결론은 “image-only도 된다”가 아니라 “image-only가 신호는 잡지만 cohort 일반화와 ROI-grounded representation 문제가 남았다”이다. 따라서 바로 대형 VLM/MLLM pretraining을 올리기보다, ROI-grounded image representation이 진짜로 형성되는지 검증하는 중간 실험이 필요하다.

## 추천 다음 단계

### Step 1. Baseline 06 진단 리포트 보강

목적: LOCO gap의 원인을 먼저 분해한다.

해야 할 일:

- predictions를 manifest metadata와 join
- cohort별 threshold-free AUC와 threshold-dependent confusion을 분리
- age bin, sex, scanner/field strength 가능하면 stratified audit
- probability histogram/calibration plot 생성
- ADNI/AJU/OASIS처럼 class-prior가 치우친 fold의 threshold 문제 분석

판단 기준:

- AUC는 양호한데 balanced accuracy가 낮으면 threshold/calibration 문제
- AUC 자체가 낮으면 representation/domain shift 문제
- 특정 cohort만 무너지면 site/protocol shift 문제

### Step 2. ROI summary vs image-only 동일 row 비교

목적: image-only CNN이 ROI morphology 신호를 어느 정도 재현하는지 확인한다.

해야 할 일:

- baseline_03 ROI summary prediction과 baseline_06 image prediction을 동일 held-out row 기준으로 align
- 둘 다 맞는 row, ROI만 맞는 row, image만 맞는 row, 둘 다 틀린 row를 분류
- ROI-only score와 image-only score correlation 확인
- fold별로 ROI advantage가 큰 cohort를 찾기

판단 기준:

- ROI와 image score가 강하게 상관되면 image CNN이 ROI morphology를 일부 학습한 것
- ROI는 맞고 image만 틀리는 row가 많으면 ROI signal을 image encoder로 옮기는 distillation이 타당
- image만 맞는 row가 많으면 ROI 외 texture/intensity/domain signal 가능성도 점검

### Step 3. seed repeat는 작게만 수행

목적: baseline_06이 우연한 seed 결과인지 확인한다.

권장:

- full 6-fold × 3 seeds가 가장 좋지만 비용이 늘어난다.
- 먼저 worst/representative folds 3개만 seed repeat:
  - ADNI: 큰 n, 낮은 AP/FP 문제
  - AJU: class prior 역전/threshold 문제
  - KDRC 또는 AIBL: 상대적으로 안정적인 reference

판단 기준:

- AUC 변동이 작으면 현 결과 신뢰 가능
- fold별 변동이 크면 모델/threshold/optimization 안정화가 먼저

### Step 4. 다음 핵심 실험은 ROI→image distillation

목적: VLM 전에 “이미지 encoder가 ROI-grounded morphology representation을 배울 수 있는가”를 검증한다.

설계:

- Teacher: baseline_03/04의 ROI summary 또는 정제된 ROI morphology feature
- Student: T1w final_tensor image-only 3D encoder
- 금지: diagnosis/CDR/PET/cohort/scanner/age/sex를 teacher target이나 caption에 직접 넣지 않기
- loss: ROI z/status regression 또는 teacher-latent/logit distillation
- evaluation:
  - ROI imitation metric
  - frozen embedding CN/AD probe
  - LOCO CN/AD probe
  - cohort-wise performance

판단 기준:

- ROI imitation이 train-mean baseline을 이겨야 함
- frozen embedding probe가 baseline_06 image-only보다 개선되거나 최소한 gap을 줄여야 함
- 개선이 없으면 VLM scaling 전에 representation failure로 보고 원인 분석

### Step 5. VLM caption branch는 아직 training이 아니라 policy/spec 단계

현재 caption/VLM로 바로 가는 것은 이르다. 먼저 다음을 고정해야 한다.

- allowed_text_fields / forbidden_text_fields
- global safe caption: modality + age bucket + sex 정도
- ROI morphology caption: image-derived ROI measurement만 사용
- diagnosis/PET/CDR/biomarker 단어 금지
- ROI quant-to-text rule versioning
- train-only reference distribution fitting

이후 contrastive image-text alignment는 baseline/distillation gate를 통과한 뒤 진행한다.

## 최종 판단

지금 바로 할 일의 우선순위는 다음이다.

1. **Baseline 06 LOCO diagnostic 분석**
   - 가장 안전하고 즉시 필요함.
   - 현재 결과의 약점을 정확히 설명할 수 있게 만든다.

2. **ROI summary vs image-only row-level comparison**
   - VLM/ROI-grounded representation으로 넘어갈 근거를 만든다.

3. **작은 seed repeat 또는 selected-fold repeat**
   - 결과 안정성 확인.

4. **ROI→image distillation v0 설계/실행**
   - VLM 직전의 핵심 gate.

5. **caption/VLM branch는 policy/spec 먼저, 대형 학습은 아직 보류**

한 문장으로 요약하면:

> CN/AD image-only 신호는 확인됐지만, LOCO 일반화 gap과 ROI shortcut/형태학 정보의 관계를 먼저 분해해야 한다. 다음 단계는 대형 VLM 학습이 아니라 `LOCO 진단 → ROI/image 비교 → ROI→image distillation gate` 순서가 맞다.
