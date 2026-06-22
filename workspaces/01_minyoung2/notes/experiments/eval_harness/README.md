# Experiment: eval_harness (내부 평가 하네스, Tier 0)

**목적**: thesis(단일 ckpt × 이질 7-task Pareto) 판정 도구. 챌린지 검증 3회뿐 → 모든 recipe 결정을 *내부 subject-disjoint probe*로. frozen encoder feature → cls(AUROC)·reg(pearson)·seg(voxel 분리도 proxy) 동시 측정. 코드 `pretrain/eval_harness.py`.

## 🔴 핵심 발견 (run01, random-encoder baseline) — naive probe는 confound를 잰다
random(미학습) encoder인데:
| task | type | random 값 | 정상 기대 | 원인 |
|---|---|---|---|---|
| task4_trigeminal | seg | **0.989** | ~0.5 | **positional embedding shortcut**(삼차신경 위치 고정) |
| task2_meningioma | seg | **0.837** | ~0.5 | 위치 prior |
| task5_polymicro | cls | **0.953** | ~0.5 | **site/intensity confound**(n=48) |
| task1_infarct | cls | 0.279 | ~0.5 | n=21 noise |
| task3_brainage | reg | 0.209 | ~0 | n=60 noise |

**함의**:
1. **seg proxy는 위치 shortcut 지배** — "병변은 보통 여기"(해부 prior)지 병변 검출 아님. 진짜 encoder는 random(0.84~0.99)을 *넘어야* 의미.
2. **cls Task5 0.95(random)** = 라벨이 trivial 영상통계로 분리 = shortcut/site confound (→ fairness Task7 위험 직결).
3. 작은 n(task1·2·4 ≤40) = probe 고분산, 단일 측정 신뢰 불가.
→ **모든 내부 eval = "random-encoder baseline 대비 Δ"** (절대값 금지). `--baseline run01/eval_results.json`.

## Runs
| run | encoder | 용도 | 결과 |
|---|---|---|---|
| [run01_randombaseline](run01_randombaseline_2026-06-22/eval_results.json) | random-init ViT-S | **confound baseline**(모든 실측의 기준선) | seg 0.84/0.99·cls 0.95(Task5) = 위치/site shortcut 노출 |

## TODO (harness v2)
- multi-seed random baseline(분산 안정).
- seg: 위치 통제 강화(positional shortcut 분리) or 진짜 Dice(frozen head few-shot).
- 작은-n task: leaderboard-only or 신뢰구간 명시.
- W13: content-based near-dup(현재 ID 네임스페이스 불일치로 ID-match N/A, provenance 의존).
