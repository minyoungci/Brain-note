# P0 — Bias Audit Plan (microbrain)

> **상태:** 설계안(코드 아님). Min 승인 전 학습·대형 추출·GPU 금지. 작성 2026-06-11.
> **단일 진실:** `RESEARCH_BRIEF.md`. 운영규칙: `CLAUDE.md`. 권위 증거: minyoungi `SCANNER_BIAS_PLAYBOOK.md`.
> **이 문서가 답할 질문:** 표현학습 부진이 **(a) site/scanner bias 오염**인가 **(b) 부피 너머 미세신호의 천장**인가를
> *학습 전에* 분리·판정할 근거를 깐다. P0는 "적을 측량"하는 audit이며, 표현학습(P2)으로 가도 되는지/어떻게 갈지를 결정한다.

---

## 0. 불변 가드레일 (이 문서 전체에 적용)

- **입력 누수 금지(audit 한정 예외):** site/scanner/CDR는 **예측 타깃(audit target)** 으로만 쓴다. feature는 이미지에서 유도한 값(voxel 통계) 또는 morphometry(fs_vol_*)이며, 이들은 P2 모델 입력이 아니라 *audit 입력*이다. 표현학습 단계로 넘어가면 morphometry·scanner·CDR는 다시 target/stratify/audit 전용으로 되돌린다.
- **평가 규율:** subject-level disjoint split. classifier 하이퍼파라미터를 held-out으로 선택하지 않는다(validation-lock). 단순 고정 모델(default Logistic + default RF/GBM)만 써서 in-dist selection 함정을 원천 차단. **multi-seed ≥5**(minyoung2 W1: 3→5 seed에서 결론 뒤집힌 전례). 모든 수치는 mean±sd + bootstrap CI.
- **데이터 read-only:** `/home/vlm/data` 쓰기 금지. 산출물은 `results/P0/`·`data/derived/P0/`(plant 내부)만.
- **bf16/fp16 무관:** P0는 전부 CPU·tabular. GPU 없음. (단 A2/A3의 텐서 전수 1-pass는 I/O 비용 → §4 게이트.)
- **자기평가 금지:** 각 측정은 사전 등록된 숫자 판정기준으로만 PASS/FAIL. "좋아 보인다" 금지.

## 0.1 사전 측정으로 이미 확인된 사실 (이 설계의 근거 — raw manifest 직접 inspect)

- **site×diagnosis confound가 심각하다.** impaired rate(CDR≥0.5) per cohort: OASIS 20.2% · AIBL 30.4% · A4 31.3% · NACC 36.0% · ADNI 47.0% · KDRC 69.2% · **AJU 97.7%**. → **site가 사실상 diagnosis의 proxy.** 이것이 (a)/(b) 판정을 오염시키는 1차 위협이고, A0/A4가 정조준한다.
- **bias 축은 거의 `consortium` 하나.** `acq_scanner`는 대부분 vendor 수준(GE/PHILIPS/SIEMENS)이고 AIBL·OASIS는 SIEMENS 단일(vendor=site 공선). `acq_field_strength`는 대부분 3T, KDRC 전무(909/909 NaN). → fine-grained scanner 통제 불가, **site(7-way) + vendor(3-way, multi-vendor 코호트만)** 가 현실적 audit 타깃.
- **데이터 실재 확인:** voxelwise_qc_candidate=True 12,978/13,022. 텐서·N4텐서·마스크 7코호트 전수 디스크 존재(stat 확인). CPU 스택(sklearn 1.8 / scipy 1.15 / nibabel 5.4) 가용. I/O 재사용: `/home/vlm/minyoungi/Clinical/common/{mri_io,roi_tools}.py`.

---

## 1. 측정 항목 개요

| ID | 측정 | 입력(feature) | 타깃 | compute | 게이트 |
|---|---|---|---|---|---|
| **A0** | site×diagnosis confound 정량 | metadata only | — | CPU·즉시 | 불필요 |
| **A1** | morphometry → site/scanner 예측강도 | fs_vol_* (26 ROI + 전역) | consortium, vendor | CPU·소형 | 불필요 |
| **A2** | raw-voxel → site/scanner 예측강도 + **N4 vs base** | 텐서 intensity 통계·저해상 voxel | consortium, vendor | **텐서 1-pass(I/O)** | §4 (smoke→full) |
| **A3** | **누수 region 지도(bias atlas)** | 저해상 voxel(A2 재사용) | per-voxel site η² | CPU(A2 산출 재사용) | §4 동반 |
| **A4** | **decidability probe**: site 제거가 disease를 지우나 | A1/A2 feature | CDR(잔차) | CPU·소형 | 불필요 |
| **A5** | morphometry → CDR **정직한 LOCO baseline**(=bar) | fs_vol_* + 공변량 | cdr_global(이진) | CPU·소형 | 불필요 (P1과 공유) |

A0·A1·A4·A5는 **승인 없이 즉시 가능**(tabular). A2·A3만 텐서 전수 1-pass가 필요 → §4 게이트(먼저 350-subj smoke).

---

## 2. 공통 인프라 (설계만)

### 2.1 Split / 평가 스킴
- **site 예측(A1·A2):** site/scanner 타깃 자체는 LOCO 불가(held-out site는 train에 라벨이 없음). → **subject-disjoint stratified K-fold(K=5)** 로 "site가 디코드 가능한가"를 in-distribution으로 측정. 이건 audit 목적상 올바르다(우리는 "site가 새는가"를 묻는다). LOCO는 *downstream disease* 평가(A5·P1·P2)에만 적용.
- **disease 예측(A4·A5):** **subject-level LOCO**(leave-one-consortium-out). held-out 코호트의 base-rate를 항상 함께 보고(0.1.0의 20~98% 때문에 AUROC만으로 판단 금지 → AUROC + balanced-acc + prevalence baseline 동시).
- 모든 classifier: default Logistic(L2) + default RandomForest. 하이퍼파라미터 튜닝 없음(validation-lock). seed ≥5.

### 2.2 Feature 정의 (leakage-safe, 이미지에서만 유도)
- **morphometry(A1·A4·A5):** `fs_vol_*` 26 ROI + 전역(fs_BrainSegVol 등). 정규화 2종: **ICV(÷fs_MaskVol)** 와 **train-z**(train 통계로 z, test에 적용). minyoung2 W3 경고(voxel_count site effect) 때문에 ICV 정규화를 1차로.
- **voxel intensity(A2·A3):** 텐서는 이미 per-subject z-score → site 신호는 (i) **brain-mask 내 intensity 히스토그램 모양**(64 bins), (ii) **저해상 voxel 패턴**(8mm 다운샘플 ≈ 24×28×24, mask 적용 후 flatten), (iii) **간단 texture**(gradient magnitude의 mean/var/skew). 이 3종이 minyoungi "appearance probe"(playbook 0.556)의 재현·확장. base 텐서와 N4 텐서 **각각** 추출.

### 2.3 산출물 디렉토리
```
results/P0/
  A0_confound/        confound_table.csv, fig_cdr_by_site.png, decidability_summary.md
  A1_morph_site/      site_pred_morphometry.csv (bAcc, confusion, per-class recall, seeds)
  A2_voxel_site/      site_pred_voxel_base_vs_n4.csv, smoke_report.md
  A3_bias_atlas/      bias_atlas_eta2_base.nii.gz, bias_atlas_eta2_n4.nii.gz, region_table.csv
  A4_decidability/    residual_disease_report.md, shared_variance.csv
  A5_morph_cdr_bar/   morph_cdr_loco.csv (per-cohort AUROC/bAcc + bootstrap CI)
data/derived/P0/
  features/           morph_features.parquet, voxel_features_{base,n4}.parquet (A2 산출)
P0_AUDIT_REPORT.md    # 종합 판정 + (a)/(b)/undecidable 분기 결론
```

---

## 3. 각 측정 상세 (방법 · 산출물 · 판정기준 · NO-GO)

### A0 — site × diagnosis confound 정량 [CPU·즉시·게이트 불필요]
- **질문:** site를 알면 diagnosis가 얼마나 결정되나? (a)/(b)를 가르기 전에 *가를 수 있는 regime인지*를 먼저 본다.
- **방법:** (1) Cramér's V(consortium, cdr_global) 및 (consortium, clin_dx_label). (2) normalized mutual information. (3) "site one-hot만으로 CDR≥0.5 예측" balanced-acc(= base-rate를 외우는 상한). (4) per-site prevalence 표(이미 측정).
- **산출물:** `confound_table.csv` + `fig_cdr_by_site.png`.
- **판정기준(숫자):**
  - Cramér's V > 0.3 → **강한 confound**: "site 제거 = disease 제거" 위험 → P1/P2 평가를 **base-rate-matched 또는 within-site** 로 설계 의무화(이 결과가 설계 입력).
  - 0.1 ≤ V ≤ 0.3 → 중간: LOCO + prevalence baseline 병기로 충분.
  - V < 0.1 → 약함: 표준 LOCO 해석 OK.
- **NO-GO/분기:** confound가 강하면(예상) → A4가 decidability를 결정. A4까지 보고 P2 평가 설계 확정.

### A1 — morphometry → site/scanner 예측강도 [CPU·소형·게이트 불필요]
- **질문:** morphometry가 site-robust한가, 아니면 부피 자체가 site를 진다(인구 head-size·위축 패턴 차이)?
- **방법:** fs_vol_*(ICV-norm, train-z 2종) → consortium(7-way) + vendor(3-way, multi-vendor 코호트 한정). default Logistic + RF. subject-disjoint 5-fold × 5 seed.
- **산출물:** `site_pred_morphometry.csv`(balanced-acc mean±sd, confusion matrix, per-class recall).
- **판정기준:** chance(7-way)=0.143, chance(3-way)=0.333. morphometry site bAcc를 **G1의 비교 바닥**으로 기록. playbook은 morphometry가 *일반화 비용 ~0*이라 보고하나, *site 디코드 가능성* 자체는 별개 → 우리가 숫자로 확정.
- **NO-GO:** 없음(scaffolding). 단 5 seed에서 sd>0.05면 seed 추가.

### A2 — raw-voxel → site/scanner 예측강도 + N4 vs base [텐서 1-pass·§4 게이트]
- **질문:** 이미지에서 site/scanner가 얼마나 디코드되나, **N4가 그것을 줄이나**?
- **방법:** §2.2 voxel feature(히스토그램+저해상+texture)를 **base·N4 각각** 추출 → consortium/vendor 예측. default Logistic + RF, 5-fold × 5 seed. base와 N4의 bAcc 차이가 "N4 효과" 산출물.
- **산출물:** `site_pred_voxel_base_vs_n4.csv` + `data/derived/P0/features/voxel_features_{base,n4}.parquet`.
- **판정기준(숫자):**
  - voxel site bAcc ≫ chance(예: >0.40, 7-way) → **이미지에 site가 강하게 산다** → P2 bias-removal 의미 있음.
  - base→N4 bAcc 감소 > 0.05 → N4가 의미 있게 site를 줄임. (playbook 선례 0.556→0.517 = −0.04 = *유의미하지 않음* → 우리 코호트 전수로 재확인.)
- **NO-GO/분기(BRIEF 명시):** **N4 voxel site bAcc ≤ chance+0.10**(7-way ≤0.24) **이고** A1 morphometry도 site-robust → "bias가 이미 거의 없음" → **즉시 (b) 천장 질문으로 피벗**, P2 bias-removal arm 폐기. (가능성 낮으나 사전등록.)
- **compute:** 12,978 × 2(base+N4) 텐서 read = I/O 무거움. **먼저 350-subj smoke(50/코호트)** 로 파이프라인·예상 시간·RAM 검증 → 그 보고 후 Min이 full-pass 승인. RAM 1TB 상한 준수(스트리밍, 한 번에 1 볼륨, app-level 캡, /sysmon 확인).

### A3 — 누수 region 지도 (bias atlas) [A2 산출 재사용·CPU]
- **질문:** site 신호가 뇌의 *어디*에 사는가 → P2 invariance를 어디에 걸지 + 천장 해석(P4).
- **방법:** A2의 저해상 마스크 텐서(8mm 격자)로 **per-voxel one-way ANOVA η²**(intensity ~ 7 site) 벡터화 1-pass → 3D η² map. base·N4 각각. 고-η² 영역이 disease ROI(hippocampus/ventricle/entorhinal)와 겹치는지 overlap 정량(공간적 confound 체크).
- **산출물:** `bias_atlas_eta2_{base,n4}.nii.gz`(저해상, 표시용 resample) + `region_table.csv`(top 영역, η², disease-ROI overlap).
- **판정기준:** 서술적(hard pass/fail 없음). 정량 보고: η²>0.1 voxel 비율, disease-ROI overlap 분율. N4 전후 η² 감소 지도.
- **한계 명시[VERIFY]:** η²(univariate)는 multivariate decodability와 다르다 → A2의 multivariate bAcc와 함께 해석. 8mm 다운샘플은 미세 texture를 놓침(보수적 하한).
- **NO-GO:** 없음(지도 작성). A2가 게이트로 막히면 A3도 대기.

### A4 — decidability probe: site 제거가 disease를 지우나 [CPU·소형·게이트 불필요] ★핵심
- **질문:** site-예측 방향과 disease-예측 방향이 얼마나 겹치나 → **G1(site 제거)∧G2(disease 보존) 동시 달성이 가능한 regime인가.** 이게 임무의 (a)/(b) 판정 직결.
- **방법:**
  1. **by-product 누수:** morphometry/voxel로 site-classifier 학습 → 그 site-logit이 CDR을 얼마나 예측하나(site가 disease를 얼마나 운반하나).
  2. **site-residualization:** feature를 per-site z로 잔차화(site 1차 제거) → 잔차로 CDR LOCO 예측. minyoung4 교훈("morphometry residualize → embedding chance")을 *audit으로* 재현: 잔차 disease 신호가 살아남나 무너지나.
  3. **within-site vs pooled:** within-site CDR-AUC와 pooled CDR-AUC 차이로 site-mediated 분율 추정.
- **산출물:** `residual_disease_report.md`, `shared_variance.csv`.
- **판정기준(숫자):**
  - site-residualization 후 CDR LOCO AUROC가 **near-chance(≤0.55)로 붕괴** → **undecidable regime 확정**(site==population, minyoungi novelty와 일치): single-probe로 (a)/(b) 분리 불가 → P2는 base-rate-matched eval로만 의미. 정직한 cautionary 결과 경로.
  - 잔차 disease AUROC가 **유의하게 chance 초과(CI 하한>0.55)** → site와 분리 가능한 disease 신호 존재 → (a)/(b) 분리 가능 → P2 bias-removal이 잠재적 가치.
- **NO-GO:** 없음(판정 산출물). 이 결과가 P2 진입 가부와 평가 설계를 결정.

### A5 — morphometry → CDR 정직한 LOCO baseline (= 넘어야 할 bar) [CPU·소형·P1과 공유]
- **질문:** morphometry가 CDR을 LOCO에서 실제로 얼마나 예측하나(within-cohort 0.9x는 누수판). 이게 P2가 넘어야 할 **G2 바**.
- **방법:** fs_vol_*(ICV-norm) + 공변량(age·sex; 결측 큰 코호트 주의) → cdr_global 이진(CDR≥0.5) **LOCO**(held = 각 코호트). default Logistic + RF, 5 seed, per-cohort AUROC + balanced-acc + **prevalence baseline** + bootstrap CI(cohort-cluster). minyoung2 B2/B3 교훈: pooled bootstrap exchangeability 위반 → cohort를 random effect로 두는 보고도 병기[VERIFY].
- **산출물:** `morph_cdr_loco.csv`(per-cohort AUROC/bAcc/CI/prevalence).
- **판정기준:** 숫자 바 고정(예: held-cohort AUROC 분포). 이 값이 P2 G2 incremental의 기준선. **null도 결과**: morphometry가 LOCO에서 약하면 그 자체가 (b) 천장의 정량 근거.
- **NO-GO:** 없음(필수 바). split/leakage 단위테스트(subject disjoint, label timestamp) 통과해야 함.
- **경계:** A5는 BRIEF의 **P1**과 겹친다. P0에는 *morphometry site-robustness 판정에 필요한 최소판*만 두고, 완전한 baseline ladder(raw-voxel PCA·intensity 통계 trivial baseline)는 P1에서 확장.

---

## 4. Compute 예산 & 승인 게이트

| 항목 | 비용 | 승인 |
|---|---|---|
| A0·A1·A4·A5 | tabular CPU, 분~십수분 | **불필요 — 즉시 착수 가능** |
| A2·A3 **smoke** (350 subj × 2) | 텐서 700 read, 수 분 | 불필요(소형) |
| A2·A3 **full** (12,978 × 2 = ~26k read) | I/O bound, 수십 분~시간, RAM 스트리밍 | **필요(대형 추출 게이트)** — smoke 보고 후 |

- full-pass 전: `/sysmon` RAM 확인, 스트리밍(1 볼륨/시점), app-level 90% 캡, setsid 분리(minyoung2 W4: SIGHUP 전멸 이력).
- GPU는 P0 전 구간 **불필요**(전부 CPU). P2에서 처음 등장 → 별도 승인.

---

## 5. P0 종합 판정 규칙 → P1/P2 분기 (사전 등록)

A0~A5 종합 후 `P0_AUDIT_REPORT.md`에 아래 셋 중 하나로 판정:

1. **bias 실재 + 분리 가능** (A2 voxel site≫chance, A4 잔차 disease 생존) → **P2 진행**. 단 A3 지도로 invariance 타깃 결정, A0/A4 결과로 base-rate-matched eval 의무. G1 바=A1, G2 바=A5.
2. **bias 거의 없음** (A2 N4 site≈chance, A1 robust) → **(b) 천장 확정 경로**. P2 bias-removal 폐기, 미세신호 천장 분석으로 피벗. (BRIEF P0 NO-GO 분기.)
3. **undecidable** (A0 confound 강 + A4 잔차 붕괴) → site==population regime. P2를 within-site/base-rate-matched로만 진행하거나, **정직한 cautionary 결과**(minyoungi 명제 재확인)로 정리. 어느 쪽이든 publishable.

> 어떤 경로든 **morphometry 바(A5) 동시 비교**와 **두 게이트(G1∧G2) 동시 판정** 원칙은 불변. 한쪽만 통과는 실패.

---

## 6. 미결 결정 (Min 승인/판단 필요)

1. **A2/A3 full-pass 승인** — smoke 보고 후 12,978×2 텐서 추출을 돌릴지(대형 추출 게이트).
2. **vendor 타깃 범위** — vendor 3-way를 multi-vendor 코호트(A4/ADNI/AJU/NACC)로 한정할지, KDRC 모델-수준 라벨을 별도로 볼지(KDRC만 scanner-model 존재).
3. **A5 범위** — CDR 이진 cut(≥0.5)으로 갈지, severe(CDR≥1) 희소(831/161/19) 때문에 이진만 둘지. 공변량(age/sex) 결측 코호트 처리(KDRC sex 84.7%, field_strength 전무).
4. **디렉토리/추적** — SCRATCHPAD 미해결 항목(top-level 승격, OBSERVATORY 6번째 등록)은 P0 결과와 무관하게 진행 가능.

---

## 7. 다음 행동 (승인 시)
1. 승인 즉시: A0·A1·A4·A5 착수(CPU, 게이트 불필요) → 1차 수치 보고.
2. 병행: A2·A3 **350-subj smoke** → 파이프라인·시간·RAM 보고 → full-pass 승인 요청.
3. 전부 종합 → `P0_AUDIT_REPORT.md` 판정(§5) → P1/P2 분기 결정.

> **승인 전까지 코드 작성·실행 없음.** 이 문서는 설계 합의용이다.
