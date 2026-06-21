# 02 · 천장과 baseline — 무엇이 닫혔나

> 4개 형제 라인의 실패 근본원인(R1–R4) + 우리가 측정한 baseline bar + 닫힘/열림 ledger 종합.
> 증거 노트북: `notebook/04_morphometry_ceiling.ipynb`·`05_longitudinal_limits.ipynb`. 원본 측정: `insight/`.

## 1. 실패 근본원인 — 4-사인 (R1–R4)

4개 라인(minyoung2/4/i + plant)이 *독립적으로* 같은 벽에 부딪혔다. 2개는 구조적(불가피), 2개는 자초(통제가능).

| # | 원인 | 성격 | 핵심 증거 |
|---|---|---|---|
| **R1** | site = population 비가역 교란 | 🔴 구조적 | traveling-subject≈0 → site 제거=신호 제거(산술 항등). GRL 3회·ComBat/MixStyle/N4 dead. site×impaired Cramér's V **0.421**, morph→site **2.6×chance** |
| **R2** | morphometry 신호 천장 | 🔴 구조적 | deep≈부피. image-BN 0.910 ≤ morph 0.931; 해상도 2mm→1.5mm Δ0.000; minyoung2 5/5 LOCO 무승부 |
| **R3** | 평가 누수(in-dist 거품) | 🟡 자초 | transductive/random-split 누수(0.521→0.471). → subject-level + validation-lock + nested-LOCO 필수 |
| **R4** | 약한/confounded target | 🟡 자초 | amyloid=atrophy-staging confound, 검정력 부족(Δ<0.03 동등주장) |

**핵심:** R2는 *모델 용량* 천장이 아니라 **modality(T1w 구조) 정보량** 천장 — 부피가 T1 진단신호의 near-sufficient 요약이라 어떤 인코더·아키텍처·scale도 없는 headroom을 못 만든다. **아키텍처는 레버가 아니다.**

## 2. Baseline bar — imaging이 넘어야 할 선 (`notebook/04`)

계층적 bar(DEMO→+BASE(인지)→+MORPH), subject-level 5-fold, 부트스트랩 CI:

| | DEMO | +BASE | +MORPH | Δ(MORPH\|+BASE) 95%CI |
|---|---|---|---|---|
| **전환**(MCI→AD, N=348) AUROC | 0.665 | 0.801 | 0.791 | **−0.011 [−0.060, +0.035]** |
| **미래 cdrsb**(N=849) R² | 0.063 | 0.477 | 0.496 | **+0.019 [−0.009, +0.049]** |

→ **baseline 인지(cdrsb)가 들어가면 morphometry 증분 CI가 0을 포함**(전환·회귀 모두). 공짜 임상정보 위 구조 신호의 여유가 측정되지 않음. (`last_cdrsb`는 baseline과 autoregressive — GO 타깃서 제외, descriptive-only.)

**종단 변화율도 닫힘** (`notebook/05`): naive per-ROI Δmorph가 static morph+인지를 못 넘음 — ΔR² **−0.103 [−0.194, −0.038]**(전부 음수). transport도 파탄(R1 종단판). → ledger `2026-06-20_longitudinal_changerate_negative.md`.

## 3. 닫힘 / 열림 ledger (13개 주장 적대 검증)

13개 주장을 research-critic이 *열려있다고 반증 시도* 후 measurement-clean 기준 분류. **완전히 닫힌 건 4개뿐.**

### ✅ 완전히 닫힘 (measurement-clean — reopen 불가)
- **C1** deep이 단면 T1 AD/CN을 **정확도로** morph보다 잘함 — 가장 우호적 deep(0.910)조차 morph 0.931에 패. capacity가 천장 못 만듦.
- **C3** **naive per-ROI Δmorph**가 static morph+인지를 넘음 — ΔR² CI 전부 음수.
- **C8** scale/quality로 foundation model과 경쟁 — 12,978 ≪ BrainIAC 49k/FOMO 60k. 산술 불가.
- **C9** **AJU 단독** CN-vs-impaired — CN 2.3%(~23명), admissible 점추정 없음(recruitment).

### ⚠️ 강하게 음성이나 안 닫힘 (미검정 gate에 걸림 — 내 이전 단정의 교정)
- **C2** imaging이 prognosis서 더함 — NB04가 닫은 건 *morphometry* 증분이지 *learned imaging*이 아님. image⊋morph, `image→fs_vol R²`(GATE-3) 미측정.
- **C4** cross-site transport — *진단* morph는 오히려 transport됨(LOCO 0.936). 음성은 prognosis·Δmorph-proxy·검정력부족 한정.
- **C5** rich multimodal cross-site 종단 — 좁은 thesis는 구조적 닫힘, 넓은 thesis(Lane A train-time 합성)는 안 닫힘.
- **C6** Swin/hierarchical 아키텍처 — 그 아키텍처 in-house 미실행(2.5D CNN만), 외부증거 `[VERIFY]`.
- **C7** amyloid from T1 — 외부 T1→amyloid AUC 0.62는 chance 초과(정보 0 아님), "undecidable"이지 천장 확정 아님.

### 🔓 진짜 열림 (단 prior 강 null)
- **O3** deep spatiotemporal(deformation/Jacobian) 변화패턴이 crude Δmorph 너머 신호 — 측정 0회. kill-test는 naive Δ만 반증. 천장 0.11+비-transport+static초과요구 3중 장벽.

## 4. ⭐ 닫힘의 근본원인 + load-bearing 측정

- **R2 천장** + **R1 site=population** + **구조적 저주(disjointness)** + **scale 산술**의 곱.
- **경계조건:** 닫힘의 절반(C2·C6·C7·O1·O2)은 단 하나의 미측정 — **GATE-3 `image→fs_vol R²`**(특히 cortical/precuneus) — 에 걸려 있다. cortical R²≈1 → 완전 닫힘 승격 / cortical R²≪1 → 재개방.
  - **GATE-3 CPU 시도(2026-06-20, `src/microbrain/gate3_image_to_fsvol.py`): inconclusive.** trivial 4mm-PCA 표현 → SUBCORT R² 0.29(*너무 낮음*)·AD-CORTICAL R² −0.03. subcortical조차 못 복원 → cortical≈0이 *표현약함 vs 정보없음* 구별 안 됨 = **ambiguous band**(사전등록 예측 그대로). **결정적 GATE-3는 deep/pretrained encoder(GPU) 필요** → ledger 불변.

> 한 문장: **T1 구조에서 *정확도 기반* 모든 경로는 R2 천장 × R1 저주로 measurement-clean하게 닫혔고, 살아있는 건 정확도-아닌 축(→ `03_novelty-and-direction.md`)과 deep spatiotemporal 한 칸뿐.**
