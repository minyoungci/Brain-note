# 03. 아키텍처 & 학습 method (설계 of record)

> 설계의 단일 출처. 근거는 [[01_prior_research]], 데이터는 [[02_data]], 규칙은 [[00_challenge_rules]], 전략/일정은 [[04_strategy_plan]], 위험/모니터는 [[06_risk_register]]. 후보 상세는 `arch_candidates/`, figure는 `figures/`.

## 1. THESIS — Single-Checkpoint Multi-Task Pretraining for Heterogeneous 3D Brain MRI Tasks (2026-06-22 확정, II+III)
> **하나의 SSL 사전학습 백본+디코더가 seg(50%)·cls·reg 이질 task를 *동시에* Pareto-good하게 만드는 사전학습 recipe는 무엇이며 왜인가** — FOMO26 단일 체크포인트 제약을 정면 연구. **챌린지 제출 시스템 = first-author 체계연구(한 노력, 두 산출).**

**왜 미점유/방어가능**: S3D(CVPR2025)·Models Genesis = **seg-only** 최적화 → "한 체크포인트가 seg+cls+reg 이질 type을 *동시* 만족"은 미점유. conflict pilot(`experiments/conflict_pilot/`): dense·global gradient 충돌부재·깊이분업 = **한 백본이 다 담아도 안 싸운다**는 positive 근거. (cosine balancing=falsify, decoder-transfer=S3D 선점 → 둘 다 headline 아님: [[01_prior_research]] §E·§F.)

**기여(정직한 고도)**: method 한 방이 아니라 **체계연구 + recipe + 강한 리더보드**. (a) 어떤 pretraining(objective 조성·dense형·백본)이 7 이질 task Pareto-front를 지배하나(내부 subject-disjoint probe), (b) 단일 ckpt가 task-type 간 어떻게 trade하나(충돌부재→공존 입증), (c) 챌린지 비-trivial 제출(공저). 보조 = fairness(③ scanner-inv, 가장 열림)·magnitude 관찰·cross-seq②. decoder-transfer·balancing = 상속된 설계(novelty 아님, S3D/표준 인용).

> ⚠️ **firsthood 방어**: prior-art서 S3D·Models Genesis·OpenMind 정면 인용 + "decoder-transfer/balancing은 우리 기여 아님" 선제 명시(심사자=DKFZ 가능성 차단).
> ⚠️ **GATE**: 내부 probe로 "한 recipe가 seg·cls·reg 동시 Pareto-dominate" 실제 가능한지 — 불가(어떤 recipe도 trade-off 강제)면 *그 자체가 finding*.

*(주의: 아래 §2~§8은 구 balancing/decoder framing 잔재 — 점진 정리 중. 권위 = 본 §1.)*

**왜 이 방향 (근거)**: ① **seg=FOMO26 리더보드 50% 직결.** ② **FOMO25 findings(2604.11679)**: CNN+full-decoder 우승 = decoder가 실제로 통한 축. ③ **conflict pilot(`experiments/conflict_pilot/` run01~03)**: dense(recon)·global(distill) gradient가 *충돌 없이*(cos≈0, 3k·30k 두 regime) *깊이별 분업*(global 깊은층·dense 얕은층) → 단일 백본이 둘을 담는 게 정당 + dense decoder를 MAE로 사전학습할 근거. (negative 결과의 supporting 재활용.)

**전 thesis 기각 이력(정직)**: "Conflict-Aware adaptive balancing"(cosine 충돌 기반)은 conflict pilot서 **두 regime 모두 cos≈0·창발 없음으로 기각**. magnitude 불균형(global 깊은층 우세)은 robust하나 GradNorm 표준동기+전제(불균형=병) 미검증이라 보조로만. → [[01_prior_research]] §E, `experiments/conflict_pilot/README.md`.

**novelty 위치(정직)**: main = **SSL dense-decoder transfer × few-shot 3D medical seg(체계연구)**, backbone-agnostic(ViT·ResEnc). balancing(①)은 **novelty 아님** — 단순/표준 결합(pilot가 충돌 없음 확인). cross-seq②·fairness③·magnitude 관찰 = 보조/ablation.

> ⚠️ **GATE (이 thesis 핵심 실험)**: `{MAE-transfer decoder vs scratch decoder} × {ViT, ResEnc}` × Task2/4 seg DSC + few-shot N 곡선. **transfer가 scratch와 CI tie면 반증.**
> ⚠️ **firsthood 리스크**: decoder transfer는 supervised pretraining서 known → "SSL-decoder transfer for few-shot 3D medical seg 첫 *체계*연구"로 좁혀야. prior-art pass 진행 중(→ [[01_prior_research]] §F).

## 2. 확정 vs Phase A 미정 (핵심)
| 🔒 확정(locked) | ⏳ Phase A 측정으로 결정 |
|---|---|
| 백본 family: **3D ViT 주력 + ResEnc-L seg안전망**, 단일채널 modality-agnostic, 단일 체크포인트 | patch **16³ vs 8³** |
| method 골격: **DINO(global) + MAE(dense) + cross-seq② + register/Gram/KoLeo + 의료 aug** (balancing = 단순/표준 결합, **novelty 아님** — pilot 충돌부재) | dense **MAE-recon vs iBOT-token**(MAE로 기움) |
| 디코더(=**thesis 핵심**): **conv-stem 고해상 skip + UNETR multi-depth U-Net, MAE 사전학습→seg 전이** | **⭐디코더 전이 vs scratch (핵심 GATE)** / **ViT vs ResEnc-L** / 백본 크기(B/L) |
| 의료특화 scope(아래 §6) | skip 소스 / aug 구체 / modality-embedding |
| 분류형 resume 인프라([[04_strategy_plan]]) | magnitude 불균형(보조 ablation) / novelty firsthood(prior-art §F) / 120초 추론 / downstream specifics |

## 3. 아키텍처
**백본 = 3D ViT**(3DINO식, 검증된 길). ⚠️ ViT>CNN 미입증 → ResEnc-L을 Phase A 비교/안전망. 120초/case 추론 제약 → 크기·속도 Phase A 측정.
```
입력(마스킹 + 2 global 96³ + N local 48³)
 [3D ViT Encoder, patch 16³] + [CLS] + [4 register]
   ├ CLS  → [DINO head]            → L_global (cls/reg/probe/fairness)
   └ patch → [conv decoder(UNETR/S3D)] → MAE recon → L_dense (seg ⭐50%)
 ⇅ EMA teacher | register(dense artifact) | KoLeo(anti-collapse) | Gram anchoring(dense 퇴화)
```
- 네이티브 토큰 CLS(global)+patch(dense). multi-depth distillation(DeSD). 백본=vehicle.

## 4. 두 목적함수 + 학습 method
- Global: `L_g = −Σ P_t(x)·log P_s(x′)` (CLS/τ, teacher SK-centering).
- Dense: MAE `‖x_M−x̂_M‖²` (또는 iBOT masked-patch — Phase A 결정). S3D(sparse conv·60~90% masking)·SparK skip.
- **balancing = novelty 아님(강등, 2026-06-22)**: `L = L_d + L_g`(단순/표준 결합). conflict pilot(`experiments/conflict_pilot/`)서 dense·global gradient **충돌부재**(cos≈0, 3k·30k 두 regime)·깊이별 분업 확인 → 정교한 balancing 불필요. magnitude 불균형(global 깊은층 우세)은 robust하나 **보조 ablation**(불균형=병 미검증). ⚠️ seg(50%) 절대 희생 금지.
- **②③ = 보조/ablation**(독립 novelty 아님): ② cross-seq(per-modality stem + Dirichlet cross-recon, **modality-invariance 금지**=seg 해침)·③ scanner-invariance(adversarial→Task7). seg DSC 조금이라도 깎이면 **즉시 강등(stop-rule)**.
- 강등: Gram(MedDINOv3 −0.04, ablation/안정화용)·큰 커널(9³ 포화).
- 총손실: `L = balance(L_d, L_g) + β·L_koleo (+② +③ +γ·Gram)`.

## 5. 후보 3종 (Phase A 직교 비교) — 상세 `arch_candidates/`, figure `figures/`
> ⚠️ **C thesis(decoder-transfer) 기준 재해석(2026-06-22)**: 후보 3종은 이제 *balancing novelty 후보*가 아니라 **decoder-transfer 연구의 backbone arm**(ViT-L·ViT-8³·ResEnc). 아래 표의 "novelty/적응적 balancing"은 *구 framing 잔재* — §1이 권위. figure/표 전면 갱신은 figure 재제작 시.
deep-research가 *답 못 준 갈림*(dense=MAE vs iBOT / patch 16³vs8³ / ViT vs ResEnc)을 직교 대표.

| | A: BalancedDINO-iBOT | B: BalancedDINO-MAE | C: Seg-Safe ResEnc |
|---|---|---|---|
| 백본/patch | ViT-L / 16³ | ViT / **8³**(dense-first) | ResEnc-L CNN |
| dense | iBOT masked-patch | **MAE** recon | MAE/S3D recon |
| global | DINO(CLS) | DINO(CLS) | global-distill+SimPool |
| seg 강도 | 중 | 강 | **강(검증된 최강)** |
| novelty | **강** | 강 | 중 |
| 120초 리스크 | 중 | 높음(8³) | 낮음 |
| 포지션 | thesis 정공 | 리스크 대응 | seg 안전망/baseline+ |
- 공통: 단일채널·**단순 결합(balancing 강등)**·register/Gram/KoLeo·EMA·multi-crop·bf16·8×B200(FSDP+FlashAttn)·resume.

### 공통 디코더 (seg=50% 통제변수)
few-shot이라 디코더 from-scratch=데이터 굶주림. **default(문헌 상속)**: conv-stem 고해상 skip + UNETR multi-depth U-Net 디코더를 **MAE로 사전학습→seg 전이**(head 교체). cls/reg는 CLS만. conv-stem skip = 16³서도 fine seg 회복(8³ 의존↓). 디코더 전이 = MAE-dense를 또 지지(iBOT은 conv 디코더 없음). C는 native U-Net 디코더. **Phase A 측정**: 전이 vs scratch·skip 소스·무게 vs 120초·16³+디코더 vs 8³. **재증명 안 함**: ViT 업샘플+skip 필요성·conv-stem 가치·전이 방향(문헌 확정).

## 6. 의료특화 scope (합법 ⭕ / off-scope ❌)
- ⭕ **multi-sequence cross-seq(②)** — 세션 54% 멀티모달 실측, downstream 정합.
- ⭕ **scanner/site-invariance(③ fairness)** — group/scanner 메타(779/916 보유), Task7 직결.
- 🟡 경량 해부 prior(좌우대칭·정준 pos-encoding) — ablation. age/sex는 보조 aux만(융합입력 X=누수), 회색지대(규칙 사례확인).
- ❌ **longitudinal·APOE·인지점수** — *이전 AD/amyloid 프로젝트 잔상*. FOMO26은 종단 task 0 + FOMO300K에 APOE/인지 없음(age/sex/group만) + Methods 외부supervision 금지 → **넣지 말 것**(누수/위법 공격 지점).

## 7. 핵심 ablation (= 논문 기여)
**⓪ GATE(thesis 핵심)**: **SSL dense-decoder 전이 vs scratch 디코더** — decoder-transfer가 few-shot seg(Task2/4 DSC)를 가르나? few-shot N(21~494) 곡선. **CI tie면 thesis 반증.**
① decoder-transfer × **{ViT, ResEnc}**(backbone-agnostic) × skip 소스. ② 전이 디코더에 dense iBOT vs MAE. ③ cross-seq·fairness·magnitude 불균형 = 보조. + ④ corpus 조성(구조-only / +b1000 / +all-b) × 전처리형태. 전부 OpenMind 프로토콜·subject-disjoint·3시드+CI. 안 되면 negative=자산.
> 기각: cosine-conflict balancing — conflict pilot서 falsify([[01_prior_research]] §E·`experiments/conflict_pilot/`).

### 공통 baseline (넘어야 할 바)
**encoder-only SSL + scratch 디코더**(우리가 넘을 핵심 대조) · ResEnc-L MAE(seg 바, OpenMind) · 공식 Asparagus ResEnc U-Net. **판정**: Task2·4 seg DSC(50%) 1차 + few-shot N 곡선 + Task1 AUROC(DWI) + global/dense proxy probe.

## 8. 실험별 구조 · figure 매핑 (Phase A 실행 지도)
> "확정"은 2층: **공통 코어는 잠금**, 경합 축(아래)은 **Phase A가 결정**. 지금 승자 못박음 = baseline-first/자기평가편향 위반. 확정되는 건 *승자*가 아니라 *실행 지도*. figure 7종 실물 검증 완료(2026-06-22) — 설계와 일치.

**figure 인벤토리 (7)**: 백본 3(=모델 자체/단일 체크포인트 자산) + 사전학습 그래프 3(=SSL scaffold+balancing) + 디코더 1(=downstream seg). 각 Phase A arm = 백본 figure + 사전학습 figure + 디코더 조합.

| Phase A arm | 백본 figure (모델 자체) | 사전학습 figure (scaffold) | seg 디코더 | dense / global | 포지션 |
|---|---|---|---|---|---|
| **A** BalancedDINO-iBOT | `figures/backbone_vitL.png` (ViT-L 16³·24blk·dim1024·~300M·CLS+4reg+216patch) | `figures/candidateA_balanced_dino_ibot.png` | `figures/decoder_shared.png` | iBOT masked-patch / DINO(CLS) | thesis 정공·**novelty 최강** |
| **B** BalancedDINO-MAE | `figures/backbone_vit8_primus.png` (ViT 8³·dim~768·1728토큰=8×seq) | `figures/candidateB_balanced_dino_mae.png` | `figures/decoder_shared.png` | **MAE recon**(conv dec) / DINO(CLS) | seg(50%) **리스크 정면** |
| **C** Seg-Safe ResEnc | `figures/backbone_resenc_unet.png` (ResEnc-L CNN U-Net 5stage 32→320ch·btnk 8³) | `figures/candidateC_segsafe_resenc.png` | **native U-Net**(C 백본 figure 내) | MAE/S3D recon / SimPool→distill | seg **안전망/baseline+** |

**경합 축 → 비교 figure** (어느 figure가 그 결정을 구현하나):
| Phase A 축 | 비교 figure |
|---|---|
| patch 16³ vs 8³ | `backbone_vitL` ↔ `backbone_vit8_primus` |
| dense iBOT vs MAE | `candidateA` ↔ `candidateB`/`candidateC` |
| ViT vs ResEnc | `candidateA`/`B` ↔ `candidateC` |
| **⭐디코더 전이 vs scratch (핵심 GATE)** | `decoder_shared` (MAE recon head → 폐기 → seg head) = **hero figure** |

**⚠️ 정리 시 주의 (깨질 수 있는 지점):**
1. `decoder_shared`는 **A·B(ViT)에만**. C는 native U-Net 디코더(C 백본 figure 포함) — 혼동 금지.
2. **figure 미반영**: cross-seq②(per-modality stem)·fairness③(adversarial head)는 method 확정이나 *어느 figure에도 안 그려짐*. arm-무관 **method-level 모듈**(어느 백본에도 얹힘) → 논문 figure 완성 시 추가 필요(현재 gap).
3. **통합 마찰 = 실행순서**: 공식 Asparagus finetune은 **CNN ResEnc**(`+model=resenc_unet_b`) 네이티브 → **C는 zero-friction**(baseline+로 *먼저*), **A·B(ViT)는 custom model 등록** 비용이 실험에 포함. → [[05_downstream_setup]] §우리 설계 함의.
4. **🔴 figure 갱신 필요(C thesis, 2026-06-22)**: 사전학습 figure(`candidateA/B/C_*`)의 주황 **"Adaptive Balancing"** 박스는 이제 **강등(novelty 아님)**. `decoder_shared`가 **hero figure**. C thesis(decoder-transfer)에 맞게 figure 재제작 필요 — 현재 figure는 구 balancing framing.
