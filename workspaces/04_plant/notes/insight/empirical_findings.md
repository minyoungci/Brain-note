# 경험적 발견 — dead-end(재시도 금지) + 작동하는 것

> 이 데이터(7-코호트 T1w)에서 *직접 측정*으로 닫힌 것들. 재시도 = sunk-cost.

## ❌ Dead-ends (재개 금지 — 근거 병기)

| 시도 | 결과 | 근거 |
|---|---|---|
| **harmonization으로 bias 제거** (ComBat/ComBat-GAM/N4/MixStyle) | cross-site 일반화 못 올림. ComBat 부호 뒤집힘(RF −0.014/LR +0.022), MixStyle site-probe +0.026, NACC 회귀. confounded regime서 over-correction | minyoungi 01~09 · scout |
| **N4 ≠ harmonization** | voxel→site 0.475→0.470 (−0.006). N4는 site 거의 못 줄임 | P0-A2 |
| **global GRL/site-adversarial** | minyoung4 2회 실패 + **AD/CN 3회째 확인**: 0.844→0.817(NACC 0.82→0.70). bounded(n=55) 개선→full 악화(scanner-family 0.328→0.660) | minyoung4 · `adcn_methodology` |
| **이미지가 AD/CN morph 초과 ((a) 신호)** | 누수無 nested-LOCO+from-scratch+강target(0.931)+**공정(inductive)** 비교+해상도 불변에서 image(BN-adapt) 0.910 ≤ morph 0.931. 과거 철회된 (b) 주장을 이번엔 **F1/F2/F3 없이 clean하게** 닫음 | `adcn_inductive_bn` · DECISION_LOG 2026-06-15 |
| **해상도 추격(2mm→1.5mm)** | BN-adapt image Δ**0.000**(0.910→0.910), raw +0.005. AD/CN 분류 AUROC는 해상도 무관(T5 cortical R²와 별개 — task-level은 평탄). 1mm 빌드 폐기 | `ledgers/2026-06-15_adcn_resolution...` |
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
| **inductive BN-adapt (unlabeled K=64→freeze)** | LOCO site-shift gap +0.06 회복, transductive와 동등(recovery 1.05, K64 포화)·공정·배포가능. GRL은 악화 | `adcn_inductive_bn` C4 2026-06-15 |
| **★morphometry는 *인구 간*(서양↔Korean)에도 deep보다 transportable** | CN-vs-impaired cross-pop(n=1143): deep<morph 양방향 유의(W→K Δ−0.106[−0.143,−0.068]·K→W −0.062[−0.101,−0.022]). within은 유의차 없음 | P4 2026-06-16, `docs/P4_results.md` |
| **★cross-population deep 결손 = test-time(BN) 비가역 / 사전학습으론 *비대칭* 회복** | BN-adapt 0% 회복(둘 다). 단 **brain-age 사전학습은 W→K를 morph 동등까지 회복(Δ−0.002), K→W는 못 함(Δ−0.053 유의)** | "비가역 population"은 과한 결론 — 정정. Korean→Western이 가장 취약. P4 §4e |
| **★MMSE는 인구간 비등가** | 매칭(age·sex·CDR-stage) 후에도 Korean MMSE 낮음(AD Δ+4.7) | 강한 임상 feature가 곧 비전이 → fusion서 제외, equity 메시지 |

## 핵심 메커니즘 (왜 자꾸 (b)로 수렴하나)
- **site≈population confound**(Cramér's V site-impaired 0.42): site가 신호를 *가리는* 게 아니라 confounded 라벨을 *부풀린다*. → harmonization 걸면 일반화 안 좋아지고 over-correction.
- **morphometry ⊂ image** (부피는 이미지의 lossy 요약): image가 원칙적으론 넘을 수 있으나, 실증은 ≈morph. 표현이 site를 외움(0.72~0.81).
- **분자/유전(amyloid/APOE) = 모달리티 천장**: T1w 구조에 정보가 거의 없음 → image도 morph도 못 뽑음.

## 메타 교훈 (2026-06-15) — testbed ≠ headline (AD/CN 라인 종료)
- AD/CN(morph 강 0.93)은 (a)/(b)를 깨끗이 *판정*하는 **testbed**지 논문 headline이 아니다. 이번에 testbed가 답을 줬다:
  **(b) 천장 실재(이번엔 누수 없이) + (a) bias = BN-통계 shift(inductive로 공정 교정 가능, GRL은 악화).**
- 이건 *de-risking 음성결과*지 그 자체로 paper가 아니다. "이미지가 morph 못 넘음"은 **Wen 2020 / Bron 2021**이 이미 확립 → replication.
  novelty 실측(literature-scout): 공정 LOCO 비교(C1)는 점유됨, 분해 프레임(C3)만 공백이었으나 thin. 가장 위협=**Bron 2021**.
- 분해(C3 fusion: 잔여가 morph 환원가능한가)는 설계·도구(`adcn_fusion_c3.py`)까지 갔으나 **라인 종료로 최종 미실행**(7/15 fold에서 중단). 재개 시 OOF prob 재생성 필요.
- headline 후보는 여전히 **morph-weak regime(MCI/amyloid) transportability**에 남아있고 **미해결**(과거 T1/T2/T3로 철회). 단 이번에 검증한 *누수없는 LOCO + 공정 inductive 비교* 도구가 재시도의 무기.
