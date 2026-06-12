# SPEC — 3D ROI-token SSL for Structural Brain MRI (SSOT)

> **단일 출처(SSOT).** 새 주제의 연구 방향·데이터·설계·계획의 유일 기준. 누적 갱신.
> 시작: 2026-06-11 · 목표 venue: **ACCV/WACV/BMVC**(tier-2 vision, *representation-learning method* 프레이밍) · 이전 탐색 phase는 git tag `exploratory-v1`에 보존.
> 원칙: 성능 주장 보류, 자기평가로 "완료/novelty" 판정 금지, 생성·검증 분리, 모든 게이트는 독립 산출물로 판정.

---

## 0. 한 줄 요약
**95개 FreeSurfer DKT+aseg ROI를 *토큰*으로 하는 region-token transformer를 3D 구조 T1에 masked-region modeling + inter-region contrastive로 SSL pretrain.** 구조 MRI 최초의 **ROI-as-unit SSL**(fMRI엔 존재, 구조 T1엔 미점유 — scout 검증). downstream = **CDR-SB 인지 severity**(AJU/KDRC/ADNI; 위축이 *정당한* 신호 — imaging이 covariate를 +0.2~0.39 압도, R1b). 기여 = *region-token SSL 메커니즘*이며 **핵심 증거 = ROI-token SSL vs whole-volume SSL ablation.**
> **task 변경 이력:** amyloid는 atrophy-staging confound로 폐기(R1: CN-stratified서 imaging<covariate; AJU/KDRC CN n=17/21로 검증불가). CDR-SB 인지는 위축이 정당한 인과라 confound 없음. amyloid는 honest-secondary(CN 한계 명시)로만.

---

## 1. 동기 & Novelty (scout 검증, 2026-06-11)
### 1.1 왜 이 주제 (이전 phase의 교훈)
- cross-cohort 전이는 site≈severity confound로 구조적으로 막힘(이전 phase 입증) → **within-cohort로 전환.**
- amyloid-from-T1은 천장 낮음(~0.62–0.70, covariate age+APOE4가 매칭) → **단, AJU/KDRC에선 imaging이 covariate를 넘음**(아래 §3 측정).

### 1.2 Novelty wedge (scout: 미점유 검증)
- **점유(must-beat baseline):** 일반 3D SSL(Models Genesis/MedIA2021, Swin-UNETR SSL/CVPR2022), **DAMT(ACCV2024)** = anatomy-aware 3D-T1 SSL, *whole-volume Swin*(ROI-token 아님), amyloid 안 함.
- **점유(다른 modality):** ROI-token/masked-ROI SSL은 **fMRI/brain-network엔 존재**(BrainMass/MRM, BrainMAE) — 구조 T1 아님.
- **점유(supervised):** per-ROI 3D ViT 앙상블(SciRep2024) — SSL 아님.
- **미점유(우리 wedge):** **"95 DKT ROI를 토큰으로 한 masked-region/region-contrastive SSL on 3D *구조* T1"** — peer-review 미발견. = 진짜 빈자리.
- **한 줄 thesis:** *"구조 MRI에서 해부 ROI를 토큰으로 SSL pretrain하는 region-token transformer(masked-region + inter-region contrastive) — 구조 MRI 최초의 ROI-as-unit SSL, amyloid·AD에 전이."*

---

## 2. 데이터 자산 (이전 phase에서 확정, 안전)
| 자산 | 규모 | 위치 |
|---|---|---|
| T1 192³ (SSL pretrain) | 7코호트 **13,022** | `/home/vlm/data/preprocessed_official/v2/` + `official_manifest_full_n4.csv` |
| **DKT+aseg parcellation (95 ROI)** | **13,022 전부(100%)** | `{t1w}/roi_transfer_option_b_candidate_v0/aparc_DKTatlas_aseg_final_tensor_grid_*.nii.gz` |
| amyloid 라벨 + covariate(age/APOE4/sex/mmse) | 4코호트 3,180 | `data/multimodal_manifest.csv` |
| **downstream: AJU 1000 / KDRC 534** | amyloid 100% | (imaging이 covariate 넘는 코호트) |

---

## 3. Feasibility (직접 측정, 2026-06-11)
### 3.1 amyloid = 폐기 (R1, atrophy-staging confound)
within-cohort amyloid: overall은 AJU/KDRC서 imaging>COV이나 **CN-stratified(정직)서 역전** — ADNI/OASIS CN(n 595/353)서 ROI(0.59/0.65)<COV(age+apoe4, 0.74/0.77). AJU/KDRC CN n=17/21로 검증불가. → 구조 MRI의 amyloid 신호는 downstream 위축(증상기에만)이라 confound. **폐기.**
### 3.2 CDR-SB 인지 severity = 채택 (R1b, 정당)
| cohort | COV(age+sex) corr | **ROI corr** | imaging 기여 |
|---|--:|--:|---|
| AJU | 0.045 | **0.433** | ✅ **+0.39** |
| KDRC | 0.005 | **0.394** | ✅ **+0.39** |
| ADNI | 0.194 | **0.482** | ✅ +0.29 |
| OASIS | 0.081 | 0.284 | ✅ +0.20 |
→ **전 코호트서 imaging이 covariate 압도.** 인지는 위축으로 *직접* 발생(정당 인과), age+sex는 인지 거의 못 예측 → confound 없음. **downstream = CDR-SB 회귀(또는 severity-level 분류).** 보조: impaired-vs-CN(ADNI ROI 0.663>COV 0.611).

---

## 4. 설계 (region-token SSL)
### 4.1 ROI 토큰화
- 각 subject: parcellation(95 ROI) + T1 → 토큰 95개. 각 토큰 = ROI 영역의 표현(설계 결정: per-ROI 3D patch encoder / per-ROI pooled CNN feature / per-ROI scalar+위치 — **§5 게이트로 결정**).
### 4.2 SSL pretext (2개)
- **masked-region modeling**: ROI 토큰 일부 마스킹 → 나머지로 복원(feature 또는 voxel).
- **inter-region contrastive**: 같은 subject ROI 간/augmented view 간 대조.
### 4.3 backbone
- region-token **transformer**(95 토큰 + positional=ROI 해부 위치). SSL은 13K로 pretrain.
### 4.4 downstream
- pretrained encoder → AJU/KDRC amyloid 이진분류(fine-tune or linear-probe). 보조: AD/age(de-risk).

## 5. 게이트 (생성·검증 분리) — R0–R4 완료(2026-06-11)
- **R0 ✅** `data_roi.py`/`cache_img.py`: ROI feature(190d) + T1(96³)+parc(24³) 캐시(3180, roi_feats 정렬 검증).
- **R1 ✅(amyloid 폐기)**: amyloid는 atrophy-staging confound(CN-stratified서 imaging<covariate). → **R1b**: CDR-SB로 전환, imaging이 covariate +0.2~0.39 압도(정당).
- **R2 ✅** `roitoken.py`: ROI-token transformer + masked-region SSL. pretrain(3180) recon L1 roi 0.467 / whole 0.716. 정상 학습.
- **R3 ✅** downstream CDR-SB(frozen embed→Ridge): ROI-token AJU **0.478**/KDRC **0.415**/ADNI **0.533** > hand-crafted ROI(0.433/0.394/0.482) > covariate(0.05~0.19).
- **R4 ✅ 핵심 ablation**: **ROI-token > whole-volume 전 코호트**(+0.10~0.15) → region-token이 이득 원인 **입증**.
- **R5 ✅ 13K 확장 + multi-seed**(2026-06-11): SSL을 13,022(7코호트)로 pretrain. downstream 5-seed CDR corr: ROI-token AJU **0.521±0.006**/KDRC 0.400±0.027/ADNI **0.525±0.009** vs whole 0.420/0.336/0.452(ablation gap +0.06~0.10 ≫ std=유의) vs hand-crafted 0.433/0.394/0.482(AJU +0.088/ADNI +0.043/KDRC +0.006). 13K로 AJU +0.043 향상.
- **R6 ✅ baseline 직접 비교**(matched-backbone, 13K, multi-seed): ROI-token이 **모든 baseline 능가** — vs DAMT-style(whole anatomy) +0.06~0.10, vs Models-Genesis(generic) +0.067~0.078, vs hand-crafted(AJU+0.088/ADNI+0.043/KDRC marginal), vs covariate 압도. 핵심: whole-vol선 anatomy≈generic → **ROI-tokenization이 이득 원인**(인과 분리).
- **R7 ✅ ablation**(2026-06-11): ① **positional 필수** — no-pos시 CDR −0.05~−0.10(AJU 0.478→0.424, KDRC 0.415→0.336, ADNI 0.533→0.435) + recon 0.467→0.705 → 해부 *정체성*이 이득 원인(단순 pooling 아님), region-token 설계 정당화. ② **fine-tune < frozen-probe**(AJU 0.482/KDRC 0.374 < 0.521/0.400) → frozen SSL 표현이 더 강함, linear-probe를 main protocol로.
- **R8 ✅ code-auditor 감사 + 수정**(2026-06-11) — **이전 R3/R5/R6/R7 transductive 수치 정정:**
  - 감사 통과: CDR leakage 없음·probe 누수 없음·데이터정렬·roi_pool·SSL mask·비교공정 전부 정확.
  - **C1 수정(transductive→inductive)**: downstream subject(모든 시점) 제외 재pretrain(13K→5956). **honest CDR: ROI-token AJU 0.471±0.018/KDRC 0.378±0.012/ADNI 0.492±0.001**(transductive 0.521/0.400/0.525서 하락).
  - **C3 수정(no_pos 버그)**: downstream이 no_pos 미전달 → positional ablation 무효였음. 수정·동일 5-seed 재측정: with-pos 0.494/0.422/0.532 vs no-pos 0.423/0.336/0.434, **drop −0.07~−0.10 유의(positional 필수 *재검증*)**.
  - **핵심 ablation 유지(inductive)**: ROI-token > whole +0.06~0.09 유의 → **region-token이 원인(견고)**.
  - **주장 정정**: "모든 baseline 압도" → **"학습 SSL baseline(generic/whole-vol anatomy) 능가, hand-crafted와는 comparable"**(inductive vs hand-crafted: AJU +0.038/ADNI tie/KDRC −0.016).
- **남은 것**: ① MG baseline도 inductive 재측정 ② masked/contrastive 항 ablation ③ AD/age 보조 task ④ KDRC 보강 ⑤ (optional) 실제 DAMT Swin ⑥ 논문 작성.

## 6. Must-beat baselines (scout, 우선순위)
1. **covariate LR(age+APOE4+sex)** — 생사. 못 이기면 중단.
2. **FreeSurfer-ROI-volume XGBoost** — 강한 classical region baseline.
3. **일반 SSL(Models Genesis / Swin-UNETR SSL) + DAMT(ACCV2024)** — region-token이 *기여의 원인*임을 ablation으로.

## 7. 정직한 리스크
1. **R4 ablation 실패**: ROI-token이 whole-volume SSL 못 이기면 논문 안 됨(핵심).
2. **amyloid 천장**: 0.62–0.70, headline은 *method*(amyloid는 testbed). AD/age 보조로 de-risk.
3. **shortcut learning**: skull-strip artifact·diagnosis-confounded amyloid → CN-stratified·amyloid-balanced 평가 필수(scout 경고).
4. **DAMT 인접**: whole-volume이지만 anatomy-aware 강자 → ROI-token daylight 명확히. `[VERIFY]` DAMT 7 pretext 정확 목록.

## 8. 참조 (scout 검증 출처)
- DAMT(ACCV2024, arXiv 2410.00410, github.com/jongdory/DAMT) · Swin-UNETR SSL(CVPR2022) · Models Genesis(MedIA2021) · BrainMass(MRM, fMRI ROI-token) · Reith(AJNR2025, T1 amyloid 0.62) · per-ROI ViT 앙상블(SciRep2024) · skull-strip shortcut(PMC12722621).
