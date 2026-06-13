# 3D ROI VQA — 완전 실패/Novelty 분석 (post-mortem)

작성: 2026-06-13. 범위: 2026-05-27 ~ 06-13의 F04 프로젝트 전체 (image-only 3D MRI ROI-grounded
VQA). 본 문서는 RESEARCH_LOG.md / SPEC.md / ACCV/ / reports/ / results/ 의 실제 산출물과,
**본 분석에서 독립 재현·재계산한 검증치**에 근거한다. 추측은 [추정] 으로, 검증 불가 인용은
[VERIFY] 로 표기한다.

> 결론 한 줄: **이 task(FreeSurfer-percentile VQA)는 구조적으로 top-tier vision novelty가
> 불가능하다.** 근본 원인은 *2단계 circularity* — (i) 정답 레이블이 morphometry의 threshold라
> morphometry가 완전 oracle(AUC→1.0)이고, (ii) grounding GT가 FreeSurfer mask인데 brain-extraction
> +conform 후 해부구조가 공간적으로 trivial해 **상수 prior가 모든 해상도에서 grounding을 이긴다.**
> 모든 "특수 메커니즘"은 데이터에 의해 차례로 deflate되었다. 본 분석은 이 negative들을 독립
> 재현했고(거짓 아님), 동시에 **non-circular 탈출구(amyloid 등 PET/유전 레이블)**가 데이터에
> 실재함을 정량 확인했다.

---

## 0. 독립 검증 (생성≠검증 원칙)

로그를 맹신하지 않고, 핵심 negative 2건과 novelty의 gating 1건을 직접 재현/재계산했다.

| 검증 항목 | 방법 | 결과 | 판정 |
|---|---|---|---|
| Grounding circularity (C2 철회 근거) | `scripts/control_circularity.py` 를 저장된 `test_attn.npz`+prior로 재실행 | AJU static 0.807 vs learned 0.790 (Δ−0.016), OASIS Δ−0.006, NACC Δ+0.012; cos(attn,prior)=0.95–0.97, per_cell_std=0.0005 | **재현됨**. 학습 attention은 상수 prior를 못 이김 → grounding 주장 철회는 정당 |
| Routing deflation | EXPERIMENT_LOG / PAPER_PLAN의 multi-seed 표 교차 확인 | 단일-seed +0.038 → 3-seed +0.019(sig 1/3); 진짜 효과는 분산 감소 | **로그와 일치**(아래 §2.4) |
| Novelty gating: amyloid가 non-circular인가 | `scripts/analyze_amyloid_baselines.py` 신규 작성, real_final manifest로 baseline AUC 재계산 | morphometry가 amyloid에 대해 **oracle이 아님**(within-cohort 0.709, LOCO 0.665) | **확인**: circularity 없음, 탐색할 headroom 존재(§4) |

---

## 1. Task 정의와 치명적 결함

- **Task**: image tensor + question id 만 입력. 4개 이진 질문(낮은 해마부피 / MTL 위축 / 뇌실 확대 /
  낮은 해마-뇌실 비). **정답 레이블 = train-only-CN 정규분포 기준 ROI 잔차 percentile의 cutoff**
  (≤0.10 또는 ≥0.90). 즉 `label = threshold(FreeSurfer_morphometry(image))`.
- **치명적 결함(circularity-1)**: 레이블이 morphometry로 만들어졌으므로 morphometry는 정의상
  완벽한 oracle이다. SPEC에도 "ROI-oracle = 1.0" 명시. 따라서 이미지 모델이 할 수 있는 최선은
  *FreeSurfer를 모사*하는 것이고, 천장은 morphometry의 재현(LOCO ~0.91)이다. **vision이 새로
  발견할 신호가 원리적으로 없다.**
- shortcut control(clinical-context AUC≈chance)은 잘 되어 있어 "이미지를 본다"는 점은 보장되지만,
  그 이미지가 가리키는 정답 자체가 이미지에서 나온 도구의 출력이라는 순환은 통제 대상이 아니다.

---

## 2. 시도한 모든 방향 (빠짐없이) 과 실패/무-novelty 이유

### 2.1 표현/해상도 기반선 (긍정이지만 novelty 아님)
| 방향 | 결과 | 판정 |
|---|---|---|
| 2.5D slab vs 3D | 2.5D pooled 0.732 ≪ 3D MTL-crop 0.881 (hippo +0.208, MTL +0.245) | 3D 승. **기지 사실의 재확인**, novelty 아님 |
| single-view(B1) vs multi-crop concat(B2) | from-scratch 다중seed: B1 0.787±0.017, B2 0.815±0.020 (B2>B1 mean +0.028, sig 1/3) | 고해상 ROI crop 추가가 유일하게 견고한 +. 그러나 "crop 더 넣기"는 방법 novelty 아님 |
| DINOv2(2D 자연영상 SSL) 얕은 probe | AJU macro 0.616 (primary 0.879 대비 −0.263) | **음성 대조**: 2D 자연영상 feature는 3D MTL 형태 신호 결여 |
| 3D foundation model | 로컬에 3D 의료 SSL 가중치 없음 → 미수행 | 인프라 부재 |

### 2.2 라우팅 계열 (핵심 가설 — 전부 deflate)
| 변형 | 결과 | 판정 |
|---|---|---|
| hard anatomical routing (oracle, question-id) | 단일seed 0.859 → **macro-선택 다중seed 0.835±0.008, vs B2 +0.019, sig 1/3** | 단일seed 0.859는 변동성 큰 pooled-val 체크포인트의 운빨. 진짜 효과는 **분산 감소**(std 0.008 vs 0.020), 평균 정확도 아님 |
| 자유학습 gate (no prior) | gate가 단일 "안전" expert(roi-union)로 collapse, MTL 디테일 상실(0.688 vs oracle 0.820) | **FAIL**: 자유 gate는 올바른 per-question one-hot을 발견 못함 |
| anatomy-prior 지도 gate (λ=0.3/1.0) | 동일한 올바른 one-hot으로 수렴해도 정확도 더 낮음(0.80/0.78 < hard 0.859). λ↑ 일수록 악화 | **반직관 핵심**: 같은 라우팅, 다른 정확도. 학습 자체가 답안 task를 degrade |
| Gumbel hard(이산) 라우팅 | no-prior가 1 expert로 collapse (0.840) | **FAIL** |
| (fine-tuned base 재평가) learned router λ=0.3 | 0.882 (vs B2 +0.070), 3-cohort LOCO에서 5/6 cell bootstrap-유의 | 좋아 보였으나 → §2.5에서 plain attention과 동급으로 deflate |

핵심: 라우팅은 "the method"에서 "stability/analysis 결과"로 격하. 하드/소프트/이산 모든 형태가
무너졌고, 살아남은 효과는 분산 감소뿐.

### 2.3 학습형 novelty 모듈 (둘 다 음성)
| 모듈 | 결과 | 판정 |
|---|---|---|
| 학습형 질문조건 3D localization (weak ROI-mask sup, B_loc) | fine-tuned base 0.827, **single-view B1 0.837 미달**; MTL 0.733→0.761 소폭↑이나 hard 0.871엔 한참 못미침 | **FAIL**: coarse 8³ global attention은 dedicated 80³ MTL crop의 미세 신호 복원 불가 |
| 관계형 cross-ROI(ratio hook, B2rel) | 0.832; B1(0.837) 미달, ratio-질문 특이 이득 없음 | **FAIL** |

### 2.4 백본 스케일링 (gain 소멸)
| backbone | params | router vs B2 |
|---|---:|---:|
| compact | 0.35M | **+0.070** |
| ResNet-10 | 14M | +0.006 |
| ResNet-18 | 33M | **−0.005** |
라우팅 이득이 백본 크기에 따라 단조 소멸. 큰 백본은 질문별 해부 정보를 이미 포착 → 명시적
라우팅 불필요. (남은 긍정: 0.35M routed가 33M ResNet-18보다 좋음 → "parameter-efficiency"
서사. 단 ResNet 행은 AJU-only·2-seed 한계.)

### 2.5 라우팅 vs 평범한 attention (gate 잉여)
V1 실험: plain attention 0.876 vs router 0.882 (**Δ+0.005**). → "라우팅 게이트"의 특수성이
사실상 없음. attention만으로 동등.

### 2.6 데이터-스케일 축
frac 1.0/0.3/0.1 에서 router-B2 이득 +0.070/+0.076/+0.012 → 30%에서 정점, 10%에서 붕괴.
저데이터 우위 서사도 견고하지 않음.

### 2.7 Grounding 축 (재구성 시도 → circularity로 철회, **본 분석 재현됨**)
- 처음: loc-sup attention의 mass-in-ROI 0.78 (no-sup 0.20, Grad-CAM 0.14, uniform 0.03) →
  "morphometry가 못하는 grounding 축" 으로 reframe.
- Reviewer-2(critic) 지적: attention이 **고정 population prior(맵 2개뿐)** 로 지도되고, 같은
  FreeSurfer mask 군에 대해 정합된 뇌에서 평가됨 → registration artifact 의심.
- **결정적 대조(재현)**: 상수 prior(모든 피험자 동일) vs 학습 attention, paired mass-in-ROI →
  static 0.807/0.836/0.736 vs learned 0.790/0.830/0.748. **학습이 상수를 못 이김.**
  cos(attn,prior)=0.95–0.97, per_cell_std=0.0005 → 학습 attention은 prior의 복사본.
- 해상도 sweep(8³/16³/32³): 상수 prior가 모든 격자에서 높게 유지(hippo 0.80/0.84/0.73 등).
  공간은 conform-native(192×224×192 동일 affine), 피험자별 ROI centroid 산포 3.3–3.9mm <
  구조 크기 → **conform이 심부 구조를 수 mm로 co-locate해 상수가 공간 grounding을 이김.**
- 판정: **C2(grounding) 철회**. 이것이 circularity-2.

### 2.8 신뢰도/불확실성/abstention/score-meta 계열 (~28 스크립트, 전부 bootstrap 미통과)
| thread | 결과 | 판정 |
|---|---|---|
| soft-label τ (0.03/0.05) local pretrain | AJU↑ OASIS↓ (코호트-ROI-τ tradeoff) | 비-보편, 미승격 |
| 질문별 τ hybrid | calibration↑ 이나 ranking(AUC) 붕괴(0.874<0.905) | calibration-편향, 표현 개선 아님 |
| fusion-head soft target | AUC 무변, OASIS LOCO 악화 | 무효 |
| staged unfreeze | in-split +0.003 이나 AJU LOCO −0.013 | 도메인 brittleness |
| hard boundary 제외 / crop 기하 변형 | AUC↑처럼 보이나 balanced-acc 붕괴(0.531) / 미세변별 상실 | calibration 파괴 |
| intensity aug / perturbation consistency | flip-rate↓ 이나 AUC↓ | 유용 형태신호까지 지움 |
| DSBN(vendor/field) | AJU −0.031 ~ −0.059 | 음성: DG는 BN통계 문제 아님 |
| BN test-time adaptation | AUC 무변(−0.001) | 핵심실패는 BN 아님 |
| score-only meta 3-zone | uncertain recall↑(+0.117) 이나 far-positive↓(−0.115), zone-bacc CI 0 횡단 | 미통과 |
| recall-constrained meta / dual-target policy | 점추정 +0.044 이나 bootstrap CI 0 횡단(작은 AJU n=96 변동) | **반복 실패: 작은 cohort 점추정 변동, bootstrap 미통과** |
| teacher-consistency / reliability head | 점추정 소폭↑, bootstrap 미통과, 작은 val 과적합 | 미통과 |
| ventricle 전용 audit(~6) | 뇌실 AUC 0.979로 포화·견고 | 병목 아님(병목은 hippo/MTL·AJU) |

공통 실패모드: **작은 held-out cohort에서의 점추정 변동을 bootstrap이 전부 걷어냄.** 라벨-경계
노이즈가 바닥(floor)이고, 어떤 head/loss/decision-policy도 이 floor를 못 넘음.

### 2.9 "Adjusted target" 재라벨링
age/sex/head-size/cohort 보정 잔차 percentile로 재라벨. 3D adjusted 0.869. 그러나 **raw-visible
3D를 adjusted로 재라벨한 대조가 0.881로 거의 동등** → 이득은 모델이 아니라 라벨 평활(label
smoothing) 효과. 또한 MTA visual-rating 앵커 부재로 "임상 타당성"은 미해결. 방법 novelty 아님.

### 2.10 Brain-age + cross-vendor DG probe
morphometry age MAE 4.2–4.5yr / r~0.5. 학습 3D CNN(2.4k CN train): test MAE 4.58–4.63 →
morphometry와 무승부/패, 과적합(val4.0→test4.6). 한계: cache가 CN-age의 44%만 커버, 노년
좁은 age range(70.6±7.0)가 MAE를 ~4로 cap, 분야 과밀. **음성**.

---

## 3. Novelty가 없는 이유 — 메타 패턴

1. **2단계 circularity가 천장과 바닥을 동시에 고정한다.** 정답=threshold(morphometry)이므로
   천장은 morphometry 재현(≈0.91)이고, grounding GT=FS mask + conform 평탄화이므로 바닥은
   상수 prior다. vision이 들어갈 틈이 위아래로 막혀 있다.
2. **모든 특수 메커니즘이 차례로 deflate.** 라우팅(=attention, +0.005), 큰 백본(이득 소멸),
   Gumbel(collapse), localization/relational(B1 미달), grounding(상수에 패), score-meta(bootstrap
   미통과). 어느 하나도 견고한 양성 없음.
3. **신호 vs 노이즈 floor.** from-scratch 노이즈(std 0.02–0.03)가 모듈 효과크기(0.02–0.05)를
   덮고, 라벨-경계 노이즈가 정확도 floor를 만든다. 즉 효과가 있어도 측정이 안 되거나, 측정돼도
   라벨 품질에 막힌다.
4. **데이터 강점(다중코호트/다중벤더/LOCO/shortcut-control)은 medical-imaging 벤치마크용**
   이지 pure-vision method paper의 동력이 아니다.

→ **이 task/data에서 ACCV-main급 vision-method novelty는 구조적으로 불가.** (이 결론은
정직하며, 본 분석에서 핵심 negative를 재현해 거짓이 아님을 확인했다.)

---

## 4. 탈출구 — Non-circular 레이블이 데이터에 실재한다 (정량 확인)

`official_manifest_full_n4_real_final.csv`(2026-06-10, SPEC가 참조하던 n4보다 최신)는 **이미지에서
유도되지 않은** 레이블을 담는다. 이것이 circularity를 깨는 유일한 길이다.

### 4.1 가용성 (본 분석 재계산)
- **Amyloid PET 양성/음성(이진, 양 클래스 존재; A4는 전부 양성이라 제외)**: OASIS 1048(31% +),
  NACC 515(39% +), KDRC 534(68% +), AJU 1286(34% +) → **합 3,383 세션 / 2,407 피험자 / 4 코호트.**
  추가 연속값: centiloid(OASIS/NACC), SUVR(A4 1811/KDRC 481) → cross-tracer 조화 가능.
- **APOE e4n(유전)**: 3,134 세션(0:5466 / 1:2581 / 2:553).
- **인지(MMSE/MoCA)·CDR-SB(중증도)**: 광범위.
- **종단(longitudinal_voxel_manifest_v0)**: 18,868행, scan_date/cdrsb 시계열 → 진행/전환 예측 가능
  (단 전환자 수 적어 data-starved [추정], 별도 검증 필요).
- **Korean multimodal**: apoe/amyloid + 혈액검사 + 동반질환(dm/htn/dyslipidemia).

### 4.2 Gating test — morphometry가 oracle인가? (본 분석 재계산, subject-level split)
| baseline | within-cohort 5-fold CV AUC | strict LOCO mean AUC |
|---|---:|---:|
| age 단독 | 0.611 | 0.596 |
| APOE e4n 단독 | 0.645 | 0.634 |
| age+APOE (clinical bar) | 0.720 | 0.703 |
| morphometry(FS ROI) | **0.709** | **0.665** |
| morphometry+age+APOE | **0.742** | 0.712 |

→ **morphometry는 amyloid에 대해 oracle이 아니다(0.71, FreeSurfer-VQA의 1.0과 대조).**
circularity 없음. **탐색할 진짜 gap이 존재**한다: 이미지가 morphometry+age+APOE(≈0.74) 너머
amyloid 신호를 갖는가? within→LOCO에서 morphometry가 0.709→0.665로 떨어짐 = **cross-site
일반화 gap**(미해결 문제) 도 정량 확인.

### 4.3 문헌 현실 점검 (literature-scout, 정직한 바)
- 가장 엄밀한 다중코호트 T1-only amyloid: **AUC≈0.62** (Kim et al., *AJNR* 2025, n=4058).
  단일-ADNI는 ~0.86이나 dx 혼합으로 부풀려짐. → 본 분석 baseline(within 0.71, LOCO 0.665)이
  이 범위와 정합 → **leakage 징후 없음.**
- 합의: MRI는 age+APOE 너머 **modest**하게만 기여, 주로 atrophy 경유. CN/preclinical에서 가장 약함.
- **3D MRI VQA로 분자/유전 status를 묻는 선행연구는 없음**(M3D=스케일, AutoRG-Brain=grounding,
  mpLLM=MoE; 전부 해부/소견/리포트). → molecular-status VQA framing은 진짜 gap [VERIFY: forward-
  citation sweep 필요].
- **함정**: cross-tracer 0.95–0.98(AmyloidPETNet)은 **PET 입력**이지 MRI 아님 — 절대 혼용 금지.

---

## 5. 권고 방향 (정직한 위험 고지 포함)

**채택 후보: image-only 3D-MRI molecular-status VQA — amyloid 중심, multi-cohort/multi-tracer LOCO.**
이는 circularity를 깨고(amyloid=PET 독립 측정), VQA framing의 진짜 gap이며, 팀의 기존 강점
(shortcut-control·다중코호트 LOCO·age/APOE/site 교란 통제)을 그대로 활용한다.

방어 가능한 기여(정확도-최대화 아님):
- **C1 framing**: 분자/유전 status를 3D MRI VQA로 묻는 첫 시도(해부 mimicry 탈피).
- **C2 generalization 벤치마크**: cross-cohort/cross-tracer(PIB/FBP/FBB/visual) LOCO — 문헌상 open.
- **C3 incremental-information**: MRI가 age+APOE+morphometry 너머 amyloid 신호를 갖는가?
  dx 층화(CN 별도 보고), clean null. **양성이든 음성이든 well-posed 발견.**

**정직한 위험(반드시 사용자에게 고지)**:
- 천장이 낮다(절대 AUC ~0.65–0.75 [추정]). 이미지가 age+APOE를 크게 못 넘을 수 있음 → 그 경우
  결과는 "엄밀한 음성/벤치마크" 이며 "화려한 novelty" 아님.
- age leakage(amyloid가 나이와 공변) 통제가 필수: age-only baseline·age-matched/잔차 보고.
- cross-tracer 라벨 노이즈, dx 불균형, site/scanner 교란 — 전부 사전 통제·보고 필요.
- A4(전부 양성)는 이진 분류 제외(site shortcut). KDRC는 APOE/age 결측 → clinical bar에서 빠짐.

**탈락/후순위**:
- FreeSurfer-percentile VQA(현행): 더 이상 vision novelty 탐색 불가 → 종료, 벤치마크/분석
  자산으로만 보존.
- 종단 진행/전환 예측: 임상 가치 최고이나 전환자 data-starved → 별도 N 검증 후 판단.
- APOE-from-MRI 단독: 깨끗하나 신호 약해 near-chance 가능성 → C3의 보조 축으로만.

---

## 6. 다음 단계 (이 문서 이후)
1. 이전 산출물·ACCV draft를 `Archive/` 로 분리(§아카이브).
2. amyloid VQA용 cache-coverage·age/dx 교란 구조 정밀화, image cache 준비 상태 확인.
3. **GPU 실험은 사용자 사전승인 후**: image-only 3D 모델이 §4.2 바(0.71–0.74)를 LOCO에서
   넘는지, age/APOE/site 통제 하에서, dx 층화로 측정. leakage·거짓결과 금지.
4. 각 결과를 research-critic/code-auditor로 독립 검증 → GAP 반복.
