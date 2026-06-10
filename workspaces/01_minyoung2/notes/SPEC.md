# SPEC — 3D Medical Adapter for Multimodal Brain MRI (SSOT)

> **단일 출처(SSOT).** 연구 방향·데이터·설계·전처리·계획의 유일 기준. 새 문서 만들지 않고 여기 누적 갱신.
> 이전 docs는 `docs/archive/`로 이관(SPEC으로 통합 완료).
> 갱신: 2026-06-10 · 상태: **셋업 확정 — S0(novelty 검증) 완료, S1(backbone) 착수 대기.** · 목표 venue: **ACCV**(증거기반 적합 — comparable accepted, §6) / fallback MICCAI.
> 원칙: 성능 주장 보류, 자기평가로 "완료/novelty" 판정 금지, `[VERIFY]`는 실행 전까지 사실 아님, 생성·검증 분리.

---

## 0. 한 줄 요약
**Frozen 3D T1 backbone**에 **available 모달리티(FLAIR)**와 **privileged 모달리티(PET/Centiloid, train-only)**를 **경량 3D adapter**로 주입하는 **3D medical adapter/module 개발.** 기여는 *adapter(method) 자체*이며 **ablation study가 핵심 증거**. 평가는 절대성능이 아니라 **adapter의 상대 이득 · parameter 효율 · 결측/해상도 robustness**(→ amyloid 신호 천장과 무관).

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
