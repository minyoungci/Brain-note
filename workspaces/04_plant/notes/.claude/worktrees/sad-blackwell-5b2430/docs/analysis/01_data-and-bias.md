# 7-코호트 bias audit + bias-robust 학습/평가 설계

> 2026-06-20. `notebook/01_class_and_site_confound.ipynb`(라이브 측정) + 4-lens 설계 패널(평가·입력·bracket·측정게이트)
> 의 적대검증(R1–R4 재진입 점검) 종합. **핵심 프레임: bias는 *제거*가 아니라 *비결정화*한다**(제거는 4-라인 불가 증명).

---

## 0. 한 문장

site는 구조만으로 2.6×chance 식별되지만(AJU 0.905) **site를 통제하면 disease는 여전히 분리된다**
(within-site morph→impaired 평균 0.775) → bias를 제거할 필요 없이, **입력 cordon + nested-LOCO + 음성통제 +
per-cohort 게이트**로 site가 *점수에 도달하는 산술 경로를 차단*하면 신호는 살아남는다. 단 NB05가 *공짜 임상정보
위* imaging 여유를 미검출했으므로 **가장 현실적 1차 결과는 음성(ceiling benchmark)** 이고, 그것도 정당한 산출물이다.

## 1. per-cohort bias audit (QC-pass 12,978, 라이브)

| 코호트 | n | CN/MCI/AD% | morph→site AUC | within-site disease | 결측·구조 함정 |
|---|---|---|---|---|---|
| AJU | 1287 | 2.3/80/18 | **0.905** | 0.739 | CN 거의 없음, native aniso 3.20, field 17% 결측 |
| KDRC | 908 | 31/51/18 | 0.813 | 0.839 | **field 100% 결측**, cross-sectional, age 15% 결측 |
| A4 | 1772 | 69/29/2 | 0.759 | 0.717 | preclinical(AD 2%), APOE-e4 61% enriched |
| AIBL | 987 | 70/22/8 | 0.734 | 0.832 | **APOE 전무**, 단일 스캐너 |
| OASIS | 1420 | 80/15/6 | 0.685 | 0.843 | **라벨 71% 미매칭**(clin_match 29%) |
| ADNI | 4739 | 53/41/6 | 0.672 | 0.698 | 가장 균형, 유일 종단(changers 339) |
| NACC | 1865 | 64/29/7 | 0.665 | 0.760 | MMSE 84% 결측, 내부 multi-site |

전역: morph→7class site **balanced-acc 0.371**(chance 0.143 · 2.6×) · site×impaired **Cramér's V 0.421**.

## 2. bias-robust 설계 프로토콜

### 2a. 평가 (bias가 신호로 위장 못 하게 막는 곳)
- **LOCO를 유일 headline split** (leave-one-cohort-out 7-fold). within-cohort split은 진단 diagnostic으로만(누수 취약 천장).
- **표현-수준 nested-LOCO**: fold k에서 SSL/인코더 사전학습과 probe 적합 *둘 다* 코호트 k 제외(2026-06-11 frozen-encoder-LOCO-probe 누수=철회된 0.662 방지).
- **validation-lock**: 체크포인트·HP 선택은 train-코호트 inner-val(subject-level)로만. held-out 점수가 모델선택에 닿으면 무효.
- **subject-level split + dup_group collapse** 전역.
- **음성통제 배터리**(양성 해석 *전*, 각 chance 임계): label-shuffle→CI에 0.5, mask-only→chance, intensity-hist-only→chance(appearance→site shortcut 차단), nuisance-only=image가 넘을 floor. (b) 외 control이 chance 초과면 fold 무효.
- **계층적 증분 bar**: DEMO→+BASE(cdrsb)→+MORPH→+IMAGE. **image GO = Δ(image | DEMO+BASE+MORPH) 부트스트랩 95%CI 하한>0.** DEMO 단독 위 비교 금지(NB05: DEMO+BASE 위 morph 증분 전 spec 0 포함).
- **per-cohort 보고 의무**(pooled 평균 headline 금지), **multi-seed≥3**, 등가 주장은 **TOST+CI**(점추정 금지).
- **test-time 적응 inductive만**(K=64 BN 재계산→freeze). C4(AD/CN) 공정성을 prognosis에 상속 금지 → ADNI scanner-LOCO 안에서 재검증.
- **dual-gate decidability**(held-out별): G1=표현의 site분류 near-chance ∧ CDR 보존 / G2=morph+cognition bar 초과 transported CI>0. 한쪽만=실패.

### 2b. 입력 (site가 점수로 가는 경로 차단)
- 입력 = **이미지 텐서(canonical 1mm-RAS z-score brain-masked) + 명시 최소 메타(나이·성별)만.**
- **영구 입력 금지**(전부 site proxy로 정량됨): `field_strength`(KDRC 100% 결측=field≡site), `acq date/session-index`(ADNI만 parseable=site tell), `APOE`(A4 61% vs ADNI 38% 부분 proxy·AIBL 전무), native `aniso`(1.23~3.20=site 지문), site/scanner/consortium/CDR/morph/raw ROI.
- **결측을 입력 indicator로 쓰지 않음**(결측 패턴 자체가 site signal): mean-impute+indicator 금지, stratify-aside.
- **입력 후보 메타는 guard 통과 필수**: probe meta→cohort bal-acc > 1/K면 입력서 거부.
- **morph-distilled 표현을 'beyond morph' 검정에 금지**(T2 순환): morph-pretrain은 init으로만 + 반드시 task fine-tune.

### 2c. bias-handling
- **제거 아니라 비결정화**: 입력 cordon + nested-LOCO + 음성통제 + per-cohort gate. global GRL/ComBat/MixStyle/N4 **영구 금지**(측정으로 dead).
- **정량·특성화하되 안 지움**: morph→site AUC를 published bias-severity 축으로 보고, 전 결과를 그 축으로 stratify(고분리 코호트서도 생존하는 주장만 신뢰).
- **1차 방어 = 단일 코호트 bracket**(site가 fold 내 상수 → shortcut gradient 0).
- **over-correction guard**: 어떤 정규화도 전 코호트 동시평가, 단일 코호트라도 회귀하면 NO-GO. 기본값=아무것도 적용 안 함.
- **잔차화는 fix가 아니라 audit**: 코호트별 site-nuisance 회귀 후 disease AUC 재측정(spec 민감도 포함, 단일 수치 금지 — 0.722는 A4-specific).

## 3. per-cohort 결정 (각 코호트를 어떻게 쓰나)

| 코호트 | 결정 | 근거 |
|---|---|---|
| **ADNI** | **PRIMARY 학습+평가**(단일 bracket), 내부 scanner-LOCO | 최저 morph→site 0.672·가장 균형·유일 종단. R1·R3·R4 동시 최약 |
| **NACC** | **audit-only** transport probe(정확도/GO 수치 금지) | cross-site accuracy=R1 grave 재진입. 내부 multi-site는 site-id 있으면 LOCO canary |
| **AJU** | **HARD 격리**(headline 제외), bias-severity anchor·transport-IN 타깃만 | CN 2.3%(within CN-vs-imp 불가)·0.905·aniso 3.20. pooling=site=label 외움 |
| **KDRC** | **audit-only**, field 입력 영구제외 | field 100% 결측=완벽 indicator. K→W 비가역(P4 확정). cross-sectional |
| **A4** | clean-vendor invariance **source** + 음성통제 reservoir(AD task 제외) | vendor⊥diagnosis(V=0.00) 유일급. AD ~2%라 진단 degenerate |
| **AIBL** | 보조 transport fold(APOE-arm·scanner-LOCO 제외, gap 보고) | APOE 전무·단일 스캐너 → 특정 비교 금지(정직한 scoping) |
| **OASIS** | **label-free SSL/BN pool만**(dedup 선검증 후), supervised 제외 | 라벨 71% 미매칭=supervised 무신뢰. CN-heavy·저 site는 SSL엔 안전 |

## 4. decision gates (학습 전, 숫자)

- **GATE-3 [최우선·R2 천장] `image→fs_vol R²` structure-wise + CI** (canonical 1mm, ADNI). pooled>0.9 금지(T5: cortical R² 이미 음수/0.23). **사전등록**: AD-관련 cortical ROI(entorhinal·precuneus·PCC) R² 하한>임계 → morph=image proxy → 천장 확정 → **benchmark 직행**. cortical 낮음 → micro-signal 여지 → **bounded imaging 정당화**. **0.6~0.85 ambiguous band 행동을 측정 전 등록**(post-hoc 차단). 1mm 해상도 추격은 NO-GO.
- **GATE-4 [의사결정]**: imaging이 **DEMO+BASE+MORPH** bar를 부트스트랩 95%CI 하한>0으로 초과해야 GO. + **MDE/TOST 등가한계 사전등록**(N=849 회귀·N=348 survival C-index가 그럴듯한 증분 검출 검정력 있나). 검정력 부족 null=‘천장’ 아닌 ‘검정력-미결정’.
- **GATE-2 [decidability]**: 코호트별 site 잔차화 후 disease AUC CI하한>0.5(multi-seed)면 DECIDABLE. 코호트별 재측정(0.722는 A4-specific).
- **GATE-0/1 [자동제외]**: morph→site>~0.85 또는 CN-vs-imp 계산불가면 pooled 신호서 자동제외(AJU·OASIS trip).
- **kill**: 같은 arm 3회 NO-GO→폐기·상위복귀. imaging이 bar 못 넘으면 폐기·음성 ledger. **null은 사전등록 1차 산출물.**

## 5. 현재 분석 정직 평가

**강점:** 데이터 전수 무결성 검증(NB02) · confound를 제거 아닌 *정량*으로 닫음(NB01/03/06) · 계층적 baseline bar를 CI까지(NB05) · **research-critic 정정을 실제 반영**(자기평가 편향을 독립비평으로 깸) · 검정력 지형 사전 측정(NB04).

**공백(다음 측정 우선순위):**
1. **[최우선] `image→fs_vol R²` 미측정** — 전 프로그램을 6.1 vs 6.2로 분기하는 단 하나의 게이트(GATE-3). CPU/소.
2. 표현-수준 site-separability 미측정(잔여 aniso→site·intensity-hist→site·metadata→site·mask→site audit).
3. 코호트별 잔차화 disease AUC 미확립(A4 단일 0.722뿐).
4. ADNI clean same-scanner **paired-MRI 가용 N** 미측정(longitudinal-pair=R2 원리적 우회 유일 후보).
5. GATE-4 검정력(MDE)/TOST 미사전등록 → imaging null의 ‘천장 vs 검정력부족’ 구별 불가.
6. manifest 메타(NACC site-id, OASIS dedup) 가용성 미확인.

## 6. 정직한 caveat (낙관 금지)

- **가장 현실적 1차 결과는 음성**: NB05가 DEMO+BASE 위 morph 증분을 전 spec 0 포함으로 측정. image가 그 위를 넘는 근거는 검정 전부터 약함. ceiling benchmark로 frame(가치는 venue/novelty 베팅, Bron2021 최대 위협).
- **ADNI 진행 검정력 한계**: sustained 전환 83(24/36/48mo=26/40/50) ≪ 문헌 150~400. binary null=‘천장’ 아닌 검정력부족 가능 → survival(N=348)+TOST로만 구별. `last_cdrsb`는 baseline과 autoregressive라 증분 구조적 ~0 → **GO 타깃서 제외, descriptive-only**.
- **R² 게이트가 ambiguous band(0.6~0.85)에 떨어질 가능성 높음**(cortical R² 이미 낮음) → 단일 분기점이 분기 못 하면 post-hoc 합리화 위험 → 임계·행동 사전등록 필수.
- **G1(site→chance)은 단일 probe로 undecidable**(biology-preserved vs erased 구별 불가) → 비순환 보조 probe로 완화하나 잔여 모호성 명시.
- **음성통제는 *설계된* 누수만 잡음**: interpolation-edge가 site와 상관되면 다 통과 가능 → 잔여 audit으로 줄이되 제거 못 함.
- **단일 bracket = 누수안전 ↔ 외적타당성 trade**: within-ADNI는 transport 입증 못 함. NACC가 유일 정직한 transport check지만 작고 MMSE-불구.
- **cross-pop transport(Korean)는 측정 비등가로 교란**(MMSE 매칭 후도 AD Δ+4.7) → population-biology 아닌 **equity/transport finding**으로 frame.

> 참조: `notebook/01_class_and_site_confound.ipynb`(audit) · `02_ceiling-and-baselines.md`(R1–R4·baseline bar·닫힘 ledger) · `03_novelty-and-direction.md`(방향) · `../../insight/failure_root_causes.md` · `../../RESEARCH_BRIEF.md`.
