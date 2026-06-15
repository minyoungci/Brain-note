# docs/ — 데이터·매니페스트 정본 (canonical reference)

이 폴더는 **현재 확정된** 데이터/매니페스트 명세와 경로의 단일 참조처다.
(연구 전략 dossier는 `../research_topic/`, 일일 로그는 `../research_notes/daily/`.)

## 현재 문서 (2026-06 확정)

| 문서 | 용도 |
|---|---|
| [INDEX.md](INDEX.md) | repo 전체 인덱스 (시작점) |
| [MANIFEST_AND_DATA_PATHS.md](MANIFEST_AND_DATA_PATHS.md) | canonical 141-열 manifest 스키마 + 파일 경로 + 로더 |
| [MANIFEST_FINAL_DATA_SPEC.md](MANIFEST_FINAL_DATA_SPEC.md) | ⭐코호트별 **raw 디스크 실보유 모달리티/임상** 전수 + 최종 사용데이터 결정 (2-층위: raw↔manifest) |
| [DATA_INVENTORY.md](DATA_INVENTORY.md) | 폴더별 보유/활용 가능 데이터 정리 |
| [SCANNER_DISTRIBUTION.md](SCANNER_DISTRIBUTION.md) | 코호트별 scanner vendor/model 분포 |

## figures/
PaperBanana로 생성한 현재 도표(데이터 개요·전처리 파이프라인·연구 도전·minyoung4)의 입력 prompt(`*/pb_*_input.md`)와
산출 PNG. (구 representation-learning 도표는 해당 라인 종료로 제거됨.)

## 정본 체인
`MANIFEST_FINAL_DATA_SPEC`(디스크에 무엇이 있나) → `MANIFEST_AND_DATA_PATHS`(QC-pass된 141-열 manifest로 무엇이 즉시 쓸 수 있나)
→ Korean 세부는 `../Clinical/consortiums/Korean/`.
