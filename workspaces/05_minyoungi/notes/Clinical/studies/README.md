# Clinical/studies/ — 심화 스터디 (최신, `official_manifest_full_n4` 기반)

교차코호트 체인(`../notebooks/00~06`)·코호트별 EDA(`../consortiums/`)보다 **뒤에 만든 심화 스터디**. N4 텐서 + 통합 manifest(13,022×101) 위에서 수치와 영상을 함께 본다.
공유 헬퍼: `../common/{mri_io, roi_tools, render3d}` (절대경로 import). 커널: `Python (/opt/conda)`.

> 🧭 인사이트 축 내비게이션은 상위 [`../INSIGHTS.md`](../INSIGHTS.md).

## research_tutorial/  — ⭐ 새 실험 종합 입문
| 노트북 | 내용 |
|---|---|
| `notebooks/research_data_tutorial.ipynb` | **데이터 처음 시작점.** 37code/52md, 8섹션: manifest 구조 · 영상공간/N4 · ROI 신뢰도 · 해부학 · FastSurfer 부피 · 임상 · site bias · 연구 체크리스트 |

## qc_scanner_render/  — QC·스캐너·해부 심화
| 노트북 | 내용 |
|---|---|
| `notebooks/roi_anatomy_tutorial.ipynb` | 뇌 부위(ROI) 해부 + AD 관련성 (MTL→심부GM→뇌실 순), 영상 오버레이 |
| `notebooks/data_quant_study.ipynb` | 수치(표/지표) ↔ 영상 통합 점검: §1 영상공간/z-score · §2 **ROI 신뢰도 진단★** · §3 부피↔voxel · §4 site/스캐너↔영상 · §5 CN/AD↔영상 |
| `notebooks/qc_scanner_render_study.ipynb` | QC-pass 스캔: (A) 컨소시엄 7종 삼면도+3D · (B) 스캐너 벤더별 |
| `notebooks/dkt_cortex_extraction.ipynb` | **재처리 없이** 기존 grid aseg에서 DKT 피질 영역 추출 + 신뢰도(inside_brain/lr_asym) |
| `derived_dkt/`, `out/`, `scripts/` | 파생 마스크(비파괴) · 산출물 · 빌더/헬퍼 |

⚠️ option_b ROI는 **BLOCKED_PROVISIONAL**(후보) — 정량 주장 전 `../VOXEL_ANALYSIS_PLAN.md` 게이트.
