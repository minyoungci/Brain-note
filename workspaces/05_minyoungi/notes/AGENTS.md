# AGENTS.md - minyoungi Codex Workspace

이 파일은 `/home/vlm/minyoungi`에서 작업하는 Codex 및 자율 코딩 에이전트를 위한 작업 지침이다.

핵심 철학은 Karpathy식 코딩 원칙을 따른다.

- 코딩 전에 먼저 생각한다.
- 가정과 불확실성을 숨기지 않는다.
- 최소한의 코드로 해결한다.
- 필요한 파일만 외과적으로 수정한다.
- 작업 단위를 작게 나누고 검증 기준을 명시한다.
- 채팅 기록이 아니라 파일에 컨텍스트를 남긴다.
- 코드 작성, 검토, 검증을 사고 단계에서 분리한다.

## 0. 워크스페이스 목적

`/home/vlm/minyoungi`는 깨끗한 Codex 연습 및 작업용 워크스페이스다.

이 워크스페이스에는 Codex 작업을 위한 최소 구조와 데이터 링크만 둔다.

Ontology/data/cohort/experiment/claim 관련 작업에서는 반드시 `docs/ONTOLOGY_OPERATING_RULES.md`와 `ontology/registry/*.yaml`을 먼저 확인한다. Codex가 기억해야 하는 canonical data basis, label contract, consortium-specific caveats, failure modes, claim discipline은 그 문서가 source of truth다.

```text
.git/                  # 이 워크스페이스의 독립 git repo
.gitignore
AGENTS.md              # 이 가드레일 파일
.codex/                # Codex 설정, hooks, custom subagents
.agents/skills/        # Codex 재사용 workflow skills
docs/                  # 최소한의 Codex 설정 문서와 context 문서
data_links/            # 공유 데이터 위치로 연결되는 symlink
```

Min이 명시적으로 요청하지 않는 한, 다른 워크스페이스에서 source code, checkpoint, log, experiment output, 오래된 agent 설정, 과거 연구 산출물을 복사하지 않는다.

의도한 운영 패턴은 다음과 같다.

```text
Codex 설정, 문서, skills, hooks, custom subagents는 이곳에 둔다.
데이터는 data_links symlink를 통해 접근한다.
실제 코드는 새 작업에서 의도적으로 생성한다.
다른 워크스페이스의 코드를 통째로 상속하지 않는다.
```

## 1. 최상위 원칙

정확하고, 보수적이고, 단순하며, 검증 가능하게 일한다.

목표는 많은 코드를 쓰는 것이 아니다. Min의 의도를 가장 작은 올바른 산출물로 번역하고, 그것이 맞는지 확인하는 것이다.

파일을 변경하기 전에 다음을 식별한다.

```text
Task:
Files to change:
Expected artifact:
Validation:
Risks:
Unclear assumptions:
```

Min이 명시적으로 요청하지 않는 한 broad edit, 대량 directory import, speculative structure 생성을 하지 않는다.

## 2. Karpathy식 코딩 철학

이 지침은 속도보다 신중함을 우선한다. 단순한 작업에서는 판단을 사용하되, 연구 구현이나 서버 작업에서는 이 원칙을 기본값으로 삼는다.

### 2.1 코딩 전에 생각하기

조용히 가정하지 않는다.

구현 전에 다음을 수행한다.

- 가정을 명시한다.
- 불확실성을 숨기지 않는다.
- 해석이 여러 개면 가능한 해석을 제시한다.
- 더 단순한 접근이 있으면 먼저 말한다.
- 작업이 불명확하면 멈추고 무엇이 불명확한지 말한다.
- 연구 정의, 통계 범위, 데이터 필터, irreversible implementation 방향은 임의로 선택하지 않는다.

### 2.2 단순함 우선

현재 요청을 해결하는 최소 코드를 작성한다.

추가하지 않는다.

- 요청받지 않은 기능
- 한 번만 쓰는 코드에 대한 abstraction
- 필요 없는 flexibility
- 요청받지 않은 configuration system
- 작은 script를 감싸는 과도한 framework
- 실제로 필요하지 않은 error handling

200줄로 작성한 해결책이 합리적으로 50줄로 가능하다면 단순화한다.

### 2.3 외과적 변경

필요한 것만 수정한다.

기존 파일을 편집할 때:

- 주변 코드를 임의로 개선하지 않는다.
- 관련 없는 파일을 reformat하지 않는다.
- 필요하지 않으면 rename 또는 reorganize하지 않는다.
- 선호와 다르더라도 기존 스타일을 따른다.
- 관련 없는 dead code를 발견하면 삭제하지 말고 보고한다.
- 내가 만든 변경 때문에 생긴 unused import, variable, function만 정리한다.

수정된 모든 줄은 Min의 요청과 직접 연결되어야 한다.

### 2.4 목표 기반 실행

모호한 목표를 검증 가능한 목표로 바꾼다.

예시:

```text
"버그를 고쳐줘"
-> 문제를 재현하고, patch하고, 더 이상 발생하지 않는지 확인한다.

"validation을 추가해줘"
-> invalid input을 정의하고, check를 추가하고, 예상된 실패 동작을 확인한다.

"리팩터링해줘"
-> 변경 전후 동작이 동일한지 확인한다.

"분석을 구현해줘"
-> input contract, unit of analysis, output artifact, validation check를 정의한다.
```

여러 단계 작업은 다음 형식으로 작게 나눈다.

```text
1. Step:
   Verify:

2. Step:
   Verify:

3. Step:
   Verify:
```

코드를 작성했다는 이유만으로 task가 완료된 것은 아니다. validation이 통과했거나 blocker가 명확히 문서화되었을 때만 완료로 본다.

## 3. 연구를 코드로 번역하는 사고 방식

연구 구현에서는 바로 코딩하지 않는다. 먼저 연구 질문을 계산 가능한 구조로 번역한다.

```text
Research question:
Computable definition:
Outcome:
Exposure / predictor:
Unit of analysis:
Grouping variables:
Time period:
Inclusion / exclusion criteria:
Required input columns:
Expected output:
Validation checks:
Ambiguous decisions:
```

outcome, grouping unit, filter scope, expected artifact가 불명확하면 구현을 시작하지 않는다.

데이터프레임 작업에서는 항상 다음을 생각한다.

- 한 row가 무엇을 의미하는가?
- key가 unique한가?
- join 이후 row 수가 변하는가?
- filter가 연구 질문과 맞는가?
- rate, count, percent, proportion을 혼동하지 않았는가?
- UI, CI, SE, SD를 혼동하지 않았는가?
- wide/long 변환 후 값이 보존되는가?

join, pivot, filter, summarize 이후에는 가능한 경우 다음을 보고한다.

```text
Rows before:
Rows after:
Join keys:
Grouping keys:
Duplicate keys:
Missing values:
Output path:
```

## 4. Memory 및 Context 관리

채팅 기록은 source of truth가 아니다.

오래 유지되어야 하는 컨텍스트는 파일에 남긴다. 그래야 다음 상황에서도 작업이 일관된다.

- 에이전트 교체
- 세션 재시작
- context compaction
- 장기 프로젝트
- builder, reviewer, verifier 간 handoff
- 여러 날에 걸친 분석 구현

### 4.1 Context 파일 구조

필요할 때 다음 파일을 사용한다.

```text
docs/context/WORKSPACE_STATE.md
docs/context/PROJECT_GOAL.md
docs/context/DATA_LINKS.md
docs/context/TASKS.md
docs/context/ANALYSIS_DECISIONS.md
docs/context/ASSUMPTIONS.md
docs/context/OPEN_QUESTIONS.md
docs/context/VALIDATION_LOG.md
docs/context/HANDOFF.md
```

모든 파일을 자동으로 만들 필요는 없다. 미래 작업에 실제로 유용한 durable context가 있을 때만 생성하거나 업데이트한다.

### 4.2 Context 파일별 목적

`WORKSPACE_STATE.md`

- 현재 워크스페이스의 구조
- 중요한 설정 위치
- 어떤 파일이 canonical인지
- 현재 알려진 제한 사항

`PROJECT_GOAL.md`

- 프로젝트의 목적
- 최종 산출물
- 성공 기준
- 범위에 포함되는 것과 제외되는 것

`DATA_LINKS.md`

- `data_links/`의 symlink 목록
- 실제 target path
- 읽기 전용 여부
- 데이터 사용 시 주의할 점

`TASKS.md`

- 진행 중인 task
- 완료된 task
- 보류 중인 task
- 각 task의 validation 상태

`ANALYSIS_DECISIONS.md`

- 연구 질문 정의
- outcome, exposure, grouping, time period 결정
- 모델 또는 분석 방법 선택 이유
- 대안과 tradeoff
- Min 승인 여부

`ASSUMPTIONS.md`

- 구현 또는 분석에 사용한 가정
- 아직 검증되지 않은 가정
- 가정이 틀렸을 때 영향

`OPEN_QUESTIONS.md`

- Min에게 확인해야 할 질문
- 데이터 확인이 필요한 부분
- 연구 정의가 모호한 부분
- 다음 작업을 막는 blocker

`VALIDATION_LOG.md`

- 실행한 검증 명령
- 검증 날짜
- 입력 파일
- 출력 파일
- pass/fail 결과
- 관찰된 문제

`HANDOFF.md`

- 중간에 멈춘 작업의 현재 상태
- 다음 에이전트가 바로 이어서 할 수 있는 정보

### 4.3 Context에 저장할 것

저장한다.

- 프로젝트 목적
- 현재 task 상태
- 데이터 위치
- 데이터 contract
- 분석 결정
- 중요한 가정
- unresolved question
- validation 결과
- 중요한 command history
- handoff note

저장하지 않는다.

- secret
- API key
- password
- private credential
- 무관한 chat summary
- 일시적인 추측
- 대량 output 복사본

### 4.4 작업 시작 시 Context Protocol

작업 시작 시 다음 순서로 진행한다.

1. `AGENTS.md`를 읽는다.
2. 관련된 `docs/context/` 파일이 있으면 읽는다.
3. 수정 대상 파일을 먼저 inspect한다.
4. 현재 이해를 짧게 요약한다.
5. 빠진 context와 가정을 식별한다.
6. 다음 action이 명확하고 범위가 작을 때만 진행한다.

### 4.5 Context 업데이트 트리거

다음 상황에서는 context 파일을 업데이트하거나, 어디에 기록해야 하는지 Min에게 제안한다.

- 연구 결정이 내려졌을 때
- 데이터 contract를 발견했을 때
- 중요한 가정이 생겼을 때
- validation이 성공 또는 실패했을 때
- 작업을 중간에 멈출 때
- blocker가 발견되었을 때
- 미래 에이전트가 알아야 할 정보가 생겼을 때

기록은 간결하게 한다. narrative log보다 구조화된 note를 선호한다.

### 4.6 Handoff Note

작업을 완료하지 못하고 멈출 때는 다음 형식의 handoff note를 남긴다.

```text
Current goal:
Files inspected:
Files changed:
Commands run:
Current state:
Validation status:
Open questions:
Next recommended action:
```

`docs/context/HANDOFF.md`가 존재하고 작업이 non-trivial하면 업데이트한다.

## 5. Task Packet

non-trivial 작업은 편집 전에 작은 task packet으로 정의한다.

```text
Goal:
Inputs:
Files to change:
Outputs:
Assumptions:
Steps:
Validation:
Done when:
Needs Min approval:
```

task packet은 작아야 한다. 작업이 커지면 분할한다.

## 6. 역할 분리

non-trivial research 또는 coding work에서는 다음 사고 단계를 분리한다.

1. Builder: 가장 작은 동작 변경을 구현한다.
2. Reviewer: 가정, edge case, complexity, scientific fit을 검토한다.
3. Verifier: validation을 실행하거나 정의하고 expected criteria와 비교한다.

복잡한 코드를 작성한 동일한 pass가 별도 review 또는 verification 없이 final이라고 선언하지 않는다.

작은 작업에서는 하나의 에이전트가 세 단계를 모두 수행할 수 있다. 그러나 반드시 별도의 self-review 단계를 명시한다.

## 7. 데이터 안전

`data_links/`는 공유 데이터로 연결되는 symlink를 포함한다. symlink target은 보호 대상으로 취급한다.

다음 경로 아래에서는 write, delete, move, rename을 하지 않는다.

```text
/home/vlm/data/raw/
```

symlink를 통해 bulk-delete하지 않는다. destructive command 전에 symlink target에서 작업하고 있지 않은지 확인한다.

```bash
cd /home/vlm/minyoung2
python - <<'PY'
from pathlib import Path
for p in Path('data_links').glob('*'):
    print(p, 'is_symlink=', p.is_symlink(), '->', p.resolve())
PY
```

## 8. 기본 허용 및 금지 사항

기본 허용:

```text
작은 Codex 문서 생성/수정
Min이 요청한 새 code file 생성
data_links를 통한 read-only data inspection
read-only inspection command 실행
작은 CPU-only validation 실행
작은 audit script 생성
```

명시적 승인 전 금지:

```text
GPU training 또는 long job
대량 preprocessing/inference batch
10개 이상 파일의 bulk edit/delete
다른 workspace wholesale copy
shared data write/delete
checkpoint/log/output overwrite
canonical analysis definition 변경
background job 실행
```

## 9. GPU 및 Long Job Gate

GPU 또는 장시간 작업을 제안하기 전에 다음을 실행하고 보고한다.

```bash
nvidia-smi
pwd
git status --short
git branch --show-current
```

그다음 command preview만 제공한다.

Min의 명시적 승인 없이 `torchrun`, distributed job, long inference, large preprocessing을 실행하지 않는다.

## 10. Git 관리

이 워크스페이스는 독립 git repo다.

- 의미 있는 편집 전 가능하면 `git status --short`를 확인한다.
- Min이 명시적으로 요청하지 않는 한 commit, push, rebase, reset, checkout을 하지 않는다.
- 사용자 변경을 되돌리지 않는다.
- 변경은 작고 review 가능해야 한다.
- 관련 없는 dirty file은 수정하지 않고 언급만 한다.

## 11. Validation 규칙

가장 작은 관련 검증을 선호한다.

예시:

```text
syntax check
unit test
tiny sample smoke test
row-count check
key-uniqueness check
input/output schema check
before/after output comparison
small example manual calculation
```

연구 산출물은 traceability를 확인한다.

```text
input file
script used
parameters
row counts
grouping keys
output path
known limitations
```

validation을 실행할 수 없으면 이유를 말하고, 다음으로 가능한 검증 방법을 제시한다.

## 12. Codex Startup

이 워크스페이스에서 Codex가 참고해야 하는 파일:

```text
AGENTS.md
.codex/config.toml
.codex/hooks.json
.codex/agents/*.toml
.agents/skills/*/SKILL.md
docs/context/*.md
```

Codex에 처음 줄 추천 prompt:

```text
Read AGENTS.md and relevant docs/context files first. This is a clean Codex workspace. Do not assume old code exists unless the task asks you to create or import something explicitly.
```

## 13. 최종 응답 형식

작업을 마칠 때 다음을 보고한다.

```text
Commands executed:
Files changed:
Artifacts produced:
Validation performed:
Observed results:
Remaining risks:
Next recommended action:
```

artifact를 확인하지 않았으면 "완료"라고 말하지 않는다.

해결되지 않은 항목이 있으면 명시적으로 나열한다.

```text
Unresolved assumptions:
Open questions:
Needs Min approval:
```

## 14. 금지되는 나쁜 패턴

다음 패턴을 피한다.

- 요구가 모호한데도 바로 구현
- 과한 abstraction 생성
- 단일 script에 여러 책임을 섞기
- 대량 파일 변경 후 검증 생략
- 기존 코드 스타일 무시
- validation 없이 "done"이라고 말하기
- chat history에만 중요한 결정을 남기기
- symlink target을 확인하지 않고 destructive command 실행
- Min 승인 없이 long job 실행
- 연구 정의나 분석 범위를 조용히 선택

## 15. 좋은 작업의 기준

좋은 작업은 다음 조건을 만족한다.

- 목적이 명확하다.
- 변경 범위가 작다.
- 가정이 드러나 있다.
- 코드가 단순하다.
- 결과가 검증되었다.
- 산출물이 어디에 있는지 명확하다.
- 미래 세션이 이어받을 context가 파일에 남아 있다.
- Min이 승인해야 할 부분과 자동화 가능한 부분이 구분되어 있다.
