# 다기관 Glioma 데이터 EDA 및 공통 활용 변수 정리

생성일: 2026-06-18

이 문서는 `data/` 하위 로컬 다운로드 데이터와 metadata/path 구조를 기반으로 작성한 1차 EDA 요약이다. 아직 image voxel/header를 로딩하지 않았고, outcome/cohort/split도 확정하지 않았다.

## 산출물

- `docs/context/build_data_eda.py`: EDA 재현 스크립트
- `docs/context/eda_dataset_inventory.csv`: 데이터셋별 실제 파일/단위 inventory
- `docs/context/eda_imaging_inventory.csv`: modality/file type별 coverage
- `docs/context/eda_variable_profile.csv`: metadata 모든 컬럼의 missingness, cardinality, numeric summary, top values
- `docs/context/eda_common_variable_matrix.csv`: 공통 변수 후보별 dataset coverage matrix
- `docs/context/eda_summary.md`: 자동 생성 요약 보고서
- `docs/context/build_manifest_and_harmonization.py`: canonical manifest 및 label harmonization audit 생성 스크립트
- `docs/context/canonical_manifest.csv`: NIfTI, DICOM, histopath를 포함한 통합 manifest
- `docs/context/label_harmonization_audit.csv`: 모델링 후보 단위별 raw/harmonized label audit
- `docs/context/label_harmonization_counts.csv`: harmonized label별 unit row 및 unique subject count
- `docs/context/label_harmonization_subject_conflicts.csv`: 동일 subject 내 label 충돌 audit
- `docs/context/manifest_harmonization_summary.md`: manifest/harmonization 자동 요약

## 1. 데이터 단위와 규모

| 데이터셋 | 기본 분석 단위 | 실제 데이터 규모 | 핵심 주의점 |
|---|---:|---:|---|
| UTSW | subject | 625 subjects, 6,349 NIfTI | 단일 subject-level metadata. `Operation Status`는 전부 `PRE`. |
| MU-Glioma-Post | subject-timepoint | 203 subjects, 596 path timepoints, 2,978 NIfTI | post-treatment longitudinal 구조. scanner metadata는 654 rows로 path timepoint 596개보다 많아 reconciliation 필요. |
| UCSD-PTGBM | subject-session | 178 subjects, 243 sessions, 5,369 NIfTI | v1 136 subjects/184 sessions, BraTS test 42 subjects/59 sessions. subject/session overlap 없음. |
| UPENN-GBM NIfTI | scan_id | 630 subjects, 671 scan IDs, 10,646 NIfTI | scan-level clinical/acquisition table. 같은 subject의 baseline/recurrence 가능성 있음. |
| UPENN-GBM DICOM | series | 630 subjects, 3,301 studies, 3,680 series, 828,234 DICOM files | NIfTI와 중복 표현이므로 split/모델링에서 중복 누수 방지 필요. |
| UPENN-GBM Histopath | slide | 71 NDPI | `radiology_mapping.csv` 71 rows와 연결됨. UPENN 내부 multimodal subset. |

## 2. 공통 활용 가능 변수

### 바로 공통 baseline으로 쓸 수 있는 후보

| 변수/정보 | Coverage 요약 | 판단 |
|---|---|---|
| Age | UTSW 625/625, MU 203/203, UCSD 243/243, UPENN 671/671 | 가장 안정적. 단, age 기준이 imaging/diagnosis/scan으로 다르므로 명칭 분리 필요. |
| Sex/Gender | 전 데이터셋 100% | 안정적. `M/F`, `Male/Female` harmonization 필요. |
| Core structural MRI | UTSW 625/625, MU 596/596 timepoints, UCSD 243/243 sessions, UPENN 671/671 scans | 가장 현실적인 pooled image baseline. T1/T1c/T2/FLAIR 명칭 통일 필요. |
| Scanner manufacturer/model/field strength | 대체로 높음. MU는 scanner-row 단위, 나머지는 subject/session/scan 단위 | pooled model에서 confounder/stratification 변수로 필수. |

### 공통이지만 harmonization이 필요한 후보

| 변수 | Coverage | 해석 |
|---|---:|---|
| Primary diagnosis | UTSW/MU/UCSD는 explicit, UPENN은 collection 자체가 GBM-only | pan-glioma diagnosis/grade task에는 UPENN을 조심해야 함. |
| Tumor grade | UTSW 618/625, MU 203/203, UCSD 243/243, UPENN 0/671 | UPENN은 grade variation source가 아님. |
| IDH | UTSW 622/625, MU 203/203, UCSD 168/243, UPENN 565/671 | 좋은 molecular prediction 후보. 단 value vocabulary가 다름. |
| MGMT | UTSW 281/625, MU 203/203, UCSD 149/243, UPENN 291/671 | usable하지만 missingness가 큼. MU code dictionary 확인 필요. |
| 1p/19q | UTSW 335/625, MU 203/203, UCSD 112/243, UPENN 없음 | UPENN 제외 분석에서만 공통 후보. |
| ATRX | MU 203/203, UCSD 114/243만 존재 | 전체 공통 변수는 아님. |

### Outcome 후보

| Outcome | 사용 가능 데이터 | 판단 |
|---|---|---|
| Overall survival | MU 203/203, UCSD 219/243, UPENN 452/671, UTSW 없음 | survival 연구는 UTSW 제외 또는 UTSW unlabeled 처리 필요. 기준일이 diagnosis/acquisition/surgery로 달라 정렬 필요. |
| Progression/PFS | MU 203/203, UCSD 87/243, UPENN PsP/TP 60/671, UTSW 없음 | 공통 progression task로 바로 묶기 어렵다. dataset별 의미가 다름. |
| Treatment variables | MU/UCSD 일부, UPENN extent of resection, UTSW 없음 | 치료 반응 모델은 cohort별 별도 설계가 필요. |

## 3. 영상 정보 현황

### Structural MRI

- UTSW: `brain_t1`, `brain_t1ce`, `brain_t2`, `brain_flair` 및 ants 버전이 각 625/625.
- MU: `brain_t1c`, `brain_t1n`, `brain_t2f`, `brain_t2w`가 596/596 timepoints.
- UCSD: `T1pre`, `T1post`, `T2`, `FLAIR`가 243/243 sessions.
- UPENN: structural imaging 671/671 scan IDs. NIfTI에는 stripped/unstripped structural set이 모두 있음.

### Segmentation

- UTSW: `tumorseg_FeTS` 625/625, manual correction 계열 362/625.
- MU: `tumorMask` 594/596 timepoints. 2개 timepoint는 tumorMask 파일이 없음.
- UCSD: BraTS tumor segmentation 및 cellular tumor segmentation 계열이 243/243.
- UPENN: automatic segmentation 611/671, corrected segmentation 232/671.

### Advanced imaging

- UCSD: diffusion/perfusion 계열이 가장 풍부하다. ADC/DWI/RSI/DSC/ASL/CBF/CBV는 거의 전 session에서 존재한다.
- UPENN: DTI 592/671, DSC 534/671.
- UTSW/MU: 현재 path 기준으로 DTI/perfusion 공통 baseline에는 포함하기 어렵다.

## 4. 데이터셋별 요약

### UTSW

- Clinical rows: 625 subjects.
- Sex: M 371, F 254.
- Diagnosis: GLIOBLASTOMA 387이 가장 많고, astrocytoma/oligodendroglioma 등 다양한 glioma subtype 포함.
- Grade: grade 4 = 420, grade 3 = 97, grade 2 = 101.
- IDH: wild type 446, mutated 176.
- MGMT: methylated 114, unmethylated 167, coverage 281/625.
- 영상은 core structural MRI와 FeTS segmentation이 전 subject에 있다.
- Outcome/survival/progression column은 현재 metadata에 없음.

### MU-Glioma-Post

- Clinical rows: 203 subjects.
- Path timepoints: 596, scanner metadata rows: 654.
- Primary diagnosis: GBM 157, Astrocytoma 28, Diffuse glioma 10 등.
- Grade: grade 4 = 168, grade 2 = 28, grade 3/4 혼합 코드 존재.
- Progression: 152/203.
- Overall Survival death flag: death 97, alive/censored로 보이는 0이 106.
- IDH/MGMT/1p19q/ATRX는 모두 코드형 값으로 들어 있어 data dictionary 기반 decoding이 필요하다.
- Longitudinal/post-treatment 데이터라 subject-level split과 temporal ordering 확인이 필수다.

### UCSD-PTGBM

- Clinical rows: 243 sessions, unique subject는 178명.
- v1과 BraTS test package는 subject/session overlap이 없다.
- 대부분 GBM: Primary Diagnosis Glioblastoma 235/243, Grade 4 240/243.
- MGMT 149/243, IDH 168/243, 1p19q 112/243, ATRX 114/243.
- OS는 219/243, PFS는 87/243만 현재 missing-token 제거 후 사용 가능.
- GE 3T 중심 데이터라 scanner/site confounding이 강할 수 있다.

### UPENN-GBM

- NIfTI clinical/acquisition rows: 671 scan IDs, 630 subjects.
- DICOM: 3,680 series, 828,234 actual files, metadata image count와 실제 파일 수 일치.
- GBM-only cohort라 diagnosis/grade variation을 학습하는 데이터로 쓰면 안 된다.
- IDH1 available 565/671, MGMT available 291/671.
- Overall Survival available 452/671.
- Structural imaging은 671/671, DTI 592/671, DSC 534/671, automatic segmentation 611/671, corrected segmentation 232/671.
- Histopath 71 NDPI는 UPENN subset multimodal 연구에만 사용 가능하다.

## 5. 현재 기준으로 가능한 연구 방향 후보

1. Structural MRI 공통 representation / segmentation-aware modeling
   - UTSW, MU, UCSD, UPENN 모두 포함 가능.
   - 단위는 subject/session/scan으로 다르므로 먼저 canonical manifest가 필요하다.

2. IDH prediction
   - 모든 주요 cohort에서 존재하지만 UCSD/UPENN missingness가 있다.
   - pan-glioma로 할지 GBM-only로 할지 먼저 정해야 한다.

3. MGMT prediction
   - coverage가 낮은 cohort가 많아 missingness-aware cohort definition이 필요하다.
   - MU/UTSW/UCSD/UPENN value vocabulary 통합이 선행되어야 한다.

4. Survival modeling
   - MU, UCSD, UPENN 중심으로 가능.
   - time origin이 diagnosis/acquisition/surgery로 다르므로 바로 pooling하면 안 된다.

5. Advanced imaging comparison
   - UCSD와 UPENN 중심으로 diffusion/perfusion 연구 가능.
   - UTSW/MU까지 포함한 전체 공통 baseline은 아님.

6. Radiology-histopath subset
   - UPENN 71 slide subset에서만 가능.
   - 전체 다기관 모델의 primary direction으로 삼기에는 coverage가 작다.

## 6. 다음에 반드시 해야 할 검증

1. Canonical manifest 생성
   - `dataset`, `subject_id`, `session_id/timepoint`, `scan_id`, `paths`, `available_modalities`, `clinical_row_key`를 한 행 단위로 정리.

2. Label harmonization
   - sex, race/ethnicity, diagnosis, grade, IDH, MGMT, 1p/19q, ATRX의 코드북/값 통합.
   - MU molecular code는 dictionary 해석 없이 모델 label로 쓰면 안 된다.

3. Image header audit
   - NIfTI shape, affine, orientation, spacing, channel mapping 확인.
   - DICOM은 series-level metadata와 대표 header만 별도 점검.
   - 이 단계는 파일 헤더를 많이 읽으므로 실행 전 command preview와 범위 확인이 필요하다.

4. Split policy 확정
   - subject-isolated split이 기본.
   - MU/UCSD longitudinal session, UPENN recurrence/baseline, DICOM/NIfTI 중복으로 인한 leakage를 방지해야 한다.

5. Outcome/cohort 확정
   - classification인지 survival인지, pan-glioma인지 GBM-only인지, multi-session을 어떻게 다룰지 먼저 결정해야 한다.

## 7. Canonical manifest 및 label harmonization audit 결과

`canonical_manifest.csv`는 총 5,886 rows로 생성되었다.

| dataset | representation | unit_type | rows |
|---|---|---:|---:|
| UTSW | nifti | subject | 625 |
| MU-Glioma-Post | nifti | subject-timepoint | 596 |
| UCSD-PTGBM | nifti | subject-session | 243 |
| UPENN-GBM | nifti | scan_id | 671 |
| UPENN-GBM | dicom | series | 3,680 |
| UPENN-GBM | histopath | slide | 71 |

검증 결과:

- 기대 row 수 5,886과 실제 manifest row 수가 일치한다.
- UTSW subject key, MU subject-timepoint key, UCSD session key, UPENN scan_id, UPENN DICOM series_uid, UPENN histopath slide_id 중복은 모두 0건이다.
- manifest의 `path_json`에 포함된 29,077개 path entry는 모두 실제 존재한다.
- UPENN DICOM은 series-level row로 포함했으며, UPENN NIfTI와 중복 표현이므로 모델 split에서 독립 샘플로 취급하면 안 된다.

### Harmonized label subject counts

`label_harmonization_counts.csv`에는 unit row 수와 unique subject 수가 함께 들어 있다. MU처럼 longitudinal timepoint가 있는 데이터는 unit row count가 subject count보다 커지므로, label 분포 해석에는 unique subject count를 함께 봐야 한다.

핵심 subject-level 해석:

- MU IDH: wildtype 161 subjects, mutant 28, unknown 14.
- MU MGMT: unmethylated 97 subjects, methylated 66, indeterminate 11, unknown 29.
- UCSD IDH: wildtype 148 unit rows, mutant 20, unknown 75. unique subject 기준은 별도 count 파일을 사용한다.
- UPENN IDH: wildtype 546 scan rows, mutant 19, unknown 106.
- UTSW IDH: wildtype 446 subjects, mutant 176, unknown 3.

### Subject-level label conflict

`label_harmonization_subject_conflicts.csv`에서 동일 subject 내 harmonized label 충돌이 26 rows 발견되었다.

- UCSD: IDH conflict 2 subjects, MGMT conflict 1 subject, 1p/19q conflict 1 subject.
- UPENN: IDH/MGMT conflict가 여러 multi-scan subject에서 발견됨. 대부분 `unknown`과 known label이 섞인 경우지만, 일부는 `methylated`와 `unmethylated`가 같이 존재한다.

따라서 molecular prediction task를 만들 때는 다음 중 하나를 명시해야 한다.

1. scan/session-level label을 그대로 사용한다.
2. subject-level label을 만들되 known label 우선 규칙을 둔다.
3. subject 내 conflicting label이 있는 case를 제외한다.
4. baseline scan만 쓰는 등 timepoint 정책을 먼저 정한다.

현재 상태에서는 3 또는 4가 가장 보수적이다.

## 8. NIfTI header sample audit 결과

`build_nifti_header_audit.py`를 추가했고, 기본은 sample mode다. 전수 header audit은 장시간 파일 순회가 될 수 있어 실행하지 않았다.

생성 산출물:

- `docs/context/nifti_header_audit_sample.csv`
- `docs/context/nifti_header_audit_sample_summary.md`
- `docs/context/nifti_zero_byte_files.csv`

Sample audit 범위:

- 총 300개 NIfTI header를 dataset/modality_group stratified sample로 읽었다.
- header read error는 sample 내 0건이다.
- 전체 manifest NIfTI path에서 zero-byte 파일은 1개 발견되었다.

Zero-byte 파일:

```text
data/UCSD-PTGBM/PKG - UCSD-PTGBM-BraTS-2024-test-set/UCSD-PTGBM-BraTS-2024-test-set/UCSD-PTGBM-0149_02/UCSD-PTGBM-0149_02_total_cellular_tumor_seg.nii.gz
```

이 파일은 UCSD BraTS test package의 `total_cellular_tumor_seg` segmentation 파일이다. 모델 학습 manifest에서 이 파일은 제외하거나 재다운로드/복구 여부를 확인해야 한다.

Header sample에서 관찰된 geometry:

| dataset | 주요 shape/spacing/orientation | 해석 |
|---|---|---|
| UTSW | 대부분 `240x240x155`, `1x1x1`, `LPS` | 공통 structural grid로 보임. 단 manual segmentation sample 중 `98x146x92`가 있어 segmentation variant 확인 필요. |
| MU-Glioma-Post | `240x240x155`, `1x1x1`, `LPS` | UTSW/UPENN과 같은 grid에 가까움. |
| UCSD-PTGBM | core structural/segmentation은 `256x256x256`, `1x1x1`, `ILA`; raw diffusion/perfusion 일부는 4D low-res | preprocessing 시 UCSD orientation과 raw advanced imaging 처리 분리 필요. |
| UPENN-GBM | 대부분 `240x240x155`, `1x1x1`, `LPS`; perfusion 일부는 `240x240x155x45` | structural/segmentation은 정규화 grid로 보이나 DSC 4D 파일은 별도 처리 필요. |

현재 기준 preprocessing implications:

1. Core structural MRI baseline은 `240x240x155 LPS` 계열과 `256x256x256 ILA` 계열이 섞여 있다.
2. UCSD는 이미 256-cube로 정규화된 파일과 raw 4D diffusion/perfusion이 같이 있어 modality별 inclusion rule이 필요하다.
3. segmentation dtype은 dataset별로 `uint8`, `uint16`, 일부 `float32`가 섞여 있어 label value audit이 필요하다.
4. full preprocessing 전에 전수 header audit으로 shape/orientation/spacing outlier를 모두 확인해야 한다.

전수 audit command preview:

```bash
python docs/context/build_nifti_header_audit.py --mode full
```

이 명령은 `canonical_manifest.csv`의 모든 NIfTI path header를 읽는다. GPU는 사용하지 않지만 storage I/O가 오래 걸릴 수 있으므로 승인 후 실행한다.

## 9. Candidate modeling task feasibility

`build_candidate_task_feasibility.py`를 추가했고, 현재 EDA 산출물만 사용해 후보 task별 사용 가능 규모를 계산했다.

생성 산출물:

- `docs/context/candidate_task_feasibility.csv`
- `docs/context/candidate_task_feasibility.md`

### Imaging-first 후보

| 후보 task | dataset별 규모 | 판단 |
|---|---|---|
| Structural MRI common baseline | UTSW 625 subjects, MU 203 subjects/596 timepoints, UCSD 178 subjects/243 sessions, UPENN 630 subjects/671 scans | 가장 안전한 전체 공통 baseline. |
| Structural + segmentation baseline | UTSW 625, MU 203 subjects/594 usable timepoints, UCSD 178 subjects/242 usable sessions, UPENN 611 subjects/scans | UCSD zero-byte segmentation 1개와 MU missing mask 2개를 제외하면 매우 강한 후보. |
| Advanced diffusion/perfusion | UCSD 178 subjects/243 sessions, UPENN 560 subjects/599 scans | UCSD+UPENN 중심 연구. 전체 consortium 공통 baseline은 아님. |
| Both diffusion and perfusion | UCSD 178 subjects/243 sessions, UPENN 491 subjects/527 scans | advanced imaging 비교/ablation에 적합. |

### Label prediction 후보

| 후보 task | 보수적 eligible subjects | 판단 |
|---|---:|---|
| IDH prediction | UTSW 622, MU 189, UCSD 121, UPENN 525 | 가장 강한 molecular prediction 후보. UCSD 2 subjects, UPENN 9 subjects는 subject-level conflict로 제외 권장. |
| MGMT prediction | UTSW 281, MU 163, UCSD 105, UPENN 266 | 가능하지만 coverage가 낮고 conflict/unknown/indeterminate가 많아 2차 후보. |
| Tumor grade prediction | UTSW 618, MU 201, UCSD 178, UPENN 0 | UPENN 제외 pan-glioma grade task로 가능. UCSD는 대부분 grade 4라 class imbalance 큼. |
| Diagnosis family prediction | UTSW 625, MU 203, UCSD 178, UPENN 0 | UPENN은 GBM-only collection이라 class variation source로 쓰지 않는다. |
| Overall survival time modeling | MU 96 subjects with numeric death duration, UCSD 71 subjects with numeric OS duration, UPENN 603 subjects with numeric survival duration, UTSW 0 | time origin/censor semantics가 달라 바로 pooling 금지. 별도 survival 설계 필요. |

### 현재 기준 우선순위

1. Structural MRI common baseline을 먼저 정리한다.
   - 모든 주요 dataset이 포함되고 label 정의 리스크가 가장 작다.
   - age/sex/scanner/site covariate를 함께 사용할 수 있다.

2. Structural + segmentation baseline을 함께 준비한다.
   - UTSW/MU/UCSD/UPENN 모두 segmentation coverage가 높다.
   - zero-byte UCSD segmentation 1개는 제외 또는 재확인 필요.

3. 첫 supervised molecular task는 IDH가 가장 현실적이다.
   - known mutant/wildtype subject 수가 가장 크다.
   - subject-level conflict를 제외하고 subject-isolated split을 적용해야 한다.

4. MGMT와 survival은 다음 단계로 둔다.
   - MGMT는 missingness가 크다.
   - survival은 time origin과 censor definition이 dataset마다 달라 먼저 통계적 설계가 필요하다.

5. Diagnosis/grade task는 pan-glioma subset에서만 생각한다.
   - UPENN은 GBM-only라 diagnosis/grade variation 학습에 넣으면 dataset shortcut이 생긴다.

## 10. Common variable codebook 결과

`build_common_variable_codebook.py`를 추가했고, NIfTI modeling unit 기준 raw value와 harmonized value를 함께 정리했다.

생성 산출물:

- `docs/context/common_variable_codebook.csv`
- `docs/context/common_distribution_summary.csv`
- `docs/context/common_variable_codebook.md`

### 공통 demographic / scanner covariate

| dataset | subjects | age mean/median/range | scanner vendor 요약 | field strength 요약 |
|---|---:|---|---|---|
| UTSW | 625 | mean 55.04, median 58.00, range 18-85 | Siemens 268, GE 172, Philips 141, Hitachi 15, Toshiba/Canon 1 | 1.5T 383, 3T 197, low-field 17, unknown 28 |
| MU-Glioma-Post | 203 | mean 57.88, median 61.00, range 19-87 | Siemens 계열 198, GE 1 | 1.5T 117, 3T 86 |
| UCSD-PTGBM | 178 | mean 55.72, median 56.00, range 20-88 | GE 178 | 3T 178 |
| UPENN-GBM | 630 | mean 62.67, median 63.42, range 18.65-88.5 | Siemens 622, GE 8 | 3T 557, 1.5T 73 |

해석:

- `age`와 `sex`는 전 dataset에서 가장 안정적인 clinical covariate다.
- scanner vendor/field strength는 공통 covariate로 쓸 수 있지만, dataset과 강하게 얽혀 있다.
- UCSD는 GE 3T로 거의 고정되어 있어 scanner 변수가 사실상 site/dataset indicator가 된다.
- UPENN은 Siemens 3T 중심, UTSW는 vendor/field 다양성이 가장 크다.

### 주요 label raw-to-harmonized mapping

IDH:

- UTSW: `wild type -> wildtype`, `mutated -> mutant`.
- MU: `IDH1=0;IDH2=0 -> wildtype`, `IDH1=1 -> mutant`, `2 code -> unknown`.
- UCSD: `Wild type -> wildtype`, `Mutant -> mutant`.
- UPENN: `Wildtype -> wildtype`, `Mutated -> mutant`, `NOS/NEC -> unknown`.

MGMT:

- UTSW: `methylated/unmethylated` 직접 사용 가능, missing 344 subjects.
- MU: `0 -> unmethylated`, `1 -> methylated`, `2 -> indeterminate`, `4 -> unknown`.
- UCSD: `Methylated/Unmethylated`, missing/unknown 많음.
- UPENN: `Methylated/Unmethylated`, `Indeterminate`, `Not Available`.

1p/19q:

- UTSW/UCSD는 codeleted vs intact/not-codeleted로 비교적 직접 매핑 가능.
- MU는 0/1 외에 deletion/duplication/tetraploid/abnormal karyotype 코드가 있어 `other_abnormal`으로 분리했다.
- UPENN은 현재 common NIfTI clinical metadata에 없음.

ATRX:

- MU와 UCSD만 활용 가능하다.
- UTSW/UPENN은 현재 공통 NIfTI manifest 기준으로 unknown이다.

### Codebook 기반 추가 주의점

1. Unit count와 subject count를 항상 같이 봐야 한다.
   - MU는 596 unit rows지만 203 subjects다.
   - UCSD/UPENN도 subject에 여러 session/scan이 있을 수 있다.

2. Scanner normalization은 1차 수준이다.
   - Siemens 계열, GE 계열, Philips 등 vendor는 정리했지만 scanner model은 아직 raw string이다.
   - scanner model을 covariate로 쓰려면 model family grouping이 추가로 필요하다.

3. Field strength normalization은 modeling covariate로 바로 쓸 수 있다.
   - `1.5T`, `3T`, `low_field_lt_1.5T`, `ultra_high_field_gt_3T`, `unknown`으로 정리했다.
   - MU에 7T 1 subject가 있어 outlier로 별도 확인이 필요하다.

4. Label harmonization은 보수적으로 유지한다.
   - `unknown`, `indeterminate`, `other_abnormal`을 무리하게 positive/negative에 합치지 않는다.
   - 최종 task별 inclusion/exclusion rule을 별도 문서로 확정해야 한다.

## 11. Structural MRI + IDH candidate cohort audit

첫 supervised 후보로 `structural MRI -> IDH mutant/wildtype prediction`을 가정한 cohort audit을 만들었다. 아직 split은 생성하지 않았다.

생성 산출물:

- `docs/context/build_idh_structural_cohort_audit.py`
- `docs/context/idh_structural_candidate_subjects.csv`
- `docs/context/idh_structural_candidate_summary.csv`
- `docs/context/idh_structural_confound_summary.csv`
- `docs/context/idh_structural_candidate_cohort.md`

### Inclusion rule draft

Structural IDH candidate:

1. NIfTI representation이 존재한다.
2. 최소 1개 unit에서 core structural MRI가 있다.
3. subject-level IDH가 `mutant` 또는 `wildtype`으로 확정된다.
4. `label_harmonization_subject_conflicts.csv`에서 IDH conflict가 없어야 한다.

Structural+segmentation variant:

- 위 조건에 추가로 usable segmentation이 있는 unit이 최소 1개 필요하다.
- 알려진 zero-byte NIfTI path는 제외한다.

### Eligible subject counts

| dataset | structural IDH subjects | mutant | wildtype | structural+seg IDH subjects |
|---|---:|---:|---:|---:|
| UTSW | 622 | 176 | 446 | 622 |
| MU-Glioma-Post | 189 | 28 | 161 | 189 |
| UCSD-PTGBM | 121 | 12 | 109 | 121 |
| UPENN-GBM | 525 | 19 | 506 | 507 |
| Total | 1,457 | 235 | 1,222 | 1,439 |

검증:

- Structural IDH eligible subject 수는 `candidate_task_feasibility.csv`의 IDH prediction count와 일치한다.
- 전체 NIfTI subject 후보는 1,636 subjects이고, structural IDH 후보는 1,457 subjects다.
- 제외 사유는 대부분 `idh_unknown_or_unresolved`이며, UCSD 2 subjects와 UPENN 9 subjects는 IDH conflict 때문에 제외된다.

### Confounding / class imbalance

IDH mutant 비율:

- UTSW: 176/622 = 28.30%
- MU-Glioma-Post: 28/189 = 14.81%
- UCSD-PTGBM: 12/121 = 9.92%
- UPENN-GBM: 19/525 = 3.62%

해석:

- IDH label은 dataset과 강하게 얽혀 있다. 단순 pooled random split은 dataset shortcut을 학습할 위험이 크다.
- Scanner vendor별 mutant 비율도 다르다: Siemens 중심 subset은 11.49%, GE는 20.74%, Philips는 34.75%로 관찰된다.
- 따라서 첫 supervised 실험도 subject-isolated split만으로는 부족하고, dataset/site/scanner stratified reporting 또는 leave-one-consortium-out 검증이 필요하다.

### Split policy draft

아직 split은 만들지 않았지만, 정책은 다음을 따라야 한다.

1. split key는 반드시 `dataset + subject_id`다.
2. MU/UCSD/UPENN의 여러 timepoint/session/scan은 같은 split에 묶는다.
3. UPENN DICOM과 NIfTI는 중복 표현이므로 독립 샘플로 섞지 않는다.
4. split별로 dataset, scanner vendor, field strength, age, sex, IDH class distribution을 보고한다.
5. 가능하면 internal pooled split 외에 leave-one-dataset-out 평가를 포함한다.

## 12. UPENN DICOM / histopath sample audit

`build_dicom_histopath_audit.py`를 추가했고, DICOM은 sample mode로만 실행했다. Pixel data는 읽지 않고 `pydicom.dcmread(..., stop_before_pixels=True)`로 representative DICOM header만 읽었다. 전수 DICOM header audit은 장시간 I/O 작업이 될 수 있어 실행하지 않았다.

생성 산출물:

- `docs/context/build_dicom_histopath_audit.py`
- `docs/context/dicom_series_inventory.csv`
- `docs/context/dicom_header_audit_sample.csv`
- `docs/context/histopath_slide_inventory.csv`
- `docs/context/dicom_histopath_audit_sample_summary.md`

### DICOM series inventory

UPENN DICOM은 총 3,680 series이며, concept별 요약은 다음과 같다.

| DICOM concept | series | subjects | image files |
|---|---:|---:|---:|
| T1 | 680 | 597 | 120,034 |
| FLAIR | 655 | 614 | 38,547 |
| T2 | 653 | 613 | 51,510 |
| T1 post/contrast | 605 | 566 | 111,411 |
| DTI/diffusion | 580 | 542 | 65,815 |
| Perfusion | 489 | 455 | 437,885 |
| Other MR | 9 | 8 | 1,288 |
| Secondary capture | 9 | 8 | 1,744 |

Sample audit:

- concept별 최대 8개 series, 총 64개 representative DICOM header를 읽었다.
- header read error는 0건이다.
- sample header에서 field strength는 대부분 3T였지만, missing 8건, 1.5T 4건, `2.8936200141907` 1건, `15000` 1건이 관찰되었다.
- raw DICOM은 rows/columns/pixel spacing/slice thickness가 다양하므로, NIfTI normalized set과 같은 방식으로 바로 pooling하면 안 된다.

해석:

- UPENN DICOM은 UPENN NIfTI와 중복 표현이다. 같은 subject/scan의 raw representation으로 보고, primary modeling sample로 독립 사용하면 leakage가 생긴다.
- DICOM raw 연구를 하려면 전수 DICOM header audit, series selection rule, DICOM-to-volume conversion policy가 별도로 필요하다.

전수 DICOM header audit command preview:

```bash
python docs/context/build_dicom_histopath_audit.py --mode full
```

이 명령은 전체 3,680 series에서 representative DICOM header를 읽는다. Pixel data는 읽지 않지만 storage I/O가 길 수 있으므로 승인 후 실행한다.

### Histopath inventory

UPENN histopath package:

- NDPI slide files: 71/71 존재.
- total size: 약 148.302 GiB.
- median slide size: 약 2.047 GiB.
- radiology ID로 연결 가능한 slide: 38 slides.
- 연결 가능한 unique radiology subjects: 18 subjects.
- radiology ID missing slide: 33 slides.

해석:

- histopath는 UPENN 내부 small multimodal subset으로만 볼 수 있다.
- 전체 다기관 모델의 공통 modality가 아니다.
- 현재 환경에는 `openslide`가 없어 WSI thumbnail/patch/pixel audit은 수행하지 않았다.
- histopath 연구를 하려면 radiology mapping 누락 33 slides 처리 정책과 WSI reader 환경을 먼저 정해야 한다.

## 13. Master EDA status / download completeness check

전체 산출물과 다운로드 상태를 한 번에 확인하기 위해 `build_eda_master_report.py`를 추가했다.

생성 산출물:

- `docs/context/build_eda_master_report.py`
- `docs/context/eda_master_report.md`
- `docs/context/eda_artifact_index.csv`
- `docs/context/eda_requirement_coverage.csv`
- `docs/context/eda_dataset_status_master.csv`
- `docs/context/upenn_nifti_manifest_gap.csv`

핵심 확인 결과:

- primary image/slide files: 853,647개.
- `_tools`를 제외한 direct primary suffix count도 853,647개로 inventory와 일치한다.
- partial/incomplete download-like file은 `_tools` 제외 기준 0개다.
- canonical manifest는 5,886 rows, model-ready unit row에 매핑된 파일은 853,631개다.
- manifest 기준 zero-byte NIfTI는 1개다: UCSD BraTS test `UCSD-PTGBM-0149_02_total_cellular_tumor_seg.nii.gz`.
- UPENN NIfTI actual file 10,646개 중 canonical manifest path에 매핑된 파일은 10,630개다. 차이 16개는 `UPENN-GBM-00260_11`, `UPENN-GBM-00509_11`의 structural stripped/unstripped duplicate old/non-old path 선택 문제이며, scan ID 누락은 아니다.

판단:

- 다운로드 자체는 현재 기준 완료로 볼 수 있다.
- 단, downstream preprocessing 전에 UCSD zero-byte segmentation 처리와 UPENN duplicate structural path 선택 규칙을 정해야 한다.
- full NIfTI/DICOM header audit, WSI pixel audit, preprocessing, split 생성, training은 아직 실행하지 않았고 승인 후 진행해야 한다.

## 14. Modeling-oriented detailed EDA

공통 변수와 영상 입력을 모델링 관점에서 바로 보기 위해 `build_modeling_eda_detail.py`를 추가했다. 이 단계도 metadata/path-level EDA이며, image array load, preprocessing, split, training은 수행하지 않았다.

생성 산출물:

- `docs/context/build_modeling_eda_detail.py`
- `docs/context/modeling_subject_table.csv`
- `docs/context/modeling_dataset_summary.csv`
- `docs/context/modeling_subject_label_distributions.csv`
- `docs/context/modeling_imaging_coverage.csv`
- `docs/context/modeling_unit_multiplicity.csv`
- `docs/context/modeling_label_confound_summary.csv`
- `docs/context/modeling_common_feature_readiness.csv`
- `docs/context/modeling_eda_detail.md`

### Subject-level modeling table

NIfTI 기반 subject-level cohort는 총 1,636 subjects다.

| Dataset | Subjects | NIfTI units | Multi-unit subjects | Structural core | Segmentation | Diffusion | Perfusion | IDH usable, conflict excluded | MGMT usable, conflict excluded |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| UTSW | 625 | 625 | 0 | 625 | 625 | 0 | 0 | 622 | 281 |
| MU-Glioma-Post | 203 | 596 | 155 | 203 | 203 | 0 | 0 | 189 | 163 |
| UCSD-PTGBM | 178 | 243 | 49 | 178 | 178 | 178 | 178 | 121 | 105 |
| UPENN-GBM | 630 | 671 | 41 | 630 | 611 | 554 | 497 | 525 | 266 |

### Common feature readiness

Subject-level 기준 공통 활용 가능성:

- Age: 1,636/1,636 subjects. 전 데이터셋 공통 covariate지만 기준 시점은 dataset마다 다르다.
- Sex: 1,636/1,636 subjects.
- Structural MRI core: 1,636/1,636 subjects. 가장 안정적인 all-dataset imaging baseline이다.
- Scanner vendor/field strength: 1,608/1,636 subjects. split/reporting confounder로 필수다.
- Tumor segmentation: 1,617/1,636 subjects. 단 UCSD zero-byte segmentation 1개 처리 필요.
- IDH binary usable: 1,457/1,636 subjects. subject-level conflict 제외 후에도 가장 강한 supervised label 후보.
- MGMT binary usable: 815/1,636 subjects. 가능하지만 missing/conflict 부담이 커서 second-stage 후보.
- Tumor grade: 999/1,636 subjects. UPENN은 grade variation source가 아니므로 task-specific 사용.
- 1p/19q: 473/1,636 subjects. UPENN에는 없고 UTSW/MU/UCSD 중심.
- ATRX: 232/1,636 subjects. MU/UCSD 중심.
- OS numeric: 770/1,636 subjects. time origin/censor semantics가 달라 바로 pooling 금지.
- PFS numeric: 224/1,636 subjects. sparse하고 의미가 dataset별로 다르다.
- Diffusion/perfusion: 각각 732/1,636, 675/1,636 subjects. UCSD+UPENN focused input으로 봐야 한다.
- Linked histopath: 18/1,636 radiology subjects. UPENN small multimodal subset이다.

### Leakage/confounding implications

- MU는 203명 중 155명이 여러 timepoint를 가진다. split은 반드시 subject-level이어야 한다.
- UCSD는 178명 중 49명이 여러 session을 가진다.
- UPENN은 630명 중 41명이 여러 scan을 가진다.
- UPENN DICOM과 NIfTI는 같은 cohort의 다른 representation이므로 독립 샘플로 섞으면 안 된다.
- IDH mutant rate는 dataset별로 크게 다르다: UTSW 28.30%, MU 14.81%, UCSD 9.92%, UPENN 3.62%. pooled random split은 dataset/scanner shortcut 위험이 크다.
- MGMT methylated rate는 IDH보다 dataset 차이가 작지만 UPENN/UCSD에는 subject conflict와 missingness가 있어 conflict exclusion rule이 필요하다.

판단:

- 첫 공통 imaging 연구 baseline은 structural MRI core가 가장 타당하다.
- 첫 supervised target은 IDH가 가장 현실적이다.
- 단, split 생성 전에 subject-isolated + dataset/scanner-aware reporting 또는 leave-one-consortium-out 평가 정책을 먼저 확정해야 한다.

## 15. Clinical/imaging deep-dive EDA and common data tiers

공통 사용 가능한 데이터를 task 선택 관점에서 더 명확히 구분하기 위해 `build_clinical_imaging_deep_dive.py`를 추가했다.

생성 산출물:

- `docs/context/build_clinical_imaging_deep_dive.py`
- `docs/context/clinical_imaging_deep_dive.md`
- `docs/context/deep_feature_availability.csv`
- `docs/context/deep_coavailability_matrix.csv`
- `docs/context/deep_pairwise_feature_availability.csv`
- `docs/context/deep_outcome_availability.csv`
- `docs/context/deep_scanner_distribution.csv`
- `docs/context/deep_common_data_tiers.csv`
- `docs/context/deep_nifti_sample_geometry_summary.csv`
- `docs/context/deep_data_quality_flags.csv`

### Common data tiers

Tier 1, all-dataset baseline:

- age: 1,636/1,636 subjects.
- sex: 1,636/1,636 subjects.
- structural MRI core: 1,636/1,636 subjects.
- scanner vendor: 1,608/1,636 subjects.
- field strength: 1,608/1,636 subjects.

Tier 2, near-common supervised/auxiliary candidates:

- segmentation: 1,617/1,636 subjects.
- IDH binary usable, conflict excluded: 1,457/1,636 subjects.
- MGMT binary usable, conflict/unknown/indeterminate excluded: 815/1,636 subjects.

Tier 3, subset or semantic-harmonization-needed variables:

- grade: 999/1,636 subjects. UPENN은 variable grade source가 아니다.
- 1p/19q: 473/1,636 subjects. UPENN missing.
- ATRX: 232/1,636 subjects. MU/UCSD 중심.
- OS numeric: 770/1,636 subjects. time origin/censor harmonization 필요.
- PFS numeric: 224/1,636 subjects. sparse하고 의미가 dataset별로 다르다.

Tier 4, subset imaging/multimodal:

- diffusion: 732/1,636 subjects.
- perfusion: 675/1,636 subjects.
- linked histopath: 18/1,636 subjects.

### Candidate co-availability

전체 subject 기준:

- structural core: 1,636/1,636.
- structural core + age/sex/scanner vendor/field strength: 1,608/1,636.
- structural + segmentation: 1,617/1,636.
- structural + IDH: 1,457/1,636.
- structural + segmentation + IDH: 1,439/1,636.
- structural + MGMT: 815/1,636.
- structural + segmentation + MGMT: 802/1,636.
- structural + OS numeric: 770/1,636.
- structural + diffusion + perfusion: 669/1,636.
- structural + linked histopath: 18/1,636.

### Additional quality flags

`deep_data_quality_flags.csv`에서 다음을 명시했다.

- UCSD BraTS test zero-byte NIfTI 1개: segmentation task 전 repair/exclude 필요.
- UPENN NIfTI duplicate structural old/non-old path gap 16개: preprocessing 전 path preference 필요.
- UCSD PFS/progression numeric duration에 negative min -8.0이 있어 outcome modeling 전 raw metadata inspection 필요.
- OS/PFS duration은 일부 데이터셋에서 사용 가능하지만 time origin/censor semantics가 통일되지 않아 아직 pool-ready가 아니다.
- full NIfTI/DICOM header audit은 sample audit만 있고, 전수 audit은 승인 후 실행해야 한다.

## 16. Research handoff and completion audit

지금까지의 EDA 산출물을 연구 시작용으로 한 번에 볼 수 있도록 handoff를 추가했다.

생성 산출물:

- `docs/context/build_eda_research_handoff.py`
- `docs/context/eda_research_handoff_ko.md`
- `docs/context/eda_completion_audit.csv`
- `docs/context/eda_completion_audit.md`
- `docs/context/eda_handoff_artifact_index.csv`

핵심 역할:

- `eda_research_handoff_ko.md`: 데이터 현황, 공통 tier, co-availability, 후보 task, outcome/scanner/quality flags, 권장 첫 연구 방향을 한 문서에 정리한다.
- `eda_completion_audit.csv`: EDA 요구사항별 완료/주의/승인필요 상태를 표로 정리한다.
- `eda_handoff_artifact_index.csv`: 어떤 산출물을 어떤 목적으로 보면 되는지 index를 제공한다.

Completion audit 해석:

- 공통 clinical/imaging metadata/path-level EDA는 task 선택이 가능할 정도로 완료되었다.
- image header audit은 sample audit까지만 완료되었고 full audit은 approval-gated다.
- DICOM/histopath도 sample/inventory audit까지만 완료되었고 full DICOM header audit 및 WSI pixel audit은 approval/environment-gated다.
- split/preprocessing/training은 EDA phase 범위 밖이며, task/split/metric/compute scope 승인 후 진행해야 한다.

## 17. Common data dictionary and task cards

공통 변수의 의미와 후보 task를 연구 설계 관점에서 바로 볼 수 있도록 data dictionary/task card 산출물을 추가했다.

생성 산출물:

- `docs/context/build_common_data_dictionary_and_task_cards.py`
- `docs/context/common_data_dictionary.csv`
- `docs/context/candidate_task_cards.csv`
- `docs/context/common_data_dictionary_task_cards.md`

`common_data_dictionary.csv`는 17개 공통/부분공통 feature에 대해 다음을 정리한다.

- canonical definition
- harmonized value/type
- dataset별 availability
- raw source column
- recommended use
- modeling caveat

`candidate_task_cards.csv`는 8개 후보 task를 정리한다.

| Task card | Status | 핵심 |
|---|---|---|
| T0 structural representation baseline | protocol design 가능 | structural core all-dataset baseline |
| T1 structural IDH prediction | first supervised 후보 | conflict 제외 IDH 1,457 subjects |
| T1b structural+segmentation IDH | T1 후 variant | structural+segmentation+IDH 1,439 subjects |
| T2 structural MGMT prediction | second-stage | MGMT 815 subjects |
| T3 grade/diagnosis family | restricted subset | UPENN shortcut 주의 |
| T4 survival/PFS | defer | time origin/censor harmonization 필요 |
| T5 advanced imaging UCSD+UPENN | subset task | diffusion+perfusion 669 subjects |
| T6 UPENN radiology-histopath | pilot only | linked histopath 18 subjects |

해석:

- 실제 첫 protocol은 T0 또는 T1에서 시작하는 것이 가장 보수적이다.
- T1을 실행하려면 full NIfTI header audit, IDH conflict exclusion rule, subject-level split policy가 먼저 승인되어야 한다.

## 18. Next audit plan and approval gates

EDA 다음 단계에서 실행 가능한 audit과 decision gate를 정리하기 위해 `build_next_audit_plan.py`를 추가했다. 이 단계는 계획 문서만 생성하며 full audit, preprocessing, split, training은 실행하지 않았다.

생성 산출물:

- `docs/context/build_next_audit_plan.py`
- `docs/context/eda_next_audit_plan.csv`
- `docs/context/eda_next_gate_checklist.csv`
- `docs/context/eda_next_audit_plan.md`

승인-gated command preview:

```bash
python docs/context/build_nifti_header_audit.py --mode full
python docs/context/build_dicom_histopath_audit.py --mode full
```

장시간 audit 실행 직전에는 별도로 다음을 확인/보고해야 한다.

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

Next gates:

1. 첫 task 후보 확정: 권장 `T1_structural_idh_prediction`.
2. full NIfTI header audit 승인.
3. UCSD zero-byte segmentation repair/exclude 결정.
4. UPENN duplicate structural old/non-old path preference 결정.
5. subject-level split + dataset/scanner-aware reporting + leave-one-consortium-out 포함 여부 승인.
6. preprocessing target geometry/orientation/normalization policy 승인.

현재 상태:

- metadata/path-level EDA는 task 선택에 충분하다.
- 모델 training으로 넘어가기 전 가장 먼저 필요한 기술 gate는 full NIfTI header audit이다.

## 19. EDA artifact consistency validation

지금까지 생성한 EDA 산출물 간 count가 서로 맞는지 검증하기 위해 `validate_eda_outputs.py`를 추가했다.

생성 산출물:

- `docs/context/validate_eda_outputs.py`
- `docs/context/eda_validation_checks.csv`
- `docs/context/eda_validation_report.md`

검증 결과:

- 총 checks: 73.
- PASS: 72.
- FAIL: 0.
- WARN: 1.

WARN 1건은 의도된 상태다. full image audits 및 preprocessing/training이 Min 승인 전에는 완료되지 않았다는 approval-gated 경고다.

검증된 주요 일관성:

- primary data file total: 853,647.
- canonical manifest rows: 5,886.
- canonical manifest mapped files: 853,631.
- subject-level NIfTI cohort: 1,636.
- structural + IDH coavailability: 1,457.
- structural + segmentation + IDH coavailability: 1,439.
- structural + MGMT coavailability: 815.
- known zero-byte NIfTI: 1.
- UPENN NIfTI manifest gap rows: 16.
- manifest-mapped NIfTI file-size inventory rows: 25,326.
- manifest-mapped NIfTI total size: 147.2949 GiB.
- UPENN DICOM series image total: 828,234.
- UPENN histopath slide total size: 148.3012 GiB.

해석:

- 현재 EDA 산출물끼리는 모순되는 count가 발견되지 않았다.
- 남은 WARN은 데이터 문제라기보다 승인-gated 작업이 아직 실행되지 않았다는 상태 표시다.

## 20. Visual EDA summary figures

표 중심 EDA를 빠르게 훑을 수 있도록 visual summary를 추가했다. 모든 figure는 기존 `docs/context` CSV 산출물에서 생성되며 raw image array는 로딩하지 않는다.

생성 산출물:

- `docs/context/build_eda_visual_summaries.py`
- `docs/context/eda_visual_summary.md`
- `docs/context/eda_visual_summary_index.csv`
- `docs/context/figures/dataset_primary_files.png`
- `docs/context/figures/common_data_tiers_subjects.png`
- `docs/context/figures/candidate_coavailability.png`
- `docs/context/figures/label_positive_rate_by_dataset.png`
- `docs/context/figures/subject_imaging_coverage_heatmap.png`
- `docs/context/figures/data_quality_flags.png`

Figure 역할:

- dataset file 규모 확인.
- common data tier별 subject availability 확인.
- candidate cohort co-availability 확인.
- IDH/MGMT positive rate의 dataset confounding 확인.
- subject-level imaging coverage heatmap 확인.
- known data quality flags 확인.

## 21. Storage and file-size audit

저장 공간과 이후 preprocessing/output disk 계획을 위해 `build_storage_size_audit.py`를 추가했다. 이 스크립트는 filesystem stat과 기존 manifest/inventory만 읽으며, NIfTI array, DICOM pixel data, WSI pixel은 로딩하지 않는다.

생성 산출물:

- `docs/context/build_storage_size_audit.py`
- `docs/context/nifti_file_size_inventory.csv`
- `docs/context/nifti_file_size_summary.csv`
- `docs/context/dicom_series_image_count_summary.csv`
- `docs/context/histopath_size_summary.csv`
- `docs/context/eda_storage_size_audit.md`

확인된 수치:

- Manifest-mapped NIfTI files: 25,326.
- Manifest-mapped NIfTI total size: 147.2949 GiB.
- Missing manifest-mapped NIfTI files: 0.
- Zero-byte mapped NIfTI files: 1.
- UPENN DICOM series: 3,680.
- UPENN DICOM total image count: 828,234.
- UPENN histopath slides: 71.
- UPENN histopath total size: 148.3012 GiB.
- Radiology-linked histopath slides: 38 slides, 18 radiology subjects, 76.7422 GiB.

해석:

- NIfTI 파일은 모두 실제 path가 존재하지만, UCSD BraTS test segmentation 1개는 0 byte라 repair/exclude 결정이 필요하다.
- DICOM은 828k개 개별 파일 size stat을 의도적으로 생략했고, series image-count burden으로만 요약했다.
- Histopath는 linked subject가 18명뿐이라 multimodal modeling의 주 cohort가 아니라 UPENN pilot subset으로 보는 것이 맞다.

## 22. Consortium-level common data matrix

연구 protocol을 바로 설계할 수 있도록 subject-level feature availability를 컨소시엄별 long/wide matrix로 재정리했다. 이 단계는 기존 `modeling_subject_table.csv`와 distribution CSV만 읽으며 raw image array나 pixel data는 로딩하지 않는다.

생성 산출물:

- `docs/context/build_consortium_common_data_matrix.py`
- `docs/context/consortium_common_data_matrix.csv`
- `docs/context/consortium_common_data_wide.csv`
- `docs/context/consortium_selected_distribution.csv`
- `docs/context/consortium_common_data_matrix.md`

핵심 확인:

- Long matrix: 175 rows = 35 features x 5 dataset scopes(MU, UCSD, UPENN, UTSW, ALL).
- Wide matrix: 35 features.
- Selected clinical/scanner/label distribution rows: 122.
- Structural core: 1,636/1,636 subjects.
- Structural + age + sex + scanner vendor/field strength: 1,608/1,636 subjects.
- Structural + IDH: 1,457/1,636 subjects.
- Structural + segmentation + IDH: 1,439/1,636 subjects.
- Structural + MGMT: 815/1,636 subjects.
- Structural + diffusion + perfusion: 669/1,636 subjects.
- Structural + linked histopath: 18/1,636 subjects.

해석:

- 첫 supervised protocol의 공통 schema는 structural MRI core + age + sex + scanner vendor/field strength + IDH가 가장 현실적이다.
- Segmentation은 coverage가 높아 T1 이후 variant로 붙이기 좋다.
- MGMT는 가능하지만 missingness가 커서 second-stage target이다.
- Diffusion/perfusion, survival/PFS, histopath는 all-consortium common feature가 아니므로 별도 subset/pilot protocol로 분리해야 한다.

## 23. Research cohort membership and leakage grouping

모델 개발로 넘어가기 전에 subject-level eligibility flag와 leakage grouping key를 명시하기 위해 `build_research_cohort_membership.py`를 추가했다. 이 단계는 split을 만들지 않고, 각 subject가 어떤 후보 task에 들어갈 수 있는지만 표시한다.

생성 산출물:

- `docs/context/build_research_cohort_membership.py`
- `docs/context/research_cohort_membership.csv`
- `docs/context/research_cohort_summary.csv`
- `docs/context/research_leakage_group_audit.csv`
- `docs/context/research_cohort_membership.md`

핵심 확인:

- Subject-level membership rows: 1,636.
- Candidate cohort summary rows: 50 = 10 cohort flags x 5 dataset scopes.
- Leakage audit rows: 5 = 4 datasets + ALL.
- T0 structural common: 1,636 subjects, 2,135 NIfTI units.
- T0b structural + age/sex/scanner: 1,608 subjects.
- T1 structural IDH: 1,457 subjects, mutant 235, wildtype 1,222.
- T1b structural + segmentation + IDH: 1,439 subjects.
- T2 structural MGMT: 815 subjects, methylated 347, unmethylated 468.
- T5 structural + diffusion + perfusion: 669 subjects.
- T6 radiology-histopath pilot: 18 subjects.

Leakage 관련 확인:

- 전체 1,636 subjects 중 245 subjects가 multiple NIfTI units를 가진다.
- MU: 155/203 subjects가 multi-timepoint다.
- UCSD: 49/178 subjects가 multi-session이다.
- UPENN: 41/630 subjects가 multi-scan이다.
- UTSW: 현재 subject당 1 unit이다.
- 향후 split은 반드시 `dataset::subject_id`를 grouping key로 사용해야 한다.

해석:

- 이 산출물은 split 파일이 아니라 split 준비용 membership/guardrail table이다.
- unit-level random split은 MU/UCSD/UPENN에서 subject leakage를 만든다.
- 실제 split 생성은 task, cohort, metric, split policy 승인 후에만 진행해야 한다.

## 24. Candidate task bias and shortcut audit

첫 supervised 후보인 IDH와 second-stage 후보인 MGMT가 dataset/scanner/age/sex와 얼마나 얽혀 있는지 별도 audit을 추가했다. 이 산출물은 split을 만들지 않고, future split/reporting policy를 정하기 위한 target imbalance table이다.

생성 산출물:

- `docs/context/build_candidate_task_bias_audit.py`
- `docs/context/candidate_task_bias_group_distribution.csv`
- `docs/context/candidate_task_bias_group_summary.csv`
- `docs/context/candidate_task_bias_dataset_matrix.csv`
- `docs/context/candidate_task_bias_audit.md`

핵심 확인:

- Group distribution rows: 123.
- Grouping risk summary rows: 16.
- Dataset-level matrix rows: 8.
- IDH task total: 1,457 subjects, mutant 235, wildtype 1,222.
- IDH dataset positive rate: UTSW 28.30%, MU 14.81%, UCSD 9.92%, UPENN 3.62%.
- IDH dataset positive-rate spread: 24.68 percentage points.
- IDH age-bin positive-rate spread: 65.97 percentage points.
- MGMT task total: 815 subjects, methylated 347, unmethylated 468.
- MGMT dataset positive rate: MU 40.49%, UCSD 50.48%, UPENN 42.86%, UTSW 40.57%.
- MGMT dataset positive-rate spread: 9.99 percentage points.

해석:

- IDH는 coverage가 가장 좋아 첫 supervised target으로 적합하지만, dataset/age/scanner shortcut 위험이 크다.
- IDH pooled random split만으로 성능을 주장하면 위험하다. dataset/scanner-aware reporting과 leave-one-consortium-out 평가가 필요하다.
- MGMT는 dataset-level positive rate는 IDH보다 안정적이지만 coverage가 815명으로 낮고 small-cell scanner/field strata가 많아 second-stage가 적절하다.

## 25. Final synthesis and objective evidence matrix

EDA 산출물이 어떤 objective requirement를 충족하는지 추적하기 위해 최종 synthesis와 evidence matrix를 추가했다.

생성 산출물:

- `docs/context/build_eda_final_synthesis.py`
- `docs/context/eda_final_synthesis_ko.md`
- `docs/context/eda_completion_evidence_matrix.csv`
- `docs/context/eda_start_here_index.csv`

핵심 확인:

- Objective evidence rows: 8.
- Start-here index rows: 12.
- Start-here index missing artifacts: 0.
- 최종 validator: 73 checks, FAIL 0, WARN 1.

해석:

- 현재 EDA는 metadata/path-level, sample header, storage stat, common-data, cohort membership, target bias audit까지 연결되어 있다.
- 남은 WARN은 데이터 불일치가 아니라 Min 승인 전 full image audits/preprocessing/training을 실행하지 않았다는 의도된 상태다.
- 다음 작업은 EDA 확장이 아니라 첫 protocol 승인과 full NIfTI header audit gate다.
