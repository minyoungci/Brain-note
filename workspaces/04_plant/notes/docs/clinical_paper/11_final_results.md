# 최종 결과 — amyloid–vascular 이중 예후축 (paper-ready, 2026-06-24)

> (i) 확정. 사전지정 모델만(조작 없음). 코드 `experiments/incremental_value/10_final_analysis.py`. Figure `figs/final_two_axis.png`.

## Table 1 — 코호트
n=286 (MCI 252·AD 32·CN 2), age 71.9±7.5, 여성 71%, edu 8.4y, interval median 1.94y, baseline MMSE 24.2 / CDR-SB 2.4, amyloid+ 32%, vascular-etiology 26%. ΔMMSE −0.72±3.37, MCI→AD 전환 23/252.

## 주 결과 — 두 독립 예후축 (full 임상바: age·sex·edu·baseline MMSE·CDR·dx·interval 통제)
| 축 | ΔMMSE(2yr) | MCI→AD 전환 |
|---|---|---|
| **Amyloid-PET+** | β=−1.86 [−2.69,−1.02] **p<0.001** | Cox HR=2.90 p=0.046 / logit OR=4.34 p=0.012 |
| **Vascular etiology** | β=−1.03 [−1.90,−0.16] **p=0.021** | Cox HR=3.36 p=0.011 / logit OR=5.08 p=0.007 |

- within-MCI(진단 proxy 배제, n=252): amy β=−1.29 p=0.004 · vasc β=−1.31 p=0.005 — 둘 다 견고.
- **2×2 가산 구조:** amy−/vasc− +0.12(전환2%) · amy−/vasc+ −1.04(11%) · amy+/vasc− −1.68(11%) · **amy+/vasc+ −2.28(39%)**.

## modality 증분 지도 (clinical bar 위 nested-CV ΔR²)
- +amyloid **+0.045** [독립] · +hippo구조 **+0.028** [독립] · +vascular −0.004(null*) · +WMH-DL −0.006(null) · +혈액 −0.012(null)
- *vascular는 *연관*(β·HR) 유의하나 *개별예측 CV증분*은 약함(작은 subgroup) — 다변량 연관이 결과, 예측력 한계 명시.

## 정직한 한계
- **AI-WMH(FS WM-hypo 객관적 부피) = null**(age와 corr 0.42, full바서 p=0.13). vascular 신호는 *WMH 부피*가 아닌 *임상 etiology 패턴*. → "WMH burden ≠ 예후" secondary.
- vascular etiology 라벨은 영상-정보 사용(단 outcome=미래 인지라 예측은 비순환).
- 전환 23 events(검정력 보통). 단일기관·MCI중심·MMSE screening급(CDR 보조).
- novelty: Lee2016(SVaD 이중축 n61)·Younes2025(amyloid 단독). **delta=전체 실세계 MCI 스펙트럼 + 가산 2×2 + 전환 + WMH-부피-아님 nuance + full-stack 통제.** 체급 중위 SCI.

## 결론
주제("실세계 Asian MCI의 amyloid–vascular 이중 예후축")가 **데이터로 견고히 지지됨** — 두 축 독립·두 outcome·가산 구조. AI는 파이프라인 도구(FastSurfer morphometry·DL-SUVR); 영상 AI(WMH)는 예후 음성(secondary).
