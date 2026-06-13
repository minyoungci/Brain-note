# 한국인-특화 AD 멀티모달 연구 주제 (2026-06-13)
*보유 데이터 최대 활용 + 세션 교훈(morphometry-ceiling / clinical-ceiling / kitchen-sink / ΔAUC-over-clinical) 반영.*

## 데이터의 *고유* 강점 (무엇이 우리만의 것인가)
- **동시 측정 3-병리축**: amyloid(PET-SUVR) + vascular(FLAIR-WMH) + atrophy(T1), *같은 한국인 subject*에 co-registered (N~1,836).
- **+ 전신/대사/혈관 패널**: APOE·DM·HTN·dyslipidemia·HbA1c·지질·갑상선·B12/folate (~80%) + 인지(MMSE/CDR/GDS).
- **한국 memory-clinic 인구**: 서구(ADNI)와 다른 *높은 혈관 부담·mixed pathology*, APOE 효과 차이 — 서구 데이터로 답 못 하는 질문.
- 즉 "amyloid-PET + full blood + vascular risk를 *동아시아*에 동시 보유" = 복제 어려운 자산.

## 벽을 *우회*하는 원칙 (왜 이번엔 다른가)
- ❌ "deep이 morphometry/clinical을 이긴다" 프레이밍 금지 (8회 죽음).
- ✅ 기여를 *과학적 발견*(한국 AD의 병리 상호작용) 또는 *임상 ΔAUC-over-(clinical+blood)*로. 혈액/임상 = baseline·control이지 feature 덤프 아님.

## 후보 주제 (정직한 평가)

### ★ A. 한국 인지장애의 amyloid–vascular–neurodegeneration 상호작용 (clinical-neuroscience)
- **질문**: 한국인(고혈관/대사 부담)에서 vascular·metabolic 위험(DM/HbA1c/지질)이 amyloid(PET)→WMH(FLAIR)→atrophy(T1)→cognition 경로를 *어떻게 조절*하나? amyloid-우세 vs vascular-우세 축이 멀티모달 영상+혈액으로 구분되나?
- **데이터 활용**: 전부 (tri-modal + 혈액 + 혈관위험 + 인지).
- **벽 회피**: method-win이 아니라 *과학적 특성화*(mediation/pathway/subtyping) → morphometry-ceiling 무관.
- **venue**: Alzheimer's & Dementia / NeuroImage:Clinical / J Alzheimers Dis (clinical/translational).
- **risk**: 통계/역학 중심(AI-method 약함); "vascular가 AD 조절"은 부분 known → *한국-특화 + 멀티모달 동시측정*이 차별점이어야. ⭐후보(데이터-fit 최고).

### B. PET 없이 amyloid 양성 예측 (cheap multimodal → amyloid)
- **질문**: T1+FLAIR+APOE+혈액으로 amyloid 양성(PET-SUVR/visual ground truth) 예측 — 비싼 PET 대체.
- **벽 회피 약함**: 구조→amyloid ≈0, APOE+age가 지배 → **clinical-ceiling 위험 큼**. clinical+APOE baseline 먼저 측정 필수; imaging ΔAUC 없으면 죽음.
- **venue**: 임상영상. **risk 높음** (서구서 이미 다수 + ceiling).

### C. 멀티모달 fusion AD staging/conversion-risk (ML-method, ΔAUC-over-clinical+blood)
- **질문**: tri-image+tabular fusion이 강한 clinical+blood baseline을 *넘는* endpoint(현재 dx 아님 — 미래 decline/conversion 등)가 있나?
- **벽 회피**: conversion 라벨이 *있어야* 함 — KDRC/AJU longitudinal 여부 확인 필요(이전 manifest는 subject-고정 dx였음 → 게이트).
- **risk**: ceiling + fusion novelty 혼잡. conversion 라벨 없으면 불가.

## 권고
**★ A (한국 AD amyloid–vascular 상호작용)** 가 *데이터-fit·실현성·Korean-특화*가 가장 높음 — 벽(morphometry/method)을 구조적으로 우회. 단 clinical/translational 성격(의료 venue). AI-method를 원하면 A에 *멀티모달 통합 method*를 얹어 hybrid 가능(영상이 혈액 너머 공간정보를 더하는 부분).

## 첫 게이트 (GPU 전, 공통 — 무엇을 택하든)
1. **clinical+blood-only baseline 측정** — 타깃(amyloid 양성 / dx / WMH 등)을 임상+혈액만으로 얼마나 예측하나. = 이겨야 할 바.
2. **tri-modal 영상의 ΔAUC-over-(clinical+blood)** — 영상이 *실제로 더하나*. 없으면 ceiling 재확인.
3. (C 택시) conversion/longitudinal 라벨 존재 여부 확인.
→ 이 게이트가 통과해야 본 연구 진행. task-first, 무작정 학습 금지.
