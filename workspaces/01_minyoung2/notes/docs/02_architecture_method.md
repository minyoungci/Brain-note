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
