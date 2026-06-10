# 05 — ComBat-GAM vs 선형 ComBat (fs_vol) 결과

_생성: 2026-06-04. 원본 READ-ONLY(sha256 `5ae141a4…` 전후 동일). 스크립트 `exp_combat_gam.py`, 검증 `verify_gam.py`._
_데이터: fs_vol 26 ROI, complete-case **n=12,579 / subjects 6,823** (02와 동일 필터). 둘 다 batch=consortium, 보존=age/sex/dx3._
_차이: 선형 ComBat(neuroCombat)은 age를 1차항으로, ComBat-GAM(neuroHarmonize, Pomponio 2020)은 age를 평활(smooth) 항으로 보존._

## 동기
02에서 코호트별 age→hippocampus/ICV 기울기가 ~2배 차이(부호는 모두 음수)였다. 선형 ComBat이 age 비선형성을
못 흡수해 잔여 site/biology 왜곡을 남겼을 가능성 → ComBat-GAM이 더 방어적일지 검정. (06 3.1-C가 남긴 방법론 구멍.)

## 결과 (subject-grouped GroupShuffleSplit ×8, RandomForest)

| 지표 | raw | 선형 ComBat | **ComBat-GAM** |
|---|---|---|---|
| **site7 ba** (chance 0.143) | 0.238 | **0.175** | 0.179 |
| site7 shuffled (null) | 0.143 | 0.143 | 0.143 |
| scan4 ba | 0.274 | 0.243 | 0.244 |
| **age R²** | 0.284 | 0.278 | 0.275 |
| CN-AD AUC pooled | 0.893 | 0.896 | 0.898 |
| **CN-AD AUC within-ADNI** | 0.884 | 0.885 | 0.889 |
| fake-label AUC (null) | 0.498 | 0.495 | 0.495 |
| **age→hipp/ICV slope_spread** | 0.007 | 0.007 | 0.007 |

## 결론 (독립검증됨)

**ComBat-GAM은 선형 ComBat 대비 의미있는 이득이 없다.** 세 가지 모두에서:

1. **site 잔여**: GAM 0.179 ≈ 선형 0.175 — GAM이 오히려 *미세하게 높음(나쁨)*. 검증 `verify_gam.py`(2): RF per-split std로 보면 linear 0.175±0.003 vs GAM 0.178±0.003, **|diff|=0.0024 < pooled_sd=0.0029 → 노이즈 내.** LogReg(선형분류기)로도 linear 0.159 vs GAM 0.165로 같은 순서(GAM 무이득).
2. **biology 보존**: within-ADNI CN-AD AUC linear 0.885 vs GAM 0.889(+0.004) — RF std·LogReg std(~0.030) 안이라 **유의차 아님**. age R²는 GAM이 오히려 0.278→0.275로 소폭 낮음. 즉 GAM이 biology를 *더* 보존하지도 않음.
3. **GAM 고유 metric(slope_spread)**: GAM이 노렸던 코호트별 age→hipp 기울기 spread가 **0.007로 전혀 안 줄어듦.** 비선형 age 모델링이 cross-cohort 기울기 정렬에 기여하지 못함.

→ **02의 "선형 ComBat이 비선형 age를 못 잡아 손해 봤을 것"이라는 우려는 기각.** 우리 fs_vol에서 age-volume 관계의
비선형성은 harmonization 품질에 영향을 줄 만큼 크지 않다. 잔여 site(0.16~0.18 > chance 0.143)는 **선형가정
아티팩트가 아니라 site==population 모집단 교란분의 정당한 잔존**(02 결론 강화).

## null control / 무결성
- shuffled-site ba ≈ 0.143(chance), fake-label AUC ≈ 0.495(≈0.5) — 전 조건 통과(허위신호 없음).
- manifest sha256 실행 전후 동일.

## 함의 (06 feasibility 업데이트)
- **feature-level harmonization의 천장 재확인**: 선형이든 GAM이든 fs_vol 잔여 site는 0.16~0.18에서 멈춘다.
  06 Part 1.2의 "ComBat-GAM이 약간 더 방어적일 여지"는 **우리 데이터에선 실현되지 않음** → 06 verdict 불변.
- feature-level half(02 선형 + 05 GAM)는 이제 **완결**. 다음은 image-level half(deep harmonization arm, GPU).

## 산출물
- `out/combat_gam_results.json` (전체 수치 + 코호트별 slope)
- `verify_gam.py` 출력(LogReg 재현 + std 노이즈 판정)
