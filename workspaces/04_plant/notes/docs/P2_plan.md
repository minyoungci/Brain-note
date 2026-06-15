# P2 PLAN — AD/CN에서 학습 표현이 morphometry를 넘는가 + 컨소시엄 bias 처리

> 설계서(코드 전 합의). research-critic 검증 반영(amyloid→AD/CN 피벗, nested-LOCO, 순환 회피).
> kill-criteria 숫자 명시. 갱신 2026-06-11. 이전 amyloid 버전은 폐기(morph 약해 판정 불가).

## 0. 목표
**morph가 *강한* target(AD/CN, LOCO 0.936)에서, 학습 이미지 표현이 morphometry를 LOCO로 넘는가?**
- 모델이 morph를 *재현 가능*(R²↑)한데도 disease가 morph를 못 넘으면 → **(b) 천장 airtight**.
- 넘으면 → **(a) 부피 너머 신호 존재**. 어느 쪽이든 1차 결과. (amyloid에선 morph 약해 불가능했던 판정.)

## 1. 데이터 (CDR 기반 AD/CN)
- **CN=CDR0, AD=CDR≥1, MCI 제외.** CDR=표준 척도(dx_label 이질성 회피, critic M3).
- **LOCO 5코호트**(양 클래스 ≥40): ADNI(963CN/168AD)·NACC(918/105)·OASIS(531/75)·AIBL(433/63)·KDRC(280/165). 합 **CN 3,125 / AD 576 subj**.
- A4(CN-only 757)·AJU(AD-only 198): held-out 불가, **train 보강 옵션**(클래스 편중 주의).
- subject-level split, **subject당 1세션**(near-dup 방지). 입력=T1w 이미지만(1.5mm). morph/scanner/CDR/APOE 입력 금지.
- 불균형 AD 16% → class-weight. confound Cramér's V=**0.222**(KDRC 0.37 outlier).

## 2. 세 가지 동시 측정 (각 held-out 코호트 H)
1. **morph baseline(바):** fs_vol→AD/CN, 4코호트 학습→H. ≈0.936.
2. **모델작동 R² 체크(nested, T1 누수차단):** 인코더→fs_vol 회귀를 **H 제외 4코호트로** 학습→H에서 R². 높음=모델 부피 재현(=(c) 배제).
3. **(a)/(b) 검정(순환 회피, T2):** 이미지→AD/CN을 **H 제외 4코호트로** 학습→H. **frozen morph-probe 금지**(≈morph 자명). **supervised from-scratch 또는 morph-pretrain-init+fine-tune.**

## 3. ★ 컨소시엄 BIAS 처리 (층상 방어 — "지우기" 아님)
> 모든 증거(P0·minyoung4·scout)가 "글로벌 site 삭제는 confounded regime서 over-correction"이라 경고. 그래서 *erase 아닌 측정·통제·전이*.

- **L1 평가 = 1차 방어:** subject-level **LOCO**(held-out 코호트 unseen) + **validation-lock(EMA)**. transport가 진짜 site-robustness 시험.
- **L2 항상 G1 모니터:** 표현→consortium **site-probe bAcc**를 disease AUROC와 *함께* 보고(dual-gate). 기준: morph-features 0.27(목표), Stage1 from-scratch 0.81(나쁨). **site를 외우면서 high AUROC면 누수 의심.**
- **L3 confound-aware 학습:** class-weight + **site⊥label 균형 샘플링**(KDRC 0.37 outlier 때문에 site→base-rate 지름길 차단). per-cohort + prevalence baseline 병기.
- **L4 invariance 개입(Arm B, 정직한 low prior):** Arm D(무처리)와 비교. **글로벌 consortium-adversarial 금지**(minyoung4 2회 실패). 대신 **acquisition-axis 조건화(DSBN)** 또는 clean-vendor subspace(A4/ADNI vendor⊥dx) decorrelation. kill: Arm D 대비 G1 유의 개선 못 하면 폐기.
- **L5 test-time adaptation:** held-out 코호트의 *unlabeled* 이미지로 BN-adapt → 새 site 분포 흡수(라벨 불필요).
- **L6 decidability 판정:** AD/CN을 site-residualize 후에도 살아남나(P0-A4식). 살아남으면 invariance 안전, 무너지면 over-correction 확정 → "지우면 안 됨" 증거.

> **핵심 질문(이 실험의 과학적 산출):** 어떤 bias 처리(B/C/TTA)가 LOCO transport를 무처리(D) 대비 *실제로* 올리나? 못 올리면 → "bias는 실재하나 제거 불가, morphometry가 robust 경로" = 정직한 1차 결과.

## 4. 평가 엄밀성 (critic 요구)
- **multi-seed ≥3**, per-fold AUROC+bAcc+**bootstrap CI(cohort cluster)**.
- **TOST equivalence**(match 주장) / one-sided exceedance(초과 주장). 점추정 금지.
- 바 2개: **morph 단독(과학적)** + morph+APOE+age(임상).

## 5. KILL-CRITERIA (숫자)
- **NO-GO 1(천장):** image AD/CN LOCO가 morph(0.936) 대비 CI 상한이 0 이하(미초과)가 ≥4/5 fold ∧ ≥3 seed **이고** 모델작동 R²>0.5(부피 재현됨) → **(b) airtight**, 딥 arm 중단.
- **NO-GO 2(불안정):** ≥2 코호트 AUROC<0.6 붕괴 ∧ seed sd>0.08 → 진단 먼저(맹목 튜닝 금지).
- **NO-GO 3(bias 처리 무효):** Arm B/C/TTA가 Arm D 대비 G1 유의 개선 못 함 → 그 개입 폐기·ledger(insight/).
- **NO-GO 4(반복):** 같은 arm 3회 NO-GO → 폐기, 상위 복귀(insight T8).
- **모델 못 작동(R²<0.3):** (c) 미결 → 1mm escalate, (b) 결론 금지.

## 6. 판정 논리 → 결론
| image vs morph(0.936) | R² | site-probe | 결론 |
|---|---|---|---|
| 유의 미초과 | 높음 | (무관) | **(b) 천장 airtight** |
| 동등(TOST) | 높음 | 낮으면 G1통과 | match, beyond 없음 |
| 유의 초과 | 높음 | 낮음 | **(a) 신호 존재 + bias 처리 성공** |
| 초과하나 site-probe 높음 | — | 높음 | site 누수 의심 → Arm B 필수 |
| 미초과 | 낮음 | — | (c) 미결 → 1mm |

## 6b. ADDENDUM C4 (2026-06-15) — L5 BN-adapt의 transductive/inductive 공정성 검증
> 배경: Tier-2 결과 none_tta(transductive BN-adapt) 0.910 vs none 0.844 = 회복 +0.06. 단 transductive는
> held-out 배치 통계를 추론에 쓰므로 morphometry(inductive, subject 단위)와 **불공정 비교**(novelty 실측 C4).
> 해상도는 무관 확정(2026-06-15 ledger) → 2mm 사용(속도).

- **3-way BN eval (동일 학습, 동일 고정 eval subset):** raw(학습 running stats) / transductive(eval 배치 통계) /
  **inductive**(target-site calibration subset K개, 라벨 미사용·eval과 disjoint로 BN 재계산→freeze→per-sample).
- calibration pool=256(seed 고정), K∈{64,128,256} sweep, eval=cohort−256. seeds 0,1. 격리 스크립트 `adcn_inductive_bn.py`.
- **KILL/판정:**
  - inductive(256) ≈ transductive (±0.01) → **C4 PASS**: 회복 공정·배포가능 → "0.91 도달 정당, 잔여=천장" 유지 → C3 진행.
  - inductive가 raw→transductive gap의 **<50% 회복** → 회복은 transductive 아티팩트 → 0.910은 불공정 상한 → 약화, ledger.
  - inductive < raw → K noise/구현버그 의심 → 진단(맹목 반복 금지).

## 7. 스테이징 (비용)
- nested-LOCO 인코더 5× + finetune 5×multi-seed = 1.5mm ~반나절 GPU. → ① morph baseline(즉시) → ② R² 체크 1-2 fold(모델작동 확인) → ③ image LOCO 전체 → ④ bias arm(B/C/TTA).
- Stage 진입 전 git 체크포인트. 실패·교훈은 `insight/`에 누적.
