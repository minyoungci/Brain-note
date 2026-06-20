# 아키텍처 & 학습 method (모델 계획)

> 근거·검증상태는 [[01_prior_research]]. 규칙 함의는 [[00_challenge_rules]]. 무결성은 [[03_data_integrity]].

## 1. THE THESIS
> **Principled (non-additive) local-global balancing for joint dense+global 3D self-distillation**, FOMO300K(기존 3배) 규모로 처음 입증. 고정 λ 가산이 아니라 dense(→seg)·global(→cls) 목적을 *적응적으로 균형* → **단일 백본이 seg·cls·reg·linear-probe·fairness를 동시에**(규칙이 단일 체크포인트 강제 = thesis와 정합).

**정직한 novelty 위치** (3개 축, 무게 분산):
- **① 적응적 balancing** — *main, 단 borderline*. Swin UNETR의 static λ 대체. **검증상태: SSL split-head 전이는 unvalidated 가설.** 핵심 = "*well-tuned* λ를 넘는가"(equal-λ만 넘으면 incremental). Phase A서 *제일 먼저* 검정. 약하면 ③으로 무게 이동.
- **② cross-sequence masked-recon × self-distillation** — 조합 gap(BrainFM은 MAE only). robustness 기여.
- **③ scanner-invariance (fairness, Task6/7)** — *가장 열림*(선행 0). 단 정확도 깎을 risk → 검정 필수.
> ⚠️ 과거 "CNN feature-map dual-head token 정의"는 ViT 채택으로 *무효*(ViT는 CLS+patch 네이티브 토큰). novelty는 ①②③에.

## 2. 아키텍처 (ViT — 3DINO식, 확정)
**백본 = 3D ViT** (CNN ResEnc에서 정정). 근거: 3DINO가 ViT-L로 3D self-distill 입증(유일 peer-reviewed) = 검증된 길; CNN-DINO-at-scale은 미입증. *단 ViT>CNN 명백은 아님 → CNN은 Phase-A 대안.* ⚠️ **120초/case 추론 제약**(규칙) → 모델 크기·추론속도 Phase A 측정(작은 모델 findings 정합).
```
입력(마스킹 + 2 global crop + N local crop)
   [3D ViT Encoder] ─ CLS token ─→ [DINO head] → L_global (cls/reg/probe/fairness)
        │ patch tokens
        ├─→ [iBOT masked-patch head] → L_dense
        └─→ [conv decoder (UNETR/S3D식)] ─→ [MAE recon] → L_dense (seg)  ⭐seg=리더보드 50%
   ⇅ EMA teacher(동일) | register tokens(dense artifact) | anti-collapse: KoLeo
```
- 네이티브 토큰: CLS(global)+patch(dense). register tokens로 dense artifact 제거.
- dense 경로 = conv decoder + MAE(S3D: sparse conv·densification·dynamic 60~90% masking) + SparK hierarchical skip.
- multi-depth distillation(DeSD): ViT 여러 layer distill.
- **백본은 vehicle, novelty 아님.**
- ⚠️ **새 변수(공식 셋업, [[05_downstream_setup]])**: 공식 Asparagus baseline·finetune 파이프라인이 **ResEnc U-Net(CNN)** (`+model=resenc_unet_b`). ViT 쓰려면 Asparagus에 custom model 등록 필요(통합 마찰). → **Phase A 결정**: (a) 공식 ResEnc로 가서 CNN-DINO/MAE 사전학습(마찰↓, 단 CNN-DINO 미입증 리스크) vs (b) ViT custom 등록(검증된 self-distill, 마찰↑). *공식이 CNN이라는 점이 ViT-vs-CNN 저울에 추가됨* — Phase A서 ResEnc 기준 먼저 + ViT 비교가 현실적.

## 3. 두 목적함수
- Global: `L_g = − Σ_k P_t(x)^(k) log P_s(x′)^(k)`, P=softmax(CLS/τ), teacher SK-centering.
- Dense: `L_d = − Σ_{i∈M} Σ_k P_t(p_i)^(k) log P_s(p̃_i)^(k)` (+ `‖x_M − x̂_M‖²` MAE).
- 기존(suboptimal): `L = L_d + λ·L_g` (고정 λ).

## 4. 학습 method
**[① 적응적 balancing] (핵심, falsifiable)**
- (A) 불확실성가중 `L=(1/2σ_d²)L_d+(1/2σ_g²)L_g+log σ_dσ_g` (B) PCGrad(충돌 투영) (C) GradNorm (D) Curriculum.
- 정당화: L_d·L_g는 gradient scale 다르고 cosine<0 가능 → 고정 λ는 Pareto-suboptimal. 지도 MTL서 adaptive>static(Kendall/GradNorm/PCGrad) — *SSL 전이는 검정 대상*.
- **baseline = well-tuned fixed-λ** (equal-λ 아님). ⚠️ seg(50% 가중) 절대 희생 금지.

**[② cross-seq recon] (멀티모달 robustness)**
- per-modality stem/token + Dirichlet 마스킹 cross-sequence recon(BM-MAE/MultiMAE). ⚠️ **modality-invariance 금지**(seg 해침) — modality-specific 보존, cross-recon으로 관계만.

**[③ scanner-invariance] (fairness)**
- adversarial(gradient-reversal) 또는 strong-aug式 → Task7. ⚠️ 정확도 깎을 risk → *정확도도 돕는 aug-invariance로, ablation으로만, 안 되면 fallback*. (modality-inv≠scanner-inv: 전자 신호손상, 후자 nuisance제거 — 단 후자도 과하면 위험.)

**[dense = MAE/S3D 중심]** (Gram 아님). ablation: iBOT-dense vs MAE-recon(선행 없음=기여).
**[강등]** Gram anchoring(MedDINOv3 −0.04, ablation만) / 큰 커널(9³ 포화).
**[지지]** multi-depth(DeSD) / multi-crop / KoLeo·VICReg.
**총손실**: `L = balance(L_d, L_g) + β·L_koleo (+ ② cross-seq, + ③ inv, + γ·Gram — ablation시만)`.

## 핵심 ablation (= 논문 기여)
① balancing > well-tuned λ? ② cross-seq > single-modal? ③ fairness가 seg 안 깎고 Task7 올리나? + iBOT-dense vs MAE. 전부 OpenMind 프로토콜·subject-disjoint·3시드+CI. 안 되면 negative=자산.

### ④ corpus-composition ablation (DWI 포함 여부 — research-critic 권고, 2026-06-20)
> ⚠️ "consistency 정합 = DWI 반드시 포함"은 **비약**(정합은 *어떻게* 전처리할지를 규정, *얼마나 넣을지* 아님). DWI 사전학습은 nice-to-have(Task1/2 finetune이 어차피 backbone에 dwi 노출). 희석 위험: 7중 5개 구조 task, seg 2·4=리더보드 50%, DINOv2/SEER "큐레이션>raw볼륨". → **혼합비는 실증 결정.**
- **전처리는 all-DWI 유지**(유연성·재전처리 회피). 혼합비는 manifest `modality`(b값 태그)로 학습 시 샘플링.
- **arm**: C0 structural-only(182K) / C1 +b0-dwi / C2 +all-dwi(현 기본=control) / C3 +dwi downweight(~15%).
- **결정지표**: Task2·4 seg DSC(50%, 1차) + Task1 infarct AUROC(dwi 입력 task) + Task6 probe. **동일 step수**(epoch 아님)·subject-disjoint·3시드+CI.
- **규칙**: C0/C1이 seg서 C2 tie-or-better & Task1 손실 없으면 → b0-only/고b 제외. 전부 CI겹침 → C1(parsimony).
- 열린 검증: Task1/2 finetune이 full-backbone인지 frozen+head인지(등록 후 config) → dilution 계산 좌우. 선행 3D-brain-SSL의 DWI-fraction ablation 유무(literature-scout) → 없으면 ④ 자체가 novelty.
- ⚠️ b값 분포(전수 실측, dwi 118,509): **b0 32% · b1000-family(998/999/1000) ~23%**(downstream 정합 양호) · **고b(≥1500) 27%**(=corpus ~10%, 노이즈) · 'dwi' untagged 10% · trace 1.4%. **adc/md/fa는 corpus에 없음**(per-b-value만) → 사전학습 DWI 신호 = b1000-family+trace.

### literature-scout 종합 (2026-06-20) — 근거기반 DATA FORM 정정
> 6축 peer-reviewed 조사. brain FM 선례 전부 구조중심(all-b DWI 1급 스트림 0); modality-invariance가 seg↓(2511.11311[VERIFY]); 큐레이션>규모(DINOv2); FM 관행=최소전처리(MNI/강제등방 X, OpenMind·FOMO우승); DWI 표준형=b1000 trace; norm=percentile-clip+z-score>무클립[0,1].
- **(a) DWI 형태**: all-b → **b1000-family(+trace)로 큐레이션**, b0(T2중복)·고b(노이즈) drop/downweight. ADC는 corpus에 없어 사전학습 불가(downstream만 제공).
- **(b) 전처리**: FM 관행대로 **더 최소화** — crop+RAS 유지, **DWI 1mm 업샘플 지양(native)**, norm을 **percentile-clip(0.5–99.5)+z-score**로(무클립[0,1]은 고b 아웃라이어에 취약), MNI 비권장. ⚠️ 대회규칙=전처리 자유(필수 아님)이므로 우리가 pretrain=our-inference 일관성만 지키면 자유 선택 가능.
- **(c) ablation은 선례 없음=novelty**: 구조-only vs +b1000 vs +all-b × (4단계 vs 최소전처리)를 구조5/DWI2 task 분리 측정. MICCAI/IPMI 기여.
- **삼중복합오류**(현 run): all-DWI(39%)+1mm-resample+[0,1] → 1순위 수정=조성(b1000만), 2순위=DWI native, 3순위=clip.
- **운영 해법(재확인)**: 전처리 all-DWI 유지(유연 풀, b값 태그) → **학습 혼합비=구조+b1000-family**(샘플링). 단 해상도/norm은 npy에 baked → 최소전처리 변형은 Phase-A서 DWI 재처리(저렴 ~0.5TB)로 ablation.
