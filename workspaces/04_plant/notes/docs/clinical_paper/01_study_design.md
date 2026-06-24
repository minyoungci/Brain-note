# 연구 설계 — (a) Incremental-value / parsimony 논문

> 2026-06-24. 베뉴=임상 SCI(JAD/JCN/DADM 체급, → [[clinical-sci-venue-target]]). claim-first(CLAUDE.md §5).
> 근거: K-ROAD가 *멀티모달을 다 모았으나 incremental-value 정량은 명시적으로 안 함*(lit/kroad_2024.md §7).

## 0. 한 문장 주제
**"풍부하게 표현형화된 실세계 Asian memory clinic에서, 비싼/분자 모달리티(amyloid-PET·혈액)가 싼 구조 MRI 위에 더하는 한계기여를 leakage-free로 정량하고, 어디서 *등가적으로 무시 가능*한지를 TOST로 형식 증명한다."**

## 1. 중심 claim (검증 전 확정)
싼 것부터 쌓을 때(인구학→구조 T1→FLAIR/WMH→혈액→amyloid-PET), **인지-중증도 특성화의 한계기여는 구조 T1 이후 급감하며, 분자(amyloid) 모달리티의 증분은 사전등록 margin 내에서 등가적으로 무시 가능**하다. 단 amyloid는 *etiology*를 정의하지 *인지-중증도*를 더하지 않는다(역할 분리).

## 2. delta vs K-ROAD (게이트 — 채움)
- K-ROAD: 멀티모달 5,856명 구축·기술, "ML에 쓸 수 있다"만 언급. **incremental-value·등가성·cost-rational 분석 안 함.**
- 우리 delta(한 문장): **"K-ROAD가 구축만 한 멀티모달 스택의 *모달리티별 한계기여*를, 누수통제+등가검정으로 *처음* 정량하여, 분자 모달리티가 인지-중증도 특성화에 등가적으로 불필요함을 보인다."**
- 정직: novelty는 *데이터 규모*가 아니라 *분석(등가성+cost ladder)*에 있음. 단일기관은 한계로 명시.

## 3. 연구질문 (각 RQ ↔ 죽이는 리뷰어 반론)
- **RQ1 (인지 parsimony, 주):** 각 모달리티가 인지-중증도(MMSE·CDR-SB)에 더하는 한계기여는? → "비싼 거 다 필요하다"는 가정을 친다.
- **RQ2 (amyloid 분류 triage, 보조):** 싼 모달리티(구조+FLAIR+혈액+APOE)로 amyloid 양성을 충분히 가려 PET를 *절약*할 수 있나? → "그럼 구조로 PET 대체하면 되잖아"를 *선제 반박*(분자정보는 구조에 없음 = morph 0.66 천장).
- **POS-CTRL (양성대조):** 같은 파이프라인이 FLAIR의 *혈관 dx* 증분은 *검출*함을 보임 → "네 방법이 둔감해서 null 난 것" 반론을 죽인다(failure_root_causes "검정력 부족 ≠ 동등").

## 4. 표본 / 데이터 (manifest 실측 기준)
- **코호트:** AJU all-3(T1+FLAIR+PET 파일검증) n=963; 혈액 완비 부분집합 n=863. 단일기관, cross-sectional.
- **타깃(비순환):** MMSE, CDR-SB(연속) — 어떤 모달리티도 정의 안 함. (RQ2 타깃 amyloid+는 예측자에서 PET 제외해 비순환.)
- **제외/주의:** etiology dx는 *예측 타깃 아님*(FLAIR 순환) — POS-CTRL과 stratifier로만.

## 5. 예측자 ladder (비용/침습 오름차순 — cost-rational 서사의 축)
| 단계 | 추가 블록 | 임상 비용 |
|---|---|---|
| M0 | 인구학(age·sex·edu) | ~0 |
| M1 | + 구조 T1 morphometry(FS vol: 해마·내후각·뇌실·BrainSeg) | 루틴 MRI |
| M2 | + FLAIR/WMH(visual grade) | *동일 MRI 세션 = 한계비용 ~0* |
| M3 | + 혈액 22종 + APOE | 저가·루틴 |
| M4 | + amyloid-PET(SUVR composite/Centiloid) | **고가·분자** |

## 6. 분석 task (각 task ↔ RQ, 전부 GPU 불필요·tabular·표준기법)
- **T1. 계층 incremental 성능:** nested CV(subject-level holdout, 5-fold×N-seed, validation-lock). 각 단계 R²(연속)/AUC(분류) + **paired ΔR² 부트스트랩 CI 하한**. (R3 누수통제 = 프로젝트 dead-end 원인 회피)
- **T2. 등가검정(TOST):** 사전등록 margin(예 ΔR²<0.02)로 M4−M3, M3−M2 증분의 *등가성* 형식 검정. (단순 p>0.05 금지)
- **T3. 고전 nested 회귀(해석용):** partial R²·LRT·AIC로 모달리티별 설명분산 — 임상독자 친화.
- **T4. POS-CTRL:** 동일 파이프라인으로 FLAIR→혈관 dx 증분 *유의 검출* 시연(방법 민감도 증명).
- **T5. RQ2 amyloid triage:** (구조+FLAIR+혈액+APOE)→amyloid+ AUROC·NPV; "PET 절약 가능 비율" 임상지표화. APOE 단독·+morph 단계 비교(우리 기록: morph 0.66→+APOE 0.78).
- **T6. Robustness:** dx 하위군별·모델별(선형 vs GBM) 민감도; KDRC(중복변수)로 *부분* 외부확인(전이주장 아님, 안정성만).
- **T7. 외부 anchoring:** AJU 기술통계(amyloid-by-dx 등)를 K-ROAD 공개수치 *옆에* 제시(재분석 아닌 맥락화).

## 7. 통계 rigor (experiment-methodology + insight 흉터 반영)
- subject-level holdout + validation-lock(R3). multi-seed·**하위군별 보고**(pooled 평균 회귀은폐 금지).
- 증분은 **CI 하한>0** 점추정 금지. 등가는 **TOST**.
- 계층 bar 명시(covariate→morph→image→biomarker; "baseline에 morph 이미 포함" 자기기만 회피).
- 결측: 혈액 완비 863 주분석 + 다중대체 민감도.

## 8. Figure-first (figure 하나=주장 한 구성요소)
- F1. 코호트 구성 + amyloid-by-etiology(우리) vs K-ROAD 맥락.
- F2. **cost ladder × 한계기여**(RQ1 핵심) — 단계별 ΔR² + CI + TOST 등가밴드.
- F3. RQ2 amyloid triage ROC + PET-절약 곡선.
- F4. POS-CTRL(FLAIR가 혈관 dx엔 증분 있음) — 민감도 증명.

## 9. 정직한 scope/limit (먼저 적는다)
단일기관(외부검증 제한, KDRC 부분만) · cross-sectional(중증도지 진행 아님) · MMSE/CDR는 screening급(SNSB full 아님) · amyloid AJU=visual+SUVR(Centiloid 직접 아님).

## 10. Min 확정 필요 (돌리기 전)
1. **사전등록 등가 margin**(ΔR² 무시가능 경계 — 0.02? 임상적 근거로).
2. **주 타깃 확정**(MMSE vs CDR-SB 중 primary).
3. **기관 tier 요건**(JAD/JCN/DADM 충분? ESCI(DADM) 허용?).
