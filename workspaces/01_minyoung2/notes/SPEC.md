# SPEC — 3D Medical Adapter for Multimodal Brain MRI (SSOT)

> **단일 출처(SSOT).** 연구 방향·데이터·설계·전처리·계획의 유일 기준. 새 문서 만들지 않고 여기 누적 갱신.
> 이전 docs는 `docs/archive/`로 이관(SPEC으로 통합 완료).
> 갱신: 2026-06-10 · 상태: **debiasing 방향 경험적 기각(D1a cosmetic·D1b payoff 부재 — site≈disease 구조적 confound). 전략 재평가 중(research-advisor). §9가 현 SSOT.** · 목표 venue: **ACCV**(증거기반 §6·§9) / fallback MICCAI.
> 원칙: 성능 주장 보류, 자기평가로 "완료/novelty" 판정 금지, `[VERIFY]`는 실행 전까지 사실 아님, 생성·검증 분리.

---

## 0. 한 줄 요약 (2026-06-10 방향 전환 — 상세 §9)
**Frozen 3D brain-MRI foundation 표현이 acquisition site를 선형 인코딩**(linear probe bal-acc 0.756 vs chance 0.379, leakage 0.377) → cross-cohort 임상 전이를 깸(S2/S3 LOCO Δ<0). 해법: **train-only 임상 scalar(amyloid/Centiloid)로 disease 부분공간을 *보호*하면서 closed-form concept erasure로 site를 제거**(privileged-guided certified erasure, backbone 재학습 0). 기여 = *erasure 메커니즘 + privileged KEEP/REMOVE governance*(scout+critic 독립 수렴). 평가 = site_leakage↓ vs LOCO 임상전이 보존, baseline=ComBat·domain-adversarial·**vanilla-LEACE(핵심 ablation)**.
> 이전 방향(FLAIR/PET adapter)은 S1–S3에서 LOCO first-win 실패 → §1–8은 그 탐색 기록(보존), **§9가 현 SSOT.**

---

## ✅ 확정 실험 셋업 (data / task / goal) — S1 착수용

### 연구 목표 (차별적 contribution)
**"Modality Adapters"** — frozen 단일모달(T1) 3D backbone에 **추가 모달리티를 끼워넣는** 경량 3D adapter. 기존 3D-medical adapter(MA-SAM, AutoProSAM = backbone을 *task/3D로 적응*)와 달리 **모달리티를 *추가***하며, 두 모드를 한 프레임에 통합:
- **(차별 hook 1) Privileged-modality adapter** — train-only 모달리티(PET/Centiloid)를 pluggable adapter로 주입·distill, 추론 시 제거(추론 비용 0).
- **(차별 hook 2) Resolution-agnostic adapter** — 같은 모달리티가 site마다 2D(5mm)/3D(1.2mm)로 달라도 한 adapter가 수용.
- + 결측-modality graceful + parameter 효율.
> 점유 선행(MA-SAM, mmFormer/ShaSpec, MMPKD)은 **baseline**이고, 차별점은 *modality-adding + 2 모드 + 해상도-이질*의 **통합**(단일 논문이 안 한 조합). tier-2 적합(§6 comparable accepted).

### 데이터 (확정)
| 용도 | 데이터 | 규모 |
|---|---|---|
| **Backbone 사전학습(SSL)** | T1 192³ 7코호트 (`official_manifest_full_n4.csv`) | **13,022** |
| **FLAIR input-adapter** | AJU good(<35mm) + KDRC good (+OASIS 편입중) | 520+409 ≈ **929** |
| **PET privileged-adapter** | ADNI SUVR (Centiloid: ADNI+OASIS) | **~649** |
| downstream 라벨 | `multimodal_manifest.csv` (amyloid-매칭 3,180) | 4코호트 |

### Task (확정)
- **Primary (FLAIR-adapter 검증):** **CDR-SB 회귀(인지)** — AJU+KDRC. 신호 충분(AJU range 0–18). FLAIR=혈관성 기여.
- **Secondary (privileged-adapter 검증):** **amyloid 분류 상대 lift** — ADNI(PET teacher).
- **보조:** brain-age 회귀.
- **평가 축:** adapter on/off **상대 이득** + #trainable params(효율) + 결측/2D↔3D robustness. (절대 baseline-win 아님 → 신호 천장 무관.)

### Backbone (확정, 2개 병기)
**B1** = 3D ViT + SSL(MAE, 13K T1) · **B2** = 3D ResNet + supervised. 둘 다 frozen → adapter만 학습. 두 backbone 재현 = backbone-agnostic 주장.

---

## 1. 연구 방향 — 왜 adapter인가 (막힌 셀 → adapter가 자산화)

### 1.1 막힌 셀 (재방문 금지)
- **amyloid 예측 method-win:** T1 외부검증 천장 ~0.62 < covariate+APOE4 baseline **0.743**(Phase1) → 어떤 method도 못 이김(이길 대상이 신호 천장 위).
- **4코호트 공유 멀티모달:** 비-T1 inference 채널이 2코호트 이상 깨끗이 공유 안 됨(FLAIR도 AJU 2D ≠ KDRC 3D).
- **MRI→amyloid PET 합성:** OCCUPIED(ShareGAN 등) + clean paired PET이 ADNI 1코호트뿐.

### 1.2 adapter 프레이밍이 이를 자산으로 전환
- **결측·이질 멀티모달 = adapter가 푸는 문제.** 코호트마다 다른 modality 가용성/해상도가 곧 testbed.
- **기여 = adapter(method).** 평가가 "amyloid AUROC로 baseline 이김"이 아니라 "adapter-on vs off 상대 이득 + param 효율 + robustness" → **천장과 분리**(critic F1 면역).
- **ACCV 적합:** 3D adapter는 architecture 기여이고, modality 조합 × backbone × task의 ablation이 vision-method 논문 형태.
- **site bias 회피:** backbone은 SSL(label無 → 도메인 robust) + frozen, adapter가 도메인/모달리티 적응 흡수 → 7코호트 supervised에서 깨지던 rep learning 문제 우회.

### 1.3 정직한 리스크 (낙관 금지)
1. **novelty = 조합형(검증 완료, §6)** — 개별요소 전부 점유 → tier-2 적합하나 reviewer에 따라 "incremental" 편차. 차별 hook(privileged+resolution-agnostic 통합)을 실험으로 또렷이 보여야 방어.
2. **signal 게이트(가장 큰 리스크)** — downstream(특히 CDR-SB)에 신호가 있어야 adapter 이득이 보임. **S1 linear-probe로 먼저 확인(없으면 task 교체).**
3. **2코호트 FLAIR** — FLAIR input-adapter 검증은 AJU+KDRC뿐 → cross-cohort 주장 약함(adapter 기여로 방어).
4. **AJU FLAIR 2D** — 253개(27%) 정합 실패, 해상도 이질 → adapter가 흡수해야 할 난점이자 리스크.

---

## 2. 데이터 현실 (직접 전처리로 확정, 2026-06-10)

### 2.1 modality 매트릭스 (inference 가용)
| modality | ADNI | OASIS | AJU | KDRC | adapter 역할 |
|---|:--:|:--:|:--:|:--:|---|
| **T1w** | ✓ | ✓ | ✓ | ✓ | **frozen backbone base** (universal) |
| **FLAIR** | (확장후보) | **△ 다운로드중** | ✓ 2D(5mm) | ✓ 3D(1.2mm) | **input-modality adapter** (AJU+KDRC, **+OASIS 편입중**) |
| **PET**(amyloid) | ✓ AV45 | ✗(scalar) | ✓ FBB/FMM | △ tracer미검증 | **privileged adapter**(train-only, ADNI) |
| **Centiloid scalar** | ✓ | ✓ | ✗ | ✗ | privileged scalar adapter(train-only) |
| T2 2D / DTI | — | — | △ | △ | **미사용**(2D 또는 AJU-only) |

### 2.2 라벨 완비도 (label table 3,180, amyloid-매칭)
| 코호트 | N | amyloid | cdr_sb | mmse | age | CDR-SB 신호 |
|---|--:|--:|--:|--:|--:|---|
| ADNI | 1203 | 100% | 100% | 100% | 99% | median 0, range 0–10 |
| AJU | 1000 | 100% | 100% | 99% | 100% | **median 2, range 0–18(치매)** ← 인지 신호 풍부 |
| KDRC | 534 | 100% | 100% | 89% | 74% | median 0.5, range 0–2(early) |
| OASIS | 443 | 100% | 100% | 100% | 100% | median 0, 대부분 정상 |
- 라벨 종류: 정량 Centiloid(ADNI/OASIS) vs visual read(AJU/KDRC). tracer: AV45/PiB/FBB/FMM 혼재.

### 2.3 핵심
- 비-T1 inference 3D 채널은 **KDRC FLAIR(1코호트)뿐**, AJU FLAIR는 2D → **adapter가 해상도 이질·결측을 흡수**하는 게 설계 목표이자 기여.

---

## 3. 연구 설계 — Adapter Framework

### 3.1 Backbone (2개 병기 — adapter가 backbone-agnostic임을 ablation으로 입증)
| ID | 구성 | 사전학습 데이터 | 비고 |
|---|---|---|---|
| **B1 (vision-flavored)** | **3D ViT + SSL(MAE)** | T1 192³ **~13K 준비분**(7코호트) | adapter 주입 자연(transformer block), B200 가능. SSL→site bias robust |
| **B2 (효율)** | **3D ResNet + supervised**(brain-age/multi-task) | 4코호트 T1 | 빠름·메모리 가벼움, adapter=conv bottleneck |
- 둘 다 **frozen** 후 adapter만 학습(param 효율 = 핵심 result). 두 backbone에서 adapter 이득 재현 = backbone-agnostic 주장.

### 3.2 Adapter 두 모드 (통합 기여)
1. **Input-modality adapter** (FLAIR): 추론에도 존재. 경량 3D 인코더 → frozen backbone에 injection(cross-attn / FiLM). **결측 코호트는 off → base만**(graceful). **2D/3D 해상도-agnostic** 설계.
2. **Privileged adapter** (PET/Centiloid): **train-only.** adapter 지식을 T1 경로로 distill, 추론은 T1만 → 추론 비용 0, site bias 0.

### 3.3 실험 매트릭스 (modality 조합 × task × backbone)
| downstream(target) | 코호트 | 비교 조합 | 검증 adapter |
|---|---|---|---|
| **CDR-SB(인지)** | AJU+KDRC | T1 / **T1+FLAIR-adapter** / T1+FLAIR(full-ft) | FLAIR input-adapter (**first win**) |
| **amyloid** | ADNI(+T1전이) | T1 / **T1+PET-priv** / T1+Centiloid-priv | privileged adapter(상대 lift) |
| brain-age(보조) | AJU+KDRC | T1 / T1+FLAIR-adapter | 일반성 |
- 각 셀: 성능 + #trainable params + 결측 degrade + (FLAIR)2D↔3D 일관성. **B1·B2 양쪽 반복.**

### 3.4 Baselines (adapter가 이겨야 할)
T1-only(frozen+head, 하한) · full multimodal fine-tune(상한) · naive early/late fusion · **PEFT(LoRA, vanilla Houlsby adapter)** · (가능시)ShaSpec/MMFormer/M3AE.

### 3.5 Ablation Study (= 핵심 기여, 사용자 지시)
우리 **3D medical adapter/module**의 설계요소를 데이터에 맞게 변형하고 on/off:
- injection 위치/방식(cross-attn vs FiLM vs bottleneck), 해상도-agnostic 모듈 on/off, privileged-distill 항 on/off, gating(결측 처리) 방식, adapter 용량(param) sweep.
- 축: **modality 조합별 · backbone별(B1/B2) · 해상도(2D/3D)별 · 결측률별 · param별.**
→ "어떤 설계가 왜 이득을 주는가"를 ablation으로 규명 = 논문의 spine.

### 3.6 Metrics
task(CDR-SB MAE/corr, amyloid AUROC 상대 lift, age MAE) · 효율(trainable params, FLOPs) · robust(missing-modality drop, 2D↔3D 일관성).

---

## 4. 데이터 상태 + 추가 전처리 (audit 2026-06-10)
| 자산 | 상태 | 추가 전처리 |
|---|---|---|
| **T1 (SSL 코퍼스)** | 7코호트 **13,022개 192³ ready**(A4 1811·ADNI 4742·AIBL 987·AJU 1287·KDRC 909·NACC 1866·OASIS 1420) | **불요** |
| **T1 (downstream)** | 3,180 amyloid-매칭 ready | 불요 |
| **FLAIR** | AJU 933(good 520)·KDRC 531(good 409) | **AJU 253(>50mm) 정리** + **OASIS FLAIR 다운로드중→편입**(amyloid-세션 매칭·2D/3D 확인·prep_flair 실행) |
| **PET teacher** | ADNI ~649 (SUVR) ready | 불요(OASIS=scalar, AJU/KDRC=후속) |
| **라벨** | amyloid/cdr_sb 100%, mmse 97%, age(KDRC 74%) | 불요(KDRC age는 보조 task만 영향) |
→ **핵심 추가 전처리 거의 없음.** 유일 항목 = AJU FLAIR 2D 정합 품질(제외/개선 결정). 선택: AJU/KDRC PET(FBB/FMM) privileged 추가 시 전처리 필요.

---

## 5. 단계·게이트 (sprint, 생성·검증 분리)
- **S0 — adapter novelty 검증** ✅(2026-06-10): 개별요소 점유=baseline, 차별=*modality-adding + privileged + resolution-agnostic + 결측-robust* 통합. ACCV comparable accepted 확인(§6). → 설계 셀 fix.
- **S1 — backbone 2개 사전학습 + freeze + T1 linear-probe baseline** `[signal 게이트, 다음 액션]`: 각 downstream(특히 CDR-SB)에 신호 있는지 확인. 없으면 task 교체.
- **S2 — FLAIR input-adapter** `[first win]`: CDR-SB에서 T1 대비 이득. 안 나오면 재설계.
- **S3 — PET privileged-adapter**: amyloid 상대 lift(절대 아님).
- **S4 — Ablation study(핵심) + baselines**: §3.5 전 축.
- **S5 — robustness(결측/2D-3D/param) + 작성.**

## 6. Novelty / 선행 (S0 검증 완료 2026-06-10)
- **개별 요소 = 전부 점유(= baseline로 사용):** 3D medical adapter(MA-SAM, **AutoProSAM/WACV2025**, 3DSAM-adapter), missing-modality(**mmFormer/MICCAI2022, ShaSpec/CVPR2023**), privileged-distillation(MMPKD, **modality distillation/WACV2022**), modality-incremental(X-Fusion, Adapter-in-Adapter/NeurIPS2024), 멀티모달 합성(M2DN/TMI2024, MISA-LDM/MICCAI2025).
- **차별 cell(조합 novelty, tier-2 적합):** *modality-adding* adapter(기존=backbone을 task/3D로 적응과 구분) + **privileged-mode + resolution-agnostic + 결측-robust 통합**. 단일 논문이 이 조합 안 함.
- **ACCV 적합 = 증거기반:** 3D 뇌 MRI multi-task(**ACCV2024** Domain-Aware 3D Swin: AD/PD/age), 3D medical adapter(**WACV2025** AutoProSAM), privileged modality distillation(**WACV2022**) 모두 tier-2 비전에 accepted → 우리와 **같은 범주**.
- **accept 결정 요인 = novelty 아니라 실험(S1/S2 이득 입증).** 잔존 리스크: 조합-novelty(reviewer 편차), 멀티모달 2코호트 scale, adapter 실제 이득 미입증 가능성.

## 7. 전처리 인프라 (완료, 재사용)
- 코드 `preprocessing/`(common·resolve_pet·prep_flair·prep_pet·run_batch·verify_tracers·qc_overlay). 정합 = **SimpleITK MI rigid multi-start**(GEOMETRY+brain-centroid, MI 최선 채택, init별 예외격리). T1w 192³ identity-affine fixed, cerebellum 참조=`roi_transfer_.../final_tensor_grid`, PET=SUVR(cerebellum). QC=centroid_mm(>35 suspect, >50 진짜bad).
- 출력 `data/preprocessed_mm/{cohort}/{sid}/{sess}/{mod}/` + sidecar `reg_qc`.
- label 재빌드 `scripts/rematch_t1_to_amyloid.py`(earliest→amyloid 최근접 ±365d), manifest `scripts/build_multimodal_manifest.py`.
- 상세 이력: §본 문서 git + 메모리 [[preprocessing-multimodal-outcome]], [[label-table-session-pairing]], [[pet-multimodal-raw-inventory]].

## 8. 출처/경로
- T1 192³: `/home/vlm/data/preprocessed_official/v2/{cohort}/subjects/{sid}/{sess}/t1w/final_tensor_n4/t1w_brain_1mm_RAS_192x224x192_n4_zscore.nii.gz`
- 전체 manifest(13K, SSL용): `/home/vlm/data/preprocessed_official/official_manifest_full_n4.csv`
- 멀티모달 출력: `data/preprocessed_mm/` · manifest `data/multimodal_manifest.csv` · 라벨 `data/amyloid_label_table.csv`(백업 `*.earliest_session_backup.csv`)
- QC: `reports/qc/*.png`, `reports/tracer_verification.md`, `reports/rematch_report.md`

> 검증 의무: 각 게이트는 독립 산출물(scout gap·linear-probe 신호·ablation 지표)로만 판정. 자기평가로 "완료/novelty" 금지.

---

## 9. 방향 전환 (2026-06-10) — adapter → frozen-representation debiasing (**현 SSOT 핵심**)

### 9.1 전환 근거 (S1–S3가 가리킨 단일 근인 = site bias)
| 실험 | 결과 | 함의 |
|---|---|---|
| **S1a** | frozen brain-age feature: **linear site bal-acc 0.756 vs chance 0.379**(leakage 0.377). CDR-SB random-split corr 0.473(site-confounded), amyloid AUROC 0.646. | frozen 표현이 site를 강하게 인코딩. |
| **S2** | FLAIR adapter: pooled +0.060이나 **LOCO Δ=-0.094/-0.039**(전이 실패). | naive adapter가 source-site nuisance에 overfit. |
| **S3** | resolution-aug: AJU fold 전이 회복(naive 0.069→robust 0.157)했으나 **어느 fold도 T1 못 넘음**(first-win 아님). | aug 메커니즘은 작동, 그러나 FLAIR 추가로는 T1 초과 불가. |
→ **모든 실패의 근인 = site/domain bias가 frozen 표현을 오염**시켜 cross-cohort 전이를 깸. "modality 추가"가 아니라 **"bias 제거 표현 학습"**이 데이터가 가리키는 방향(reframe 아님, 정정).

### 9.2 Novelty wedge (literature-scout + research-critic **독립 수렴**, 2026-06-10)
- **점유(=baseline, novelty 아님):** 목표 "site-invariant·disease-preserving frozen rep"(Moyer/MRM2020, Dinsdale/NeuroImage2021) · post-hoc frozen-FM debiasing(DNE/MICCAI2024, FairMedFM/NeurIPS2024, PRISM/ICCV2025) · 선형 concept erasure(INLP/ACL2020, RLACE/ICML2022, **LEACE/NeurIPS2023**) · privileged-info DG(EMBC2024).
- **미점유(wedge, 검증됨):** ① **closed-form *certified* 선형 site-erasure를 frozen 3D brain-MRI foundation feature에**(데모적 attribute가 아닌 site/scanner; 검색상 미점유) + ② **train-only 임상 scalar(amyloid/Centiloid)로 disease 부분공간 보호**(privileged-guided KEEP/REMOVE) → erasure **over-projection/collateral damage**(INLP 알려진 실패모드) 회피.
- **한 줄(sharpest):** *"frozen 3D brain-age feature가 site를 선형 인코딩함을 보이고(0.756 vs 0.379), privileged train-only 임상 scalar로 disease 부분공간을 보호하며 closed-form erasure로 site 제거 → backbone 재학습 없이 certified site-invariance + LOCO 임상전이 보존."*
- load-bearing 3요소 {certified-closed-form, privileged-protection, frozen-3D-medical} — 하나라도 빠지면 기존 family로 붕괴.

### 9.3 MUST-CITE baseline (반드시 비교·반드시 이기거나 동급)
1. **ComBat** (Fortin, NeuroImage 2018) — harmonization 표준. 512-d에 직접 적용.
2. **Domain-adversarial unlearning** (Dinsdale·Jenkinson·Namburete, "Deep learning-based unlearning of dataset bias for MRI harmonisation and confound removal", NeuroImage 228, 2021; DOI 10.1016/j.neuroimage.2020.117689; code: github.com/nkdinsdale/Unlearning_for_MRI_harmonisation) — iterative domain-adaptation(gradient-reversal류). post-hoc closed-form이 **재학습 없이** ≈/> 임을 보여야.
3. **vanilla LEACE/INLP (privileged 보호 X)** — **핵심 ablation·kill-shot.** vanilla가 이미 전이 보존하면 privileged 기여 死.
- "certified"는 ***선형* 한정으로 scope**(비선형 MLP probe 보고 필수). 보호자 amyloid=4코호트 100% 커버하나 AUROC 0.646(moderate); Centiloid 강하나 ADNI+OASIS만.
- ACCV로 가려면 *vision/representation* 기여(certified erasure + privileged governance) 전면화. "뇌스캔 harmonization"은 MICCAI/MedIA(순수 LEACE 적용은 top-tier reject).

### 9.4 게이트 (생성·검증 분리, critic 반영)
- **D1a [완료 2026-06-10]** `experiments/d1.py`: transductive full-strength LEACE. 결과 raw→leace: linear site **0.707→0.110**(소거✓), **MLP site 0.653→0.465**(비선형 잔존✗), within-cohort CDR **0.352→0.342**(보존✓), amyloid 0.621→0.613(보존✓). **판정 (c): "certified *linear* erasure" 헤드라인 폐기**(site가 비선형 인코딩 → 선형 소거 cosmetic). 단 **disease는 선형 site와 분리됨(보존)** → critic 최악(outcome b) 반증. proxy만 측정했고 실제 payoff(LOCO 전이)는 D1b에서.
- **D1b [완료 2026-06-10, 결정적]** `experiments/d1b.py`: 4-cohort LOCO 임상 전이. raw mean CDR corr **0.292**/amyloid **0.615**. persite-std **0.251(−0.040)**/0.584(OASIS fold 0.227→0.058 붕괴). LEACE 0.275/0.602. LEACE+privileged 0.299(+0.008)/0.604. **판정: 어떤 debiasing도 raw 초과 못 함 → payoff 부재.** 근인 = **site≈disease-stage 구조적 confound**(critic F1 실증): site 분산 제거 = disease-관련 cross-cohort 분산 제거. → **bias-removal-for-transfer 가설 경험적 기각**(메서드 아닌 데이터 구조 문제). 전략 재평가(research-advisor) 진행.
- **D2 [완료 2026-06-10] Rank-1 de-risk** `experiments/d2.py`: site≈severity를 ordinal supervision으로(advisor top-EV). within-held-out-cohort Spearman: A(direct)=0.254 / B(cohort-median ordinal)=**0.083(실패)** / C(cohort-clf)=0.103 / D(within-pct)=0.266. **판정 null**: advisor의 B는 site-clf로 붕괴, D는 A를 +0.012(노이즈)만 초과. confound-as-supervision의 method 이득 없음.
- **privileged headroom 측정 [완료]**: within-distribution Centiloid→CDR-SB: ADNI 0.416→0.500(+0.084), OASIS 0.185→0.325(+0.141). **유일한 양성 신호.** 단 Centiloid→amyloid AUROC=1.000(완전 circular → amyloid privileged 死). 정직한 privileged target=CDR뿐. 실현엔 GPU adapter 필요(frozen feature론 상한만 측정).

### 9.6 전략 재평가 결과 (research-advisor + cheap de-risks, 2026-06-10)
- **advisor 확정**: bias-removal-for-transfer 死(구조적). SSL site-invariant backbone=**low-EV**(site-invariant=severity-invariant). **cross-cohort transfer를 성공지표에서 포기**가 핵심 이동.
- **cheap de-risk(캐시 feature) 소진**: bias removal(D1a/D1b)=死 · Rank-1 confound-as-supervision(D2)=null · Rank-3 privileged Centiloid→CDR=**양성 상한(+0.08~0.14, 유일 pulse)**, 실현=GPU adapter 베팅(novelty 얇음·2코호트) · Rank-2 selective prediction=미검증(cheap 가능, diagnosis-rot 위험).
- **advisor Q5 kill 근접**: cheap 양성이 privileged(얇음)뿐 → "frozen brain-age feature + 4-confounded-cohort로 강한 ACCV method 불가" 가능. 필요 변화 = site·severity가 *crossed*된 데이터(현 4코호트엔 없음).
- **결정 지점**: (i) privileged adapter(Rank-3) GPU 투입 / (ii) Rank-2 selective prediction cheap de-risk / (iii) scope·data·venue 재고. → 사용자 판단: **(i) 선택**.

### 9.7 최종 종합 — 모든 구체적 방향 소진 (2026-06-10)
- **P1 [완료] privileged adapter gate** `experiments/p1.py`: ADNI within-cohort 5-fold, baseline(λ=0) vs privileged(Centiloid distill λ=0.5). mean CDR **0.326→0.337(Δ+0.011, 노이즈)**. sizing(T1→Centiloid recoverability 0.266) 예측대로 **null**. adapter baseline(0.326)이 frozen-linear(0.416)보다도 낮음(overfit). → privileged 死.
- **D3 [완료] bias-removal 재실험(confound-free)** `experiments/d3.py`: ADNI-internal site는 crossed(eta²=0.045) + leakage 존재(linear 0.147 vs chance 0.042). grouped-site LOCO: raw CDR **0.425** vs persite-std 0.368/leace 0.361/leace_priv 0.387 — **전부 raw 이하(−0.04~−0.06)**. → **confound이 없어도 debiasing이 전이를 악화** → "confound 때문" 가설 반증 → **bias-removal thesis 근본적으로 死**(confounded·crossed 양쪽 모두).
- **종합 kill(advisor Q5 발동, 데이터로 강제):** amyloid(ceiling) · FLAIR adapter(전이 死) · bias-removal(D1b confounded + D3 crossed 양쪽 死) · confound-as-supervision(D2 null) · privileged adapter(P1 null). **현 frozen brain-age backbone + 4코호트로는 이 angle들에서 강한 ACCV method 불가**(소진적 경험 검증).
- **공통 실패 인자:** ① 모든 게 cross-site/cohort 전이에서 죽음 ② frozen brain-age backbone(site-biased·약한 임상신호, T1→amyloid 0.646 천장) ③ 절대 ceiling. → 바꿔야 할 것 = backbone(표현 자체) 또는 problem framing 또는 venue. **다음 결정 사용자 판단 필요.**

### 9.5 정직한 리스크 (낙관 금지)
1. **가장 큰 리스크(critic):** frozen brain-age backbone은 disease/site 분리를 학습한 적 없음 → 선형 erasure가 LogReg만 속이고 disease는 붕괴(outcome b/c) 가능. **D1a가 오늘 판정.**
2. **scout 경고:** vanilla LEACE가 전이까지 고치면 privileged 기여 소멸 → D1b에서 vanilla가 *under-deliver*해야 paper 성립(좁은 창).
3. **venue:** ACCV-native neuroimaging-harmonization 선례 희박 → 실제 경쟁은 MICCAI/MRM. vision-method 프레이밍 필수.
4. **보호자 신호 강도:** amyloid AUROC 0.646(moderate) → 보호 부분공간 noisy 가능. Centiloid(강)는 2코호트뿐.

---

## 10. 방향 재전환 (2026-06-11) — ROI dissociation → anatomy-guided representation learning (**현 SSOT 핵심**)

### 10.1 발견 계기 (ROI 자산)
사용자 질문 "ROI 기반 주제도 같은 문제인가?"에서 DKT+aseg parcellation(96라벨, 100% 커버)으로 regional volume+intensity feature(190d) 추출 후 동일 LOCO 프로브 비교 → **counterintuitive dissociation 발견.**

### 10.2 핵심 발견 = DISSOCIATION (novelty wedge, scout 확정)
- **ROI(hand-crafted anatomy) feature가 learned deep feature보다 cross-cohort 전이가 좋음 — site bias는 *더 큰데도*.**
- `roi_probe.py`: ROI vs CNN — site leakage 0.829 vs 0.707(↑), CDR LOCO **0.420 vs 0.292**(↑), amyloid LOCO **0.705 vs 0.615**(↑).
- **G3 rigor** `g3.py`: 차원 매칭(PCA 50/100/190)+선형/비선형 probe 후에도 견고. d100: ROI site 0.81/0.80 & transfer 0.42/0.72 vs CNN site 0.68/0.67 & transfer 0.30/0.63. → "deep가 site bias 낮은 건 artifact" 공격 차단(kill-shot #1 해소).
- **함의:** site-invariance와 clinical-transferability는 별개 축. (이것이 §9 debiasing이 무의미했던 근본 이유: site 제거 ≠ 신호 개선.)
- scout: novelty = **dissociation 발견**(메커니즘 region-pool/distill은 점유). 한줄 thesis: *"LOCO에서 hand-crafted anatomy가 deep보다 전이↑(site bias↑인데도) → 두 축 dissociation → anatomy-guided learning으로 gap을 메운다."* 최대 경쟁자 = DAMT(ACCV2024, 단 pooled eval·age 중심). MUST-CITE: DAMT, Brain Informatics 2024(morphometric vs deep, age서 parity), Swin UNETR(CVPR2022).

### 10.3 GAP 실험 프로그램 (T1-only LOCO CDR corr, 4-fold)
| 실험 | 표현 (추론 요구) | LOCO CDR | 메모 |
|---|---|--:|---|
| **ROI-vol** (hand-crafted) | FreeSurfer 필요 | **0.420** | 전이 상한(anatomy) |
| G1 `g1.py` e2e global | T1-only | 0.276 | **overfit**(train 0.99/test 0.28) |
| frozen brain-age | T1-only | 0.292 | |
| G4 `g4.py` ROI-distill(aux) | T1-only | 0.260 | null(+0.008) |
| G2 `g2.py` region-pool | parcellation(추론) | 0.321 | +0.075 vs global, 단 ROI-vol에 dominated |
| **G5 `g5.py` anatomy-pretrain** | **T1-only** | **0.349** | **최고 T1-only**(std-deep +0.07, ROI 격차 ~절반) |
| G6 `g6.py` richer+combo | — | 진행중 | richer target / feat+ROIvol이 0.42 초과? |

### 10.4 최종 판정 (GAP 프로그램 G1–G7 완료 + code-auditor 감사, 2026-06-11)
**Diagnosis + Fix 양쪽 성립. 모두 leakage-free 감사 통과.**
- **Diagnosis(G3, honest inductive PCA): 단단.** 차원 매칭(50/100/190)+선형/비선형 probe+train-only PCA 전부에서 ROI가 site-leak↑(0.77~0.83) AND transfer↑(CDR 0.39~0.42, amy 0.69~0.71) vs CNN(site 0.64~0.70, CDR 0.29~0.31, amy 0.62~0.64). site-invariance ⊥ clinical-transferability.
- **왜(G1):** e2e deep는 source cohort 암기(train 0.99/test 0.28) → 전이 실패.
- **Fix(G5): anatomy-prediction pretraining = 최고 T1-only(0.349)**, 표준 deep(0.28~0.29) +0.06~0.07.
- **anatomy-specific(G7 control): real 0.349 ≫ shuffled 0.250 ≈ random 0.271** → 이득은 *해부 내용* 때문(일반 pretrain 아님). "그냥 pretraining" 반박 차단.
- **method가 hand-crafted 초과(G6): anatomy-pretrain feat + ROI-vol = 0.440 > ROI-vol 0.420**(양 seed 0.438/0.442) → deep가 anatomy에 보완적 texture 추가(이전 ROI+brain-age-CNN은 0.381로 해쳤음 — anatomy-pretrain이 deep를 transfer-robust 보완재로 전환).
- **감사(code-auditor): label leakage 없음.** C1(캐시 정렬) 실측 일치+assert 추가, C2(transductive PCA) train-only로 수정(수치 거의 불변, 결론 견고).

### 10.5 표준 표 (T1-only LOCO CDR corr, 4-fold cross-cohort)
| 표현 | LOCO CDR | 추론 |
|---|--:|---|
| ROI-vol(hand-crafted) | 0.420 | FreeSurfer 필요 |
| **combo: anat-pretrain + ROI-vol** | **0.440** | FreeSurfer+T1 |
| **anat-pretrain(G5)** | **0.349** | **T1-only** |
| frozen brain-age | 0.292 | T1-only |
| e2e global(G1) | 0.276 | T1-only |
| random-target pretrain(control) | 0.271 | T1-only |
| distill aux(G4) | 0.260 | T1-only |
| shuffled-anat pretrain(control) | 0.250 | T1-only |

### 10.6 남은 보강 (논문 전)
- multi-seed CI 전 headline(현 G6만 2seed) · DAMT(ACCV2024) 대조 baseline · 더 강한 backbone(사용자 리소스 가용)로 gain 확대 가능성 · amyloid 전이(ROI 0.705)도 동일 분석 확장.

### 10.7 research-critic 검증 + REFRAME (2026-06-11) — **현 포지셔닝**
**critic 평결: 현 "dissociation primary" 포지셔닝은 ACCV reject(MICCAI-better/workshop). 핵심 이유:**
- **F1**: "hand-crafted>deep cross-cohort"은 radiomics folklore(Currin/PMC10606594) + **반대 논문 존재**(Lu et al./SciRep2022: 3D CNN>ROI on external NACC). 둘 다 미인용 → 최유력 reject.
- **F2**: DAMT(ACCV2024)가 우리 메커니즘(anatomy/morphology/radiomics 예측 pretrain)을 이미 함; 우리는 strict subset. **DAMT/강한 SSL을 LOCO로 안 돌리면** fix도 dissociation 절반도 방어 불가(weak-baseline strawman).
- **F3**: n=4, CI 없음. (→ stats_hard로 대응 완료)
- **M1**: fix(0.349)<FreeSurfer(0.420). combo(0.440)는 FreeSurfer 입력 필요+고작 +0.02. "hand-crafted 이긴다" 주장 금지.
- **M3(핵심)**: **debiasing 반증(site-invariance≠transferability, crossed-design D3)이 dissociation보다 더 novel** → 헤드라인 뒤집어야.

**REFRAME (채택):**
- **PRIMARY 주장**: *"site-invariance ⇏ cross-cohort clinical transferability"* — (a) debiasing이 전이 개선 못 함(D1b confounded + **D3 crossed-design**, confound 깨도 死) + (b) dissociation(anatomy가 site-bias↑인데 transfer↑)으로 경험적 반증. harmonization 통념 직접 반례.
- **SUPPORTING**: dissociation(특히 **amyloid 4/4 견고**, stats_hard) · **G7 content-specificity**(real 0.349≫shuffled 0.25, vision-legible 최강 ablation).
- **fix = existence proof**(method 주장 아님): anatomy-pretrain, 강한 SSL/DAMT 대비 위치 확인 중.

**진행 중 보강(사용자 승인 "강한 baseline+반증 reframe+stats"):**
- ✅ stats_hard: per-cohort CI+leave-one-cohort. **amyloid 4/4 ROI>CNN 견고**, CDR 3/4(ADNI 예외, CI 겹침).
- 🔄 강한 SSL(SimCLR/ResNet18, ext 4664) LOCO — dissociation 생사 판정(ROI 따라잡으면 붕괴).
- ⬜ DAMT 공개코드 재현(출판 필수) · Lu/Currin 인용·반박 · amyloid를 2nd axis로.
- **honest 확률**: 현재 MICCAI>ACCV. 강한 SSL 생존+반증 reframe+DAMT면 ACCV 경합.
