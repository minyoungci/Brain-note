# INSIGHTS — 데이터 이해 인사이트 인덱스 (인사이트 → 노트북 지도)

> **이 문서의 목적**: `Clinical/`의 데이터 이해 튜토리얼(ipynb 32종)을 **토폴로지(코호트/교차/스터디)가 아니라 인사이트 축**으로 찾게 해주는 내비게이션. 다른 대형 실험(`/home/vlm/minyoung4`)을 시작하는 사람/에이전트는 **이 파일을 먼저** 읽고, 필요한 인사이트의 노트북·섹션으로 직행한다.
>
> **두 권위 문서의 역할 분리**
> - **데이터를 *이해*하려면** → 이 `INSIGHTS.md` (어느 노트북이 무엇을 보여주는가)
> - **그 인사이트로 모델을 *어떻게 학습*시키나** → `../roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md` (DO/DON'T 규칙 + 9개 실험 증거)
>
> 노트북은 토폴로지 폴더(코호트별/교차/스터디)에 그대로 둔다 — 경로 하드코딩·의존체인 때문에 물리 이동은 순손해. 이 인덱스가 인사이트 축을 제공한다.

---

## 🧭 목적별 읽기 경로 (먼저 여기)

| 당신의 목표 | 순서 |
|---|---|
| **새 대형 실험을 시작한다 (데이터 처음)** | `studies/research_tutorial/notebooks/research_data_tutorial.ipynb`(종합 입문) → `notebooks/04_repr_learning_challenges.ipynb`(왜 어려운가) → PLAYBOOK(어떻게 학습) |
| **특정 코호트를 깊이 이해한다** | `consortiums/{C}/{C}_01_clinical_eda` → `_02_mri_voxel_roi` → `_03_3d_render` (C ∈ ADNI/NACC/AIBL/OASIS/A4/AJU/KDRC) |
| **site/scanner bias를 모델에서 어떻게 다루나** | INSIGHT 1·2·3·4(아래) → **PLAYBOOK** |
| **공통 타깃(라벨)을 정의한다** | `notebooks/05_cdr_common_target` → INSIGHT 7·8 |
| **ROI/voxel 데이터를 쓸 수 있나** | INSIGHT 5·6 → `VOXEL_ANALYSIS_PLAN.md` (게이트 필수) |

---

## 인사이트 → 노트북 지도

각 행: **인사이트** · 한 줄 의미 · **이해(notebook§)** · **증명(harmonization 실험)** · 견고성.
※ 수치는 검증본(`README.md`·memory·harmonization RESULTS) 기준. 노트북 자체 수치는 샘플/교육용.

### 🔴 site·bias 축 (대형 실험의 1순위 제약)

**INSIGHT 1 — site bias는 다축이고 이미지로는 거의 못 지운다**
- 의미: 식별 가능성 metadata **0.761** > image appearance **0.556** > N4-후 **0.517** ≫ biology(brain_vox) **0.151**(≈chance). 주 경로는 voxel 해상도·벤더(이미지 후처리로 불가).
- 이해: `studies/qc_scanner_render/notebooks/data_quant_study.ipynb` §4(Site/스캐너↔영상) · `notebooks/03_roi_volume_analysis.ipynb` §4(Site Effect) · `studies/qc_scanner_render/notebooks/qc_scanner_render_study.ipynb`(벤더별 렌더)
- 증명: harmonization **01**(3축 정량) · **03**(N4가 image harmonizer 중 최선이나 이득 작고 probe-의존)
- 견고성: ⭐⭐⭐ (LogReg 독립검증 통과)

**INSIGHT 2 — site == 모집단 교란 (한국 vs 서구, traveling subject 0명)**
- 의미: AJU/KDRC(한국)와 서구 코호트는 공변량 분포가 거의 분리. site를 0으로 지우면 비교하려는 생물학까지 손상. AJU=MCI-heavy(MCI 980/CN 23) → site가 라벨 지름길.
- 이해: `notebooks/01_consortium_overview.ipynb`(7코호트 분포) · `notebooks/05_cdr_common_target.ipynb` §7(CDR이 site를 학습할 위험) · `notebooks/04_repr_learning_challenges.ipynb` Challenge 2(Domain Shift)
- 증명: harmonization **08**(site는 mask가 아니라 inflation) · **09**
- 견고성: ⭐⭐⭐

**INSIGHT 3 — morphometry(ROI 부피)는 CN/AD에서 이미 site-robust = 학습 바닥**
- 의미: LOCO held-cohort AUC ~0.90–0.92(한국 KDRC 포함), site-shift 비용 ≈0. 이미지 방법이 넘어야 할 바 **0.91**.
- 이해: `notebooks/03_roi_volume_analysis.ipynb` §5(ROI로 AD 분류 가능성) · `notebooks/04_repr_learning_challenges.ipynb` Challenge 3(signal dilution)
- 증명: harmonization **04**(LOCO) · **09**(전처리 줄세우기, train-z 0.910 승자) → **모델링 규칙은 PLAYBOOK**
- 견고성: ⭐⭐⭐ (RF+LogReg 일치)

**INSIGHT 4 — harmonization은 cross-cohort 일반화를 못 올린다**
- 의미: ComBat/N4/MixStyle 모두 morphometry baseline을 못 이김. ComBat은 분류기 따라 부호 반전(RF −0.014 / LogReg +0.022) → 일반화 부스터 신뢰 불가, in-distribution만.
- 이해: `notebooks/06_harmonization_combat.ipynb`(ComBat before/after, site↓·신호보존)
- 증명: harmonization **02**(feature ComBat) · **05**(ComBat-GAM 이득 無) · **07**(MixStyle도 못 이김) · **09**(부호반전)
- 견고성: ⭐⭐⭐

### 🟠 데이터 신뢰성·좌표 축 (쓰기 전 반드시)

**INSIGHT 5 — ROI 마스크는 BLOCKED_PROVISIONAL (후보, 검증 아님)**
- 의미: manifest 전수 13,022행 `roi_final_ready=False`, `BLOCKED_PROVISIONAL`. option_b ROI/부피 기반 결과는 "검증"이 아니라 "후보". 정량 주장 전 per-ROI overlap/volerr 게이트 필요.
- 이해: `consortiums/{C}/{C}_02_mri_voxel_roi.ipynb` §4-5(그리드 정합·voxel/부피) · `studies/qc_scanner_render/notebooks/data_quant_study.ipynb` §2(ROI 신뢰도 진단 ★) · `studies/qc_scanner_render/notebooks/roi_anatomy_tutorial.ipynb`(잠정 경고) · **`VOXEL_ANALYSIS_PLAN.md`**
- 견고성: ⭐⭐⭐ (manifest 플래그 근거)

**INSIGHT 6 — 그리드/좌표 함정 (192³ z-score vs 256³ conformed)**
- 의미: `final_tensor` 192×224×192 identity-affine z-score(모델 입력) ↔ `roi_masks/*` 256³ conformed → **직접 오버레이 불가**. voxel 작업은 option_b `*_final_tensor_grid_*` 버전 사용. summary `centroid_voxel`은 ~31vox 어긋남(크롭 중심으로 쓰지 말 것).
- 이해: `consortiums/{C}/{C}_02_mri_voxel_roi.ipynb` §3-4 · `studies/qc_scanner_render/notebooks/dkt_cortex_extraction.ipynb`(재처리 없이 grid aseg에서 추출) · `research_data_tutorial.ipynb` §2 · README "핵심 사실"
- 견고성: ⭐⭐⭐

### 🟡 라벨·임상 축

**INSIGHT 7 — clinical join 커버리지는 코호트마다 다르다 (A4/KDRC는 dx 라벨 없음)**
- 의미: row-level join OASIS **29%**·KDRC 85%·나머지 ~100%. A4(preclinical)·KDRC는 diagnosis 0% → 공통 라벨이 안 됨.
- 이해: `notebooks/00_manifest_alignment.ipynb` §6(join 품질 리포트) · `consortiums/{C}/{C}_01_clinical_eda.ipynb` §3(row-join 가능성) · README join 표
- 견고성: ⭐⭐⭐

**INSIGHT 8 — CDR Global = 7코호트 공통 타깃 후보(커버리지 100%) but site-이질**
- 의미: CDR Global은 전 코호트 100% 커버 → 공통 타깃 가능. 단 site 간 분포 크게 이질 → CDR이 site를 학습할 위험.
- 이해: `notebooks/05_cdr_common_target.ipynb`(전체)
- 견고성: ⭐⭐ (타당성 검토, 실험 미확정)

**INSIGHT 9 — 왜 RL이 어려운가 (종합)**
- 의미: 라벨 불균형 + site domain shift + 3D 고차원 signal dilution(AD-sensitive voxel ≈0.28%) + label noise(CDR↔dx 불일치) + MCI 이질성.
- 이해: **`notebooks/04_repr_learning_challenges.ipynb`**(6 challenge + 전략, 이 축의 종합) · `research_data_tutorial.ipynb`(입문 버전)
- 견고성: ⭐⭐⭐

### ⚪ 데이터 quirks (디버깅 시 참조)
- sex 코딩 이질(ADNI/NACC/AIBL/OASIS=M/F, A4=Male/Female, **AJU=0/1 정수[0=F,1=M]**, KDRC=결측) → README "검증 중 발견한 데이터 사실", `consortiums/{C}/_01`
- FastSurfer **eTIV 미산출** → ICV는 `MaskVol` 프록시 (cross-site 정규화 한계)
- FastSurfer 경로 `.0` 접미사 trap → `final_tensor_path`에서 t1w 디렉토리 유도 (session_id 재구성 금지)
- 출처: `Clinical/README.md` "검증 중 발견한 데이터 사실" 표

---

## 노트북 인벤토리 (위치 그대로)

| 그룹 | 위치 | 개수 | 내용 |
|---|---|---|---|
| 교차코호트 체인 | `notebooks/00~06` | 7 | 00 manifest_alignment(master_df 기반)→01 overview→02 image↔clinical→03 ROI volume→04 RL challenges→05 CDR target→06 ComBat. **의존체인: 00 먼저** |
| 코호트별 deep EDA | `consortiums/{7}/_0{1,2,3}` | 21 | 01 clinical EDA·join / 02 MRI·ROI voxel / 03 3D render. **7코호트 동일 템플릿** |
| 스터디(최신, N4 manifest) | `studies/` (→ [`studies/README.md`](studies/README.md)) | 5 | research_data_tutorial(**새 실험 입문**) · roi_anatomy_tutorial · data_quant_study · qc_scanner_render_study · dkt_cortex_extraction |
| roi_qc QC 검수 (별도 계보) | `../roi_qc/notebooks/roi_inspection.ipynb` (→ [README](../roi_qc/notebooks/README.md)) | 1 | roi_usability별 MRI↔ROI↔manifest 단건 검수. roi_qc 도구(Clinical 튜토리얼 아님), `roi_verify_viz.py`와 한 쌍. 경로 절대화 완료(CWD 독립) |

실행: `base`(`/opt/conda`) 파이썬, 헤드리스 `nbconvert --execute`. `common/`은 절대경로(`/home/vlm/minyoungi/Clinical`)로 import.

---

## 연결 문서
- 모델링 규칙(권위): `../roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md`
- harmonization 실험 9종: `../roi_qc/experiments/harmonization/README.md`
- ROI 게이트 절차: `VOXEL_ANALYSIS_PLAN.md`
- 데이터 사실/경고 상세: `README.md`
- memory: `scanner-site-bias-axes`, `roi-blocked-provisional`, `manifest-acq-voxel-site`, `clinical-manifest-join`
