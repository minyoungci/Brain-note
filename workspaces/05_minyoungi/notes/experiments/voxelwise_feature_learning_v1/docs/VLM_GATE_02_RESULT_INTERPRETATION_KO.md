# VLM Gate 02 결과 해석 — ROI→Image Distillation v0

작성 시점: 2026-05-26

## 실행 요약

VLM으로 바로 가기 전에, T1w-only 3D image encoder가 ROI-summary teacher signal을 학습할 수 있는지 selected folds에서 확인했다.

실행 folds:

- ADNI
- AJU
- KDRC

두 조건을 실행했다.

1. `with_voxel_count`: ROI summary 전체 사용
2. `no_voxel_count`: `roi_voxel_count__*` 제외

공통:

- input: T1w `final_tensor` voxel array only
- teacher target: baseline_03 ROI summary z-vector
- no diagnosis/cohort/scanner/age/sex/PET/CDR/biomarker input
- leakage audit: all pass

## 주요 결과

### with_voxel_count

- all leakage pass: true
- all ROI imitation beats train mean: true
- mean ROI MSE relative improvement: 0.2478
- mean frozen-probe ROC-AUC: 0.7350
- mean frozen-probe bACC: 0.6411
- mean probe AUC minus baseline_06 direct image: -0.0666
- mean probe bACC minus baseline_06 direct image: -0.0586

Fold별:

- ADNI: probe AUC 0.7339 vs baseline_06 0.7572
- AJU: probe AUC 0.7674 vs baseline_06 0.8081
- KDRC: probe AUC 0.7036 vs baseline_06 0.8395

### no_voxel_count

- all leakage pass: true
- all ROI imitation beats train mean: true
- mean ROI MSE relative improvement: 0.2654
- mean frozen-probe ROC-AUC: 0.7501
- mean frozen-probe bACC: 0.6872
- mean probe AUC minus baseline_06 direct image: -0.0515
- mean probe bACC minus baseline_06 direct image: -0.0125

Fold별:

- ADNI: probe AUC 0.7136 vs baseline_06 0.7572
- AJU: probe AUC 0.7794 vs baseline_06 0.8081, bACC 0.7137 vs baseline_06 0.6495
- KDRC: probe AUC 0.7574 vs baseline_06 0.8395

## 해석

### 1. ROI imitation 자체는 성공했다

두 조건 모두 selected 3 folds에서 train-mean baseline보다 낮은 ROI z MSE를 달성했다.

즉, image encoder는 T1w image만 보고 ROI-summary teacher signal의 일부를 학습할 수 있다.

이건 VLM/ROI-grounded representation 방향에 긍정적인 결과다.

### 2. 하지만 frozen CN/AD probe는 baseline_06 direct image보다 아직 약하다

ROI imitation은 되었지만, frozen embedding probe는 baseline_06의 supervised direct image classifier보다 낮다.

이 뜻은 다음과 같다.

- ROI target prediction success != task-relevant representation success
- 단순 ROI regression objective만으로는 CN/AD decision geometry가 충분히 좋아지지 않는다.
- VLM scaling으로 바로 가면 representation bottleneck을 그대로 가져갈 가능성이 있다.

### 3. no_voxel_count 조건이 더 낫다

`no_voxel_count`가 with_voxel_count보다 평균적으로 더 좋다.

- mean probe AUC: 0.7350 → 0.7501
- mean probe bACC: 0.6411 → 0.6872
- AJU bACC는 baseline_06보다 개선됨: 0.6495 → 0.7137

해석:

- voxel_count/volume shortcut을 직접 맞추는 것보다, intensity/summary morphology 쪽 target이 representation에는 더 안정적일 수 있다.
- 그러나 KDRC/ADNI에서는 여전히 direct supervised image baseline보다 낮다.

## 현재 판단

Gate 02는 partial pass다.

Pass한 것:

- leakage audit pass
- ROI imitation beats train-mean baseline
- no_voxel_count ablation이 더 유망함

Fail/보류인 것:

- frozen embedding probe가 baseline_06 direct image를 일관되게 넘지 못함
- ROI regression만으로는 VLM-ready representation이라고 보기 어려움

## 다음 추천

바로 대형 VLM으로 가지 말고 다음 objective ladder를 진행한다.

1. `no_voxel_count` 유지
2. ROI z regression only 대신 teacher-logit/latent objective 추가
3. supervised hard-label CE와 distillation을 분리 비교
4. frozen probe뿐 아니라 direct linear head도 함께 보고
5. ADNI/AJU/KDRC selected folds에서 먼저 확인 후 full LOCO 확장

다음 실험 이름 제안:

`vlm_gate_03_teacher_logit_latent_distillation_v0`

핵심 질문:

> ROI summary teacher의 class-relevant latent/logit signal을 image encoder가 더 잘 흡수하면, frozen CN/AD LOCO probe가 baseline_06 direct image gap을 줄일 수 있는가?

## 보수적 결론

T1w image encoder는 ROI morphology signal을 일부 학습할 수 있다. 그러나 단순 ROI regression distillation은 아직 supervised image-only baseline을 넘지 못했다. VLM으로 가기 전에는 `no_voxel_count + teacher-logit/latent distillation` gate를 한 번 더 통과해야 한다.
