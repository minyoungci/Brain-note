# minyoung2 — EXP01 감시 카드

> **목적:** nuisance shortcut 통제 후 T1w 표현이 transportable CDR 신호를 incremental하게 담는지 판정  ·  **출처:** workspaces/01_minyoung2 SCRATCHPAD·reports  ·  **갱신:** 2026-06-03

## 연구 주제

T1w MRI 표현이 site / label-provenance / tracer / timing / 뇌용적 같은 nuisance shortcut을 통제한 뒤에도 치매(CDR) 신호를 코호트 간 transport 가능하게 incremental하게 담는가를 판정한다. 1차 기여는 성능 SOTA가 아니라 **재사용 가능한 음성-결과-내성 평가 프로토콜**(7-cohort LOCO + control battery)이다.

## 가설 (H1)

subject-level + leave-cohort-out split에서 T1w 이미지 표현이 nuisance 배터리 baseline 대비 통계적으로 유의한 incremental AUROC를 보인다. (H0 = 증분 ≤ 0)

## 현재 상태

- 🟡 **thesis 재설정 국면.** 공식 H1(image > nuisance battery)은 ✅ 6/6 fold 충족했으나, baseline을 전뇌 용적 하나 → **5-ROI regional 위축**으로 강화하자 deep의 우위가 소멸(❌ F9). pooled에서만 +0.018 AUROC 유의(🟡 F10).
- 정직한 thesis는 **parsimony / cautionary**로 정리된다: "다코호트 transport CDR에서 transportable 신호의 본질은 regional 위축이며, deep 2.5D MIL은 그 위에 marginal(+0.018) 보완만 제공한다."
- 🟡 **strong-deep 3D CNN baseline(IMG-020/021/022) 실행 중 — 결과 미생성.** 반복 프로세스 종료(SIGHUP) 진단 후 setsid 분리 + RAM 90% 캡으로 재투입. 산출 디렉토리는 현재 비어 있다.
- 🆕 **EXP04 "N4 transport" 신규 라인(06-03 04:49 Gate0 셋업, 05:33 실행 중).** N4 bias 보정 이미지가 코호트 간 전이에 유리한지 `n4` vs `base`를 held-out cohort(NACC·OASIS, seed0)로 비교(encoder full finetune). 초기 진행: n4-NACC val AUROC ep1→5 0.75→0.80. `[VERIFY]` worktree(`.claude/worktrees/…chandrasekhar`) 산출이라 main 커밋 여부·n4>base 결론 미확정. official_manifest_full_n4 기반(minyoung3·minyoung4와 공유되는 N4 프로그램).

## 다음 게이트

1. 3D CNN(full-res) LOCO 6-fold 완주 → regional volume을 유의하게 이기는 fold가 하나라도 있는가 (Reviewer-2 [F2]).
2. equivalence test(TOST + 사전 마진 δ)로 "deep ≈ regional" 음성을 검정력 부족과 분리 ([F1]).
3. +0.018을 random-effects 메타분석 + cohort-cluster bootstrap으로 재검정 (exchangeability, [F3]).

## 한 줄 리스크

⚠️ deep이 단순 5-ROI 위축 로지스틱을 어떤 fold에서도 유의하게 이기지 못하면(현재까지 5/5 무승부), 핵심 framing "deep representation이 가치 있다"는 이 endpoint(CDR)+데이터에서 방어 불가 — 음성/방법론 논문으로 강등된다.
