# Candidate C — Seg-Safe ResEnc (seg 안전망 + baseline+)

> 한 줄: **검증된 3D-seg 최강 CNN(ResEnc-L)에 global self-distillation을 얹어** seg(50%)를 확보하면서 단일 백본의 cls 능력도 부여. novelty는 덜 ViT-native하나 seg 리스크를 가장 확실히 제거.

## 구조
```
입력 3D volume (단일채널)
 → 마스킹(MAE) + 약증강
 → [ResEnc-L U-Net encoder (CNN, MIC-DKFZ)]
     ├─ bottleneck feat → [SimPool attention-pool] → [global-distill head] → L_global
     └─ encoder feat → [U-Net decoder] → MAE/S3D recon → L_dense
 ⇅ EMA teacher (global 경로)
 → L = balance(L_dense, L_global)   ★적응적 비가산★
 + KoLeo (register/Gram은 CNN엔 무관)
```
- downstream seg: U-Net decoder 그대로 finetune(네이티브) → seg 강점 직접 계승.

## 설계 근거 (choice → evidence)
| 선택 | 근거 |
|---|---|
| backbone = **ResEnc-L CNN** | **OpenMind(3-0)**: 3D seg에서 ResEnc-L 평균 최강. seg=50% 안전망. "CNN 압도"는 기각(0-3)이나 "평균최강"은 확정 |
| dense = MAE/S3D recon | OpenMind: MAE가 ResEnc를 from-scratch 넘게 함(150 epoch). S3D(CVPR25) sparse-conv |
| global = SimPool + distill head | SimPool(ICCV23): CNN에 attention-pool로 global 표현 부여(CNN은 CLS 토큰 없음). cls task 대응 |
| 적응적 balancing | A/B와 동일 novelty — MAE(dense)×global-distill 균형 |
| register/Gram 제외 | CNN엔 token-artifact 개념 없음(ViT 전용). KoLeo만 |

## 장단점
- **+** seg 리스크 가장 확실히 제거(검증된 최강), 추론 효율 좋음(120초 여유), MAE가 검증된 SSL.
- **−** novelty 약함(CNN-distill은 ViT-self-distill보다 덜 신선, balancing 기여는 동일하나 "백본 신규성" 없음). DINO-style self-distill의 ViT 네이티브 이점 포기.

## 추론(120초) 전략
CNN U-Net = 가장 효율적, sliding-window로 여유. 세 후보 중 추론 리스크 최저.

## 역할
**주력이라기보다 안전망/상한 baseline**: A·B(ViT)가 seg에서 C를 못 넘으면 → C로 seg 점수 방어 + "ViT가 CNN 못 넘음" negative=자산. A·B가 C를 넘으면 → ViT-novelty 정당화.

## Figure spec (paperbanana)
입력 → 마스킹 → ResEnc-L U-Net 인코더(CNN 블록 스택) → 두 갈래(bottleneck→SimPool→global-distill head→L_global / decoder→MAE recon 복원볼륨→L_dense) → "Adaptive Balancing" 결합 → EMA teacher 점선. U-Net skip connection과 CNN 블록을 ViT 후보와 시각적으로 대비.
