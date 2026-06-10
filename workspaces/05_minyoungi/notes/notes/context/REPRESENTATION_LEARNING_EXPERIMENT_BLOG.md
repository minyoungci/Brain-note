# 3D Brain Representation Learning: 실패를 해부한 실험 기록

작성일: 2026-05-22  
워크스페이스: `/home/vlm/minyoungi`  
목적: 지금까지의 3D brain representation learning 실험, 실패 지점, 확정된 근거, 다음 방향을 하나의 문서로 정리한다.

> 핵심 결론: 지금까지의 실험은 “모델을 조금 더 키우면 해결된다”가 아니라, **ROI-volume teacher distillation만으로는 강한 3D brain representation을 만들기 어렵다**는 방향을 가리킨다. 다만 중간에 발견한 구현/최적화 문제는 해결했고, 현재 병목은 **teacher ceiling + 80/class generalization/teacher-transfer gap**으로 이동했다.

---

## 1. 우리가 풀고 있는 문제

우리의 최우선 목표는 CN/MCI/AD classifier를 만드는 것이 아니라 **3D brain representation learning**이다.

CN/MCI/AD 성능은 downstream probe일 뿐이다. 따라서 좋은 representation은 최소한 다음을 만족해야 한다.

- 3D MRI anatomy를 안정적으로 담는다.
- AD-relevant disease axis, 예를 들어 hippocampus/entorhinal 위축과 ventricle 확장 방향성을 반영한다.
- cohort/scanner shortcut에 과도하게 의존하지 않는다.
- MCI를 단순 hard class로만 맞추는 것이 아니라 CN↔AD continuum 위에서 해석 가능하게 배치한다.
- 이후 ROI caption, report, VLM alignment로 확장할 가치가 있다.

하지만 지금까지의 결과는 **단순 ROI-volume scalar teacher를 image encoder에 distill하는 경로가 main route로는 약하다**는 쪽에 가깝다.

---

## 2. 데이터와 산출물 관리 원칙

이번 정리는 산출물을 많이 남기지 않는 원칙으로 진행했다. 최신 결과는 overwrite 방식의 JSON과 단일 root-cause 문서에 누적했다.

주요 rolling 문서:

```text
/home/vlm/minyoungi/notes/context/REPRESENTATION_LEARNING_ROOT_CAUSE_PLAN.md
```

이번 블로그형 통합 문서:

```text
/home/vlm/minyoungi/notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md
```

대표 최신 artifact:

```text
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_LATEST_AUDIT.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FINAL_TENSOR_QC.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_HEAD_OPT_AUDIT_LATEST.json
/home/vlm/minyoungi/experiments/roi_to_image_distill_v0/REPRESENTATION_ROOT_CAUSE_FLATPOOL_80CLASS_LATEST.json
```

---

## 3. 첫 번째 질문: ROI teacher가 완전히 잘못됐나?

결론: **완전히 잘못된 것은 아니다.**

근거:

- AD 방향성 audit에서 16/16 ROI가 기대 방향을 유지했다.
- ROI-only probe는 internal_test에서 대략 0.50 전후의 balanced accuracy를 낸다.
- FastSurfer native-space overlay 54-case gross QC에서 큰 off-brain/gross misregistration은 보이지 않았다.

ROI harmonization audit에서 본 teacher 후보는 다음과 같다.

### Current mixed-train MaskVol z

```text
internal_test diagnosis probe: bal_acc=0.5193, macro_f1=0.4847, CN/MCI/AD recall=0.6067/0.3385/0.6127
cohort probe balanced_accuracy: 0.3772
directionality: 16/16
```

### Teacher-S / signal-preserving CN age/sex residual z

```text
internal_test diagnosis probe: bal_acc=0.5558, macro_f1=0.5172, CN/MCI/AD recall=0.6411/0.3646/0.6618
cohort probe balanced_accuracy: 0.3567
directionality: 16/16
```

### ComBat cohort+age/sex then train z

```text
internal_test diagnosis probe: bal_acc=0.4947, macro_f1=0.4476, CN/MCI/AD recall=0.6133/0.2188/0.6520
cohort probe balanced_accuracy: 0.1575
directionality: 16/16
```

### Teacher-B / bias-reduced ComBat + CN age/sex residual z

```text
internal_test diagnosis probe: bal_acc=0.5063, macro_f1=0.4617, CN/MCI/AD recall=0.6133/0.2535/0.6520
cohort probe balanced_accuracy: 0.1366
directionality: 16/16
```

정리하면:

- signal-preserving teacher는 diagnosis signal이 상대적으로 강하다.
- ComBat/bias-reduced teacher는 cohort signal을 크게 줄이지만 diagnosis signal, 특히 MCI signal도 일부 깎는다.
- 따라서 teacher variant 하나를 무조건 고르는 것이 아니라, signal-preserving branch와 bias-reduced branch를 비교해야 한다.

앞으로 혼동 방지를 위해 예전의 `T1/T2`라는 이름은 쓰지 않는 것이 좋다. 시간점처럼 보이기 때문이다.

```text
Teacher-S = signal-preserving ROI teacher
Teacher-B = bias-reduced ComBat ROI teacher
```

---

## 4. 두 번째 질문: voxel-wise ROI mask를 final_tensor 공간에서 쓸 수 있나?

결론: **현재는 쓰면 안 된다.**

FastSurfer native-space ROI mask를 student input인 `final_tensor` 공간으로 affine-only resampling한 결과:

```text
n_cases = 54
n_ok = 54
n_resampled_nonzero = 52
nonzero_rate = 0.9629629629629629
relative_volume_error_summary = {'median': -0.8916871697779953, 'p10': -0.961322181228985, 'p90': -0.765759029190213, 'min': -1.0, 'max': -0.6743909089192293}
```

해석:

- 대부분의 ROI volume이 크게 줄거나 일부가 사라졌다.
- contact sheet에서도 ROI가 너무 작거나 밀리는 패턴이 있었다.
- 즉 FastSurfer native ROI mask를 `final_tensor` 192×224×192 공간에 affine-only로 옮기는 것은 신뢰할 수 없다.

따라서 금지:

```text
voxel-wise ROI crop
ROI mask-guided attention
voxel-wise ROI supervision/loss
```

허용:

```text
scalar ROI z teacher
ROI-derived tabular teacher
teacher latent/logit distillation
```

이 실패는 ROI scalar teacher가 틀렸다는 뜻이 아니라, **voxel-wise transform chain이 아직 검증되지 않았다는 뜻**이다.

---

## 5. 세 번째 질문: image student가 teacher를 못 배우는 이유는 implementation bug였나?

처음에는 small CNN teacher-latent run에서 결과가 나빴다.

### 초기 CNN/GAP teacher-latent 결과

Teacher-S branch에서 teacher 자체는 어느 정도 유효했다.

```text
teacher internal_test: bal_acc=0.5458, macro_f1=0.5459, CN/MCI/AD recall=0.6125/0.4000/0.6250
student direct: bal_acc=0.3333, macro_f1=0.1667, CN/MCI/AD recall=0.0000/1.0000/0.0000
student frozen: bal_acc=0.4417, macro_f1=0.3652, CN/MCI/AD recall=0.5750/0.0250/0.7250
```

문제는 student direct head가 한 class로 collapse했고, frozen embedding도 teacher를 충분히 따라가지 못했다는 점이다.

그래서 tiny overfit diagnostic을 했다.

### 12/class tiny overfit diagnostic

기존 GAP CNN에서는 12/class도 제대로 외우지 못했다.

대표 결과:

```text
full objective tiny direct: bal_acc=0.4167, macro_f1=0.3183, CN/MCI/AD recall=0.0000/0.3333/0.9167
no_roi tiny direct: bal_acc=0.4722, macro_f1=0.3804, CN/MCI/AD recall=0.0000/0.5833/0.8333
teacher_ce tiny direct: bal_acc=0.6389, macro_f1=0.6420, CN/MCI/AD recall=0.7500/0.5833/0.5833
true_ce_diag tiny direct: bal_acc=0.3333, macro_f1=0.1667, CN/MCI/AD recall=0.0000/1.0000/0.0000
```

이때 중요한 관찰:

- ROI loss를 빼도 해결되지 않았다.
- hard teacher CE는 개선을 만들었지만 완전 overfit은 아니었다.
- true-label CE only도 MCI collapse를 보였다.

이 시점의 가설은 “label/data/CE plumbing 문제인가, 아니면 architecture/optimization 문제인가?”였다.

---

## 6. 네 번째 질문: label/data/CE path가 깨졌나?

결론: **깨지지 않았다.**

Head/optimization audit 결과:

```text
row_id_onehot_head: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
raw_image_random_projection_head: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
frozen_random_cnn_gap_head: bal_acc=0.6389, macro_f1=0.6397, CN/MCI/AD recall=0.6667/0.5833/0.6667
GAP CNN lr=1e-3 clip=1: bal_acc=0.5556, macro_f1=0.4999, CN/MCI/AD recall=0.8333/0.0833/0.7500
GAP CNN lr=1e-4 no clip: bal_acc=0.9722, macro_f1=0.9722, CN/MCI/AD recall=0.9167/1.0000/1.0000
flatpool CNN lr=1e-3: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
flatpool CNN lr=3e-3: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
```

확정된 것:

- row-id one-hot head가 완벽히 외우므로 label/CE/metric loop는 정상이다.
- raw image random projection head가 완벽히 외우므로 image tensor와 label 연결도 깨지지 않았다.
- GAP CNN은 lr=1e-3에서 불안정하지만 lr=1e-4에서는 거의 완벽히 overfit한다.
- coarse spatial layout을 보존하는 flatpool CNN은 lr=1e-3/3e-3에서도 완벽히 overfit한다.

따라서 이전 failure의 한 원인은 확정됐다.

```text
Primary resolved root cause:
  low-dimensional global-average bottleneck + aggressive lr/optimization
```

즉 “MRI image student가 원래 아무것도 못 배운다”가 아니라, **이전 architecture/optimization 조합이 tiny overfit조차 불안정하게 만든 것**이다.

---

## 7. 다섯 번째 질문: flatpool CNN으로 teacher-latent 문제는 해결됐나?

부분적으로만 해결됐다.

### 12/class flatpool objective ladder

Flatpool CNN은 모든 teacher-latent variant에서 12/class를 완벽히 overfit했다.

```text
teacher CE tiny direct: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
teacher CE+KL tiny direct: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
teacher CE+KL+emb tiny direct: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
teacher CE+KL+emb+ROI tiny direct: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
```

이건 중요한 pass다.

```text
Resolved:
  tiny overfit failure
  single-class collapse
  basic teacher-latent optimization blocker
```

### 80/class flatpool Teacher-S controlled run

하지만 80/class로 확장하면 결과는 아직 강하지 않다.

Teacher ceiling:

```text
train80 teacher: bal_acc=1.0000, macro_f1=1.0000, CN/MCI/AD recall=1.0000/1.0000/1.0000
val80 teacher: bal_acc=0.4542, macro_f1=0.4426, CN/MCI/AD recall=0.5375/0.2250/0.6000
internal_test80 teacher: bal_acc=0.5167, macro_f1=0.5135, CN/MCI/AD recall=0.6125/0.3750/0.5625
```

Student:

```text
teacher CE internal_test direct: bal_acc=0.4833, macro_f1=0.4749, CN/MCI/AD recall=0.5250/0.3000/0.6250
teacher CE internal_test frozen: bal_acc=0.4708, macro_f1=0.4692, CN/MCI/AD recall=0.5750/0.4000/0.4375

teacher CE+KL+emb+ROI internal_test direct: bal_acc=0.4917, macro_f1=0.4850, CN/MCI/AD recall=0.5250/0.3375/0.6125
teacher CE+KL+emb+ROI internal_test frozen: bal_acc=0.4792, macro_f1=0.4787, CN/MCI/AD recall=0.5375/0.4125/0.4875
```

해석:

- class collapse는 사라졌다.
- MCI recall은 이전보다 회복됐다.
- train absorption은 가능하다.
- 하지만 frozen internal_test balanced accuracy는 약 0.48 수준이다.
- teacher internal_test 자체도 약 0.52 수준이어서 ceiling이 높지 않다.

즉 현재 병목은 implementation bug가 아니라 다음으로 이동했다.

```text
Current bottleneck:
  80/class generalization
  teacher-student transfer gap
  moderate/weak ROI teacher ceiling
```

---

## 8. 지금까지 확정된 내용

### 확정 1. ROI scalar teacher는 완전 garbage가 아니다

근거:

- ROI directionality가 유지됐다.
- ROI-only diagnosis probe가 0.50 전후 signal을 보인다.
- native-space overlay gross QC에서 큰 실패는 없었다.

하지만 한계:

- volume-only teacher다.
- eTIV/ICV, cortical thickness, hippocampal subfields가 없다.
- ComBat을 하면 bias는 줄지만 disease signal도 일부 줄어든다.
- MCI signal이 특히 약하다.

### 확정 2. voxel-wise ROI supervision은 아직 금지

근거:

- final_tensor-space ROI resampling QC에서 volume loss/misalignment가 컸다.

따라서 scalar ROI만 사용해야 한다.

### 확정 3. 이전 CNN failure에는 architecture/optimization 문제가 있었다

근거:

- GAP CNN lr=1e-3은 tiny overfit 실패.
- GAP CNN lr=1e-4는 거의 overfit.
- flatpool CNN은 완벽히 overfit.

### 확정 4. flatpool CNN은 tiny teacher-latent objective를 해결했다

근거:

- 12/class 모든 objective ladder가 balanced accuracy 1.0.

### 확정 5. 하지만 80/class representation은 아직 강하지 않다

근거:

- best frozen internal_test가 약 0.479.
- Teacher-S internal_test 자체가 약 0.517.
- 따라서 ceiling과 transfer gap 모두 문제다.

---

## 9. 무엇을 더 하면 안 되는가

현재 evidence상 바로 하면 안 되는 것:

```text
큰 VLM 학습으로 점프
ViT/Transformer만 키워서 재시도
ROI mask-guided loss 사용
voxel-wise ROI crop 사용
loss를 여러 개 더 붙인 대형 run
seed만 무작정 반복
```

이유:

- 기본 implementation blocker는 해결됐지만, teacher ceiling이 낮다.
- 3-class CN/MCI/AD probe는 MCI heterogeneity와 cohort confounding을 많이 섞는다.
- 더 큰 모델은 원인을 더 흐릴 수 있다.

---

## 10. 연구 방향 재정렬

현재 evidence는 ROI-volume distillation을 main route로 계속 밀기보다는, 이를 **auxiliary / diagnostic branch**로 내려야 함을 시사한다.

추천 방향:

### A. ROI teacher 강화

현재 teacher가 volume-only라 약하다. 강화 후보:

```text
cortical thickness
surface area
hippocampal subfields
eTIV/ICV correction
AD signature composite
CN-only normative modeling
ComBat/harmonization refinement
age/sex/cohort nuisance modeling
```

목표:

```text
teacher ceiling 자체를 올린다.
```

### B. 3D self-supervised / anatomical multi-task representation으로 이동

ROI teacher를 main supervision이 아니라 auxiliary로 둔다.

후보:

```text
masked autoencoding
3D contrastive/self-distillation
age/sex/ROI multi-task auxiliary
CN↔AD disease-axis probe
image-to-ROI caption retrieval smoke test
```

목표:

```text
CN/MCI/AD hard 3-class 성능이 아니라 3D anatomy와 disease-axis representation을 먼저 만든다.
```

---

## 11. 다음 실험을 한다면 어떤 순서인가

바로 VLM이 아니라 다음 순서가 맞다.

```text
1. Teacher-S vs Teacher-B를 같은 flatpool CNN 80/class 조건에서 비교한다.
2. frozen embedding cohort probe를 추가한다.
3. 둘 다 <=0.50이면 ROI-volume teacher ceiling 문제로 판정한다.
4. 그 경우 ROI-volume distillation은 main path에서 내리고 auxiliary로 둔다.
5. self-supervised/anatomical multi-task representation 설계로 넘어간다.
```

평가 metric은 3-class 하나만 보지 않는다.

```text
anatomical metric: ROI/age/brain-volume proxy prediction
disease-axis metric: CN vs AD, CN→AD axis, MCI projection
bias metric: cohort probe, per-cohort recall
VLM readiness: ROI caption retrieval/alignment
```

---

## 12. 최종 결론

지금까지의 실험은 실패가 아니라, 경로를 좁히는 데 성공한 것이다.

우리가 확정한 것:

```text
1. ROI scalar teacher에는 signal이 있다.
2. voxel-wise ROI mask는 현재 final_tensor 공간에서 쓰면 안 된다.
3. 이전 CNN collapse는 GAP bottleneck + lr/optimization 문제였다.
4. flatpool CNN은 tiny overfit과 teacher-latent objective를 통과한다.
5. 그러나 80/class generalization은 여전히 약하고 teacher ceiling도 낮다.
```

따라서 현재 가장 정직한 결론은 다음이다.

> **ROI-volume scalar teacher distillation은 3D brain representation learning의 main route로는 약하다. 구현/최적화 문제는 상당 부분 해결됐지만, 80/class에서 teacher-transfer와 generalization이 약하고 teacher 자체 ceiling도 낮다. 이제 ROI distillation은 auxiliary/diagnostic branch로 두고, 더 강한 anatomical teacher 또는 self-supervised/anatomical multi-task 3D representation으로 방향을 재정렬해야 한다.**

---

## 13. 짧은 decision statement

앞으로의 연구 decision:

```text
Continue:
  flatpool CNN as a verified diagnostic student
  scalar ROI teacher as auxiliary/explanation signal
  Teacher-S vs Teacher-B bias audit

Stop / pause:
  voxel-wise ROI supervision
  GAP CNN lr=1e-3 teacher-latent path
  ROI-volume teacher distillation as sole main objective
  premature VLM scaling

Start:
  stronger anatomical teacher design
  self-supervised/anatomical multi-task representation plan
  disease-axis and cohort-bias evaluation protocol
```
