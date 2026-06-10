# minyoungi — AD Brain MRI Research Workspace

> ⭐ **오늘의 노트 (2026-06-10) → [`research_notes/daily/2026-06-10.md`](research_notes/daily/2026-06-10.md)**
> manifest 138컬럼 완성 · raw_*_path 7코호트 11,947경로 검증 · 전처리 파이프라인 구조 정비

> **📑 전체 색인(중요도 순): [`docs/INDEX.md`](docs/INDEX.md)** — manifest, 실험 결론, 노트, 빌드 스크립트, 도구를 한곳에서 탐색.

---

## 빠른 시작

| 무엇을 하려면 | 어디로 |
|-------------|--------|
| manifest 로드 | `Clinical/common/mri_io.py` → `load_manifest()` |
| raw NIfTI 경로 | manifest `raw_t1/flair/t2/dwi/pet_path` 컬럼 |
| 연구 방향 확인 | `research_topic/README.md` |
| 실험 결론 | `roi_qc/experiments/harmonization/SCANNER_BIAS_PLAYBOOK.md` |
| 일일 노트 | `research_notes/daily/` |

## 워크스페이스 구조

```text
AGENTS.md              # agent guardrail
README.md              # 이 파일
docs/
  INDEX.md             # 전체 색인 (TIER 0~5)
  figures/             # PaperBanana 생성 figure
Clinical/
  common/              # mri_io, roi_tools, render3d
  studies/             # 연구 튜토리얼·QC 노트북
  notebooks/           # 탐색·EDA 노트북 (09_oasis3_data_files_eda 등)
roi_qc/
  scripts/             # manifest 빌드·enrichment 스크립트 (~40개)
  experiments/
    harmonization/     # 01~09 bias check, ComBat, GAM, MixStyle + PLAYBOOK
preprocessing/
  dicom_to_nifti/      # AJU/ADNI/NACC DICOM 변환 (dcm2niix)
  raw_manifest/        # raw_*_path 컬럼 빌드 (7코호트 resolver)
  modalities/          # FLAIR/T2/PET 전처리 파이프라인
  shared/              # nifti_io, transform_chain, bias, qc
research_topic/        # 연구 주제 적부 판정 dossier
research_notes/
  daily/               # 일일 노트 (2026-05-31 ~)
literature/            # 논문 index, notes
notes/context/         # 검증·정리 기록
```

## 운영 원칙

- 실험 코드는 `/home/vlm/minyoung2`, `/home/vlm/minyoung4`에서 실행.
- manifest 원본 컬럼은 **절대 불변**. enrichment는 NaN-only fill 누적.
- GPU 스크립트·10+파일 변경·대량 배치 → 사전승인 필수.
- 일일 노트는 `research_notes/daily/YYYY-MM-DD.md` 에 작성.
