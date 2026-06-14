# I08 — MCI→AD 전환(multimodal) feasibility: 최선의 non-circular task이나 제약 큼

## 무엇을 했나
MCI→AD 전환을 longitudinal dx 궤적에서 정의(baseline MCI, 이후 AD 도달=전환), CPU gating.
(`scripts/feasibility_mci_conversion.py`)

## 발견
- baseline-MCI(≥2 dx) 681명, **전환자 134(20%)**, ADNI 편중(89/134). 추적 2.1yr.
- 멀티모달: MMSE 99%·CDR 95%·APOE 95%, 그러나 **amyloid PET 3%(20명)** → "T1+PET 멀티모달" 전제 성립 안 함.
- baseline 바(subj-CV): cognition 0.744, morphometry 0.746(**oracle 아님→headroom**), age+APOE 0.651,
  **morpho+cog+age+APOE 0.831**(강한 engineered 바). amyloid는 n=20로 평가불가.

## 재사용 가능한 인사이트
1. **전환은 우리가 본 최선의 task**(non-circular 미래결과, morphometry 비-oracle, 임상가치). 단:
   N=134 소데이터·ADNI편중·과밀분야·engineered 바 0.831 강함 → morphometry-oracle로 또 capped 위험.
2. **PET은 멀티모달 primary가 못 됨(3%)** — 멀티모달의 진짜 질문은 "값싼 T1+clinical이 비싼 PET 없이
   전환을 얼마나 예측하나". PET privileged는 20명으로 너무 적음.
3. 정직한 예상: T1-CNN≈morphometry(0.74), 결합은 cognition+morpho 지배 → 딥 image가 0.831 크게 못 넘음.
   기여는 accuracy가 아니라 소데이터/cross-cohort(AJU 포함)/벤치마크로 framing해야.

## 증거/포인터
- `scripts/feasibility_mci_conversion.py`, [[I02_amyloid_null_and_morphometry_oracle]](오라클),
  [[I07_whattofuse_amyloid_clinical_dominant]](타깃 전수탐색).
