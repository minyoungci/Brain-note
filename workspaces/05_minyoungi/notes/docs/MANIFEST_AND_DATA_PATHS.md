# 최종 Manifest & 데이터 경로 — 단일 참조

_검증일 2026-06-14. 모든 수치는 실제 parquet/디스크 점검값._

## 1. 최종(canonical) manifest

| | |
|---|---|
| **파일** | `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet` (+ `.csv`) |
| **shape** | **13,022 행 × 141 열** _(2026-06-14: +acq_scanner_model{,_raw,_source})_ |
| **subjects** | 7,231 |
| **consortiums (7)** | ADNI 4,742 · NACC 1,866 · A4 1,811 · OASIS 1,420 · AJU 1,287 · AIBL 987 · KDRC 909 |
| **행 단위** | 1행 = 1 세션(subject × session), `tag`가 unique 키 |
| **QC 게이트** | `final_qc_status`·`fs_qc_status` 전 행 PASS (즉 전 행이 QC-pass 데이터) |
| **데이터 딕셔너리** | `official_manifest_full_n4.README.md` (authoritative) · `official_manifest_full_n4_real_final.datadict.csv` (열별 dtype/coverage/example) |
| **로더** | `Clinical/common/mri_io.py` → `load_manifest()` (이 파일을 가리킴) |

> ⚠️ 구버전(`official_manifest.csv` 12열, `official_manifest_full.parquet` 75열,
> `official_manifest_full_n4.parquet` 101열)은 모두 이 141열의 **부분집합**. 신규 분석은
> 반드시 `_real_final` 사용. (구버전은 lineage 보존용으로만 잔존)
> 직전 138열 버전은 `..._real_final.pre_scanner_kdrc_20260614.{parquet,csv}` 로 백업됨.

---

## 2. 데이터 경로 컬럼 (디스크 실파일을 가리키는 9개)

커버리지/실존은 2026-06-14 점검값 (실존은 200-샘플 기준 100%).

### 2a. 모델 입력 텐서 — 4개, 전부 100% 존재
| 컬럼 | 내용 | 규격 |
|---|---|---|
| `final_tensor_n4_path` | **N4 보정 + z-score T1w** (⭐모델 입력 권장) | 192×224×192, RAS, 1mm, float32 |
| `final_mask_n4_path` | 위 텐서의 brain mask | 〃, binary {0,1} |
| `final_tensor_path` | z-score T1w (N4 **미적용**) | 〃 |
| `final_mask_path` | 위의 brain mask | 〃 |

> z-score는 **마스크 내부** 기준(in-mask mean=0·std=1), 마스크 외부는 0. N4 vs 비-N4
> 마스크는 재처리로 미세 상이(Dice 0.97~1.0) — 정상.

### 2b. raw 원본 NIfTI — 5개, 부분 커버리지 (있는 건 100% 존재)
| 컬럼 | 모달리티 | 커버리지 |
|---|---|---|
| `raw_t1_path` | T1w 원본 | 5,127 / 13,022 (39%) |
| `raw_flair_path` | FLAIR | 3,379 (26%) |
| `raw_dwi_path` | DWI/DTI | 1,722 (13%) |
| `raw_pet_path` | amyloid PET | 903 (7%) |
| `raw_t2_path` | T2 | 816 (6%) |

> raw 경로는 전처리 **이전** 원본 위치(`/home/vlm/data/raw/...` 또는 v2 native).
> 부분 커버리지는 결측이 아니라 **해당 모달리티 보유 세션에만** 채워짐.

---

## 3. 141열 구성 (11 의미 블록)

| 블록 | 수 | 컬럼(요약) |
|---|---|---|
| ① 식별 | 5 | consortium, subject_id, session_id, qc_t1w_key, **tag** |
| ② 경로·모델입력 | 4 | final_tensor[_n4]_path, final_mask[_n4]_path |
| ③ 경로·raw | 5 | raw_{t1,flair,t2,dwi,pet}_path |
| ④ QC/ROI | 9 | final_qc_status, fs_qc_status, roi_usability, auto_verdict, numeric_*_rois, voxelwise_qc_candidate |
| ⑤ FastSurfer 부피 fs_* | 34 | fs_BrainSegVol, fs_vol_hippocampus_L/R, …(피질·피질하 부피) |
| ⑥ 임상 clin_*/cdr | 25 | cdr_global, cdrsb, clin_{dx_label,mmse,moca,apoe,education,sex,age}(+ *_source) |
| ⑦ N4 메트릭 n4_* | 4 | n4_grid_match_frac, n4_zmean, n4_zstd, n4_meanabs_diff_vs_baseline |
| ⑧ voxel/해상도 | 10 | vox_{x,y,z,min,max,mean,aniso}, brain_voxel_loss_ratio, vox_source |
| ⑨ scanner/site | **7** | acq_scanner[_raw], acq_field_strength, acq_scanner_source, **acq_scanner_model**, **acq_scanner_model_raw**, **acq_scanner_model_source** |
| ⑩ 코호트 biomarker | 29 | {kdrc,adni,aju,oasis,a4,nacc}_* (amyloid SUVR/centiloid, APOE, Fazekas, Braak, MoCA …) |
| ⑪ 기타 | 9 | auto_reasons, vision_category/note, roi_final_ready, tensor/mask_exists, bias_ratio_* |

`roi_usability` 분포: USABLE_AUTO 12,932 · NOT_CANDIDATE 44 · USABLE_W_CAVEAT 30 · REVIEW_REQUIRED 11 · ROI_UNUSABLE 5.

---

## 4. 디스크 레이아웃 (전처리 트리)

```
/home/vlm/data/preprocessed_official/
├── official_manifest_full_n4_real_final.{parquet,csv}   ← ⭐ 최종 manifest
├── official_manifest_full_n4.README.md                  ← 데이터 딕셔너리
├── official_manifest_full_n4_real_final.datadict.csv
├── korean_multimodal_manifest.{parquet,csv}             ← 한국 멀티모달 별도(2,196×89)
└── v2/
    └── {ADNI,NACC,A4,OASIS,AJU,AIBL,KDRC}/subjects/
        └── {subject_id}/{session_id}/
            ├── t1w/
            │   ├── final_tensor_n4/  t1w_brain_1mm_RAS_192x224x192_n4_zscore.nii.gz  ← 모델입력
            │   │                     brain_mask_1mm_RAS_192x224x192_n4.nii.gz
            │   ├── final_tensor/     t1w_brain_1mm_RAS_192x224x192_zscore.nii.gz
            │   │                     brain_mask_1mm_RAS_192x224x192.nii.gz
            │   └── native_t1w_hdbet[_bet].nii.gz         ← raw/native
            └── pet_amyloid/  pet_suvr_1mm_RAS_192x224x192.nii.gz (보유 세션만)
```

---

## 5. 로드 예시

```python
import pandas as pd, nibabel as np_nib, numpy as np
df = pd.read_parquet("/home/vlm/data/preprocessed_official/"
                     "official_manifest_full_n4_real_final.parquet")
row = df.iloc[0]
vol  = np_nib.load(row.final_tensor_n4_path).get_fdata(dtype=np.float32)  # (192,224,192)
mask = np_nib.load(row.final_mask_n4_path).get_fdata() > 0.5
# 또는: from Clinical.common.mri_io import load_manifest; df = load_manifest()
```

---

## 6. 사용 전 반드시 알아야 할 caveat

1. **train/test split**: 교차세션 **중복 4쌍** 존재(content-hash 검증). 특히 **AJU
   cross-subject 2쌍**(`ABD-BS-0013≡0014`, `ABD-AJ-0029≡0030`)은 ID가 달라 subject
   분할로도 leakage가 안 잡힘 → split 전 collapse 필수. OASIS 2쌍은 same-subject.
   상세: `Clinical/consortiums/PREPROC_QC_DUPLICATES.md`.
2. **N4 site 잔존**: N4는 순수 scanner bias를 절반으로 줄이나 해상도/메타데이터 축의
   site는 영상에서 제거 불가 → leave-one-consortium-out + 잔차 site 모니터링 권장.
3. **한국 코호트**: AJU/KDRC는 이 141열 manifest에 **포함**되며, 추가로 멀티모달 전용
   `korean_multimodal_manifest`(2,196×**93**, 2026-06-14 scanner+KDRC 재-enrich 반영)가 별도 존재.
4. **scanner model (신규)**: `acq_scanner_model`(family, 예 'Siemens Prisma') / `_raw`(DICOM 원문) /
   `_source`. ADNI 100%·AIBL 100%·AJU 96%·KDRC 91%·NACC 85%. A4/OASIS는 소스에 모델 없음(vendor만).
   상세 분포 `docs/SCANNER_DISTRIBUTION.md`.
5. **KDRC 임상 재-enrich (신규)**: KDRC 임상이 `KDRC*.zip` 중첩 4파일로 분산 → 병합 재추출로
   apoe/amyloid_visual 909/909, scanner 456→831, mmse 852 등 대폭 보강(충돌 0, codebook 검증).
6. **임상 결측**: clin_* 대부분 ≥97% 백필됐으나 진짜 source 공백(KDRC 일부, OASIS/AJU 잔여)은
   날조하지 않고 결측 유지. KDRC scanner 78건은 임상파일에 코드 자체가 '-'(공백).
7. **QC 전수 PASS의 의미**: 전 행 final/fs QC PASS = 물리적으로 건전·내부 일관(전처리
   파일 전수 재검증 완료, FAIL 0). 단 해부학적 정합성(L/R flip 등)은 보증 범위 밖.

> 전처리 파일 전수 QC 결과: `Clinical/consortiums/PREPROC_QC_ROLLUP.md`,
> 컨소시엄별 `Clinical/consortiums/<C>/preproc_qc/`.
