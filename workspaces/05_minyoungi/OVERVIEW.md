# minyoungi — 언어지도 3D 뇌 MRI 치매 표현학습의 게이트 통과 기록

## 한눈에

- **무엇**: 3D T1 뇌 MRI에 구조화 임상정보를 자연어 supervision으로 입혀 치매(CN/MCI/AD) 표현을 학습하는 VLM/MLLM 연구. CN/MCI/AD 분류나 PET amyloid 예측 자체가 목표가 아니라, cohort 간 일반화되고 shortcut에 무너지지 않는 representation이 목표다 (출처: notes/context/PROJECT_GOAL.md).
- **왜**: 데이터는 진짜 판독문이 아니라 structured clinical table + imaging이므로 "radiology report VLM"으로 부르면 공격받는다. 더 안전한 framing은 "언어지도 멀티모달 뇌영상 표현학습 + PET/ATN 검증"이다 (출처: literature/notes/2026-05-18_vlm_research_feasibility.md).
- **지금 어디까지**: VLM 본학습 전 게이트 단계에 머물러 있다. ROI-volume scalar teacher distillation은 main route로는 **약하다고 반증**됐고(80/class frozen bal\_acc ≈0.48), 구현/최적화 버그는 대부분 해결됐다. 연구 방향은 (1) PASS-only voxel-wise baseline, (2) harmonization/shortcut-audit 쪽으로 이동 중이다 (출처: notes/context/REPRESENTATION\_LEARNING\_EXPERIMENT\_BLOG.md).
- **주의**: 이 워크스페이스는 *문헌·task설계·컨텍스트·초기 실험·매니페스트* 전용이다. 실제 대형 모델링/전처리는 별도 워크스페이스(`/home/vlm/minyoung4`)에서 돌고, 5~6월 일일 노트만 `research_notes/daily/`로 미러된다 (출처: notes/context/WORKSPACE\_STATE.md).

## 배경·문제 정의

핵심 연구 질문은 하나로 고정돼 있다.

> 구조화 임상 정보를 자연어 supervision으로 바꿔 학습한 3D MRI 표현이, 치매 cohort 간 일반화되고 PET/ATN 또는 longitudinal endpoint와 정렬되는가? (출처: notes/context/PROJECT_GOAL.md)

이 질문을 지키기 위해 task 위계를 명시적으로 나눠 둔다. Task A(ROI-grounded MRI + 구조화 임상언어 표현학습)가 main, Task B(longitudinal progression), Task C(PET/ATN privileged validation branch)는 검증축이다. PET/ATN은 main prediction task로 격하하지 않고 supervision/validation branch로만 둔다 (출처: notes/context/PROJECT_GOAL.md).

VLM claim을 인정하기 위한 baseline gate도 사전에 박아 뒀다: text-only/clinical-only/ROI-only/image-only baseline을 모두 이겨야 하고, subject-disjoint split + cohort-held-out 평가, target field leakage 제거, scanner/cohort shortcut audit이 전부 통과돼야 한다 (출처: notes/context/PROJECT_GOAL.md).

작업 규율도 강하다. AGENTS.md는 Karpathy식 원칙(코딩 전 생각, 최소 코드, 외과적 변경, 생성과 검증 분리)과 GPU/장시간 작업 사전승인 게이트를 강제한다 (출처: AGENTS.md).

## 데이터

7개 컨소시엄(ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC) 기반이다.

- **v2_integrated canonical manifest** (이 워크스페이스 기준): CN/MCI/AD classifiable + image-ready 행 **11,199**. cohort별 ADNI 4,849 / OASIS 1,609 / NACC 1,592 / AJU 1,241 / AIBL 988 / KDRC 920 (출처: notes/context/REPRESENTATION\_LEARNING\_NEXT\_EXPERIMENT\_PLAN.md). A4는 이 manifest에 포함되지 않으며 13,022행 확장 manifest에 합류됨.
- **final_tensor 규격**: 192×224×192, identity affine RAS, z-score (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **voxel-wise PASS-only labeled manifest** (2026-05-25): QC PASS만 남긴 classifiable MRI **10,623행** (CN 5,716 / MCI 3,613 / AD 1,294), 각 MRI당 정확히 5개 ROI-pair(hippocampus, amygdala, thalamus, lateral\_ventricle, parahippocampal\_cortex), label join 100%, validation\_pass=True (출처: notes/context/VOXELWISE\_PASS\_ONLY\_LABELED\_MANIFEST\_HANDOFF\_20260525.md).
- **2026-06 manifest 진화** (미러된 메인 워크스페이스 작업): `official_manifest_full_n4_real_final.parquet`이 13,022 × **138 컬럼**으로 완성. 12→75(FastSurfer vol/ROI/QC)→101(N4 텐서/voxel/scanner)→…→138(raw\_\*\_path) 계보. 임상 커버리지 보강(예: ADNI MMSE 0%→99%, OASIS APOE 0%→100%, A4 amyloid SUVR 100%) (출처: research\_notes/daily/2026-06-10.md).
- **CSF 바이오마커**: 7코호트 전무(연속 농도값 없음)로 확정. NACC/OASIS는 0/1 지표만 존재, ADNI는 미download (출처: research\_notes/daily/2026-06-10.md).

**Caption 누설 정책**이 데이터의 핵심 제약이다. 진단 caption은 `age bucket + sex`만 허용하고 diagnosis/CDR/CDRSB/cohort/scanner/field\_strength/biomarker/ROI는 전부 금지다. PET/ATN/biomarker branch는 `NOT_READY`, ROI-caption은 FastSurfer aseg+DKT Volume\_mm3 한정으로 `CONDITIONALLY_READY_FOR_ROI_CAPTION_V0_DESIGN` (출처: manifests/v2\_integrated/captions/policy/CAPTION\_FIELD\_POLICY.md).

## 접근·방법

- **ROI scalar teacher → image student distillation**: 16개 AD-관련 FastSurfer volume ROI를 teacher로, T1 image-only student에 distill. teacher는 두 갈래로 유지 — Teacher-S(`cn_age_sex_residual_z`, signal-preserving) vs Teacher-B(`combat_then_cn_age_sex_residual_z`, bias-reduced) (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **student objective ladder**: teacher CE → +KL → +embedding → +ROI auxiliary. 평가는 학습 head 정확도가 아니라 **frozen embedding probe**가 1차 metric (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **voxel-wise feature learning v1 baselines**: PASS-only manifest 위에서 ROI mean/summary feature logistic regression부터 단계적으로 실행(baseline\_02 mean logreg → baseline\_03 summary logreg → baseline\_04 ablation). GPU 스크립트(CNN/voxel-wise encoder)는 gate 대기 중 (출처: experiments/voxelwise\_feature\_learning\_v1/baselines/baseline\_02…/REPORT.md, baseline\_03…/REPORT.md, baseline\_04…/REPORT.md).
- **shortcut audit**: 이미지 없이 cohort/clinical/missingness/acquisition metadata만으로 CN/MCI/AD를 얼마나 맞히는지 정량화해 caption 정책을 결정 (출처: manifests/v2\_integrated/audits/shortcut\_audit\_v0/shortcut\_audit\_v0\_report.md).
- **harmonization 실험군** (6월, 미러): ComBat / ComBat-GAM / N4 / WhiteStripe / Nyúl / blur / MixStyle를 site-probe + biology-probe + null control 이중·삼중 검증으로 비교 (출처: research\_notes/daily/2026-06-04.md, research\_notes/daily/2026-06-02.md).

## 현재 상태와 결과

수치는 모두 단일/소표본 controlled run 기준이며, "성능 주장"이 아니라 게이트 통과 여부 판정용이다.

**✅ 확정**

- **label/CE/data plumbing은 정상**. row-id one-hot head와 raw-image random-projection head가 12/class를 bal\_acc 1.0으로 완전 암기 (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **과거 CNN collapse의 원인은 GAP bottleneck + lr**. GAP CNN lr=1e-3은 tiny overfit 실패, lr=1e-4는 거의 성공(0.972), flatpool CNN은 lr=1e-3/3e-3에서 완벽 overfit(1.0) (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **ROI directionality 16/16** 기대 AD 방향 보존(해마/내후각피질 ↓, 뇌실 ↑) (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **shortcut audit (internal\_test, n=1,680)**: `cdr_only` bal\_acc 0.883, `age_sex_cdr` 0.893, upper-risk `nonimage_risky_all` 0.947 → CDR류는 진단의 사실상 동의어이므로 caption 금지. `cohort_only` 0.500, `scanner_field_strength_only` 0.452, `missingness_only` 0.472로 modest (출처: manifests/v2\_integrated/audits/shortcut\_audit\_v0/shortcut\_audit\_v0\_report.md).
- **handcrafted ROI baseline (CN vs AD, voxel-wise PASS-only)**: mean-only(baseline\_02) ROC-AUC 0.7018; summary 40-feature(baseline\_03) random ROC-AUC **0.9004**, leave-one-cohort-out mean **0.8732**(min 0.8139). ablation(baseline\_04): voxel\_count(부피)만으로 0.8913 ≈ full, 최강 단일 ROI는 amygdala(random split) / hippocampus(LOCO) (출처: experiments/voxelwise\_feature\_learning\_v1/baselines/baseline\_02…/REPORT.md, baseline\_03…/REPORT.md, baseline\_04…/REPORT.md).
- **(6월) morphometry는 이미 site-robust**: fs\_vol CN/AD LOCO held-cohort AUC raw 0.916/icv 0.923, site-shift 비용 0.001~0.004 ≈ 0. ComBat/GAM/MixStyle 어느 것도 morphometry baseline을 못 이김 (출처: research\_notes/daily/2026-06-04.md).
- **(6월) N4가 유일하게 효과 있는 intensity 레버**: population을 고정한 within-ADNI 순수 스캐너 probe 0.84→0.66(전체 13,022 재처리 후 2,800표본 reprobe 기준), 모집단 생물학 보존. WhiteStripe/Nyúl/blur는 N4 대비 무이득 또는 역효과 (출처: research\_notes/daily/2026-06-10.md, research\_notes/daily/2026-06-02.md).
- **(6월) site는 픽셀(0.556)보다 acquisition metadata(0.761)·voxel 해상도에 더 강하게 박혀 있다** (출처: research\_notes/daily/2026-06-04.md).

**❌ 반증**

- **ROI-volume scalar teacher distillation을 main route로 쓰는 것은 약하다**. flatpool 80/class에서 best frozen internal\_test bal\_acc ≈0.479, teacher 자체 internal\_test도 ≈0.517로 ceiling이 낮다. 12/class overfit과 class collapse는 해결됐지만 80/class 일반화·teacher-transfer gap이 병목 (출처: notes/context/REPRESENTATION\_LEARNING\_EXPERIMENT\_BLOG.md).
- **voxel-wise ROI mask를 final\_tensor 공간으로 affine-only 전송하는 경로는 무효**. 54케이스 median relative volume error −0.892(잔존 부피 약 11%) → voxel-wise ROI crop/mask/supervision 금지 (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **(6월) manifest만으로는 longitudinal conversion 연구 불가**: dx가 subject당 정적이고(2+세션 2,830명 중 변화 58명), ADNI 전환 0명 (출처: research\_notes/daily/2026-06-04.md).

**🟡 잠정**

- **image-only tiny 3D CNN은 하한선/스모크 용도로만**. 3-seed internal\_test bal\_acc **0.4028 ± 0.0146**, MCI 과예측이 3seed 반복(pred\_rate\_MCI 0.51~0.68), repeat seed에서 CN 예측 소멸(CN recall 0). 같은 sample에서 ROI+age/sex probe는 acc 0.575로 CN/AD를 더 잘 잡음 → MRI signal 부재보다 현재 CNN/학습 설정 한계가 큼 (출처: experiments/image\_only\_smoke\_v0/runs/…/diagnostic\_audit\_v0/DIAGNOSTIC\_SUMMARY\_KO.md).
- **(6월) 연구 framing verdict**: image-level "정확도 SOTA 향상" claim 가능성 매우 낮음. 현실적 publishable은 **shortcut-audit / representation-validity 프로토콜**, 특히 "site==population에서 site-down과 biology-제거는 단일 probe로 결정 불가(undecidable)"라는 명제가 novelty. research-critic 독립 감사 CONDITIONAL PASS (출처: research\_notes/daily/2026-06-04.md).

## 폐기·전환된 시도

- **voxel-wise ROI supervision**: transform QC 실패로 보류(scalar ROI만 허용) (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **ROI-volume distillation as sole main objective**: main에서 내려 auxiliary/diagnostic branch로 강등 (출처: notes/context/REPRESENTATION\_LEARNING\_EXPERIMENT\_BLOG.md).
- **GAP CNN lr=1e-3 teacher-latent path**: collapse로 폐기, flatpool로 전환 (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).
- **WhiteStripe/Nyúl/blur-to-floor harmonization**: N4 대비 무이득 → 탐색 종료, N4 단독 확정 (출처: research\_notes/daily/2026-06-02.md).
- **positive harmonization 논문 방향**: CN/AD는 비용~0이라 headroom 없고, CN/MCI는 unmask 안 되고, conversion은 데이터 불가 → audit/boundary 논문으로 pivot (출처: research\_notes/daily/2026-06-04.md).
- **워크스페이스 정체성 자체의 전환**: WORKSPACE\_STATE.md(2026-05-19)는 "실험 코드는 여기 두지 않는다"고 적었으나, 이후 `experiments/`에 image\_only\_smoke / roi\_to\_image\_distill / voxelwise\_feature\_learning 실험이 실제로 실행됨. 문서와 현재 상태 간 괴리 존재 [근거부족: WORKSPACE\_STATE.md 갱신 필요] (출처: notes/context/WORKSPACE\_STATE.md vs experiments/).

## 남은 과제·다음 단계

- **teacher 정보량 병목 검증**: 16-dim ROI에서 ~100-region DKT volume teacher(E3)로 확장 smoke. true cortical thickness는 surface output 부재로 미가능 (출처: notes/context/REPRESENTATION\_LEARNING\_NEXT\_EXPERIMENT\_PLAN.md).
- **외부 SSL baseline**: 3D-Neuro-SimCLR frozen probe(E4)로 ROI distillation 우회 경로 비교. clone/weights 저장 위치 결정 필요 (출처: notes/context/REPRESENTATION\_LEARNING\_NEXT\_EXPERIMENT\_PLAN.md).
- **평가축 전환**: hard 3-class 대신 CN vs AD binary + CN→AD disease-axis + MCI projection + cohort probe로 representation을 측정(E1) (출처: notes/context/REPRESENTATION\_LEARNING\_NEXT\_EXPERIMENT\_PLAN.md).
- **ROI final-tensor transfer Option B**: FastSurfer aparc/aseg를 final\_tensor 공간으로 정확히 옮기고 per-ROI overlap/volerr/visual QC 게이트 통과 후에만 voxel-wise 재개 (출처: notes/context/REPRESENTATION\_LEARNING\_NEXT\_EXPERIMENT\_PLAN.md, notes/context/ROI\_FINAL\_TENSOR\_TRANSFER\_OPTION\_B\_PLAN.md).
- **멀티모달 확장 (사전승인 필요)**: AJU/ADNI/NACC DICOM→NIfTI 배치 변환 후 raw\_\*\_path 재빌드 (출처: research\_notes/daily/2026-06-10.md).
- **VLM readiness gate는 아직 미충족**: ROI teacher validity + spatial QC + frozen representation gate + cohort 일반화 + 3-seed 안정성 전부 통과 전까지 full VLM 금지, 소형 retrieval smoke만 허용 (출처: notes/context/REPRESENTATION\_LEARNING\_ROOT\_CAUSE\_PLAN.md).

## 출처 맵

- `AGENTS.md` — 워크스페이스 운영 규칙(Karpathy식, GPU 게이트, 데이터 안전)
- `notes/context/PROJECT_GOAL.md` — VLM 연구 목표·task 위계·baseline gate
- `notes/context/WORKSPACE_STATE.md` — 워크스페이스 정체성(문헌/설계 전용 명시, 2026-05-19)
- `notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md` — 실패 해부 통합 기록(ROI distillation 약함 결론)
- `notes/context/REPRESENTATION_LEARNING_ROOT_CAUSE_PLAN.md` — 단계별 게이트·실패 위치 추적·전 실험 수치
- `notes/context/REPRESENTATION_LEARNING_NEXT_EXPERIMENT_PLAN.md` — E1~E4 다음 실험 Go/No-Go
- `notes/context/VOXELWISE_PASS_ONLY_LABELED_MANIFEST_HANDOFF_20260525.md` — PASS-only labeled manifest 카운트·검증
- `literature/notes/2026-05-18_vlm_research_feasibility.md` — VLM 가능성 판단·naming 주의·task 후보
- `manifests/v2_integrated/captions/policy/CAPTION_FIELD_POLICY.md` — task별 allowed/forbidden caption field
- `manifests/v2_integrated/audits/shortcut_audit_v0/shortcut_audit_v0_report.md` — 비이미지 metadata shortcut 정량화
- `experiments/voxelwise_feature_learning_v1/baselines/baseline_02…/REPORT.md` — ROI mean CN vs AD baseline
- `experiments/voxelwise_feature_learning_v1/baselines/baseline_03…/REPORT.md` — ROI summary 40-feature baseline·LOCO
- `experiments/voxelwise_feature_learning_v1/baselines/baseline_04…/REPORT.md` — ROI stat ablation
- `experiments/image_only_smoke_v0/runs/…/diagnostic_audit_v0/DIAGNOSTIC_SUMMARY_KO.md` — image-only CNN 3-seed 진단
- `research_notes/daily/2026-05-31.md` · `2026-06-02.md` · `2026-06-04.md` · `2026-06-10.md` — (미러) clinical/CDR·N4·harmonization·138컬럼 manifest
- `docs/README.md` — blog형 설계 문서·PaperBanana figure 안내

---
> 자동 생성: LLM 에이전트가 `minyoungi` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-13.
