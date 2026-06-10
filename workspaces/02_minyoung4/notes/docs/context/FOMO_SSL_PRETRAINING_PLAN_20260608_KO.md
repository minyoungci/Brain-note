# FOMO300K + 기존데이터 결합 SSL Representation Learning — 방향 계획서 (2026-06-08)

상태: **계획(plan) 문서.** 실행 전 Min 승인 필요 항목을 §7에 명시. 직전 실패 연구(`FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md`)를 토대 사실로 계승한다.

---

## 0. 한 줄 요약 (낙관 금지)

- "FOMO300K + 우리 데이터로 scratch SSL"은 **그 자체로는 방법론 논문이 아니라 챌린지 submission이다.**
- 외부 사실: **FOMO25 주최측이 "model/data scaling은 reliable benefit 없음"이라 직접 결론**(arXiv 2604.11679). 즉 "더 큰 데이터·모델" 축은 외부에서 이미 죽어가는 축.
- 방어 가능한 방향: **audit 主 + biology-guided objective를 우리 비순환 probe로 검증**. SSL은 독립 챕터가 아니라 audit의 stress-test로 종속.
- **의사결정 게이트(GPU 대량 투입 전 단일 실험)**: 공개 biology-guided 체크포인트(AnatCL/y-Aware) frozen linear-probe가 우리 LOCO에서 morphometry **0.91 바**를 넘는 기미(≥0.88)가 있는가? 없으면 scratch SSL 베팅은 비합리.

---

## 1. 목적 / 범위

| 항목 | 내용 |
|---|---|
| Research question | site==population confounded regime(한국+서구)에서, FOMO300K로 사전학습한 표현이 morphometry(0.91 LOCO 바)를 *넘는가*, 그리고 그 판정이 비순환 probe로 가능한가 |
| Outcome (1차) | CN/AD LOCO held-cohort 분류(이미지 표현 frozen linear-probe) |
| Outcome (보조) | brain-age 회귀, sex 분류 (utility), site-probe(누수), embedding collapse |
| 비교 baseline | FreeSurfer fs_vol morphometry + 선형모델 = **LOCO AUC ≈ 0.90–0.92 (한국 KDRC 포함)** — 이미지가 넘어야 할 기준선 |
| 측정 도구 | `/home/vlm/minyoungi/roi_qc/scripts/embedding_diagnostics.py` (4-panel: collapse/site/utility/baseline-gap) |
| 범위 밖 | 정확도 SOTA 경쟁, harmonization-for-accuracy, MCI 전환예측 (선행 실험서 사망) |

---

## 2. 데이터 contract

### 2.1 FOMO300K (신규 추가)
- 규모: 306,207 scans(V1.1), **1.30 TB / 40,343 파일**, 거의 .zip.
- 형태: **raw 배포** — native 공간·해상도(예: 0.6mm), **whole-head(두개골 포함)**, raw intensity, **멀티모달**(MP2RAGE/T2starw/MPRAGE/FLAIR/DWI…), 세션당 다중 run.
- 접근: gated. **`minyoungxi` 계정 + gated-repo read 권한 토큰으로 해결**(smoke test 통과).
- 경로: `/home/vlm/data/FOMO300K` (다운로드 진행 중, 백그라운드 resume).
- 구성(상위): HCP, OpenNeuro, HBN, BraTS-GEN, NKI, **OASIS1·OASIS2**, CoRR, IXI, BrainLat 등.
- ⚠️ **누수 표면 = OASIS뿐**: FOMO엔 OASIS1/2가 있고 우리 eval엔 OASIS3 → **우리 OASIS는 eval에서 제외**(Min 결정 반영). ADNI/NACC/AIBL/A4(DUA 제한)·AJU/KDRC(한국 비공개)는 FOMO에 없음 → 누수 0.
- ⚠️ **AMAES 공개 가중치(BRAINS-45K = ADNI+OASIS3+OASIS4+PPMI) 사용 금지** — 우리 ARDNI/OASIS3와 train-eval 누수. scratch만 안전.

### 2.2 기존 데이터 (우리 7 코호트)
- 13,022 세션 / 7,231 subject / **39% 다중세션(최대 16회)** → **split은 반드시 subject 단위**(누수).
- 라벨: clin_age 99%, clin_sex 99%, clin_dx_label 97%(dx3: CN/MCI/AD), cdr 100%.
- **코호트별 CN/AD 극단 불균형**: A4=CN전용, OASIS=AD 8, AJU=CN 23/MCI 980 → LOCO CN/AD 채점 가능 코호트 제한.
- age 범위는 코호트 간 유사(63–79) → age-probe 교란 적음.

---

## 3. 전처리 계획 — **공식 코드 사용, 우리 v2 미사용**

### 3.1 채택 레시피 (Yucca / FOMO25 baseline 기반, 재구현 금지·재사용)
```text
raw NIfTI
  → RAS 좌표계
  → 1mm isotropic resample
  → 99th percentile clip
  → per-volume z-normalization
  → crop to minimum bounding box of brain
(whole-head: skull-strip 안 함, MNI 등록 없음, N4 없음, 각 scan 독립 datapoint)
```
근거: FOMO300K "minimal preprocessing to preserve original characteristics" + AMAES 전문 인용. 실측: 받은 FOMO 볼륨이 raw·whole-head·멀티모달임을 확인.

### 3.2 입력 진입점 (중요 — 이중처리 함정)
| 입력 | 사용할 것 | 사용 금지 |
|---|---|---|
| FOMO | raw FOMO300K NIfTI(받는 그대로) | — |
| 우리 데이터 | **`/home/vlm/data/raw/{ADNI,NACC,AIBL,A4,AJU,KDRC}` 원본 NIfTI (whole-head)** | ❌ v2 `final_tensor*`(이미 strip+conform=이중처리), ❌ `native_t1w_hdbet`(이미 skull-strip, nonzero 9.5% 실측) |

- 🔒 `raw/`는 보호 디렉토리지만 **읽기 입력**이므로 규칙 위반 아님(write/delete/move만 금지).
- 우리 v2/N4/ComBat 산출물은 SSL 입력엔 안 쓰되, **morphometry baseline(fs_vol) 및 데이터 이해 근거로는 계속 유효.**

### 3.3 확인된 걸림돌 (실측 2026-06-08)
1. **raw 포맷 불균일 — 코호트별 준비작업**:
   - ADNI / A4 / KDRC = **NIfTI 준비됨 ✓**
   - **NACC = DICOM(158 .dcm 표본) → DICOM→NIfTI 변환 필요**
   - **AIBL = `AIBL-VLM-v1.zip`(16.6 GB) 미해제 → 압축 해제 후 포맷 확인 필요**(v2엔 AIBL 987세션 존재하므로 내부 이미지는 사용 가능, 단 zip 풀어야 함)
2. **입력 어댑터**: 공식 코드는 BIDS-ish 가정 → 우리 컨소시엄별 레이아웃 매핑 필요(plug-and-play 아님).
3. **306K 전처리 비용**: 멀티모달·다해상도 306K resample = 큰 작업(디스크·시간) → **Min 승인 대상(long job)**. 단 **GPU는 8×B200 idle 확보**되어 컴퓨트 자체는 병목 아님(전처리는 주로 CPU/IO).

---

## 4. 데이터 역할 / split / 누수 — **확정(2026-06-08)**

**한국 데이터(AJU/KDRC) = held-out 시험대로 보존 (Min 결정 확정).** 사전학습/probe-train에 섞지 않는다 → "한국 confounded benchmark" 해자 유지.

| 역할 | 코호트 | CN/AD 가용성 |
|---|---|---|
| **사전학습(SSL)** | FOMO300K (+ 우리 Western 포함 여부는 §7 미결) | — (라벨 불요) |
| **probe-train(linear)** | Western ex-OASIS: ADNI/NACC/AIBL/A4 | CN=6229 / AD=474 (subj 4603) |
| **held-out TEST** | **한국: KDRC (CN282/AD249) = CN/AD 시험대 ✓** | KDRC만 CN/AD 가능 |
| held-out TEST(보조) | 한국: AJU (CN23) | **CN/AD 불가** → site-probe·age·sex·MCI만 |
| **제외** | OASIS3 | FOMO OASIS1/2 누수 |

- **핵심 시험**: train Western → **test KDRC** = 우리가 가진 "0.91 LOCO held-KDRC 바"와 직접 정합.
- split: **subject 단위 GroupShuffleSplit / LOCO** (39% 다중세션 누수 차단). 진단 하네스가 이미 subject-grouped 구현.
- 클래스 불균형: probe-train CN:AD ≈ 13:1 → class-weight 필수.

---

## 5. SSL 방법론 연구 viability 판정 (research-advisor 독립 평가 종합)

### 5.1 방어 가능한 novelty (4 후보 중 2 생존)
| 방법론 각도 | 판정 | 근거 |
|---|---|---|
| **biology-guided objective** (SSL loss에 age/morphometry anchor) | ✅ 가장 방어 가능 | 순수 SSL ICC 0.25–0.45 vs biology-guided가 FreeSurfer 0.93 초과(AnatCL 0.97, y-Aware 0.81). **morphometry 바를 넘는 유일하게 알려진 이미지 경로.** [일부 preprint VERIFY] |
| **debiasing-by-design SSL** (site shortcut을 학습 시점에 차단) | ✅ 조건부, 최고 novelty | undecidability thesis와 결합 시 진짜 새로움. 단 평가 순환 주의 |
| population-conditioned SSL (한국/서구 token) | 🟡 함정 | population-id 조건화 = metadata 0.761 shortcut을 합법화. vendor×field×voxel로만 조건화해야 방어되나 그러면 novelty 소멸 |
| site-invariant contrastive (cross-site negative) | ❌ 죽음 | = Dinsdale unlearning의 contrastive 버전. site==population에서 invariance 강제 = biology over-correction. Bayer 2022로 즉사 |

**핵심**: novelty가 **objective(생성) + evaluation protocol(검증) 양쪽**에 걸쳐야 한다. objective만이면 AnatCL incremental.

### 5.2 reviewer가 죽이는 지점 (우선순위)
1. **[치명·최가능] morphometry 0.91 바 미달.** 04/07이 image<morphometry 예측, FOMO25 "scaling unreliable". 못 넘으면 → **audit 프레임이면 생존**(예측대로 큰 backbone도 못 넘음=기여), **SOTA 프레임이면 즉사.** → 프레이밍이 생사.
2. **[치명] self-evaluation 순환.** 우리 진단 하네스로 "내 SSL이 site 덜 배움"을 보이는데 그 metric을 우리가 만듦. traveling subject 0명이라 외부 축 없음. → **FOMO26 official bias/fairness·linear-probe task 또는 공개 travelling-heads(ON-Harmony)로 제3자 교차검증 필수.**
3. **[치명] undecidability 자가당착.** "판정 불가"라며 "내 SSL이 더 낫다" 주장 → 모순. → 단일 probe 불가 / **비순환 probe triple로는 가능**을 method 평가에도 일관 적용, biology probe(0.91 보존)를 유일 판정자로 고정.
4. **[중] 단일 task cherry-pick** → brain-age 등 2nd task로 generality.
5. **[중] 입력 규격 불일치** → §3 공식 레시피 통일로 차단.

### 5.3 판정
- **vanilla MAE/contrastive scratch 단독 = 방법론 논문 아님(단순 적용).**
- **SSL-method 단독 챕터 = high-risk**(컴퓨트 군비경쟁에서 BrainIAC/AMAES팀에 불리).
- **합리적 구조 = audit 主, SSL은 audit의 stress-test.** FOMO300K는 "새 방법 티켓"이 아니라 "내 audit이 큰 backbone에도 성립"을 보이는 탄약.

---

## 6. 단계별 plan (게이트 기반)

```text
STEP 1 [즉시·CPU] T-1 cross-population shortcut-audit 완료 = SSL의 토대
  → confounded regime undecidability + 비순환 probe가 유일 판정자. 토대 없이 SSL 가면 자가당착 직격.

STEP 2 [단기·GPU 추론만·승인] 공개 biology-guided 체크포인트 frozen linear-probe = 의사결정 게이트
  → AnatCL(EIDOSLAB) / y-Aware(DenseNet121@BHB-10K) 공개 가중치 확보 가능.
  → ⚠️ 둘 다 입력이 CAT12 VBM(MNI GM map, ~121×145×121@1.5mm) — 우리 whole-head 파이프라인과 별개 전처리.
     → 게이트용으로 KDRC(held-test) + Western subset에만 CAT12 VBM 실행(SPM 기반, 소수만). 전수 불요.
  → train Western(CAT12) → test KDRC(CAT12) frozen+linear, fs_vol 0.91 바와 비교.
  → 공개 biology-guided조차 0.91 못 넘으면 scratch로 넘을 확률 더 낮음(컴퓨트는 8×B200로 충분하나, 우리 데이터·objective가 그들 대비 우위 없음).
  → 양방향 안전: 넘으면 method 가능성 / 못 넘으면 audit 증거 강화(Plan B).

STEP 3 [조건부·GPU 대량·승인 — STEP2가 ≥0.88일 때만] biology-guided objective scratch SSL
  → FOMO300K(+한국 결정에 따라) scratch + biology anchor objective + confounded-regime validation protocol.
  → vanilla MAE는 baseline으로만. 기여 = objective + protocol 결합.

STEP 4 [선택] FOMO26 official track 제출 = self-eval 순환 방어용 외부 검증(우승 목표 아님).

PLAN B [STEP2가 0.91 한참 밑] SSL-method 챕터 폐기, audit으로 전량 회수.
  → "FOMO scratch SSL도 공개 biology-guided도 confounded regime에서 morphometry 0.91 못 넘는다 +
     그 이유를 진단 하네스로 분해" = FOMO25 'scaling unreliable'을 한국 regime으로 확장한 강한 negative-result audit.
```

---

## 7. Min 승인/결정 필요 (조용히 정하지 않음)

- ✅ **[확정] 한국(AJU/KDRC) = held-out 시험대.** (2026-06-08)
1. **우리 Western(ADNI/NACC/AIBL/A4 ex-OASIS): 사전학습에 포함 vs probe-train 전용** — FOMO300K에 우리 Western을 섞으면 scale↑이나, 그 데이터로 잰 probe는 오염되니 probe-train도 별도 held-out 필요. (FOMO만으로 사전학습 + Western=probe-train이 가장 깔끔)
2. **멀티모달 범위**: 전 모달리티 사전학습 vs T1-only 필터.
3. **STEP 2 먼저 실행 동의** (GPU 추론 + CAT12 VBM 소수 subset) — scratch 베팅의 게이트.
4. **N4 추가 여부** (기본: 레시피대로 미적용).
5. **STEP 3(scratch SSL)·306K 전처리**: long job → command preview 후 별도 승인. (GPU=8×B200 idle 확보)

---

## 8. Validation / 정직성 원칙

- 모든 probe: subject-grouped split, LogReg+RF cross-estimator, shuffle null, biology-probe(0.91) 유일 판정자.
- self-evaluation 순환 방지: 제3자 metric(FOMO26/공개 travelling-heads) 교차검증 없이는 "site 덜 배움" claim 금지.
- 검증하지 않은 것은 "완료"라 하지 않는다(AGENTS.md §7).
- preprint 단독 근거는 [VERIFY] 유지(AnatCL/y-Aware/travelling-heads ICC).

## 9. 참조
- 진단 하네스: `/home/vlm/minyoungi/roi_qc/scripts/embedding_diagnostics.py`
- feasibility dossier: `/home/vlm/minyoungi/research_topic/`
- 선행 실패 정리: `./FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md`
- morphometry 바 실측: `/home/vlm/minyoungi/roi_qc/experiments/harmonization/04_loco_generalization/`
- 외부: FOMO25 findings(arXiv 2604.11679), FOMO26(linear-probe+fairness task), AMAES(arXiv 2408.00640), FOMO300K(arXiv 2506.14432)
