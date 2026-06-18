# DATASET CARD — canonical manifest

_실측 기준: `official_manifest_full_n4_real_final.parquet` 직접 inspect (2026-06-18).
이전 `*.datadict.csv`(2026-06-10)는 stale(컬럼 수·일부 coverage 불일치) → **이 문서가 우선**._

| | |
|---|---|
| 파일 | `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet` |
| shape | **13,022 행 × 141 열** |
| 행 단위 | 1행 = 1 세션(subject × session). unique 키 = `tag` |
| subjects | 7,231 |
| 코호트(7) | ADNI 4,742 · NACC 1,866 · A4 1,811 · OASIS 1,420 · AJU 1,287 · AIBL 987 · KDRC 909 |
| QC | 전 행 `final_qc_status`=`fs_qc_status`=PASS |
| 로더 | `Clinical/common/mri_io.py::load_manifest()` |

관련 문서: 경로·디스크 레이아웃 = [`MANIFEST_AND_DATA_PATHS.md`], 코호트별 raw 보유 = [`MANIFEST_FINAL_DATA_SPEC.md`].

---

## 1. Feature type 분류 체계

각 컬럼을 아래 7개 type 중 하나로 분류한다. **모델 입력 가능 여부와 leakage 위험은 type이 아니라 task가 결정**한다(§4·[`TASK_CARD.md`]).

| type | 정의 | 모델 입력 |
|---|---|---|
| `ID` | 식별자(코호트·subject·session·tag) | ❌ 절대 금지(정체성 leakage) |
| `PATH` | 디스크 파일 경로 문자열 | 텐서 **내용**은 입력(이미지 모델), 경로 **문자열**은 금지 |
| `QC` | 품질관리 메타데이터 | ❌ (필터링 용도, feature 아님) |
| `MORPH` | T1 유래 FastSurfer 부피 | ✅ tabular baseline 예측자 (단, 이미지와 동시 사용 시 double-dip 주의) |
| `ACQ` | 획득 메타(scanner·voxel·N4·bias) | ⚠️ site-shortcut/confounder — 통제 변수로만 |
| `CLIN` | 인구통계·인지·진단 | task별 상이(predictor 또는 forbidden) |
| `BIOMARK` | amyloid·tau·Fazekas·Braak 등 | ⚠️ 대부분 **label** 또는 label-인접 |

---

## 2. 전체 컬럼 목록 (141)

coverage% = 전체 13,022행 대비 non-null. `leak` 열 = leakage/shortcut 위험 등급(§3).

### 2.1 식별자 · 경로 · QC

| # | column | dtype | cov% | type | leak | 의미 |
|--:|---|---|--:|---|---|---|
| 0 | consortium | object | 100 | ID | 🔴 | 코호트(7). 단독으로 amyloid 유병률·dx 분포 leak |
| 1 | subject_id | object | 100 | ID | 🔴 | 피험자 ID(7,231) |
| 2 | session_id | object | 100 | ID | 🔴 | 세션 ID(5,623 unique) |
| 3 | qc_t1w_key | object | 100 | ID | 🔴 | `consortium\|subject\|session` 합성키 |
| 12 | tag | object | 100 | ID | 🔴 | unique 행 키(13,022) |
| 4 | final_tensor_path | object | 100 | PATH | 🔴문자열 | z-score T1(N4 미적용) 텐서 경로 |
| 5 | final_mask_path | object | 100 | PATH | 🔴문자열 | 위 brain mask |
| 75 | final_tensor_n4_path | object | 100 | PATH | 🔴문자열 | **N4+z-score T1 (모델 입력 권장)** |
| 76 | final_mask_n4_path | object | 100 | PATH | 🔴문자열 | 위 brain mask |
| 133 | raw_t1_path | object | 39.4 | PATH | 🔴문자열 | 전처리 이전 T1 원본 |
| 134 | raw_flair_path | object | 25.9 | PATH | 🔴문자열 | FLAIR 원본 |
| 135 | raw_t2_path | object | 6.3 | PATH | 🔴문자열 | T2 원본 |
| 136 | raw_dwi_path | object | 13.2 | PATH | 🔴문자열 | DWI/DTI 원본 |
| 137 | raw_pet_path | object | 6.9 | PATH | 🔴문자열 | amyloid PET 원본 |
| 6 | final_qc_status | object | 100 | QC | – | 전 행 PASS(상수) |
| 7 | fs_qc_status | object | 100 | QC | – | 전 행 PASS(상수) |
| 13 | n_numeric_qc_pass_rois | float64 | 99.7 | QC | – | 통과 ROI 수 |
| 14 | numeric_all_required_rois_pass | object | 99.7 | QC | – | 필수 ROI 전수 통과 여부 |
| 15 | numeric_failed_rois | object | 0.04 | QC | – | 실패 ROI 목록(5행만) |
| 16 | roi_numeric_qc_covered | bool | 100 | QC | – | ROI QC 적용 여부 |
| 17 | voxelwise_qc_candidate | bool | 100 | QC | – | voxel-wise QC 후보 |
| 18 | auto_verdict | object | 99.7 | QC | – | 자동 QC 판정 |
| 19 | auto_reasons | object | 99.7 | QC | – | 판정 사유 |
| 20 | max_pairwise_leak | float64 | 99.7 | QC | – | ROI 간 누출 지표(상수 0) |
| 21 | vision_category | object | 0.35 | QC | – | 시각 검수 범주(46행) |
| 22 | vision_note | object | 0.12 | QC | – | 시각 검수 노트(16행) |
| 23 | roi_usability | object | 100 | QC | – | USABLE_AUTO 등 5범주 |
| 24 | roi_final_ready | bool | 100 | QC | – | 상수 False |
| 58 | fs_stats_found | bool | 100 | QC | – | 상수 True |
| 59 | clin_matched | bool | 100 | QC | – | 임상 조인 성공 여부 |
| 60 | clin_level | object | 90.9 | QC | ⚠️ | **조인 단위 = `subject_firstnonnull`** → §5 전환-task 경고 |
| 73 | tensor_exists | bool | 100 | QC | – | 상수 True |
| 74 | mask_exists | bool | 100 | QC | – | 상수 True |

### 2.2 MORPH — FastSurfer 부피 (33열, 전부 float64 / cov ≈100%)

전부 **N4+z-score 이전 native T1**에서 FastSurfer로 산출. `MORPH` type, leak 등급 🟡(이미지 모델과 동시 사용 시 동일 정보 double-dip; tabular-only baseline에서는 정당).

- 전역(7): `fs_MaskVol`(eTIV proxy — 진짜 eTIV 부재, [[fastsurfer-vinn-no-etiv]]), `fs_BrainSegVol`, `fs_BrainSegVolNotVent`, `fs_SupraTentorialVol`, `fs_SupraTentorialVolNotVent`, `fs_SubCortGrayVol`, `fs_CerebralWhiteMatterVol`
- 피질하 L/R(8): `fs_vol_{lateral_ventricle,inf_lat_vent,thalamus,hippocampus,amygdala}_{L,R}`
- 피질 ROI L/R(18): `fs_vol_{entorhinal,fusiform,inferiortemporal,isthmuscingulate,middletemporal,parahippocampal,posteriorcingulate,precuneus}_{L,R}`

> ⚠️ `lateral_ventricle`(뇌실)은 **위축 confound**의 핵심 — Track04에서 뇌실 보정 시 headline 붕괴([[vascular-snap-track04]]). confounding verifier 필수 통제 대상([`VERIFIER_SPEC.md`]).

### 2.3 CLIN — 인구통계·인지·진단

| # | column | dtype | cov% | leak | 의미 / 값 |
|--:|---|---|--:|---|---|
| 8 | cdr_global | object | 100 | 🟡 | CDR 전역(0/0.5/1/2/3). **visit-level**(§5) |
| 9 | cdrsb | object | 100 | 🟡 | CDR sum-of-boxes(31값). visit-level |
| 10 | cdr_source | object | 100 | – | visit_level_v7 6,137 / baseline_broadcast 4,165 / raw_a4_cdr 1,811 / raw_kdrc 909 |
| 11 | cdr_source_table | object | 100 | – | CDR 원천 테이블 |
| 61 | clin_sex | string | 98.9 | 🟢 | F/M |
| 62 | clin_sex_raw | string | 91.2 | – | 원본 성별 코드 |
| 63 | clin_age | float64 | 98.6 | 🟡 | 연령(주요 confounder) |
| 64 | clin_dx_label | string | 96.6 | 🔴 | **진단**: CN 5,769 · MCI 3,980 · CN_preclinical 1,811(A4) · AD 804 · Dementia 165 · ImpairedNotMCI 54. ⚠️**subject-단위**(§5) |
| 65 | clin_dx_raw | object | 67.1 | 🔴 | 원본 진단 문자열 |
| 66 | clin_mmse | float64 | 87.1 | 🟡 | MMSE(인지 — 강한 dx/amyloid proxy) |
| 67 | clin_cdrsb | float64 | 70.8 | 🟡 | CDR-SB(정제판) |
| 68 | clin_education | object | 38.1 | 🟢 | 교육연수(결측多) |
| 69 | clin_moca | object | 14.3 | 🟡 | MoCA(NACC만) |
| 70 | clin_apoe | object | 86.9 | 🟢 | APOE 유전형(E3/E3 등). amyloid/전환 정당 예측자 |
| 71 | clin_apoe_e4n | object | 66.0 | 🟢 | APOE e4 대립유전자 수(0/1/2) |
| 72 | clin_source | object | 90.9 | – | 임상 조인 출처 |
| 97 | clin_sex_source | string | 98.9 | – | 출처 |
| 98 | clin_age_source | string | 98.6 | – | 출처(상수 original_join) |
| 99 | clin_dx_source | string | 96.6 | – | 출처 |
| 100 | clin_cdrsb_source | string | 70.8 | – | 출처 |
| 106 | clin_apoe_source | object | 73.0 | 🟠 | 출처 — **코호트 지문**(어느 코호트인지 leak) |
| 107 | clin_mmse_source | object | 60.1 | 🟠 | 출처 — 코호트 지문 |
| 108 | clin_education_source | object | 9.9 | 🟠 | 출처 — 코호트 지문 |

### 2.4 ACQ — 획득 메타 (scanner·voxel·N4·bias)

전부 site/scanner-shortcut 위험. leak 🟠(코호트·scanner 정체성 → label로 우회 누출).

| # | column | dtype | cov% | 의미 |
|--:|---|---|--:|---|
| 77 | n4_grid_match_frac | float64 | 100 | N4 격자 일치율 |
| 78 | n4_zmean | float64 | 100 | N4 후 z-mean |
| 79 | n4_zstd | float64 | 100 | 상수 1.0 |
| 80 | n4_meanabs_diff_vs_baseline | float64 | 100 | N4 전후 평균절대차 |
| 81 | bias_ratio_min | float64 | 100 | bias field 비율 최소 |
| 82 | bias_ratio_max | float64 | 100 | 최대 |
| 83 | bias_ratio_mean | float64 | 100 | 평균 |
| 84 | brain_voxel_loss_ratio | float64 | 100 | 뇌 voxel 손실율(상수 0) |
| 85–91 | vox_{x,y,z,min,max,aniso,mean} | float64 | 100 | native voxel 해상도(해상도 = N4와 독립 site 축, [[manifest-acq-voxel-site]]) |
| 92 | vox_source | object | 100 | 상수 hdbet |
| 93 | acq_scanner_raw | string | 88.9 | scanner vendor 원문(12종) |
| 94 | acq_scanner | string | 96.9 | scanner vendor 정규화(7종) |
| 95 | acq_field_strength | float64 | 88.5 | 자장 강도(1.5/3T) |
| 96 | acq_scanner_source | string | 100 | scanner 출처 |
| 138 | acq_scanner_model | string | 72.1 | scanner 모델 family(17종, 예 Siemens Prisma) |
| 139 | acq_scanner_model_raw | string | 72.1 | DICOM 원문 모델명(41종) |
| 140 | acq_scanner_model_source | string | 100 | 모델 출처 |

> [[scanner-site-bias-axes]]: site는 픽셀(probe 0.556)보다 **메타데이터(0.761)** 에 더 박혀 있음. N4는 잔차 0.517까지만 감소. ACQ 컬럼 = 가장 직접적 shortcut 통로.

### 2.5 BIOMARK + 코호트별 파생 (대부분 LABEL 또는 코호트 지문)

| # | column | dtype | cov% | 코호트 | 의미 / 클래스 분포 |
|--:|---|---|--:|---|---|
| 101 | kdrc_clinical_matched | bool | 100 | KDRC | 조인 플래그 |
| 102 | kdrc_amyloid_suvr | float64 | 6.6(856) | KDRC | amyloid SUVR(연속) |
| 103 | kdrc_amyloid_visual | object | 7.0(909) | KDRC | **Positive 417 / Negative 492** |
| 104 | kdrc_fazekas_pv | object | 5.1(662) | KDRC | 뇌실주위 Fazekas(0–3) |
| 105 | kdrc_fazekas_deep | object | 5.1(661) | KDRC | 심부 Fazekas(0–3) |
| 109 | adni_mmse_gap_days | float64 | 35.9 | ADNI | MMSE-스캔 시차(코호트 지문) |
| 110 | aju_dx_sdcode | float64 | 9.9 | AJU | 진단 코드(21종) |
| 111 | aju_dx_detail | object | 9.9 | AJU | 진단 상세(21종) |
| 112 | aju_dx3 | object | 9.9 | AJU | AJU 3분류 dx(AJU dx 권위 — `clin_dx_label`은 AJU에서 함정, [[korean-cohort-enrichment-v3]]) |
| 113 | aju_amyloid | object | 9.9(1286) | AJU | **positive 435 / negative 851**(visual) |
| 114 | aju_cdr_global | float64 | 9.9 | AJU | AJU CDR |
| 115 | aju_gds | float64 | 9.9 | AJU | 우울척도 GDS |
| 116 | aju_mmse_visit | object | 9.9 | AJU | MMSE visit(bl/tfu) |
| 117 | oasis_mmse_gap_days | float64 | 10.9 | OASIS | MMSE-스캔 시차 |
| 118 | oasis_amyloid_centiloid | float64 | 8.0(1048) | OASIS | centiloid(연속) |
| 119 | oasis_amyloid_positive | object | 8.0(1048) | OASIS | **positive 330 / negative 718** |
| 120 | oasis_amyloid_tracer | object | 8.0 | OASIS | PIB/AV45 |
| 121 | oasis_amyloid_gap_days | float64 | 8.0 | OASIS | amyloid-스캔 시차 |
| 122 | a4_amyloid_suvr | float64 | 13.9(1811) | A4 | SUVR(연속, 72값) |
| 123 | a4_amyloid_positive | object | 13.9(1811) | A4 | ⚠️**positive 1811 (전원 양성, n_unique=1)** — §4 참조 |
| 124 | nacc_amyloid_centiloid | float64 | 4.0(515) | NACC | centiloid(연속) |
| 125 | nacc_amyloid_positive | float64 | 4.0(515) | NACC | **1=201 / 0=314** |
| 126 | nacc_amyloid_tracer_code | float64 | 4.0 | NACC | tracer 코드(2–5) |
| 127 | oasis_animals | float64 | 10.6 | OASIS | 동물이름대기(인지) |
| 128 | oasis_moca | float64 | 2.9 | OASIS | MoCA |
| 129 | oasis_braak1_2 | float64 | 1.1(148) | OASIS | tau PET Braak I–II |
| 130 | oasis_braak3_4 | float64 | 1.1(148) | OASIS | Braak III–IV |
| 131 | oasis_braak5_6 | float64 | 1.1(148) | OASIS | Braak V–VI |
| 132 | oasis_braak_tauopathy | float64 | 1.1(148) | OASIS | tauopathy 지표 |

---

## 3. Leakage-risk 컬럼 등급표

| 등급 | 의미 | 컬럼군 |
|---|---|---|
| 🔴 직접 | 정체성/라벨/경로문자열 — 어떤 task에서도 feature 금지 | `consortium`, `subject_id`, `session_id`, `qc_t1w_key`, `tag`, 모든 `*_path`(문자열), `clin_dx_label`/`clin_dx_raw`(전환 task 라벨), task별 amyloid 라벨열 |
| 🟠 코호트 지문 | non-null 패턴/값이 코호트를 특정 → 정체성 우회 leak | 모든 `kdrc_*`/`aju_*`/`oasis_*`/`a4_*`/`nacc_*`/`adni_*`, `clin_*_source`, `*_gap_days`, `cdr_source*`, ACQ 전체(`acq_*`,`vox_*`,`n4_*`,`bias_*`) |
| 🟡 proxy | label과 강상관(인지·연령·morphometry) — task별 forbidden 또는 통제 | `clin_mmse`,`clin_moca`,`cdr_global`,`cdrsb`,`clin_cdrsb`,`clin_age`, `fs_*`(특히 `fs_vol_*hippocampus*`,`*lateral_ventricle*`) |
| 🟢 일반 | 정당 예측자(공정성 통제 필요) | `clin_sex`,`clin_education`,`clin_apoe`,`clin_apoe_e4n` |

> 핵심 함정 3가지(검증 자동화 대상):
> 1. **경로 문자열 leak** — `*_path`에 `/ADNI/`,`/AJU/`, subject_id가 박혀 있음. 문자열을 feature로 흘리지 말 것.
> 2. **코호트 지문 leak** — 코호트별 컬럼의 *결측 패턴 자체*가 코호트 라벨. amyloid 유병률이 코호트마다 다르므로(§4) 코호트 ID = label 우회.
> 3. **중복 세션 leak** — content-hash 동일 4쌍, 그 중 **AJU cross-subject 2쌍**(`ABD-BS-0013≡0014`, `ABD-AJ-0029≡0030`)은 subject 분할로도 안 잡힘. split 전 collapse 필수([`MANIFEST_AND_DATA_PATHS.md`] §6, [[preproc-tensor-qc-duplicates]]).

---

## 4. Outcome 가용성 요약 (task 정의 → [`TASK_CARD.md`], 실측 audit → [`ENDPOINT_FEASIBILITY.md`])

> task 번호는 [`TASK_CARD.md`]의 3-status 체계를 따른다(여기 amyloid=Task3, 전환=Task2). 아래는 데이터 사실만.

**Amyloid positivity outcome** (양·음 둘 다 존재해 분류 가능한 코호트):

| 코호트 | column | positive | negative | 합 | 비고 |
|---|---|--:|--:|--:|---|
| AJU | aju_amyloid | 435 | 851 | 1,286 | visual read |
| KDRC | kdrc_amyloid_visual | 417 | 492 | 909 | visual read |
| OASIS | oasis_amyloid_positive | 330 | 718 | 1,048 | + centiloid 연속 |
| NACC | nacc_amyloid_positive | 201 | 314 | 515 | 0/1 |
| **소계(분류가능)** | | **1,383** | **2,375** | **3,758** | |
| A4 | a4_amyloid_positive | 1,811 | 0 | 1,811 | ⚠️**전원 양성 → 코호트 내 분류 불가**, 양성 예시·external로만 |
| ADNI | (manifest 부재) | — | — | — | UCBERKELEY_AMY 외부조인 필요(~1,203, [[manifest-real-final]]) |

**MCI→AD 전환 outcome**: 진단 분포는 §2.3 `clin_dx_label`. 단 전환 정의는 종단 라벨 필요 → §5의 치명적 제약 참조.

---

## 5. ⚠️ Missingness & 종단-라벨 치명적 제약

### 5.1 결측 요약 (cov% 낮은 순, 분석 영향 큰 것)
- 코호트-한정 컬럼(`*_amyloid_*`, `aju_*`, `kdrc_*`, braak 등): 1–14% — **결측이 아니라 해당 코호트에만 존재**(구조적). pooled 분석 시 코호트 교집합이 작음.
- 임상 결측(진짜 공백): `clin_education` 38%, `clin_moca` 14%, `clin_cdrsb` 71%, `clin_apoe_e4n` 66%, `clin_mmse` 87%(KDRC 52.5%·NACC 16%이 끌어내림), `clin_dx_label` 96.6%(KDRC 84.7%·OASIS 85%).
- ACQ: `acq_field_strength` 88.5%(KDRC 0%), `acq_scanner_model` 72%(A4/OASIS 소스에 모델 없음).
- 결측은 **백필하지 않고 유지**가 원칙([`MANIFEST_AND_DATA_PATHS.md`] §6). 결측 자체가 코호트 지문(§3 🟠)임에 주의.

### 5.2 🔴 전환 task를 막는 manifest 구조 (실측, 2026-06-18)
- `clin_dx_label`은 `clin_level=subject_firstnonnull`로 조인됨 → **subject당 사실상 단일 라벨**.
  - 다중세션 subject 중 `clin_dx_label`이 세션 간 변하는 수: **ADNI 0 / NACC 0 / A4 0 / AIBL 0** (AJU 31·OASIS 27만 예외).
  - 실측: ADNI에서 `clin_dx_label` 시퀀스가 MCI→AD인 subject = **0건**.
  - ⇒ **manifest의 `clin_dx_label`만으로는 전환을 정의할 수 없음.**
- visit-level 신호는 **`cdr_global`/`cdrsb`** 에만 존재(`cdr_source=visit_level_v7` 6,137행). 세션 간 `cdr_global` 변동 subject: ADNI **339** · NACC 51 · OASIS 56 · **AJU 0**.
- 종단 구조: ADNI(다중세션 849 subj, 최대 16) ≫ OASIS 363 · NACC 361 · AJU 286(최대 **2**) · AIBL 178 · **KDRC 0(단일세션)**.
- ⇒ 전환 task는 (a) per-visit 진단을 원천(ADNI DXSUM·NACC UDS·OASIS UDSd1)에서 **재조인**하거나 (b) visit-level CDR 진행을 proxy로 정의해야 하며, 현실적으로 **ADNI 중심·Western 코호트**에서만 성립. **한국 코호트(KDRC 종단 0, AJU 최대 2세션)는 전환 task 부적합**([[sci-clinical-pivot]]: "Korean 종단 없음 → 예후 external 불가").

---

## 6. 검증 로그 (generation ≠ verification)
- 모든 수치 = `pd.read_parquet` 직접 inspect 3-패스(`/tmp/inspect_manifest.py`,`inspect2.py`,`inspect3.py`, 2026-06-18). 코호트 카운트·dx 분포·amyloid 클래스·세션-내 dx/CDR 변동·전환 시퀀스 0건 전부 재실행 확인.
- stale 소스 식별: `*.datadict.csv`(2026-06-10)는 컬럼 수(127<141)·일부 coverage 불일치 → 채택 안 함.
- ⚠️ 미검증: 본 카드는 **manifest 내부 구조**만 확인. 외부조인(ADNI amyloid)·per-visit dx 재조인은 별도 검증 필요([`EVALUATION_PROTOCOL.md`] external validation).
