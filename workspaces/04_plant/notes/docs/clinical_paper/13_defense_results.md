# 방어 분석 통합 — AT(N) 재정식화 + robustness (2026-06-25)

> claim 변경: "amyloid+vascular 두 독립축" → **AT(N): N>A 견고, V/WMH 약함/null**.
> 코드 `experiments/incremental_value/12_robustness_battery.py`·`13_defense_battery.py`·`14_rtm_robust_resolution.py`.
> PRIMARY 코호트 = MCI-only (SL diagnosis=='MCI', n=252, amyloid+=76). 보조 = full n=286.
> 사전선언 primary outcome: ΔMMSE 연속 + 이진 ≤−3.

## 핵심 표 — AT(N) 한 모델 (MCI-only, ΔMMSE ~ A+N+V+WMH+임상바)

| 축 | 측정 | OLS p | Huber p | outlier제거 p | 부트스트랩 P(β<0) | 판정 |
|---|---|---|---|---|---|---|
| **N** | 해마/내후각 위축(z) | 0.0013 | 0.0026 | 0.0050 | **1.000** | **가장 robust** ✅ |
| **A** | amyloid visual | 0.0109 | 0.0056 | 0.0057 | 0.983 | robust(단 ↓아래) ✅ |
| V | clinical vascular 라벨 | 0.0333 | **0.184** | **0.141** | — | **취약(사망)** ⚠️ |
| WMH | FastSurfer 부피(log) | 0.80 | — | — | — | **null** ❌ |

- A–N 공선성: corr=+0.21, VIF=1.05 → **독립적 증분**(amyloid가 위축의 원인이지만 각자 예후정보 추가).
- A=연속 SUVR 버전도: SUVR β−5.17 p=0.0004, N β−0.62 p=0.004.
- full n=286서도 동일 패턴(A p=0.0002, N p=0.0007, V p=0.030, WMH null).

## amyloid 단서 (정직 — limitation으로 명시)
표준 ANCOVA(baseline 선형보정)로는 robust하나, **더 보수적 baseline 통제에서 borderline**:
- centered mmse² 추가(VIF 1.5): p=0.063 · ceiling(MMSE≥29) 제외(n=233): p=0.095
- baseline-MMSE 3분위: 高(28-30)서만 p=0.032, 中·低 n.s. → 효과가 *경증/고기능 MCI*에 집중.
- 해석 두 갈래: ⓐ ceiling/RTM 인공물 ⓑ 인지보존 amyloid+ = 순수 prodromal AD(쇠퇴 직전). age 결과와 일관 → ⓑ 우세하나 **데이터만으론 ⓐ 배제 불가**.
- → **amyloid는 연속 β보다 이진 OR·SUVR 용량반응·age 교호로 방어가 더 강함.**

## amyloid 이진 "의미있는 쇠퇴" OR (MCI-only)
| 임계 | event | A OR(p) | N OR(p) | V OR(p) |
|---|---|---|---|---|
| ≤−3 **★주** | 56/252 | **2.62 (0.013)** | 1.35 (0.11) | 1.30 (0.54) |
| ≤−2 보조 | 80/252 | **3.40 (0.0006)** | 1.44 (0.035) | 1.57 (0.25) |
| ≤−4 보조 | 33/252 | 1.79 (0.22) | 1.71 (0.020) | 2.65 (0.055) |
- amyloid OR은 *중등도* 쇠퇴(≤−2,−3)서 강, *심한* 쇠퇴(≤−4)선 N/V로 넘어감 — threshold 의존 정직 보고.

## amyloid × age simple slope (MCI-only, 교호 p=0.0036; script12 Huber·outlier 통과)
| age | amyloid 효과 ΔMMSE β [95%CI] | |
|---|---|---|
| 65 | −2.54 [−3.80,−1.28] | 강 유의 |
| 72 | −1.43 [−2.31,−0.56] | 유의 |
| 80 | −0.17 [−1.25,+0.92] | null |
→ **figure-ready.** 젊은 MCI서 amyloid 강예후, 고령서 소멸.

## vascular subtype decomposition (full n=286, 보조) — 보정 resid ΔMMSE
| subtype | n | resid ΔMMSE |
|---|---|---|
| MCI(amnestic) | 100 | +0.22 |
| MCI(non-amnestic) | 68 | +0.72 |
| Vascular MCI | 46 | **−0.31 (약)** |
| Subcortical VaD | 7 | **−2.48 (강, 소수)** |
| AD+SVD / AD+vascular | 10/7 | −0.51 / −0.80 |
| Multi-infarct | 5 | +1.48 |
| (AD, dementia급) | 14 | −2.95 |
→ **pooled vascular 신호 = Subcortical VaD(n=7) 거의 단독.** 본체 Vascular MCI는 약함. "신호는 소수 subcortical 아형에서 온다"가 정직·방어적.

## WMH null 방어 (MCI-only, A+N+바 보정)
- log부피 p=0.19 · 시각등급(wmh_grade_visual) p=0.26 · 사분위 비선형 joint F p=0.69 → **전부 null** ✅
- raw-linear만 p=0.027 → log·비선위서 소멸 = **outlier-driven 인공물**(robust 측정에서 null).
- ⚠️ Fazekas는 이 286명 전부 결측 → "Fazekas null" 주장 **불가**. "시각등급(wmh_grade_visual) null"로 근거 교체.

## follow-up selection bias (followed 286 vs not-followed 668)
- 추적군이 **경증**: MMSE 24.15 vs 22.96(p<0.001), CDR-SB 2.41 vs 2.93(p<0.001), AD 11% vs 23%.
- 단 **amyloid 분포 균형**(0.32 vs 0.35, p=0.31), vascular 유사(p=0.08).
- → 예후 *연관*은 큰 편향 아님(amyloid 균형). 절대 쇠퇴율·일반화는 *경증 memory-clinic MCI* 한정. limitation 명시.

## 방어된 최종 claim (한 문장)
> 실세계 Asian MCI에서 **신경퇴행(N: 해마/AD-signature 위축)이 2년 인지쇠퇴의 가장 robust한 예측자**, **baseline amyloid(A)가 독립 예후정보 추가**(특히 중등도 쇠퇴·젊은 환자), **WMH 부담·pooled vascular 진단은 독립 예측 못 함**(vascular 신호는 소수 subcortical-VaD 국한).

## delta (정직 — 좁힘)
"amyloid가 쇠퇴 예측"은 교과서. delta = **real-world Korean memory-clinic MCI에서 AT(N) 예후 분해의 *패턴*** = N우위 + WMH-부담-null(부피·시각 모두) + **amyloid 나이의존성**. 체급 = JCN(IF~3). novel 메소드 아님(임상·실증 fork).

## 미해결 / 다음
- A의 RTM 단서: 외부코호트(ADNI/KDRC)서 amyloid가 baseline 통제 후에도 ΔMMSE 예측하는지 방향성 확인(범위 주의).
- Vemuri 2015 본문 정독(독립축 점유 정도).
- 외부 sanity: A+N 축 방향성만 ADNI서 재현 가능한지.
