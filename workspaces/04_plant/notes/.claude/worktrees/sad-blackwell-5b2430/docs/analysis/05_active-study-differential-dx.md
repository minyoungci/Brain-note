# 05 · 활성 연구 — 멀티모달 치매 감별진단 (AD-계열 vs 혈관-계열)

> 상태: **활성 positive 방향** (2026-06-22 확정, go/no-go=GO-with-conditions) · 사전등록 protocol은 설계 workflow 산출 후 본 문서 §5에 lock.
> 이 문서는 이번 세션의 *살아남은* positive 결과를 한 곳에 통합한다. 닫힌 방향은 §6 + `../DECISION_LOG.md`.

## 1. 한 줄

실세계 East-Asian 기억클리닉(AJU)에서 **임상의가 직접 계산하지 않는 비순환 morphometry(FreeSurfer fs_vol)가, 중증도(CDR/MMSE) 통제 후에도 AD-계열 vs 혈관-계열 치매의 etiology를 구별**한다 — 세션 통틀어 적대 검증에서 *살아남은* 유일한 positive 신호.

## 2. 검증된 결과 (부풀림 없이, subject-level 5-seed CV + paired ΔAUC bootstrap)

원래 contrast(AD-계열 vs 혈관-계열, N=355): DEMO(나이+성별)=0.510(우연) → +중증도(CDR,MMSE)=0.671 → **+MORPH(비순환)=0.756** → +WMH=0.811 → +amyloid=0.912.

**1차 estimand = ΔMORPH-over-severity** (Tier-2 없이), 3개 사전지정 contrast 전부 CI가 0 제외:

| contrast | N | ΔMORPH-over-severity 95%CI |
|---|---|---|
| AD-계열 vs 혈관-계열(all) | 355 | [+0.022, +0.130] ✓ |
| AD-계열 vs VaD-치매(MCI 제외) | 251 | [+0.064, +0.281] ✓ |
| 순수 AD-without vs 순수 VaD | 155 | [+0.011, +0.228] ✓ |

검증 완료: ① **누수 없음**(subject-level 355=unique subjects, drop_duplicates 선행, DEMO=우연 음성대조 재현) ② **provenance**(fs_vol·CDR·MMSE·aju_amyloid=메인 매니페스트, wmh_grade_visual=`korean_multimodal_manifest.parquet` 1287, 전부 재현 가능).

## 3. Tier 구조 (circularity 정면 처리)

| Tier | 변수 | 역할 | circularity |
|---|---|---|---|
| **1 (headline)** | age·sex·CDR·MMSE·**fs_vol(26 ROI)** | 1차 주장 | **비순환**(임상의 미열람) |
| 2 (강등) | wmh_grade_visual·aju_amyloid | decision-support 절만 | 순환(임상의가 읽고 라벨링; NINDS-AIREN VaD=영상정의) |
| 3 (kill-test) | registered T1(+FLAIR/PET) 텐서 | 학습-rep, **NULL 예상** | T1-only leave-out-modality만 비순환 |

## 4. 데이터

- **코호트: AJU 단독** — 임상 감별라벨(`aju_dx_detail`) 고유. KDRC=coarse CN/MCI/AD, Western=감별라벨 없음 → **외부복제 불가(내부 CV only)**.
- subject-level 355 (complete-case). AD-계열 238행/혈관-계열 231행(세션) → subject collapse.
- 멀티모달 텐서(`flair_brain_1mm_RAS_192x224x192_zscore`, `pet_suvr_1mm_RAS_192x224x192`) 디스크 실재하나 **Western 멀티모달처럼 인덱싱 안 됨 → Tier-3용 modality index 빌드 필요**(미완 작업).

## 5. 사전등록 protocol (LOCKED, 13-서브에이전트 설계+적대리뷰 산출 wrc2gv4m2)

**검증된 결과 (E0–E3, leakage-clean, 부풀림 없이):** 코드=`../../src/microbrain/diffdx_tier1.py`(E0/E1/E2)·`diffdx_e3_severity_matched.py`(E3), 동결표=`../../data/derived/diffdx/tier1_frozen.parquet`.

- **E0 누수 증명:** per-fold scaler.mean_ DIFFER(전역-z 누수 없음), 음성대조 DEMO(나이+성별)=0.512∈[0.45,0.55] PASS. provenance: N=355(AD 190/혈관 165), 0 dropped, 중복텐서 0.
- ladder(leak-free): DEMO 0.512 → +severity 0.677 → **+MORPH 0.755** (인라인과 일치 = 누수 부풀림 아님).
- **E1 PRIMARY (C1, N=355): ΔMORPH-over-severity = +0.077, 95%CI [+0.019,+0.132] → CI 0 제외 → GO ✓**
- E2 확인: C2(N=251) +0.155 [+0.037,+0.268] ✓ · C3(순수, N=138) +0.113 [−0.012,+0.236] (underpowered, 비-gating).
- **E3 severity-MATCHED (N=246): ΔMORPH = +0.261 [+0.172,+0.350] → 생존 ✓ = severity-INDEPENDENT atrophy pattern (novelty 핵심).**
- **E4 robustness (`diffdx_e4_robustness.py`): ✓ 전부 통과.** ICV-method robust(÷ICV +0.077 ≈ residual +0.080); leave-one-ROI-out ×26 range FULL[+0.073,+0.081]/MATCHED[+0.251,+0.270] 전부 양수·0 ROI >50%이동(분산 패턴); leave-one-subtype-out ×7 전부 양수(+0.015~+0.156)·부호뒤집힘 0.

**1차 추정량:** ΔMORPH-over-severity(C1). X0=age+sex+CDR+MMSE, X1=+26 ICV-정규화 fs_vol. L2-logistic(C=1.0, 무튜닝), subject-level StratifiedKFold(5)×5seed, scaling은 Pipeline으로 train-fold 전용, subject-level paired bootstrap(B=2000). **GO 규칙: C1 CI 하한 > 0 AND DEMO∈[0.45,0.55].** (충족.)

**사전등록 실험 (전부 완료):**
- ~~E4 robustness~~ ✅ 통과(위 참조).
- **E5 학습-rep kill-test ✅ 완료 = 사전등록 NULL 확정** (`e5_extract_brainiac.py`+`e5_probe.py`, GPU). frozen **BrainIAC**(ViT-B 96³ SimCLR, 768-d) T1-only → **aju_amyloid**(비순환 생물 타깃), N=1000. **BrainIAC AUC=0.512 ≪ fs_vol 0.697, ΔAUC=−0.185 [−0.231,−0.136]** → 학습 rep이 hand-crafted 못 넘음(AI 돌파구 없음). kill-rule(BrainIAC>fs_vol=누수) 미발동. **degeneracy 공포 → positive control로 추출 유효 입증**(BrainIAC sex AUC 0.807·age R² 0.099 잡음 → amyloid null은 진짜, raw cos~1.0은 DC offset). N=355서 학습>hand-crafted는 누수 신호라는 사전등록이 거짓 novelty 차단.

**Tier-2(WMH/amyloid)** = labeled "circular upper-bound" 참조표만, ΔAUC·abstract 금지. C1 CI가 0 포함이면 Tier-2 미보고.

## 5b. Novelty 주장 (방어 가능, 입증됨)

방법 novelty 아님(foreclosed). **조합 novelty:** ① 사전적 **circularity-decomposition**(비순환 Tier-1 headline + Tier-2 강등) ② co-located T1+FLAIR+PET ③ East-Asian 혼합병리 임상 감별라벨(유일). 핵심 입증=E1(비순환 ΔMORPH, 음성대조)+E3(severity-matched 생존 → severity-independent atrophy pattern). E5(T1→amyloid NULL 사전등록)가 누수-구동 거짓 novelty 차단.

## 6. 정직한 천장 / 닫힌 방향

**천장(부풀림 없이):** specialty 임상-측정 논문(NeuroImage:Clinical/Alz&Dem/HBM). Nat Med 아님. 학습-rep "AI 돌파구"는 N=355서 NULL 우세. 경쟁=Kolachalama *Nat Med* 2024(neuropath 51k, AUROC 0.96). novelty=비순환 circularity-decomposition + co-located 멀티모달 East-Asian 혼합코호트 조합(moderate).

**이번 세션에 닫힌 방향**(상세=`../DECISION_LOG.md` 2026-06-22): 정확도로 morph 넘기(C1), frozen-FM>morph, cortical frozen extraction(AMAES degenerate), 종단 Δmorph, GATE-3 inconclusive, **Study #4 APOE×amyloid cross-pop(비식별+선행 반박)**, **Study #1 amyloid×WMH super-additivity(null)**, cross-modal disentangle(A 식별가정 거짓), 모든 cross-population 인과비교(cohort 공선=비식별).
