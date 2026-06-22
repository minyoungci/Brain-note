# Candidate A — BalancedDINO-iBOT (thesis 정공법)

> 한 줄: **3DINO(검증된 ViT self-distill)에 우리의 적응적 비가산 local-global balancing을 얹은** 정공 후보. novelty가 가장 선명.

## 구조
```
입력 3D volume (단일채널, z-norm[0,1])
 → 증강: 2 global crop(96³) + N local crop(48³), 마스킹
 → [3D ViT-L tokenizer: patch 16³] + [CLS] + [4 register tokens]
 → ViT-L encoder (FlashAttn)
     ├─ CLS token  → [DINO head]        → L_global   (cls/reg/probe/fairness)
     └─ patch tokens → [iBOT head(masked)] → L_dense  (seg)
 ⇅ EMA teacher (student의 EMA, 동일 구조)
 → L = balance(L_dense, L_global)   ★적응적 비가산★
 + KoLeo(anti-collapse) + Gram anchoring(dense 퇴화 방지)
```
- seg downstream: patch token → UNETR식 conv decoder를 **finetune 단계**에서 부착.

## 설계 근거 (choice → evidence)
| 선택 | 근거 |
|---|---|
| ViT-L, 16³ patch, 96/48 crop, 2+N multi-crop, EMA | **3DINO(npj Dig Med 2025, 3-0)** 검증된 정확 config. 우리 227K가 동급 스케일(2.3×) |
| dense = iBOT masked-patch | 3DINO가 iBOT 사용 → distillation-pure(전부 self-distill, 별도 recon decoder 불필요). global과 head 공유 자연스러움 |
| 적응적 balancing (novelty) | 3DINO는 `L_image+L_patch` **고정가산** → 적응적 비가산 미선점(검색한계, prior-art pass 필요). tension 실재(OpenMind 3-0) |
| register tokens 4개 | ICLR24(3-0): artifact 제거, dense에 비대칭 이득, <2% FLOPs |
| Gram anchoring | DINOv3(3-0): **긴 학습서 dense 퇴화 해결** — long run 필수 |
| KoLeo | prototype collapse(3-0): K 키워도 cluster 안 늚 → KoLeo가 레버 |

## 장단점
- **+** novelty 가장 선명(ViT self-distill balancing), 3DINO 재현으로 리스크↓, 전부 distillation(단순).
- **−** ⚠️ **biggest risk 직격**: OpenMind상 seg는 MAE>iBOT, ResEnc-L 평균최강 → 16³ iBOT만으론 seg(50%) 약할 수 있음. → B/C와 Phase A 비교 필수.

## 추론(120초) 전략
ViT-L sliding-window. 초과 시 patch/모델 축소 또는 distillation(Tier 4).

## Figure
- **백본 구조(foundation 모델 자체)**: `../figures/backbone_vitL.png` — ViT-L 인코더 내부(patch embed·토큰·24블록·CLS/patch 출력). *이게 단일 체크포인트로 남는 자산.* B는 같은 ViT를 8³ patch로, C는 ResEnc-L CNN으로 백본만 교체.
- **사전학습 그래프(scaffold+balancing)**: `../figures/candidateA_balanced_dino_ibot.png`.

## Figure spec (paperbanana, 사전학습 그래프)
입력 볼륨 → multi-crop → ViT-L(patch16³, CLS+register) 인코더 → 두 갈래(CLS→DINO head→L_global / patch→iBOT head→L_dense) → 가운데 "Adaptive Balancing" 모듈이 두 loss 결합 → EMA teacher 점선 피드백 → KoLeo·Gram anchoring 박스. 강조색 = Adaptive Balancing(우리 novelty).
