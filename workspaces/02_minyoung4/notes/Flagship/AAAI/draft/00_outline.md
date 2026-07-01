# AAAI Manuscript — Draft Outline & Section Status

작성 원칙: **fixed(audit-검증)된 내용만** 작성. 외부 데이터 의존부는 `[EXTERNAL-PENDING]`, 미확인 사실은 `[VERIFY]`.
draft는 md로 먼저(AuthorKit27 .tex는 별도 port). 수치는 `results/table_c2_objective_balance.csv` 등 source에서만.

| § | 섹션 | 근거 | 작성 가능? |
|---|---|---|---|
| Abstract | — | TC3 결과가 headline 결정 | ⛔ **branch-point(TC3 후)** |
| 1 | Introduction | 문제 framing(고정) + 기여 TC1-3 | 🟡 골격 가능(결론 수치는 비움) |
| 2 | Related Work | SparK/ConvMAE/SimMIM, 3D med SSL, brain-age, shortcut/confound | ✅ 지금 |
| 3 | Method | model(SparK backbone) + TC1/TC2/TC3 *방법 정의* | ✅ 지금 |
| 4.1 | Exp setup | 코퍼스·전처리·probe·Δ-over-random | ✅ 지금(외부 setup은 pending) |
| 4.2 | **TC2 results** (HEADLINE, 검증중: rank↔transfer decoupling + label-free selection criterion C) | inverted-U + rank decoupling (내부, SOLID); C·regret = Phase 0/외부 pending | 🟡 finding 지금 / selector pending |
| 4.3 | **TC1 results** (protocol-adaptive) | frozen matched +0.134 + diagnostic +0.101 | ✅ **지금** |
| 4.4 | TC3 results (external) | 외부 brain-age/dx, shortcut audit, morphometry | ⛔ `[EXTERNAL-PENDING]` |
| 5 | Limitations | 내부 n, single-seed, shortcut, SparK | 🟡 골격 가능 |
| 6 | Conclusion | — | ⛔ branch-point(TC3 후) |

진행 로그:
- 2026-06-29: outline + §3 Method + §4.2 TC2 초안.
