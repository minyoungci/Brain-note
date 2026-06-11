# EXP-F3 — few-shot: BrainIAC(768) vs morphometry(30)

낮은 train N에서 BrainIAC이 이기면 few-shot이 use-case. 평균 over 5 reps.

## CN/AD (KDRC, AUC↑) — train N (subjects) sweep
| train_n | BrainIAC | morphometry |
|---|--:|--:|
| 20 | 0.671 | 0.878 |
| 40 | 0.704 | 0.874 |
| 80 | 0.693 | 0.872 |
| 372 | 0.744 | 0.909 |

## brain-age (clean, MAE↓) — train N sweep
| train_n | BrainIAC | morphometry |
|---|--:|--:|
| 50 | 6.98 | 6.20 |
| 150 | 6.59 | 5.77 |
| 400 | 6.23 | 5.54 |
| 1240 | 5.69 | 5.44 |

## 판정