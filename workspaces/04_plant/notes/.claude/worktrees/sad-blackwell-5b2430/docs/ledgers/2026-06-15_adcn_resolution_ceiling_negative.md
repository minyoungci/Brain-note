# NO-GO ledger — AD/CN 이미지 해상도가 morphometry gap의 원인인가 (음성)

> 2026-06-15. 사전 등록 가설: none_tta@2mm가 morph(0.931)에 −0.021 못 미친 잔여가 **2mm 다운샘플 핸디캡** 때문인가. 해상도-매칭(2mm→1.5mm) 직접 검정. 결론: **해상도는 한계가 아니다. 잔여는 해상도 불변 → 천장 성분.**

## 사전 등록 기준 (결과 보기 전 고정)
- none_tta@1.5mm **≥0.931**(bar 교차) → G2 개방, (b) 미세신호 추적.
- **[0.910, 0.931)** → 해상도가 gap을 좁힘 → 1mm 빌드 정당화.
- **≤0.910**(2mm 대비 무개선) → 해상도가 한계 아님 → 천장 강한 증거 → **해상도 추격 중단·음성 기록**. ← NO-GO 트리거.

## 측정 (직접 — LOCO 5-cohort ADNI/NACC/OASIS/AIBL/KDRC × 2-seed, image-only)

| arm | 2mm (96³ 풀) | 1.5mm (128·149·128) | Δ(해상도) |
|---|---|---|---|
| none (raw image) | 0.844 | 0.849 | +0.005 |
| grl (consortium-adversarial) | 0.817 | 미실행 | — |
| none_tta (BN-adapt, transductive) | **0.910** | **0.910** | **0.000** |

- voxel 수 2.37× 증가(2mm→1.5mm)에도 **none_tta 평균 AUROC Δ=0.000**, raw도 Δ=+0.005(seed noise 내).
- per-fold(none_tta) 2mm→1.5mm: ADNI .905→.907, NACC .894→.883, OASIS .918→.927, AIBL .924→.917, KDRC .908→.913 — 전부 ±0.01.
- BN-adapt 회복분(none→none_tta): 2mm +0.066, 1.5mm +0.061 → **site-shift 제거 성분 ~0.06, 해상도 불변**.
- 잔여 gap(none_tta vs morph): 2mm −0.021, 1.5mm −0.021 → **해상도 불변**.

## 판정
- ❌ **−0.021 잔여는 해상도 핸디캡이 아님.** 2.37× voxel이 정확히 0을 삼 → 한계효용 평탄.
- ❌ **1mm 캐시 빌드 안 함.** 또 3.4× voxel·~72GB 상주로 −0.021 쫓기 = sunk-cost(CLAUDE.md "조금만 더" 금지).
- ✅ 잔여는 **천장 성분 후보**로 귀속. 단 아래 confound로 "확정" 아님.

## confound / 한계 (정직하게)
1. **테스트 범위 2mm↔1.5mm뿐.** native 1mm(morphometry 해상도)은 미검 — "1mm서 급등" 반례 가능성 [열림]이나 평탄 곡선상 비용 정당성 없음.
2. **none_tta는 transductive**(held-out 배치 통계 특혜, C4). 즉 0.910은 낙관적 상한 → **진짜 inductive 천장은 더 낮음** → "이미지가 morph 못 따라잡음" 결론을 강화.
3. **2-seed**(약함). 단 2mm·1.5mm 각 2-seed = 독립 4런이 동일 0.910 수렴 → 집계 robust.
4. grl는 1.5mm 미실행 — 2mm서 명백 악화(0.817, NACC 0.82→0.70), "진단 없는 반복 금지"에 따라 재실행 불필요.

## 다음 (해상도 축 종료 후)
해상도는 닫고, 잔여를 천장으로 **확정하려면** literature 판정(2026-06-15 novelty 실측)의 3개로 이동:
- C2: GRL-악화/AdaBN-회복 dissociation을 **multi-seed × 전 site**로 robust화(현재 2-seed).
- C3: AdaBN 회복분 ↔ **site-decodability 감소** 인과 + 잔여의 **morphometry 환원불가** 독립확인.
- C4: **inductive 변형**(target-site 소량 unlabeled calibration→freeze)이 같은 회복 내는지 → transductive confound 제거.

산출: `results/P2/adcn_method_none_tta_adcn_1p5mm.{csv,json}`, `adcn_method_none_adcn_1p5mm.{csv,json}`.
되돌아갈 지점: commit `51944b3`(1.5mm 실행 직전 체크포인트).
