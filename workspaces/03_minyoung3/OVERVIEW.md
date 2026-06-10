# minyoung3 — 3D 뇌 MRI ROI-grounded VQA와 질문조건부 라우팅 (Q-ROUTE)

## 한눈에

- 이 워크스페이스는 한 줄로 "**이미지+질문 ID만 입력**하는 shortcut-내성 3D T1w MRI ROI-근거 VQA(4개 해부 질문)를 만들고, 어떤 형태의 ROI 조건화가 실제로 도움이 되는지를 LOCO·다중시드로 가린다"는 방향으로 수렴했다 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`).
- 처음 선언했던 "2.5D 마스킹 center-slice SSL + ROI 보조경로 → CDR 분류" 계획은 실험을 거치며 두 번 전환됐다: 2.5D→3D, 그리고 질병분류→VQA 과제/벤치마크. `README.md`와 `docs/context/WORKSPACE_STATE.md`의 2.5D·F05 ROI 프레이밍은 이 전환 이전의 오래된 문서로, 현재 방향과 불일치한다 (출처: `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md`, `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`).
- 지금 확정된 사실은 "**3D가 2.5D보다 미세 내측측두 질문에서 크게 우월**"(2.5D pooled AUC 0.732 vs 3D 0.835~0.912)과 "**고해상도 전용 ROI crop이 도움**"이라는 두 가지다. 나머지 다수 방법(DSBN·2D SSL·BN-TTA·style consistency·스칼라 오버레이 등)은 baseline을 부트스트랩으로 못 이긴 음성 결과로 정리됐다 (출처: `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md`, `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md`).
- 현재 잠정 리드는 "**질문→해부 ROI 전문가로의 학습형 라우터**(anatomy-prior, λ=0.3)"이며 fine-tuned 3D-SSL base에서 macro AUC 0.882로 concat baseline을 +0.070 앞선다 — 단, 작성 중 초안이고 단일 SSL 시드·3개 코호트 한정이며 초안 자체에 내부 모순이 있다(아래 [VERIFY]) (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`).
- 목표 발표처는 ACCV(tier-2 CV)로, SOTA 질병분류가 아니라 "VQA 과제·벤치마크 + 어떤 조건화가 전이되는가"를 기여로 잡는다 (출처: `reports/F04_QROUTE_ACCV_PAPER_PLAN.md`).

## 배경·문제 정의

워크스페이스의 명시적 경계는 보수적이다. `README.md`와 `docs/STUDY_DECISION.md`는 "재현 손실이 임상 표현 품질을 증명한다", "Visual-QC PASS가 ROI 해부학적 완벽성을 증명한다", "MRI가 PET amyloid를 robust하게 예측한다", "3D 볼륨 분류기" 같은 헤드라인 주장을 **금지**한다 (출처: `docs/STUDY_DECISION.md`, `README.md`). 2026-05-27에 과거 PET/종단/3D voxel 방향은 코드·결과·노트에서 삭제됐다. README와 WORKSPACE_STATE.md는 삭제 전 인벤토리가 `Official/potato/Reset_Audits/`에 보존됐다고 명시하나, 해당 디렉토리는 디스크에서 확인되지 않는다 [근거부족] (출처: `README.md`, `docs/context/WORKSPACE_STATE.md`).

핵심 문제는 두 단계로 좁혀졌다. (1) T1w MRI에서 **shortcut에 강인한** 해부 근거 추출 — 임상/코호트/CDR/나이/성별/ROI 값을 입력에서 모두 제외하고 이미지+질문 ID만으로 답하게 한다. (2) 그 위에서 **어떤 ROI 조건화가 코호트 간 전이되는가**를 LOCO로 가린다 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`). 외부 모델링 기준선이 엄격하게 걸려 있다: 형태계측(morphometry)+단순정규화의 CN/AD LOCO RF 평균 AUC 약 0.91(train-z 0.910, ICV 0.909)이 "이미지 방법이 질병분류 헤드라인을 주장하려면 넘어야 할 바"로 설정돼, 이미지 방법을 "2.5D보다 낫다"만으로 승격하지 못하게 한다 (출처: `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`). 이 바를 못 넘는다는 판단이 질병분류에서 VQA 과제 설계로의 전환을 강제했다.

## 데이터

- **라벨 권위**: `/home/vlm/data/preprocessed_official/official_manifest.csv`(읽기 전용)을 CDR global/CDR-SB/provenance의 단일 출처로 사용 (출처: `docs/context/WORKSPACE_STATE.md`). `/home/vlm/data`는 쓰기 금지 canonical 데이터.
- **벤치마크 규모**: official N4 manifest 13,022 세션 / 7,231 피험자(전부 QC PASS)에서 파생한 matched ROI-VQA 벤치마크 19,236 QA행 / 9,278 세션 / 5,601 피험자, 4개 세션 질문, 1:1 균형 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`). 별개로 source-linked guideline QA 데이터셋은 96,376행 규모이며 임계값은 `threshold_validity = research_proxy_not_clinical`로 표시된 train-reference 백분위 프록시다(임상 검증 임계값 아님) (출처: `reports/F04_GUIDELINE_GROUNDED_QA_EVIDENCE.md`).
- **4개 질문**: 낮은 해마 부피 / 내측측두엽(MTL) 위축 / 뇌실 확장 / 낮은 해마-뇌실 비율 (출처: `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md`). 표준화/진단/amyloid·tau/치료권고 질문은 명시적으로 금지 (출처: `reports/F04_GUIDELINE_GROUNDED_QA_EVIDENCE.md`).
- **코호트 / 프로토콜**: AJU·OASIS·NACC·ADNI·A4·AIBL·KDRC가 등장하며 평가는 **subject-level leave-one-cohort-out(LOCO)**. AJU LOCO 테스트는 340 QA행 / 124 피험자, subject·session 누출 0 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`). 현재 held-out 완료는 AJU/OASIS/NACC, ADNI/A4/AIBL/KDRC는 미실시 (출처: 동일 §6).
- **3D 전문가 캐시**(전부 100% 커버리지): global 64³, bilateral MTL crop 80³, ROI-union(MTL+뇌실) 80³ (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md`).
- **shortcut 통제**: `cohort_dx_cdr_age_sex` 매칭 하에서 임상-맥락만으로의 AUC가 우연(0.50–0.55) 수준이고 ROI-oracle은 1.0 — 즉 라벨이 이미지 근거를 강제한다 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md`).

## 접근·방법

모든 변형은 view당 동일한 소형 3D conv encoder(Conv3d×4)와 공유 answer head를 쓰고, **ROI 정보를 어떻게 조건화하는가만** 다르다 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md` §3).

- **B1 single-view**: global + MTL pooled late-fusion.
- **B2 multi-crop concat**(앵커): global + MTL + ROI-union pooled concat, 라우팅 없음.
- **B_loc localization**: 질문조건부 soft 3D attention(8³ global grid), 인구 ROI-occupancy prior(등록된 FreeSurfer mask, train-only)로 약지도. 테스트 시 attention은 완전 학습.
- **B2rel relational**: hippo(MTL)·ventricle(ROI) 전문가에 대한 학습형 관계 임베딩(비율 질문 가설).
- **Routing(oracle/learned)**: 질문 ID가 해부적으로 관련된 고해상도 ROI 전문가로 라우팅(해마/MTL→MTL crop, 비율/뇌실→ROI-union). 라우팅된 근거는 concat에 residual로 더해진다. 게이트가 허용 입력인 질문 ID만의 결정적 함수이므로 누출이 아니다 (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md`).
- **Encoder 레짐**: from-scratch / frozen-contrastive(SimCLR, LOCO-safe, AJU 제외) / contrastive-init fine-tuned. 이 레짐 축이 결과 해석의 핵심이다(아래 representation-gating).

평가는 macro AUC(질문별 평균)를 1차 지표로 쓴다 — pooled AUC는 4개 이질 질문을 섞어 epoch마다 불안정하기 때문 (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md`). 유의성은 subject-level 부트스트랩.

## 현재 상태와 결과

**✅ 확정 — 3D ≫ 2.5D (미세 해부 질문)**
같은 matched 벤치마크·동일 금지입력 정책에서, 단일 시드 진단(2026-06-03): 2.5D pooled AUC 0.732 → global 3D 0.835 → fixed MTL-crop 3D pooled 0.881(평균 질문 AUC 0.903) → pretrained frozen multi-view 3D pooled 0.912(bacc 0.824). MTL-crop은 해마/MTL 질문에서 특히 강하고(MTL 0.633→0.878, 해마 0.658→0.866), frozen-fusion은 3시드에서 pooled AUC 0.9113±0.0006로 안정적이며, MTL feature 제거 시 해마/MTL AUC가 −0.591/−0.558 붕괴해 해부적 라우팅을 지지한다 (출처: `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md`). 주요 코호트 LOCO도 in-split과 근접(ADNI 0.922 vs 0.918, A4 0.939 vs 0.944, NACC 0.909 vs 0.903, OASIS 0.920 vs 0.924, AJU 0.848 vs 0.851)해 단순 코호트 암기 설명을 약화시킨다 (출처: 동일).

**✅ 확정 — 고해상도 전용 ROI crop이 도움 (조건화의 실효 성분)**
from-scratch 3시드에서 ROI-union 80³ crop 전문가 추가만으로 B1 0.766 → B2 약 0.815(약 +0.05 macro). 라우팅 deflation 이후에도 이 효과는 "robust한 양성 발견"으로 남았다 (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md` §Stage 2).

**❌ 반증/음성 — 라우팅 단일시드 우위는 재현 실패, 다수 표현·정규화 기법은 baseline 미달**
- Stage-1 단일시드의 oracle routing +0.038(macro 0.859)는 **재현 실패**. macro 선택으로 같은 시드를 다시 보면 0.823이고, 3시드 평균 oracle 우위는 +0.019, 부트스트랩 유의는 3시드 중 1시드뿐. 라우팅의 robust한 효과는 평균 정확도가 아니라 분산 감소(oracle std 0.008 vs B2 0.020)로 재해석됐다 (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md`).
- 외부 형태계측 바(0.91) 미달 및 primary 3D 대비 부트스트랩 실패로 정리된 음성 시도들: style consistency+boundary rank(pooled AUC 0.853), DSBN vendor/vendor+field(pooled AUC 0.848/0.820, primary 대비 부트스트랩 유의하게 나쁨), DINOv2 2D SSL shallow probe(AJU macro 0.616, MTL 0.366), BN-TTA(AUC·far-boundary 개선 없음) (출처: `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`).
- 뇌실 단일-ROI 라인의 다수 스칼라 오버레이/브리지/신뢰도 게이트/보정 시도는 대부분 `ACTIVE_NEGATIVE`로, validation에서 고른 정책이 AJU 테스트에서 no-op이 되거나 재발 위양성(`AJU:ABD-AJ-0089`)을 못 막는 패턴이 반복됐다 (출처: `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md`).
- B_loc(soft localization)·B2rel(relational)도 fine-tuned base에서 single-view B1(0.837)을 못 넘어 음성 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md` §4.4).

**🟡 잠정 — fine-tuned base에서 학습형 anatomy-prior 라우터가 현재 리드**
fine-tuned 3D-SSL base, AJU LOCO, 3시드 macro AUC: B1 0.837±0.009, B2 0.812±0.032, B_loc 0.827±0.010, B2rel 0.832±0.004, oracle(hard) 0.871±0.014, **learned router(λ=0.3) 0.882±0.012**(B1 대비 +0.045, B2 대비 +0.070, 모든 시드 양성, 모든 질문 개선: MTL +0.120, 해마 +0.095). 학습 게이트가 올바른 해부 라우팅으로 수렴(질문별 게이트 질량 >0.999)해 "수작업 라우팅" 반론을 제거한다고 주장 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md` §4.1).
다중코호트 LOCO(각 코호트를 SSL 포함 전 단계에서 제외)에서 learned router는 AJU/OASIS/NACC 모두에서 B2를 모든 시드에서 이기고(부트스트랩 95% CI가 6셀 중 5셀에서 엄격히 양수; NACC만 경계 P=0.965) (출처: 동일 §4.2).
**representation-gating**(왜 base가 중요한가): from-scratch는 노이즈 바닥(std 0.02–0.03)이 모듈 효과보다 커서 분리 불가, frozen-contrastive는 모두 ~0.73으로 붕괴(SimCLR scale±10%/cutout 18% 증강이 위축 단서를 지움), fine-tuned에서만 라우팅 우위가 유의해진다 (출처: 동일 §4.3).

이 두 그룹([Q-ROUTE_SPIKE]의 deflation과 [ACCV_DRAFT]의 부활)은 모순이 아니라 **레짐 차이**다 — deflation은 from-scratch 인코더, 부활은 fine-tuned base. 다만 초안 검증 상태에 주의가 필요하다(아래).

[VERIFY] `reports/F04_QROUTE_ACCV_DRAFT.md` 머리말은 "모든 주장은 OASIS/NACC 재현 전까지 AJU-LOCO 한정"이라 적으면서도 §4.2에 OASIS/NACC LOCO 수치와 부트스트랩을 이미 채워 두고 abstract는 "세 코호트 모두 모든 시드 양성"을 단언한다. 머리말 캐비엇이 stale인지, OASIS/NACC 수치가 잠정인지가 문서 내에서 불일치하므로 별도 확인 필요.

[VERIFY] `docs/figures/` 디렉토리가 디스크에 존재하지 않는다. `reports/F04_QROUTE_ACCV_DRAFT.md`에 "생성된 Fig."로 나열된 `qroute_architecture.png`, `qroute_multicohort.png`, `qroute_repr_gating.png` 세 파일 모두 디스크에서 확인되지 않음 — 초안에 경로만 명시돼 있고 실제 생성은 미완료 상태다.

## 폐기·전환된 시도

- **삭제(2026-05-27)**: 과거 PET/종단/3D voxel 방향 일체. `README.md`와 `WORKSPACE_STATE.md`는 인벤토리가 `Official/potato/Reset_Audits/`에 보존됐다고 명시하나, 해당 디렉토리는 디스크에서 확인되지 않는다 [근거부족] (출처: `README.md`).
- **2.5D → 3D 전환**: 초기 핵심 SSL(5-slice slab → 마스킹 center-slice 재구성)은 3D 진단에서 미세 해마/MTL 신호가 부족함이 드러나 "더 낮은 참조 바"로 강등. `README.md`와 `docs/STUDY_DECISION.md`의 2.5D·F05 ROI 프레이밍은 현재 방향보다 오래된 문서다 (출처: `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md`).
- **질병분류 → VQA 전환**: 이미지 분류기가 형태계측 0.91 바를 못 넘어, 헤드라인을 ROI-grounded three-zone VQA/과제/평가로 재구성 (출처: `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md`).
- **결과 디렉토리 정리 정책**: Active Artifact Registry는 "이전 `results/` 산출물은 사용자 요청으로 제거, `20260531_235859_roi_evidence_dataset`만 활성 데이터셋으로 취급"이라 명시. 단 디스크에는 다수 `results/f04_roi_evidence_encoder/2026060*` 실행 디렉토리가 여전히 존재하므로, 이 정책 문구와 실제 잔존 파일 범위는 일치하지 않는다 (출처: `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md`).

## 남은 과제·다음 단계

1. **잠정 리드의 독립 검증**: learned router(0.882) 결과를 초안 머리말 캐비엇과 정합하게 확정 — OASIS/NACC LOCO 수치의 검증 상태 확정, 단일 SSL pretrain 시드 의존 제거 (출처: `reports/F04_QROUTE_ACCV_DRAFT.md` §6).
2. **코호트 확장**: ADNI/A4/AIBL/KDRC를 held-out에 추가해 일반화 주장 강화 (출처: 동일 §6).
3. **질문/ROI 분류체계 확장**: 현재 anatomical prior는 4질문/2–3 ROI에 한정 — 라우터가 "hand-specified"가 아니라 확장 가능함을 보이려면 더 풍부한 taxonomy 필요. 완전 비지도 라우터는 붕괴하므로 prior 의존이 현재 한계 (출처: 동일 §6).
4. **체크포인트 선택·지표 위생**: pooled val AUC가 너무 불안정 → macro(또는 질문별) val AUC로 1차 선택 전환 (출처: `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md` §Forward plan).
5. **임상 과대주장 회피**: 라벨이 임상 컷오프가 아닌 정규 백분위이므로 three-zone 프레이밍 유지 (출처: `reports/F04_QROUTE_ACCV_PAPER_PLAN.md` R4).
6. **폴백 시나리오**: pretrained base에서도 어떤 모듈도 concat을 못 이기면 "벤치마크+조건화 ablation+분석" 논문으로 재프레이밍(C1/C2/C4) (출처: `reports/F04_QROUTE_ACCV_PAPER_PLAN.md` R1).

## 출처 맵

- `README.md` — 워크스페이스 목적·경계·삭제 이력 (2.5D 방향으로 미업데이트 상태)
- `docs/STUDY_DECISION.md` — 선택 연구·금지 헤드라인·필수 baseline (2.5D 방향으로 미업데이트 상태)
- `docs/context/WORKSPACE_STATE.md` — 라벨 권위·코퍼스 정책 (2.5D 방향으로 미업데이트 상태)
- `docs/context/OPEN_QUESTIONS.md` — 미해결 데이터 정렬 질문(centiloid/KDRC 등)
- `docs/F04_F05_ARTIFACT_AND_AGENT_WORKFLOW.md` — 실행/결과 디렉토리 계약, 누출 통제, 에이전트 워크플로
- `reports/F04_3D_VS_2P5D_VQA_DIAGNOSTIC_NOTE.md` — 2.5D vs 3D 핵심 진단(0.732→0.912)
- `reports/F04_IMAGE_REPRESENTATION_VS_MORPHOMETRY_BAR_20260606.md` — 형태계측 0.91 바, DSBN/DINOv2/BN-TTA/style 음성 결과
- `reports/F04_GUIDELINE_GROUNDED_QA_EVIDENCE.md` — guideline-grounded QA 스키마·출처·임계값 상태
- `reports/F04_QROUTE_QUESTION_ROUTING_SPIKE_20260610.md` — 라우팅 spike와 다중시드 deflation
- `reports/F04_QROUTE_ACCV_PAPER_PLAN.md` — ACCV 기여·실험 매트릭스·리스크 레지스터
- `reports/F04_QROUTE_ACCV_DRAFT.md` — 최신 작성 중 초안(fine-tuned base 결과·다중코호트 LOCO)
- `reports/F04_ACTIVE_ARTIFACT_REGISTRY.md` — 활성 산출물·다수 음성 정책 실험 레지스트리
- `scripts/run_f04_v6_qroute_spike.py` — Q-ROUTE 실행 스크립트 (존재 확인)
- `docs/figures/qroute_multicohort.png`, `docs/figures/qroute_repr_gating.png` — 초안에 Fig.2/Fig.3으로 기재됐으나 `docs/figures/` 디렉토리가 존재하지 않아 미생성 상태

---
> 자동 생성: LLM 에이전트가 `minyoung3` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-10.
