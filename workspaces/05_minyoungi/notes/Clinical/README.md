# Clinical — Raw/Source Data 이해 및 Manifest Alignment 검증

이 디렉토리의 목표: **완벽한 실험이 아니라**, 7개 컨소시엄의 clinical/source 데이터를
철저히 이해하고, manifest alignment와 row-level join 가능성을 교육용/검증용 ipynb로
직접 확인하는 것. 이미지를 하나씩 열어 수치 데이터와 비교하며, 3D/2D 뇌 알츠하이머
Representation Learning(RL)이 왜 어려운지에 대한 인사이트를 도출한다.

> 🧭 **인사이트 축으로 노트북을 찾으려면 → [`INSIGHTS.md`](INSIGHTS.md)** (인사이트→노트북+섹션 지도, 모델링은 PLAYBOOK으로 브릿지). 이 README는 데이터 소스·구조·검증된 데이터 사실의 레퍼런스.

## 데이터 소스
- 전처리 데이터: `/home/vlm/data/preprocessed_official/v2/{ADNI,NACC,AIBL,OASIS,A4,AJU,KDRC}`
- ⭐ **canonical manifest (단일 진실): `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`** (13,022행 × 117컬럼)
  - `+ .csv`, `+ .datadict.csv`(컬럼별 dtype·커버리지·소스), 옆 `README_MANIFEST.md`(provenance·CSF·gap).
  - provenance: `official_manifest.csv`(원본 12) → `_full`(75) → `_n4`(101) → +KDRC → +AJU/ADNI-MMSE = **real_final(117)**. 원본 컬럼은 단 한 번도 덮어쓰지 않음(NaN-only fill).
  - `common/mri_io.py`의 `MANIFEST`가 real_final을 가리킴 → 분석/실험은 이 로더 사용. base lineage(`official_manifest.csv/_full/_n4`)는 **빌드 입력으로만 유지**, 중간본 v2/v3는 real_final로 통합·삭제됨.
- 임상 커버리지(real_final, 117→**122컬럼**): MMSE A4·AIBL·AJU·**OASIS 100%**·ADNI 99%, KDRC 52%·NACC 16%; APOE/education/amyloid 보강. OASIS는 UDS-b4 nearest-visit로 MMSE 29%→100%·CDRSUM, amyloid centiloid(`oasis_amyloid_*`) 추가. **CSF 농도값(Aβ/p-tau/t-tau)은 전 컨소시엄 부재** → [`consortiums/CSF_BIOMARKER_SCAN_20260609_KO.md`](consortiums/CSF_BIOMARKER_SCAN_20260609_KO.md).
- per-consortium manifest: `v2/{C}/manifests/*_raw_input_manifest_*.csv` (진단/나이/성별), `*_t1w_full_preprocessed_ready_manifest_*.csv` (QC/geometry)
- raw clinical (컨소시엄별 상이): `/home/vlm/data/raw/{C}/...` — `common/clinical_io.py`가 로더 제공. 한국 코호트 상세 파싱: [`AJU`](consortiums/AJU/AJU_CLINICAL_PARSE_20260609_KO.md), [`KDRC`](consortiums/KDRC/KDRC_CLINICAL_PARSE_20260608_KO.md).

## 주요 인사이트 — 왜 RL이 어려운가 (2026-06-02, 실측)
멀티컨소시엄 통합의 핵심 난점 = **site/스캐너 bias가 영상에 남아 shortcut이 됨**. 상세: `research_notes/daily/2026-06-02.md`, memory `v2-no-n4-bias-correction`·`manifest-acq-voxel-site`.
- 영상 외형만으로 컨소시엄 balanced_acc 0.565(chance 0.143); 형태(brain_vox)는 ≈chance → 누수는 강도/대비/해상도(스캐너 지배).
- v2엔 N4 bias correction이 없었음(z-score만) → **N4(post-FastSurfer)로 순수 스캐너 bias 절반 감소, 모집단 보존**. WhiteStripe/Nyúl은 무이득.
- **해상도/voxel은 독립 site 축**(AJU 0.78mm·KDRC 0.40mm 고해상도 → voxel만으로 코호트 0.53). native 헤더로 voxel 100% 복구 가능.
- ⚠️ site==모집단 교란(한국인 AJU/KDRC vs 서구) → site를 무리하게 지우면 비교하고 싶은 생물학까지 손실.

## 디렉토리 구조
```
Clinical/
  INSIGHTS.md             # ⭐ 인사이트→노트북 내비게이션 (먼저 읽기)
  README.md               # (이 파일) 데이터 소스·구조·검증된 데이터 사실
  VOXEL_ANALYSIS_PLAN.md  # ROI BLOCKED_PROVISIONAL 게이트 절차
  notebooks/              # cross-consortium overview (00–06) + master_df/roi_volumes parquet
                          #  00 manifest_alignment → 01 overview → 02 image↔clinical → 03 ROI vol
                          #  → 04 RL challenges → 05 CDR target → 06 ComBat  (의존체인: 00 먼저)
  common/                 # 공유 라이브러리 (검증 완료, 노트북 재사용, 절대경로 import)
    mri_io.py             #  manifest/tensor/mask 로드, voxel 통계
    roi_tools.py          #  option_b final_tensor-grid ROI 정합검증·voxel·overlay
    render3d.py           #  marching_cubes mesh + 정적(matplotlib)/인터랙티브(plotly)
    clinical_io.py        #  컨소시엄별 raw clinical 로더 + manifest join 매핑
    nbgen.py, build_*.py  #  노트북 생성기 (재현/재생성용)
  consortiums/{C}/        # 컨소시엄별 Deep EDA 튜토리얼 (각 3개, 7코호트 동일 템플릿)
    {C}_01_clinical_eda.ipynb     # raw clinical 스키마·분포·manifest row-join 가능성
    {C}_02_mri_voxel_roi.ipynb    # final_tensor 수치검증 + option_b ROI voxel-level 오버레이
    {C}_03_3d_render.ipynb        # ROI→mesh(marching_cubes) 정적+인터랙티브(HTML) 렌더
  studies/                # 심화 스터디 (최신, official_manifest_full_n4 기반)
    research_tutorial/notebooks/research_data_tutorial.ipynb  # ⭐ 새 실험 종합 입문(37code/52md)
    qc_scanner_render/notebooks/   # roi_anatomy_tutorial · data_quant_study
                                   #  · qc_scanner_render_study · dkt_cortex_extraction
```
> orphan: `../roi_qc/notebooks/roi_inspection.ipynb` (소형 단건 cross-check, CWD 상대경로 — 이동 금지).
모든 노트북은 `base`(`/opt/conda`)에서 헤드리스 실행 검증됨(21/21 OK). 추가 의존: `nilearn plotly pyvista`(설치 완료).

## ⚠️ 결정적 경고: ROI는 BLOCKED_PROVISIONAL (후보 데이터)
manifest **전수 13,022행**에서 `do_not_use_for_atlaswide_roi_features=True`, `roi_final_ready=False`,
`roi_final_grid_qc_status=BLOCKED_PROVISIONAL` (reason: *FastSurfer-to-native transfer requires ROI-specific
visual approval; candidates are provisional*). → **option_b ROI/부피 기반 결과(03·05·06·consortium 02/03)는
"검증됨"이 아니라 "후보(provisional)"**. 정량 주장 전 `_reports/roi_transfer_option_b_*`의 per-ROI
overlap/volerr/status로 QC 게이트 필요. 상세: `VOXEL_ANALYSIS_PLAN.md`.
또한 summary JSON `centroid_voxel`은 256-conformed 좌표(그리드와 ~31vox 어긋남) → 크롭 중심은
`expected_centroid_final_voxel`/마스크 재계산값 사용(단 `voxel_count`는 그리드와 일치, 부피는 신뢰 가능).

## 핵심 사실: MRI/ROI 그리드 (voxel-level 작업 전제)
- `final_tensor`: **192×224×192, identity affine, z-score**(뇌내부 mean≈0/std≈1) — 모델 입력 그리드.
- `roi_masks/*.nii.gz`: **256³ conformed space** → final_tensor에 직접 오버레이 **불가**.
- ✅ **voxel-level은 `roi_transfer_option_b_candidate_v0/`의 final_tensor-grid 버전 사용**:
  `aparc_DKTatlas_aseg_final_tensor_grid_*.nii.gz`(aseg 96 label) + `roi_masks_final_tensor_grid_*/`(per-ROI 16종) + `option_b_one_subject_summary.json`(voxel_count/volume/centroid/status). **7개 컨소시엄 60/60 샘플 존재**.
- FastSurfer VINN은 **eTIV 미산출** → ICV 정규화는 `MaskVol` 프록시 사용.

## Clinical ↔ Manifest Row-level Join 가능성 (검증값)
| 컨소시엄 | clinical source | ID 매핑 | manifest 커버리지 |
|---|---|---|---|
| ADNI | adni_t1w_clinical_final.csv | subject_id 직접 | 99% |
| NACC | commercial_nacc70.csv | NACCID | 100% |
| AIBL | aibl_{pdxconv,cdr,mmse,ptdemog} merge | RID→`AIBL_<RID>` | 100% |
| OASIS | OASIS_meta.csv | subject_id | **29% ⚠️ (부분집합)** |
| A4 | Clinical/SUBJINFO.csv | BID→`A4_A4_<BID>` | 100% (992) |
| AJU | 임상역학정보_all.xlsx (BL) | epid 직접 | 100% |
| KDRC | kdrc_unified_clinical_DEDUP (v1) | dedup_subject_id | 85% |

> OASIS_meta는 imaged subject의 ≈29%만 커버 — 나머지 CDR은 manifest(raw_input) 기준. A4는 preclinical이라 임상 진단 라벨 없음(APOE/MMSE/amyloid가 축).

## 실행 순서 (의존성)
노트북은 `base` (`/opt/conda`) 파이썬에서 실행한다. 반드시 순서대로:

```
00_manifest_alignment.ipynb      → master_df.parquet (13,022 × 44)   [기반]
01_consortium_overview.ipynb     → 컨소시엄별 정량 비교/편향          (master_df 필요)
02_image_clinical_comparison.ipynb → T1w NIfTI 직접 열람 vs CDR/진단   (master_df 필요)
05_cdr_common_target.ipynb       → CDR Global 공통 target 타당성(전수 근거) (roi_volumes_full 필요)
06_harmonization_combat.ipynb    → ComBat로 site 편향 제거 실험(before/after)  (roi_volumes_full 필요)
   * 전수 ROI: common/extract_roi_full.py → roi_volumes_full.parquet (13,022, ROI 결측 0%)
03_roi_volume_analysis.ipynb     → roi_volumes.parquet + ROI vs 임상  (master_df 필요)
04_repr_learning_challenges.ipynb → RL 난점 6종 실증 + 전략           (master_df + roi_volumes 필요)
```

헤드리스 실행:
```bash
/opt/conda/bin/jupyter nbconvert --to notebook --execute --inplace 00_manifest_alignment.ipynb
```
의존 패키지(설치 완료): `pyarrow`, `nbconvert`, `nbclient` (+ base의 pandas/nibabel/sklearn/scipy/seaborn).

## 검증 중 발견한 데이터 사실 (RL 난점의 실증 근거)

| 항목 | 내용 | 근거 |
|------|------|------|
| **sex 코딩 이질성** | ADNI/NACC/AIBL/OASIS=`M/F`, A4=`Male/Female`, **AJU=`0/1`(정수)**, KDRC=결측. 정수/문자 혼재가 parquet 직렬화를 깨뜨림 → `_norm_sex`로 캐논 `{M,F,None}` 통일 | 00번 |
| **AJU sex 매핑** | `0=여(F)`, `1=남(M)` | 공식 설명서 `임상역학정보_all_설명서.xlsx` CE_01_base.sex |
| **diagnosis 결측** | A4·KDRC는 diagnosis 0% (A4=preclinical 예방시험, KDRC=한국 코호트). NACC 85%, AJU 96% | 00번 join report |
| **FastSurfer VINN에 eTIV 없음** | VINN stats는 eTIV/EstimatedTotalIntraCranialVol 미산출. 대신 `MaskVol`/`BrainSegVol` 존재 → **MaskVol을 ICV 프록시로 사용**(진짜 eTIV 아님, cross-site 정규화 한계) | 03번 |
| **FastSurfer 경로 레이아웃** | `t1w/fastsurfer/<subject_id>/stats/aseg+DKT.VINN.stats` (subject_id 디렉토리 레벨 존재). inner dir == subject_id (7개 컨소시엄 모두 확인). ⚠️ session_id로 경로를 재구성하면 안 됨 — ADNI 세션 디렉토리는 `<date>.0`로 `.0` 접미사가 붙는데 master_df는 join 위해 `.0`를 strip하므로 경로가 깨짐. **`final_tensor_path`에서 t1w 디렉토리를 유도**해야 함 | 03번 |
| **ROI 명명** | entorhinal/parahippocampal은 cortical → `ctx-lh/rh-*`. thalamus는 `Thalamus`(not `Thalamus-Proper`) | 03번 aseg+DKT |
| **FastSurfer 커버리지** | **13,022건 전수 100% stats 파일 존재** (경로를 final_tensor_path에서 올바르게 유도 시). `fs_qc_status`도 전건 PASS. 초기 "39% 결측"은 위 session_id `.0` strip 버그였고, 수정 후 500 샘플 파싱 실패 0건 | 전수 stat 확인 |
| **join 무결성** | 3-way join 성공률 100%, 중복 0, 라벨 커버리지 96.9%(labeled 컨소시엄) | 00번 |

## 검증된 정량 결과 (샘플 기준)
- 해마 부피 AD < CN: Mann-Whitney p=3.3e-08 (CN 7680 vs AD 6455 mm³)
- ROI 부피만으로 AD vs CN 분류: ROC-AUC ≈ 0.81 (제한적 신호 → 이미지 RL 부가가치 구간)
- AD-sensitive 복셀 비율 ≈ 0.28% (signal dilution)
- 진단 분포: CN 41.8% / MCI 26.6% / Unlabeled 23.4% / AD 8.2%
- 종단 MCI→AD 전환 subject: 128명

## 산출물
- `master_df.parquet`, `roi_volumes.parquet`
- `fig_0{1..4}_*.png` (그림 20개)

> 주의: 모든 결과는 검증/교육 목적의 샘플 기반(03은 500건 샘플). 본 실험은 별도 디렉토리에서.
