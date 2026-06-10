# 선행연구 근거 — FLAIR · T2 · amyloid PET 전처리 표준

> literature-scout(WebSearch 교차확인) 기반. peer-reviewed만 인용. 검증상태 태그:
> `★★★`=저자/연도/저널 교차확인, `[VERIFY-DOI]`=논문 실재 확인·DOI 미대조,
> `[VERIFY]`=저널 논문 부재(tech report). 논문 본문 인용 전 DOI 최종 대조 권장.

## 0. 비판적 전제 (우리 데이터)

- 우리 T1w 격자(HD-BET→FastSurfer→1mm RAS→[192,224,192]→z-score)는 T1w를 reference space로
  고정한다. 합리적이나 깨질 지점:
  1. 다기관 + 2D anisotropic(T2 4–6.5mm) → 등방 resample은 **없는 해상도를 날조**.
  2. amyloid PET를 raw intensity z-score로 쓰면 트레이서/스캐너 차이가 **site shortcut**으로
     직행 (memory `scanner-site-bias-axes`, `v2-no-n4`와 충돌).
  3. cross-modal 등록 QC 없으면 오정렬 PET/FLAIR가 GT처럼 학습됨.

## 1. FLAIR

**표준 단계**: ① N4 bias(모달리티 독립) → ② rigid(6-DOF) → T1w native, cost=NMI 또는 **BBR**
(강도 불균일에 강건) → ③ **transform compose 후 단일 보간** → ④ T1w brain mask 전파(또는
SynthStrip any-contrast) → ⑤ brain-mask robust z-score(또는 WhiteStripe). Nyúl은 텍스처 변형
→ radiomics 불리, DL 분류는 z-score 통일이 안전.

**citation**
- N4ITK bias correction — Tustison NJ, et al. (2010). *N4ITK: Improved N3 Bias Correction.* IEEE TMI 29(6):1310–1320. PMID 20378467. ★★★
- BBR — Greve DN, Fischl B (2009). *Accurate and robust brain image alignment using boundary-based registration.* NeuroImage 48(1):63–72. ★★★
- WMH 전처리/평가 de-facto — Kuijf HJ, et al. (2019). *Standardized Assessment of Automatic Segmentation of WMH (Challenge).* IEEE TMI. ★★★ [VERIFY-DOI]
- FLAIR/WMH의 AD 가치 — Garnier-Crussard A, et al. (2023). *White matter hyperintensities in AD: Beyond vascular contribution.* Alzheimer's & Dementia 19. DOI 10.1002/alz.13057. ★★★
- 강도 정규화 구현 — Reinhold JC, et al. (2019). *Evaluating the impact of intensity normalization on MR image synthesis.* SPIE MI. ★★ [VERIFY-DOI]

**2D vs 3D**: 3D FLAIR(~1mm) = T1w와 동일 처리. 2D thick = through-plane PVE 큼 → native 보존,
super-resolution은 별도 검증 전 신뢰 금지.

## 2. T2 (2D 축상 4–6.5mm)

**표준 단계**: ① N4 → ② rigid → T1w(NMI/BBR) → ③ **공간 결정이 핵심**: native anisotropic 보존
+ 등록 transform만 적용 권장. 4–6.5mm→1mm 등방 resample은 **5–6배 보간 날조**. 등방 격자
강제 시 별도 인코더/2.5D가 정직. super-resolution 등방복원은 다운스트림 이득 검증 전 근거
불가 → ④ brain-mask z-score(T2 전용 표준 없음).

**citation**
- N4ITK — Tustison 2010 (위와 동일). ★★★
- thick-slice super-resolution — Zhao C, et al. (2021). *SMORE: Self-Supervised Anti-Aliasing and Super-Resolution for MRI.* IEEE TMI 40(3):805–817. PMID 33170776. ★★★ [VERIFY-DOI]
- 임상 anisotropic 등방복원 한계 — Iglesias JE, et al. (2021). *Joint super-resolution and synthesis (SynthSR).* NeuroImage 237:118206. ★★★ [VERIFY-DOI]

**AD 가치(냉정)**: T2 단독 AD-특이 정보 제한적. WMH는 FLAIR가 우월. 미세출혈/해마내부/혈관주위
공간은 고해상 T2에서나 유효하나 **우리 4–6.5mm 축상엔 부적합 해상도**. → marginal 기여,
**ablation으로 실증 후 포함**. "넣으면 좋겠지" 금지.

## 3. Amyloid PET

**표준 정량**: ① frame 정합/평균(동적→static) → ② rigid → T1w(NMI/BBR; PET는 BBR 안정) →
③ **transform compose 후 단일 보간** → ④ **whole-cerebellum reference SUVR**(Centiloid 표준) →
⑤ PVC **기본 off**(종단 정밀도 악화) → ⑥ Centiloid 변환(트레이서별 식) → ⑦ DL 입력은
SUVR clip(0–2.5/3.0) 후 [0,1].

**citation**
- Centiloid 표준 — Klunk WE, et al. (2015). *The Centiloid Project.* Alzheimer's & Dementia 11(1):1–15.e4. DOI 10.1016/j.jalz.2014.07.003, PMID 25443857. ★★★
- PVC 종단 악화 — Schwarz CG, et al. (2019). *A Comparison of PVC Techniques for Serial Amyloid PET SUVR.* J Alzheimers Dis 67(1):181–195. DOI 10.3233/JAD-180749. ★★★
- PetSurfer SGTM PVC — Greve DN, et al. (2014/2016). NeuroImage. ★★★ [VERIFY-DOI]
- 현대 파이프라인(whole cereb + single interp) — Coupé P, et al. (2025). *petBrain.* Alzheimer's Research & Therapy. DOI 10.1186/s13195-025-01839-y. ★★★
- 트레이서별 SUVR→Centiloid — Navitsky M, et al. (2018). *Standardization of amyloid quantitation with florbetapir SUVR to Centiloid.* Alzheimer's & Dementia. ★★★ [VERIFY-DOI]

**reference region 트레이드오프**: whole cerebellum=횡단/Centiloid 1순위(다기관 권장);
composite(+pons/WM)=종단 분산 감소용, 횡단 절대값 비표준.

**DL 입력**: raw 금지 → SUVR(+Centiloid). 트레이서 혼재면 Centiloid 거의 필수.

## 4. 공통 도구

| 단계 | 도구 | 근거 |
|---|---|---|
| Bias | ANTs **N4** | Tustison 2010 ★★★ |
| Linear reg | FSL **FLIRT** | Jenkinson M, et al. (2002). NeuroImage 17(2):825–841 ★★★ |
| Nonlinear | FSL FNIRT | tech report만 [VERIFY] |
| Cross-modal | **BBR** | Greve & Fischl 2009 ★★★ |
| Skull-strip(any) | **SynthStrip** | Hoopes A, et al. (2022). NeuroImage 260:119474 ★★★ |
| PET SUVR/PVC | **PetSurfer** | Greve et al. ★★★ [VERIFY-DOI] |

## 5. 우리 데이터 적용 주의 (우선순위)

1. **PET는 무조건 SUVR(+Centiloid)**. raw z-score = site shortcut 직행.
2. **트레이서 확인 선행** — AJU/KDRC 트레이서 종류를 manifest에서 실제 inspect 후 Centiloid 결정 [VERIFY].
3. **2D T2 등방 날조 금지** — native 보존, ablation으로 포함 실증.
4. **cross-modal 등록 QC 내장** — `qc_scanner_render` 패턴으로 edge overlay 확장.
5. **N4 모달리티별 독립** — T1w bias field 재사용 금지.
6. **reference space 일관성** — 분류 과제면 MNI 불필요(추가 보간 손실).
