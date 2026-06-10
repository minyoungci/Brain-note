# 03 — N4-variant Harmonization 비교 (결과)

_생성: 2026-06-04. 캐시된 image-appearance 특징만 사용(이미지 재읽기 없음). 스크립트 `n4_variant_comparison.py`._
_지표: 7-way consortium balanced_acc(chance 0.143), subject-grouped GroupShuffleSplit(8), RandomForest. **낮을수록 harmonized**._

## 결과

**Panel A — 공통 세션(N=700), 6변형 동일 세션 비교**

| 변형 | site balanced_acc |
|---|---|
| original | 0.505 |
| **n4prod (전수 N4)** | **0.423** ← 최저(최선) |
| n4_sample | 0.438 |
| blur | 0.442 |
| whitestripe | 0.473 |
| nyul | 0.490 |

**Panel B — full N=2800 (original/n4prod/blur만 보유)**

| 변형 | site balanced_acc |
|---|---|
| original | 0.556 |
| **n4prod** | **0.517** ← 최선 |
| blur | 0.554 (거의 무이득) |

## 결론
- **N4(production)가 image-level harmonization 중 site appearance shortcut을 가장 많이 줄인다** (두 패널 모두 최저).
- WhiteStripe·Nyúl은 N4보다 덜 줄이고, **blur는 full 데이터에서 거의 무이득**(0.556→0.554).
- 단, N4의 절대 감소폭은 작다(0.556→0.517, full). 이미지 후처리의 천장 — 잔여 site는 텍스처·해상도·모집단(02·01 RESULTS 참조).
- 이전 결론("N4 채택, WS/Nyúl/blur 기각", `research_notes/daily/2026-06-02.md`)을 동일 캐시로 정량 재확인.

## 한계 (독립검증에서 드러난 중요한 뉘앙스)
- **N4의 site 감소는 probe(분류기) 의존적이다.** 독립검증(`verify_n4_variant.py`):
  - RandomForest(비선형): original 0.556 → n4prod **0.517** (N4가 줄임)
  - LogisticRegression(선형): original 0.490 → n4prod **0.517** (N4가 오히려 약간 늘림)
  → 즉 **N4는 비선형 site 신호만 줄이고 선형 분리도는 안 줄인다.** "N4가 최선"이라는 순위는 RF 기준이며, image-level harmonization의 순이득은 작고 견고하지 않다. (전체 결론 "이미지 후처리만으로 site 못 지움"을 오히려 강화.)
- Panel A 절대값(0.42~0.50)이 Panel B(0.52~0.56)보다 낮은 건 N(700 vs 2800) 차이로 인한 probe 분산 — **패널 내 상대 순위**가 결론. WS/Nyúl는 700 표본만 존재해 full 비교 불가.

## 산출물
- `out/n4_variant_results.json`, `out/fig_variant_comparison.png`
