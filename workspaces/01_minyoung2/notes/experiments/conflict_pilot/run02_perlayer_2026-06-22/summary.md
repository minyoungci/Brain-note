# run02 per-layer conflict map — 결과 & 판정 (2026-06-22, 진짜 GATE)

config: `config.json` · raw: `metrics.jsonl`·`perlayer.jsonl`(per-layer cos source) · log: `run.log`

## CONFLICT MAP (per-layer cos, n=150 측정)
| layer | mean_cos | cos<0% | mean_mag (\|∇dense\|/\|∇global\|) |
|---|---|---|---|
| patch_embed | +0.010 | 49% | **1.38** |
| embed | +0.005 | 47% | **1.42** |
| L00 | +0.015 | 43% | 0.74 |
| L01 | +0.020 | 37% | 0.39 |
| L02 | +0.010 | 45% | 0.25 |
| L03 | +0.012 | 41% | 0.20 |
| L04 | +0.010 | 42% | 0.19 |
| L05 | +0.012 | 37% | 0.16 |
| L06 | +0.011 | 40% | 0.18 |
| L07 | +0.013 | 37% | 0.18 |
| norm_final | +0.002 | 51% | 0.25 |
| **AGGREGATE** | +0.009 | 47% | — |

## 판정
- 🔴 **cosine 충돌 가설 falsify(이 regime)**: 전 layer 평평(mean_cos +0.002~+0.020, 강충돌 layer 0). run01의 "국소충돌 평균상쇄" 가설 반증. **conflict map = flat → cosine 동기 figure 없음.**
- 🟢 **magnitude 불균형은 강하고 깊이-구조적**: `|∇dense|/|∇global|` 입력 ~1.4 → 깊은 블록 ~0.16(global ~5.5× 우세), L00→L07 단조감소. dense=얕은층·global=깊은층 지배. → PCGrad(cosine) 아니라 **GradNorm/uncertainty(magnitude)** 메커니즘.

## 함의
메커니즘이 cosine-충돌 → **magnitude 불균형(깊이 구조)**으로 이동. 단 magnitude 불균형은 GradNorm 표준동기 → "incremental" 위험(깊이구조/brain특이성으로 차별화 필요).

## ⚠️ 캐비엇
ViT-S·3000step·DINO-lite·초기학습 = 작은 proxy. **cosine 충돌은 후반/대규모서 창발 가능** → "충돌 없음"이 아니라 "초기 regime서 없음". 대규모/장기 재확인 전엔 cosine 완전 사망 단정 금지.

## 다음 결정 (방향 fork — [[../README]])
(A) 장기/대규모 재확인(창발 여부) / (B) magnitude-불균형으로 메커니즘 pivot / (C) seg-decoder transfer thesis로 pivot.
