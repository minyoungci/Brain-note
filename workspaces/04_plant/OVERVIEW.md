# plant (microbrain) — 다기관 T1w MRI에서 site bias가 원인인가, morphometry 너머 신호의 천장인가를 *판정*하는 연구

## 한눈에

- T1w 뇌 MRI 치매 표현학습에서, 부진의 원인이 **(a) site/scanner bias 오염**인지 **(b) regional volumetry(부피) 너머 미세신호의 천장**인지를 — bias를 "제거"하기 전에 — **분리·판정**하는 것이 1순위 임무다 (출처: `RESEARCH_BRIEF.md`).
- 이 라인은 형제 워크스페이스(minyoung2/4/i)가 **이미 두 번 무덤에 들어간 자리**를 출발 제약으로 받는다: deep ≈ 부피, GRL 2회 실패, harmonization 역설 (출처: `RESEARCH_BRIEF.md`).
- 현재 ✅ **P0 audit 완료** — bias는 이미지에 실재(voxel→site 3.3×chance)하고 N4로 안 지워지지만, disease는 morphometry 수준에서 site와 **분리 가능**(decidable). 단 핵심 voxel 수치는 아직 smoke(350) 단계 (출처: `results/P0/P0_AUDIT_REPORT.md`).
- 🟡 **P2 결정 run 진행** — 2mm 이미지 supervised LOCO가 amyloid에서 mean AUROC **0.630 < morphometry 바 0.72**로 나왔으나, 진단 결과 이는 **(b) 천장이 아니라 2mm 해상도 + site-shortcut 핸디캡**으로 판단되어, 1mm/1.5mm + site-invariance로 **공정 재실행 중** (출처: `results/P2/stage1_loco.log`, `SCRATCHPAD.md`).
- 지배적 prior는 여전히 **(b) 천장**이며, "안 된다"는 null도 사전 등록된 1차 결과로 본다 (출처: `RESEARCH_BRIEF.md` §3).

---

## 배경·문제 정의

이 워크스페이스(`/home/vlm/plant`, 내부명 microbrain)는 원래 longitudinal 라인이었으나 2026-06-11에 **microbrain(bias-robust micro-level T1w 표현)**으로 재정의되었다 (출처: `docs/DECISION_LOG.md`, 되돌아갈 지점 commit `27b1665`).

문제의식의 핵심은 프레이밍 교정이다. "harmonization 열심히 → 부피 못 넘음 → 원인 불명"의 늪에 형제 워크스페이스(minyoung4)가 두 번 빠졌다. 따라서 이 라인은 bias 제거를 목표로 삼지 않고, **표현학습 부진의 원인이 (a)인지 (b)인지를 먼저 가르는 것**을 임무로 둔다 (출처: `RESEARCH_BRIEF.md` §0).

출발 제약으로 받은 과거 음성 결과 (출처: `RESEARCH_BRIEF.md` §1):

1. **deep ≈ regional volumetry** — minyoung2 EXP01에서 deep 2.5D 표현이 5-ROI FreeSurfer 부피 baseline을 5/5 LOCO fold에서 못 이기고 pooled에서만 +0.018 AUROC → (b) 천장 가설이 강함.
2. **adversarial/GRL 2회 실패** — minyoung4: scanner-family 누수 + morphometry 미초과로 2회 기각.
3. **Harmonization 역설** — minyoungi: ComBat이 ADNI/KDRC를 개선하면 NACC가 회귀. 전 코호트 동시 작동하는 단일 변환 없음.
4. **평가 누수** — in-dist validation checkpoint → OOD 붕괴(ADNI seed2 0.522, OASIS 0.511↔0.810). validation-locked LOCO가 아니면 AUC≈0.9는 거품.
5. **ROI fail-closed** — manifest `roi_final_ready` 전수 False → ROI 라벨 의존 supervision은 신뢰 상한이 막힘. label-free SSL이 이 함정을 구조적으로 우회.
6. **bias 변수 빈약** — 실질 bias 축은 거의 `consortium`(7값) 하나. scanner는 coarse(vendor 수준), field_strength는 대부분 3T이고 KDRC는 전무.

성공 정의는 **이중 게이트 동시 통과**다(한쪽만은 실패) (출처: `RESEARCH_BRIEF.md` §3):
- **G1 (bias 제거):** held-out cohort에서 학습된 표현으로 site/scanner classifier가 near-chance로 떨어지고, 동시에 disease(CDR) 신호는 보존.
- **G2 (가치):** validation-locked LOCO에서 표현이 morphometry baseline 대비 incremental하게 예측하고, 그 증분이 held-out cohort로 transport.

---

## 데이터

canonical manifest는 하나만 쓴다: `official_manifest_full_n4_real_final.parquet` (read-only, `/home/vlm/data`에 쓰기 금지) (출처: `RESEARCH_BRIEF.md` §2, `CLAUDE.md`).

- **13,022 세션 / 7 코호트**: ADNI 4742 · NACC 1866 · A4 1811 · OASIS 1420 · AJU 1287 · AIBL 987 · KDRC 909 (출처: `RESEARCH_BRIEF.md` §2).
- **입력 텐서**: `final_tensor_path` = 192×224×192, 1mm RAS, z-score, brain-masked, 전 세션 동일 격자(identity grid) → resample 불필요. N4 보정판(`final_tensor_n4_path`) 별도. **주의: N4 ≠ harmonization** — intra-scan bias field만 보정하고 inter-site 분포 shift는 그대로 남는다 (출처: `RESEARCH_BRIEF.md` §2).
- **voxel-wise 학습 풀**: `voxelwise_qc_candidate=True` → 12,978 세션 (출처: `RESEARCH_BRIEF.md` §2).
- **진단 타깃**: `cdr_global` (0:7080 / 0.5:4931 / 1:831 / 2:161 / 3:19) — **severe AD 희소, 불균형 심각** (출처: `RESEARCH_BRIEF.md` §2).
- **morphometry baseline**: `fs_vol_*`(L/R hippocampus·amygdala·thalamus·ventricle·entorhinal 등 + 전역 `fs_*Vol`).
- **함정 플래그**: `roi_final_ready=False`(전수, 사람 sign-off 전).

site×diagnosis confound가 심각하다는 점이 데이터의 1차 위협이다. impaired rate(CDR≥0.5)는 OASIS 20% · AIBL 30% · A4 31% · NACC 36% · ADNI 47% · KDRC 69% · **AJU 98%** → site가 사실상 diagnosis의 proxy (출처: `docs/P0_bias_audit_plan.md` §0.1).

Korean 코호트(AJU/KDRC)는 공개셋이 못 가진 완전 멀티모달(T1+FLAIR+PET+혈액패널+동반질환+GDS+WMH)을 가지나, CN이 195뿐이라 disease-enriched이다 (출처: `docs/investigations/novelty_deep_research.md` §3).

---

## 접근·방법

네 가지 방법(audit / SSL / site-invariance / harmonization)을 *택일*이 아니라 **하나의 순서**로 본다. 각 단계는 숫자로 명시된 kill-criteria(NO-GO)를 가지며, 통과 전 다음 단계 진입 금지 (출처: `RESEARCH_BRIEF.md` §4).

- **P0 — audit-first (학습 없음):** raw voxel & morphometry feature로 site/scanner 예측 강도 측정, 누수 지도(bias atlas), confound 구조, N4 효과 정량.
- **P1 — baseline·천장:** morphometry → CDR 정직한 LOCO baseline, trivial 표현 baseline, G1/G2 숫자 고정.
- **P2 — 표현학습, 다중 arm:** Arm A(label-free micro-SSL/MAE) · Arm B(+site-invariance) · Arm C(harmonization-first) · Arm D(무처리 control). 동일 게이트로 병렬 평가.
- **P3 — 평가·판정:** LOCO transport, per-cohort, multi-seed CI로 (a)/(b) 확정.

전략의 한 축은 **"disentangle, not erase"**다. 과거 3실패는 글로벌 site를 통째로 삭제해 confound regime에서 population까지 지운 데서 나왔다. 대신 P0에서 측정으로 확인된 **clean subspace(A4 vendor⊥dx V=0.012, ADNI V=0.060)**에서만 acquisition-invariance를 학습한다는 안이다 (출처: `docs/investigations/multisite_RL_strategy.md` §2). 단 이 전략 문서는 target을 AD/CN에서 morph-weak로 옮기면서 부분 SUPERSEDED 상태다 (출처: `docs/README.md`).

운영 규율(위반 금지): subject-level LOCO + validation-lock + multi-seed, 입력은 이미지(+최소 메타)만(ROI/scanner/CDR/morphometry는 target·stratify·audit 전용), bf16 필수, RAM 1TB 상한 (출처: `CLAUDE.md`, `RESEARCH_BRIEF.md` §5).

---

## 현재 상태와 결과

### ✅ 확정 — P0 audit (notebooks 01~06 실행·검증)

모든 수치는 재현 가능한 노트북 실행 결과다 (출처: `results/P0/P0_AUDIT_REPORT.md`, `results/P0/P0_summary.csv`).

| ID | 측정 | 결과 | 해석 |
|---|---|---|---|
| A0 | site×diagnosis confound | Cramér's V(site,impaired)=**0.42**, V(site,dx)=**0.53**; site-only→impaired AUROC **0.71** | 강한 confound. disease 평가에 prevalence 병기 의무 |
| A1 | morphometry→site | bAcc **0.271**(RF), chance 0.143 | 부피도 site를 ~2× 지지만 약함 |
| A1★ | within-cohort vendor⊥dx | **A4 V=0.00 · ADNI V=0.06 (clean)**; NACC 0.14(제외) | acquisition-invariance clean 신호원 = A4·ADNI뿐 |
| A4★ | decidability | pooled raw **0.774** → site-residualized **0.722** (drop **−0.052**) | disease가 site 제거 후 생존 → **SEPARABLE** |
| A5 | morphometry→CDR LOCO 바 | per-cohort 0.70~0.87, mean **0.766**; in-dist 0.774 ≈ LOCO | morphometry가 잘 transport. G2 바 = 0.77 |

핵심 사다리: **chance 0.143 < morphometry-site 0.271 < voxel-site 0.475** — site는 morphometry보다 이미지에 훨씬 강하게 박혀 있으나, disease는 morphometry 안에서 site와 분리된다. BRIEF §5 판정 규칙상 "bias 실재 + 분리 가능 → P2 진행" 경로에 해당 (출처: `results/P0/P0_AUDIT_REPORT.md` §2).

### 🟡 잠정 — voxel→site 강도와 N4 무효 (smoke 단계)

- A2(smoke 350): voxel→site bAcc base **0.475**, N4 **0.470**, chance 0.143 → site가 이미지에 강함(3.3×), N4 effect **−0.006**(N4 ≠ harmonization) (출처: `results/P0/P0_summary.csv`).
- A3(smoke): bias atlas η²>0.1 = voxel의 **4%** → site 신호는 국소적(경계/외곽).
- **한계:** A2/A3는 350-subject smoke뿐이다. 정량 NO-GO 판정은 full-pass(12,978×2)가 별도 승인 후 확정되어야 한다. 단 smoke 방향은 minyoungi playbook 선례와 일치 (출처: `results/P0/P0_AUDIT_REPORT.md` §4).

### 🟡 잠정 — P2 결정 run: 2mm 이미지는 morphometry를 못 넘었으나, 깨끗한 (b) 판정이 아님

P2의 단일 질문: **morphometry가 *약한* regime(amyloid·MCI)에서 학습된 3D 표현이 LOCO로 morphometry 바를 넘어 transport하는가** (출처: `docs/P2_plan.md` §0).

Stage-0 smoke는 PASS(파이프라인·누수 검증, held-OASIS AUROC 0.583, 입력=이미지만) (출처: `SCRATCHPAD.md`).

Stage-1 결정 run (image resnet18, EMA, LOCO, amyloid +/−, 2mm, 3 seed, 4 fold) 결과 (출처: `results/P2/stage1_loco.log`, `results/P2/stage1_summary.json`):

| held | image AUROC | prev | n |
|---|---|---|---|
| AJU | 0.628 | 0.338 | 1286 |
| KDRC | 0.659 | 0.677 | 533 |
| NACC | 0.628 | 0.390 | 515 |
| OASIS | 0.605 | 0.315 | 1048 |
| **mean** | **0.630** | — | — |

- **image LOCO mean AUROC 0.630 < morph 바 0.72 < morph+APOE 0.78** → G2 미충족.
- **G1 embedding→site bAcc 0.805** (chance 0.25, morph site-leak 0.27) → 강한 **site shortcut** → G1 실패 (P2 NO-GO 3 해당) (출처: `results/P2/stage1_loco.log`).

표면적으로는 (b) 천장으로 읽히지만, 후속 진단이 이 해석을 막는다. image(2mm) → fs_vol 회귀(held-out R², subject-disjoint) 결과 (출처: `results/P2/diag_morph_regress.json`, `SCRATCHPAD.md`):

- subcortical/ventricle **mean R² 0.67** (lateral ventricle 0.91/0.94, hippocampus 0.68/0.54, amygdala 0.63/0.72) → **모델 정상, 부피 추출 가능**.
- cortical ribbon **음수** (entorhinal_L −1.07, fusiform_L −2.02, precuneus_L −1.74) → **2mm가 thin cortex를 못 잡음 = 해상도 병목**.

> 자기평가 편향 주의: `diag_morph_regress.json`의 자동 verdict는 "모델이 부피조차 못 뽑음 → (c) 모델/해상도 병목"이라고 적었으나, 이는 mean R²(−0.057)가 극단 음수에 끌린 오판이다. median R² 0.413 + per-ROI 패턴(subcortical OK, cortical 음수)이 진실이라는 것이 SCRATCHPAD의 재해석이다 (출처: `SCRATCHPAD.md`, `CLAUDE.md` "생성과 검증은 분리된 단계"). — 즉 생성물의 자체 결론과 독립 재해석이 갈린 사례.

**현재 판정:** 2mm Stage-1의 0.63은 (b) 천장의 증거가 아니다. ①2mm로 cortical 신호 소실, ②site-shortcut(0.805) 핸디캡이 혼재한 결과다. 따라서 disease (a)/(b) 검정을 **1mm/1.5mm + site-invariance**로 공정하게 재실행 중이며, `diag_1p5mm.log`는 1.5mm cache 빌드 후 morph-regression 입력(X 3382×128×149×128, train 2699/test 683)까지 진입했으나 로그상 최종 결과는 아직 출력되지 않았다 [VERIFY: 재실행 완료 여부] (출처: `results/P2/diag_1p5mm.log`, `SCRATCHPAD.md`).

### ❌ 반증 — 폐기된 가설들

- **혈액바이오마커 + MRI (D5):** 문헌상 유일 whitespace였으나, Korean 1821세션 직접 검증에서 morph+age 0.787 → +혈액17종 0.792 = **Δ+0.005(사실상 0)**. "혈액이 AD 분류를 개선한다"는 경험적 반증 (출처: `docs/investigations/novelty_deep_research.md` §2).
- **imaging-only 멀티모달 SSL이 morphometry를 matches한다:** deep-research(104 agents, adversarial verify) 결과 **REFUTED**. cross-site degradation 실재(ADNI 0.96 → OASIS 78%/AIBL 77.5%) (출처: `docs/investigations/novelty_deep_research.md` §1).

---

## 폐기·전환된 시도

(출처: `docs/DECISION_LOG.md`, `docs/ledgers/2026-06-11_longitudinal_richdata_negative.md`)

- **longitudinal → microbrain 재정의** — 옛 longitudinal 산출물 제거, bias-robust micro-level T1w 표현으로 라인 재출발.
- **D5 혈액바이오마커 폐기** — +0.005로 반증, tested-negative control로만 잔존.
- **rich-data 종단/멀티모달 win 불가** — 세 가지 구조적 어긋남: (1) 가진 label(static AD/CN)은 morphometry 천장인 곳, (2) 종단 궤적은 feature-poor ADNI에만 있고 rich 멀티모달은 cross-sectional Korean에 있어 disjoint, (3) rich 축이 CN-poor Korean에 몰려 cross-site 시 버려야 함. rich 데이터의 정당한 역할은 cross-site benchmark testbed로 강등.
- **AD/CN harmonization headline 강등** — CN-vs-AD morphometry LOCO 바가 **0.936**(held별 0.92~0.96)으로 이미 거의 완벽 transport → bias가 baseline 병목이 아니며 headroom(→1.0)이 0.06뿐. micro-signal이 더할 여지가 구조적으로 작음. harmonization(IGUANe 등)은 P2 Arm C 대조군으로만 (출처: `docs/investigations/harmonization_scout_review.md` §4·5).

이 전환들의 공통 결론: morphometry가 강한 AD/CN(0.94)은 천장이고, headroom은 morphometry가 약한 **morph-weak regime(MCI 0.61, amyloid 0.73)**에만 남는다. 그래서 제안 주제가 그쪽으로 수렴했다 (출처: `docs/RESEARCH_PROPOSAL.md` §1·2).

---

## 남은 과제·다음 단계

1. **1mm/1.5mm + site-invariance 공정 재실행 완료** — 2mm의 cortical 소실·site-shortcut 핸디캡을 제거한 조건에서 amyloid/MCI가 morphometry 바를 넘는지 재판정. 현재 1.5mm 진단이 진행 중이나 최종 수치 미확정 (출처: `SCRATCHPAD.md`, `results/P2/diag_1p5mm.log`).
2. **A2/A3 full-pass(12,978×2) 승인·실행** — voxel→site 강도와 N4 effect의 smoke(350) 수치를 전수로 확정 (대형 추출 게이트) (출처: `results/P0/P0_AUDIT_REPORT.md` §6).
3. **P2 target 정의 고정** — A5 바 0.77은 CDR≥0.5(MCI 포함) 기준. CN-vs-AD면 0.85~0.91로 상향되므로 arm 비교 전 target 확정 필요 (출처: `results/P0/P0_AUDIT_REPORT.md` §4).
4. **이중 게이트 판정** — site-invariance가 켜진 뒤 G1(site→near-chance)과 G2(morph 초과·transport)를 동시에 보고. site-shortcut 0.805를 near-chance로 낮추지 못하면 어떤 G2 성능 주장도 무효.
5. **승인 게이트 정합성 점검** — 설계 문서들(`docs/P2_plan.md`, `docs/REPO_STRUCTURE.md`, `src/microbrain/README.md`)은 "코드·GPU는 승인 후, 현재 빈 스캐폴드"라고 기술하나, 실제로는 P2 Stage-0/Stage-1 GPU run이 실행되어 결과물이 존재한다. 문서와 실행 상태의 동기화 필요 [VERIFY: GPU 실행 승인 시점] (출처 대조: `docs/P2_plan.md` §7 ↔ `results/P2/stage1_loco.log`).

지배적 prior는 여전히 **(b) 천장**이다. 과거 3라인(deep≈morphometry 5/5 LOCO, residualize→chance)과 P0가 "이미지에 bias가 있다"만 보였을 뿐 "morphometry 너머 disease 신호가 있다"는 아직 미증명이다. **null이 가장 가능성 높은 1차 결과**이며, 그 자체로 publishable한 정직한 cautionary 결과로 본다 (출처: `results/P0/P0_AUDIT_REPORT.md` §4).

---

## 출처 맵 (참조한 핵심 파일)

- `RESEARCH_BRIEF.md` — 설계 단일 진실(임무·과거실패·게이트·단계 계획·제약)
- `CLAUDE.md` — 운영 규칙(데이터 read-only, LOCO/validation-lock, 승인 게이트, 정직·중단·되돌리기 원칙)
- `SCRATCHPAD.md` — live 상태(P0 실행, P2 진입·진단, rich-data/novelty 점검 누적 로그)
- `docs/README.md` — 문서 인덱스·읽는 순서·현황
- `docs/RESEARCH_PROPOSAL.md` — 현재 연구 방향(morph-weak regime cross-site decidability) + 5각도 수렴 근거
- `docs/DECISION_LOG.md` — 피벗·NO-GO·폐기 추적
- `docs/P0_bias_audit_plan.md` — P0 설계서(A0~A5 방법·판정기준·NO-GO)
- `docs/P2_plan.md` — P2 설계서(Stage 0~3, kill-criteria 숫자)
- `docs/REPO_STRUCTURE.md` — 디렉토리 규약(생성 src ↔ 평가 experiments/tests)
- `docs/investigations/multisite_RL_strategy.md` — "disentangle, not erase" 전략(부분 superseded)
- `docs/investigations/harmonization_scout_review.md` — harmonization scout(IGUANe=Arm C 대조, AD/CN 바 0.936)
- `docs/investigations/novelty_deep_research.md` — deep-research(104 agents) + 혈액 D5 직접 반증
- `docs/ledgers/2026-06-11_longitudinal_richdata_negative.md` — rich-data 종단/멀티모달 음성 ledger
- `results/P0/P0_AUDIT_REPORT.md`, `results/P0/P0_summary.csv` — P0 audit 종합 판정·수치
- `results/P2/stage1_loco.log`, `results/P2/stage1_summary.json` — P2 Stage-1 LOCO 결정 run(image 0.630, site-probe 0.805)
- `results/P2/diag_morph_regress.json`, `results/P2/diag_1p5mm.log` — image→fs_vol 진단(2mm 해상도 병목, 1.5mm 재실행)

---
> 자동 생성: LLM 에이전트가 `plant` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-13.
