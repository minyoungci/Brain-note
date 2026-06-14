# 방법론 함정 — 재현 방지 체크리스트

> 우리(또는 형제 라인)를 실제로 문 함정들. 새 실험 설계·결과 해석 전 이 리스트를 본다.

## T1. 표현-수준 LOCO 누수 (★ 2026-06-11 우리를 문 것)
- **무엇:** 인코더를 *전체 코호트*로 사전학습한 뒤 frozen probe로 "LOCO" 평가 → 인코더가 held-out 코호트의 site 분포를 *이미 학습 시 봄*. probe head만 LOCO고 표현은 아님.
- **증상:** "image≈morph match"(0.662≈0.663)가 실제로는 누수 오염값. (P2-③, `stage1b_frozen_probe.py` + `diag_morph_regress.py` random 80/20.)
- **교훈:** 표현학습 단계도 **nested-LOCO** — 인코더 사전학습에서 held-out 코호트를 *반드시 제외*. probe만 LOCO로는 부족.
- **체크:** "내 표현(인코더/SSL/pretrain)이 held-out 코호트의 이미지를 학습 어디서든 봤나?" → yes면 그 평가는 무효.

## T2. Morph-distilled 순환논증 (★)
- **무엇:** morphometry(fs_vol)를 target으로 회귀 학습한 표현은 정의상 ≈morph. 그걸로 "image가 morph 너머를 가지나"를 물으면 **동어반복**(morph로 만든 표현이 morph를 안 넘는 게 당연).
- **교훈:** "beyond morph" 검정엔 **morph를 안 본 표현**(pure SSL 또는 task-supervised from-scratch/fine-tune)이 필요. morph-pretrain은 *init*으로만 쓰고 반드시 fine-tune해서 표현을 task로 갱신.
- **체크:** "내 표현이 morph를 직접 배웠나?" → yes면 그 표현의 morph-비교는 순환.

## T3. 약한-target 미결정성 (★)
- **무엇:** "image가 morph를 넘나"를 **morph가 약한 target**(amyloid morph 0.66, APOE 0.59)에서 물으면 무의미. "둘 다 약함"과 "천장"을 구별 못 함.
- **교훈:** (a)/(b)는 **morph가 *강한* target**(AD/CN 0.936)에서만 판정 가능. morph 강 + 모델이 morph 재현(R²↑) + image 미초과 = 진짜 천장.
- **함정 변종:** 분자·유전 target(amyloid/APOE)은 **T1w 모달리티 천장** — morph든 image든 안 됨(구조에 정보 없음). image로 옮긴다고 안 풀림.

## T4. underpowered ≠ equivalence
- **무엇:** "유의차 없음"을 "같다(match)"로 읽기. point estimate(Δ0.001)만으로 "동등" 주장. (minyoung2 B2/B3가 받은 지적.)
- **교훈:** "match" 주장엔 **TOST equivalence + bootstrap CI** 필수. fold n 작으면 AUROC 0.001차는 noise.

## T5. 해상도가 cortical 신호를 죽임
- **무엇:** 2mm block-mean 다운샘플 → 얇은 cortex(precuneus/PCC/entorhinal) 부피 재현 R² 음수. AD/초기amyloid 핵심 부위가 소실.
- **진단 도구:** **image→fs_vol 회귀 R²**(구조별). 2mm subcortical 0.67 / cortical −0.5 → 1.5mm cortical 부분복원(단 mean R² 0.23, precuneus 여전 음수 → 1mm 필요할 수도).
- **교훈:** disease 검정 전 "모델이 부피를 재현하나(R²)"를 먼저 봐서 (b)천장 vs (c)모델/해상도 병목을 가른다. cortical 의존 task는 ≥1.5mm.

## T6. Confirmation bias in 결과 해석 (★ 메타)
- **무엇:** 1.5mm R² 결과에서 *복원된 ROI만 골라* "cortical 복원·(b) 지지"라 읽음. 자동 verdict는 "(c) 못 뽑음"(mean R²=0.23)이었는데 무시.
- **교훈:** 자기 가설에 유리하게 결과를 읽지 마라. **mean/자동판정/음수 ROI를 다 보고**, 독립 research-critic으로 검증. "긍정 결과일수록 더 의심."

## T7. 평가 누수 (형제 라인 minyoung2/i)
- in-dist validation checkpoint 선택 → OOD 붕괴(0.9→0.5). **validation-lock(EMA/last-k) + subject-level LOCO** 필수.

## T9. ★ B200(Blackwell) 3D-conv가 torch.compile 없이 ~100× 느림 (인프라 — 큰 함정)
- **증상:** 3D resnet18 학습이 step당 **14초**(B200 단독, batch48 96³). fold당 2~4시간 → 방법론 탐색 마비.
- **진단(꼭 이 순서로):** matmul 8192³ bf16 = **1.7ms(빠름)** → GPU 정상, throttle 아님. 단일 Conv3d = 31ms. cudnn.benchmark 무효. channels_last 무효. **batch16 = 3.08s(super-linear=메모리 thrash).**
- **해결:** `torch.compile(model, mode="max-autotune")` + channels_last_3d + bs16 → **0.17 s/step (18×↑)**. 첫 compile 158s(1회). uncompiled cuDNN 3D-conv 커널이 Blackwell에서 미성숙 → Triton 생성 커널이 정상.
- **표준 설정(3D CNN on B200):** `torch.backends.cudnn.benchmark=True` + `.to(memory_format=torch.channels_last_3d)` + `torch.compile` + **작은 batch(16)** + fixed-shape(partial 배치 drop). 안 하면 학습이 사실상 불가.
- **교훈:** 학습 느리면 *먼저 matmul로 GPU 자체 속도 확인* → 빠르면 conv/compile 문제. 새 HW(Blackwell)는 torch.compile 필수 가정.

## T8. sunk-cost 반복 (minyoung4 4번째 무덤 경고)
- 같은 target에서 backbone·해상도·objective만 바꿔 0.66→0.69 올리는 루프 = (a)/(b) 판정에 기여 0.
- **같은 arm 3회 NO-GO면 폐기**, 상위 결정점 복귀. target/질문을 바꾸는 것만이 판정에 기여.
