# CLAUDE.md — minyoungi 프로젝트 (project-local)
# 전역 ~/.claude/CLAUDE.md 의 행동 원칙을 상속하며, 본 파일이 **우선**한다.
# Codex 워크스페이스 규약은 AGENTS.md, 데이터/거버넌스는 docs/ 참조.

## 0. 이 프로젝트가 무엇인가
서구↔한국 다기관 뇌 MRI/임상 데이터로 AD biomarker / transportability를 연구한다.
canonical 데이터 = `official_manifest_full_n4_real_final.parquet` (13,022×141).
데이터 사실은 추측하지 말고 항상 manifest를 직접 inspect한다(전역 원칙 재확인).

## 1. 거버넌스 문서 체인 (분석 전 필독)
- [docs/DATASET_CARD.md](docs/DATASET_CARD.md) — 141열 type/leakage/missingness (데이터 사실)
- [docs/TASK_CARD.md](docs/TASK_CARD.md) — task 정의 + status + forbidden feature
- [docs/ENDPOINT_FEASIBILITY.md](docs/ENDPOINT_FEASIBILITY.md) — endpoint 가용성 audit (실측 표)
- [docs/VERIFIER_SPEC.md](docs/VERIFIER_SPEC.md) — leakage/confounding/shortcut 검증기
- [docs/EVALUATION_PROTOCOL.md](docs/EVALUATION_PROTOCOL.md) — baseline/metric/통계/external
- [docs/CLAIM_SCHEMA.md](docs/CLAIM_SCHEMA.md) — L0–L3 주장 수위
- [configs/task_status.yaml](configs/task_status.yaml) — 기계가독 status
- [docs/BLOCKER_LOG.md](docs/BLOCKER_LOG.md) — blocker + external join plan

## 2. 핵심 불변식
- **endpoint validity 먼저, 모델 나중.** outcome이 subject-level인지 visit-level인지, class variation이 있는지 확인하기 전엔 task를 시작하지 않는다.
- **생성≠검증.** 결과를 스스로 "완료/검증됨"이라 부르지 않는다. VERIFIER_SPEC 3종 독립 PASS 로그가 있어야 한다.
- **claim은 자동 강등.** CLAIM_SCHEMA가 허용하는 수위만 주장한다. L0는 결과로 보고 금지(blocker로만).
- **CDR proxy ≠ AD conversion.** 절대 혼용 금지(논문 붕괴 지점).

## 3. 데이터 안전 / 실행
- 전역 규칙 상속: sample/ 보호, GPU·10+파일 벌크·pyproject 변경은 사전 승인, surgical edit.
- manifest는 read-only로 inspect. 파생물은 `outputs/`에, 설정은 `configs/`에.
- Python: 서버 `uv run python`.

## 4. 현재 우선 연구 task

현재 primary task는 biomarker discovery agent 구현이 아니라 **endpoint feasibility audit**이다.

**Primary Task v0**: 현재 manifest와 live parquet 기준으로 실행 가능한 endpoint, blocked endpoint,
forbidden claim을 구분한다.

Agent 개발은 아래 조건이 충족된 뒤에만 진행한다 — **Activation criteria**:
1. outcome이 subject-level인지 visit-level인지 확인됨
2. outcome class variation이 존재함
3. train/test leakage 가능성이 검증됨
4. longitudinal task의 경우 per-visit label과 temporal ordering이 존재함
5. amyloid task의 경우 amyloid status 또는 SUVR label이 외부 조인되어 검증됨
6. task별 forbidden feature가 정의됨

**현재 상태 (2026-06-18 audit):**
- MCI-to-AD conversion: **BLOCKED** (per-visit dx 재조인 필요; Korean은 구조적 불가)
- Amyloid PET positivity: **COHORT-DEPENDENT** → **Task3A** within-cohort(AJU·KDRC·OASIS·NACC) EXECUTABLE(L2 internal only) / **Task3B** transportability(pooled·ADNI) BLOCKED(L0) / A4 FORBIDDEN(single-class) / ADNI·AIBL label 부재
- CDR-based progression proxy: **CANDIDATE**, but must not be described as AD conversion
- Cross-sectional severity association: **EXECUTABLE_WITH_CAUTION**

**다음 단계 (우선순위)**:
1. Endpoint feasibility audit v1 — **완료** (docs/ENDPOINT_FEASIBILITY.md + outputs/endpoint_audit/).
2. Amyloid label audit + **Step 2.0 hardening** — **완료** (docs/AMYLOID_LABEL_AUDIT.md). 실측: OASIS=centiloid~20 CL clean(PARTIAL), NACC/KDRC/AJU=LABEL_UNVERIFIED, A4=FORBIDDEN. 아직 LABEL_LOCKED 없음.
3. **Baseline 코드 gated** (scripts/run_task3a_baseline.py, default smoke_test; formal은 label_status 게이팅, 미허용 exit 1). **formal 실측 run은 label lock 전 보류** — `LABEL_UNVERIFIED` 코호트는 smoke_test만, 결과 해석 금지.
4. 다음: OASIS temporal-window rule 정의 → OASIS formal(association-only) → NACC/AJU/KDRC label 확정 → leakage/shortcut/confounding **verifier 구현**(docs/VERIFIER_SPEC.md) → LangGraph agent.
5. Task3B/Task2는 external join(BLOCKER_LOG Plan A/B) 성공·검증 후에만 활성화.

## 5. 실험 추적
- 현재 상태/핸드오프: 루트 `SCRATCHPAD.md`.
- 장기 결정/검증값: auto-memory (MEMORY.md 인덱스).
- 커밋: 타입태그 영어 + 설명 한국어, 실험 커밋은 SCRATCHPAD 갱신 동반.
