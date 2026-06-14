# 데이터 인벤토리 — 코호트별 보유 데이터 & 활용 가능 데이터

_2026-06-14. 실제 파일시스템 + manifest 전수 점검 기반. 추측 없음._

## 읽는 법

- **보유(held)**: `/home/vlm/data/raw/<cohort>/` 에 물리적으로 존재하는 원본(영상·임상).
- **활용 가능(usable)**: canonical manifest에 기록되어 QC 통과·ID 매핑된 = 바로 분석에 쓸 수 있는 것.
- 두 manifest: `official_manifest_full_n4_real_final`(13,022×141, 7코호트) · `korean_multimodal_manifest`(2,196×93, AJU+KDRC).

> ⭐ **T1은 7개 코호트 전부 100% 전처리 완료** — 디스크 검증값(13,022/13,022):
> `native_t1w_hdbet.nii.gz`(뇌추출 native T1) · `final_tensor`(z-score) · `final_tensor_n4`(N4, 모델입력) · `brain_mask` 모두 **100%**.
> 즉 **ADNI·AIBL·NACC·AJU 포함 모든 코호트의 T1은 즉시 활용 가능**하다. 아래 표의 `raw_t1_path ❌`는 "T1 없음"이 아니라
> **전처리 *이전* 원본 raw(DICOM) 소스가 manifest에 링크 안 됨**을 뜻함(T1 native/tensor는 별개로 존재).

- **모든 코호트 공통 파생물**: `native_t1w_hdbet`(100%) · `final_tensor`+`final_tensor_n4`(192×224×192 z-score T1, 100%) · brain mask · FastSurfer `fs_vol_*`(100%) · ROI usability. (전처리 파일 전수 QC = FAIL 0, `Clinical/consortiums/PREPROC_QC_ROLLUP.md`)

---

## 0. 한눈에 — 모달리티 매트릭스

**전처리 T1**(native_t1w_hdbet + final_tensor[_n4])은 **7개 코호트 전부 100%** — 아래 표는 그 외 *원본 raw* 모달리티 보유 현황.

| 코호트 | 세션(활용) | 전처리 T1 | 원본 FLAIR | T2 | DWI/DTI | PET | 기타 | 원본raw 형식 | raw_*_path(원본링크) |
|---|---|---|---|---|---|---|---|---|---|
| **ADNI** | 4,742 | ✅ 100% | — | — | — | AV45(zip) | fMRI | T1=DICOM | ❌ 원본 미링크 |
| **NACC** | 1,866 | ✅ 100% | ✅ 1997 | ✅ 726 | — | amyloid/FDG(CSV) | ASL 41 | DICOM zip(미변환) | ❌ 원본 미링크 |
| **A4** | 1,811 | ✅ 100% | ✅ 6088 | — | ✅ 656 | (amyloid SUVR=수치) | — | NIfTI | ✅ T1·FLAIR |
| **OASIS** | 1,420 | ✅ 100% | ✅ 부분 | ✅ | ✅ | (amyloid centiloid=수치) | — | NIfTI(BIDS) | ✅ T1·FLAIR47%·DWI73% |
| **AJU** | 1,287 | ✅ 100% | ✅ 1306 | ✅ 686 | ✅ 1250 | ✅ 1020 | ASL·SWI·MRA·fMRI·CT | DICOM(미변환) | ❌ 원본 미링크* |
| **KDRC** | 909 | ✅ 100% | ✅ 946 | ✅ 830 | ✅ 693 | ✅ 946 | — | NIfTI(추출됨) | ✅ T1·FLAIR·T2·DWI·PET |
| **AIBL** | 987 | ✅ 100% | — | — | — | (별도) | — | T1=zip/native | ✅ T1(v2 native) |

> **전처리 T1 100%** = `native_t1w_hdbet`·`final_tensor`·`final_tensor_n4` 디스크 검증(13,022/13,022). 즉 T1은 전 코호트 즉시 활용.
> `raw_*_path ❌`(ADNI/NACC/AJU) = **전처리 *이전* 원본 raw(DICOM)가 manifest에 링크 안 됨**일 뿐, T1 native/tensor는 존재.
> 멀티모달 숫자 = 보유 파일/디렉토리 수. "미변환" = DICOM 원본 보유하나 NIfTI 미변환 → **멀티모달 활용엔 변환 필요**.
> *AJU·KDRC의 FLAIR·PET는 이미 처리되어 `korean_multimodal_manifest`에 등록(AJU FLAIR 98%·PET 77% / KDRC 둘 다 98%).
> ⭐ 미활용 최대자산: **ADNI·NACC 멀티모달 DICOM**(FLAIR/T2/ASL) + **AJU T2/DTI/ASL/SWI/MRA/fMRI DICOM**(변환 대기).

---

## 1. ADNI  (4,742 세션 / 1,580 subj)

**보유 (raw):** `raw/ADNI/`
- T1: `ADNI_3_4_T1w/ADNI/<subj>/<series>/<date>/*.dcm` — **DICOM, 1,756 subj** (ADNI3/4)
- PET: `PET/ADNI_PET_AV45_*.zip` (amyloid, 압축본) · fMRI 디렉토리
- 임상: CSV 10+ (`APOERES`, `All_Subjects_UCSFFSX7`(FreeSurfer), `UBristol_CSFSER_ELISA`(CSF), `DATADIC`, `adni_t1w_clinical_final.csv` 등)

**활용 가능 (manifest):** **native T1 + final_tensor[_n4] 100%**(전처리 완료) · FastSurfer 100% · dx 99% · cdr 100% · mmse 99% · apoe 94% · **scanner+model 100%**(Prisma 28%/MR750 16%/TrioTim 14%…) · field 3T 100%. ROI USABLE 4,726.
**갭:** T1은 전처리 완료됐으나 **원본 DICOM이 raw_*_path에 미링크**(T1 결손 아님) · AV45 PET·fMRI·CSF 미통합 · amyloid SUVR 수치 미반영(GAAIN/UCBERKELEY 파일 필요).

## 2. NACC  (1,866 세션 / 1,414 subj)

**보유 (raw):** `raw/NACC/`
- MRI DICOM zip(scan별): **FLAIR 1,997 · MPRAGE/T1 ~2,000 · T2 726 · ASL 41 · IR-FSPGR(T1변형)** — 멀티모달 풍부, 미추출
- 임상: `NACC-Clinical/` CSV 다수(`commercial_mri`, `amyloidpetgaain`(centiloid), `fdgpetnpdka`, `mrisbm`(SBM), `petqc`) + Data Dictionary

**활용 가능:** **native T1 + final_tensor[_n4] 100%**(전처리 완료) · FastSurfer 100% · dx 100% · cdr 100% · **moca 100%** · mmse 16%(MoCA가 주지표) · apoe 76% · edu 100% · **scanner+model 85%**(Prisma 31%/Skyra 15%/Biograph PET-MR 13%…) · amyloid centiloid 28%. ROI USABLE 1,851.
**갭:** T1 전처리 완료(원본 DICOM만 raw_*_path 미링크) · FLAIR/T2/ASL DICOM 미변환 · FDG PET·SBM 미통합.

## 3. A4  (1,811 세션 / 992 subj)

**보유 (raw):** `raw/A4/ImageData/` — **NIfTI**: T1 6,091 · FLAIR 6,088 · DWI 656 (.nii.gz, 다중 run 포함) + BIDS json sidecar. `Clinical/` 폴더.

**활용 가능:** T1·FLAIR raw_path 100% · 텐서 100% · FastSurfer 100% · **임상 전필드 100%**(dx/cdr/mmse/apoe/edu/sex/age) · **amyloid SUVR 100%**(trial 설계상 전원 양성) · scanner **vendor만** 100%(Siemens65/GE24/Philips11%, json에 모델명 없음). ROI USABLE 1,770.
**갭:** scanner 모델 불가(소스 한계) · FLAIR/DWI는 raw 있으나 텐서 미생성(T1만 모델입력).

## 4. OASIS (OASIS3)  (1,420 세션 / 718 subj)

**보유 (raw):** `raw/oasis3/` — **MR 세션 2,842개**(활용 1,420), 각 `anat2/anat3`(T1/T2/FLAIR), `BIDS/`. `OASIS3_data_files/`(임상·Tau PET·demographics).

**활용 가능:** T1 raw 100%·FLAIR 47%·DWI 73% · 텐서 100% · FastSurfer 100% · 임상 dx85/cdr100/mmse100/apoe100 · **amyloid centiloid 74%** · Tau Braak staging 10% · scanner **vendor만** 100%(전부 Siemens, NIfTI 익명화로 모델 불가). ROI USABLE 1,412.
**갭:** 보유 2,842 세션 중 1,420만 활용(나머지 QC/페어링 탈락) · scanner 모델 불가.

## 5. AJU  (1,287 세션 / 1,001 subj) — 최다 멀티모달

**보유 (raw):** `raw/AJU/20{16..24}/<site>/<subj>/<visit>/` — **DICOM**
- MRI: 3D_T1 1,293 · T2_FLAIR 1,306 · T2_FSE 686 · DTI 1,250 · ASL 454 · SWI 547 · MRA 559 · fMRI 1,154 (visit-dir 수)
- PET 1,020 · CT 696 · 임상 `metadata/임상역학정보 분양_all.xlsx`(SNSB 전배터리)

**활용 가능:** **native T1 + final_tensor[_n4] 100%**(전처리 완료) · FastSurfer 100% · dx 96% · cdr 100% · mmse 100% · **apoe 100% · edu 100%** · **amyloid 100%** · **scanner+model 96%**(GE Discovery MR750w 75%…). ROI USABLE 1,282.
- **korean_multimodal_manifest 경유 이미 활용 가능: FLAIR 98% · PET SUVR 77%**(처리·경로 등록 완료).
**갭:** **T2/DTI/ASL/SWI/MRA/fMRI + CT DICOM 미추출**(각 ~450–1,250 visit-dir) — 변환 시 단일 코호트 최대 멀티모달. real_final엔 raw_*_path 미등록(멀티모달은 korean manifest에).

## 6. KDRC  (909 세션 / 909 subj) — NIfTI 멀티모달 완비

**보유 (raw):** `raw/KDRC/`
- `extracted_images_20260505/`(952 subj, **NIfTI**): T1 944 · FLAIR 946 · T2 830 · DTI 693 · **PET 946**
- 임상: `clinical.xlsx` + 중첩 `KDRC*.zip` 내 `데이터분양_데이터통합_*.xlsx` ×3 (총 4파일, `_kdrc_clinical_src/`에 staged)

**활용 가능:** T1 텐서 100% · FastSurfer 100% · **raw T1/FLAIR 100%·T2 90%·DWI 76%·PET 99%**(멀티모달 경로 등록됨) · dx 85% · cdr 100% · mmse 94% · **apoe 100%** · amyloid SUVR 94% · Fazekas 73% · **scanner+model 91%**(Philips-Ingenia 57%…). ROI USABLE 906.
**갭:** scanner 78건·dx 일부는 임상 원본에 코드 부재(공백). 멀티모달 NIfTI는 보유하나 T1 외 텐서 미생성.

## 7. AIBL  (987 세션 / 617 subj)

**보유 (raw):** `raw/AIBL/AIBL-VLM-v1.zip`(16.6GB, **미추출**) — 작업본은 `v2/AIBL/.../native_t1w_hdbet.nii.gz`. 임상 `meta/aibl_{neurobat,mrimeta,pdxconv,navmeta}_*.csv`.

**활용 가능:** T1 텐서 100% · FastSurfer 100% · raw T1(native) 100% · dx/cdr/mmse 100% · apoe 없음 · **scanner+model 100%**(TrioTim 80%/Verio 20%, 전부 Siemens). ROI USABLE 985.
**갭:** apoe 미통합(meta CSV에 있을 수 있음) · 영상 원본 zip 미추출(T1만 native 사용) · amyloid PET 메타만(SUVR 없음).

---

## 8. 임상 커버리지 매트릭스 (활용 가능, manifest 기준)

| 코호트 | dx | CDR | MMSE | MoCA | APOE | edu | amyloid |
|---|---|---|---|---|---|---|---|
| ADNI | 99% | 100% | 99% | — | 94% | — | (PET 미통합) |
| NACC | 100% | 100% | 16% | **100%** | 76% | 100% | centiloid 28% |
| A4 | 100% | 100% | 100% | — | 100% | 100% | SUVR 100% |
| OASIS | 85% | 100% | 100% | (부분) | 100% | — | centiloid 74% |
| AJU | 96% | 100% | 100% | — | 100% | 100% | 100% |
| KDRC | 85% | 100% | 94% | — | 100% | — | SUVR 94% |
| AIBL | 100% | 100% | 100% | — | — | — | (메타만) |

scanner 상세 분포 → `docs/SCANNER_DISTRIBUTION.md`. amyloid/CSF 정책 → memory `csf-absent`, `manifest-real-final`.

---

## 9. 활용 로드맵 (지금 가능 vs 변환 필요)

**즉시 활용 (변환 0):**
- T1 모델입력 텐서 **13,022 전수**(7코호트, N4+z-score, QC통과) — brain-age/분류/표현학습 ready.
- FastSurfer 부피·ROI·scanner(model)·임상(위 매트릭스)·amyloid(A4/AJU 100%, OASIS/KDRC 높음).
- 멀티모달 NIfTI 즉시 가용: **KDRC(T1/T2/FLAIR/DTI/PET)**, **AJU(FLAIR 98%·PET 77%, korean manifest)**, A4(FLAIR/DWI), OASIS(FLAIR/DWI 부분).

**변환하면 크게 늘어남 (DICOM→NIfTI):**
- ⭐ **AJU**: T2/DTI/ASL/SWI/MRA/fMRI (각 ~450–1,250) — FLAIR·PET은 이미 처리됨, 나머지가 변환 대기.
- ⭐ **NACC**: FLAIR 1,997 / T2 726 / ASL — DICOM zip 전부 미추출.
- **ADNI**: FLAIR/T2 부재(T1만 download), AV45 amyloid PET·fMRI 변환 대기.
- 도구: `preprocessing/dicom_to_nifti/{aju,adni,nacc}.py` → `preprocessing/raw_manifest/build.py` 재실행 시 raw_*_path 반영.

**미통합 임상/바이오마커 (파일은 보유):**
- ADNI: CSF ELISA, UCBERKELEY amyloid/tau PET SUVR, FreeSurfer FSX7.
- NACC: FDG PET, SBM, amyloid NPDKA.
- AIBL: apoe(neurobat), amyloid PET.

---

## 10. 사용 전 caveat

1. **train/test leakage**: 교차세션 byte-identical 중복 4쌍(AJU cross-subject 2쌍은 ID 달라 subject분할로 안 잡힘) → split 전 collapse. `Clinical/consortiums/PREPROC_QC_DUPLICATES.md`.
2. **보유≠활용 세션수 (QC 깔때기)**: manifest = **QC-pass scan만**. native brain-extraction(`native_t1w_hdbet`)은 QC 이전 단계라 더 많고, 그 차이가 탈락분 — A4 7,132→**1,811**, ADNI 5,037→4,742, OASIS 1,615→1,420, KDRC 931→909, NACC 1,876→1,866, AIBL 990→987, AJU 1,287→1,287. **final_tensor_n4(모델입력)는 디스크=manifest 정확히 일치(orphan 0·missing 0, 13,022/13,022)** — QC-pass에만 생성·등록됨.
3. **scanner 모델 불가 2코호트**: A4(json 제조사만)·OASIS(NIfTI 익명화) → vendor-level이 한계.
4. **site=코호트 교란**: vendor/모델이 코호트 지문(AIBL·OASIS 단일 Siemens, AJU GE, KDRC Philips) → leave-one-consortium-out 권장.
5. **결측은 날조 안 함**: 위 % 미달분은 원본 source 공백(KDRC scanner 78·NACC mmse 등)이며 추정 채움 없음.

> 출처 스크립트: `roi_qc/scripts/{extract_scanner_model,kdrc_clinical_merged,enrich_*,verify_enriched_manifest}.py` ·
> `preprocessing/raw_manifest/build.py` · `Clinical/common/preproc_qc*.py`.
