# microbrain — RESEARCH BRIEF

> 새 연구 라인의 단일 진실 문서(single source of truth). 이 디렉토리에서 일하는 모든 에이전트는
> **작업 시작 전 이 파일을 끝까지 읽는다.** 작성 2026-06-11 · 상태: 설계 lock 전(P0 착수 대기).
> 위치 메모: 권한 때문에 `/home/vlm/minyoung/microbrain`에 둠. 원래 의도는 `/home/vlm`의 6번째 top-level
> 워크스페이스(minyoungi/2/3/4/plant의 형제). root가 옮기면 승격 가능(절대경로 참조뿐이라 이동 안전).

---

## 0. MISSION (3문장)

뇌 T1w MRI의 **site/scanner bias에 내성 있는 micro-level 표현**을, 과거 실패를 반복하지 않도록
밑바닥부터 단계적으로 학습한다. **1순위 임무는 "bias를 제거하는 것"이 아니라**, 표현학습이 부진한
원인이 **(a) site/scanner bias 오염**인지 **(b) T1w에서 regional 부피(morphometry) 너머의 미세
신호 자체가 약한 천장**인지를 **분리·판정**하는 것이다. 그 판정 위에서만 micro-level 표현의 가치를 주장한다.

> 이 프레이밍이 전부다. (a)와 (b)를 안 가르면, "harmonization 열심히 → 부피 못 넘음 → 원인 불명"의
> 늪(minyoung4가 두 번 빠진 곳)에 또 빠진다.

---

## 1. PRIOR NEGATIVE RESULTS — 먼저 알고 시작하라 (가장 중요)

이 라인은 **이미 두 번 무덤에 들어간 자리**다. 아래는 형제 워크스페이스가 데이터로 확인한 사실이며,
새 에이전트는 이것을 *가정이 아니라 출발 제약*으로 받아들인다. 원문 근거:
`/home/vlm/minyoung/OBSERVATORY/workspaces/{01_minyoung2,02_minyoung4,05_minyoungi}/`
(`OVERVIEW.md`·`README.md`·`findings.md`·`risks.md`) 및 `learn/knowledge/01_loco_transport.md`.

1. **deep ≈ regional volumetry.** minyoung2 EXP01: deep 2.5D 표현이 5-ROI FreeSurfer 부피 baseline을
   5/5 LOCO fold에서 못 이기고 pooled에서만 +0.018 AUROC. → **(b) 신호 천장 가설이 강하다.**
   morphometry baseline은 모든 주장의 최소 bar다.
2. **adversarial/GRL은 2번 실패.** minyoung4: scanner-family 누수 + morphometry 미초과로 2회 기각.
   단순 GRL 재시도 = 3번째 실패. 누수 경로(scanner-family)를 정량 audit 없이 건드리지 말 것.
3. **Harmonization 역설.** minyoungi: ComBat이 ADNI/KDRC를 개선하면 **NACC가 회귀**. 모든 코호트에
   동시 작동하는 단일 변환은 아직 없다. "bias 제거"를 한 코호트만 보고 판단하면 안 된다.
4. **평가 누수.** in-dist validation checkpoint → OOD 붕괴(ADNI seed2 0.522, OASIS 0.511↔0.810).
   validation-locked LOCO가 아니면 AUC≈0.9는 **site 누수 포함된 거품**.
5. **ROI fail-closed.** manifest `roi_final_ready` **전수 False**(사람 sign-off 전). ROI 라벨 의존
   supervision은 신뢰 상한이 막혀 있다. → **label-free SSL이 이 함정을 우회하는 구조적 장점**을 가진다.
6. **bias 변수가 빈약하다.** 실질 bias 축은 거의 `consortium`(site) 하나다(아래 §2). scanner 모델은
   coarse(≤5종/코호트), field_strength는 대부분 3T이고 KDRC는 전무. fine-grained scanner 통제는 데이터가 없다.

---

## 2. DATA CONTRACT — 줄 데이터 (검증된 사실)

**THE canonical manifest (이것만 쓴다):**
```
/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet
  (+ .csv, + .datadict.csv  ← 컬럼 사전. 작업 첫 단계에서 datadict부터 읽는다.)
README: 같은 폴더 README_MANIFEST.md
```
- read-only canonical. `/home/vlm/data`에 **쓰기 금지**.
- **13,022 세션 / 7 코호트**: ADNI 4742 · NACC 1866 · A4 1811 · OASIS 1420 · AJU 1287 · AIBL 987 · KDRC 909.

**입력 텐서(이미지):**
- `final_tensor_path` = **192×224×192, 1mm RAS, z-score, brain-masked**. 전 세션 **동일 격자(identity)** → resample 불필요.
- `final_mask_path` = brain mask(동일 격자).
- N4 보정판: `final_tensor_n4_path` / `final_mask_n4_path`. **주의: N4 ≠ harmonization.** N4는 intra-scan
  bias field(밝기 불균일)만 보정하고 inter-site 분포 shift는 그대로 남긴다. n4 vs base 전이 우위는 아직 미결(minyoung2 EXP04 진행 중).

**bias 통제 변수 (메타):**
- `consortium` (site 주축, 7값) · `acq_scanner`(coarse, ≤5종/코호트) · `acq_field_strength`
  (3.0T 11,506 / 1.5T 22 / 결측 1,494 = KDRC 909 전부 + NACC 361 + AJU 220) · `acq_scanner_source`.

**voxel-wise 게이트:** `voxelwise_qc_candidate=True` → **12,978 세션**(이게 micro/voxel 학습 풀).

**라벨·baseline:**
- 진단 타깃: `cdr_global`(0:7080 / 0.5:4931 / 1:831 / 2:161 / 3:19 — **severe AD 희소, 불균형 심각**), `cdrsb`.
- morphometry baseline: `fs_vol_*`(L/R hippocampus·amygdala·thalamus·ventricle·entorhinal 등 + `fs_*Vol` 전역).
- 임상 공변량: `clin_age`·`clin_sex`·`clin_apoe`(코호트별 결측 큼, datadict의 cov_* 참조).

**함정 플래그:** `roi_final_ready=False`(전수) · N4 QC(`bias_ratio_*`, `brain_voxel_loss_ratio`, `n4_grid_match_frac`).

**재사용 자산(읽고 시작):** minyoungi `Clinical/common/{mri_io,roi_tools,render3d,clinical_io}.py`,
`experiments/voxelwise_feature_learning_v1/`(기존 voxel-wise 시도) · minyoung2 `scripts/build_exp01_cdr_split.py`(LOCO split).
→ 바닥부터 다시 짜기 전에 무엇이 이미 있는지 확인한다.

---

## 3. SUCCESS — 정량 게이트 (측정 가능하게)

표현이 "성공"하려면 **두 게이트를 모두** 통과해야 한다. 하나만은 실패다.

- **G1 (bias 제거):** held-out cohort에서 학습된 표현으로 **site/scanner classifier AUC가 near-chance**
  (multiclass면 balanced-acc ≈ 1/K)로 떨어지고, **동시에 disease 신호(CDR)는 보존**된다.
- **G2 (가치):** **validation-locked LOCO**에서 표현이 **morphometry baseline 대비 incremental**하게
  CDR/progression을 예측하고(부트스트랩 CI 보고), 그 증분이 **held-out cohort로 transport**된다.

판정 규칙(이게 임무의 핵심 산출물):
- G1 통과 ∧ G2 통과 → **bias가 원인이었고 제거했더니 신호가 있다** (성공).
- G1 통과 ∧ G2 실패(≈morphometry) → **(b) 천장 확정: bias가 아니라 신호가 약한 것** → 정직한 cautionary 결과(이 또한 publishable).
- G1 실패(특정 코호트에서 site 못 지움) → **harmonization 역설 재현** → 어느 코호트·어느 region에서 새는지 정량화하여 보고.

> **null도 사전 등록된 1차 결과(primary outcome)다.** "안 된다"를 정직하게 측정하는 게 기여다.

---

## 4. PHASED PLAN — 단계별 프로그램 (네 접근을 모두 아우름)

네 가지 방법(audit / SSL / site-invariance / harmonization)은 *택일*이 아니라 **하나의 순서**다.
각 단계는 **kill-criteria(NO-GO)** 를 갖는다. 단계 통과 전 다음 단계 금지.

### P0 — 적을 측량한다 (audit-first). 학습 없음.
목표: 표현학습 전에 site/scanner가 **voxel/feature 어디로·얼마나** 새는지 정량 지도 작성.
- raw voxel & morphometry feature로 **site/scanner 예측 강도** 측정(linear + nonlinear probe, held-out 스킴).
- 누수 지도: intensity histogram의 site차, voxel-wise MI(voxel↔site), 어느 brain region이 site 신호를 진다.
- **confound 구조**: site × diagnosis 얽힘(코호트별 CDR 분포 차이 → spurious correlation). 이게 G2 평가를 오염시킨다.
- N4 효과: n4 vs base에서 site 예측 강도가 줄어드는가(minyoung2 EXP04의 grounded 확장).
- **산출:** "bias atlas" + P2의 bar가 될 site-classifier 강도 숫자.
- **NO-GO/분기:** 만약 N4 후 site가 이미 near-chance면(가능성 낮음) → bias 문제 아님, 즉시 (b) 천장 질문으로 피벗.

### P1 — baseline과 천장을 깐다. 모든 게 넘어야 할 bar.
- morphometry → CDR **정직한 LOCO** baseline(within-cohort 0.91은 누수판이니 LOCO로 재측정).
- trivial 표현 baseline: raw-voxel PCA, intensity 통계.
- §3의 G1/G2를 **숫자로 고정**(near-chance 기준값, incremental 유의 기준, seed 수).
- **NO-GO:** 없음(필수 scaffolding). 단, split/leakage 단위테스트가 통과해야 P2 진입.

### P2 — 표현학습, 다중 arm (SSL·site-invariance·harmonization이 *여기* 산다).
동일한 P1 게이트로 평가되는 **병렬 arm**으로 돌린다(택일 아님 → 무엇이 실제로 작동하는지 *학습*):
- **Arm A (기반):** self-supervised micro/voxel(MAE류 patch recon 또는 contrastive). label-free → ROI fail-closed 면역.
- **Arm B:** A + **site-invariance objective**(adversarial/IRM/decorrelation). minyoung4 교훈: scanner-family 누수 모니터를 loss에 같이 건다.
- **Arm C:** **harmonization-first 입력**(ComBat/style-norm) 후 A. minyoungi 교훈: 전 코호트 동시 평가(NACC 회귀 감시).
- **Arm D (대조):** bias 처리 없는 A. → 각 개입이 *실제로 얼마를 버는지* 측정하는 기준선.
- 전 arm: **multi-seed 필수**, **validation-locked**, per-cohort 보고.
- **NO-GO:** Arm이 Arm D(무처리) 대비 G1을 유의하게 개선 못 하면 그 개입은 폐기·기록(음성 ledger).

### P3 — 평가와 결정적 질문: (a) bias냐 (b) 천장이냐.
- LOCO transport, per-cohort, multi-seed CI. §3 판정 규칙 적용.
- 최良 bias-제거 arm이 morphometry를 넘는가? → (a)/(b) 확정. 어느 쪽이든 publishable 결과로 정리.
- **NO-GO:** 단일 fold·단일 seed 성공을 결과로 쓰지 않는다.

### P4 — (전방) micro-level 해석 / 통합.
- 표현이 작동하면: 어떤 micro-structure를 쓰는가(voxel-level attribution vs morphometry 비교). 작동 안 하면 생략.

---

## 5. HARD CONSTRAINTS (위반 금지)

- **bf16 필수, fp16 금지**(B200). MONAI 쓰면 `cache_rate=1.0` 허용(1TB RAM 기준).
- **RAM 1TB 절대 상한** — 초과 시 SSH 세션까지 종료. 대형 run 전 `/sysmon` 확인, app-level 캡.
- **validation-lock + LOCO**: held-out cohort 체크포인트 선택 금지. split은 subject-level.
- **입력 누수 금지**: 모델 입력은 *이미지(+명시된 최소 메타)*만. ROI 원값·scanner·CDR·morphometry를
  입력에 넣지 않는다(이들은 target/stratify/audit 전용). minyoung3 입력정책과 동일.
- **multi-seed 필수**, 코호트별 보고. `roi_final_ready=False`를 항상 인지(ROI 정량은 후보).
- `uv run python <script>` (서버). 데이터 쓰기는 `/home/vlm/data` 밖(`results/`·`data/derived/`)에만.

## 6. ANTI-GOALS (하지 말 것 — 과거 실패 패턴)

- in-dist validation으로 성공 주장 / 단일 seed·단일 fold 결과 채택.
- harmonization·invariance를 **한 코호트만 보고** 좋다고 판단(전 코호트 동시 확인 의무).
- "deep > volumetry"를 **검증 전 가정**으로 사용. 매 단계 morphometry bar와 비교.
- P0 audit 없이 P2로 직행(=minyoung4 재현). 적을 모르고 GRL부터 켜지 않는다.
- 장식·과장. 근거 약한 주장엔 `[VERIFY]`/`[불확실]`. 생성과 검증은 분리된 단계.

## 7. FIRST MOVE (에이전트가 바로 할 일)

1. `official_manifest_full_n4_real_final.datadict.csv` 정독 → 컬럼·코호트별 커버리지 파악.
2. §1 원문(OBSERVATORY 형제 카드 3종) 읽고 과거 실패를 자기 말로 요약(이해 확인).
3. **단계 설계 문서**(`docs/<phase>_plan.md`)를 먼저 쓰고 Min 승인 → 그 다음 코드.
   (GPU·대형 배치 실행은 사전 승인 게이트. P0는 대부분 CPU/소형으로 가능.)
