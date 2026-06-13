# ★ FINAL TOPIC (2026-06-13, 게이트 검증 후 확정)

## 제목
**"한국인 인지장애의 amyloid–vascular 공동병리와 그 대사·유전 결정인자: 멀티모달(PET–MRI–혈액) 특성화"**
(Amyloid–vascular co-pathology and its metabolic/genetic determinants in Korean cognitive impairment)

## 왜 이 주제로 확정했나 (게이트 근거)
- GATE: clinical+blood(APOE+혈관+대사)가 강한 baseline (amyloid 0.76, CN/AD 0.91); **tri-modal 영상 추가 ΔAUC 작음**(T1 +0.035, FLAIR/PET ~0). → **"imaging-method가 이긴다" 프레이밍 폐기.**
- longitudinal 미약(286명, conversion 36건) → 예후 타깃도 under-powered.
- ∴ 기여는 *method-win*이 아니라 **과학적 발견**(한국 AD 병리 상호작용) — morphometry/clinical ceiling을 *우회*. 의료/translational venue.
- 데이터 고유강점 정확히 활용: amyloid-PET + FLAIR-WMH + 구조 + 포괄 혈액/혈관위험을 *동아시아*에 동시 보유(서구 데이터로 답 못 함).

## 연구 질문 + 설계 (cross-sectional, N=tri-modal 1,836; 완전 혈액+APOE subset ~1,300)
**Q1 — 결정인자 (Phase 1, 즉시 실행 가능, GPU 불필요)**
각 병리축[amyloid(PET-SUVR), vascular(WMH/Fazekas), atrophy(hippo/entorhinal)]을 대사·혈관·유전 인자(DM·HTN·HbA1c·지질·APOE)로 회귀, age/sex/edu 통제. → *한국인에서 어느 전신인자가 어느 축을 구동*하나. bootstrap CI + Holm.

**Q2 — 멀티모달 subtyping (Phase 2)**
3 영상축으로 군집(amyloid-우세 / vascular-우세 / mixed / low) → 각 군집의 인지·임상·위험인자 프로파일. 군집 안정성(bootstrap)·인지 연관 검증.

**Q3 — 임상 실용 발견 (Phase 3)**
게이트 발견 형식화: CN/AD·amyloid를 MRI+APOE+혈액으로 예측 시 **PET가 redundant**(ΔAUC≈0) — "한국 AD dx에 비싼 amyloid-PET이 필요한가?" 정직한 ΔAUC로.

**Q4 — Korean vs Western 비교 (Phase 4, 보조·confound 명시)**
보유 ADNI/OASIS/AIBL로 amyloid–vascular interplay 대조 (단 site=population confound 명시, 보조 결과로만).

## 방법·무결성
- 통계: 다변량 회귀·mediation·clustering, 전부 age/sex/edu 통제, bootstrap 95% CI, Holm 보정.
- *deep-learning method 아님* (게이트가 폐기). 예측 부분(Q3)은 ΔAUC-over-(clinical+blood), leakage-safe(subject-CV).
- 과대포장 금지: "vascular가 AD 기여"는 부분 known → *한국-특화 + 동시-멀티모달*이 차별점임을 명시.

## venue / novelty(정직)
- venue: Alzheimer's & Dementia / Alzheimer's Research & Therapy / NeuroImage:Clinical / J Alzheimers Dis (clinical/translational).
- novelty: **moderate** — 강한 AI-method 아님. 동아시아 amyloid-PET+포괄혈액 멀티모달 동시측정 코호트는 드물어, *Korean mixed-pathology 특성화*가 임상적으로 기여. 정직히 top-AI는 아님.

## 첫 실행 (Phase 1, 지금)
determinants 회귀: 각 병리축 ~ 대사/혈관/유전 (통제·CI). 산출 = 어느 전신인자가 어느 축 구동(한국).

---
## Phase 4 비교 코호트 결정 (2026-06-13, manifest 검증)
**서양 비교 = OASIS** (4축 amyloid+FLAIR+APOE+T1을 *모두* 가진 유일 코호트; A4=APOE없음/CN-only, ADNI/NACC=FLAIR없음, AIBL=대부분 없음).
- joint N: amyloid+APOE+T1 **1,045** / 4축 전부 **596**.
- ⚠️ 정직한 confound 3종: (1) OASIS=CN/preclinical(AD 8명) vs Korean=memory-clinic(MCI/AD) → 인구 불일치, (2) tracer FBB vs PiB+AV45, (3) 서양엔 혈관/대사 패널·WMH label 없음.

### A&D 전략 (confound 회피)
- **PRIMARY = Korean-unique 멀티모달 특성화** (amyloid-vascular dissociation + metabolic determinants). 서양이 못 가진 데이터 → 비교 없이 성립하는 기여.
- **OASIS는 제한적 secondary**: APOE→amyloid 축만, *표준화 within-cohort 계수* 정성 비교 + confound 명시. 헤드라인 아님.
- 대안: 직접 cross-cohort 비교 대신 *출판 서양 reference*와 대조 (site=population confound 회피).
- Target journal: **Alzheimer's & Dementia** (clinical/translational). Korean memory-clinic 멀티모달 동시측정의 희소성이 셀링포인트.
