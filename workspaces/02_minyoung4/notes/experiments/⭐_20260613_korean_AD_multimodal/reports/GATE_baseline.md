# GATE — clinical+blood baseline vs imaging ΔAUC (tri-modal AJU+KDRC, n=1836)

leakage-safe 5-fold subject-CV. ΔAUC = block 추가 시 증가분.

## Target 1: amyloid positivity (n_pos/neg = 678/789) — PET 제외(순환)
| block | AUC | ΔAUC |
|---|--:|--:|
| clinical | 0.595 |  |
| +APOE | 0.747 | +0.152 |
| +vascular+meta | 0.757 | +0.010 |
| +morphometry(T1) | 0.792 | +0.035 |
| +WMH(FLAIR) | 0.793 | +0.001 |

## Target 2: CN vs AD (n = 297/426) — MMSE 제외(순환), PET 허용
| block | AUC | ΔAUC |
|---|--:|--:|
| clinical | 0.652 |  |
| +APOE | 0.822 | +0.170 |
| +vascular+meta | 0.905 | +0.084 |
| +morphometry(T1) | 0.943 | +0.037 |
| +WMH(FLAIR) | 0.943 | +0.000 |
| +amyloid(PET) | 0.946 | +0.003 |

## 판정 (정직)
- imaging 블록(morphometry/WMH/PET)의 ΔAUC가 clinical+blood 위로 *유의*하면 headroom 존재 → 주제 viable.
- 미미하면 clinical-ceiling 재확인 → 그 타깃은 imaging-method로 가치 없음.