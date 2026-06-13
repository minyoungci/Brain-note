# KDRC/AJU Multimodal Controlled Image-Reasoning — Feasibility (2026-06-13, CORRECTED)

## ★ 핵심: tri-modal이 *이미 전처리·co-registered* 됨 (korean_multimodal_manifest.csv)
출처: `/home/vlm/data/preprocessed_official/korean_multimodal_manifest.csv` (AJU 1287 + KDRC 909).
(주의: official_manifest_full_n4_real_final.csv는 raw 경로만 있어 과소평가됨 — 이 korean manifest가 정답.)

| 모달 | 상태 | 공간 |
|---|---|---|
| T1 (t1w_final_path) | ✅ 전처리 | 192×224×192 1mm z-score |
| FLAIR (flair_final_path) | ✅ 전처리 | **동일 192³ 1mm (co-registered)** |
| PET-SUVR (pet_suvr_path, +dl) | ✅ 전처리 | **동일 192³ 1mm, SUVR값 [0,3]** (pet_to_t1w.mat 등록) |
| T2 / DWI | ❌ raw (4mm slice / 4D DTI) | 첫 버전 제외 |

**tri-modal(T1+FLAIR+PET-SUVR) 전처리완료 디스크실존 = 1,836** (KDRC 873 + AJU 963). 즉시 사용 가능.

## 라벨 (∩ tri-modal 1836)
amyloid_visual **1467 (neg789/pos678 균형)** · dx 1669(MCI946/AD426/CN297) · APOE_e4 1466 · MMSE 1417 · CDR 1467 · GDS 1444 · WMH_visual 963 · Fazekas 274 · 혈액패널/혈관위험(dm,htn,bmi,hba1c…) 다수.
- tri ∩ (dx & amyloid_visual) = **1300**.

## feasibility 판정: GOOD (데이터-ready, 병목은 task 설계)
- ✅ tri-modal 전처리·정합 완료, **N 1836** (controlled-matching 여유 충분).
- ✅ 라벨 풍부·균형, 단일 한국인구(cross-ancestry confound 회피).
- ⚠️ task는 *이미지-reasoning*으로 설계 필수 (cognition-prediction=morphometry-ceiling, 금지).
  - 후보: amyloid 양성(PET spatial)·WMH burden(FLAIR)·mixed-pathology를 *영상에서 통합 판독*하는 reasoning.
- ⚠️ markers(scalar)는 morphometry 못 넘음(K 실험) → task는 *scalar 예측이 아니라 영상 통합 reasoning*이어야 가치.

## 다음 (GPU 전, task-first)
1. reasoning task/question 설계 확정 (무엇을 묻고, 왜 morphometry로 못 풀고 멀티모달 영상이 필요한가).
2. controlled-matched question N 충분성 게이트 (1836서 matching 후 잔여).
3. tri-modal 96³/192³ 캐시 빌드 (전처리 완료라 로드만) → 학습.

## leakage/과대포장 주의 (기록)
앞선 official_manifest 기반 "N~266" 판정은 *틀린 manifest* 탓 — korean manifest로 정정. tri-modal 정합은 1-subject load로 확인(전수 정합 QC는 학습 전 별도 권장).
