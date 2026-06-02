# minyoungi — 근거 파일 / 재사용 자산

> **목적:** 발견·리스크의 근거 파일과 재사용 자산 목록  ·  **출처:** `/home/vlm/minyoungi` (커밋 2bfa860, HEAD; READ-ONLY)  ·  **갱신:** 2026-06-02

워크스페이스 루트: `/home/vlm/minyoungi` (독립 git repo). READ-ONLY로 열람.
HEAD 커밋: `2bfa860 Audit Gate05b NACC per-target ROI failures` (커밋 author date 2026-05-28).

---

## A. 워크스페이스 가이드 (역할 정의)

| 파일 | 내용 | 비고 |
|---|---|---|
| `/home/vlm/minyoungi/README.md` | 워크스페이스 역할 = 문헌/PET-MRI background/paper triage/연구노트. 실험은 minyoung2/4 | 지원 워크스페이스 선언 |
| `/home/vlm/minyoungi/AGENTS.md` | Codex 가드레일, Karpathy식 원칙, ontology source-of-truth 규칙 | 15KB |

## B. Clinical 데이터 이해 (핵심 daily + 노트북)

| 파일 | 내용 | 읽음 |
|---|---|---|
| `research_notes/daily/2026-05-31.md` | **핵심**: CDR 공통타깃, 39% 결측 오진단, ComBat, BLOCKED_PROVISIONAL 발견 | ✅ 전문 |
| `research_notes/daily/2026-06-02.md` | site/scanner shortcut + N4 mini-exp 상세 | 참조(scratchpad 경유) |
| `Clinical/README.md`, `Clinical/VOXEL_ANALYSIS_PLAN.md` | clinical 디렉토리 설명, voxel 데이터셋 조직안 | 목록 확인 |
| `Clinical/notebooks/00~04` | manifest align / consortium overview / image-clinical / ROI volume / repr-learning challenges | **재사용 자산** (헤드리스 통과) |
| `Clinical/notebooks/05_cdr_common_target.ipynb` | CDR Global 공통 타깃 (use_with_safeguards) | **재사용 자산** |
| `Clinical/notebooks/06_harmonization_combat.ipynb` | ComBat site harmonization 실증 | **재사용 자산** |
| `Clinical/consortiums/{C}/{C}_01_clinical_eda·02_mri_voxel_roi·03_3d_render` | 7컨소시엄 × 3 deep EDA (21개) | **재사용 자산** |
| `Clinical/common/{mri_io,roi_tools,render3d,clinical_io,nbgen}.py` | 공유 lib (roi_tools.centroid는 마스크 재계산) | **재사용 자산** |
| `Clinical/notebooks/roi_volumes_full.parquet` | 전수 13,022 ROI volume (결측 0%, 단 provisional) | 데이터 |

## C. Gate05b ROI / NACC audit (최근 커밋 흐름)

| 파일 | 내용 | 커밋 |
|---|---|---|
| `docs/context/VALIDATION_LOG.md` | **핵심**: Gate04~05 전 실험 검증 로그(810줄). NACC per-target, distribution, failure audit 수치 전부 | 2bfa860 |
| `docs/context/GATE05B_ROI_LANGUAGE_SUPERVISION_PLAN.md` | Gate05b 설계: b0~b3 variants, Baseline06/07 게이트, pass/fail 라벨 | 2e5ab25 계열 |
| `docs/context/GATE05B_PRIMARY_STRESS_SPLIT_POLICY.md` | primary(ADNI/AIBL/KDRC) vs stress(NACC) 보고 정책 | 5c9296a |
| `docs/context/GATE05B_PREFLIGHT_DRYRUN_2026-05-28.md` | preflight caption + CPU dry-run audit | beda26b |
| `docs/context/CAPTION_FIELD_POLICY.md` | allowed/forbidden text field 정책 | - |
| `experiments/voxelwise_feature_learning_v1/scripts/vlm_gate_05b_nacc_*.py` | NACC failure/distribution/per-target audit 스크립트 | eval-only, GPU 본진은 별도 |
| `experiments/voxelwise_feature_learning_v1/results/gate05b_*` | audit 산출물 CSV/REPORT_KO.md | - |

## D. ROI QC (Gate05b 게이트 파이프라인)

| 파일 | 내용 | 읽음 |
|---|---|---|
| `roi_qc/README.md` | ROI QC 파이프라인 개요, data scope strict(13,022), promotion gate | ✅ |
| `roi_qc/SCRATCHPAD.md` | **핵심**: 전수 auto-QC 결과(12,932 PASS), N4/site probe(06-02), 핸드오프 | ✅ 전문 |
| `roi_qc/ROI_USABLE_REPORT.md` *(실제명 `ROI_USABILITY_REPORT.md`)* | 99.54% pass, 3-게이트 weakest-link, 5 UNUSABLE 상세 | ✅ 전문 |
| `roi_qc/VISUAL_QC_CRITERIA.md` | 시각 QC 5-check 루브릭, tiered sampling | 참조 |
| `roi_qc/manifest_roi_qc_final.parquet` | 13,022 + roi_usability/roi_final_ready 컬럼 | 데이터 |
| `roi_qc/scripts/` | **재사용 자산**: auto_anatomical_qc, run_autoqc_full, probe_site, probe_robust, n4_extract_features, roi_verify_viz, merge_full_manifest 등 23개 | - |
| `roi_qc/reports/autoqc_full.parquet` | 12,978 후보 per-ROI metrics | 데이터 |
| `roi_qc/notebooks/roi_inspection.ipynb` | 인터랙티브 ROI↔MRI 시각 대조 | **재사용 자산** |

## E. 문헌 triage (literature)

| 파일 | 내용 |
|---|---|
| `literature/README.md`, `literature/notes/` | paper triage notes (PET learning readiness, VLM feasibility, 6-consortium modality status 등 11개) |
| `literature/index/external_index/20260516/` | 외부 논문 index |
| `literature/{config,figures,scripts}/` | API example, figures, 수집 스크립트 |
| `notes/context/` | workspace cleanup/validation 기록, CLINICAL_BIOMARKER_AVAILABILITY_AUDIT, PROJECT_GOAL 등 |

## F. 외부 참조 (이 워크스페이스 밖, audit가 가리킴)

| 경로 | 내용 |
|---|---|
| `/home/vlm/data/preprocessed_official/official_manifest.csv` | 13,022 rows, 공식 manifest (ROI-mask readiness 컬럼은 없음) |
| `/home/vlm/data/preprocessed_official/official_manifest_full.{parquet,csv}` | 13,022×75 통합 manifest (roi_qc가 빌드, 원본 불변) |
| `/home/vlm/minyoung/Official/sky/2026-05-2x_*.md` | 각 Gate audit의 Official 한국어 노트 (VALIDATION_LOG가 참조) |

---

## 확인 메모

- **HEAD = 2bfa860** (`git rev-parse --short HEAD`). git log 상 author date 2026-05-28이 최신. 최근 5커밋: Gate05b NACC per-target audit / ROI distribution audit / failure modes / primary stress split / roi ce sweep.
- 파일명 주의: 리포트 실제 파일은 `roi_qc/ROI_USABILITY_REPORT.md` (위 표 D에서 단축 표기).
- minyoungi 파일은 READ-ONLY로만 열람, 수정/실행/GPU 없음.
