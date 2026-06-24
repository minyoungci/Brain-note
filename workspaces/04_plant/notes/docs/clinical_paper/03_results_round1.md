# Round-1 결과 — incremental-value (2026-06-24)

> 사전등록: margin ΔR²<0.02, primary MMSE. subject-level GroupKFold, AJU n=858 complete-case(M0..M4).
> 코드: `experiments/incremental_value/{01_incremental_value,02_sensitivity_gbm}.py`.

## RQ1 — 인지 한계기여 (Ridge vs GBM)

| 증분 | Ridge ΔR² (MMSE) | GBM ΔR² (MMSE) | GBM ΔR² (CDR-SB) | 판정 |
|---|---|---|---|---|
| +T1 morph | +0.208 | +0.190 | +0.223 | 큼 (구조가 대부분 운반) |
| +FLAIR | +0.013 등가 | +0.009 등가 | +0.003 등가 | **robust 무시가능** |
| +blood(22)+APOE | −0.006 등가 | −0.001 등가 | −0.009 (경계) | **robust 무시가능** |
| **+amyloid-PET** | +0.014 등가 | **+0.034 NOT등가** | **+0.022 NOT등가** | **모델 의존 — 비선형서 기여** |

**핵심:** PET의 인지 기여는 **비선형**. 선형모델이 놓침. GBM(flexible)에서 margin 초과 → "PET 무시가능"은 **선형 artifact, 기각**.

## POS-CTRL (방법 민감도 — PASS)
- 혈관 dx: M1 AUROC 0.719 → +FLAIR **0.845 (+0.126)**. 파이프라인은 신호 있으면 크게 잡음 → RQ1 null(FLAIR/blood)은 진짜 무시가능이지 둔감 아님.

## RQ2 — amyloid triage (PET 제외)
- demo+APOE 0.735 → +T1morph 0.770 → +FLAIR+blood 0.761. APOE+구조가 0.77, PET 완전대체 불가.

## 종합 판정 (정직)
- **클린 parsimony 주제 기각.** dispensable한 모달리티(FLAIR·혈액)는 공짜/저가 → 임상 win 아님. 비싼 PET는 *기여함*(비선형) → "PET 생략" 펀치라인 거짓.
- robust 잔존: ① FLAIR·혈액 인지 무시가능(약함, 싸서) ② amyloid 인지기여의 비선형성(방법론 caution, niche) ③ FLAIR↔혈관 해리(보조).
- 어느 것도 단독 강한 임상 페이퍼 미달.

## 미해소 robustness (했어도 결론 안 바뀔 가능성 높으나 정직성 위해)
- margin sweep(0.01/0.015/0.02), 결측대체(M3 863 vs 858), KDRC 부분 외부확인 — 단 *클린 주제는 이미 PET로 기각*이라 우선순위 낮음.
