# minyoung3 — 질문-조건부 ROI 라우팅 기반 3D 뇌 MRI VQA (Q-ROUTE) 연구 워크스페이스

## 한눈에

- **무엇을:** T1w 뇌 MRI에서 임상·코호트·ROI 메타데이터를 전부 배제하고 "이미지 텐서 + 질문 ID"만으로 해부학적 위축 증거(해마 부피, 내측측두엽 위축, 뇌실 확장, 해마-뇌실 비율)를 답하는 **image-only ROI-grounded 3D VQA** 벤치마크와 방법을 만든다 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md).
- **왜:** 임상 컨텍스트만으로는 AUC가 우연 수준(0.50–0.55)이 되도록 매칭한 shortcut-통제 벤치마크를 깔고, "어떤 형태의 ROI 조건화가 코호트 간 LOCO에서 실제로 전이되는가"를 분리 검증하기 위함 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md).
- **지금 어디까지:** 2026-06-10 기준 ACCV 타깃 논문 초안 단계. 핵심 주장은 "고해상도 전용 ROI expert로의 질문-조건부 라우팅"이 단일뷰·다중crop concat보다 낫다는 것이나, 이 우위는 **표현(인코더) 품질에 강하게 종속**되며 백본을 키우면 사라진다 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md).
- **주의:** 루트의 README.md / docs/STUDY_DECISION.md는 "2.5D + ROI SSL"을 단일 방향으로 못박은 2026-05-27 문서로, 실제 진행된 3D VQA·라우팅 방향과 더 이상 일치하지 않는다(아래 "폐기·전환" 참조).

## 배경·문제 정의

이 워크스페이스의 **문서상 선언(README)**과 **실제 실험 궤적(Archive/reports + results)** 사이에는 분명한 간극이 있다. 두 층위를 분리해 읽어야 한다.

**문서상 선언(2026-05-27):** 워크스페이스를 "2.5D axial T1w 마스킹 center-slice 표현학습 + ROI 보조경로" 단일 논문 방향으로 한정하고, 과거 3D voxel/PET-transfer 방향은 코드·결과·노트에서 삭제, 사전 인벤토리는 `Official/potato/Reset_Audits/`에 보존한다고 명시 (출처: README.md, docs/PATH_CONVENTIONS.md). 금지 헤드라인으로 "MRI→PET amyloid 직접예측", "full 3D volumetric classifier", "Visual-QC PASS = 해부학적 완벽 정합 주장"을 못박았다 (출처: docs/STUDY_DECISION.md).

**실제 진행 방향:** 2.5D 표현학습은 **성능 병목으로 조기 강등**되고, 연구는 (1) 3D ROI-grounded VQID 벤치마크, (2) 질문-조건부 ROI 라우팅 방법(Q-ROUTE), (3) 표현 품질·백본 스케일 분석으로 재편되었다 (출처: Archive/reports/F04_QROUTE_ACCV_PAPER_PLAN.md, Archive/reports/F04_QROUTE_ACCV_DRAFT.md).

문제 정의의 핵심은 "shortcut 저항성"이다. 모델 입력은 **3D 이미지 텐서 + 질문 ID뿐**이며, consortium/진단/CDR/나이/성별/ROI 수치/percentile은 입력에서 제외된다. `cohort_dx_cdr_age_sex` 매칭 하에서 임상 컨텍스트만으로는 AUC ≈ 우연(0.50–0.55), ROI-oracle은 1.0이 되도록 설계해 "임상 메타로 푸는 지름길"을 차단했다 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md). 질문은 4개(저해마부피 / MTL 위축 / 뇌실 확장 / 저 해마-뇌실 비율), 1:1 균형 (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).

## 데이터

- **라벨 권위:** `/home/vlm/data/preprocessed_official/official_manifest.csv`를 CDR global/CDR-SB/source provenance의 단일 권위로 사용 (출처: docs/context/WORKSPACE_STATE.md). `/home/vlm/data`는 읽기 전용 canonical 데이터로 못박음 (출처: docs/PATH_CONVENTIONS.md).
- **벤치마크 규모(최신 초안 기준):** official N4 manifest 13,022 sessions / 7,231 subjects(전부 QC PASS)에서 매칭 ROI-VQA 벤치마크 19,236 QA rows / 9,278 sessions / 5,601 subjects, 1:1 균형, train-only normative reference + percentile-cutoff 라벨 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md).
- **LOCO 프로토콜:** AJU leave-one-cohort-out — train/val에서 AJU 제외, test = AJU 340 rows / 124 subjects, subject+session 누수 0. 1차 지표는 **macro AUC**(질문별 AUC 평균); pooled AUC는 4개 이질적 질문이 섞여 epoch 간 불안정해 부차 지표로 강등 (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).
- **Expert 캐시(100% QA 커버리지):** global 64³, bilateral MTL crop 80³, ROI-union(MTL+ventricle) 80³ (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).
- **외부 모델링 bar:** 같은 데이터 계열의 형태계측(morphometry+simple-norm) CN/AD LOCO RF AUC가 train-z 0.910 / ICV 0.909로 측정되어 "이미지 방법은 fixed 2.5D를 이겼다는 것만으로는 승격 불가, 0.91 형태계측 bar에 근접/초과하거나 다른 기여(VQA 과제설계)로 프레이밍해야 한다"는 hard reference로 설정됨 (출처: Archive/reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md).

벤치마크 규모는 문서 간 차이가 있다. 스파이크 노트의 LOCO split은 train/val/test = 11,528 / 2,454 / 340(124 AJU subjects)으로, 초안의 전체 19,236행과 다르다 — 스파이크는 부분집합 기반 (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md vs F04_QROUTE_ACCV_DRAFT.md). [VERIFY] 두 수치의 정확한 포함/제외 기준 차이는 매니페스트 원본 미열람으로 미확인.

## 접근·방법

조건화 변형들은 동일한 소형 3D conv 인코더(Conv3d×4, view별)와 공유 answer head를 쓰고 **ROI 정보를 어떻게 조건화하는지만** 다르다 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md):

- **B1 single-view fusion:** global + MTL pooled late fusion.
- **B2 multi-crop concat:** global + MTL + ROI-union pooled concat(라우팅 없음) — 핵심 anchor.
- **B_loc localization:** 질문-조건부 soft 3D attention(global feature map 8³ 그리드), FreeSurfer ROI-occupancy prior로 약지도(λ). test 시 attention은 완전히 학습됨(prior 입력 없음).
- **B2rel relational:** hippo(MTL)·ventricle(ROI) expert 위 학습된 관계 임베딩(비율 질문 동기).
- **Routing(oracle, hard):** 질문 ID가 결정적으로 해당 해부 expert로 라우팅(hippo/MTL→MTL crop, ratio/vent→ROI-union), 라우팅된 증거를 concat에 residual로 더함. 질문 ID는 허용 입력이므로 누수가 아님 (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).
- **Learned router(anatomy-prior):** 학습 게이트 + 약한 anatomy-prior CE(λ=0.3) — 초안이 내세우는 최종 방법.
- **인코더 레짐:** from-scratch / frozen-contrastive(SimCLR, LOCO-safe) / contrastive-init fine-tuned. SSL은 held-out 코호트를 SSL·downstream·val 전부에서 제외 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md).

운영 규율은 강하게 문서화돼 있다: slab-row 랜덤 split 금지, subject/session 누수 0, reconstruction loss로 임상 가치 주장 금지, 새 adapter/loss는 cheap gate 통과 후에만 스케일, run 디렉토리마다 immutable config·manifest hash·command·checkpoint·metrics·RUN_NOTE 보존 (출처: docs/F04_F05_ARTIFACT_AND_AGENT_WORKFLOW.md, docs/plans/2026-05-27_F04_F05_auto_research_master_plan.md).

## 현재 상태와 결과

**확정 ✅** (여러 문서에서 일관되게 재현된 사실)

- **2.5D는 fine 해부 증거에서 병목.** 동일 shortcut-통제 벤치마크에서 2.5D pooled AUC 0.732 vs global 3D 0.835 vs fixed MTL-crop 3D pooled 0.881 vs pretrained frozen multi-view pooled 0.912. 특히 해마(0.658→0.866)·MTL(0.633→0.878)에서 3D crop이 급격히 개선 (출처: Archive/reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md). frozen-fusion pooled AUC는 3 seeds에서 mean 0.9113 / std 0.0006로 안정 (출처: 동 파일).
- **고해상도 전용 ROI crop 추가가 견고한 양의 효과.** B1 0.766 → B2 ~0.815(약 +0.05 macro). 라우팅 우위가 무너진 뒤에도 이 효과는 "토대"로 남음 (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).
- **조건화 이득은 표현 품질에 종속(representation-gating).** from-scratch(노이즈 바닥) / frozen-contrastive(전부 ~0.73대 붕괴, 실측값 B1 0.736·B2 0.737·oracle 0.727) / fine-tuned에서만 라우팅 우위가 유의해짐. SimCLR augmentation(scale ±10%, cutout 18%)이 위축 단서에 대한 불변성을 학습시켜 frozen feature가 위축에 부분적으로 둔감 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §4.3).

**잠정 🟡** (최신 초안 수준 주장, run 원본 artifact는 미열람)

- **Fine-tuned 3D-SSL base에서 라우팅이 baseline 초과(초안 메인 표).** learned router(λ=0.3) macro AUC 0.882±0.012 > oracle 0.871±0.014 > B1 0.837±0.009 > B2 0.812±0.032. 3 코호트 LOCO에서 B2 대비 6개 cohort-router cell 중 5개가 bootstrap 유의(95% CI strictly positive); NACC×learned-router만 경계(CI 하한 −0.001, P=0.965) (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §4.1–4.2). [VERIFY] 이 수치들은 리포트 본문 기준이며, results/ 하위 run JSON은 지시에 따라 미열람.
- **백본을 키우면 라우팅 이득이 사라짐.** router vs B2 = +0.070(0.35M compact) → +0.006(ResNet-10 14M) → −0.005(ResNet-18 33M). 그러나 compact 0.35M routed(0.882)가 ResNet-18 최고값(B1 0.869)보다 높음 → 기여는 "보편적 정확도 향상"이 아니라 **파라미터 효율적 해부 조건화**(작은 인코더가 40–90배 큰 백본을 능가) (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §4.6, ResNet 행은 AJU-only 2 seeds).

**반증 ❌** (가설이 깨졌거나 method-ready 아님으로 종결)

- **From-scratch 인코더에서 hard 라우팅은 concat을 견고하게 못 이김.** 다중 seed(20260610/11/12) macro-AUC 선택 시 oracle mean +0.019, bootstrap 유의 1/3 seeds뿐. 스파이크 1단계의 단일-seed +0.038(oracle 0.859)은 변동성 큰 pooled-val checkpoint의 운빨로 판명(macro 선택 시 동일 seed oracle 0.823). 실재하는 견고한 효과는 정확도가 아니라 **분산 감소**(oracle std 0.008 vs B2 0.020) (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md "Stage 2").
- **가설했던 두 novelty 모듈은 음성.** (1) localization: 약지도가 MTL 0.733→0.761로 약간 올리지만 single-view B1(0.837) 미달 — 거친 8³ global attention이 전용 80³ MTL crop의 fine 신호를 회복 못함. (2) relational: 비율 질문 특이 이득 없고 B1 미달 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §4.4).
- **이미지-측 일반화 levers 대거 음성.** DSBN(vendor / vendor+field), DINOv2 shallow probe(AJU macro AUC 0.616), BN-reset/momentum TTA, style-consistency+boundary-rank — 전부 fixed 2.5D보다는 위지만 primary 3D(pooled AUC 0.879)와 0.91 형태계측 bar 미달. 공통 실패기제: uncertain row를 회복하는 대가로 primary가 맞히던 far-boundary row를 희생 (출처: Archive/reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md).
- **신뢰도/보정 기반 정책·재라벨 분기(2026-06-08) 다수 method-ready 실패.** ventricle 다중-score stacking, baseline-positive veto, ventcrop rescue, answer-weight 재라벨, teacher-localreadout consistency, margin-gated overlay 등은 점추정에서 baseline 3D를 일부 넘어도 subject-level bootstrap이 혼합이거나 코호트 전이(특히 NACC↔AJU)에서 깨짐. 재발 hard case `AJU:ABD-AJ-0089:V1`(뇌실 enlargement false positive), `AJU:ABD-AJ-0237:V2`(ventricle target-space discordance)가 반복적으로 정책을 무너뜨림 (출처: Archive/reports/F04_ACTIVE_ARTIFACT_REGISTRY.md).

**비판적 관찰:** 스파이크 노트의 "deflation"(from-scratch에서 라우팅 비-견고)과 초안의 "robust win"(fine-tuned base에서 견고)은 **서로 모순이 아니라** representation-gating으로 봉합된다 — 같은 모듈이 약한 base에선 노이즈에 묻히고 강한 base에서만 드러난다. 다만 초안의 메인 수치(특히 multi-cohort·backbone)는 리포트 본문 주장 수준이며, 본 분석에서는 results/ 하위 run artifact를 직접 검증하지 않았다.

## 폐기·전환된 시도

- **2026-05-27 리셋:** 과거 3D voxel/PET-transfer/longitudinal 방향을 코드·결과·리포트·노트에서 삭제, 사전 인벤토리만 `Official/potato/Reset_Audits/`에 보존. 명시적 번복 전 재생성 금지 (출처: README.md, docs/PATH_CONVENTIONS.md).
- **2.5D center-slice SSL → 3D ROI VQA로 전환:** README/STUDY_DECISION이 단일 방향으로 못박은 2.5D SSL은 fine 해부 병목으로 조기 강등(2.5D pooled AUC 0.732 vs global 3D 0.835+)되고, 연구는 3D ROI-grounded VQA로 이동 (출처: Archive/reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md). **루트 README.md·docs/STUDY_DECISION.md·docs/context/*는 이 전환을 반영하지 않은 stale 문서**로, 현재 상태는 Archive/reports의 QROUTE 문서를 정본으로 봐야 한다.
- **하드 라우팅을 "the method"에서 강등:** from-scratch 다중-seed deflation 이후 라우팅은 "방법"에서 "안정성/분석 결과"로 강등되었다가, fine-tuned base에서 learned router로 재승격(아직 잠정) (출처: Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md).
- **disease-classification 헤드라인 포기:** 0.91 형태계측 bar를 이미지 분류로 넘지 못해, 발표 경로를 "ROI-grounded three-zone VQA 과제·평가 설계 + 3D-over-2.5D 증거"로 좁힘 (출처: Archive/reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md).

## 남은 과제·다음 단계

- **인코더 레짐 결정:** LOCO-safe contrastive pretrain(global64/mtl80/roi80) 후 frozen·fine-tuned에서 전 변형 3-seed 재평가로 논문 spine 확정 — 모듈이 견고히 이기면 method paper(C3), 아니면 benchmark+ablation+analysis paper로 reframe (출처: Archive/reports/F04_QROUTE_ACCV_PAPER_PLAN.md).
- **다중 코호트 확장:** 현재 AJU/OASIS/NACC 3개 LOCO. 잔여 consortium(ADNI/A4/AIBL/KDRC)은 아직 held-out 미적용; NACC에서 B1 baseline 자체가 강해(0.891) 마진이 작음 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §6).
- **라우터 일반화:** anatomy-prior 없는 fully-unsupervised router는 붕괴 — prior 의존을 줄이고 질문/ROI taxonomy를 늘려 "hand-specified" 비판을 약화 (출처: Archive/reports/F04_QROUTE_ACCV_DRAFT.md §6).
- **미해결 데이터 계약 질문:** A4 AMYLCENT의 centiloid 동등성, OASIS3 canonical centiloid 컬럼, OASIS3 positivity threshold, KDRC tracer/전처리·BCODE↔official-v2 path 연결 (출처: docs/context/OPEN_QUESTIONS.md).
- **검증 권고:** 초안의 메인/멀티코호트/백본 표 수치는 results/ run 원본(summary.json, bootstrap audit)으로 독립 재확인 필요. 본 OVERVIEW는 리포트 본문만 근거로 했다.

## 출처 맵

- README.md — 워크스페이스 선언(2.5D+ROI SSL, 현재 stale)
- docs/STUDY_DECISION.md — study 계약, 허용/금지 헤드라인
- docs/context/WORKSPACE_STATE.md — 라벨 권위·금지 헤드라인
- docs/context/OPEN_QUESTIONS.md — 미해결 데이터 계약 질문
- docs/PATH_CONVENTIONS.md — 디렉토리·삭제·GPU 게이트 정책
- docs/F04_F05_ARTIFACT_AND_AGENT_WORKFLOW.md — run/result 계약, 에이전트 워크플로우
- docs/plans/2026-05-27_F04_F05_auto_research_master_plan.md — 데이터/모델/loss/probe ladder, 승격·kill 규칙
- Archive/reports/F04_QROUTE_ACCV_DRAFT.md — 최신 논문 초안(메인 결과·representation-gating·backbone)
- Archive/reports/F04_QROUTE_ACCV_PAPER_PLAN.md — ACCV 계획·contribution·risk register
- Archive/reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md — 라우팅 스파이크·from-scratch deflation
- Archive/reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md — 2.5D vs 3D 병목 진단
- Archive/reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md — 형태계측 0.91 bar, 음성 levers(DSBN/DINOv2/BN-TTA)
- Archive/reports/F04_ACTIVE_ARTIFACT_REGISTRY.md — 2026-06-08 신뢰도/보정/재라벨 분기 다수(대부분 음성/진단)

---
> 자동 생성: LLM 에이전트가 `minyoung3` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-13.
