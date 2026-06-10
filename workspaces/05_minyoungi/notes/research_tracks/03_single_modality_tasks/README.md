# Track 03 — 단일모달 Clean Tasks

## 목표
멀티모달 융합의 confound를 피해, **단일 모달리티 내에서 confound 없이 유효한 task**를 본다.
"융합이 더 낫다"를 주장하지 않으므로 site==population 함정에서 자유롭다(within-modality).

## 후보 task (측정 근거 동반)

### 3a. amyloid PET 영상 → amyloid status (깨끗)
- 근거: 우리 SUVR(cortical composite) vs visual 판독 **AUC AJU 0.97 / KDRC 0.82**. 영상이 직접 amyloid를 본다(자명하지만 깨끗한 검증).
- 확장: **구조(T1+FLAIR)만으로 amyloid 예측** — 단 ΔAUC over 임상(APOE)이 ~0이라(측정됨) 약함. 딥 표현이 형태계측을 넘나가 유일한 열린 질문(GPU).

### 3b. 구조(ROI) → 치매/위축 staging (강함)
- 근거: 비인지임상 위 ROI **ΔAUC +0.133(AJU)/+0.053(KDRC)**, ROI-only 0.90+. 형태계측=위축 직접측정.
- dossier 정합: "CDR 공통타깃 형태계측 staging"(00 열린방향). **harmonize 필수**(fs_vol은 ComBat 가능 — pixel과 달리 [[combat-fsvol-harmonization]]).
- 열린 질문: ROI harmonize가 코호트(0.747) 죽이고 치매신호 살리나? (CPU 측정 가능)

## 왜 별도 track인가
이건 VLM이 아니라 **형태계측/SUVR 기반 깨끗한 예측·staging**. 융합 novelty가 약하지만
신호가 실재하고 confound가 통제 가능. 보수적 baseline·sanity로도 가치.

상태: 3a·3b 모두 일부 실측 완료. ROI harmonize 측정이 다음 cheap step.
