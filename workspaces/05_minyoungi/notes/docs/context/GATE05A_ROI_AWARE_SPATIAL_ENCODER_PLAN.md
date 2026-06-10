# Gate05a ROI-aware spatial encoder upper-bound plan

Created: 2026-05-27 KST

## 결론 배경

현재 결론은 `mixed bottleneck`이다.

- ROI-derived privileged signal은 KDRC에서도 강하다.
  - Gate04d seed 42 기준 Teacher-S / true ROI teacher AUC는 약 0.88 수준이다.
  - 따라서 "ROI 정보 자체가 약하다"는 해석은 폐기한다.
- 그러나 T1w-only student는 이 signal을 충분히 보존하지 못한다.
  - predicted ROI head probe와 global pooled embedding probe가 모두 약 0.82--0.83 수준에 머문다.
- 따라서 실패는 `global pooling only`가 아니라 다음 두 층위가 함께 약한 mixed failure로 본다.
  1. ROI target transfer / class-relevant ROI reconstruction 부족
  2. reusable embedding transfer 부족
- AD에서 predicted-vs-true ROI alignment가 CN보다 약한 징후가 있다.
  - 단, 현재 row-level 근거는 seed 42 단일 결과이므로 provisional evidence다.

## Novelty claim wording

Use this conservative wording:

> Medical KD, ROI-grounded learning, and LOCO evaluation each exist separately. Our contribution is to study their intersection: distilling ROI-derived privileged anatomical signal into a T1w-only reusable image representation, diagnosing where that transfer fails across cohorts, and testing whether ROI-aware spatial encoding can close the gap.

## Gate05a의 성격

Gate05a는 논문 최종 모델이 아니다. 구조적 병목 진단 실험이다.

- Gate05a: ROI-mask-assisted spatial encoder upper-bound diagnostic
  - inference 때도 ROI mask를 입력한다.
  - 질문: 명시적 ROI spatial feature extraction을 주면 teacher-student gap이 줄어드는가?
  - 성공해도 이것은 T1w-only deployable model이 아니다.
- Gate05b: mask-free T1w-only ROI-supervised student
  - inference 때 T1w image only.
  - training 때만 ROI teacher/supervision 사용.
  - 최종 VLM-ready deployable representation 방향은 Gate05b에서 판단한다.

## Gate05a 핵심 질문

T1w image feature map에서 FastSurfer-derived ROI masks를 이용해 regional feature를 명시적으로 추출하면, KDRC 및 LOCO 환경에서 다음 gap이 줄어드는가?

- Teacher-S AUC - predicted ROI probe AUC
- Teacher-S AUC - frozen embedding probe AUC
- AD predicted-vs-true ROI cosine/MSE fragility

## Minimal factorial variants

처음부터 attention/contrastive/class-aware loss를 모두 넣지 않는다. 해석 가능성을 위해 4개 variant로 제한한다.

- `m0_global_same_loss`
  - Gate04-style global pooled baseline.
  - Loss: Teacher-S KL + 0.1 CE.
- `m1_roi_pool_same_loss`
  - ROI-aware pooling + same loss.
  - 구조 변경 효과: M1 vs M0.
- `m2_roi_pool_cosine`
  - ROI-aware pooling + same loss + ROI cosine alignment.
  - 단순 ROI 정렬 효과: M2 vs M1.
- `m3_roi_token_cosine`
  - ROI token aggregator + same loss + ROI cosine alignment.
  - ROI token 구조 효과: M3 vs M2/M1.

## Primary endpoints

- Direct head AUC / balanced accuracy
- Frozen embedding probe AUC / balanced accuracy
- Predicted ROI probe AUC / balanced accuracy
- Teacher-student AUC gap
- ROI prediction MSE
- predicted-vs-true ROI cosine mean/median
- CN/AD class-wise ROI cosine and MSE
- Fold-wise delta vs baseline06

## Conservative pass criteria

Do not pass Gate05a from a single seed.

Suggested KDRC criteria:

- KDRC frozen AUC >= baseline06 KDRC AUC 0.8395 in at least 2/3 seeds.
- KDRC seed mean frozen AUC >= 0.845.
- Predicted ROI probe AUC gap to Teacher-S decreases relative to Gate04d.
- AD ROI cosine increases and AD ROI MSE decreases consistently across seeds without CN degradation.

Suggested LOCO criteria:

- Mean LOCO frozen AUC >= 0.82.
- No catastrophic fold regression: no fold should drop >0.02 below its baseline06 unless explicitly explained.

## Important caveats

- ROI masks as model input mean Gate05a is not T1w-only deployable.
- If Gate05a does not improve predicted ROI probe or frozen embedding, spatial masks alone are insufficient and loss/teacher target design must be revisited.
- If Gate05a improves predicted ROI probe but not frozen embedding, the bottleneck remains reusable representation transfer.
- If AD cosine remains poor despite ROI-aware pooling, disease-specific alignment or contrastive objective becomes a justified next ablation, not an assumption.
