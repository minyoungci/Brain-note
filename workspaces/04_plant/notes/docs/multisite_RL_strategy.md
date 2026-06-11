# 다기관 Bias-robust Representation Learning — 전략 노트

> **상태:** 가설·설계 (pre-P0, 미승인). P0 audit 결과(특히 A4 decidability)에 따라 채택/폐기.
> 이 문서는 "bias를 어떻게 해소하면서 다기관 RL을 할까"에 대한 *측정 기반* 답이다. 작성 2026-06-11.
> 근거: 이 라인의 직접 측정(아래 §1) + minyoung2/4/i 실패 + SCANNER_BIAS_PLAYBOOK.

---

## 0. 프레이밍 교정 (가장 중요)

"bias를 제거하면서 다기관 RL" 이라는 질문은 **bias가 제거 가능하고 그게 병목이라는 낙관을 전제**한다.
과거 3번의 실패가 정확히 그 전제에서 나왔다. 올바른 질문:

> **acquisition(scanner) 변이를 population(질병) 신호에서 *분리*할 수 있는가? 분리 가능한 곳은 어디인가?**

bias는 "지우는" 대상이 아니라 "population에서 분리되는 정도"를 *측정*하는 대상이다.
분리 가능하면 다기관 RL이 의미 있고, 불가능하면(undecidable) 정직한 null이 결과다.

---

## 1. 측정된 사실 (이 전략의 토대 — 직접 inspect)

**(F1) Cross-cohort: site ≈ population (분리 불가).** impaired rate(CDR≥0.5): OASIS 20% · AIBL 30% · A4 31% · NACC 36% · ADNI 47% · KDRC 69% · **AJU 98%**. consortium을 지우면 population까지 지워진다 → 글로벌 site-삭제(adversarial/ComBat/MixStyle)는 over-correction. **이미 3번 실패.**

**(F2) Within-cohort: 분리 가능한 부분공간이 존재.** 같은 코호트 안 vendor 변이의 진단-혼입도 Cramér's V(vendor, impaired):

| 코호트 | vendor 수 | V(vendor,impaired) | impaired% spread | 판정 |
|---|---|---|---|---|
| **A4** | 3 (GE/PHI/SIE) | **0.012** | 1.6pp | ★ 가장 깨끗 (vendor ⊥ 진단) |
| **ADNI** | 3 | **0.060** | 8.2pp | 대규모 + 거의 깨끗 |
| AJU | 3 | 0.033 | 1.6pp | vendor는 깨끗하나 CN 없음(98% impaired) → 질병측 무용 |
| KDRC | 4 (model급) | 0.114 | 4.5pp | CN 거의 없음 → 질병측 무용 |
| NACC | 3 | **0.146** | 30.6pp | vendor가 진단과 **얽힘 → 사용 불가** |
| AIBL/OASIS | 1 | — | — | 단일 vendor → within 변이 없음 |

→ **A4(V=0.012)·ADNI(V=0.060) 내부에서는 acquisition이 population과 거의 독립**이다. 여기가 "site를 안 지우고도 acquisition-invariance를 배울 수 있는" 유일한 깨끗한 신호원.

**(F3) 신호 천장 (b)이 지배적 prior.** deep ≈ morphometry 5/5 LOCO 무승부(minyoung2); morphometry residualize 후 embedding=chance 0.529(minyoung4). → 어떤 RL도 *없는 신호를 만들지 못한다.*

**(F4) 구조적 이점/제약.** `roi_final_ready=False`(전수) → ROI-label supervision은 신뢰 상한 막힘 → **label-free SSL이 이 함정을 우회**. longitudinal: subject당 평균 1.80세션(ADNI 3.0) → subject-level split 필수, dx는 subject당 정적이라 다세션은 near-duplicate(유효표본·CI 보정).

---

## 2. 전략 — "분리(disentangle), 삭제(erase) 아님"

핵심 아이디어: **글로벌 site를 적대적으로 지우지 말고, A4/ADNI 내부 vendor 변이(population과 분리된)로부터 acquisition-invariance를 학습**한다. 그러면 population biology를 over-correct하지 않으면서 scanner 축만 둔감해진다.

### 2.1 제안 프로그램 (P0 통과 조건부)
- **Substrate (Arm A):** label-free SSL (MAE류 patch-recon 또는 contrastive), voxelwise 풀 12,978에 학습. ROI fail-closed 면역(F4). 입력=이미지만(누수 금지).
- **Invariance (Arm B):** A 위에 **acquisition-invariance**를 *A4/ADNI 내부 vendor 짝*에서만 학습(F2의 깨끗한 신호). 글로벌 consortium-adversarial 금지(=minyoung4 재현). NACC vendor 제외(F2 confound).
- **Held-out 대응:** 새 코호트엔 vendor 통계가 없음 → **test-time adaptation(BN-adapt/TENT)**. ("평균으로 site 지운다"는 직관이 깨지는 바로 그 지점을 TTA로 메움.)
- **Control (Arm D):** 무처리 plain SSL. Arm B가 D 대비 G1을 유의 개선 못 하면 invariance 폐기(음성 ledger).
- **Harmonization (Arm C):** in-dist 분석용으로만, 전 코호트 동시 감시(NACC 회귀 watch). "해법" 아님, 비교 arm.

### 2.2 왜 과거 3실패와 다른가
- FL/global-adversarial/ComBat: **site를 통째로 삭제** → confound regime에서 population 삭제. ✗
- 본 전략: **측정으로 확인된 분리 가능 신호(A4 V=0.012)만** 사용 → population 보존. 그리고 **audit(P0) 후에만** 진입.

### 2.3 정직한 한계 (낙관 금지)
- vendor ≠ 전체 site 효과. A4/ADNI 내부 vendor-invariance가 **AIBL/OASIS(단일 vendor)·KDRC(다른 scanner)로 transport된다는 보장 없음.** 레버는 confound를 *줄이지* *없애지 못한다.*
- (F3) 천장이 진실이면 분리에 성공해도 morphometry를 못 넘는다. → **null이 가장 가능성 높은 1차 결과.**
- 성공 판정은 항상 **G1 ∧ G2 동시 + LOCO transport + morphometry 바**. 한쪽만은 실패.

---

## 3. 마이크로 실험 사다리 (각 = 1 falsifiable 질문 + kill-criteria)

> "정말 마이크로" = 가장 작은 반증 단위부터. 앞 단계 통과 전 다음 금지. CPU→GPU 순.

| ID | 질문 | 산출 | NO-GO (kill) | 단계 |
|---|---|---|---|---|
| **M0** | site×diagnosis confound 강도? | Cramér's V | — (설계 입력) | P0·A0 |
| **M1** | A4/ADNI 내부 vendor가 *이미지에서* 디코드되나? | within-cohort vendor bAcc | vendor ≈ chance → invariance objective 무의미, B 폐기 | P0·A2 |
| **M2** | morphometry → site/CDR LOCO 바 | bAcc·AUROC·CI | — (필수 바) | P0·A1/A5 |
| **M3** | site 잔차화 후 disease 생존? | residual AUROC | residual ≤0.55 붕괴 → undecidable, RL 보류·정직한 null | P0·A4 |
| **M4** | SSL substrate가 morphometry 바 근처라도? | frozen linear-probe AUROC | LOCO probe < 바−0.05 의 3 arm 연속 → (b) 천장 확정 | P2·Arm A |
| **M5** | within-vendor invariance가 D 대비 G1 개선? | site-probe↓ Δ | Arm D 대비 유의 개선 없음 → B 폐기 | P2·Arm B/D |
| **M6** | held-out 코호트로 transport (dual gate)? | per-cohort G1∧G2 | 단일 fold/seed 성공 채택 금지 | P3 |

각 M은 **5 seed·subject-level·validation-lock**. M0~M3는 CPU(P0). M4~는 GPU(별도 승인).

---

## 4. 결정 트리 (P0 후)

```
M0 confound 강(V>0.3) ──┐
M3 residual 붕괴(≤0.55) ─┴─> undecidable → 정직한 null(minyoungi 명제 재확인) 또는 within-site 평가만
M1 vendor near-chance ───> 이미지에 bias 약함 → (b) 천장으로 피벗
M3 residual 생존(>0.55) + M1 vendor 디코드됨 ──> 분리 가능 → Arm A→B 진행, M4 게이트
M4 SSL probe ≪ 바 (3 arm) ──> (b) 천장 확정 → publishable cautionary
```

> 어느 경로든 결과다. 이 라인의 기여는 "bias 제거 성공"이 아니라 **"(a)/(b)를 정직히 판정"**.

---

## 5. 미결 (Min 판단)
1. SSL objective: MAE(patch recon) vs contrastive — P0 후 결정(누수 지도 A3가 입력).
2. acquisition-invariance 구현: DSBN(조건화) vs decorrelation penalty vs IRM — M1/M3 결과로 택1.
3. within-vendor 짝 정의: A4+ADNI만 vs AJU vendor도(질병측 무용이나 invariance엔 가용?) [불확실].
4. 이 전략 자체를 research-advisor/research-critic로 독립 검증할지.
