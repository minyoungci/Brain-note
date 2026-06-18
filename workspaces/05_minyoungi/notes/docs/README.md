# docs/ — 데이터·매니페스트 정본 (canonical reference)

이 폴더는 **현재 확정된** 데이터/매니페스트 명세와 경로의 단일 참조처다.
(연구 전략 dossier는 `../research_topic/`, 일일 로그는 `../research_notes/daily/`.)

## 현재 문서 (2026-06 확정)

### 데이터·매니페스트 정본
| 문서 | 용도 |
|---|---|
| [INDEX.md](INDEX.md) | repo 전체 인덱스 (시작점) |
| [MANIFEST_AND_DATA_PATHS.md](MANIFEST_AND_DATA_PATHS.md) | canonical 141-열 manifest 스키마 + 파일 경로 + 로더 |
| [MANIFEST_FINAL_DATA_SPEC.md](MANIFEST_FINAL_DATA_SPEC.md) | ⭐코호트별 **raw 디스크 실보유 모달리티/임상** 전수 + 최종 사용데이터 결정 (2-층위: raw↔manifest) |
| [DATA_INVENTORY.md](DATA_INVENTORY.md) | 폴더별 보유/활용 가능 데이터 정리 |
| [SCANNER_DISTRIBUTION.md](SCANNER_DISTRIBUTION.md) | 코호트별 scanner vendor/model 분포 |

### 실험 거버넌스 (2026-06-18, manifest 실측 기반)
| 문서 | 용도 |
|---|---|
| [DATASET_CARD.md](DATASET_CARD.md) | ⭐141-열 전체 type 분류 + leakage-risk 등급 + missingness + **전환-task 막는 구조 제약**(실측) |
| [ENDPOINT_FEASIBILITY.md](ENDPOINT_FEASIBILITY.md) | ⭐endpoint 가용성 audit (7코호트×4엔드포인트 실측 표; EXECUTABLE/BLOCKED/FORBIDDEN) |
| [TASK_CARD.md](TASK_CARD.md) | Task1 횡단 severity / Task2 전환 / Task3A·3B amyloid / Task4 CDR proxy — status·forbidden feature |
| [AMYLOID_LABEL_AUDIT.md](AMYLOID_LABEL_AUDIT.md) | Task3A 선행: 코호트별 amyloid label 정의·시점정합·leakage 위험 (실측) |
| [BLOCKER_LOG.md](BLOCKER_LOG.md) | blocker + external join plan(A DXSUM / B amyloid / C NACC) |
| [VERIFIER_SPEC.md](VERIFIER_SPEC.md) | leakage / confounding / shortcut 검증기 3종 + V4 scorecard |
| [AGENT_BENCHMARK.md](AGENT_BENCHMARK.md) | ⭐Step 2.2: OASIS 결과 → agent claim-safety benchmark (claim-trap cases + scorecard) + generic vs verification-aware 평가 설계 |
| [EVALUATION_PROTOCOL.md](EVALUATION_PROTOCOL.md) | baseline 위계(B0–B4) · metric · 통계검정 · external(transportability) 계획 |
| [CLAIM_SCHEMA.md](CLAIM_SCHEMA.md) | L0–L3 claim 수위 자동 결정 규칙 |

> 기계가독 status: [`../configs/task_status.yaml`](../configs/task_status.yaml), 실측 표: [`../outputs/endpoint_audit/endpoint_feasibility_table.csv`](../outputs/endpoint_audit/endpoint_feasibility_table.csv).
> 거버넌스 체인: `DATASET_CARD`(데이터 사실) → `ENDPOINT_FEASIBILITY`(가용성) → `TASK_CARD`(과제·status·금지 feature) → `VERIFIER_SPEC`(게이트) → `EVALUATION_PROTOCOL`(평가) → `CLAIM_SCHEMA`(주장 수위). blocker 복구 = `BLOCKER_LOG`.

## figures/
PaperBanana로 생성한 현재 도표(데이터 개요·전처리 파이프라인·연구 도전·minyoung4)의 입력 prompt(`*/pb_*_input.md`)와
산출 PNG. (구 representation-learning 도표는 해당 라인 종료로 제거됨.)

## 정본 체인
`MANIFEST_FINAL_DATA_SPEC`(디스크에 무엇이 있나) → `MANIFEST_AND_DATA_PATHS`(QC-pass된 141-열 manifest로 무엇이 즉시 쓸 수 있나)
→ Korean 세부는 `../Clinical/consortiums/Korean/`.
