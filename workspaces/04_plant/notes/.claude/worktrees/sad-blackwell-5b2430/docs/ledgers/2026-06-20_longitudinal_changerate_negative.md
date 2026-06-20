# NO-GO ledger — 종단 변화율(longitudinal change-rate) thesis kill-test (음성)

> 2026-06-20. "기술적 novelty"의 마지막 live 후보(종단 변화율 deep 표현)를 GPU 약속 전 CPU kill-test로 검정.
> 결과: **사전등록 NO-GO 기준 위반 → 폐기.** 되돌아갈 commit: `4d2eb1b`.

## 검정한 가설
단일시점 morphometry가 *구조적으로* 못 담는 종단 변화율에 deep이 들어갈 신호가 있나 →
대리 baseline **Δmorphometry(Δfs_vol/year)** 가 static morph+cognition을 넘는지(넘으면 deep 여지).

## 측정 (계층적 bar, 부트스트랩 CI · `notebook` 외 1회 측정)
- 데이터: ADNI ≥3 visit 614명(input=초기 2시점, target=미래 Δcdrsb after input) + OASIS 193명(cross-site transport).
- ICV-정규화 fs_vol 26 ROI × {static(baseline), Δrate}. Ridge, subject-level 5-fold.

| | ADNI-내부 R² | ADNI→OASIS transport R² |
|---|---|---|
| DEMO+intervals | +0.025 | −0.133 |
| +BASE(cognition) | +0.073 | −0.023 |
| +STATIC morph | **+0.114** | −0.141 |
| +ΔMORPH(change) | +0.027 | −21.66 |

- **Δ(ΔMORPH | static+cog) 내부 = −0.089, 95%CI [−0.172, −0.031]** (전부 음수 → 변화 feature가 *해침*).
- transport ΔR² = −25.9 [−79.9, −3.2] (파탄).

## 판정 (사전등록 NO-GO: Δmorph가 CI하한>0으로 static 초과해야)
- ❌ **위반.** 종단 변화율은 static morph+cognition을 못 넘고(내부 CI 전부 음수), transport도 안 됨.
- **R1 종단판:** 미래 저하가 site 간 transport 안 됨(OASIS 저하 0.21±1.0 ≪ ADNI 0.91±2.4 = population shift 지배). static 모델조차 OASIS서 R²<0.
- **천장:** 미래 Δcdrsb의 구조-예측 천장이 낮음(내부 best R²~0.11).

## 정직한 caveat (과대 음성도 경계)
- 이 kill-test가 refute하는 것: *naive per-ROI Δvolume*가 돕는다 — 깨끗이 음성.
- refute 못 하는 것: 정교한 deep spatiotemporal이 crude Δvolume가 놓치는 *변화 패턴*을 뽑을 가능성. 단 (낮은 천장 0.11 + 비-transport + static을 넘어야 함) 3중 장벽이 쌓여 prior는 강하게 null.
- 변화 feature 노이즈(짧은 간격·26 ROI 차분)가 음성을 부풀렸을 수 있음 → 유일 재검 후보=denoised 변화측정(긴 간격·whole-brain atrophy rate·정규화). **단 '조금만 더' 금지 — 재검은 명시 결정 시에만.**

## 누적 증거 (4 독립 라인, 같은 방향)
R2 천장(deep≈morph) · baseline bar(DEMO+BASE 위 imaging 증분 CI 0 포함) · 문헌 4팀(honest cross-site win 전무) · **이 kill-test(종단 변화율도 음성)**. → 구조 T1에서 *정확도 기반* 기술 novelty 경로는 측정상 없음.

## 다음 (상위 결정점 복귀)
- (a) **다른 modality**: 매니페스트에 raw FLAIR 3379·DWI 1722·PET 903 존재 → T1이 못 가진 신호 regime일 수 있음(단 과거 multimodal=crowded, 재조사 필요).
- (b) novelty를 *비-정확도 축*(robustness/efficiency)으로 재정의(문헌상 약한 novelty, 사용자가 음성/측정 framing 거부).
- (c) denoised 종단 변화 1회 재검(long-shot).
