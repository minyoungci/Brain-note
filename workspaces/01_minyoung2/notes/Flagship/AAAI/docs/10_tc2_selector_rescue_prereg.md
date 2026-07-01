# docs/10 — TC2 Selector Rescue: pre-registration (LOCKED before FastSurfer data)

**작성 2026-07-01, research-critic 판정 직후. 데이터 보기 전 잠금.**
목적: Phase 1(5점, brain-age)에서 label-free selector가 **NO-GO**로 판정됐다(argmax 실패 + 최적=grid 중점이라
trivial "중점 찍기"에 짐 + regret 0.019는 노이즈). 이 문서는 positive selector를 **정당하게** 되살릴 수 있는
유일한 조건 — critic이 지목한 off-center 2번째 task — 을 **결과 보기 전에** 사전등록한다. 이 조건을 통과하지
못하면 TC2는 honest negative(cautionary finding + open problem, `draft/04_2`)로 확정한다.

## 왜 이 실험인가 (critic F1 직접 대응)
- brain-age transfer 최적점 = wg0.5 = **grid 정확한 중점** → "중점 찍기" default regret 0. selector가 이길 여지 없음.
- 내부 3점 {0.774,0.792,0.768} 통계적 tie → 이 task는 정점 *위치*를 결정할 정보량 자체가 없음.
- ⇒ selector가 가치를 증명하려면 **최적점이 grid 중점이 아닌(off-center) task**가 필요. dense/seg task는
  w_dense를 선호할 것이므로 최적 w_global이 **왼쪽(예: 0 또는 0.25)**으로 치우칠 것으로 예측(H-A). 이러면
  "중점 찍기"가 실패하고, 라벨-프리 기준이 그 off-center 정점을 짚으면 비로소 non-trivial selector 증거가 된다.

## 사전등록 가설 (LOCKED)
- **H-A (off-center)**: FastSurfer-ROI dense task의 frozen-probe transfer(Δ-over-random)는 w_global에 대해
  **비단조이며 최적점이 grid 중점(0.5)이 아니다**. 예측 방향: 최적 wg ≤ 0.25. (falsify: 최적이 0.5이거나 단조)
- **H-B (selector)**: 사전등록 라벨-프리 기준을 **held-out UNLABELED** feature에서 계산했을 때, 그 기준이 지목하는
  per-task ŵ의 **leave-one-task-out(LOTO) mean regret**이 두 trivial baseline(① grid-midpoint default, ② rank-max)
  **모두보다 낮고, paired-bootstrap 95% CI가 두 baseline을 배제**한다.

## 사전등록 기준·절차 (LOCKED — 결과 보고 바꾸지 않음)
- **task 집합(최소 2, off-center 1 필수)**: {brain-age(center, 기존), FastSurfer-ROI dense(off-center 후보)}.
  가능하면 3번째(다른 modality/endpoint) 추가로 LOTO 신뢰도↑.
- **후보 기준 C (사전등록)**: primary=α-ReQ(spectral exponent, `m_alpha_req`). 보조=EVR-top10, cluster-silhouette.
  ※ uniformity는 Phase 1서 사후발견이라 **여기 등록해 별도 검증**(등록 없이 headline 금지).
- **지표 계산 위치**: transfer를 측정한 eval cohort가 **아닌** held-out **unlabeled** pool(사전학습 코퍼스 subset
  또는 제3의 외부 unlabeled)에서 C를 계산. (Phase 1 confound M1 차단 — 배포 selector 정의.)
- **selection 절차**: 각 task를 hold out → 나머지 task에서 C로 ŵ 선택 → held-out task에서 regret(=opt − ŵ transfer)
  측정 → 평균. paired bootstrap(subject/​task 재표집)으로 CI.
- **baseline(반드시 격파)**: ① grid-midpoint(항상 0.5) ② rank-max(RankMe argmax) ③ random-wg. **모든 후보·baseline의
  regret+CI를 표로 전량 보고**(min만 보고 금지, Holm 보정).
- **dense task 측정 규약**: FastSurfer mask=pseudo-label → "seg 성능" 주장 금지, **representation-probe/selection**로만.
  Dice는 위치 shortcut에 포화(random encoder 0.84~0.99) → transfer = **Δ-Dice-over-random**(또는 위치-비포화 probe).
  subject-disjoint + FOMO300K leakage 대조(§external_eval 절차) 선행.

## 판정 (GO/NO-GO, LOCKED)
- **GO (positive selector 재주장 가능)** ⇔ (a) H-A 성립(off-center task ≥1, 중점-triviality 깨짐) **그리고**
  (b) H-B 성립(등록 기준의 LOTO regret CI가 midpoint·rank-max baseline 아래) **그리고** (c) sanity(per-task transfer
  재현) 통과. 이때만 draft를 "label-free selector" positive로 승격.
- **NO-GO(기본값)** ⇔ 위 중 하나라도 실패 → `draft/04_2`의 honest negative(cautionary + open problem) 확정.
  α-ReQ/uniformity를 selector로 headline하지 않음.

## 선결 조건 (사용자 진행)
1. Phase 1 완료(✅ 2026-07-01) → 사용자 FastSurfer 실행 예정.
2. FastSurfer-ROI mask(QC-pass) → FOMO Yucca4 정합(1mm-iso/RAS/[0,1]) + leakage 대조.
3. dense-probe harness(frozen, 5 ckpt, Δ-over-random) 배선 — eval_harness 확장.
4. held-out unlabeled pool 확보(코퍼스 subset).

## 정직성 경계 (재확인)
- 이 문서의 목적은 positive를 *만드는* 게 아니라 positive가 정당한지 *결과 전에 판별 규칙을 고정*하는 것.
- Phase 1 NO-GO는 이미 확정 사실 — 숨기지 않고 본문에 보고(F3). 구원 실패 시 negative가 최종.
- 모든 threshold는 이 커밋 시점에 LOCKED. 결과 본 뒤 기준 변경 = HARKing으로 자기신고.
