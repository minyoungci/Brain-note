# SCI 임상저널 피벗 — 방향 결정 (2026-06-14)

_AI 컨퍼런스(정확도 SOTA) 프레이밍이 막힌 뒤, SCI급 임상저널 + 최신 AI 기법 + 전체 데이터 활용으로
재설정. research-advisor + literature-scout 독립검토 + 디스크 데이터 재확인 종합. 이전 실패 참조._

## TL;DR (결정)
> **플래그십 = "서구→한국 cross-population AD 영상-바이오마커 *횡단* transportability & fairness"**, 최신기법 =
> **group-conditional conformal/calibration + domain-generalization 평가**, 정직하게 **modest한 external-validation
> 천장(0.8 internal이 외부서 붕괴)을 *기여*로** 보고. 타깃: *NeuroImage:Clinical* / *Alzheimer's & Dementia* /
> *Radiology:AI*. **정확도 SOTA 주장 아님 — 외부검증·보정·형평성이 기여.**

## 1. AI 컨퍼런스 부적합 — 확정 (실패 요약, 반복 금지)
morphometry-oracle 천장(learned-rep는 morphometry+임상 못 넘음), T1→molecular ~chance, site=cohort 교란,
SSL viability gate 실패, 순환(label=threshold(morphometry)). flagship exp01–04: amyloid 예후 증분 **+0.03~0.07
(modest), 큰 win 없음**. → 정확도 novelty는 이 데이터에서 정직하게 불가. **이 데이터는 rigorous modest 효과 +
clean negative를 지지** → 임상저널의 "외부검증·보정·형평성" 보상 구조와 정합.

## 2. 전체 데이터 활용 — 재확인 (디스크 검증값, claim별 분모)
| 자산 | 실측 | 활용 판정 |
|---|---|---|
| **Korean 종단** | KDRC **0명** ≥2세션, AJU **286명**(V1/V2) | ⚠️ **prognosis external 불가** → advisor #1(종단+Korean) 기각 |
| **Korean 횡단 임상/amyloid** | AJU dx96·APOE100·amyloid_visual100·MMSE100·CDR100; KDRC dx85·APOE100·amyloid_visual100·SUVR94·CDR59 | ✅ **횡단 transportability external 강력** (Korean=주인공) |
| **amyloid 횡단(전수)** | A4 1811+KDRC 856+OASIS 1048+NACC 515+**ADNI 1203(UCBERKELEY, join 100% 검증)** ≈ **5,433 / 5코호트** | ✅ **scale가 진짜 산출물** (인구-규모 amyloid 참조) |
| **종단(예후) 학습** | ADNI conv 791(162ev)/slope 783 + OASIS conv 282(23ev)/slope 274 | ~**1k events ≠ 13k** (Western only) |
| **dx 라벨 이질성** | AJU(권위 dx_session) MCI801·AD239·**CN144**·OtherDem94; KDRC CN282·AD249·MCI239 | ⚠️ 순진한 pooling 금지, 정의 lock. ~~CN23~~=clin_dx_label 함정(→[`06`](06_korean_richness_audit.md) 정정) |

**핵심**: "13k"는 대부분 claim에서 **decoration/liability**. 실제로 scale가 *payoff*인 곳은 **횡단 amyloid(5,433)와
cross-population(Korean external)** 뿐. 종단 예후의 effective N은 ~1k(Western). Methods에 분모를 외과적으로 명시.

## 3. 추천 방향 (ranked, 실패-회피 명시)
### #1 [플래그십] 서구→한국 횡단 transportability & fairness (Korean=external)
- **임상질문**: 서구 코호트로 학습한 AD 위험/amyloid-positivity/위축-패턴 모델이 비서구(한국) 인구에서 *얼마나·어디서
  깨지나* (discrimination·calibration·subgroup fairness), 그리고 biology-보존 harmonization이 보정을 고치되 한국-서구
  생물학 차이를 지우지 않나.
- **천장 안 죽는 이유**: 정확도 주장이 아니라 **transportability/calibration audit**. site=population을 *제거*하려는
  순간 biology가 chance로 죽는다는 우리 결과(실패#3)를 *무기화* — full site-removal을 목표로 안 함. T1-image→molecular
  주장 안 함(임상 correlates + morphometry로 위험, 또는 영상 천장 자체를 정직 보고).
- **데이터**: 학습=서구 5코호트, **external=Korean(AJU+KDRC) 횡단**. amyloid 5,433. → **scale·Korean 둘 다 payoff.**
- **최신기법**: domain-generalization LOCO + **group-conditional conformal**(코호트·APOE·성별·민족별 coverage) +
  feature-level ComBat(보정-repair용, accuracy-boost 주장 아님).
- **결과(정직)**: "서구학습 모델은 한국서 calibration drift, discrimination 부분전이, ComBat은 보정만 고침" — rigorous·
  임상실행가능. 내부 0.8+가 외부서 붕괴한다는 reality-check가 **현재 문헌에 비어있는 gap**(scout 확인).
- **타깃**: *NeuroImage:Clinical* / *Radiology:AI* / *Brain Communications*.

### #2 [scale-payoff] 인구-규모 amyloid-positivity surrogate + 다운스트림 예후 효용 + Korean 보정
- 임상 correlates(APOE·age·cognition·위축, **T1-image 아님**)로 amyloid-positivity 확률 → trial-screening(절약된 PET수),
  **측정 amyloid로 검증 + 다운스트림 conversion 효용 검증**(순환 회피). 5,433/5코호트로 cross-population 보정 audit
  (한국 e4 빈도 차이: AJU 27% vs KDRC 49%). 타깃 *EJNMMI* / *A&D:TRCI*.

### #3 [보조] 서구 종단 amyloid 예후 증분 (exp02–04)
- amyloid 예후 +0.03~0.07, Western LOCO, 메커니즘(상류). **Korean external 불가**(종단 없음) → 단독 플래그십 아님,
  #1의 보조/메커니즘. 타깃 *A&D:DADM*.

### 강등/제외
- harmonization **신기법** 제안(문헌 crowded), **Korean 종단 예후**(데이터 없음), 멀티모달 DICOM 변환(고비용·횡단
  intersection 작음 → scale liability).

## 4. 정직한 한계 (반드시 본문에)
- **plasma pTau217이 MRI-amyloid-surrogate를 능가**(AUC~0.95, Lancet Neurol 2025) → 정면 인정하고 **혈액이 못하는 것
  (공간 위축 패턴·궤적·*한국 등 under-served 인구 형평성*)**으로 가치 재정위.
- traveling-subject 0 → "한국 정확도"가 아니라 **audit/calibration/fairness**로 framing.
- modest 효과 = 약점 아니라 **정직한 external regime** (내부 0.8+ 미보고분). overclaim이 이 데이터의 cardinal sin.
- dx 라벨(AJU CN **144**세션, ~~23~~=clin_dx_label 함정 정정→[`06`](06_korean_richness_audit.md)) → CN-vs-AD AJU서 modest 가능(구조적 불가 아님); amyloid-positivity/연속 타깃/stratified, 정의 lock(`03_spec §3/§7`).

## 5. 다음 단계 (CPU, 승인 불요)
1. 라벨/분모 정의 lock (AJU MCI-dominant, KDRC 균형; amyloid_visual 코호트별 코딩 통일).
2. **횡단 transportability harness**: 서구학습→Korean external LOCO + group-conditional conformal + calibration/NRI.
3. 결과 research-critic/code-auditor 독립검증 후 #1 매뉴스크립트 골격.
(GPU는 #1/#2엔 거의 불요; 종단 transformer만 별도 승인.)

## 출처
research-advisor(ac0f08a2) + literature-scout(aac6c001) 검토; 디스크 재확인(이 문서 §2); 실패원장
`00_data_constraints.md`, `META_INSIGHTS_transferable_KO.md`, `FINAL_CONCLUSIONS.md`, flagship `Flagship_Exp/`.
대표 SCI: Bron NeuroImage:Clinical 2021(외부검증 법칙), A&D 2025 ADNI+GARD(dx-only=gap 잔존), Lancet Neurol 2025(pTau217).
