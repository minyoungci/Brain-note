# Experimental Retrospective (2026-06-13) — toward genuinely novel technical research

세션 전체에서 *측정된* 사실만으로 깊은 기술 인사이트를 추출하고, 점령되지 않았을 *후보* 기술방향을 도출.
(문헌 점령 여부는 deep-research로 별도 검증 — 후보는 그 통과 후에만 확정.)

## 1. 측정된 하드 사실 (재논쟁 불가)
- **F-A** site=population, traveling-subject 0 → de-confounding(A·B)·harmonization·foundation-adaptation의 site 제거 *전부 실패*. cohort-AUC ~0.84 irreducible.
- **F-B** morphometry(30-d, ICV-정규화 ROI 부피)가 site-robust(LOCO 0.88) **AND** 모든 학습표현을 disease에서 능가.
- **F-C** 88M-param 학습 encoder(BrainIAC frozen/full, scratch, morpho-distill)가 morphometry보다 *더* site-loaded(0.84>0.77)이고 disease는 *동등 이하*.
- **F-D** 임상 라벨(dx/amyloid/cdr/brain-age) = morphometry-solved 또는 unlearnable(amyloid ΔAUC≈0).
- **F-E** full-FT ≫ frozen이나, foundation은 site를 주입(소량).
- **F-F** KDRC 멀티모달(T1+FLAIR+T2+DWI+PET) — 거의 미사용.
- **F-G** separability 메트릭 = 표준수학(principal-angle/concept-subspace), 점령됨. 결합법칙만 미확정.

## 2. 깊은 기술 인사이트 (사실들의 *교차*에서)
- **I-1 (표현학습 비효율 역설)**: 고용량 학습표현이 *동시에* (a) 더 site-loaded이고 (b) disease는 30-d 수제 feature보다 못함. → 작은-N 다site에서 deep capacity가 *전이가능 biology*가 아니라 *nuisance(site)*에 쓰임. **왜 morphometry가 이기나**: ICV-정규화(곱셈적 scanner gain 상쇄) + ROI-pooling(노이즈 평균) = *구조적* site-robustness. deep encoder엔 이 inductive bias가 없고 작은 N으론 학습 못 함.
- **I-2 (병목은 task-side지 data-side 아님)**: 데이터는 풍부, **라벨이 병목**. 새 연구는 *method*가 아니라 *target*을 바꿔야 함. "morphometry를 이긴다"는 라벨로는 불가.
- **I-3 (deep이 morphometry 너머로 *유일하게* 줄 수 있는 것 = FreeSurfer가 *버리는* 정보)**: shape·texture·asymmetry·subregional. 단 임상 라벨엔 이게 천장 너머로 도움 안 됨(측정). → 이 버려진 정보가 의미있으려면 *다른 target* 필요.
- **I-4 (한 번도 안 한 패러다임 = generative/counterfactual)**: 전부 discriminative(image→label)였음. site=population + 극단적 인구다양성(美·濠·韓)은 *생성모델의 population-shift 거동* 연구에 오히려 이상적 토대.
- **I-5 (방법론 메타교훈)**: deflation 메트릭은 calibration 실패, alignment는 통과; single-seed는 오도(#4). → *calibration·다seed가 결론을 뒤집음* = 우리 파이프라인의 검증 규율이 자산.

## 3. 후보 기술방향 (문헌 검증 *전* — deep-research 통과 시에만 채택)
| # | 아이디어 | 어느 인사이트 | 왜 novel일 수 있나 | 무엇이 죽일 수 있나 |
|---|---|---|---|---|
| **D-I** | **morphometry-biased 학습표현**: ICV-정규화 + 미분가능 soft-ROI pooling을 *아키텍처 prior*로 + residual stream. site-robust by construction + 초과 여지 | I-1,I-3 | deep<morphometry 역설을 *구조적으로* 해결; FreeSurfer-free·end-to-end | morpho-distill이 이미 fs_vol 재현(천장); residual이 임상라벨엔 무효일 위험. "direct volumetry"(SynthSeg/FastSurfer) 점령 가능 |
| **D-II** | **합성 traveling-subject 생성**: scanner-조건부 생성모델로 "이 뇌를 다른 site로 찍으면?" 반사실 렌더; 공개 traveling-subject(ON-Harmony/SRPBS)로 *검증* | I-4,F-A | 실제 여행피험자 없이 harmonization 검증을 *가능케*; 생성→실측 검증 결합 | 생성 harmonization(GAN/diffusion)은 혼잡; novelty=프레이밍에 의존 |
| **D-III** | **population-shift-aware selective prediction**: site 제거 대신, 모델이 *자기 신뢰불가 영역*(미관측 population)을 알고 기권. OOD-aware 배포 | I-1,F-A | 임상배포 안전성(다인구 AD모델); site=population을 *제거 대상*이 아니라 *불확실성 원천*으로 | OOD/selective prediction 일반론 점령; 신경영상 특화·인구조건부가 새로워야 |
| **D-IV** | **capacity-allocation 진단+개입**: deep이 capacity를 site vs biology에 *어떻게* 배분하는지 정량화하고, biology로 재배분하는 학습목표 | I-1,F-C | "왜 deep<morphometry"의 *기술적 해부+처방* | 처방이 실제로 morphometry를 넘어야 가치; 안 넘으면 또 negative |

## 4. 정직한 메타 판단
- 이 데이터의 *임상 라벨* 축은 소진됨(I-2). 살아있는 축 = **target 변경**(생성·자기-인식·표현구조).
- 후보 중 **D-I/D-IV(표현학습 역설의 구조적 해결)**가 측정된 사실(I-1)에 가장 직접 근거하나, "residual이 천장 못 넘으면 무효" 리스크가 있음 → *임상라벨이 아닌* shape-sensitive target이 필요.
- **D-II(생성 반사실)**는 패러다임이 새롭고 공개데이터로 검증 가능하나 혼잡 분야.
- 어느 것도 문헌 검증 전엔 "novel"이라 못 박지 않음 — separability에서 배운 교훈(메트릭이 점령됨).
→ deep-research 결과 + 후보별 정밀 lit 확인 후, *진짜 빈 자리*에 있는 1개를 기술 제안으로 확정.
