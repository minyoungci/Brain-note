# DECISION_LOG — plant (microbrain)

> 모든 피벗·NO-GO·폐기·롤백을 여기에 누적한다. 되돌리기는 이 로그를 근거로 한다.
> 형식: `[날짜] 무엇을 · 왜 · 되돌아갈 commit(또는 tag)`. 최신이 위.

## 결정 기록

- [2026-06-11] 라인 시작 — plant를 longitudinal에서 **microbrain(bias-robust micro-level T1w 표현)**으로
  재정의. 옛 longitudinal 산출물 제거. · 되돌아갈 지점: commit `27b1665`(git init, longitudinal 상태).

- [2026-06-11] **P0 audit 실행 완료**(CPU + voxel smoke). 판정: **bias 실재(voxel→site 0.475, 3.3×chance) +
  N4 무효(−0.006) + disease 는 morphometry 수준에서 site 와 분리 가능(A4 잔차 0.722, drop −0.05) → decidable**.
  BRIEF §5 "bias 실재+분리가능" 경로 → P2 진입 근거 확보. 단 (b) 천장이 여전히 최우선 prior. ·
  산출: `results/P0/P0_AUDIT_REPORT.md` + notebooks/01~06 + figures. 되돌아갈 지점: 직전 commit.

- [2026-06-11] **주제 제안 확정(근거 기반)**: 5각도 수렴(P0·morph바·harmon scout·deep-research·혈액검증) →
  "T1w micro-표현이 **morphometry 약한 regime(MCI/amyloid)** 에서 transportable하게 더하는가" cross-site decidability 연구.
  AD/CN(천장 0.94)·harmonization·혈액바이오마커(+0.00 반증)·멀티모달 fusion(crowded)은 headline에서 제외. 문서=`docs/RESEARCH_PROPOSAL.md`.

## NO-GO / 폐기 ledger (요약 — 상세는 docs/ledgers/)

- [2026-06-11] **D5 혈액바이오마커+MRI 폐기** — novel(whitespace)이나 morph+age 대비 incremental 반증:
  dementia +0.005 · MCI-vs-CN +0.000 · amyloid +0.007. tested-negative control로만 잔존. 근거=`docs/novelty_deep_research.md`.
- (P0 audit 자체는 폐기 arm 없음.)
