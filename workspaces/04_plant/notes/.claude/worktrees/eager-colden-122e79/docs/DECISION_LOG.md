# DECISION_LOG — plant (microbrain)

> 모든 피벗·NO-GO·폐기·롤백을 여기에 누적한다. 되돌리기는 이 로그를 근거로 한다.
> 형식: `[날짜] 무엇을 · 왜 · 되돌아갈 commit(또는 tag)`. 최신이 위.

## 결정 기록

- [2026-06-17] **P4 라인 폐기 — 코드·산출물 삭제.** 사용자 결정. P4(서양 vs Korean cross-pop AD 전이)는
  실증·robustness가 닫혔으나 **체급 부족으로 폐기**: ① 방법 아닌 경고성 negative 결과(Bron2021 영역 중첩,
  [[p2-novelty-positioning]]) ② 최강 펀치라인(비가역 population)을 strong-backbone에 스스로 철회(2026-06-16 기록) ③
  within deep≈morph로 전제 약함 ④ "population effect" 해석이 MMSE/중증도/라벨정의 confound에 노출(4코호트로 미해소).
  삭제: `experiments/P4/`(11 .py, git 복구가능) + `data/derived/P4/`(4.4GB, gitignore=영구). **보존:** `docs/P4_*.md`·
  `insight/`·`SCRATCHPAD.md`. 되돌아갈 지점: commit `5eae3c1`(P4 코드·문서 온전).
  필요실험 완수(per-cohort·M2공정성·M4 split·독립 코드감사·강backbone) + 코드리뷰·산출물비교. 핵심 정정:
  from-scratch deep은 cross 양방향 deep<morph(유의)이나, **brain-age 사전학습이 W→K를 morph *동등*까지 회복
  (Δ−0.002, CI[−0.036,+0.032]) · K→W는 비회복(Δ−0.053 유의) · within-Korean은 morph 초과(Δ+0.075)**.
  → "test-time(BN) 비가역이나 전이가능 사전학습으론 *비대칭* 부분회복; Korean→Western 가장 취약." (이전 "비가역
  population" 단정 철회 — 점추정→CI/추가실험으로 정정한 정직 사례.) 부수 수정: M2(morph train-only 공정성),
  M1(aggregate_transfer 삭제). 결과=`docs/P4_results.md`(§0/§4c-e/§5/§7/§8). 되돌아갈 지점: commit `e932647`.

- [2026-06-16] **P4 실증 완료 — 헤드라인 통계 확정.** 서양(ADNI+OASIS) vs Korean(AJU+KDRC) CN-vs-impaired,
  matched(age·sex·CDR-stage, 2286 subj). deep(CNN·ResNet 5-seed) vs morph transfer 매트릭스. **cross-pop full-target
  (n=1143)** 평가로 power 확보: **cross 양방향 deep<morph 유의**(W→K Δ−0.106[−0.143,−0.068]·K→W −0.062[−0.101,−0.022]),
  within 유의차 없음. **BN-adapt 0% 회복 → 결손=population-level(비가역)**, scanner shift(C4 +0.06 회복)와 대조.
  Stage-1: MMSE 인구-비등가. 인프라 교훈: DataLoader/mmap thrash→GPU상주(insight T12), val⊂train 누수버그 수정.
  결과=`docs/P4_results.md`, 코드=`experiments/P4/`. 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **전략 피벗 Path A→B + P4 설계.** 사용자 결정: venue 임팩트 우선(Path B). field는 site-LOCO/morph-bar를
  gating 안 함(ADLIP이 그 없이 Alz&Dem 게재) → 우리 rigor는 진실용이지 보상용 아님. **P3(Path A decidability) 대체.**
  새 주제 = **서양(ADNI+OASIS) vs Korean(AJU+KDRC) cross-population AD 모델 비교**(ADLIP式 vision-language fusion).
  task=CN-vs-impaired 이진(AD 128/그룹 얇음 회피). 매칭 CN 307/impaired 920/그룹(age·sex). hook=cross-pop 매칭+
  transfer gap의 acquisition/population **분해**(P3 도구 흡수=해석가능성 엔진)+East-Asian(ADLIP 미보유). amyloid는
  비대칭(서양 22%)이라 Korean 내부 보조만. AIBL(APOE0)·NACC(MMSE16%) 제외. ★리스크: site×dx confound 내장(AJU CN27)
  → 분해 없으면 "서양≠Korean" 해석불가(NO-GO 1). 설계=`docs/P4_crosspop_adlip_plan.md`. 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **P3 개정 — research-critic 조건부 GO(범위 절반 축소).** 적대검증 치명결함 3: F1(scanner/population
  분리는 traveling-subject=0이라 원리적 불가) · F2(Q2 amyloid specificity null은 SNAP/amyloid-independent atrophy
  문헌이 이미 출판=새 과학 아님) · F3(AJU↔KDRC "R1 청정" 거짓: 측정법+base-rate 1.77× confound). + M2(C3 미완주를
  엔진 전제). → **개정:** Q2 헤드라인 강등(within-cohort 보조만), Q1을 "gap decidability 지도(어느 성분이 decidable/
  원리적 undecidable)"로 재정의, C3를 Stage-0 GATE로 격상, F1은 within-NACC 독립 2차추정(|Δ|<0.02)으로 검증/강등.
  scout·advisor·critic·memory 전부 동일 결론(decidability/negative-result framing이 유일 생존로). 개정=`docs/P3_signal_decomposition_plan.md`.

- [2026-06-16] **P3 주제 설정 — 구조 MRI 신호 다기관 분해 + AD-특이성 벤치마크.** 성능 논문 포기(R1+R2
  구조적). literature-scout/research-advisor 독립 수렴 + 자산 재인벤토리(parquet 직접)로 확정. 두 질문:
  Q1(gap을 scanner-회복/population-비가역/morph-천장으로 분해, 엔진=C3) + Q2(transport 신호가 AD-특이인가
  — impaired 내 amyloid+/− specificity, **AJU↔KDRC=Korean 청정 testbed**). ★신규 자산: amyloid 라벨 5코호트
  3,774 subj, impaired 대비는 Korean 집중(서구 문헌 공백). null도 1차 결과. 체급=NeuroImage:Clinical급.
  설계=`docs/P3_signal_decomposition_plan.md`, 근거=`insight/failure_root_causes.md`(4-사인). 되돌아갈 지점: commit `6300402`.

- [2026-06-16] **자산 정정(parquet 직접):** datadict stale 확인(127 vs 141컬럼, clin_apoe ADNI 0%→실제 94%).
  ROI=morphometry(roi_final_ready=False는 target sign-off만 미완, baseline 사용가능). PET 원본영상=KDRC만 903.
  scanner-model fine-grained 존재(ADNI 16종) — BRIEF "scanner 데이터 없음" 전제 부정확. memory `manifest-only-source-of-truth`.

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
