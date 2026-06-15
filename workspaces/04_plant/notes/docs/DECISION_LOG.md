# DECISION_LOG — plant (microbrain)

> 모든 피벗·NO-GO·폐기·롤백을 여기에 누적한다. 되돌리기는 이 로그를 근거로 한다.
> 형식: `[날짜] 무엇을 · 왜 · 되돌아갈 commit(또는 tag)`. 최신이 위.

## 결정 기록

- [2026-06-15] **C4 PASS — BN-adapt 회복은 공정·inductive·배포가능.** 3-seed×5-fold 동일 eval subset 3-way BN:
  raw 0.850 / transductive 0.909 / **inductive(K64) 0.912** → recovery_ratio (ind−raw)/(trans−raw)=**1.05**(전 K).
  target-site **unlabeled 64장**으로 BN 재계산→freeze→per-subject가 +0.06 회복 전부 재현(K64 포화).
  → **transductive 공정성 confound 제거**: image(BN-adapt) 0.91 vs morph 0.931은 이제 양쪽 inductive=공정 비교,
  잔여 −0.02 유지. 회복은 site-shift 큰 fold(ADNI .75→.92, NACC .78→.90)에 집중. 단 공정성만 해결 — 잔여=천장
  판정은 **C3**(잔여의 morph 환원불가 + 회복↔site-decode 인과) 필요. 근거=`results/P2/adcn_inductive_bn_adcn_2mm.{csv,json}`,
  설계=`docs/P2_plan.md §6b`. 되돌아갈 지점: commit `af0ecdb`.

- [2026-06-15] **P2 Tier-2 방법론 4-arm 확정 + 해상도 축 종료(NO-GO).** LOCO 5-cohort×2-seed, image-only,
  morph bar 0.931. 결과: none 0.844 / grl 0.817(**적대 디바이싱 악화**, NACC .82→.70) / **none_tta(BN-adapt) 0.910**.
  해상도-매칭 검정(2mm→1.5mm, voxel 2.37×): none_tta Δ=**0.000**(0.910→0.910), none Δ=+0.005 → **잔여 −0.021은
  해상도 핸디캡 아님 = 천장 성분**. 사전 등록 NO-GO(≤0.910) 트리거 → **1mm 캐시 빌드 안 함.** 단 none_tta는
  transductive(C4 confound)라 0.910은 낙관적 상한. 다음=천장 확정용 C2(multi-seed dissociation)·C3(site-decode 인과)·
  C4(inductive 변형). 근거=`docs/ledgers/2026-06-15_adcn_resolution_ceiling_negative.md`,
  novelty 실측=memory `p2-novelty-positioning`(Bron 2021이 최대 위협 — C1 단순비교는 점유됨, C3 분해만 공백).
  되돌아갈 지점: commit `51944b3`(1.5mm 실행 직전 체크포인트).

- [2026-06-11] 라인 시작 — plant를 longitudinal에서 **microbrain(bias-robust micro-level T1w 표현)**으로
  재정의. 옛 longitudinal 산출물 제거. · 되돌아갈 지점: commit `27b1665`(git init, longitudinal 상태).

- [2026-06-11] **P0 audit 실행 완료**(CPU + voxel smoke). 판정: **bias 실재(voxel→site 0.475, 3.3×chance) +
  N4 무효(−0.006) + disease 는 morphometry 수준에서 site 와 분리 가능(A4 잔차 0.722, drop −0.05) → decidable**.
  BRIEF §5 "bias 실재+분리가능" 경로 → P2 진입 근거 확보. 단 (b) 천장이 여전히 최우선 prior. ·
  산출: `results/P0/P0_AUDIT_REPORT.md` + notebooks/01~06 + figures. 되돌아갈 지점: 직전 commit.

- [2026-06-11] **주제 제안 확정(근거 기반)**: 5각도 수렴(P0·morph바·harmon scout·deep-research·혈액검증) →
  "T1w micro-표현이 **morphometry 약한 regime(MCI/amyloid)** 에서 transportable하게 더하는가" cross-site decidability 연구.
  AD/CN(천장 0.94)·harmonization·혈액바이오마커(+0.00 반증)·멀티모달 fusion(crowded)은 headline에서 제외. 문서=`docs/RESEARCH_PROPOSAL.md`.

- [2026-06-11] **insight/ 폴더 신설(표준 규칙):** 실패·실패지점·교훈을 항상 `insight/`에 누적
  (methodological_traps·empirical_findings). 추후 인사이트·연구 활용. + P2 target을 **AD/CN**(morph 강 0.936)으로
  확정, **컨소시엄 bias 처리를 층상 방어(L1~L6)로 통합**(erase 아닌 측정·통제·전이). 설계=`docs/P2_plan.md`.

- [2026-06-11] **(b) 천장 주장 철회 — research-critic 적대 검증.** P2-③의 "image≈morph fair-test"가
  F1(인코더 random-split = 표현수준 LOCO 누수)·F2(morph-distilled emb 순환 + amyloid 약한 target)·F3(1.5mm
  mean R²=0.23·precuneus 음수 = "cortical 복원" 과대진술)으로 무효. **(a)/(b) 미결로 되돌림.** FINDINGS §0.1 정정.
  되돌아갈 지점: commit `2ff018d`(철회 전 상태). · 다음(필수): nested-LOCO + AD/CN target 검정.

## NO-GO / 폐기 ledger (요약 — 상세는 docs/ledgers/)

- [2026-06-11] **D5 혈액바이오마커+MRI 폐기** — novel(whitespace)이나 morph+age 대비 incremental 반증:
  dementia +0.005 · MCI-vs-CN +0.000 · amyloid +0.007. tested-negative control로만 잔존. 근거=`docs/novelty_deep_research.md`.
- [2026-06-15] **AD/CN 이미지 해상도 추격 NO-GO** — 잔여 −0.021(none_tta 0.910 vs morph 0.931)이 해상도 불변
  (2mm→1.5mm Δ0.000) → 1mm 빌드 폐기. + **grl(consortium-adversarial) 폐기**(0.817, raw보다 악화). 근거=`docs/ledgers/2026-06-15_adcn_resolution_ceiling_negative.md`.
- (P0 audit 자체는 폐기 arm 없음.)
