# 전략 · 트랙 · 일정

> 규칙은 [[00_challenge_rules]], 모델은 [[02_architecture_method]], 무결성은 [[03_data_integrity]].

## 트랙 전략
- **Methods 트랙 (주력)**: FOMO300K only. ① balancing(공저 게이트의 "의미있는 수정") + ③ fairness(Task6,7, first-author). 단일 백본이 7 task.
- **Open 트랙 (최소)**: 한국 임상데이터 추가 = *단일 ablation만*, 기본 포기(306K의 0.6% → 자원분산). 져도 "소규모 외부데이터 무효" negative로 공저 기여.

## 논문 전략 (규칙 기반)
- **공저(안전판, 반드시)**: 7 task에 *비-trivial* 제출(unmodified baseline=trivial 제외) → top저널(MedIA/TMI/Nat Methods/npj) 공저초청(≤5인).
- **first-author(도전)**: ① balancing / ③ fairness(미점유) 정조준. dense ablation(iBOT vs MAE)도 기여.
- **둘 다 노리되**: 공저는 반드시, first-author는 ①③ 한정.

## 가드레일 (AD 함정)
1. 백본 리스크 = ViT 채택으로 완화(3DINO 검증). 단 Phase A서 수렴·probe·**추론시간(120초)** 확인.
2. baseline 먼저: 3DINO/S3D/well-tuned-λ 같은 split 재현 → 못 넘으면 정직 보고.
3. 3+ 시드 + CI. 4. falsifiable(①②③ 전부 ablation, 안 되면 negative=자산). 5. 큰 모델 금지(8×B200=병렬 iteration).

## de-risking 워크플로우 (재학습 리스크 제거)
- **Phase A (소규모)**: 작은 백본 + 5~10K subset + 짧은 학습 → ① balancing A~D, iBOT-vs-MAE, ② cross-seq on/off, ③ inv on/off 를 OpenMind proxy(seg+cls held-out)로 비교 + **ViT-DINO 작동·추론시간 검증** → 이긴 recipe 1개. *설계 틀림 다 걸러짐.*
- **Phase B (1회, 8×B200)**: 검증된 recipe만 full subset·full epoch 스케일업.
- 조기경보: `monitor.py` 학습 *중* STOP/WARN. warm-restart로 재학습 회피.

## 9주 일정 (8/21 마감, ~9주)
| 주차 | 작업 |
|---|---|
| 1 | **인프라 올인** — 등록 → 7 task 제출 파이프라인 통과. **seg 2·4(sliding-window/NSD) 최우선**(50% 가중). 120초 추론 검증. |
| 2-3 | baseline(3DINO additive / S3D / well-tuned λ) 재현(OpenMind 프로토콜) + **Phase A ablation**. |
| 3-6 | **Phase B** balancing + cross-seq + fairness(Task6,7), 3시드+CI. |
| 4-7 | 7 task 비-trivial 제출(공저 확보). |
| 7-9 | ablation·polish·최종제출·논문. (시간되면 Open 단일 ablation) |

## 즉시 게이트 (데이터 오면)
1. **FOMO26 등록**(당신) → downstream 7 task 데이터. (이게 1순위 전제, [[00_challenge_rules]] 일정 6/15 파이프라인 열림.)
2. Phase A pilot 착수. 현재 status는 [[SCRATCHPAD]].
