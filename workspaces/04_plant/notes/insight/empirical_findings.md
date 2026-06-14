# 경험적 발견 — dead-end(재시도 금지) + 작동하는 것

> 이 데이터(7-코호트 T1w)에서 *직접 측정*으로 닫힌 것들. 재시도 = sunk-cost.

## ❌ Dead-ends (재개 금지 — 근거 병기)

| 시도 | 결과 | 근거 |
|---|---|---|
| **harmonization으로 bias 제거** (ComBat/ComBat-GAM/N4/MixStyle) | cross-site 일반화 못 올림. ComBat 부호 뒤집힘(RF −0.014/LR +0.022), MixStyle site-probe +0.026, NACC 회귀. confounded regime서 over-correction | minyoungi 01~09 · scout |
| **N4 ≠ harmonization** | voxel→site 0.475→0.470 (−0.006). N4는 site 거의 못 줄임 | P0-A2 |
| **global GRL/site-adversarial** | minyoung4 2회 실패. bounded(n=55) 개선→full(n=1765) 악화(scanner-family 0.328→0.660) | minyoung4 |
| **혈액 바이오마커 + MRI** | morph+age 대비 Δ: dementia +0.005·MCI +0.000·amyloid +0.007. texture +0.00 | `novelty_deep_research.md` |
| **멀티모달 fusion**(ShaSpec/HyperFusion 등) | 문헌 crowded + cross-site(LOCO) 증거 전무. imaging-only SSL "matches morph" 주장 REFUTED | deep-research |
| **amyloid를 (a)/(b) target으로** | morph 0.66(약) → 판정 불가. image 0.63~0.66 ≈ morph | T3 함정 |
| **APOE/molecular를 brain으로 예측** | morph→APOE 0.586(≈chance). 모달리티 천장 | landscape 측정 |
| **rich-data 종단 연구** | Korean(rich)은 cross-sectional(CDR변화 35명), 궤적은 ADNI(feature-poor)만 → disjoint | `ledgers/longitudinal...` |

## ✅ 작동하는 것 / transport되는 것

| 발견 | 수치 | 함의 |
|---|---|---|
| **morphometry(fs_vol)는 site-robust** | AD/CN LOCO 0.936 ≈ in-dist, site-shift 비용 ~0 | 넘기 어려운 강한 baseline. (a)/(b)의 바 |
| **disease는 morph 수준선 site와 분리 가능** | 잔차화 후 0.774→0.722(−0.05), within-site AUROC 0.68~0.87 | decidable regime (P0-A4) |
| **decidability framework** | residualization + dual-gate(G1 site↓ ∧ G2 morph 초과) | 방법론 기여, null-robust |
| **진단: image→fs_vol R²** | (b)천장 vs (c)모델실패를 가르는 도구 | 표현 평가 전 필수 |
| **clean-vendor subspace** | A4(V=0.00)·ADNI(V=0.06): vendor⊥diagnosis | site-invariance를 *글로벌 삭제 아닌* 여기서 학습 |
| **APOE는 amyloid 예측에 기여** | morph+APOE 0.78 vs morph 0.66 (+0.12) | 단 유전정보(이미지 아님). 임상 바엔 포함해야 |

## 핵심 메커니즘 (왜 자꾸 (b)로 수렴하나)
- **site≈population confound**(Cramér's V site-impaired 0.42): site가 신호를 *가리는* 게 아니라 confounded 라벨을 *부풀린다*. → harmonization 걸면 일반화 안 좋아지고 over-correction.
- **morphometry ⊂ image** (부피는 이미지의 lossy 요약): image가 원칙적으론 넘을 수 있으나, 실증은 ≈morph. 표현이 site를 외움(0.72~0.81).
- **분자/유전(amyloid/APOE) = 모달리티 천장**: T1w 구조에 정보가 거의 없음 → image도 morph도 못 뽑음.
