주요 오류 두 개 확인:
1. `SPEC.md §17` — 파일에 §0–§8만 존재, §17 없음
2. "AJU/KDRC FLAIR 일부 출력 존재(…AJU FLAIR sidecar 다수)" — `data/preprocessed_mm/**/*flair*` 검색 결과 없음. OASIS PET 출력만 실재 확인.

---

# minyoung2 — Frozen 3D T1 백본에 모달리티를 끼워넣는 3D Medical Adapter 연구

## 한눈에
- **무엇:** 단일모달(T1) 3D 뇌 MRI 백본을 frozen으로 고정하고, 추가 모달리티(추론용 FLAIR, train-only PET/Centiloid)를 경량 3D adapter로 주입하는 **"Modality Adapter" 방법론** 개발. 기여는 adapter(method) 자체이고 ablation이 핵심 증거. (출처: SPEC.md §0, §확정 셋업)
- **왜:** 직전 방향(T1→amyloid 분류)이 morphometric ceiling에 막혀 폐기됨 — covariate+APOE4 baseline AUROC 0.743을 어떤 T1 method도 못 넘김. 그래서 "baseline을 이기는 절대성능"이 아니라 "adapter on/off 상대 이득·파라미터 효율·결측/해상도 robustness"로 평가축을 옮겨 신호 천장과 분리. (출처: SPEC.md §1.1, reports/phase1_covariate_baseline.md)
- **지금 어디까지:** 데이터/전처리 인프라 확정, novelty 검증(S0) 완료. 다음 액션은 백본 2개 사전학습 + T1 linear-probe로 **downstream 신호가 있는지 확인하는 게이트(S1)** — 미착수. (출처: SPEC.md §5)
- **목표 venue:** ACCV (comparable accepted 증거 기반), fallback MICCAI. (출처: SPEC.md 머리말)

## 배경·문제 정의
이 워크스페이스는 **방향 전환의 산물**이다. archive에 남은 직전 설계(2026-06-08/09)는 "T1w → amyloid 이진분류 + SSPD(Shortcut-Suppressed Privileged Distillation)"였다. (출처: docs/archive/2026-06-08-amyloid-classification-task-and-data-spec.md, docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md)

이 직전 방향은 세 개의 "막힌 셀"로 종료됐다. (출처: SPEC.md §1.1)
- **amyloid method-win 불가:** T1 외부검증 천장 ~0.62 < covariate+APOE4 baseline 0.743 → 이길 대상(baseline)이 이미 신호 천장 위에 있음.
- **4코호트 공유 멀티모달 불가:** 비-T1 inference 채널이 2코호트 이상 깨끗이 공유되지 않음(FLAIR조차 AJU 2D ≠ KDRC 3D).
- **MRI→amyloid PET 합성 불가:** 선행연구로 점유(ShareGAN 등) + clean paired PET이 ADNI 1코호트뿐.

전환의 핵심 논리: 이 결측·이질성 자체가 곧 **adapter가 푸는 문제**라는 재프레이밍이다. 코호트마다 다른 modality 가용성·해상도가 testbed가 되고, 기여를 method(adapter)로 옮기면 평가가 "amyloid AUROC로 baseline 이김"이 아니라 "adapter-on vs off 상대 이득"이 되어 amyloid 신호 천장과 분리된다. (출처: SPEC.md §1.2)

차별점은 **조합형 novelty**다. 개별 요소(3D medical adapter, missing-modality, privileged-distillation, modality-incremental)는 전부 선행연구에 점유되어 baseline으로만 쓰고, 차별은 *modality-adding + privileged-mode + resolution-agnostic + 결측-robust*를 **단일 프레임에 통합**한 점이다. (출처: SPEC.md §6)

## 데이터
용도별로 분리되어 있고, 규모가 서로 다르다. (출처: SPEC.md §확정 셋업, §2.2)

| 용도 | 데이터 | 규모 |
|---|---|---|
| 백본 SSL 사전학습 | T1 192³ 7코호트 (`official_manifest_full_n4.csv`) | 13,022 |
| FLAIR input-adapter | AJU good(<35mm) + KDRC good (+OASIS 편입중) | 520+409 ≈ 929 |
| PET privileged-adapter | ADNI SUVR (Centiloid: ADNI+OASIS) | ~649 |
| downstream 라벨 | `multimodal_manifest.csv` (amyloid-매칭) | 3,180 |

라벨 완비도(label table 3,180, amyloid-매칭): ADNI 1203 / AJU 1000 / KDRC 534 / OASIS 443. amyloid·cdr_sb 100%, mmse 97%, KDRC age 74%. (출처: SPEC.md §4)

CDR-SB 인지 신호 분포가 task 선택의 근거다 — **AJU가 median 2, range 0–18(치매 포함)로 신호가 풍부**하고, KDRC median 0.5(0–2, early), ADNI·OASIS median 0(대부분 정상). 그래서 primary task를 AJU+KDRC의 CDR-SB 회귀로 잡았다. (출처: SPEC.md §확정 셋업)

라벨 이질성 주의: 정량 Centiloid(ADNI/OASIS) vs visual read(AJU/KDRC)로 ground truth 정의가 다르고, tracer가 AV45/PiB/FBB/FMM로 혼재한다. (출처: reports/tracer_verification.md, SPEC.md §2.2)

## 접근·방법
**백본 2개 병기(둘 다 frozen → adapter만 학습):** (출처: SPEC.md §3.1)
- **B1:** 3D ViT + SSL(MAE), T1 ~13K로 사전학습. SSL이라 라벨 없이 도메인 robust, transformer block에 adapter 주입 자연스러움.
- **B2:** 3D ResNet + supervised(brain-age/multi-task), adapter=conv bottleneck. 빠르고 가벼움.
- 두 백본에서 adapter 이득이 재현되면 backbone-agnostic 주장 성립.

**Adapter 두 모드(통합 기여):** (출처: SPEC.md §3.2)
1. **Input-modality adapter (FLAIR):** 추론에도 존재. 경량 3D 인코더로 frozen 백본에 injection(cross-attn / FiLM). 결측 코호트는 off → base만(graceful). 2D/3D 해상도-agnostic 설계.
2. **Privileged adapter (PET/Centiloid):** train-only. adapter 지식을 T1 경로로 distill, 추론은 T1만 → 추론 비용 0, site bias 0.

**평가축(절대성능 아님):** task 지표(CDR-SB MAE/corr, amyloid AUROC 상대 lift, age MAE) + 효율(trainable params, FLOPs) + robustness(missing-modality drop, 2D↔3D 일관성). ablation이 논문의 척추 — injection 위치/방식, 해상도-agnostic on/off, privileged-distill on/off, gating, adapter 용량 sweep을 modality 조합·backbone·해상도·결측률·param별로 분리 보고. (출처: SPEC.md §3.5, §3.6)

**전처리 인프라(완료, 재사용):** 모든 모달리티를 preprocessed T1w 192³ RAS 격자에 정합한다. 환경에 ANTs/FreeSurfer가 없어 정합은 **SimpleITK Mattes-MI rigid multi-start**(GEOMETRY init + brain-centroid init 둘 다 시도, MI 최선 채택, init별 예외 격리)로 구현. PET은 cerebellum 참조 SUVR, FLAIR/T2는 brain mask 내부 z-score. QC는 정합 후 centroid 거리(centroid_mm > 35 suspect, rot > 60° suspect). (출처: preprocessing/common.py, preprocessing/prep_flair.py:29-33)

배치 드라이버는 manifest를 돌며 modality별로 실행되고 idempotent(출력 존재 시 skip)·per-subject try/except·runlog CSV 기록 구조다. manifest는 amyloid label table(SSOT)에 modality별 RAW 경로 컬럼을 glob으로 붙여 빌드한다(전처리 안 함, 경로 resolve만). (출처: preprocessing/run_batch.py, scripts/build_multimodal_manifest.py)

## 현재 상태와 결과

**✅ 확정**
- **S0(adapter novelty 검증) 완료(2026-06-10):** 개별 요소는 전부 선행 점유=baseline, 차별=통합 조합. ACCV comparable accepted(ACCV2024 Domain-Aware 3D Swin, WACV2025 AutoProSAM, WACV2022 privileged distillation) 확인. (출처: SPEC.md §5, §6)
- **Phase1 covariate baseline(이전 방향 산출물):** LOCO 4-fold, a-dem(demographic+APOE4) **mean AUROC 0.743** [fold range 0.700–0.793], a-clin(+MMSE/CDR-SB) **0.775** [0.747–0.804]. 이 0.743이 amyloid에서 T1 method가 넘어야 했던 bar이고, 넘지 못해 방향 전환의 직접 근거가 됨. (출처: reports/phase1_covariate_baseline.md)
- **T1 192³ SSL 코퍼스 13,022개 ready**(A4 1811·ADNI 4742·AIBL 987·AJU 1287·KDRC 909·NACC 1866·OASIS 1420), 추가 전처리 불요. (출처: SPEC.md §4)
- **라벨 재매칭:** T1 세션을 amyloid 최근접(±365d)으로 교체, 총 3291 → 3180(drop 111), 경로 실재 3180/3180, gap≤365d 100%. (출처: reports/rematch_report.md)
- **tracer 검증:** ADNI(AV45)·OASIS(PIB/AV45)·AJU(FBB/FMM) tracer 확정 → SUVR 산출 가능. KDRC는 영상 헤더에 tracer 미기재 → 정량 PET 보류, visual label만 사용. (출처: reports/tracer_verification.md)
- **전처리 인프라 동작:** OASIS PET 출력 실재 확인(`data/preprocessed_mm/OASIS/OAS30002/d0653/pet/pet_to_t1w_192x224x192_suvr.nii.gz` 등). AJU/KDRC FLAIR 전처리 출력은 미생성 상태 — QC 보고서(`reports/qc/aju_flair.png`, `flair_bulk.log`)만 존재. (출처: data/preprocessed_mm/ 디렉토리 직접 확인)

**❌ 반증·폐기(막힌 셀, 재방문 금지)**
- amyloid 예측 T1 method-win: 외부검증 ~0.62 < baseline 0.743. (출처: SPEC.md §1.1)
- 4코호트 공유 멀티모달 inference 채널: 2코호트 이상 깨끗이 공유 안 됨. (출처: SPEC.md §1.1)
- MRI→amyloid PET 합성: 선행 점유 + clean paired PET ADNI 1코호트뿐. (출처: SPEC.md §1.1)

**🟡 잠정·미검증([VERIFY])**
- **signal 게이트(가장 큰 리스크):** downstream(특히 CDR-SB)에 adapter 이득이 드러날 신호가 있는지 미확인. S1 linear-probe로 먼저 확인, 없으면 task 교체. — adapter 실제 이득은 아직 입증 안 됨. (출처: SPEC.md §1.3-2, §5 S1/S2)
- **FLAIR cross-cohort 주장 약함:** input-adapter 검증이 AJU+KDRC 2코호트뿐. (출처: SPEC.md §1.3-3)
- **AJU FLAIR 2D 정합:** 253개(약 27%)가 정합 실패/해상도 이질(5mm 2D 취득). adapter가 흡수해야 할 난점이자 리스크. (출처: SPEC.md §1.3-4, §4)
- **OASIS FLAIR:** 다운로드 중 → amyloid-세션 매칭·2D/3D 확인 후 편입 예정. (출처: SPEC.md §2.1, §4)
- **novelty가 조합형:** reviewer에 따라 "incremental" 평가 편차 가능. accept 결정 요인은 novelty가 아니라 S1/S2 이득 입증. (출처: SPEC.md §1.3-1, §6)

## 폐기·전환된 시도
- **SSPD(Shortcut-Suppressed Privileged Distillation):** covariate-orthogonal residual ⊕ 도메인-구조적 partial privileged distillation(Centiloid) ⊕ LOCO를 결합해 "MRI가 amyloid 구조를 보는가 vs morphometric ceiling"을 검정하려던 직전 headline. archive로 이관됨. (출처: docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md §2.2, docs/archive/2026-06-08-amyloid-classification-task-and-data-spec.md §2)
- **Image-teacher distillation:** 타 코호트 PET tracer 미검증 + KDRC 포맷 카오스로 ADNI-내부 demonstration으로 격하되었던 upside 경로. 현 SPEC에서는 privileged adapter(train-only)로 재흡수. (출처: docs/archive/2026-06-08-amyloid-classification-task-and-data-spec.md §2)
- 전환 후 문서 정책: SPEC.md를 단일 출처(SSOT)로 누적 갱신, 이전 docs는 `docs/archive/`로 이관. (출처: SPEC.md 머리말)

## 남은 과제·다음 단계
SPEC의 게이트 순서를 따른다. (출처: SPEC.md §5)
- **S1(다음 액션):** 백본 2개(B1/B2) 사전학습 + freeze + T1 linear-probe baseline. **신호 게이트** — 각 downstream(특히 CDR-SB)에 신호가 있는지 확인, 없으면 task 교체.
- **S2(first win):** FLAIR input-adapter가 CDR-SB에서 T1 대비 이득. 안 나오면 재설계.
- **S3:** PET privileged-adapter — amyloid 상대 lift(절대 아님).
- **S4(핵심):** ablation study 전 축 + baselines(T1-only, full multimodal FT, naive fusion, LoRA/Houlsby adapter, 가능시 ShaSpec/MMFormer/M3AE).
- **S5:** robustness(결측/2D-3D/param) + 작성.
- **남은 전처리:** AJU FLAIR 2D 253개(>50mm) 정리 + OASIS FLAIR 편입. 핵심 추가 전처리는 거의 없음. (출처: SPEC.md §4)

검증 의무: 각 게이트는 독립 산출물(scout gap·linear-probe 신호·ablation 지표)로만 판정하고 자기평가로 "완료/novelty"를 선언하지 않는다는 원칙이 문서 전반에 명시되어 있다. (출처: SPEC.md 머리말·§8)

## 출처 맵
- `SPEC.md` — 단일 출처(SSOT). 연구 방향·데이터·설계·전처리·게이트 전부.
- `docs/archive/2026-06-08-amyloid-classification-task-and-data-spec.md` — 폐기된 amyloid 분류 task/데이터 명세.
- `docs/archive/2026-06-09-accv-novelty-and-experiment-plan.md` — 폐기된 SSPD novelty ledger·실험계획.
- `reports/phase1_covariate_baseline.md` — covariate baseline LOCO AUROC(0.743/0.775).
- `reports/rematch_report.md` — T1→amyloid 세션 재매칭(3291→3180).
- `reports/tracer_verification.md` — 코호트별 PET tracer 검증.
- `preprocessing/common.py` — 정합·정규화 코어(SimpleITK MI rigid multi-start, SUVR, z-score).
- `preprocessing/run_batch.py` — modality별 배치 드라이버(idempotent, runlog).
- `preprocessing/prep_flair.py`, `preprocessing/resolve_pet.py` — FLAIR/PET 단일-subject 전처리·소스 resolve.
- `scripts/build_multimodal_manifest.py`, `scripts/rematch_t1_to_amyloid.py` — manifest 빌드·라벨 재매칭.
- `data/preprocessed_mm/` — 멀티모달 전처리 출력(OASIS PET 실재 확인; AJU/KDRC FLAIR 출력 미생성).

---
> 자동 생성: LLM 에이전트가 `minyoung2` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-10.
