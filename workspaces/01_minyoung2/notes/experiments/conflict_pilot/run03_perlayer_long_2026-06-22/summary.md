# run03 per-layer LONG (30k step) — 창발 판정 (2026-06-22)

config: `config.json` (steps 3000→30000 10×, subset 2000→4000) · raw gitignore · `perlayer.jsonl` 커밋

## 목적
run02 평평이 "ViT-S·3000step 초기 proxy" 탓인지 검증 — cosine 충돌이 학습 후반/장기서 *창발*하는가?

## CONFLICT MAP (per-layer cos, n=600)
| layer | mean_cos | cos<0% | mean_mag (\|∇dense\|/\|∇global\|) |
|---|---|---|---|
| patch_embed | +0.013 | 47% | 0.80 |
| embed | +0.002 | 47% | 0.84 |
| L00→L07 | +0.002~+0.006 | 42~49% | 0.38 → 0.05 |
| norm_final | −0.004 | 52% | 0.07 |
| **AGGREGATE** | +0.007 | 47% | — |

## 창발 궤적 (초기 1/3 vs 후반 1/3)
- aggregate cos: 초기 mean +0.009 (cos<0 **52%**) → 후반 +0.011 (cos<0 **42%**). **증가 없음 — 오히려 약간 더 정렬.**
- L05~L07: 초기 ~+0.004(45~50%neg) → 후반 ~+0.002(44~46%neg). **평평 유지.**

## 판정 — cosine 충돌 가설 **결정적 기각**
10× 장기에도 평평(상승 추세 없음, 후반 더 정렬). 2 독립 regime + 창발 부재 → cosine(PCGrad)식 충돌은 thesis 근거 불가.

## 살아남은 신호 — magnitude 불균형(robust)
`|∇dense|/|∇global|` 입력 ~0.8 → 깊은층 0.05~0.07 (깊은 블록서 global이 dense를 15~20× 압도). dense=얕은층·global=깊은층, run02→03 일관·심화.

## 잔여 캐비엇
ViT-S·subset4000·DINO-lite. ViT-L 대규모서 다를 가능성 0은 아니나 평평 궤적상 "규모만으로 창발"은 저확률. → cosine 추격 종료, B(magnitude) vs C(seg-decoder) 결정.
