# SCRATCHPAD — microbrain (live state)

> 현재 라인의 상태·가설·결과를 여기에 누적. 핸드오프 시 이 파일로 상태 전달. 최신이 위.
> 과거 라인 기록은 `docs/DECISION_LOG.md`·`docs/ledgers/`·`insight/`에 보존됨.

## 2026-06-18 — Korean 원본 clinical 파싱/EDA 노트북 생성
- 용량 해석 보정: 사용자가 지적한 대로 현재까지 일반 경로 스캔으로 확인한 visible 큰 트리 합계는 `df`의 12T 사용량에 못 미침. `/home/vlm`은 GPFS 15T 중 12T 사용, inode는 33M 중 32M 사용(98%). 따라서 현재 보고값은 "접근 가능한 visible subtree의 apparent-size"이며, 실제 `df` 차이는 GPFS quota/fileset/snapshot/deleted-open file/권한 없는 트리/블록 accounting 차이까지 확인해야 함. 긴 `find` 스캔은 GPFS I/O에서 D-state로 멈춰 종료 처리.
- 추가 용량 조사: `df`의 15T/12T는 GPFS 파일시스템 전체 사용량이며, visible subtree apparent-size와 1:1 대응하지 않을 수 있음. 접근 가능한 큰 데이터 트리 기준으로는 `/home/vlm/data/FOMO300K`가 약 2134.2G로 최대. 내부 top: `PT030_OpenNeuro` 1115.1G, `PT020_HCP_Wu_Minn` 328.7G, `PT018_HBN` 222.3G. `/home/vlm/data/preprocessed_official/v2` cohort 합산은 약 370G대(AJU 85.4G, KDRC 65.5G, OASIS 60.6G 등). raw는 약 786.2G.
- raw top-level 용량 확인: `/home/vlm/data/raw` apparent-size 합산 기준 약 786.2G. 큰 순서: oasis3 263.8G(33.6%), ADNI 170.0G(21.6%), KDRC 132.9G(16.9%), A4 98.7G(12.6%), NACC 63.0G(8.0%), AJU 57.8G(7.4%). top3가 약 566.7G(72.1%).
- 추가: APOE와 MRI row 매칭을 눈으로 확인하기 위해 `experiments/korean_clinical_original_parse_eda.ipynb`에 APOE-MRI QC 섹션 추가.
- 산출물: `experiments/apoe_mri_qc_jpg/apoe_mri_{CN,MCI,AD,Other,OtherDementia}.jpg`와 `experiments/apoe_mri_qc_jpg/apoe_mri_qc_index.csv`.
- QC 결과: `dx_session` 기준 eligible 2056행, T1w path exists 2056/2056, duplicate consortium+subject+session key 0. 클래스별 montage는 sagittal/coronal/axial mid-slice와 subject/session/APOE/e4/MMSE 라벨을 같이 표시.
- 시각 확인: `apoe_mri_CN.jpg`를 열어 MRI와 APOE 라벨 가독성 확인 완료.
- 요청: Korean(AJU·KDRC) 데이터를 canonical manifest 기준으로 가져오고, 원본 clinical Excel을 보수적으로 파싱해 EDA하는 ipynb 작성.
- 생성: `experiments/korean_clinical_original_parse_eda.ipynb`; 재생성 스크립트 `experiments/build_korean_clinical_original_parse_eda_nb.py`.
- 데이터 기준: `/home/vlm/data/preprocessed_official/official_manifest_full_n4_real_final.parquet`, `/home/vlm/data/preprocessed_official/korean_multimodal_manifest.csv`.
- 원본 clinical: AJU `/home/vlm/data/raw/AJU/metadata/임상역학정보 분양_all.xlsx`(실제 파일명은 NFD라 notebook에서 NFC resolver 사용), KDRC `/home/vlm/data/raw/KDRC/clinical.xlsx`.
- 파싱 검증: AJU BL 1322행·TFU 295행, KDRC 576행; key missing 0. 핵심 numeric 변환 실패 0.
- manifest 대조: AJU 1287/1287 session raw clinical 매칭, KDRC 534/909 session raw clinical 매칭; KDRC unmatched 375는 manifest의 `demo_source` 결측 375와 일치. raw-derived 핵심 변수와 manifest 비교 mismatch 0.
- EDA 포함: diagnosis/MMSE/amyloid/SUVR 분포, modality coverage, cohort별 missing-rate heatmap, numeric describe.
- 다음: 노트북 결과를 열어 mismatch=0과 KDRC 결측 구조를 확인한 뒤, clinical text schema 또는 분석 타깃 설계로 넘어갈 수 있음. KDRC 환자 인구학은 raw Excel의 보호자 정보와 혼동 금지.

## (활성 라인 없음 — 다음 주제 대기)
- 보존 자산: `RESEARCH_BRIEF.md`(설계 SoT) · `docs/DECISION_LOG.md` · `docs/ledgers/` · `insight/` · `src/microbrain/audit.py`.
- 다음: 새 라인 주제 설정 → 코드 전에 `docs/<phase>_plan.md`로 설계 합의 → 승인 후 착수. 여기에 상태 기록 시작.
