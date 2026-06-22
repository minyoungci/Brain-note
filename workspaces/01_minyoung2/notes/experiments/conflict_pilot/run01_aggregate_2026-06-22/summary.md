# run01 aggregate — 결과 & 해석 (2026-06-22)

config: `config.json` · raw: `metrics.jsonl`(gitignore) · compact: `cos_series.csv`(150행) · log: `run.log`(gitignore)

## 결과 (n=150 cos, step 0~2980)
| 지표 | 값 |
|---|---|
| cos(∇L_d,∇L_g) mean / median | **+0.017 / +0.018** (거의 0) |
| cos<0 비율 | **43%** (초기 1/3: 40% → 후기 1/3: 44%) |
| std | 0.108 |
| 강신호 \|cos\|>0.1 | 31% step (그 중 음수 43%) → **강충돌 cos<−0.1 ≈ 13% step** |
| L_dense | 1.02 → 0.55 (감소) |
| L_global | 8.22 → 5.70 (감소) |
| 건강 | collapse/NaN 없음, rankme 6~7 안정, teacher entropy 0.9→0.3(정상 sharpening) |

## 해석 (비판적 — 스크립트 자동판정 무비판 수용 금지)
- ✅ **충돌 실재·빈번**: 43% step에서 cos<0. gradient 일관 정렬 아님 → 관리할 tension 있음.
- ⚠️ **그러나 aggregate는 near-orthogonal(약함)**: mean≈0, 강충돌은 ~13%뿐. gradient가 대부분 직교면 고정-λ 가산이 *충돌 축*에서는 치명적이지 않을 수 있음.
- 🔴 **결정적 한계**: aggregate cos는 전 encoder param을 뭉뚱그림 → 재정의 thesis(**conflict map, layer/region별**)의 *진짜 검증 아님*. mean≈0 + std 0.108 + 43% 부호반전 = **국소 충돌이 평균 상쇄**된 전형. 잘못된 통계량을 봄.

## GATE 판정
**조건부 PASS** (pivot 아님, 확정도 아님). falsify 안 됨(43%·정상학습) → 진행 근거 있음. **진짜 GATE = per-layer cos + grad_mag_ratio (run02)**.

## 한계
ViT-S·2000subset·3000step·DINO-lite·초기학습·단일백본(ViT) = 방향 신호지 최종 아님.

## 부수 확인
**data_fraction 71% / GPU util 21% → I/O 바운드 실측 확정** (gpfs ~2GB/s 병목, B200 연산 아님).
