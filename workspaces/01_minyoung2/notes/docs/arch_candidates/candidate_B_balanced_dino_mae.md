# Candidate B — BalancedDINO-MAE (dense-first, 리스크 대응)

> 한 줄: **seg=리더보드 50%라는 최대 리스크를 정면 대응** — dense 경로를 MAE 재구성 + 8³ patch로 강화하고, 우리 적응적 balancing으로 global과 묶음.

## 구조
```
입력 3D volume (단일채널)
 → 2 global crop + N local crop, 높은 마스킹(60~90%)
 → [3D ViT tokenizer: patch 8³ (Primus식)] + [CLS] + [4 register]
 → ViT encoder (FlashAttn, 8³→8× sequence)
     ├─ CLS token   → [DINO head]                 → L_global
     └─ patch tokens → [conv decoder (UNETR/S3D)]  → L_dense = MAE recon ‖x_M − x̂_M‖²
 ⇅ EMA teacher (global 경로)
 → L = balance(L_dense, L_global)   ★적응적 비가산★
 + KoLeo + Gram anchoring
```
- 마스킹 80% 시 VRAM 40%↓(Primus) → 8³ sequence 비용 일부 상쇄.

## 설계 근거 (choice → evidence)
| 선택 | 근거 |
|---|---|
| dense = **MAE recon** (iBOT 아님) | **OpenMind(3-0)**: 3D seg에서 reconstruction/MAE가 best 레시피. seg 50%니 dense를 MAE로 |
| patch **8³** | Primus(3-0): 8³가 dense 풍부(seg↑), 80% 마스킹 시 VRAM 40%↓. 단 sequence 8×(비용) |
| conv decoder(S3D/SparK) | S3D(CVPR25)·SparK(ICLR23): sparse conv·densification·hierarchical skip = dense 이득 최대 |
| global = DINO + 적응 balancing | global 능력 유지(cls/reg task) + novelty. MAE 단독은 cls 약함(OpenMind) → balancing이 필요 |
| register·Gram·KoLeo | A와 동일 근거 |

## 장단점
- **+** seg(50%) 최강 잠재력(MAE+8³), biggest risk 정면 대응, novelty 유지(MAE×global balancing은 더 희소).
- **−** ⚠️ **추론 비용 높음**: 8³ = sequence 8× → 120초/case 리스크 가장 큼. conv decoder로 구조 복잡↑. 학습 throughput↓.

## 추론(120초) 전략
8³는 추론 부담 최대 → **distillation을 16³ student로** 또는 추론 시 patch 병합 검토. Phase A에서 추론시간 *반드시* 실측(W2).

## Figure spec (paperbanana)
입력 → 높은마스킹 multi-crop → ViT(patch8³, CLS+register) 인코더 → 두 갈래(CLS→DINO head→L_global / patch→conv decoder→MAE recon, 복원된 볼륨 썸네일→L_dense) → "Adaptive Balancing" 결합 → EMA teacher 점선. 8³ 작은 패치 그리드와 conv decoder를 시각 강조.
