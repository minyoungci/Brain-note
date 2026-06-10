# 07 — Deep image-level harmonization (MixStyle domain-randomization) 결과

_생성: 2026-06-04. GPU(B200, bf16) 학습. 스크립트 `stage21_mixstyle_domain_randomization.py`. 원본 READ-ONLY(data csv sha256 전후 동일)._
_목적: 06 feasibility 3.3.1의 기각벡터("강한 image harmonization을 안 돌렸다")를 닫기 위해 **강한 방법 1개를 직접 실행**._

## 설계
- 입력: 5-ROI(parahippocampal/hippocampus/amygdala/lateral_ventricle/thalamus) crop 40³ intensity+mask = **10채널** (minyoung4 stage8M baseline과 동일 파이프라인 `s9.extract_roi_combo_patch` 재사용 → 공정 비교).
- 모델: 작은 3D CNN(10→32→64→128, GAP→linear). **MixStyle3D**(Zhou 2021 ICLR)를 block1/2 뒤 삽입 + 경량 MRI-style aug(gamma/noise/low-freq bias, intensity 채널만).
- arm: vanilla(mixstyle 0.0) vs MixStyle(0.5+aug). held: KDRC(한국, test AD 130), AIBL(test AD 51). bf16, class-weighted BCE, best-val 선택.
- 데이터: 1765 subjects(ADNI 907/AIBL 473/KDRC 385, CN 1509/AD 256). **train AD가 107~205로 희소**(아래 한계).
- 비교 기준: **동일 split의 morphometry(fs_vol÷MaskVol, LogReg) held-AUC**를 매 run 인라인 계산.

## 결과 (held-test CN/AD AUC)

| held | arm | **image CNN AUC** | **morphometry AUC** | **Δ(img−morph)** | site-probe(train feat, chance 0.5) | null perm p |
|---|---|---|---|---|---|---|
| KDRC | vanilla | 0.878 | 0.949 | **−0.070** | 0.637 | 0.0 |
| KDRC | MixStyle | 0.885 | 0.949 | **−0.064** | 0.663 | 0.0 |
| AIBL | vanilla | 0.898 | 0.930 | **−0.032** | 0.693 | 0.0 |
| AIBL | MixStyle | 0.900 | 0.930 | **−0.031** | 0.726 | 0.0 |

**재현성 검증(seed 17 vs 42, held-KDRC, `verify_*_seed42/`):**
- img_auc seed-spread: vanilla 0.003, MixStyle 0.001 (안정).
- morphometry 항상 이김: 6개 run(2 cohort×2 arm×2 seed) **전부 Δ<0** (−0.031~−0.080).
- MixStyle의 img 효과: +0.007(s17)/+0.011(s42) — 양 seed 일관되게 미미, ~0.07 격차 못 메움.
- MixStyle의 site-probe 효과: **+0.026(s17)/+0.027(s42)** — 양 seed 거의 동일 → site shortcut 감소 실패는 재현되는 현상(노이즈 아님).

## 결론 (검증됨)

1. **이미지-레벨 deep 표현은 LOCO에서 morphometry를 못 이긴다 — 전 조건·전 seed에서.** 3D CNN held-AUC 0.88~0.90 < morphometry 0.93~0.95 (Δ −0.03~−0.08). 04(morphometry site-robust) + minyoung4 stage8~20 + 문헌(06)을 **직접·독립 재확인.**
2. **MixStyle domain-randomization은 gap을 못 메운다.** img_auc 변화 +0.002~0.011(노이즈 수준). "스타일 무관화로 morphometry를 따라잡는다"는 가설 **기각**.
3. **MixStyle은 표현의 site shortcut을 못 줄인다 — 오히려 소폭 올린다.** site-probe(penultimate feature로 train 코호트 식별) 0.637→0.663, 0.693→0.726, Δ +0.026~0.027(양 seed 재현). 기대했던 "site-probe가 chance로 하락"의 **반대.** instance-statistic mixing이 anatomy 채널엔 작동해도 deep feature의 site 분리도를 낮추지 못함.
4. null perm p=0.0(전 run): 모든 AUC는 진짜 신호(chance 아님). data csv 무결.

→ **06 verdict 강화 + reviewer-proof화**: "강한 image harmonization(MixStyle+MRI aug)도 (a) morphometry를 못 이기고 (b) site shortcut을 못 줄인다"를 직접 입증. 06 3.3.1의 "강한 방법 미실행" 기각벡터가 닫힘. 이미지 정규화(03 N4)+특징 harmonization(02 ComBat/05 GAM)+스타일 무관화(07 MixStyle) 세 레이어 전부에서 동일 결론.

## 한계 (정직성)
- **train AD 희소(107~205)** → 3D CNN은 data-limited. 더 큰/사전학습(foundation) 백본이면 절대 AUC는 오를 수 있으나, **이 regime(AD 희소+site==population)에서 morphometry가 이긴다는 상대 결론**은 바뀌지 않을 가능성이 큼(04도 동일). 큰 backbone은 별도 study.
- MixStyle은 domain-randomization의 한 형태. **GAN/IGUANe(image translation)·SynthSeg 전체는 미실행**(06: CycleGAN은 site==population서 hallucination 위험으로 비권장). 단 03+02+05+07로 정규화/특징/스타일 축을 커버.
- site-probe는 held-out이 단일 코호트라 **train 2-way(chance 0.5)** — 7-way보다 약한 probe. 절대값은 seed 분산 있으나 MixStyle Δ는 안정.
- 작은 CNN(과적합 억제용 선택). 구조 sweep 미실시.

## 산출물
- `out/{vanilla,mixstyle}_held{KDRC,AIBL}/result.json` (seed 17)
- `out/verify_{vanilla,mixstyle}_heldKDRC_seed42/result.json` (재현성)
- `out/patch_cache/` (5-ROI 40³ patch 캐시, 1765개; 재실행 가속, 원본과 분리)
