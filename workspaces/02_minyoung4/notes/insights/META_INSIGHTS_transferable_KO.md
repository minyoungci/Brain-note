# META INSIGHTS — 데이터 불문 이관 가능한 교훈 (다른 연구에도 적용)

> 특정 데이터가 아니라 *방법론·연구전략* 차원의 재사용 가능한 heuristic.
> 각 항목: **교훈 / 근거(측정) / 적용법**. 새 연구 시작 시 이 목록을 체크리스트로.

---

## 1. 영상 ceiling 진단을 *method 작업 전에* 먼저 (가장 비용 절감 큰 게이트)
- **교훈**: 영상 method(fusion/atlas/SSL/attention)를 만들기 *전에*, `raw-voxel → morphometry → +clinical+APOE` ΔAUC ladder를 먼저 측정하라. clinical+APOE 위로 영상 ΔAUC가 ~0이면 *어떤 method도* 못 이긴다.
- **근거**: intensity 0.88 < morpho 0.91; +morph over clinical+APOE = +0.038(CN/AD), **MCI선 CI∋0=0**. BrainIAC 0.735 < morpho 0.91.
- **적용법**: 새 영상 예측 프로젝트는 *1일* ladder 게이트로 시작. headroom 없으면 method 개발 중단, task/데이터 전환.

## 2. "site=population irreducible"은 *가정이 아니라 검정 대상*
- **교훈**: 다기관 데이터에서 "site가 생물학과 얽혀 harmonization이 신호를 망친다"는 통념을 *가정하고 설계하지 마라*. disease-match 후 측정하라.
- **근거**: 우리가 이 통념으로 여러 방향을 설계했으나, 자체 E2(disease-matched)가 **cross-ancestry deflation +0.05→−0.001 (p=0.79)**로 반증. 겉보기 site=biology 얽힘은 *disease-imbalance artifact*였다.
- **적용법**: harmonization deflation 주장 전 반드시 (a) disease/age-matched subset, (b) cross-cohort transfer(우리 Phase3b: 붕괴없음)로 교차확인. site는 ranking-benign일 수 있다.

## 3. 선행연구 scooping 체크를 *결과를 믿기 전에* — 지역(한국어 포함) SOTA까지
- **교훈**: "새롭다"고 믿기 전에 lit-gate. 특히 *지역 코호트 SOTA*(한국어 학회지 포함)를 명시 검색.
- **근거**: 이번 세션 "positive" 3건이 scooping으로 붕괴 — PP→amyloid(A4/LEARN 2025), MCI-amyloid-without-PET(한국 0.856 > 우리 0.76), triage(plasma pTau217 0.935로 필드 이동).
- **적용법**: 모든 finding에 [이미있음/부분/gap] 판정 + 대표논문. 영어 검색만으로 "gap"이라 단정 금지(검색범위 한계 명기).

## 4. 생성 ≠ 검증 — 자기기만 카탈로그 (전부 독립검증이 잡음)
- **교훈**: 자신이 만든 "positive"는 반드시 독립 audit(code-auditor)+critic+lit 통과 후에만 믿어라. SD/CI를 무시하는 auto-게이트는 self-eval 편향.
- **근거(이번/이전 세션 실제 사례)**:
  - E1 rho=0.90 → disease-imbalance artifact(E2가 폭로).
  - Phase1 "clean double-dissociation" → scooped + AJU-only + p-floor 버그 + ICV-artifact.
  - Phase2 auto-✅ "stable subtype" → **ARI SD 0.43 무시**, ordinal-WMH artifact.
  - Phase3b triage NPV<base-rate → **변수 재사용 버그**(MCI 아닌 AD에 계산).
- **적용법**: "Done/완료" 선언 전 독립 검증 필수. 이상신호(NPV<base, p=정확히 0.004 반복, CI 안 보이는 ✅)는 버그 의심 트리거.

## 5. 천장이 *정보부재*면 → 데이터 unlock > 분석 cleverness
- **교훈**: ceiling이 "신호가 이 modality에 없음"이면 더 정교한 모델은 낭비. 레버는 *새 측정*이지 새 architecture 아님.
- **근거**: 영상 4회 측정 모두 ~0 over clinical+APOE. 반면 plasma pTau217은 amyloid AUC 0.935(다른 modality엔 신호 존재).
- **적용법**: ceiling 부딪히면 "method 부족인가, 정보 부재인가" 먼저 판별(=#1 ladder). 정보부재면 modality 추가(혈액/유전) 또는 task 전환.

## 6. SSL/foundation viability 게이트 (사전학습 *전에* 체크)
- **교훈**: 자체 SSL/foundation이 경쟁력 있으려면 다음 중 ≥1 충족 필요 — ① ≥1만 subject(또는 외부 대규모 pretrain), ② image-headroom downstream(seg/lesion/PET예측), ③ site-invariance엔 ≥5-10 site(+traveling-subject).
- **근거**: BrainSegFounder 41k, FOMO 60k; FOMO25 "scaling unreliable"도 ≥1만에서 관측. 우리 2000/2-site/ceiling은 셋 다 실패.
- **적용법**: pretraining GPU 투입 전 위 3조건 체크. 다 미달이면 frozen 외부모델 probe로 충분(우리처럼 음성 확인).

## 7. Negative result는 *측정이 leakage-clean이고 mechanism이 있으면* 자산
- **교훈**: dead-end 지도 자체가 방법론/resource 논문이 될 수 있다("capacity meets confound/weak-signal"). 대부분 논문은 *승리*만 보고하므로 덜 점령됨.
- **근거**: 7코호트 leakage-clean foundation 패배 측정 + mechanism(ICV-norm+ROI-pooling이 구조적 site-robustness, deep엔 그 inductive bias 없음).
- **적용법**: ⚠️ self-eval 순환 회피 위해 *제3자 검증축*(traveling-subject, 외부 official task) 필수. 없으면 audit 형태로만 방어. venue: NeuroImage/MELBA/reproducibility.

## 8. 통계/구현 함정 (반복 발생)
- **ordinal을 연속모델에**: 3값 ordinal(WMH grade)을 Gaussian GMM에 넣으면 포화점에 spurious cluster. 군집 전 `n_unique` 진단.
- **ICV 미정규화**: raw volume → 머리크기 artifact(ICV-norm 후 DM/BMI 결정인자 소멸). 부피는 항상 /BrainSegVol.
- **cohort-orthogonal 결측 = site proxy**: KDRC/AJU가 *다른* 라벨을 가지면 결측패턴이 cohort 누수 신호. pooled supervised 위험 → SSL(label-free)+frozen probe가 안전.
- **full-cov GMM 소군집**: 소군집(n<50)에 full covariance → 특이공분산 → BIC 비물리적 폭락. diag/spherical 사용, BIC 단독 신뢰 금지.
- **paired bootstrap**: ΔAUC CI는 같은 resample subject에 두 모델 OOF로 paired. NaN-OOF 마스킹 필수.

## 9. Overclaim 철회 규율
- **교훈**: 효과크기를 정직하게. CI∋0 → "redundant"로만(우월 주장 금지). 부분예측(0.76~0.79)을 "불가결/대체불가"로 쓰지 마라.
- **근거**: "PET irreplaceable" → 0.79는 부분회복이라 "확정엔 PET 필요"로 철회. AUC 0.76 = "PET 필요"와 "일부 생략가능"이 *둘 다 참*.
- **적용법**: 모든 주장에 95% CI 동반. "moderate/modest"를 두려워 말 것. known vs new 명시.

## 10. easy-contrast 함정
- **교훈**: CN vs AD(쉬운 대조)는 PET/영상 가치를 *과소*평가. 실제 임상용처(MCI/모호 staging)에서 검증해야 의미.
- **근거**: CN/AD redundancy(ΔAUC+0.003)는 expected. MCI로 옮겨야 실제 질문. 단 cross-sectional status일 뿐 conversion(PET 진짜 가치)은 longitudinal 필요.
- **적용법**: 예측/증분 주장은 *어려운·임상관련* subgroup에서. 쉬운 대조의 결과를 일반화하지 말 것.
