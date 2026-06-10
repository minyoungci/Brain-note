# minyoung4 — 3D representation 실험군 종결 후 amyloid positivity 분류로 전환한 워크스페이스

## 한눈에
- 이 워크스페이스는 Min 요청으로 기존 연구 디렉토리를 비우고 처음부터 다시 시작한 곳이다. README는 "특정 연구 방향은 아직 확정하지 않는다"고 명시한다 (출처: README.md).
- 직전의 3D T1w MRI CN/AD representation 실험군은 **실패로 공식 종결**됐다. morphometry baseline(AUC ≈ 0.91)을 안정적으로 넘지 못했고, scanner/site shortcut이 너무 강했다 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).
- 그 후 FOMO300K 기반 SSL 계획서가 작성됐으나, 이는 GPU 대량 투입 전 승인이 필요한 **게이트 기반 계획 문서**다 (출처: docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md).
- 현재 가장 최근(2026-06-10) **확정된 task**는 ADNI/OASIS/AJU/KDRC 4개 코호트의 **이진 amyloid positivity 분류**다. T1w를 유일한 비누수 공통 입력으로, amyloid-PET를 train-only privileged teacher로 쓴다 (출처: audits/modality_amyloid_pet_inventory/README.md).

## 배경·문제 정의
이 워크스페이스의 운영 원칙은 보수적이다. 코딩/분석 전에 Research question·Outcome·Cohort·Split policy·Leakage risks·Expected artifact·Validation을 먼저 정의하도록 AGENTS.md가 강제하며, outcome·cohort·label·split·metric·compute scope는 "조용히 정하지 않는다"고 못박는다 (출처: AGENTS.md).

이 가드레일은 직전 실패에서 나왔다. 이전 연구군의 핵심 교훈은 "MRI를 더 많이 본다는 것만으로 representation이 좋아지지 않는다"와 "CN/AD에서 morphometry는 매우 강한 baseline이며 image encoder는 이를 명시적으로 넘어야 한다", 그리고 "shortcut을 지우는 것과 disease signal을 남기는 것은 별개 문제"였다 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).

## 데이터
현재 확정 task가 대상으로 삼는 4개 코호트의 실측 인벤토리(2026-06-10, 디스크 직접 확인):

| 코호트 | amyloid label | raw PET | label∩raw | official v2 처리됨 |
|---|--:|--:|--:|--:|
| ADNI | 1203 | 1537 | 669 | 0 |
| OASIS | 443 | 412 | 347 | 0 |
| AJU | 1000 | 994 | 994 | 992 |
| KDRC | 534 | 903 | 530 | 890 |

(출처: audits/modality_amyloid_pet_inventory/reports/SUMMARY.md, audits/modality_amyloid_pet_inventory/README.md)

- amyloid **라벨(target y)** 은 4개 코호트 모두 사실상 100% 존재한다 (출처: audits/modality_amyloid_pet_inventory/README.md).
- 4개 코호트 공통 모달리티는 raw 기준 T1w와 PET-amyloid 둘뿐이다. 그런데 PET-amyloid는 amyloid target 자체라 input으로 쓰면 누수 → **비누수 공통 INPUT은 T1w 단 하나**다. FLAIR는 ADNI 결손으로 3/4 코호트에만 존재한다 (출처: audits/modality_amyloid_pet_inventory/README.md).
- 권위 전처리 트리는 `/home/vlm/data/preprocessed_official/v2`이며, 워크스페이스 내 `data/preprocessed_mm/`은 레거시 스냅샷이다 (출처: audits/modality_amyloid_pet_inventory/README.md, audits/modality_amyloid_pet_inventory/config.py).

> 참고: `data/amyloid_label_table.csv`, `data/multimodal_manifest.csv`, `data/preprocessed_mm/`는 대용량 데이터로 직접 열지 않았다. 위 수치는 audit 보고서가 집계한 값을 인용한 것이다 [VERIFY: 원본 CSV 미열람].

## 접근·방법
확정 task의 모델링 골격(2026-06-10 locked):

- **Target(y)**: 이진 amyloid 양성/음성 — 4개 코호트 모두에 공통으로 정의된 유일한 라벨 (출처: audits/modality_amyloid_pet_inventory/README.md).
- **Test-time input**: T1w(universal) + 선택적 FLAIR. ADNI는 FLAIR가 없어 input-modality **adapter**가 T1w-only로 동작 (출처: audits/modality_amyloid_pet_inventory/README.md).
- **Train-only privileged signal**: PET-amyloid를 distillation teacher로 사용(추론 시 미사용). official PET 출력이 레거시 FLAIR와 voxel 단위로 정렬(affine 동일, 192×224×192 그리드, 표본 8/8 aligned)되어 co-registered teacher로 채널 stack 가능 (출처: audits/modality_amyloid_pet_inventory/README.md, audits/modality_amyloid_pet_inventory/reports/SUMMARY.md).

전처리는 자체 v2를 재구현하지 않고 **FOMO/Yucca 공식 레시피를 byte 단위로 대조한 scaffold**를 둔다: RAS → crop-to-nonzero → 1mm isotropic resample(order=3 cubic) → foreground 99th-percentile clamp → foreground z-norm. skull-strip/MNI 등록/N4 없음. 단 공식 입력은 pre-stripped인 반면 FOMO300K는 whole-head raw라, 공식 매치하려면 HD-BET/SynthStrip을 upstream에서 돌려야 한다는 미결 결정이 남아 있다 (출처: docs/context/fomo_official_preprocessing_20260608/README_KO.md).

PET pairing은 "미룰 수 없는 단 하나의 전처리 결정"으로 별도 Phase 0 스크립트가 처리한다: amyloid-labelled ADNI/OASIS subject마다 raw PET scan을, HD-BET brain과 FastSurfer seg를 모두 가진 가장 가까운 T1w 세션에 매칭하고 gap(일수)을 기록한다. 이 단계에서는 아무것도 drop하지 않고 downstream에서 필터한다 (출처: audits/modality_amyloid_pet_inventory/pet_pairing_adni_oasis.py).

## 현재 상태와 결과

**확정 ✅**
- task 정의 lock: 4 코호트 이진 amyloid positivity 분류, input=T1w(+FLAIR adapter), teacher=PET-amyloid (출처: audits/modality_amyloid_pet_inventory/README.md, locked 2026-06-10).
- 코호트별 양성률(verified): ADNI 39.7%, OASIS 33.6%, AJU 34.4%, **KDRC 67.8%**(약 2배 outlier). pooled training 시 "KDRC ⇒ positive" shortcut 위험 → cohort-aware stratification 필요 (출처: audits/modality_amyloid_pet_inventory/README.md).
- 라벨 harmonization(verified): ADNI·OASIS는 둘 다 Centiloid ≈ 20에서 cut → 상호 정합. AJU/KDRC는 핵의학 visual read로 Centiloid 없음 → CL20 대비 검증 불가(잔여 confound) (출처: audits/modality_amyloid_pet_inventory/README.md).
- official PET ↔ 레거시 FLAIR voxel 정렬: 표본 8/8 aligned, 동일 affine·동일 그리드 (출처: audits/modality_amyloid_pet_inventory/reports/SUMMARY.md).

**반증 ❌**
- 3D CN/AD representation 가설: intensity-only AUC(0.8825/0.8866)가 morphometry baseline(0.9072/0.9104)보다 **낮았다**. morphometry+intensity 개선은 조건 의존적이고 all-source에서는 오히려 더 낮았다 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).
- residual/acquisition residualization: morphometry 대비 residual delta AUC가 +0.00013 ~ +0.00037 수준 → disease gain 사실상 0 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).
- 선행 단정 "OASIS는 amyloid PET 영상이 없다"는 **틀렸다**. raw 직접 확인 결과 OASIS·ADNI 모두 amyloid PET raw가 실재한다 (출처: audits/modality_amyloid_pet_inventory/README.md).

**잠정 🟡**
- scanner/site shortcut이 핵심 위험으로 남는다: 폐기된 3D 실험의 ROI feature scanner AUC 0.9529, GPU smoke embedding의 consortium AUC 0.9216 / scanner AUC 0.8948 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md). 이 수치들은 폐기된 실험군의 것이므로 새 task의 결과가 아니다.
- ADNI PET 커버리지 669/1203(56%)은 한계가 아니라 추가 추출로 회복 가능 — extracted raw가 AV45 baseline zip만 풀린 상태 (출처: audits/modality_amyloid_pet_inventory/README.md).
- OASIS 시간 정합 위험: raw PET 보유 347명 중 라벨 T1w 세션과 최근접 PET이 180일 이내 257명, **>730일이 86명** → label↔image mismatch 위험 (출처: audits/modality_amyloid_pet_inventory/reports/SUMMARY.md).
- tracer 도메인 혼재: ADNI=AV45, OASIS=AV45+PiB, AJU/KDRC=FBB/FMM. 도메인 내 SUVR은 self-consistent하나 cross-domain 비교 불가, FBB/FMM Centiloid 변환은 막혀 있다 (출처: audits/modality_amyloid_pet_inventory/README.md).
- ADNI/OASIS amyloid PET는 official v2에 아직 0개 — 배선(resolver 추가 + inventory builder 확장 + run)이 미완 (출처: audits/modality_amyloid_pet_inventory/README.md).

## 폐기된 시도
- **3D T1w CN/AD representation 실험군(stage236~244)**: ROI summary feature 계열 중단, residualized feature 계열 실패, 3D encoder는 smoke/probe availability 수준만 확인. representation/performance claim 금지, 모델·산출물 보존 불요로 판정하고 stage236~244 스크립트·출력·체크포인트를 폐기 산출물로 정리했다 (출처: docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md).
- **FOMO300K SSL 방향**: "그 자체로는 방법론 논문이 아니라 챌린지 submission"이라 자평하고, 외부 사실(FOMO25 주최측 "model/data scaling은 reliable benefit 없음")을 근거로 단순 scaling 축을 경계한다. 방어 가능한 구조는 "audit 主 + biology-guided objective, SSL은 audit의 stress-test"로 종속시키는 형태. STEP 2(공개 biology-guided 체크포인트 frozen linear-probe가 morphometry 0.91 바를 넘는 기미 ≥0.88)가 GPU 대량 투입 전 의사결정 게이트다. 이는 **계획 문서이며 실행되지 않았고 Min 승인이 필요**하다 (출처: docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md).

## 남은 과제·다음 단계
- ADNI·OASIS amyloid PET를 official 파이프라인에 배선: raw resolver 추가, inventory builder를 AJU/KDRC 너머로 확장 후 `run_full --modality pet_amyloid` (출처: audits/modality_amyloid_pet_inventory/README.md).
- tracer harmonization 결정: AV45 / PiB / FBB·FMM의 SUVR 범위 상이. Centiloid는 현재 막힘(FBB/FMM 식 상이 + KDRC per-subject tracer 미상) (출처: audits/modality_amyloid_pet_inventory/README.md).
- OASIS 세션 규칙 확정(nearest-to-T1w vs label-session)과 86명 large-gap subject 처리 (출처: audits/modality_amyloid_pet_inventory/README.md).
- clinical text feature 조인: Tier A(age·sex·CDR_global·diagnosis) + Tier B(CDR_SB·education·MMSE·APOE)를 코호트별 source column에서 harmonize. 단 CDR/MMSE는 dx와 ~83% 일치하는 라벨 누수, 도구 이질이 site 지문 위험. 이는 **인벤토리/스펙 문서**이며 조인은 미실행, ADNI IDA 다운로드·멀티코호트 조인·KDRC/AJU 한국어 헤더 매핑이 Min 승인 대상 (출처: docs/context/CLINICAL_TEXT_COMMON_FEATURES_20260608_KO.md).
- FOMO 전처리: skull-strip 채택 여부(공식 match vs whole-head), 학습 직결 시 .npy+.pkl 전환, raw cohort별 path adapter audit → bounded smoke → 대량 preprocessing(별도 승인) (출처: docs/context/fomo_official_preprocessing_20260608/README_KO.md).

## 출처 맵
- `README.md` — 워크스페이스 리셋 원칙, 유지 파일 목록
- `AGENTS.md` — 가드레일, 작업 전 정의 템플릿, GPU/long job 게이트
- `docs/context/FAILED_3D_CNAD_REPRESENTATION_STUDY_CLOSURE_20260607_KO.md` — 3D CN/AD representation 실패 종결(LOCO·shortcut·residual·smoke 수치)
- `docs/context/FOMO_SSL_PRETRAINING_PLAN_20260608_KO.md` — FOMO300K SSL 게이트 기반 계획
- `docs/context/CLINICAL_TEXT_COMMON_FEATURES_20260608_KO.md` — 7코호트 공통 clinical text 인벤토리·채택 스키마
- `docs/context/fomo_official_preprocessing_20260608/README_KO.md` — 공식 전처리 byte-대조 scaffold
- `audits/modality_amyloid_pet_inventory/README.md` — 확정 task 정의 + 실측 findings(2026-06-10 locked)
- `audits/modality_amyloid_pet_inventory/reports/SUMMARY.md` — per-cohort 카운트·OASIS gap 버킷·affine spot-check
- `audits/modality_amyloid_pet_inventory/config.py` — 트리 루트·raw 레이아웃·코호트 단일 출처
- `audits/modality_amyloid_pet_inventory/pet_pairing_adni_oasis.py` — ADNI/OASIS PET↔T1w pairing(Phase 0)

---
> 자동 생성: LLM 에이전트가 `minyoung4` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-10.
