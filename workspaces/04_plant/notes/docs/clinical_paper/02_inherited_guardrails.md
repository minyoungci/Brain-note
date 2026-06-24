# 물려받은 가드레일 — incremental-value 라인에 *실제로* 적용되는 것만

> old-line(insight/·DECISION_LOG)에서 *이 tabular 임상 라인에 관련된 교훈만* 증류.
> deep-learning/3D-CNN 전용 함정(표현-LOCO 누수·morph-distill·해상도·B200 conv·TTA·DataLoader)은 무관 → 제외.
> 원본 전체는 git 히스토리(commit `6fafde2` 시점)에 보존.

## 설계에 직접 박힌 가드레일 (01_study_design이 인용)
- **R3 평가 누수 (T7):** subject-level holdout + **validation-lock**. random split 금지. in-dist 체크포인트 선택 금지. → nested CV 골격.
- **검정력 ≠ 동등 (T4):** "증분 작다"를 p>0.05로 주장 금지. **TOST equivalence + bootstrap CI** 필수. = 우리 T2 task의 근거.
- **약한/confounded 타깃 (R4·T3):** 주 타깃은 morph가 *의미있게 설명*하는 비순환 타깃(MMSE·CDR-SB). **amyloid는 주 타깃 금지**(morph 0.66 약함, 분자=T1 모달리티 천장) → RQ2 triage로만, 예측자에서 PET 제외.
- **baseline 자기기만:** 계층 bar 명시(covariate→morph→image→biomarker). **morph를 baseline(M1)에 반드시 포함** — 안 그러면 증분 과대평가.
- **pooled 평균이 회귀 은폐:** **하위군별 보고** 필수(dx 군별). pooled 단일 숫자 금지.
- **확증편향 (T6, 메타):** 자기 가설에 유리하게 결과 읽지 마라. 자동판정·전체 분포·음수까지 다 보고. "긍정 결과일수록 더 의심." 생성≠검증 분리.
- **AUROC만 (T11):** RQ2(amyloid triage) discrimination은 **AUROC**로. 고정임계 bACC는 불균형서 0.5로 붕괴 = calibration 증상이지 실패 아님.

## 이 라인 예측을 *미리* 정하는 실증 prior (empirical_findings 증류 — 가정 아닌, 재검정 대상)
- **혈액+MRI 증분 ≈0** (과거: morph+age 대비 dementia +0.005·MCI +0.000·amyloid +0.007). → **M3(혈액)의 한계기여가 작을 것**이라는 *사전 기대*. 우리는 이를 TOST로 *정직하게 재검정*(가정해서 쓰지 않음).
- **멀티모달 fusion**: 문헌 crowded·LOCO 증거 전무 → 우리는 fusion 성능경쟁이 아니라 *한계기여 정량*으로 차별.
- **rich-data = cross-sectional** (Korean 종단 35명뿐) → **우리 설계가 cross-sectional인 이유**(진행 아닌 중증도). 종단 주장 금지.
- **morphometry는 site-robust 강baseline** (AD/CN LOCO 0.936, site-shift ~0) → M1(구조 T1)이 넘기 어려운 floor인 이유.
- **amyloid morph-weak 0.66 / APOE morph→0.59 chance** → RQ2에서 "구조로 PET 대체" 기대를 낮게 잡는 근거. 단 morph+APOE→amyloid 0.78(과거)이라 APOE가 핵심 추가축.

## 단일코호트 설계 정당화 (R1)
- site=population 비가역 교란(cross-site harmonization 원리적 불가, 4라인 입증) → **AJU 단일기관 bracket이 회피책**. 서양은 *전이 대상 아님*, descriptive 맥락만. "transferable 표현" 주장 안 함.

## 데이터 위생
- **manifest = parquet 직접 조회** (datadict/README는 stale). 경로는 **파일 stat 검증**(플래그 신뢰 금지) — 00_assemble_cohort.py가 이미 적용.
- AJU 2쌍 cross-subject 동일 텐서 등 누수: split 전 collapse 확인([[manifest-leakage-duplicates]]).
