# 데이터 무결성 — leakage / overfitting (비타협)

> AD 연구 실패의 핵심 교훈([[01_prior_research]] D). 모든 실험에 *내장*. 규칙 함의는 [[00_challenge_rules]].

## Leakage 차단
| 원천 | 방어 |
|---|---|
| **#1 pretrain↔downstream subject 중복** | FOMO300K(공개셋: OASIS/ADNI/IXI…) ∩ downstream test = ∅ 를 subject-ID/hash로 **코드 강제 검증**. 겹치면 pretrain서 제외. (downstream은 임상 덴마크/인도라 대개 disjoint이나 *반드시 확인*.) |
| split 누수 | pretrain-val / finetune train·val·test 전부 **subject-disjoint** (같은 subject 다른 session도 분리). |
| normalization 누수 | per-volume z-norm(무누수). SSL의 **BatchNorm은 batch 정보 누수·collapse shortcut → InstanceNorm/GroupNorm**(소배치 3D에도 유리). |
| confound 누수 | scanner/demographic은 *train-time 억제(invariance)*에만, **inference feature로 안 씀**. |
| probe 누수 (Task6,7) | frozen feature → finetune 누수 없음. 단 probe train/test도 subject-disjoint. |

## Overfitting 방어
1. **few-shot finetune(21~200)이 최대 위험** → ① frozen/linear-probe 우선(Task6,7 구조적 안전) ② finetune은 light + **subject-disjoint val early-stop** + strong aug.
2. **작은 모델**(FOMO25 findings) → 과적합↓. "디테일"은 *objective(voxel-wise dense)*에서, *모델 크기 아님*.
3. **3+ 시드 + CI** (few-shot OOD 고분산 — AD에서 단일숫자에 속았던 교훈). 리더보드 1등 ≠ 통계 1등.
4. **validation 3회 제한**(규칙) → 리더보드 튜닝 불가 → **모든 선택을 내부 subject-disjoint val로**, 리더보드는 최종 확인.
5. **모니터 가동**: `pretrain/monitor.py`가 학습 *중* collapse/목적충돌/dense퇴화/probe추세 STOP·WARN 자동판정 → 조기 중단.

## "더 디테일" 원칙 (voxel-wise + group attention)
- voxel-wise dense는 *seg(50% 가중)에 직접 기여* — 단 **objective에서 디테일**, 무거운 attention/큰 모델은 overfit·역효과.
- group attention은 가볍게(SimPool/slot) — 무거운 3D attention 남발 금지.

## baseline-first (AD 함정)
- novel method(balancing/cross-seq/fairness)가 *같은 split*에서 baseline(3DINO additive / S3D / well-tuned λ)을 못 넘으면 **정직 보고**(negative=자산). test-peeking 금지, test 1회만.
