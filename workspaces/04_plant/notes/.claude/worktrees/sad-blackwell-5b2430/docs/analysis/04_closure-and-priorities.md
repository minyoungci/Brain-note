# 04 · 실제 닫힌 이유(상세) + Korean 데이터 역할 + 우선순위 연구

> 4 sibling 라인(minyoung2/3/4/i) closure 원문 정밀 추출(8-agent workflow) + Korean(AJU/KDRC) 비공개 데이터 분석 종합. 2026-06-20.
> 모든 수치는 원문 인용 또는 매니페스트 라이브. ⚠️ sibling 원문 일부는 자동생성 문서라 `[VERIFY]`.

---

## 1. 실제로 닫힌 이유 — 축별 상세 (수치·메커니즘)

### R1 · site = population = severity (구조적 비식별 — 제거 시도 부족이 아님)
- **메커니즘:** traveling-subject **0**(같은 피험자를 ≥2 스캐너로 찍은 데이터 없음) → site를 age/sex/disease/ancestry에서 *원리적으로* 분리 불가. 게다가 겉보기 "cohort-disease 얽힘"이 **disease-prevalence 불균형 artifact**로 판명.
- **증거:** plant Cramér's V **0.421**. minyoung4 excess-alignment **+0.546±0.018**(calibration: random pseudo-cohort +0.086, within-ADNI scanner +0.003 ≈ 분리가능 → +0.546은 진짜 얽힘). GRL full-FT(λ0.3/1.0) site-probe Δ~0.02 비단조·LOCO Δ≈0. **decomposition artifact 검증:** disease-imbalance 통제 후 Spearman ρ **+0.90→−0.20**, cross-ancestry deflation +0.05→−0.001(CN 7580 vs AD+Dem 969 매칭하면 scanner/ancestry 효과 *소멸*). → **결론: 제거 중단, 측정으로 전환.**

### R2 · morphometry 천장 (image ≤ fs_vol, coarse dx)
- **메커니즘:** 4개 독립 라인이 동일 paired-bootstrap LOCO + **제대로 된 5-ROI 부피 baseline**(약한 전뇌부피 strawman 아님)에서 deep이 fs_vol을 *CI 배제하며* 못 넘음. 과거 양성 증분은 약한 baseline artifact. 임상-라벨 정보축 **소진**(under-modeled 아님).
- **증거:** plant image-BN 0.910 ≤ morph 0.931. m2 F9 deep vs 5-ROI(동일 코호트): ADNI 0.693/**0.692**, NACC 0.713/0.707, OASIS 0.799/0.786, **KDRC 0.816/0.836(regional 더 높음)**; pooled deep>regional 단 +0.018[+0.011,+0.026]이나 exchangeability 위반. m3 외부 morph bar 0.910, 3D-VQA 0.879<bar, 56-variant 음성ledger. mi ROI→CDR AUC 0.905 vs tiny-3D-CNN 0.403.

### Molecular (IDH/MGMT, glioma — 우리 dementia 풀 밖)
- **메커니즘:** **ORACLE 수준에서 닫힘** — segmentation 의존 lesion-ROI/mask 입력(배포가능 mask-free보다 강함)조차 cross-consortium clinical-adjusted dAUC 음수. task-level 실패(분자신호 비전이)라 아키텍처로 못 구함.
- **증거:** IDH Res3DNet dAUC **−0.0405**[−0.0505,−0.0310] N=1444; oracle mask −0.0370. MGMT −0.0057. IDH-rate UTSW 28.3% vs UPENN 3.62%(7.8×). *주의: glioma 코호트는 현 전처리 풀에 없음 — 문서상 닫힘, 범위 밖.*

### Foundation / SSL / pretraining (scale·frozen-FM)
- **메커니즘:** pretraining이 얽힘을 *못 깬다* — 학습 표현이 morphometry와 *같은 방향*으로 얽히고, 공개 FM은 morph보다 *더* site-loaded면서 dx는 열세. scale은 field가 죽는 축으로 선언.
- **증거:** BrainIAC frozen site-probe **0.842 vs morph 0.770**(FM이 site 더 외움)·CN/AD AUC 0.735 vs 0.911. pretraining이 age-독립 site 주입(from-scratch ~0.71 vs full ~0.76). FM 가치 비유의(full .800±.017 vs scratch .779±.034). m3 DINOv2 frozen AJU LOCO 0.616. **사용자 from-scratch도 실패+cohort bias 심함(2026-06-20).**

### Harmonization (ComBat/GAM/N4/MixStyle/label-shift)
- **메커니즘:** **unmask가 아니라 deflate** — site==population==severity라 site 제거=population(=severity) 제거. morph LOCO bar 못 넘고, 유일 부분승(N4)은 within-scanner 한정·single-vendor서 역효과.
- **증거:** morph LOCO raw 0.916/ICV 0.923, ComBat/GAM/MixStyle 미초과. ComBat site-class 0.407→0.362≈chance(CDR↔hippo −0.297→−0.389 보존). N4 within-ADNI 0.84→0.66(chance 0.143 미달), single-vendor AJU 0.73**→0.81**(악화). label-shift ΔBA −0.024.

### ⚠️ 그러나 — *진짜로는 안 닫힌* 것 (정직)
closure 원문이 [VERIFY]/[근거부족]으로 남긴 빈틈:
- **3D CNN full-volume은 minyoung2에서 *미실행***(IMG-020/021/022가 SIGHUP detach 실패로 0 결과) → "3D가 regional을 넘나"는 *infra 실패*지 *평가*가 아님. **단 사용자의 최근 from-scratch 실패가 이 빈틈을 메우는 방향**(음성).
- **TOST 등가검정 미구현** → "음성"과 "검정력 부족" 미분리(m2 risks B3).
- molecular의 representation/pretraining framing은 명시적 open(단 glioma=범위 밖). T2-FLAIR contrastive(CMD) 미시도.
- minyoung4 excess-alignment diagnostic의 외부 traveling-subject calibration 미완(DUA 필요).

---

## 2. Korean 데이터(AJU/KDRC) 역할 — 3축에서 DECISIVE, 그 외엔 장식

**비공개·분양 데이터가 *결정적*인 곳은 정확히 셋. 과대주장이 함정.**

1. **감별/혼합병리 phenotyping (DECISIVE·고유):** AJU `aju_dx_detail` 100% — 임상의 판정 라벨로 *서양 코호트엔 없는* 축: AD without(120)·AD+small vessel(68)·AD+vascular factors(50)·Subcortical VaD(53)·Multi-infarct(15)·Vascular MCI(157)·amnestic(443) vs non-amnestic MCI(201). amyloid×dx 교차로 amyloid-음성 AD 41 등 불일치 subgroup.
2. **amyloid×WMH×다모달 *동시* 측정 (DECISIVE for rank-3):** KDRC가 같은 피험자에 정량 SUVR(856, mean 1.007 ratio)+Fazekas PV/deep(661)+FLAIR907/T2 816/DWI689/PET903. *amyloid 단독은 A4/OASIS/NACC도 보유 — Korean 고유는 amyloid×WMH×다모달 **co-location**.*
3. **leakage-clean East-Asian 외부검증 (rank-2 enabler):** AJU·KDRC 둘 다 max_pairwise_leak=0, 공개 FM 풀 미포함(추정). KDRC 단면(909=909 split-safe), AJU 1287행/1001subj(subject-split+dup collapse 필수).

**⚠️ 치명적 mismatch:** 혈관 *라벨*은 **AJU(T1 전용)**, 혈관을 *찍는* FLAIR/DWI는 **KDRC(coarse dx만)** — 한 코호트가 라벨+모달리티+종단을 동시 보유 못 함. cross-cohort bridging은 미검증 commensurability 가정.

---

## 3. ⭐ 우선순위 연구 (현 데이터 기반)

> 공통 프레임: 정확도-novelty는 닫힘 → 모든 방향은 **측정(measurement)**으로, 'SOTA 정확도'는 금지. **null이 modal 결과** → 사전등록 필수(null도 publishable). subject-level 셀 작음 → GPU 전 N 확인.

**#1 — 혼합/혈관 vs 순수-AD phenotype 분리 (morph+WMH bar 위, amyloid 조건부)** *[최우선]*
- **무엇:** amyloid-양성 내에서 'AD without'(순수) vs 'AD+SVD/vascular'(혼합)를 imaging이 fs_vol+WMH-proxy를 *같은 라벨*로 넘나. 닫힌 길(coarse dx) 재방문 아님 — *새 라벨축*.
- **데이터(subject-level 검증):** A+ 순수 **77** vs 혼합 **78**(균형 binary 가능). fs_vol 전수. *fine 4-way 혈관 staging은 사망(MID 11, strategic 6).*
- **kill-test:** deep/texture가 fs_vol+(WMH/ventricle proxy) logistic을 paired-bootstrap CI하한>0(≥5 seed)로 못 넘으면 NO-GO; class N<40이면 abort. → 음성 ledger, sweep 금지.
- **venue:** MICCAI/MedIA/Alz&Dem:DADM. **risk:** HIGH null(fs_vol이 이미 혈관축 포착 가능), AJU T1-only라 *최적 혈관 모달(FLAIR/DWI) 부재* → T1 null은 "T1엔 부피 너머 혈관신호 없음"만 증명. 라벨이 임상-consensus(imaging-influenced)라 circularity → "fs_vol bar 대비 phenotype 측정"으로 frame.

**#2 — leakage-clean East-Asian 외부검증 + GAP-DECOMPOSITION**
- **무엇:** 서양(A4+OASIS+NACC) 학습 → Korean(KDRC/AJU) 테스트, transfer gap을 amyloid-prevalence shift vs imaging-covariate shift vs 잔여 site로 분해. 산출 = *분해 프로토콜 + 측정된 East-Asian drop*(새 모델 아님). R1/R2 수용, *다른 축*(cross-ethnic).
- **데이터:** KDRC amyloid_visual 417+/492−, AJU 435+/851−, 둘 다 leakage-clean.
- **kill-test:** gap의 >50%를 한 성분에 CI배제로 귀속 못 하면(=site 지배, R1 실패모드) → 순수 음성-측정으로 강등. AD-vs-CN headline 금지(AJU CN 2.3%).
- **venue:** NeuroImage:Clinical/Frontiers Aging. **risk:** MED-HIGH(site 지배로 분해 불가 가능, drop 작을 수도 0.04~0.07).

**#3 — KDRC 다모달(T1+FLAIR+DWI) → 정량 amyloid SUVR, WMH 통제**
- **무엇:** FLAIR/DWI가 T1-fs_vol 대비 SUVR R²를 *Fazekas 통제 후* 더하나. 연속 타깃이라 dx 천장 우회. KDRC 고유 co-location.
- **데이터:** SUVR 856(ratio, 단위 확인 필수), FLAIR907/DWI689, fazekas 661.
- **kill-test:** 다모달이 T1-fs_vol을 SUVR R²(WMH 공변량)서 ΔR² CI배제로 못 넘으면 NO-GO; SUVR reference-region/단위 *먼저* 확인(불가면 visual binary로 fallback); tabular(SUVR~Fazekas+APOE+fs_vol)가 이미 설명하면 imaging arm drop.
- **venue:** HBM/NeuroImage:Clinical. **risk:** HIGH(amyloid-from-MRI 천장, DWI 689로 N -24%, education=0).

**#4 — DO-NOT-PURSUE 등록 (sunk-cost 재진입 차단)**
다음은 닫힘 — *새 out-of-pool 증거 없이 재개 금지*: (i) coarse CN/AD·CN/MCI/AD를 morph보다 잘하려는 아키텍처/SSL/FM, (ii) GRL/ComBat/MixStyle/N4/label-shift site 제거, (iii) **fine 4-way 혈관 staging**(MID 11·strategic 6 = 구조적 검정력 부족), (iv) 이 매니페스트 longitudinal conversion, (v) IDH/MGMT molecular. 게이트: 공개 biology-guided checkpoint ≥0.88(→0.91 bar) 또는 traveling-subject 확보 또는 FLAIR+감별라벨 2번째 East-Asian 코호트 없이는 미개봉.

---

## 4. 정직한 caveat + 데이터 정정

- **정확도-novelty는 닫혔다 — 명시하라.** 모든 Korean 방향은 *측정*(감별 phenotype/cross-ethnic gap/연속 biomarker 증분)으로, "우리 모델이 SOTA" 금지.
- **null이 modal 결과** — 사전등록으로 null을 registered result로(hyperparameter sweep 트리거 아님).
- **subject-level 셀 작음** — row-level이 과대계상했음. A+ 혼합 29~49 subj, 혈관 stage 6~11. binary보다 세분하면 검정력 부족. **GPU 전 N 확인.**
- **modality ⊥ labels**(검증): AJU=T1 전용+혈관라벨, KDRC=FLAIR/DWI+coarse dx. T1-only AJU null은 "T1 혈관신호 없음"만 증명.
- **임상-consensus 라벨은 imaging-influenced** → circularity 위험. "fs_vol bar 대비 phenotype 측정"으로 frame.
- **site=population은 Korean에도 제거불가**(Cramér's V 0.421). rank-2는 site 지배 가능 → registered negative로 사전등록.
- **데이터 정정(매니페스트 라이브 재확인):** ⓐ **KDRC cdrsb는 *있음*(909)** — brief의 "cdrsb 없음"은 stale. ⓑ KDRC education=0(보정 한계). ⓒ KDRC SUVR mean 1.007=ratio 단위(절대값 아님, reference 확인). ⓓ amyloid는 A4/OASIS/NACC도 보유 = Korean 고유 아님. → **datadict/README 금지, parquet 직접 조회.**

> 참조: `02_ceiling-and-baselines.md`(닫힘 ledger)·`01_data-and-bias.md`·`03_novelty-and-direction.md`·`../ledgers/`·`../DECISION_LOG.md`. 원문: minyoung2/3/4/i OBSERVATORY workspaces.
