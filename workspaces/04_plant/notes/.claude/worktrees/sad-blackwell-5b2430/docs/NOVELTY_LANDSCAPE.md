# 기술적 Novelty Landscape — 문헌 조사 종합

> 2026-06-20. literature-scout 4팀(종단변화·brain-MRI SSL·site-robust/TTA·사용자 아키텍처)의 독립 조사 종합.
> 목표: "benchmark/음성결과가 아니라 **기술적 novelty**가 궁극 목표"라는 사용자 방향 하에서, novelty가 *실제로* 살 수 있는 자리를 문헌으로 판정.
> ⚠️ 인용은 literature-scout(WebSearch) 보고 기반 — 사용 전 원문 검증 필요 `[VERIFY]`.

---

## 0. 압도적 수렴 (4팀 독립, 같은 결론)

**문헌이 우리의 측정된 R2 천장을 *반박이 아니라 확증*한다.** honest cross-site(외부 코호트/LOCO) 평가에서 deep/SSL/transformer가 morphometry를 이긴 peer-reviewed 증거는 **없다.**

- **Bron 2021** (외부검증, 가장 엄격): AD-CN CNN 0.933 ≤ SVM 0.940(내부)·0.876 ≤ 0.896(외부); MCI 전환 CNN 0.742 < SVM 0.756. → deep ≤ morphometry. `[VERIFY]`
- **BioFINDER**: 종단 deep 0.862 < hippocampal-volume+FreeSurfer 0.910. `[VERIFY]`
- 높은 숫자(VSwinFormer 0.966 등)는 **전부 ADNI-내부·단일코호트·morphometry baseline 없음·cross-site 없음** → 우리가 측정한 천장·confound가 transport에서 무너진다고 예측하는 바로 그 조건.
- 다수 "transformer" 논문이 실은 **FreeSurfer 부피를 입력으로 먹는다**(morph가 신호를 진다고 자인).
- "beats morphometry" 주장은 약체 venue(MDPI)·PET 혼합·큰 cross-site 하락(93→78). `[VERIFY]`

## 1. 방향별 판정

| 방향 | 점유도 | 신호 달성가능 | 판정 |
|---|---|---|---|
| **D. 사용자 아키텍처**(Video Swin/hierarchical/patch-slice) | saturated | **foreclosed** | ❌ 아키텍처-스왑은 novelty 아님. honest cross-site서 morph 못 넘음(문헌 확증). 입력에 FreeSurfer 넣는 논문이 다수 = 천장 자인 |
| **brain-MRI SSL**(cross-sectional) | saturated | low | ❌ gap은 "비어 있으나 *modality 천장 때문* = 함정". R-NCE(2026 preprint)가 morph-residual niche 선점 中 |
| **site-robust / TTA** | saturated | low-med | △ "fair-TTA conditional on confound"는 gap이나 *기존 도구 교집합 = 약한 방법론 novelty*. 음성/측정 framing은 사용자가 거부 |
| **A. 종단 변화율 / spatiotemporal** | **active(미포화)** | **medium** | ✅ **유일하게 살아있는 비-아키텍처-스왑 thesis** (아래) |

## 2. 유일하게 살아있는 thesis (4팀 모두 지목)

> **honest cross-site(LOCO)에서 Δ-morphometry(부피 변화율·Jacobian/SIENA)를 넘는, site-robust 종단 변화율 deep 표현 — deployable test-time adaptation과 결합.**

왜 이것만 살아있나:
1. **구조적 근거(아키텍처-스왑 아님):** 단일시점 부피는 정의상 *변화 궤적·국소 변형*을 못 담는다 → morph가 *경험적*이 아니라 **구조적으로** lossy한 유일 regime. (R2를 원리적으로 우회.)
2. **진짜 미개척:** 기존 종단 deep은 전부 (a) ADNI-내부 CV, (b) 단일시점 baseline과 비교(Δmorph 아님), (c) cross-site 없음. "deep 변화율이 Δmorph를 honest cross-site서 넘는다"는 **문헌에 증명된 바 없음.**
3. **우리만의 자산 결합:** 종단 변화 모델링 + **inductive BN-adapt(우리 +0.06 검증)** 를 site-shift 하에서 결합한 선행연구 **전무**. ← 진짜 novel 메커니즘은 "더 큰 transformer"가 아니라 **"종단 *진짜* 생물학적 변화를 종단 *스캐너 drift*에서 분리하는 deployable TTA"**.
4. **데이터 있음:** ADNI 동일스캐너 paired 757명(≥2 visit), 614명(≥3), SSL pool 12,978.

## 3. ⚠️ 정직한 위험 (낙관 금지 — 이게 결정적)

- **"부재가 gap이지만 양날"**: 문헌이 "deep 변화율 > Δmorph cross-site"를 안 보인 건 *아무도 정직하게 안 해서*일 수도, *되지 않아서*일 수도 있다. 우리 R2 천장 + Bron 2021은 **후자(null)로 강하게 기운다.** 즉 이 thesis조차 **가장 현실적 결과는 Δdeep ≈ Δmorph(음성)**.
- 비교선이 **Δmorph로 상승** — SIENA/Jacobian atrophy-rate는 강한 baseline. 단일시점 morph보다 이기기 더 어렵다.
- 종단 deep AD는 *active*라 선점 위험 있음(c-index 0.70→0.80–0.90 보고 `[VERIFY]`) — novelty는 반드시 *메커니즘(drift-disentangling TTA)*에 있어야, "종단 transformer"로는 점유됨.
- **메타 결론(불편하지만 정직): 우리 측정 + 전 문헌 어디에도 "새 아키텍처가 구조 T1에서 morphometry를 정확도로 이긴다"는 근거가 없다.** "novelty = 정확도 win"이면 evidence-backed 경로가 없다. 추구는 고위험 베팅이고 가장 그럴듯한 결과는 null 재현이다.

## 4. 빠른 kill-test (GPU 약속 전, CPU·즉시)

이 thesis를 살리거나 죽이는 가장 싼 측정 — **변화-수준 baseline bar:**
1. **Δmorphometry(Δfs_vol over 757 paired) → 미래 진행** 예측이 단일시점 morph+DEMO+BASE를 *넘는가?* (종단이 morph 수준에서라도 더하나)
2. 넘는다면 그 위에 deep 변화율이 들어갈 *여유*가 있는지가 다음 질문. 안 넘으면 → 종단 전체가 morph 천장 안 = thesis 조기 종료.
3. NO-GO: Δmorph가 단일시점을 부트스트랩 CI하한>0으로 못 넘으면 종단 novelty 폐기·음성 ledger.

## 5. 사용자 아키텍처에 대한 직답

**Video Swin / hierarchical / patch-slice selection은 그 자체로 novelty가 아니다**(문헌 확증, saturated, honest cross-site서 morph 못 넘음). 이것들은 *수단*일 뿐 — §2 thesis(종단 변화율 + drift-disentangling TTA)라는 *풀 문제*가 먼저 서야 도구로 정당화된다. 아키텍처가 thesis가 되면 minyoung4 무덤 재방문.

> 참조: `docs/COHORT_AUDIT_AND_BIAS_DESIGN.md`·`PRIOR_FAILURE_AND_GOFORWARD.md`·메모리 `p2-novelty-positioning`(Bron 2021 위협). 조사 원본: workflow wf_18e515d5.
