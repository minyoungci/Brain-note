# I02 — Amyloid-from-MRI: representation-robust null + morphometry-oracle taxonomy

## 무엇을 시도했나
non-circular 탈출구로 amyloid 양성(PET 측정, 이미지 비유도) VQA. image-only 3D CNN, strict
LOCO(cross-site/tracer/ethnicity), 4코호트 3,383세션. 5개 표현 regime: from-scratch(w16/w32),
brain-age 사전학습(MAE 4.40yr), ROI-volume 사전학습("학습된 morphometry"), 각각 ft+frozen.

## 어디서/왜 정체했나 (실패 지점)
- **morphometry는 amyloid에 oracle가 아님(0.71)** → circularity는 깼으나,
- **교란 없는 CN에서 image가 age+APOE 너머 더하는 값 = +0.002 (≈0)**. dx-층화로 드러남:
  pooled의 "신호"는 dx/atrophy/age 교란. age-matched CN 200-draw에서 모든 image arm CI가
  0.5 포함(chance), morphometry만 0.55–0.58.
- 강한 표현(brain-age MAE 4.40yr = morphometry급)도 못 넘음 → "약한 추출기" 아님.
- ROI-volume을 재현하도록 명시 학습한 표현조차 0.653으로 morphometry 0.665에 근접만.
- permutation null 0.51 → leakage 없음 / APOE-from-MRI ≈ chance(유전형 구조 비예측).

## 재사용 가능한 인사이트
1. **morphometry-oracle 진단축**: task를 (a) morphometry=oracle(해부 질문, 위 headroom 0),
   (b) morphometry≈clinical≈chance(분자 질문 교란 없는 stratum, 모든 headroom 0)로 분류.
   중간지대 "win"은 dx/age 교란일 가능성 높음. **새 task의 morphometry-oracle AUC를 먼저 재라.**
2. **null을 주장하려면 표현 강도를 통제하라**: from-scratch null은 "약한 추출기" 반론에 약하다.
   강한 사전학습 표현(brain-age/foundation)에서도 null이면 modality 천장으로 결론 가능.
3. **dx/age 교란이 분자 예측을 부풀린다**: 반드시 dx-층화(CN 별도) + age(+sex)-matched 다중-draw로
   정직한 stratum을 보고. pooled AUC는 헤드라인 금지.
4. **A4 같은 enrollment-편향 코호트(전부 양성)는 binary에서 제외**(순수 site shortcut).
5. permutation null은 leakage의 결정적 sanity — 항상 돌려라.

## 증거/포인터
- `results/amyloid_vision/RESULTS_AMYLOID.md` (R1–R7), `BASELINE_BAR.md`,
  `CN_MULTIDRAW_ARMS.md`, `IMAGE_VS_MORPHO.md`. 스크립트 `scripts/run_amyloid_vision.py` 등.
