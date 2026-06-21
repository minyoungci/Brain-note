# Foundation Model — 구조 후보 (Phase A 비교 대상)

> 근거 통합: [[../01_prior_research]] · [[../02_architecture_method]] · deep-research(2026-06-21, 24소스/17확정) · research-critic · literature-scout. 데이터/제약은 [[../00_challenge_rules]] [[../../SCRATCHPAD]].

## 왜 후보를 여러 개 두나
deep-research가 **답을 못 준 설계 갈림**(측정으로만 결정 가능)이 셋이다 — 이 갈림을 각각 대표하는 직교 후보로 Phase A에서 *실증 비교*한다. 자기평가 편향 금지(docs/03), baseline-first.

| Phase A 갈림 | 근거 |
|---|---|
| dense objective = **MAE-recon vs iBOT-token** | OpenMind(ICCV25): seg엔 MAE 우세 ↔ 3DINO: iBOT 사용. balancing 공식이 이에 좌우 |
| patch = **16³ vs 8³** | Primus(3-0): 8³ dense 풍부하나 sequence 8×. ViT seg-parity 미해결 |
| backbone = **ViT vs ResEnc-L** | OpenMind(3-0): seg는 ResEnc-L 평균최강 / "CNN 압도"는 기각(0-3) → 미해결 |

## 후보 3종 (직교)
| | A: BalancedDINO-iBOT | B: BalancedDINO-MAE | C: Seg-Safe ResEnc |
|---|---|---|---|
| **포지션** | thesis 정공법 | dense-first(리스크 대응) | seg 안전망/baseline+ |
| backbone | ViT-L | ViT (8³ tokenizer) | ResEnc-L (CNN) |
| patch/token | 16³ | **8³**(richer dense) | conv stride(해당없음) |
| global 경로 | DINO(CLS) | DINO(CLS) | global-distill head(+SimPool) |
| dense 경로 | **iBOT** masked-patch | **MAE** recon(conv decoder) | **MAE/S3D** recon |
| **balancing(novelty)** | 적응적 비가산 | 적응적 비가산 | 적응적 비가산 |
| 안정화 | register·Gram·KoLeo | register·Gram·KoLeo | (CNN, register 무관)·KoLeo |
| seg 강도 | 중 | **강** | **강(검증된 최강)** |
| novelty 강도 | **강**(ViT-distill balancing) | 강 | 중(CNN-distill, 덜 ViT-native) |
| 추론(120초) 리스크 | 중(ViT-L) | 높음(8³ sequence) | 낮음(CNN 효율) |

## 공통 요소 (세 후보 전부)
- **단일 채널 modality-agnostic** 인코더(구조+DWI 혼합, per-volume z-norm) — 규칙: 단일 체크포인트.
- **적응적 비가산 local-global balancing** = 우리 main novelty. `L = balance(L_dense, L_global)`.
- **분류형 resume 인프라**(외부죽음→자동재개 / 발산·붕괴→정지): 모든 후보 학습에 공통(Multi-day).
- **EMA teacher**, multi-crop(2 global + N local), bf16, 8×B200(FSDP+FlashAttn).

## 공통 baseline (넘어야 할 바, novelty 아님)
- **ResEnc-L MAE**(seg 바, OpenMind) · **DINO+iBOT 고정가산**(3DINO식, well-tuned-λ 바, Warning W1).

## Phase A 판정 지표
Task2·4 seg DSC(50%) 1차 + Task1 AUROC(DWI) + global/dense proxy probe. 3시드+CI, subject-disjoint. 안 되면 negative=자산.

## Figure
각 후보 `*.md`에 figure spec + paperbanana 생성 PNG(`../figures/`). 비교 figure는 overview용.
