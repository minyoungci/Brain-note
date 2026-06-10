# Research Summary v2 — Gate03–Gate05a 통합 정리

작성일: 2026-05-27
Workspace: `/home/vlm/minyoungi`
Experiment family: `experiments/voxelwise_feature_learning_v1`
범위: Gate02 실패 진단을 배경으로, Gate03, Gate03b, Gate03c, Gate04, Gate04b, Gate04c, Gate04d, Gate05a 결과를 통합 정리한다.

---

## 1. 현재 연구 목표

이 실험 라인의 목적은 단순 CN/AD 분류 성능 경쟁이 아니다. 목표는 다음이다.

> FastSurfer/ROI morphology에서 나온 disease-relevant teacher geometry를 T1w voxel-only image student가 얼마나 안정적으로 학습하고, 그 frozen representation이 cohort-held-out CN/AD probe에서 baseline image model을 넘을 수 있는지 검증한다.

즉 현재 gate들은 VLM 본실험 전에 필요한 representation-readiness gate다.

- Teacher input: ROI summary features, 특히 `no_voxel_count` Teacher-S.
- Student input: T1w `final_tensor` voxel only.
- 금지 input: ROI scalar 직접 입력, cohort/scanner/diagnosis/PET/CDR/biomarker, age/sex는 Teacher-B diagnostic 외에는 사용하지 않음.
- 평가: leave-one-cohort-out, heldout cohort별 AUC/bACC, frozen embedding probe, predicted ROI probe, direct student head.

핵심 질문:

1. ROI teacher 자체가 CN/AD signal을 갖는가?
2. T1w image student가 그 teacher geometry를 복원하는가?
3. 복원된 representation이 direct image baseline인 `baseline_06`보다 cohort-held-out에서 안정적으로 나은가?
4. 실패가 teacher ceiling 문제인지, student transfer 문제인지, 구조 문제인지 분리 가능한가?

---

## 2. Baseline 기준

비교 기준은 `baseline_06_3d_cnn_loco_cn_vs_ad`다.

경로:

```text
/home/vlm/minyoungi/experiments/voxelwise_feature_learning_v1/baselines/baseline_06_3d_cnn_loco_cn_vs_ad/metrics_leave_one_cohort_out.csv
```

Baseline06 평균:

| Metric | Value |
|---|---:|
| mean AUC | 0.8087 |
| mean bACC | 0.7146 |

Fold별 baseline06:

| Heldout | AUC | bACC |
|---|---:|---:|
| ADNI | 0.7572 | 0.6952 |
| AIBL | 0.8576 | 0.7827 |
| AJU | 0.8081 | 0.6495 |
| KDRC | 0.8395 | 0.7543 |
| NACC | 0.7968 | 0.7275 |
| OASIS | 0.7932 | 0.6786 |

중요: `baseline_06`은 직접 supervised image-only CNN이다. Teacher-student 방법이 이 baseline을 넘지 못하면, VLM scaling claim으로 넘어가면 안 된다.

---

## 3. Gate02 실패 진단의 출발점

Gate02 `no_voxel_count` ROI→image distillation은 ROI imitation은 train-mean baseline보다 나았지만, frozen embedding probe는 baseline06을 안정적으로 넘지 못했다. 이후 Gate03–05a는 이 실패 원인을 줄이기 위한 연속 실험이다.

Gate02 failure diagnostic 핵심 수치:

| Representation | mean heldout-CV AUC | mean train→heldout AUC | 해석 |
|---|---:|---:|---|
| True ROI teacher | 0.8847 | 0.8678 | ROI summary에는 강한 CN/AD signal 존재 |
| Predicted ROI head | 0.7419 | 0.7345 | student가 ROI disease-axis를 충분히 복원 못함 |
| CLS/image embedding | 0.7779 | 0.7491 | frozen image representation도 teacher보다 낮음 |

Fold별 핵심:

- ADNI: true ROI는 강하지만 predicted ROI/CLS가 train→heldout에서 낮음.
- AJU: predicted ROI train→heldout AUC 0.8150으로 비교적 teacher에 가까움.
- KDRC: true ROI train→heldout AUC 0.8834로 강하지만 predicted ROI train→heldout AUC 0.6770으로 크게 무너짐.

Gate02 결론:

> 실패 원인은 teacher ceiling 부족이 아니라, class-relevant ROI teacher geometry를 T1w image student가 단순 ROI regression으로 충분히 전달하지 못한 것이다.

따라서 이후 실험은 ROI z MSE만 반복하는 것이 아니라 Teacher-S logit/latent distillation, CE anchor, ROI-aware spatial structure를 단계적으로 테스트했다.

---

## 4. Gate별 핵심 결과

### 4.1 Gate03 — Teacher-S logit/latent distillation

경로:

```text
results/vlm_gate_03_teacher_logit_latent_distillation_v0_selected/
```

설정:

- selected folds: ADNI, AJU, KDRC
- variants: `hard_label_ce`, `teacher_kl`, `teacher_latent_kl`, `teacher_latent_kl_roi_aux`

평균 variant 결과:

| Variant | mean frozen AUC | mean frozen bACC | mean Δ baseline06 AUC | 해석 |
|---|---:|---:|---:|---|
| teacher_kl | 0.8118 | 0.7139 | +0.0101 | 평균 AUC best |
| teacher_latent_kl_roi_aux | 0.7994 | 0.7336 | -0.0023 | bACC/ROI alignment은 좋지만 AUC 낮음 |
| teacher_latent_kl | 0.7757 | 0.6942 | -0.0259 | ADNI에는 좋지만 fold-dependent |
| hard_label_ce | 0.7601 | 0.7112 | -0.0415 | 평균 약함, KDRC에서는 상대적으로 도움 |

Fold별 best:

| Fold | Best variant | frozen AUC | baseline06 AUC | Δ baseline06 |
|---|---|---:|---:|---:|
| ADNI | teacher_latent_kl | 0.8301 | 0.7572 | +0.0729 |
| AJU | teacher_kl | 0.8609 | 0.8081 | +0.0528 |
| KDRC | hard_label_ce | 0.8094 | 0.8395 | -0.0302 |

판정:

- Gate02 대비 명확한 개선.
- 하지만 KDRC가 baseline06을 넘지 못해 selected-fold partial/near pass.
- Teacher-S logit KL은 유효하지만 KDRC에는 supervised disease-boundary anchor가 필요할 가능성이 드러남.

---

### 4.2 Gate03b — CE + Teacher-S KL mixed objective

경로:

```text
results/vlm_gate_03b_ce_teacher_kl_mixed_v0_selected/
```

설정:

- selected folds: ADNI, AJU, KDRC
- variants: `ce_plus_teacher_kl_0.5`, `ce_plus_teacher_kl_1.0`, `ce_plus_teacher_kl_latent_0.25`, `ce_plus_teacher_kl_roi_aux_0.05`

평균 variant 결과:

| Variant | mean frozen AUC | mean frozen bACC | mean Δ baseline06 AUC | 해석 |
|---|---:|---:|---:|---|
| ce_plus_teacher_kl_latent_0.25 | 0.7847 | 0.7020 | -0.0169 | KDRC에 좋지만 평균 낮음 |
| ce_plus_teacher_kl_roi_aux_0.05 | 0.7736 | 0.7116 | -0.0280 | direct AUC는 좋지만 frozen AUC 약함 |
| ce_plus_teacher_kl_0.5 | 0.7696 | 0.7101 | -0.0321 | 평균 약함 |
| ce_plus_teacher_kl_1.0 | 0.7665 | 0.6880 | -0.0351 | 안정적이지 않음 |

Fold별 best:

| Fold | Best variant | frozen AUC | baseline06 AUC | Δ baseline06 |
|---|---|---:|---:|---:|
| ADNI | ce_plus_teacher_kl_roi_aux_0.05 | 0.7977 | 0.7572 | +0.0404 |
| AJU | ce_plus_teacher_kl_latent_0.25 | 0.7571 | 0.8081 | -0.0510 |
| KDRC | ce_plus_teacher_kl_latent_0.25 | 0.8440 | 0.8395 | +0.0045 |

판정:

- KDRC 병목을 줄이는 방향에서는 성공.
- 그러나 ADNI/AJU를 희생해서 global replacement로는 부적절.
- 최적 objective가 fold-dependent임이 명확해졌다.

---

### 4.3 Gate03c — Objective robustness selected-fold

경로:

```text
results/vlm_gate_03c_objective_robustness_v0_selected/
```

설정:

- selected folds: ADNI, AJU, KDRC
- variants: `teacher_kl_repeat`, `ce0.1_plus_teacher_kl`, `ce0.25_plus_teacher_kl`, `teacher_kl_latent0.1`, `ce0.1_plus_teacher_kl_latent0.1`

평균 variant 결과:

| Variant | mean frozen AUC | mean frozen bACC | mean Δ baseline06 AUC | 해석 |
|---|---:|---:|---:|---|
| ce0.1_plus_teacher_kl | 0.8307 | 0.7378 | +0.0291 | selected-fold best universal recipe |
| teacher_kl_repeat | 0.8017 | 0.7139 | +0.0001 | 안정적이나 성능 낮음 |
| ce0.25_plus_teacher_kl | 0.8003 | 0.7070 | -0.0014 | CE가 너무 강하면 KDRC 해침 |
| teacher_kl_latent0.1 | 0.7932 | 0.7056 | -0.0084 | fold-dependent |
| ce0.1_plus_teacher_kl_latent0.1 | 0.7562 | 0.6821 | -0.0454 | 실패 |

Fold별 best:

| Fold | Best variant | frozen AUC | baseline06 AUC | Δ baseline06 |
|---|---|---:|---:|---:|
| ADNI | teacher_kl_latent0.1 | 0.8262 | 0.7572 | +0.0689 |
| AJU | ce0.25_plus_teacher_kl | 0.8673 | 0.8081 | +0.0592 |
| KDRC | ce0.1_plus_teacher_kl | 0.8443 | 0.8395 | +0.0048 |

`ce0.1_plus_teacher_kl` 기준:

- mean frozen AUC: 0.8307
- mean frozen bACC: 0.7378
- mean Δ baseline06 AUC: +0.0291
- ADNI/AJU/KDRC 모두 baseline06 AUC 이상

판정:

- selected folds에서는 strong pass.
- 이 시점에서 `Teacher-S KL + 0.1 * hard-label CE`가 full LOCO 확장 후보가 됐다.
- 단, selected-fold success가 full-fold success를 보장하지 않는다는 위험은 남아 있었다.

---

### 4.4 Gate04 — Full 6-fold LOCO, Teacher-S KL + 0.1 CE

경로:

```text
results/vlm_gate_04_full_loco_teacher_s_kl_ce01_v0_seed42_stable/
```

설정:

- folds: ADNI, AIBL, AJU, KDRC, NACC, OASIS
- variant: `ce0.1_plus_teacher_kl`
- stable seed reset 적용 후 재실행한 결과 기준

평균:

| Metric | Value |
|---|---:|
| teacher AUC | 0.8643 |
| direct AUC | 0.8115 |
| frozen AUC | 0.8159 |
| frozen bACC | 0.7288 |
| predicted ROI probe AUC | 0.8241 |
| mean Δ baseline06 AUC | +0.0071 |

Fold별:

| Fold | Teacher AUC | frozen AUC | frozen bACC | predROI AUC | baseline06 AUC | Δ baseline06 |
|---|---:|---:|---:|---:|---:|---:|
| ADNI | 0.8812 | 0.8074 | 0.7429 | 0.8082 | 0.7572 | +0.0502 |
| AIBL | 0.9251 | 0.8814 | 0.8047 | 0.8712 | 0.8576 | +0.0237 |
| AJU | 0.8712 | 0.7939 | 0.6515 | 0.8392 | 0.8081 | -0.0142 |
| KDRC | 0.8856 | 0.8529 | 0.7732 | 0.8556 | 0.8395 | +0.0134 |
| NACC | 0.8015 | 0.7597 | 0.6896 | 0.7704 | 0.7968 | -0.0371 |
| OASIS | 0.8210 | 0.7999 | 0.7108 | 0.7999 | 0.7932 | +0.0067 |

판정:

- Full LOCO 평균은 baseline06보다 소폭 높다.
- ADNI/AIBL/KDRC/OASIS는 baseline06 AUC 이상.
- AJU/NACC는 baseline06 미달.
- 특히 NACC는 Teacher-S ceiling 자체가 낮다: Teacher AUC 0.8015, baseline06 AUC 0.7968.

보수적 결론:

> Gate04는 partial pass다. 평균과 일부 fold는 개선되지만, AJU/NACC 미달 때문에 full success가 아니다.

---

### 4.5 Gate04b — NACC/AJU robustness + Teacher-B diagnostic

경로:

```text
results/vlm_gate_04b_nacc_aju_robustness_teacher_b_v0_seed42_workers0/
```

설정:

- folds: NACC, AJU, KDRC, OASIS
- variants: `teacher_kl_repeat`, CE weight ladder, `teacher_b_ce0.1_plus_teacher_kl`
- Teacher-B: ROI + age/sex privileged diagnostic teacher
- 첫 실행은 `Too many open files`로 중단, 동일 조건을 `num_workers=0`으로 완료.

평균 variant 결과:

| Variant | mean frozen AUC | mean frozen bACC | mean Δ baseline06 AUC | 해석 |
|---|---:|---:|---:|---|
| ce0.05_plus_teacher_kl | 0.8116 | 0.7341 | +0.0022 | 4-fold 평균 best |
| teacher_kl_repeat | 0.8003 | 0.7194 | -0.0091 | OASIS에 좋음, 평균 부족 |
| ce0.25_plus_teacher_kl | 0.7933 | 0.6956 | -0.0161 | AJU 좋지만 NACC 약함 |
| ce0.15_plus_teacher_kl | 0.7709 | 0.7094 | -0.0385 | 낮음 |
| ce0.1_plus_teacher_kl | 0.7692 | 0.6978 | -0.0401 | Gate04와 다르게 약함 |
| teacher_b_ce0.1_plus_teacher_kl | 0.7671 | 0.6952 | -0.0422 | teacher ceiling은 올리나 transfer 실패 |

Fold별 best:

| Fold | Best variant | frozen AUC | baseline06 AUC | Δ baseline06 | 해석 |
|---|---|---:|---:|---:|---|
| AJU | ce0.25_plus_teacher_kl | 0.8580 | 0.8081 | +0.0499 | rescue 성공 |
| KDRC | ce0.1_plus_teacher_kl | 0.8305 | 0.8395 | -0.0089 | Gate04보다 약화 |
| NACC | ce0.15_plus_teacher_kl | 0.7900 | 0.7968 | -0.0068 | teacher ceiling 근접, baseline 미달 |
| OASIS | teacher_kl_repeat | 0.8092 | 0.7932 | +0.0160 | pass |

Teacher-B 진단:

- NACC Teacher-B AUC는 0.8290으로 Teacher-S 0.8015보다 높다.
- 하지만 Teacher-B student frozen AUC는 0.7812로 NACC best 0.7900보다 낮다.
- KDRC에서는 Teacher-B frozen AUC가 0.6924로 크게 나빠졌다.

판정:

- AJU는 CE tuning으로 rescue 가능.
- NACC는 Teacher-S ceiling 근처까지는 가지만 baseline06을 안정적으로 넘지 못함.
- Teacher-B는 teacher ceiling을 올려도 T1w-only student transfer를 보장하지 않는다.
- KDRC는 Gate04 single run에서 보인 rescue가 불안정하다는 신호가 생김.

---

### 4.6 Gate04c — KDRC-only seed-repeat reproducibility

경로:

```text
results/vlm_gate_04c_kdrc_reproducibility_v0/
```

설정:

- heldout fold: KDRC only
- seeds: 42, 43, 44
- variants: `teacher_kl_repeat`, `ce0.05_plus_teacher_kl`, `ce0.1_plus_teacher_kl`, `ce0.15_plus_teacher_kl`

핵심 결과:

| Variant | mean frozen AUC | std | min/max | mean Δ baseline06 AUC | baseline pass count |
|---|---:|---:|---:|---:|---:|
| ce0.1_plus_teacher_kl | 0.8080 | 0.0233 | 0.7810 / 0.8225 | -0.0315 | 0/3 |
| teacher_kl_repeat | 0.7991 | 0.0058 | 0.7931 / 0.8047 | -0.0404 | 0/3 |
| ce0.15_plus_teacher_kl | 0.7885 | 0.0135 | 0.7755 / 0.8024 | -0.0510 | 0/3 |
| ce0.05_plus_teacher_kl | 0.7850 | 0.0132 | 0.7700 / 0.7947 | -0.0545 | 0/3 |

KDRC baseline06 AUC: 0.8395.

판정:

> KDRC rescue는 seed-repeat 기준으로 재현되지 않았다.

해석:

- `ce0.1_plus_teacher_kl`은 여전히 상대적으로 best지만 baseline06을 못 넘는다.
- Gate04의 KDRC 0.8529는 단일 run 관찰로 보류해야 한다.
- KDRC는 Teacher-S AUC가 약 0.887로 높기 때문에 teacher ceiling 문제가 아니라 student representation transfer 문제다.

---

### 4.7 Gate04d — KDRC transfer diagnostic

경로:

```text
results/vlm_gate_04d_kdrc_transfer_diagnostic_v0/
```

상태:

- 초기 `REPORT_KO.md`는 partial summary였고, CPU image inference가 병목이었다.
- 현재 존재하는 diagnostic summary는 Gate04c seed summary 기반의 5-way 일부 지표다.

핵심 지표:

| Representation | AUC mean | AUC std | bACC mean | 해석 |
|---|---:|---:|---:|---|
| teacher_s_loaded_model | 0.8870 | 0.0018 | 0.8162 | teacher는 강함 |
| predicted_roi_head_probe | 0.8122 | 0.0200 | 0.7324 | baseline06보다 낮음 |
| global_pooled_embedding_probe | 0.8080 | 0.0233 | 0.7386 | baseline06보다 낮음 |
| student_direct_head | 0.7997 | 0.0206 | 0.7324 | baseline06보다 낮음 |

KDRC baseline06 AUC: 0.8395.

판정:

- KDRC에서는 teacher 자체는 강하다.
- predicted ROI head, global pooled embedding, direct head 모두 teacher와 baseline06에 못 미친다.
- 따라서 `global pooling only` 문제라고 단정할 수 없다.
- 현재는 mixed bottleneck이다: ROI teacher disease-axis transfer, image-student representation geometry, 구조적 pooling 한계가 함께 얽혀 있을 가능성이 높다.
- row-level confidence/error profile과 AD/CN cosine split 없이는 고신뢰 miss pattern을 결론내리면 안 된다.

---

### 4.8 Gate05a — ROI-aware spatial upper-bound

경로:

```text
results/vlm_gate_05a_roi_aware_spatial_upperbound_v0_full_parallel/
```

설정:

- folds: ADNI, AIBL, AJU, KDRC, NACC, OASIS
- variants:
  - `m0_global_same_loss`: 기존 global pooling 구조, 동일 loss
  - `m1_roi_pool_same_loss`: ROI-aware pooling, 동일 loss
  - `m2_roi_pool_cosine`: ROI-aware pooling + cosine alignment
  - `m3_roi_token_cosine`: ROI token 방식 + cosine alignment
- 목적: 구조적 ROI-aware pooling이 transfer bottleneck을 줄이는지 upper-bound 성격으로 확인.

평균 variant 결과:

| Variant | direct AUC | direct bACC | frozen AUC | frozen bACC | predROI AUC | ROI cosine | mean Δ baseline06 AUC | 판정 |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| m0_global_same_loss | 0.8118 | 0.7167 | 0.8061 | 0.7220 | 0.8096 | -0.0340 | -0.0026 | baseline 근처, 개선 아님 |
| m1_roi_pool_same_loss | 0.8231 | 0.7231 | 0.8029 | 0.7390 | 0.8148 | 0.0155 | -0.0058 | direct/bACC는 좋지만 frozen AUC 낮음 |
| m2_roi_pool_cosine | 0.8169 | 0.7184 | 0.8123 | 0.7382 | 0.8177 | 0.4702 | +0.0036 | 평균상 최선, 약한 partial pass |
| m3_roi_token_cosine | 0.7784 | 0.6639 | 0.7760 | 0.7010 | 0.7769 | 0.3770 | -0.0327 | 실패 |

`m2_roi_pool_cosine` fold별 결과:

| Fold | Teacher AUC | frozen AUC | frozen bACC | predROI AUC | ROI cosine | baseline06 AUC | Δ baseline06 |
|---|---:|---:|---:|---:|---:|---:|---:|
| ADNI | 0.8812 | 0.8022 | 0.7506 | 0.7877 | 0.1109 | 0.7572 | +0.0450 |
| AIBL | 0.9251 | 0.8354 | 0.7571 | 0.8425 | 0.7829 | 0.8576 | -0.0223 |
| AJU | 0.8712 | 0.8408 | 0.7221 | 0.8431 | 0.6233 | 0.8081 | +0.0328 |
| KDRC | 0.8856 | 0.8464 | 0.7640 | 0.8395 | 0.5019 | 0.8395 | +0.0069 |
| NACC | 0.8015 | 0.7494 | 0.6976 | 0.7777 | -0.0191 | 0.7968 | -0.0474 |
| OASIS | 0.8210 | 0.7999 | 0.7376 | 0.8160 | 0.8211 | 0.7932 | +0.0067 |

판정:

- `m2_roi_pool_cosine`이 평균 frozen AUC 0.8123으로 Gate05a 내 최고다.
- 하지만 baseline06 대비 평균 개선은 +0.0036에 불과하다.
- ADNI/AJU/KDRC/OASIS는 개선, AIBL/NACC는 악화.
- NACC는 여전히 가장 큰 failure fold다.
- `m3_roi_token_cosine`은 현재 구조/학습 조건에서 명확히 실패다.

보수적 결론:

> ROI-aware pooling + cosine alignment는 약한 긍정 신호가 있지만, fold-wise 안정성을 해결하지 못했다. m2만 다음 구조 실험 후보로 남길 수 있고, m3는 버리는 것이 맞다.

---

## 5. 통합 병목 분석

### 5.1 해결된 것

1. 단순 ROI z regression만으로는 부족하다는 점이 확인됐다.
   - Gate02 failure diagnostic에서 true ROI teacher는 강하지만 predicted ROI/CLS가 낮았다.

2. Teacher-S logit distillation은 의미 있는 개선 방향이다.
   - Gate03 `teacher_kl` mean frozen AUC 0.8118.
   - Gate02 대비 약 +0.0616 개선.

3. Small CE anchor는 일부 fold에서 disease-boundary transfer를 돕는다.
   - Gate03c `ce0.1_plus_teacher_kl` selected 3-fold mean frozen AUC 0.8307.
   - ADNI/AJU/KDRC 모두 selected 조건에서 baseline06 이상.

4. AJU는 objective tuning으로 rescue 가능하다.
   - Gate04b best AJU: `ce0.25_plus_teacher_kl`, frozen AUC 0.8580, Δ baseline06 +0.0499.

5. ROI-aware spatial pooling은 완전히 무의미하지 않다.
   - Gate05a `m2_roi_pool_cosine`은 평균상 best이고 ROI cosine이 크게 개선됐다.
   - 하지만 effect size는 작다.

### 5.2 아직 unresolved인 것

#### NACC teacher ceiling / data distribution 문제

NACC는 다른 fold와 다르다.

- Gate04 Teacher-S AUC: 0.8015
- baseline06 AUC: 0.7968
- Gate04 frozen AUC: 0.7597
- Gate04b best frozen AUC: 0.7900
- Gate05a m2 frozen AUC: 0.7494

해석:

- NACC에서는 Teacher-S 자체가 baseline06보다 크게 강하지 않다.
- Student가 teacher를 따라가도 baseline06을 넘기 어렵다.
- Teacher-B는 teacher ceiling을 0.8290까지 올렸지만 student transfer를 개선하지 못했다.
- 따라서 NACC는 단순 구조 변경보다 teacher definition, cohort/site/QC, ROI harmonization, label/class distribution 분석이 먼저다.

#### KDRC transfer gap

KDRC는 NACC와 반대다.

- Teacher-S AUC는 약 0.887로 강하다.
- 그러나 Gate04c seed-repeat best 평균 frozen AUC는 0.8080으로 baseline06 0.8395보다 낮다.
- Gate04 단일 run의 KDRC 0.8529는 재현되지 않았다.
- Gate04d에서 predicted ROI head/global embedding/direct head 모두 teacher와 baseline06 사이 gap이 남았다.

해석:

- KDRC는 teacher ceiling 문제가 아니라 image student transfer 문제다.
- CE anchor는 상대적으로 도움되지만 충분하지 않다.
- 구조, optimization, ROI disease-axis transfer, row-level high-confidence miss pattern을 더 분해해야 한다.

#### AIBL의 Gate05a 악화

Gate04에서는 AIBL이 pass였다.

- Gate04 AIBL frozen AUC: 0.8814, Δ baseline06 +0.0237

하지만 Gate05a m2에서는 악화됐다.

- Gate05a m2 AIBL frozen AUC: 0.8354, Δ baseline06 -0.0223

해석:

- ROI-aware pooling/cosine이 모든 cohort에 universal하게 좋은 구조는 아니다.
- AIBL은 teacher ceiling이 높고 기존 Gate04 transfer가 좋았기 때문에, ROI-local forcing이 오히려 global discriminative signal을 희생했을 가능성이 있다.

#### AD-specific fragility / class-wise issue

현재 많은 요약은 AUC 중심이다. bACC와 class-wise recall/F1이 fold별로 엇갈린다.

예:

- Gate05a m2 ADNI frozen bACC는 0.7506으로 좋지만, AIBL/NACC의 bACC는 baseline 대비 확인이 필요하다.
- Gate04 AJU는 AUC가 baseline보다 낮지만 bACC는 baseline 근처였다.

따라서 다음 보고에는 AD recall, CN recall, precision/AP, confidence error profile이 필요하다. AUC만으로 “임상적으로 더 좋다”고 말하면 안 된다.

---

## 6. 현재까지의 결론

### 6.1 가장 보수적인 scientific statement

> ROI-derived Teacher-S supervision은 T1w image representation을 개선하는 방향성이 있으며, selected folds에서는 Teacher-S KL + small CE anchor가 baseline image CNN을 넘는 강한 결과를 보였다. 그러나 full LOCO와 seed-repeat에서는 성능이 cohort-specific하게 불안정했고, NACC는 teacher ceiling 자체가 낮으며, KDRC는 teacher는 강하지만 image student transfer가 재현성 있게 baseline을 넘지 못했다. ROI-aware pooling + cosine alignment는 약한 추가 신호를 보였지만 fold-wise 안정성 문제를 해결하지 못했다.

### 6.2 지금 하지 말아야 할 claim

다음 주장은 아직 하면 안 된다.

1. “ROI-aware VLM representation이 baseline을 안정적으로 이긴다.”
   - 틀림. Gate05a m2 평균 개선은 +0.0036이고 AIBL/NACC가 악화됐다.

2. “KDRC rescue가 해결됐다.”
   - 틀림. Gate04 단일 run에서는 보였지만 Gate04c 3-seed repeat에서 재현되지 않았다.

3. “Teacher-B가 NACC 해결책이다.”
   - 틀림. Teacher-B는 NACC teacher AUC를 올렸지만 student frozen AUC는 개선하지 못했다.

4. “global pooling만 문제다.”
   - 아직 단정 불가. Gate04d와 Gate05a 결과는 mixed bottleneck을 시사한다.

5. “VLM scaling으로 바로 가자.”
   - 아직 이르다. representation-readiness gate가 full pass하지 않았다.

---

## 7. 다음 단계 제안

Min의 제안대로 **둘 다**가 맞다. 순서는 반드시 Path B → Path A다.

### Path B 먼저: 연구 재정비

이미 이 문서가 첫 단계다. 다음으로 해야 할 정리 작업은 다음이다.

1. Gate03–05a result registry 정리
   - 각 gate의 `selected_fold_variant_metrics.csv`, `summary_aggregated.json`, `REPORT_KO.md` 경로를 하나의 index에 연결.

2. Fold-specific challenge map 작성
   - ADNI: latent/geometry alignment 반응 좋음.
   - AIBL: Gate04 transfer 좋지만 Gate05a ROI-local forcing에서 악화.
   - AJU: CE tuning으로 rescue 가능, teacher signal 충분.
   - KDRC: teacher strong, student transfer unstable.
   - NACC: teacher ceiling/data distribution 문제.
   - OASIS: near/pass, 비교적 안정적이나 ceiling 높지 않음.

3. Row-level diagnostic gap 채우기
   - 특히 KDRC와 NACC에 대해 confidence error profile, AD/CN recall, high-confidence miss, class-wise cosine을 봐야 한다.

4. 논문/제안서 스토리 초안
   - “ROI teacher → image student transfer is possible but cohort-specific failure modes dominate.”
   - VLM 본실험은 이 gate를 통과한 뒤 진행.

### Path A는 그 다음: m2 기반 추가 개선

Gate05a 이후 바로 대형 sweep을 돌리면 안 된다. m2의 신호가 너무 약하다. m2 개선은 다음처럼 좁혀야 한다.

우선순위 높은 실험:

1. `m2` seed repeat on selected hard folds
   - folds: KDRC, NACC, AIBL
   - 목적: m2 평균 +0.0036이 noise인지 구조 신호인지 확인.
   - pass 기준: fold별 baseline06 초과 seed count, mean Δ AUC, std.

2. NACC teacher/data audit before Teacher-B retrial
   - Teacher-S vs Teacher-B calibration
   - class count/site/scanner/age/sex distribution
   - ROI feature distribution and harmonization check
   - baseline06 prediction overlap

3. KDRC row-level transfer diagnostic completion
   - Gate04d full row-level profile 재실행 또는 cached feature 활용.
   - teacher high-confidence rows에서 student miss pattern 확인.

4. m2 loss tuning은 작게
   - ROI cosine temperature 또는 weight만 2–3개 값.
   - AD/CN class-aware cosine weighting은 NACC/KDRC diagnostic 후에만 실행.
   - multi-scale ROI pooling은 구조 변화가 커서 seed repeat 전에는 premature.

낮은 우선순위 또는 보류:

- Teacher-B를 NACC에만 바로 적용하는 것: teacher ceiling은 올라가도 transfer 실패 가능성이 이미 확인됐다.
- Multi-scale ROI pooling: 구조 복잡도 증가 대비 현재 m2 신호가 약하다.
- m3 ROI token 확장: 현재 Gate05a에서 실패했으므로 보류.

---

## 8. 즉시 추천 액션

1. 이 문서를 기준으로 Gate03–05a 결과를 고정한다.
2. `EXPERIMENT_INDEX.md` 또는 별도 registry에 Gate03–05a 요약 경로를 추가한다.
3. KDRC/NACC row-level diagnostics를 먼저 완성한다.
4. 그 다음에만 `m2` selected hard-fold seed repeat를 설계한다.

현재 결론은 “성능 개선을 더 해보자”가 아니라 다음이다.

> 지금까지의 결과는 m2를 버리기에는 아깝지만, m2를 믿고 scaling하기에는 약하다. 먼저 cohort-specific failure mode를 문서화하고, m2 seed repeat와 NACC/KDRC 진단을 통해 구조 신호인지 noise인지 분리해야 한다.
