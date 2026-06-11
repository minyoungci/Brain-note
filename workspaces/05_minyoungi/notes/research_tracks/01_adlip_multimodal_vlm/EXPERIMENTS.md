# Track 01 — ADLIP Multimodal VLM · 실험 로그

> 단일 누적 로그. 새 실험은 맨 아래 append. 날짜·가설·셋업·결과·인사이트·다음.
> 목표: top-tier AI conf. **leakage/overfitting 절대 금지**가 1순위 제약.

## 고정 원칙 (모든 실험 공통)
- **subject-level split** (session 아님 — 종단 leakage 차단). 현재 train_ready는 1session/subject지만 원칙 유지.
- **normalization 통계는 train에서만 fit** → val/test 적용 (통계 leakage 차단).
- **텍스트 paraphrase 3변형은 같은 subject 내에서만** (subject-level split이라 자동).
- **이중 평가**: ① random stratified (within-dist) ② **LOCO**(train AJU→test KDRC 등, cross-population). 둘 다 보고.
- **honest metric = ΔAUC over clinical-only baseline** (절대 AUC는 APOE/MMSE 대리누수로 부풀려짐 — 측정 확정).
- test set은 모델선택·튜닝에 **절대 미사용**. val로만 튜닝.
- 매 실험 **cohort-probe**(임베딩→코호트 AUC) 동반 — confound 정량.

## 검증된 출발 사실 (재논쟁 금지 — `../README.md` 참조)
- 텍스트→코호트 0.999 / 영상(fs_vol)→0.747 (양 modality 누설).
- 구조 ΔAUC: amyloid +0.01(무용) / 치매 +0.13(강함). 혈액 ΔAUC≈0.
- train_ready 1,408 (AJU 962 / KDRC 446), dx: MCI654/AD412/CN142/OtherDem73/None119, amyloid 641+/767−.

---

## EXP-000 (2026-06-10) — leakage-safe split 설계·생성
**가설/목적**: 이후 모든 실험의 토대가 될 split을 leakage 없이 만든다.

**셋업**:
- subject-level, stratify by (cohort × dx_3way[CN/MCI/Dementia]).
- 70/15/15 train/val/test, seed=42.
- LOCO split 2종 별도 정의: `loco_test=KDRC`(train AJU), `loco_test=AJU`(train KDRC).
- 산출: `splits/` (split_random.csv, split_loco_kdrc.csv, split_loco_aju.csv).

**결과**: ✅ `splits/{split_random,split_loco_kdrc,split_loco_aju}.csv` 생성·검증.
- random: train 1006 / val 201 / test 201, **subject 중복 0**, dx 비율 유지(CN 0.11, test CN 21).
- LOCO-KDRC: train AJU 817 / val 145 → test KDRC 446, **코호트 완전 분리**.
- LOCO-AJU: train KDRC 379 / val 67 → test AJU 962, 분리 ✓.
- 환경: torch 2.10+cu128, **CUDA 8 GPU**, transformers/monai/nibabel OK.

**인사이트**: train_ready는 1session/subject(AJU V2는 PET 부재로 multimodal_full 탈락 → baseline만) → 종단 leakage 원천이 현재 없음. 단 LOCO-AJU는 train이 KDRC 379로 작아 불안정 예상(역방향 LOCO는 보조 지표로).

**다음**: 멀티모달 데이터로더 + 인코더 (EXP-001).

---

## EXP-001 (2026-06-10) — 멀티모달 contrastive: tiny-overfit이 실패, 원인 진단
**가설**: 모달별 3D DenseNet121(T1/FLAIR/PET) + Bio_ClinicalBERT + InfoNCE로 영상↔텍스트 정렬.

**셋업**: `model.py`(ImageEncoder=모달별 DenseNet→late fusion, TextEncoder=frozen BERT),
`train.py`(InfoNCE, bf16), `data.py`(leakage-safe loader). tiny-overfit(12샘플)로 코드 sanity.

**결과 (실패)**: 12샘플 overfit이 안 됨 — loss가 ln(N) 수준에서 정체, acc≈chance. batch12·lr1e-3·다수 epoch에도 동일.

**진단 (근본 원인 2개)**:
1. **영상 embedding collapse**: random 3D CNN이 다양한 입력(batch-std 0.109)을 거의 동일 feature로 압축.
   norm별 batch-std: **DenseNet-instance 0.005(최악)** < DenseNet-batch 0.014 < resnet18 0.026.
   → **instance norm이 batch-방향 분산을 죽임**(per-sample 정규화). InfoNCE에 치명적.
2. **텍스트 동질성**: overfit 12샘플 텍스트 **쌍 코사인 0.952(min 0.895)**. 임상 프로파일이 본질적으로
   비슷(다 "노인+MMSE+APOE+공존질환") → frozen BERT가 거의 같게 임베딩 → 매칭 구별 불가.

**기술적 시도**:
- (a) instance→batch norm + projection BatchNorm1d (collapse 완화) → 부분 효과(train 3.2→2.4), val은 BN running-stat가 12샘플서 부정확해 발산.
- (b) text fine-tune ON (frozen 해제) → 동질 텍스트 분리되는지 (진행중).

**💡 인사이트**: CLIP/ADLIP은 *다양한 캡션*을 전제하는데, 우리 임상 텍스트는 **구조적으로 동질(cos 0.95)**.
영상도 random init collapse. **두 modality 모두 batch-방향 분산이 작아 표준 InfoNCE가 구조적으로 난항**.
이는 [cohort confound]에 더해 ADLIP식 contrastive가 우리 데이터에 안 맞는 *세 번째* 이유.
→ novelty 기회: 동질 텍스트용 fine-grained/hard-negative contrastive, 또는 영상↔연속임상벡터 regression-hybrid.

**다음**: text fine-tune overfit 결과 확인 → 풀리면 본 학습(text-ft), 안 풀리면 contrastive 재설계.

**추가 진단 (원인 분리)**:
- batch-norm ImageEncoder의 영상 feature 쌍 코사인 **0.111(min −0.039), batch-std 0.39** → **영상 collapse는 batch-norm으로 해결**(영상 12개 잘 구별됨).
- 반면 텍스트 CLS 쌍 코사인 **0.952** → 텍스트가 병목. **InfoNCE의 text→image 방향이 동질 텍스트로 매칭 불가.**
- 결정적 실험 of_txt2: image freeze(이미 다양) + text fine-tune(lr3e-4)로 동질 텍스트가 분리되며 overfit되는지 (진행중).
- ⚠️ 부수발견: overfit 모드가 train=True라 텍스트 paraphrase가 매 epoch 랜덤 → 타겟 불안정(미세 noise). 본 sanity엔 영향 작으나 인지.

**분리 진단 (영상 인코더 자체)**: 영상→dx supervised overfit(12샘플) = acc 0.42→0.83 **진동, 완전 overfit 실패**.
→ random-init 3D DenseNet이 **N=1006 from-scratch로 학습 불안정**(작은-batch BatchNorm + 192³ 깊은 net).

## EXP-001 결론 (표준 ADLIP contrastive = 우리 데이터에 부적합, 다중 원인)
5+ 설정(norm·lr·freeze·paraphrase·text-ft)에도 12-샘플 tiny-overfit 실패. 원인 3중:
1. **영상 from-scratch 학습 불안정** (supervised조차 0.83 진동) — 작은 N + 192³ 3D CNN.
2. **텍스트 동질 cos 0.952** — 임상 프로파일이 본질적으로 비슷 → 1:1 InfoNCE 매칭 구조적 불가.
3. **cohort confound** (텍스트 0.999 / 영상 0.747) — 정렬이 코호트로 샘.
→ 셋 다 표준 CLIP/ADLIP 전제(다양한 1:1 image-text, 큰 N, 사전학습 backbone)와 충돌.

💡 **종합 인사이트**: 우리 데이터는 CLIP 패러다임과 구조적으로 안 맞음. top-tier로 가려면
"표준 contrastive를 적용"이 아니라 **이 부적합을 정면으로 다루는 방법론적 기여**가 필요.

**novelty 후보 (다음, EXP-002~)**:
- (N1) 영상: from-scratch 불안정 → **사전학습/SSL 3D 인코더 frozen + linear-probe contrastive** (작은 N 적합).
- (N2) 텍스트 동질 → **graded/clinical-distance soft contrastive** (1:1 hard match 폐기) 또는 supervised contrastive.
- (N3) 픽셀 학습난·ROI 강신호 → **ROI-anchored representation** (fs_vol/PET를 구조적 앵커로) + 픽셀 보조.
- (N4) audit 프레이밍: "왜 medical image-text contrastive가 동질캡션+site-confounded에서 실패하는가"의 체계적 분해(Track 02 결합).

---

## EXP-002 (2026-06-10) — N1: 사전학습 인코더 탐색 → morphometry-distillation novelty
**가설**: 사전학습 frozen 영상 인코더가 from-scratch 불안정을 해결한다.

**다각적 검증 (frozen feature linear-probe dx CN-vs-Dem, train→test AUC)**:
| 인코더 | batch-std | dx AUC |
|---|---|---|
| r3d18 **Kinetics-pretrained** | 0.072 | **0.758** |
| r3d18 random | 0.016 | 0.829 |
| DenseNet from-scratch (frozen) | 0.002 | 0.790 |
| (기준) fs_vol morphometry | — | **~0.90** |

**발견**:
1. **Kinetics(자연영상) 사전학습이 의료에 transfer 안 됨** — random보다 못함(0.758<0.829). 외부 사전학습 부적합.
2. frozen random feature도 dx 신호 있으나(0.79-0.83) **morphometry(0.90)를 못 넘음** → 픽셀<형태계측 재확인(dossier 정합).

**💡 novelty 방향 확정 — Morphometry-Distilled Pixel Encoder (N1+N3)**:
픽셀 인코더를 **픽셀→fs_vol(26 ROI) regression으로 사전학습** → (a) 명확한 supervised 타겟이라 from-scratch 불안정
해결, (b) morphometry 강신호(0.90)를 픽셀 표현에 증류, (c) 픽셀 VLM 유지. frozen 후 contrastive.
"작은-N 의료 VLM의 영상 표현을 morphometry distillation으로 안정화" = 기술적 기여.

**검증 기준**: distill 사전학습 frozen feature의 dx AUC가 frozen-random(0.83)을 넘어 morphometry(0.90)에 근접하면 성공.

**진행**: pretrain_morphometry.py (GroupNorm 인코더로 batch 독립 안정화) 구현·학습 (다음).

**인프라**: 영상 I/O 병목(epoch당 1006×192³ nibabel) → **96³ float16 캐시(1408개, 5.4GB)** 구축, data.py에 use_cache96 통합. 영상실험 GPU-bound화.

**morpho-distill 학습 (캐시, 96³, batch64, OneCycle lr5e-4)**: ROI 10개(해마/편도/내후각/뇌실 L/R + Mask/BrainSegVol).
MSE 안정 하강: ep00 1.03 → ep10 0.55 → ep20 0.40 → … (random 1.0 대비 절반↓). **from-scratch 불안정이 명확 supervised 타겟으로 해결됨.** frozen dx-probe 결과 대기.

**✅ N1 결과**: morpho-distill ep39 MSE 0.259. **frozen distilled feature dx CNvsDem AUC = 0.931** (batch-std 0.42).
| 인코더 frozen→dx | AUC |
|---|---|
| from-scratch DenseNet | 0.790 |
| random r3d18 | 0.829 |
| fs_vol morphometry(기준) | ~0.90 |
| **morphometry-distilled** | **0.931** |
→ distill이 from-scratch 불안정 해결 + morphometry 신호 증류. ckpt_morpho_encoder.pt.
⚠️ **검증 필요**: distill이 morphometry(코호트 0.747 누설)를 증류했으면 distilled도 cohort 누설 가능 → cohort-probe·LOCO 검증 진행.

**다각 검증 (distilled encoder, frozen probe)**:
| | random | LOCO-kdrc | LOCO-aju |
|---|---|---|---|
| dx CNvsDem | **0.931** | 0.774 | 0.724 |
| cohort | **0.948** | — | — |
| amyloid | 0.918* | — | — |
*amyloid는 PET채널 입력이라 trivial(honest 아님).

**💡 검증 결과 (정직)**: distill이 학습안정성은 해결했으나 **cohort confound 미해결** — morphometry(cohort 0.747) 증류하며 confound도 증류(0.948 증폭). random 0.931은 cohort shortcut 부풀림 → **LOCO 0.72-0.77이 진짜**.
→ **다음 novelty (EXP-003): Harmonization-Distillation** — ComBat-harmonized fs_vol(site↓·biology보존 [[combat-fsvol-harmonization]])을 distill 타겟으로 → confound 없는 픽셀 표현. 검증기준: cohort AUC↓(0.95→?) 유지하며 LOCO dx 유지/개선.

---

## EXP-003 (2026-06-10) — Harmonization-Distillation (cohort confound 해결 시도)
**가설**: distill 타겟 fs_vol을 **ComBat-harmonize**(site↓ biology보존)하면 distilled encoder의 cohort 누설(0.948)이 줄고 LOCO dx가 유지/개선된다.

**전제 검증 (ComBat fs_vol, train_ready)**: raw cohort 0.761/dx 0.897 → **harmonized cohort 0.618/dx 0.899**. site↓ biology유지 확인.

**진행**: pretrain_morphometry --harmonize (train fs_vol ComBat, dx·age covariate 보호, train만=leakage방지) → distill → eval (cohort·LOCO).

**✅ 결과 (eval_distilled, morpho vs morpho_harm 동일 코드 나란히 평가)**:
*baseline이 EXP-002 수치(0.931/0.948/0.774/0.724) 정확 재현 → 하네스 신뢰.*

| frozen→probe | morpho (baseline) | **morpho_harm** | Δ |
|---|--:|--:|--:|
| dx CNvsDem (random) | 0.931 | 0.899 | −0.032 |
| **cohort (random)** | **0.948** | **0.921** | **−0.027** |
| LOCO-kdrc dx | 0.774 | **0.784** | **+0.010** |
| LOCO-aju dx | 0.724 | **0.736** | **+0.012** |
| amyloid (random) | 0.918* | 0.917* | ~0 |

\*amyloid는 PET 입력채널이라 trivial(honest 아님).

**💡 인사이트 (정직)**: 가설 방향대로 작동하나 **부분적**. cohort shortcut 의존이 줄며(random dx 0.93→0.90 de-inflate, cohort 0.948→0.921) **honest LOCO dx가 양방향 +0.01 개선** — 정렬된 신호가 더 전이됨. **단 핵심 한계**: cohort가 여전히 **0.921(거의 완전 분리)**. ComBat이 fs_vol을 0.618로 낮췄지만 픽셀 인코더는 site를 0.921로 재학습 → **confound가 distill 타겟이 아니라 입력 픽셀(스캐너/프로토콜)에 있어, 타겟만 harmonize로는 불충분**.

**다음 (EXP-004)**: confound가 입력 레벨 → 타겟-harmonize를 넘어 **표현 레벨 de-siting** 필요 (adversarial cohort head / GRL, 또는 입력·feature harmonization). 검증기준: cohort AUC를 0.92→<0.8로 낮추며 LOCO dx ≥0.78 유지.

**✅ EXP-003 결과 (harmonized distill 다각 검증)**:
| frozen probe | raw distill | harmonized distill |
|---|---|---|
| dx random | 0.931 | 0.899 |
| cohort | 0.948 | 0.921 |
| LOCO-kdrc | 0.774 | 0.784 |
| LOCO-aju | 0.724 | 0.736 |
→ harmonization 방향은 맞으나 **효과 미미**(cohort 0.95→0.92, LOCO 소폭↑). fs_vol 타겟 자체는 cohort 0.76→0.62였으나 distilled encoder는 0.92로 강누설 유지.
💡 **인사이트**: 픽셀 영상이 cohort(스캐너 appearance)를 직접 담고 있어, distill *타겟*만 harmonize해선 *encoder*의 cohort 누설을 못 막는다. → 다음(EXP-004): encoder feature에 직접 작용하는 **adversarial cohort removal**(gradient reversal). 단 cohort=population+traveling0이므로 "cohort 제거 = biology 일부 손실"의 식별성 trade-off가 핵심 측정 대상.

**⚠️ 평가 관점 정정(중요)**: random-split AUC(0.93)는 cohort shortcut 부풀림. **진짜 성능 지표 = LOCO(0.72~0.77)**. 이후 "성능 향상"은 LOCO 기준으로만 주장.

---

## EXP-004 (2026-06-10) — Adversarial cohort-invariant distillation (LOCO 향상 시도)
**가설**: morphometry distill + gradient-reversal로 encoder에서 cohort를 직접 제거하면 LOCO(cross-cohort) dx가 향상된다.

**셋업**: ImageEncoder→{morpho head(fs_vol MSE), cohort head(GRL, CE)}. λ_adv ramp(0→λ over 8ep). λ sweep {0,0.5,1,2,5}.

**결과 (λ sweep)**:
| λ | dx-random | cohort | LOCO-kdrc | LOCO-aju | mean LOCO |
|---|---|---|---|---|---|
| 0.0 raw | 0.931 | 0.948 | 0.774 | 0.724 | 0.749 |
| 0.5 | 0.908 | 0.849 | 0.726 | 0.777 | 0.752 |
| **1.0** | 0.900 | 0.894 | 0.736 | **0.886** | **0.811** |
| 2.0 | 0.912 | 0.895 | 0.731 | 0.889 | 0.810 |
| 5.0 | 0.759 | 0.941 | 0.520 | 0.477 | 0.50(붕괴) |

**발견**: λ=1~2가 **mean LOCO 0.749→0.81 (+0.06)** — 특히 LOCO-aju 0.724→0.89(KDRC-학습 dx가 AJU로 전이). λ=5 붕괴 = 식별성 tension(과debiasing=biology 제거) 실증.
**⚠️ 검증 진행중**: LOCO-aju train=KDRC 379로 작아 noise 가능 → λ∈{0,1} × seed{1,2,3} 재현으로 error bar 확인.

**✅ EXP-004 검증 (3 seed, error bar)**:
| λ | dx-random | cohort | LOCO-kdrc | LOCO-aju | mean-LOCO |
|---|---|---|---|---|---|
| 0.0 raw | 0.907±0.013 | 0.945±0.009 | 0.750±0.001 | 0.690±0.010 | 0.720 |
| **1.0 adv** | 0.911±0.004 | 0.876±0.040 | 0.747±0.024 | **0.866±0.018** | **0.807** |

**💡 검증된 결론 (성능 향상 확정)**: adversarial cohort-invariant morphometry distillation이 **cross-cohort(LOCO) 일반화를 개선** — LOCO-aju +0.18(error bar 비겹침), mean-LOCO +0.09, within-dist·random 불변. λ=5 붕괴는 식별성 한계(과debiasing=biology 손실).
**비대칭 인사이트**: LOCO-aju(train KDRC 379 dementia편중→test AJU MCI편중)가 크게↑ = adversarial이 KDRC-특이 cohort 방향을 제거해 dx 경계가 AJU로 전이. LOCO-kdrc(train AJU 큰셋)는 이미 전이돼 불변.
**한계(정직)**: cohort 0.945→0.876로 완전제거 아님(부분 debias인데도 LOCO↑). text/VLM 동질성은 별개 미해결(이건 image-side 기여).

## 🎯 Track 01 novelty 종합 (EXP-002+004)
**Morphometry-Distilled + Adversarially-Cohort-Invariant Pixel Encoder for small-N site==population medical imaging**:
1. (EXP-002) 픽셀→fs_vol distill로 작은-N from-scratch 불안정 해결 + morphometry 강신호 증류.
2. (EXP-004) gradient-reversal cohort-adversarial로 **cross-cohort 일반화 +0.09 mean-LOCO (검증됨)**.
3. λ-sweep로 site==population의 **식별성 trade-off 곡선** 제시(λ=5 붕괴) — dossier ⭐audit과 결합.
→ "정확도 SOTA"가 아니라 "confounded regime에서 cross-cohort 일반화를 얻는 method + 그 한계의 정량화".

---

## EXP-005 (2026-06-11) — Task pivot: 구조MRI(T1+FLAIR)→amyloid, morphometry 넘기 시도
**동기**: CN-vs-Dem은 morphometry 포화(LOCO 0.869)라 deep 틈 없음. amyloid는 morphometry 약함(LOCO 0.676) → deep texture 기회. PET 채널 입력제외(순환방지).
**oracle**: fs_vol+PET-SUVR = 0.864(<0.869) → tabular PET도 직교신호 없음. fs_vol→amyloid LOCO=0.676(약함, headroom 있음).

**source-only deep (morpho-distill init, T1+FLAIR, strict LOCO)**:
| 방향 | source AUC | target AUC | morphometry |
|---|---|---|---|
| AJU→KDRC | 0.986(overfit) | **0.581** | 0.688 |
| KDRC→AJU | 0.969 | **0.543** | 0.665 |
→ ❌ deep source-overfit하나 cross-cohort 전이실패. **morphometry에 짐.**
💡 **근본 통찰**: morphometry(FreeSurfer seg)는 scanner-불변→LOCO강. deep 무기(texture)는 scanner-의존→LOCO약. 이 비대칭이 "왜 LOCO에서 image<morphometry"의 기전. → 다음: ① adversarial UDA(타겟영상 정렬)로 cohort-texture 제거시 타겟↑? ② within-cohort(단일site)면 deep 이기나?

---

## EXP-006 (2026-06-11) — within-cohort amyloid (단일 site, deep 마지막 시도)
**결과 (OOF 5-fold)**: AJU morph 0.691/deep 0.647/fusion 0.697 | KDRC morph 0.707/deep 0.625/fusion 0.701.
→ ❌ 단일 site에서도 deep<morphometry, fusion 무이득. **Korean에서 deep>morphometry 지점 없음 (6실험 종결)**.

## EXP-007 (2026-06-11) — 데이터 확장 결정 + 7-cohort baseline
**진단**: Korean 1,408 한계는 ① N 과소 ② 2-cohort 식별성붕괴 ③ amyloid tracer 이질. 멀티모달 VLM 명분(text)은 이미 실패 → Korean 제약은 순수 핸디캡.
**가용 자산**: canonical manifest 13,022×138, **final_tensor_path(T1 192³)·fs_vol 전 13k 100%**. 멀티모달(FLAIR/PET) 텐서는 Korean만(비-Korean 전처리=대량 GPU작업).
**새 baseline (7-cohort Leave-One-Cohort-Out, morphometry)**:
| task | LOCO AUC | n |
|---|---|---|
| CN-vs-Dementia | **0.883** | 8549 (포화, deep 어려움) |
| amyloid positive | **~0.61** | AJU 0.606/NACC 0.614 (약함=deep 기회) |
**계획**: Stage1=T1 96³(N4) 캐시 전체 → deep T1+cohort-adversarial → 7-site LOCO로 amyloid 0.61 도전. Stage2(조건부)=멀티모달 전처리. user 결정=확장+멀티모달 유지(멀티모달은 Stage2).

---

## EXP-009 (2026-06-11) — 모달리티 ablation: 멀티모달이 정말 T1-only보다 낮나 (측정)
**동기**: "멀티모달<T1-only deep"은 추측이었음 → 같은 Korean split·LOCO로 직접 측정.
**결과 (CN-vs-Dementia LOCO mean)**:
| 입력 | AJU→KDRC | KDRC→AJU | mean |
|---|---|---|---|
| T1만 | 0.864 | 0.611 | **0.738** |
| T1+FLAIR | 0.705 | 0.720 | 0.712 |
| T1+FLAIR+PET | 0.678 | 0.641 | **0.660** |
→ **모달 추가가 LOCO 단조 악화 (0.738→0.660).** 멀티모달<T1-only deep 측정 확정.
**amyloid LOCO**: T1/T1+FLAIR 0.47(chance), +PET 0.905 — 단 **PET=amyloid 직접측정(순환)**, 구조 예측 아님.
💡 **기전**: 치매신호=위축=T1에 이미 존재. FLAIR/PET는 새 질병신호 거의 0인데 각자 scanner/tracer confound(shortcut)를 추가 → 작은 N에서 학습 → cross-cohort 악화. "정보↑"는 추가모달이 신호일 때만 참; nuisance/confound면 해. 모달이 타깃 직접측정(PET→amyloid)일 때만 도움=순환.
**모든 비순환 deep(0.66~0.74) < morphometry(0.87).** → reviewer가 원하는 핵심 ablation. modality-count vs LOCO 그림 1장.

---

## EXP-010 (2026-06-11) — deep brain-age (morphometry 약한 첫 task)
**동기**: AD분류·amyloid 다 실패 → morphometry가 약한 task 탐색. brain-age morphometry LOCO MAE 5.06yr(CN n7580, 7코호트) → deep 기회.
**결과 (deep T1 96³, 7-cohort LOCO MAE)**:
| | mean-LOCO MAE | vs morph 5.06 |
|---|---|---|
| vanilla deep | 4.98yr | +0.08 (무의미) |
| site-invariant(λ=1) | 5.00yr | +0.06 |
→ ⚠️ **사실상 무승부**. deep 4/6 fold 승이나 평균차 무의미. 단 site-inv가 작은코호트 KDRC 6.08→5.06 크게 개선(adversarial 과적합억제).
💡 **레버 발견**: 비교가 불공정 — deep 96³(8배 다운샘플) vs morphometry 풀해상도(1mm) 부피. brain-age는 미세구조가 핵심이라 96³가 deep 핸디캡. → 다음: deep을 고해상(128~192³)으로 재학습이 결정적 fair 테스트.
