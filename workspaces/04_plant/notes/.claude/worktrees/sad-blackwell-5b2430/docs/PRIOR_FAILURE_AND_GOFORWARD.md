# 종합 분석 — 이전 실패의 완전 분석 + 향후 방향 (측정 기반)

> 2026-06-20. 5개 분석 노트북(`notebook/01–05`)의 실행·검증 결과를 하나로 종합.
> 모든 수치는 QC-pass 작업셋(`data/derived/manifest_qc_pass`, 12,978×145)에서 라이브 재계산.
> 원칙: 가정 아닌 측정, 음성도 1차 산출물, 생성과 검증 분리.

---

## 0. TL;DR (한 문단)

4개 라인이 막힌 이유는 "방법이 약해서"가 **아니다** — **(R1) 제거 불가능한 site=population 교란**(Cramér's V
0.421)과 **(R2) T1w 구조의 modality 신호 천장**(deep ≈ 단순 부피)이라는 두 *구조적* 벽이다. 둘 다 *task·평가
선택*의 문제이지 아키텍처 문제가 아니므로, **Video Swin/hierarchical transformer는 레버가 아니다.** 살아있는
유일한 방향은 morph-약 regime(ADNI 진행 예측)인데, **baseline bar를 CI까지 측정해보니**(research-critic 반영
개정판) — morphometry는 **구조 prognostic 신호가 실재**(demographics 위 morph 증분 CI>0: 전환 +0.080
[0.010,0.149], 미래 cdrsb ΔR² +0.222 [0.150,0.291])**하지만, 그 신호가 baseline 인지(cdrsb)와 대부분 중복**된다
— *공짜 임상정보(나이·성별·APOE·baseline cdrsb) 위*에선 morph 증분 CI가 **모든 spec에서 0을 포함**(전환
+0.001 [−0.049,0.046], 미래 cdrsb +0.027 [−0.004,0.056]). **결론: 신호는 있으나 임상 baseline 대비 imaging
여유는 미확립.** 따라서 imaging arm GO 전에 **`image→fs_vol R²`(R2 천장 검증)** 가 필수 게이트이고, 그것이
"morph=image의 충실 proxy"를 확인하면 benchmark(6.2), 아니면 bounded imaging 검정(6.1).

---

## 1. 이전 실패의 완전 분석 — 4-사인 (NB01)

4개 형제 라인(minyoung2/4/i + plant)이 **독립적으로 같은 벽**. 근본원인 4개 중 2개는 구조적(불가피),
2개는 자초(통제가능).

| # | 근본 원인 | 성격 | 핵심 증거 |
|---|---|---|---|
| **R1** | site = population 비가역 교란 | 🔴 구조적 | traveling-subject=0 → site 제거=신호 제거. GRL 3회 실패. **site×impaired Cramér's V=0.421**(라이브). |
| **R2** | morphometry 신호 천장 | 🔴 구조적 | deep 2.5D **5/5 LOCO 무승부**. image(BN) 0.910 ≤ morph 0.931. 해상도 2mm→1.5mm **Δ0.000**. |
| **R3** | 평가 누수 (in-dist 거품) | 🟡 자초 | transductive/random-split 누수(0.521→0.471). → subject-level + validation-lock + nested-LOCO 필수. |
| **R4** | 약한/confounded target | 🟡 자초 | amyloid=atrophy-staging confound, concurrent-marker, 검정력 부족(Δ<0.03 동등주장). |

**R1의 미묘한 진실(minyoungi):** confounded regime에서 harmonization은 신호를 *드러내는* 게 아니라 가짜
라벨을 *꺼뜨린다*(CN/MCI raw 0.674 → pooled 0.591 **하락**). → "harmonization으로 향상"은 이 데이터에서
원리적 불가.

**R2의 핵심:** 모델 *용량* 천장이 아니라 **modality 정보량** 천장. 부피는 이미지의 lossy 요약이지만, 실증은
deep ≈ morph. 더 큰 아키텍처로 용량을 키워도 **신호 천장은 안 깨진다.**

**Dead-ends(재시도 금지):** harmonization·N4(−0.006)·global GRL(악화)·image>morph(AD/CN)·해상도 추격·
혈액바이오마커(+0.00)·멀티모달 fusion·amyloid/APOE를 brain으로.
**작동:** morphometry는 site-robust(LOCO 0.936)·인구간 transportable·inductive BN-adapt(+0.06, GRL은 악화).

---

## 2. 데이터 무결성 — 재검증 (NB02)

- base-텐서 **전수 QC**(13,022): load_errors 0 · NaN/Inf **max=0** · z-score **σ=1 전수** · brain-mask 무결 · **0 flagged**.
- 작업셋: canonical 13,022 → **QC-pass 12,978**(drop 44 = `voxelwise_qc_candidate=False` 정확일치: A4 39·ADNI 3·KDRC 1·NACC 1).
- 누수 dup 2쌍(AJU cross-subject) `dup_group` 플래그(미drop, split 시 collapse).
- **판정: 전처리 데이터 자체는 문제 없음.** "데이터가 커서 못 읽는다"는 오해 — 전수 170초에 스트리밍 완료.

---

## 3. 클래스 분포·site 편향 — 실재하나 bracket 대상 (NB03)

코호트별 CN/MCI/AD(%): **AJU CN 2.3% · OASIS CN 79.8% · A4 CN 69.1% · KDRC CN 30.8% · ADNI 52.9%**.
→ 진단이 코호트와 거의 1:1(Cramér's V 0.421). pooled 학습 시 "AJU→MCI"를 외운다(R1).
**해법은 제거(불가 증명됨)가 아니라 단일 코호트 bracket.** cross-site transport를 *주장하지 않으면* confound가 죽이지 않는다.

---

## 4. ADNI 진행 prognosis — feasibility (NB04)

- **라벨 함정:** `clin_dx_label`은 subject별 **정적(baseline)** — 변화 0. 깨끗한 전환라벨(DXCHANGE) **매니페스트에 없음**. 시변 신호는 `cdr_global`(339명 변화)·`cdrsb`(524명)뿐이고 **CDR은 요동**.
- **MCI→AD 전환(cdr 유도, sustained):** baseline MCI & visit≥2 = 348명, 전환 83명(23.9%), median 36.5mo. 시간창별 전환자 = 24mo **26** / 36mo **40** / 48mo **50**. → **검정력 부족**(문헌 converter 150~400).
- **미래 인지저하 회귀(Δcdrsb):** **849 subjects**(10배+), 악화 331·유의악화 157, Δcdrsb mean 0.93±2.39. → 통계적으로 더 강함.

---

## 5. ⭐ Baseline bar — imaging headroom 측정 (NB05 개정판, 핵심)

> research-critic 비평으로 초판의 결함 수정: 계층적 bar(DEMO→+BASE→+MORPH)로 **baseline cdrsb 인공천장
> 분리(M2)**, 회귀 타깃을 `delta`+`last_cdrsb` **둘 다**·base 포함/제외 ablation(F1), 추적기간 span 통제(M3),
> 증분에 **subject 부트스트랩 95%CI**(F2), multi-seed(m1). morphometry(26 ROI, ICV 정규화) Linear(LogReg/Ridge).

**핵심 질문:** morphometry가 *공짜 임상정보(나이·성별·APOE·baseline cdrsb) 위에* 예측 증분을 주는가?

**① 전환 (baseline MCI→sustained AD, N=348, 양성 83), multi-seed AUROC:**
`DEMO 0.647 → +BASE 0.802 → +MORPH(base제외) 0.750 → FULL 0.802`
- Δ(morph **| DEMO+BASE**) = **+0.001  95%CI [−0.049, +0.046]** → 0 포함 (인지 위 증분 미검출)
- Δ(morph | DEMO, base제외) = **+0.080  95%CI [+0.010, +0.149]** → 0 초과 (demographics 위 구조신호 실재)

**② 미래 인지 회귀 (N=849), R² (span 통제):**
| 타깃 | DEMO+SPAN | +BASE+SPAN | FULL(+MORPH) | Δ(morph\|+BASE) 95%CI | Δ(morph\|base제외) 95%CI |
|---|---|---|---|---|---|
| `last_cdrsb`(절대, F1 권장) | 0.065 | **0.482** | 0.512 | +0.027 **[−0.004, +0.056]** | +0.222 [+0.150, +0.291] |
| `delta_cdrsb` | 0.043 | 0.111 | 0.162 | +0.044 **[−0.004, +0.091]** | +0.104 [+0.045, +0.160] |

**정정된 결론(초판 "포화→NO-GO"는 부정확):**
- **구조 prognostic 신호는 실재** — morph가 demographics 위에 올리는 증분 CI는 전 spec에서 0 초과(전환 +0.080, 회귀 +0.222 R²).
- **그러나 그 신호는 baseline 인지(cdrsb)와 대부분 중복** — *공짜 임상정보(DEMO+BASE) 위*에선 morph 증분 CI가 **모든 spec에서 0 포함**.
- ⚠️ **morph 증분 0이 imaging 0을 함의하지 않는다(M1):** morphometry는 사전정의 ROI 부피일 뿐. 이를 닫으려면 `image→fs_vol R²`(prognosis 타깃)로 "morph=image 충실 proxy"를 *확인*해야 한다. (NB05 자동 verdict는 base-제외 spec까지 보고 "GO 조건부"를 띄우나, **의사결정 비교는 DEMO+BASE 위 증분**이고 거기선 미확립.)

---

## 6. 향후 방향 제안 (CI 측정에 근거)

측정이 방향을 좁혔다: **구조신호는 있으나 임상 baseline(DEMO+BASE) 대비 imaging 여유는 미확립.** 따라서
"imaging arm을 바로 켠다"는 근거 부족이고, **GO 전에 R2 천장을 *측정으로* 닫아야** 한다(가정 금지).

### 6.0 (필수 선행, CPU/GPU 소) — R2 천장 게이트
imaging arm GO/NO-GO를 가르는 단 하나의 측정: **`image→fs_vol R²`를 ADNI prognosis 표본에서 측정.**
- image가 morph를 거의 완전 재구성(R²>~0.9) → "morph=image 충실 proxy" 확인 → 5절의 "morph 증분 ≈0"이
  곧 "imaging 증분 ≈0" → **천장 확정 → 6.2(benchmark)로 직행.**
- image가 morph 너머 정보 보유(R²≪1) → imaging이 부피가 못 잡는 micro-signal을 가질 여지 → **6.1 정당화.**

### 6.1 (조건부) bounded imaging arm — DEMO+BASE를 넘는지 1회 검정
- 6.0이 통과(R²≪1)할 때만. **SSL pretrain → ADNI finetune.** 큰 아키텍처(Swin)는 ~850에 from-scratch 불가 → SSL이 유일 경로.
- **사전등록 NO-GO(엄격, critic 반영):** (i) imaging이 **DEMO+BASE** bar를 부트스트랩 CI 하한 > 0으로 넘어야 함
  (base 제외 비교 불충분), (ii) **SSL pool에서 ADNI subject subject-level hold-out**(R3 transductive 누수 방지),
  (iii) ADNI 내부 **scanner LOCO**(단일코호트라도 scanner 외움 배제), (iv) multi-seed CI. 하나라도 실패 시 폐기·음성 ledger.
- **현실 기대:** 5절이 임상정보 위 여유 미검출을 보였으므로 낮음. 음성이어도 1차 산출물.

### 6.2 (정직·확실) Ceiling benchmark — 음성 헤드라인
- 진단(AD/CN) + 진행(전환·미래 인지)을 통합해 **"구조 T1 표현은 morphometry+baseline 인지를 넘지 못한다"**를
  diagnosis→prognosis 전 스펙트럼에서 체계적으로 특성화. 누수없는 LOCO + 계층적 bar(DEMO→인지→morph→image)가 무기.
- prognosis까지 확장한 ceiling map은 공백 가능(Wen2020/Bron2021은 진단만 — literature-scout 확인 필요).

### 6.3 (놓친 대안 — critic 제안, 측정 가치 높음)
- **survival framing:** 전환을 이진 대신 discrete-time survival(C-index)로 → informative censoring 처리, N=348 전체 활용(검정력↑).
- **longitudinal-pair 입력:** baseline+follow-up MRI **2장의 구조 변화율**을 입력 → 이건 *단일 부피의 lossy 요약이 아니라서*
  R2 천장을 원리적으로 우회할 유일 후보. 단 ADNI paired-MRI 가용 N 선확인(미측정).

**제 권고:** **6.0(image→fs_vol R²)을 먼저 측정** → 결과로 6.1(천장 아님→bounded imaging) vs 6.2(천장 확정→benchmark) 자동 분기.
6.3의 longitudinal-pair는 6.1로 가더라도 입력 설계의 1순위 후보. 어느 경로든 `docs/<phase>_plan.md` 합의 후 GPU.

---

## 7. 노트북 인덱스 / 재현

| 노트북 | 내용 |
|---|---|
| `notebook/01_prior_failure_analysis.ipynb` | 4-사인(R1–R4), dead-ends, ceiling 메커니즘 + Cramér's V 라이브 |
| `notebook/02_data_qc_integrity.ipynb` | base-텐서 전수 QC + QC-pass 빌드 검증 |
| `notebook/03_cohort_class_bias.ipynb` | 코호트×진단 confound (그림: `figures/03_cohort_class.png`) |
| `notebook/04_longitudinal_feasibility.ipynb` | ADNI 종단 구조·전환 검정력·회귀 N·라벨 함정 |
| `notebook/05_baseline_bar.ipynb` | ⭐ 계층적 baseline bar + 부트스트랩 CI (critic 반영 개정판) |

재현: `uv run python notebook/_build.py` (생성) →
`uv run jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.kernel_name=mb-uv notebook/0*.ipynb`.
데이터: QC-pass 작업셋(read-only canonical에서 빌드, `src/microbrain/build_qc_pass_manifest.py`).
