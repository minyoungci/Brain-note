# minyoung4 — "조화(harmonization)하기 전에, 분리 가능한지부터 측정하라": 리셋된 다코호트 뇌 MRI 워크스페이스

## 한눈에
- minyoung4는 특정 연구 방향을 확정하지 않은 채 이전 연구 산출물을 전부 삭제하고 처음부터 다시 시작한 워크스페이스다 (출처: README.md, AGENTS.md). **이 워크스페이스는 현재 "VLM 치매진단" 프로젝트가 아니다** — AGENTS.md는 VLM/MLLM이 기본 방향이 아니라고 명시한다 (출처: AGENTS.md).
- 세션 전체를 관통하는 측정된 하드 사실: 이 데이터의 임상 라벨(dx/amyloid/cdr)로는 어떤 deep method도 morphometry baseline을 못 넘고, site=population 얽힘이 비가역(irreducible)이다. de-confounding·SSL·foundation-adaptation·harmonization 네 출구가 모두 측정으로 막혔다 (출처: docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).
- 살아남은 기여 후보는 "harmonize하기 전에 site가 population과 분리 가능한지 측정하는 calibrated diagnostic" — **excess subspace-alignment** 메트릭이다. 자체 데이터 calibration은 통과했고 외부 traveling-subject calibration이 남았다 (출처: experiments/separability_diagnostic/PAPER_PLAN.md).
- 가장 최근(2026-06-13) scanner/population decomposition 방향은 **VERIFIED NEGATIVE** — 겉보기 신호가 disease-prevalence 불균형 artifact로 판명되어 기각됐다 (출처: SPEC.md, experiments/20260613_scanner_pop_decomp/reports/SUMMARY.md).
- 정직한 현 위치: top-AI(method-win) 논문은 없음. 현실적 산출물은 mid-venue(NeuroImage:Clinical/MELBA/HBM)급 diagnostic 또는 cautionary 논문 수준 (출처: SPEC.md, experiments/separability_diagnostic/PAPER_PLAN.md).

## 배경·문제 정의
연구 대상은 7개 코호트(ADNI/NACC/A4/OASIS/AIBL/AJU/KDRC, 美·濠·韓 혼합)의 구조 T1w MRI로 CN/AD 등 임상 라벨을 푸는 문제다 (출처: SPEC.md, docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md).

핵심 제약 두 가지가 모든 시도를 규정한다.

1. **traveling-subject가 0이다.** 같은 피험자를 여러 스캐너로 찍은 데이터가 없으므로 site 축을 age/sex/disease/ancestry로부터 원리적으로 분리할 수 없다 (출처: experiments/separability_diagnostic/STUDY_PROTOCOL_E.md).
2. **site = population = severity가 얽혀 있다.** 코호트가 곧 국가/인종/스캐너이므로 "site 제거"가 곧 "신호 제거"가 된다. harmonization(ComBat 등)을 기본값으로 적용하지만, 이 regime에서는 신호를 unmask하는 게 아니라 deflate(손실)시킬 위험이 있다 (출처: experiments/separability_diagnostic/STUDY_PROTOCOL_E.md, docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).

따라서 워크스페이스의 운영 원칙은 "방향을 정하기 전에 data contract, leakage risk, baseline, validation을 먼저 정의한다"이며, 새 실험은 leakage-clean 코호트(AJU/KDRC)와 다seed·permutation null·calibration을 강제한다 (출처: README.md, AGENTS.md).

## 데이터
- **manifest**: `official_manifest_full_n4_real_final.csv`, 7 코호트. QC-PASS 13,022 T1w 세션, 실제 dx(CN 7,580 vs AD+Dem 969), fs_vol·clinical 내장 (출처: SPEC.md, docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md).
- **leakage map**: AJU·KDRC = CLEAN(공개 foundation에 미포함), ADNI/OASIS/AIBL = likely 누수, NACC/A4 = uncertain. 그래서 task-probe는 clean 코호트에서만, site-probe는 전 코호트에서 측정한다 (출처: SPEC.md).
- **feature space 2종**: FastSurfer morphometry(30-d, ICV-정규화 ROI 부피) / BrainIAC learned features(768-d, SimCLR 3D ViT) (출처: experiments/separability_diagnostic/reports/final_diagnostic.md, docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).
- **라벨의 한계**: `clin_dx_label`이 subject-고정(첫 진단을 전 세션에 복사)이라 MCI→AD 전환을 manifest로 셀 수 없다. ADNI multi-session 849명 중 dx 변동 0%. longitudinal conversion 연구는 이 manifest로 불가 (출처: docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).

> 임상 텍스트 feature 인벤토리도 별도로 작성됐는데, manifest가 raw를 대폭 under-join하고(KDRC MMSE raw 100% ↔ manifest 0%) 일부 컬럼은 센티넬 값(-4)으로 오염돼 있다는 점이 검증됐다 (출처: docs/context/CLINICAL_TEXT_COMMON_FEATURES_20260608_KO.md).

## 접근·방법
세 갈래의 방법론이 시간순으로 시도됐다.

1. **Foundation adaptation ladder (Direction 2)**: BrainIAC를 ① frozen-probe ② linear-probe ③ LoRA/partial-FT ④ full-FT로 적응시키며 LOCO transfer와 site-loading을 측정. baseline은 from-scratch 동일 backbone과 morphometry (출처: SPEC.md).
2. **Separability diagnostic (E)**: harmonize "전에" site가 population과 분리 가능한지 알려주는 사전 진단 도구. 핵심 메트릭은 disease 방향과 cohort 부분공간 사이의 **excess subspace-alignment** ‖P_cohort·w_disease‖ − chance (dimension-matched, chance-corrected). 음성대조(random pseudo-cohort)와 분리가능 regime(within-scanner)으로 calibration (출처: experiments/separability_diagnostic/STUDY_PROTOCOL_E.md, reports/final_diagnostic.md).
3. **Scanner/population decomposition (06-13)**: 공개 traveling-subject(ON-Harmony/SRPBS)로 순수 scanner 효과를 학습해 전이하여 코호트 거리를 scanner vs population 성분으로 cross-sectional 분해하려는 시도 (출처: experiments/PROPOSAL_technical.md, SPEC.md).

방법론 메타교훈이 명시적으로 기록돼 있다: naive INLP-deflation 메트릭은 cohort-decodability와 차원에 교란되어 calibration에 실패했고(분리 가능한 within-ADNI scanner가 얽힌 7-cohort보다 더 큰 deflation을 보이는 역전), excess-alignment로 교체해야 통과했다. 또한 single-seed는 오도하므로 모든 claim은 ≥3, 핵심은 ≥5 seed (출처: experiments/separability_diagnostic/reports/improved_metric.md, SPEC.md).

## 현재 상태와 결과

### ✅ 확정 (robust)
- **excess-alignment diagnostic의 calibration 통과**: random pseudo-cohort +0.086±0.109, within-ADNI scanner +0.003±0.081 (둘 다 분리 가능 ≈ 0) ≪ 7-cohort +0.546±0.018 (얽힘) (출처: experiments/separability_diagnostic/reports/final_diagnostic.md).
- **표현학습도 얽힘을 못 줄인다**: 7-cohort entanglement가 morphometry +0.546 / BrainIAC learned feature +0.389. 학습 표현이 morphometry와 같은 방향으로 얽힌다 (출처: experiments/separability_diagnostic/reports/final_diagnostic.md).
- **per-pair spectrum이 population 구조를 복원한다**: same-population 쌍은 분리(ADNI–NACC +0.132, AJU–KDRC +0.294), cross-population(美vs韓) 쌍은 얽힘(ADNI–AJU +0.575, OASIS–KDRC +0.593) = "site == population" 정량 입증 (출처: experiments/separability_diagnostic/reports/final_diagnostic.md).
- **BrainIAC frozen은 morphometry보다 열세**: site-probe 0.842(morpho 0.770, BrainIAC가 *더* site-loaded) / brain-age MAE 5.73yr(morpho 5.56) / CN/AD AUC 0.735(morpho 0.911). few-shot 전 구간 morphometry 우세 (출처: docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).
- **full fine-tuning ≫ frozen-probe**: brain-age MAE(KDRC) frozen 6.36±.02 / scratch 5.79±.07 / full 5.35±.04. frozen audit이 foundation 가치를 과소평가했음을 반증 (출처: SPEC.md).
- **pretraining이 age-독립 site 정보를 주입한다**: from-scratch가 항상 site 최저(~0.71) vs full(~0.76), age 잔차화 후에도 불변. transfer↔site-invariance tradeoff (출처: SPEC.md).
- **site는 ranking(AUC)에는 benign**: LOCO oracle−LOCO AUC gap 평균 +0.024로 작음 (출처: experiments/20260613_scanner_pop_decomp/reports/E4_shift_decomposition.md).

### 🟡 잠정 (효과 약함 / 검정력 한계)
- **foundation 가치(full ≥ scratch)는 brain-age에서 modest하게 확인**: KDRC brain-age full−scratch −0.44(robust), AJU −0.23(robust, 3-seed 확인). CN/AD는 3seed에서 full .800±.017 > scratch .779±.034이나 scratch 분산(0.034)이 효과 크기(0.021)를 넘어 유의성 미입증 (출처: SPEC.md).
- **separability diagnostic의 외부 calibration 미완**: within-population scanner가 분리 가능 regime의 ground truth를 대신했으나, ON-Harmony/SRPBS traveling-subject 외부 검증(DUA 필요)이 남은 강화 단계 (출처: experiments/separability_diagnostic/STUDY_PROTOCOL_E.md, PAPER_PLAN.md).

### ❌ 반증 (기각)
- **scanner/population decomposition 방향 전체**: E1에서 align(PRE)→ComBat deflation(POST) Spearman rho=+0.90으로 겉보기 강했으나, disease-imbalance confound를 통제한 E2(disease-matched)에서 rho가 +0.90→−0.20(AJU 제외 −0.14, p=0.79)로 붕괴. cross-ancestry deflation도 +0.05→−0.001로 same-population과 동일해짐. 겉보기 cohort-disease 얽힘과 ComBat deflation은 전부 disease-prevalence 불균형 탓이지 scanner/ancestry 탓이 아니었다 (출처: experiments/20260613_scanner_pop_decomp/reports/E1_combat_deflation.md, E2_disease_matched.md, SUMMARY.md).
- **GRL site-adversarial mitigation**: full-FT + GRL(λ 0.3, 1.0)에서 site 변화 ~0.02·비단조·task 불일치 = 무효. site 제거 경로가 닫힘 (출처: SPEC.md).
- **label-shift(Saerens EM) 재프레이밍**: label-shift가 ComBat을 깨끗이 못 이김(ΔBA −0.024). "site benign, prior-shift가 deployment 손실 주범" 가설은 E4 T3(corr=−0.18)에서 미지지 (출처: experiments/20260613_scanner_pop_decomp/reports/E3_labelshift_vs_combat.md, E4_shift_decomposition.md).

## 폐기·전환된 시도
이 워크스페이스는 폐기된 방향의 측정값을 closure 문서로 보존하는 규율이 강하다. 시간순:

- **3D CN/AD representation (2026-06-07 종료)**: ROI intensity/tissue feature, residualized feature, 3D encoder smoke. intensity-only LOCO 0.8825 < morphometry 0.9072, scanner shortcut AUC 0.9529로 매우 강함. residualization은 scanner를 0.586까지 낮춰도 disease gain ≈ +0.0004. "MRI를 더 본다고 representation이 좋아지지 않는다"로 종결 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).
- **De-confounding 탐색 (2026-06-11 종료)**: Direction A(PET-privileged distill) — PET SUVR도 cohort-AUC 0.829, amyloid-음성 stratum 0.855로 tracer/scanner 교란이 drove함. Direction B(GRL de-siting) — cohort ~0.84 floor에서 안 줄고 LOCO dementia Δ≈0. 임상 라벨 헤드룸 없음으로 종결 (출처: docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md).
- **Foundation/SSL/harmonization/longitudinal 탐색 (2026-06-11 종료)**: BrainIAC reality-check + harmonization "deflate-not-unmask" audit + longitudinal 라벨 부재. 네 출구 모두 데이터로 막힘. "AD/aging을 구조 T1w로 푸는 질문 자체가 이미 풀린 문제"로 종결 (출처: docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md).
- **FOMO300K scratch SSL (계획 단계에서 보류)**: FOMO25 주최측이 "model/data scaling은 reliable benefit 없음"이라 직접 결론지어, "더 큰 데이터·모델" 축은 외부에서 이미 죽어가는 축으로 판단. 의사결정 게이트(공개 biology-guided 체크포인트가 morphometry 0.91 바를 넘는 기미(≥0.88)가 있는가)를 통과해야만 GPU 투입하기로 보류 (출처: docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md).

전환의 메타 패턴: **target을 바꿔야 한다**는 결론. 임상 라벨 축은 소진됐고(morphometry ceiling), 살아있는 축은 "harmonize 전 분리 가능성 측정"(diagnostic) 또는 generative/counterfactual 같은 미시도 패러다임이다 (출처: experiments/RETROSPECTIVE.md).

## 남은 과제·다음 단계
separability diagnostic을 mid-venue 논문으로 마감하는 것이 가장 구체적인 경로다 (출처: experiments/separability_diagnostic/PAPER_PLAN.md).

- **P1.1** 21-pair 전체 매트릭스 + population-distance 상관 → "alignment ∝ population distance" 정량 법칙(헤드라인 figure).
- **P1.2** 실제 ComBat 적용 후 high-alignment 쌍이 더 많은 disease-AUC를 잃는지 확인(diagnostic이 실제 deflation을 예측함을 증명).
- **P1.3** bootstrap 95% CI·permutation null·Holm 보정·k-ablation (현재 미비, desk-reject 리스크).
- **P2** 외부 traveling-subject(ON-Harmony/SRPBS) calibration — DUA/로그인 필요, gold-standard 검증.

정직한 한계(문서 자체 기록): diagnostic 코어 자체는 "harmonization can hurt"라는 known observation에 가깝고, novelty는 population-distance 법칙(P1.1)과 ComBat-link(P1.2)의 새로움에 달려 있다. P1.1–P1.2가 깨끗하면 full submission, 노이즈가 크면 venue 재조정 (출처: experiments/separability_diagnostic/PAPER_PLAN.md).

[근거부족] 워크스페이스에 P1.1 이후 단계가 실제로 착수됐는지(21-pair 매트릭스 산출물, ComBat-link 코드/결과)는 현재 파일 목록에서 확인되지 않는다.

## 출처 맵
- `README.md` — 리셋 워크스페이스 원칙, 유지 파일 목록, 데이터 안전
- `AGENTS.md` — 가드레일, VLM이 기본 방향 아님 명시, 작업 전 정의 템플릿
- `SPEC.md` — living spec: foundation adaptation ladder 실험 로그(D2-S0~S4), scanner/pop decomposition 기각, diagnostic E 요약
- `experiments/RETROSPECTIVE.md` — 측정된 하드 사실 F-A~F-G, 인사이트 I-1~I-5, 후보 방향
- `experiments/PROPOSAL_technical.md` — scanner/pop decomposition 제안 + G1 lit-check
- `experiments/separability_diagnostic/STUDY_PROTOCOL_E.md` — diagnostic 프로토콜·결과·외부 calibration 계획
- `experiments/separability_diagnostic/PAPER_PLAN.md` — DONE/REMAINING 3 phase 로드맵, 리스크
- `experiments/separability_diagnostic/reports/final_diagnostic.md` — excess-alignment 최종 수치(calibration/application/per-pair)
- `experiments/separability_diagnostic/reports/v0_diagnostic.md`, `improved_metric.md` — naive 메트릭 실패 → excess-alignment 교체
- `experiments/20260613_scanner_pop_decomp/reports/{SUMMARY,E1_combat_deflation,E2_disease_matched,E3_labelshift_vs_combat,E4_shift_decomposition}.md` — decomposition 기각 증거 체인
- `docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md` — 3D representation 실패 정리
- `docs/context/FAILED_DECONFOUNDING_EXPLORATION_CLOSURE_20260611_KO.md` — de-confounding A/B 폐기
- `docs/context/FAILED_FOUNDATION_AUDIT_CLOSURE_20260611_KO.md` — BrainIAC/SSL/harmonization/longitudinal 4출구 폐기
- `docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md` — FOMO300K SSL 계획·보류 게이트
- `docs/context/CLINICAL_TEXT_COMMON_FEATURES_20260608_KO.md` — 임상 텍스트 feature 인벤토리, manifest under-join 검증

---
> 자동 생성: LLM 에이전트가 `minyoung4` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-13.
