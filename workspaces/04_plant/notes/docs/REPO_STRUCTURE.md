# REPO STRUCTURE — microbrain (plant)

> 목적별 디렉토리 규약. **생성(src) ↔ 평가(experiments/tests) 분리**가 핵심 원칙
> (CLAUDE.md "생성과 검증은 분리된 단계"의 구조적 구현). 작성 2026-06-11.

```
plant/
├── RESEARCH_BRIEF.md          # 설계 단일 진실(SoT)
├── CLAUDE.md                  # 운영 규칙
├── SCRATCHPAD.md              # live 상태 / 핸드오프
├── docs/
│   ├── README.md              # ★ 문서 인덱스 — 여기부터 읽는다(읽는 순서·상태)
│   ├── RESEARCH_PROPOSAL.md   # ★ 현재 연구 방향 + 근거
│   ├── DECISION_LOG.md        # 피벗·NO-GO·롤백 (되돌리기 근거)
│   ├── REPO_STRUCTURE.md      # 이 파일 (디렉토리 규약)
│   ├── P0_bias_audit_plan.md  # 단계 설계서(승인 게이트). P1_*, P2_* 동일 위치(root)
│   ├── investigations/        # 탐색·근거 문서(참조용; 결론은 PROPOSAL/DECISION_LOG에)
│   │   ├── novelty_deep_research.md
│   │   ├── harmonization_scout_review.md
│   │   └── multisite_RL_strategy.md   # 부분 superseded
│   └── ledgers/               # 음성 결과 상세 ledger (실험별 NO-GO 기록)
├── src/microbrain/            # 재사용 라이브러리 (테스트됨, 실험이 import). ★코드는 P0 승인 후
│   ├── io.py                  #   텐서/마스크 로더 (minyoungi mri_io 재사용)
│   ├── manifest.py            #   canonical manifest 접근 + 컬럼 계약(contract)
│   ├── splits.py              #   LOCO / subject-disjoint / 누수 가드
│   ├── features.py            #   morphometry 정규화 · voxel intensity/texture
│   ├── probes.py              #   site/disease classifier (고정 하이퍼파라미터)
│   └── metrics.py             #   bAcc · AUROC · bootstrap CI · base-rate baseline
├── experiments/              # 실험별 얇은 스크립트 (src를 호출, 1실험=1질문)
│   └── P0_audit/             #   A0~A5 (docs/P0_bias_audit_plan.md 와 1:1)
│       ├── A0_confound/      #     site×diagnosis confound
│       ├── A1_morph_site/    #     morphometry → site 예측강도
│       ├── A2_voxel_site/    #     voxel → site 예측강도 + N4 vs base
│       ├── A3_bias_atlas/    #     누수 region 지도
│       ├── A4_decidability/  #     site 제거가 disease를 지우나 (★핵심)
│       └── A5_morph_cdr_bar/ #     morphometry → CDR LOCO 바
├── tests/                    # 단위테스트: split disjointness · 입력누수 · label timestamp
├── results/                  # 실험 산출물. 작은 report(.md/.csv)만 commit, 무거운 건 .gitignore
│   └── P0/
└── data/derived/            # 파생 feature(.parquet) — gitignore (manifest에서 재생성 가능)
    └── P0/
```

## 규약

1. **src = 생성, experiments = 사용.** 실험 스크립트는 로직을 담지 않고 `src/microbrain`을 호출만 한다. 같은 로더·split·metric을 모든 실험이 공유 → 누수 경로가 한 곳에 모여 audit 가능.
2. **1 실험 = 1 falsifiable 질문 = 1 디렉토리.** 각 실험 디렉토리는 `run.py`(또는 `.sh`) + `REPORT.md`(숫자 결과 + 사전등록 판정) + 산출 CSV를 담는다. REPORT.md는 commit, 무거운 산출물은 ignore.
3. **평가 분리.** `tests/`의 split/누수 단위테스트가 통과해야 실험 결과를 "유효"로 친다 (자기평가 금지).
4. **음성 결과 보존.** NO-GO는 `docs/ledgers/`에 `[날짜·실험·왜·되돌아갈 commit]`으로 기록. DECISION_LOG.md에 한 줄 요약.
5. **데이터 read-only.** `/home/vlm/data` 쓰기 금지. 파생물은 `data/derived/`·`results/`만.
6. **승인 게이트.** `src/`·`experiments/`의 **코드 작성·실행은 해당 단계 설계서(docs/<phase>_plan.md) 승인 후.** 현재 P0 승인 대기 → 위 디렉토리는 *빈 스캐폴드*다.
