# Experiment: conflict_pilot

**가설(thesis GATE)**: brain MRI 3D SSL에서 dense(→seg)·global(→cls) 목적의 gradient가 실제로 충돌(`cos(∇L_dense,∇L_global)<0`)하는가? — Conflict-Aware Pretraining([[../../docs/03_architecture_method]] §1)의 falsifiable 선결 실험. 충돌 실재→진행+동기 figure / 충돌 없음→pivot(seg-decoder transfer or heterogeneity).

**방법**: 단일 student forward(SimMIM dense + DINO-lite global)로 공유 encoder의 cos를 학습 전구간 측정. 코드 `pretrain/conflict_pilot.py`, 도구 `pretrain/monitor.py`(grad_conflict). pure-torch·bf16·B200.

## Runs
| run | 측정 | 결과 | 판정 |
|---|---|---|---|
| [run01_aggregate](run01_aggregate_2026-06-22/summary.md) | aggregate cos (전 param 합산) | mean +0.017·cos<0 43%·near-orthogonal | 조건부 PASS — aggregate는 진짜검증 아님 |
| [run02_perlayer](run02_perlayer_2026-06-22/summary.md) | per-layer cos + mag (3k step) | cosine 전 layer 평평 / magnitude 깊이-구조적 | cosine 기각(초기), magnitude 살아있음 |
| [run03_perlayer_long](run03_perlayer_long_2026-06-22/summary.md) | **장기 30k step (창발 검증)** | **후반에도 평평(cos<0 52%→42%, 상승 없음) / magnitude 깊이불균형 심화(global 깊은층 15~20× 우세)** | **cosine 결정적 기각 / magnitude robust** |

## 현재 결론 (2026-06-22, run03 후)
- 🔴 **cosine 충돌 가설 결정적 기각**: 3k(run02)·30k(run03) 두 regime 평평 + 창발 궤적 부재(후반 오히려 더 정렬). cosine(PCGrad)식 충돌은 thesis 근거 불가.
- 🟢 **magnitude 불균형 robust·심화**: |∇dense|/|∇global| 입력 ~0.8 → 깊은층 0.05~0.07(global 15~20× 우세). dense=얕은층·global=깊은층.
- ⚠️ 잔여 캐비엇: ViT-S·DINO-lite(ViT-L 대규모 아님) — 단 평평 궤적상 규모만으로 cosine 창발은 저확률.
- **남은 fork**: (B) magnitude-불균형 메커니즘 pivot / (C) seg-decoder transfer pivot. (A 종료.)

## 산출물 규약
- `runN_*/config.json` (하이퍼·commit), `summary.md`(결과·해석), `cos_series.csv`(compact, 커밋).
- `metrics.jsonl`·`run.log`·checkpoints = **gitignore**(대용량/재생성 가능).
- `figures/` = conflict map 등 출력 figure.
