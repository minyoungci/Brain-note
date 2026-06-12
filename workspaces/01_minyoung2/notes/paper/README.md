# Paper artifacts — authoritative = PAPER.md

- **PAPER.md** ← 전 섹션 최종 draft (감사·리뷰·재측정 반영, inductive, 수치 json 검증 완료). **이게 기준.**
- ABSTRACT.md / RESULTS.md ← 이전 버전(참고용, 일부 수치는 PAPER.md로 대체됨).
- results/*.json ← 최종 inductive 수치(감사 통과).

## 핵심 최종 결과 (PAPER.md Table 2, inductive, 5-seed)
| | AJU | KDRC | ADNI |
|---|--:|--:|--:|
| RT-SSL (ours) | 0.471 | 0.378 | 0.492 |
| whole-volume SSL (matched head) | 0.390 | 0.305 | 0.424 |
| Models-Genesis SSL | 0.417 | 0.359 | 0.440 |
| Swin-UNETR SSL | 0.366 | 0.248 | 0.417 |
| hand-crafted ROI | 0.433 | 0.394 | 0.482 |

- RT-SSL >> 모든 학습 SSL(+0.05~0.13, 유의). vs hand-crafted: tie(CI 0 포함), complementarity 없음.
- positional: KDRC/ADNI만(+0.04~0.05), AJU 효과없음.
