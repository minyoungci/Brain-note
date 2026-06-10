# minyoungi — 언어지도 멀티모달 뇌 MRI 표현학습: 정확도 경쟁을 접고 shortcut-audit으로 좁혀간 기록

## 한눈에

- 목표는 처음부터 "CN/MCI/AD 분류기"가 아니라 **구조화 임상정보를 자연어 supervision으로 바꿔 학습한 3D T1 MRI 표현이 코호트 간 일반화되고 PET/ATN과 정렬되는가**였다 (출처: notes/context/PROJECT_GOAL.md).
- 7개 컨소시엄(KDRC·A4·OASIS·AIBL·AJU·ADNI·NACC) 통합 manifest를 13,022행 × 138컬럼까지 키우고 raw NIfTI 경로 11,947건을 전수 검증했다 (출처: research_notes/daily/2026-06-10.md).
- 그러나 harmonization 실험 01~09가 "이미지 정확도 경쟁"과 "harmonization으로 일반화 향상" 경로를 **반증**했고, 연구 적부 dossier는 정확도 SOTA·MCI 전환예측·CDR staging을 "죽음"으로 판정했다 (출처: roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md, research_topic/README.md).
- 현재 살아있는 방향은 두 줄기다. **(a) cross-population shortcut-audit(한국 vs 서구 confounded regime의 undecidability 명제, CPU·즉시), (b) biology-guided foundation feature linear-probe(GPU·조건부)** (출처: research_topic/README.md).
- 주의: 워크스페이스 governance 문서(AGENTS.md, WORKSPACE_STATE.md)는 이곳을 "실험 코드를 두지 않는 문헌/노트 전용 공간"으로 규정하지만, 실제로는 GPU 실험·전처리 파이프라인·매니페스트 빌드가 모두 들어와 있어 문서가 현재 상태를 따라오지 못한다.

---

## 배경·문제 정의

연구의 중심 질문은 명시적으로 정의돼 있다.

> 구조화 임상 정보를 자연어 supervision으로 바꿔 학습한 3D MRI 표현이, 치매 cohort 간 일반화되고 PET/ATN 또는 longitudinal endpoint와 정렬되는가? (출처: notes/context/PROJECT_GOAL.md)

권장 framing은 "Language-supervised multimodal neuroimaging representation learning for dementia progression and PET/ATN-aware validation"이고, PET/ATN은 main task가 아니라 **privileged validation/supervision branch**로 격하돼 있다 (출처: notes/context/WORKSPACE_STATE.md, notes/context/PROJECT_GOAL.md).

명시적으로 **피하기로 한 것**도 분명하다: PET amyloid 이진 예측을 main으로 축소하지 않기, AD/CN/MCI 단순 분류를 novelty로 두지 않기, "radiology report VLM"이라 부르지 않기(실제 판독문이 없으므로), caption에 target label을 넣고 같은 target을 예측하는 leakage 설계 금지 (출처: notes/context/PROJECT_GOAL.md).

VLM 가능성 자체는 2026-05-18에 "가능하다. 단, 이름은 조심해야 한다"로 정리됐다. 진짜 radiology report pair가 없고, 데이터는 "imaging + structured clinical table"이므로 "tabular-to-text neuroimaging VLM" 또는 "language-supervised 3D MRI representation learning"이 안전한 표현이라는 결론이다 (출처: literature/notes/2026-05-18_vlm_research_feasibility.md).

---

## 데이터

**Canonical manifest** (워크스페이스 외부 `/home/vlm/data/`에 존재, 이 워크스페이스가 빌드·검증):
- `official_manifest_full_n4_real_final.parquet` — 13,022행 × **138컬럼** (출처: research_notes/daily/2026-06-10.md).
- 컬럼 계보: official_manifest.csv(12) → _full(75, FastSurfer ROI/QC) → _n4(101, N4 텐서·voxel·scanner) → KDRC/AJU/ADNI 임상 보강(117, MMSE·APOE·amyloid·sex·age·dx) → real_final 06-05(122, OASIS MMSE/CDR/amyloid) → A4/NACC amyloid(127) → OASIS3_data_files 보강(133) → raw_*_path(138) (출처: research_notes/daily/2026-06-10.md).
- 7코호트 멀티모달 가용성은 코호트별로 매우 비대칭하다. NIfTI 즉시 사용 가능(T1 기준): KDRC·A4·OASIS·AIBL. DICOM/zip 변환 필요: AJU·ADNI·NACC (출처: research_notes/daily/2026-06-10.md).
- raw 경로 커버리지(전수 검증, 0 missing): raw_t1 5,127(39.4%), raw_flair 3,379(25.9%), raw_t2 816(6.3%), raw_dwi 1,722(13.2%), raw_pet 903(6.9%) — 총 11,947 경로 (출처: research_notes/daily/2026-06-10.md).

**학습용 voxel-wise PASS-only labeled subset** (visual QC 통과분만):
- classifiable MRI 10,623행 (CN 5,716 / MCI 3,613 / AD 1,294), ROI-pair 53,115행(MRI당 정확히 5 ROI: hippocampus·amygdala·thalamus·lateral_ventricle·parahippocampal_cortex), label join 100% (출처: notes/context/VOXELWISE_PASS_ONLY_LABELED_MANIFEST_HANDOFF_20260525.md).

**Korean 정본**(AJU·KDRC, 모든 수치 2026-06-10 manifest 재계산·assertion 검증):
- subject-level 1,898 × 51, session-level 2,196 × 76 (출처: research_topic/03_processed_data_spec.md).
- dx_3class·APOE 100%, MMSE 97%, CDR 99% 커버리지. 단 **라벨 체계가 코호트마다 다름**: AJU{CN,MCI,AD,OtherDementia} vs KDRC{CN,MCI,Dementia} — "AD"≠"Dementia", pooled 라벨 정의가 선결 과제 (출처: research_topic/03_processed_data_spec.md).
- v2 영상 텐서 사양: 192×224×192, identity affine, z-score, N4 보정. 단 **N4 후에도 site shortcut 잔존(appearance probe 0.565)** (출처: research_topic/03_processed_data_spec.md).

**검증된 데이터 한계**(활용 전 필수): CN 부족(Korean subject CN 268 = AJU 206 + KDRC 62), CSF 7코호트 전무(amyloid PET로 대체), manifest dx가 subject당 정적이라 종단 전환 연구 불가 (출처: research_topic/03_processed_data_spec.md, research_notes/daily/2026-06-04.md, research_notes/daily/2026-06-10.md).

---

## 접근·방법

작업은 네 갈래로 진행됐다.

1. **문헌·task 설계**: VLM-ready manifest schema, caption field policy(task별 allowed/forbidden field로 leakage 통제), PAPER_READING_MATRIX(ADLIP/NeuroVLM/Natural Text Supervision MRI/M3D/CT-CLIP 계열) (출처: notes/context/PROJECT_GOAL.md, literature/notes/2026-05-18_vlm_research_feasibility.md).

2. **Harmonization/site-bias audit (roi_qc/experiments/harmonization/ 01~09)**: 7코호트 scanner/site 식별 가능성을 3축(metadata·appearance·biology)으로 정량화, ComBat·ComBat-GAM·N4 변형·MixStyle을 morphometry baseline과 비교, 전부 RF+LogReg 교차검증·null control로 검증 (출처: research_notes/daily/2026-06-04.md, roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).

3. **표현학습 실험 (experiments/)**: image_only_smoke_v0(tiny 3D CNN smoke) → roi_to_image_distill_v0(ROI scalar/latent teacher distillation) → voxelwise_feature_learning_v1(PASS-only labeled baseline ladder) (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md, experiments/voxelwise_feature_learning_v1/README.md).

4. **연구 적부 판정 (research_topic/)**: 독립 2-에이전트(literature-scout + research-advisor)가 보유 데이터로 가능/불가능한 주제를 F×N×R 랭킹으로 판정 (출처: research_topic/README.md).

평가 원칙은 일관된다: random split 금지(코호트를 외움) → **leave-one-consortium-out(LOCO), subject-disjoint** 필수, 검증은 site-probe↓ + biology-probe 보존 + null control **3종 동시** (출처: roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).

---

## 현재 상태와 결과

### 확정

- **morphometry(FastSurfer ROI 부피)는 cross-cohort site-robust**. CN/AD를 held-cohort로 LOCO AUC ~0.90, site-shift 비용 ~0.001~0.004(한국 코호트 포함), RF+LogReg 교차 재현 (출처: research_notes/daily/2026-06-04.md, roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).
- **site는 픽셀보다 acquisition metadata에 더 강하게 박힌다**: metadata(vendor+field+voxel) balanced acc 0.761 > appearance 0.556 > N4후 0.517, biology(brain_vox) 대조 0.151≈chance(0.143) (출처: research_notes/daily/2026-06-04.md).
- **이미지 end-to-end는 morphometry를 못 이긴다**: 3D CNN held-AUC 0.88~0.90 < morphometry 0.93~0.95, 6 run 전부 Δ<0(−0.03~−0.08) (출처: research_notes/daily/2026-06-04.md, roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).
- **ROI mean intensity logistic regression CN vs AD: ROC-AUC 0.7018**, balanced acc 0.6806 (subject-disjoint GroupShuffleSplit, MCI 제외, test 1,436행). 단 이는 representation learning이 아니라 5차원 sanity-check 하한선이다 (출처: experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad/REPORT.md).
- **voxel-wise ROI mask를 final_tensor(192×224×192) 공간으로 affine-only 이전하면 신뢰 불가**: 54케이스 상대 부피 오차 median −0.89(대부분 ROI가 크게 줄거나 소실) → voxel-wise ROI crop/attention/loss 금지, scalar ROI teacher만 허용 (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md).
- **이전 CNN collapse의 원인은 label/data가 아니라 architecture/optimization**: row-id one-hot head와 raw image random projection head가 balanced acc 1.0으로 완벽 overfit → label/CE/metric loop 정상. 원인은 GAP bottleneck + 과한 lr(GAP CNN lr=1e-3 실패, lr=1e-4·flatpool은 거의/완전 overfit) (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md).

### 반증

- **"ComBat이 cross-cohort 일반화를 향상시킨다"** → 효과 작고 분류기 의존. held-cohort에서 RF −0.014 / LogReg +0.022로 **부호가 뒤집힘**. 생성/검증 분리의 대표 사례 (출처: research_notes/daily/2026-06-04.md §09, roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).
- **"강한 image harmonization(MixStyle)이 site shortcut을 줄인다"** → site-probe가 오히려 +0.026~0.027 상승(양 seed 재현). N4·ComBat·MixStyle = 정규화·특징·스타일 3축 전부 morphometry를 못 이김 (출처: research_notes/daily/2026-06-04.md §07).
- **"image-only tiny CNN을 성능/VLM 비교 기준으로 쓸 수 있다"** → 부적절. seed 3개 모두 MCI 과예측(balanced acc 0.4028±0.0146), repeat seed 2개에서 CN 예측이 완전 소멸(pred_CN=0). 파이프라인 smoke/하한선으로만 사용 (출처: experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/diagnostic_audit_v0/DIAGNOSTIC_SUMMARY_KO.md).
- **정확도 SOTA / harmonization 일반화↑ / image>morphometry / MCI 전환예측 / CDR staging** → 보유 데이터로는 "죽음"으로 판정. 정확도 경쟁 논문은 닫혔고, headroom이 거의 없다(LOCO site-shift 비용 ~0) (출처: research_topic/README.md).
- **종단 MCI→AD 전환 연구** → manifest dx가 정적이라 불가(2+세션 2,830명 중 dx 변화 58명·2%, ADNI 0명). per-visit dx 재추출은 별도 데이터엔지니어링 과제 (출처: research_notes/daily/2026-06-04.md).

### 잠정

- **ROI scalar teacher에는 신호가 있으나 ceiling이 낮다**: directionality 16/16 유지, ROI-only probe ~0.50(실측 0.52 전후), 그러나 80/class에서 teacher 자체 internal_test balanced acc ~0.517, student frozen ~0.479. 구현 blocker는 해결됐고 병목이 "teacher ceiling + teacher-student transfer gap + 80/class generalization"으로 이동 (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md).
- **VLM main route(언어지도 표현학습)는 아직 미실행·aspirational**. 설계·feasibility는 정리됐으나 실제 image-text contrastive/fusion run은 돌리지 않았다 (출처: literature/notes/2026-05-18_vlm_research_feasibility.md, notes/context/PROJECT_GOAL.md).
- **biology-guided foundation feature linear-probe** → "가능·조건부(GPU·사전승인)". 순수 SSL은 site-robust 아님(인용 travelling-heads ICC 0.25–0.45 [VERIFY: 원논문 미검증]), biology-guided만 FreeSurfer 바(0.91)를 넘는다는 가설 (출처: research_topic/README.md).

---

## 폐기·전환된 시도

- **voxel-wise ROI supervision (option_b voxel ROI)**: final_tensor 공간 resampling QC 실패(median 부피오차 −0.89)로 금지. scalar ROI teacher로 후퇴 (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md, research_topic/README.md).
- **GAP CNN lr=1e-3 teacher-latent 경로**: tiny overfit조차 불안정 → flatpool CNN으로 전환 (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md).
- **ROI-volume scalar teacher distillation을 단독 main objective로 쓰기**: ceiling 낮음 → auxiliary/diagnostic branch로 격하, 더 강한 anatomical teacher 또는 self-supervised/multi-task 표현으로 재정렬 (출처: notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md).
- **이미지 harmonization으로 site 제거**: ComBat/ComBat-GAM/N4/MixStyle 전부 무이득~역효과 → "지우지 말고 조건화하라(condition, not erase)" 원리로 전환(acquisition 축만 nuisance 입력, population은 보존) (출처: roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).
- **연구 framing 자체**: "정확도/일반화 향상" → "무엇이 결정 가능한가/어디서 깨지는가를 측정하는 audit". 핵심 novelty는 site==population confounded regime에서 shortcut 제거 성공/실패가 단일 probe로 **판정 불가(undecidable)**라는 명제 (출처: research_topic/README.md).

---

## 남은 과제·다음 단계

- **T-1 (CPU·즉시·승인 불필요)**: cross-population shortcut-audit 착수. 입력 img_features(site-leaky) vs fs_vol morphometry(site-robust), LOCO held-KDRC/AIBL, AJU는 CN n=23로 held 불가하여 site-probe 전용. 성공기준 = dual-probe(site↓ + biology 0.91 보존 + null) (출처: research_topic/README.md).
- **T-3 (GPU·사전승인)**: biology-guided foundation feature linear-probe. backbone 입력 호환성(192³ z-score identity-affine) 선확인 후, LOCO로 0.91 바를 넘어야 채택 (출처: research_topic/README.md, roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md).
- **DICOM→NIfTI 대량 변환 (사전승인 필요)**: AJU 1,287세션×5모달, ADNI 4,742세션, NACC 4,922 zip. 완료 후 raw_*_path 100% 복원 → 멀티모달 VLM 입력 확보 (출처: research_notes/daily/2026-06-10.md).
- **알려진 gaps**: NACC ses-1 274세션 매핑 테이블, AIBL raw_t1이 skull-stripped라 truly-raw 아님, A4 DWI/PET·ADNI FLAIR/DWI는 local raw store 부재 (출처: research_notes/daily/2026-06-10.md).
- **거버넌스 정합성 [VERIFY]**: AGENTS.md(§0: "최소 구조와 데이터 링크만 둔다")와 WORKSPACE_STATE.md(2026-05-19: "실험 코드는 이 workspace에 두지 않는다")가 현재 실태(experiments/·preprocessing/·roi_qc/experiments/harmonization/의 GPU MixStyle run·Clinical/ 노트북)와 어긋난다. 두 문서는 갱신되거나, 실험 호스팅 정책이 명문화될 필요가 있다 (출처: AGENTS.md, notes/context/WORKSPACE_STATE.md vs README.md, research_notes/daily/2026-06-10.md).

---

## 출처 맵 (참조한 핵심 파일)

- `notes/context/PROJECT_GOAL.md` — VLM/MLLM 연구 목표·task hierarchy(A main / B longitudinal / C PET-ATN)·baseline gate
- `notes/context/WORKSPACE_STATE.md` — 워크스페이스 charter(2026-05-19, 현재 stale)
- `README.md` — 워크스페이스 구조·빠른 시작(2026-06-10 기준)
- `AGENTS.md` — Codex/에이전트 가드레일(Karpathy식 원칙), charter 원문
- `research_notes/daily/2026-06-10.md` — manifest 138컬럼 완성, raw_*_path 11,947 검증, 7코호트 멀티모달 서베이
- `research_notes/daily/2026-06-04.md` — harmonization 01~09 종합(ComBat/GAM/MixStyle/LOCO), 수치·검증
- `notes/context/VOXELWISE_PASS_ONLY_LABELED_MANIFEST_HANDOFF_20260525.md` — PASS-only labeled subset(MRI 10,623, ROI-pair 53,115)
- `notes/context/REPRESENTATION_LEARNING_EXPERIMENT_BLOG.md` — 3D 표현학습 실패 해부, root cause 확정
- `experiments/voxelwise_feature_learning_v1/baselines/baseline_02_roi_mean_logreg_cn_vs_ad/REPORT.md` — CN vs AD ROC-AUC 0.7018
- `experiments/voxelwise_feature_learning_v1/README.md` · `experiments/voxelwise_feature_learning_v1/docs/BASELINE_SEQUENCE.md` — baseline ladder(B00~B04)
- `experiments/image_only_smoke_v0/runs/image_only_smoke_v0_20260521T072243Z/diagnostic_audit_v0/DIAGNOSTIC_SUMMARY_KO.md` — image-only tiny CNN MCI 과예측 진단
- `roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md` — site-bias DO/DON'T 단일 권위 문서, 증거표
- `research_topic/README.md` — 연구 적부 판정(가능/조건부/죽음)
- `research_topic/03_processed_data_spec.md` — Korean(AJU·KDRC) 처리 데이터 정본·커버리지·한계
- `literature/notes/2026-05-18_vlm_research_feasibility.md` — VLM 가능성 판단·naming 주의·task 후보 A~D

---
> 자동 생성: LLM 에이전트가 `minyoungi` 를 탐색해 작성·검증. **검토용**이며 [VERIFY]·[근거부족] 표시 항목은 미확인. 모델 gen=`claude-opus-4-8` critic=`claude-sonnet-4-6` · 갱신 2026-06-10.
