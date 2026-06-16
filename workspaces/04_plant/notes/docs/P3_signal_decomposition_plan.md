# P3 PLAN — 다기관 gap-분해의 decidability 지도 (구조 MRI)

> 설계서(코드 전 합의). 2026-06-16 작성 → **research-critic 적대검증 후 개정(조건부 GO).**
> **개정 요지:**
> - Q2(amyloid specificity)는 SNAP/amyloid-independent atrophy 문헌이 이미 점유(F2) + AJU↔KDRC 측정법·
>   base-rate(35% vs 62%=1.77×) confound(F3) → **헤드라인 강등**(within-cohort 보조분석으로만).
> - Q1의 scanner/population 분리는 traveling-subject=0이라 원리적 한계(F1) → **독립 2차추정으로 검증 또는 강등.**
> - C3는 미완주(7/15 fold 중단)이므로 완성 전제 금지 → **Stage-0 GATE로 격상.**
> - 재포지셔닝: "성능 분해"가 아니라 **"confounded multi-cohort regime에서 gap의 어느 성분이 decidable /
>   원리적 undecidable인지의 negative-result 지도"** — 문헌 공백(FINDINGS §3.1), Bron2021과 유일 차별.
> 근거: `insight/failure_root_causes.md`(4-사인), research-critic 2026-06-16, 자산 인벤토리(parquet 직접).

## 0. 목표 (단일 primary 질문 + 보조)
**Q1 (primary):** 다기관 impaired 예측의 train→test gap에서 **어느 성분이 decidable**(scanner-회복분·morph-천장분)
**하고 어느 성분이 원리적으로 undecidable**(population-비가역, traveling-subject=0)인지를 **지도화**한다.
- "image가 morph 넘나"는 묻지 않음(R2/R4 dead). 성능 SOTA 아님. **undecidable 판정도 1차 결과.**
**(보조·헤드라인 아님):** amyloid specificity는 within-cohort 효과크기 메타비교로만(§3, confound 명시).

## Stage 0 — C3 완주 GATE (통과해야 Q1 진입)
- C3 코드 git `2508378` 복원 → OOF 재생성 → 완주(과거 7/15 fold 중단).
- **GATE 통과 조건(둘 다):** (a) image→fs_vol R²≥0.3 (모델이 부피 재현 = (c)해상도/약백본 배제) **AND**
  (b) 잔여(image−morph)가 morph-residual로 환원 불가 = 잔여의 morph 회귀 R²<0.3 (천장 성분 실재).
- **미통과 시:** Q1 중단. (b)/(c) 미결로 기록, 1mm escalate 여부 별도 판단. → **C3 자체 NO-GO를 여기 박음.**

## 1. 데이터 (검증 자산, parquet 직접 2026-06-16)
- 7코호트 13,022세션. T1w·morphometry(fs_vol) 전수. cdr_global 전수(유일 universal). CN7080/MCI4931/AD1011.
- bias 축: scanner-model ADNI 16종(100%)·NACC 11(85%)·AJU 8·KDRC 4·AIBL 2; A4·OASIS 결측. APOE 6코호트(AIBL만 0).
- 입력=T1w 이미지만(+명시 최소메타). morph/scanner/CDR/amyloid는 target/stratify/audit 전용(입력 누수 금지, T1).
- (보조용) amyloid impaired 내 +/−: AJU −629/+344 · KDRC −236/+393 · NACC −56/+68 · OASIS −19/+58 (A4 전원+ 제외).

## 2. Q1 — gap decidability 지도
- 분해: raw → inductive BN-adapt(T10 공정성, target-site unlabeled K calibration→freeze) 회복분 = **분포-shift 성분**;
  잔여 vs morph baseline = **천장 성분**.
- **★F1 수정 (scanner vs population 귀속 — 핵심):** within-ADNI 16-scanner BN-recovery를 cross-consortium gap 분모로
  *직접 쓰지 않는다*. **독립 2차 추정**: within-NACC(11-scanner) BN-recovery를 따로 측정 → 두 within-cohort recovery가
  **|Δ|<0.02로 일치할 때만** "scanner 효과 transportable" 주장. 불일치 시 scanner-회복분은 **각 코호트 내부
  lower-bound로 강등**(cross-site 결론 금지).
- **population-비가역분** = cross-consortium gap − (검증된)scanner분 − morph천장분. 이 잔차는 traveling-subject=0이라
  추가 분해 불가 → **원리적 undecidable로 *명시 보고*** (정직한 핵심 산출, 숨기지 않음).
- **two-level 명시:** within-consortium scanner / cross-consortium population. 포장 금지(desk-reject 방지).

## 3. (보조) amyloid specificity — within-cohort만, 헤드라인 아님
- **cross-cohort 학습/전이 금지**(F3: AJU visual vs KDRC SUVR 측정법 confound + base-rate 1.77× 차이).
- AJU·KDRC **각각 within-cohort**로 impaired 내 amyloid+/− 효과크기 측정 → **메타분석적 비교만**.
- **착수 전 NO-GO(F3):** 공통 cutoff 재이진화 후 base-rate ratio ≥1.5면 보조분석도 중단(현재 1.77× → 거의 발동).
- 기대: SNAP/amyloid-independent atrophy 문헌상 0.5~0.55 예상 → "구조는 비특이" 재확인 → **새 주장 금지, supporting figure로만.**

## 3b. 컨소시엄 BIAS = 측정(제거 아님)
- R1 못 푼다(4라인 확인) → erase 아닌 측정. L1 LOCO+val-lock · L2 site-probe G1 모니터 동반 · L6 decidability(P0-A4식 residualize 생존).

## 4. 평가 엄밀성
- subject-level **nested-LOCO**(인코더 사전학습서 held-out 코호트 제외, T1) + **validation-lock** + **multi-seed ≥3**.
- per-cohort 보고(pooled 금지) + bootstrap CI(cohort cluster). **cohort n<10이면 wild/small-cluster 보정 명시(m1).**
- match=TOST / 초과=one-sided. 점추정 금지(T4). discrimination=AUROC만(T11).

## 5. KILL-CRITERIA (숫자)
- **Stage-0 (C3):** 위 GATE 미통과 → Q1 중단.
- **NO-GO 1 (분해 무의미):** scanner-16 BN-recovery가 cross-consortium recovery와 구별 안 되면 → framing "shift는 대부분 scanner-회복가능"으로 전환(이것도 결과).
- **NO-GO 2 (scanner 귀속 실패, F1):** within-ADNI vs within-NACC recovery |Δ|≥0.02 → scanner분 cross-site 강등(내부 lower-bound).
- **NO-GO 3 (불안정, m2 수정):** 어느 코호트든 AUROC<0.6 **OR** seed sd>0.08 → 진단 먼저(맹목 튜닝 금지).
- **NO-GO 4 (반복):** 같은 arm 3회 NO-GO → 폐기, 상위 복귀(T8).
- **보조 amyloid(F3):** base-rate ratio≥1.5 → 보조분석 중단.

## 6. 스테이징 (비용)
0. **Stage 0 [GPU 승인]:** C3 복원·완주 GATE.
1. **Precursor [GPU]:** ADNI + NACC scanner BN-recovery **독립 2차추정**(F1 검증). population 통제된 scanner baseline.
2. **Main [GPU]:** cross-consortium decidability 지도(impaired target; MCI=morph 0.61 미검정 칸 vs AD/CN 대조).
3. **(보조) [GPU]:** within-cohort amyloid specificity(AJU·KDRC 각각, base-rate gate 통과 시).
- Stage 진입 전 git 체크포인트. GPU=별도 승인(B200 torch.compile 필수, T9). 실패·교훈 `insight/` 누적.

## 7. OPEN ITEMS (착수 전)
- [x] amyloid harmonization (2026-06-16): AJU↔KDRC 공통 visual 축 OK(KDRC SUVR 내부검증 pos1.37/neg0.64). 단 F3로 **cross-cohort 금지**, within-cohort 보조만.
- [ ] C3 git `2508378` 복원 → 현재 manifest 정합 + OOF 재생성(GPU).
- [ ] within-NACC scanner BN-recovery 추정 가능성(11-scanner, 코호트 내 분포) 확인 — F1 수정의 사활.
- [ ] MCI 라벨 코호트 정의(dx_source) fold base-rate audit(R4).
- [ ] dataset redistribution 권한(Korean 공개 가능 여부) — benchmark claim [VERIFY]. 공개 subset(ADNI/OASIS/AIBL/NACC) 재현성.
