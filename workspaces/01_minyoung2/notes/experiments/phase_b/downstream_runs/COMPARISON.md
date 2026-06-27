# Downstream seg 개선 비교분석 (R1→R2→R3) — 진행 중

> 목표: 최고 seg 결과까지 후보 실험 반복. ckpt=wg0.5. 측정=k-fold subject-disjoint·3seed·CI, pre vs scratch.
> 매 라운드 code-auditor 검증(critical 버그 다수 적발·수정). 결과→인사이트→다음 반영.

## Trigeminal (Task4, n=40) — DSC / NSD
| 라운드 | 설정 | Dice | NSD | vs R1 |
|---|---|---|---|---|
| R1 | tversky+bce, full-FT, 1mm (eval=realistic SW) | 0.413 | 0.786 | (기준) |
| R2 | **0.5mm** | **0.000** | 0.000 | 🔴 실패(64mm FOV·볼륨8×) |
| R3-A | EMA+LLRD (tversky) | 0.361 | 0.687 | 🔻 −0.052 |
| R3-A | EMA+LLRD+dicefocal | 0.293 | 0.566 | 🔻 −0.120 |
| **R3-A** | **EMA+LLRD+dicecldice** | **0.445** | **0.804** | ✅ **+0.032/+0.018** |
| R3-B | clean clDice (no EMA/LLRD) | 🔄 | 🔄 | (핸디캡 제거→더↑ 기대) |
| R3-B | clDice+boundary | 🔄 | 🔄 | (NSD push) |

## Meningioma (Task2, n=23) — DSC
| 라운드 | 설정 | Dice | vs R1 |
|---|---|---|---|
| R1 | tversky+bce, flair 단일, 1mm | 0.127 | (기준) |
| R2 | 멀티모달 mean-fusion | 0.054 | 🔴 −0.073(flair 희석) |
| R3-A | EMA+LLRD (flair) | 0.125 | ≈ 동일 |
| (다음) | 검출형 레버(CarveMix·고recall Tversky) 필요 | — | men 정체 0.13 |

## cls/reg (R3 대상 아님 — 이미 강함/포화)
| Task | finetune | Δ-over-scratch |
|---|---|---|
| brainage (n494) | r 0.947 | +0.037 (데이터충분→scratch 근접) |
| infarct (n21) | AUROC 0.942 | +0.346 (few-shot=foundation 강함) |
| polymicro (n48) | 0.986 | confound (scratch도 천장) |

## 핵심 인사이트 (누적)
1. **clDice(연결성)=trigeminal 승리 레버** (thin tubular). audit가 silent no-op 버그 고쳐 살림.
2. **EMA·LLRD·dicefocal·0.5mm·멀티모달mean = small-n seg서 해롭거나 무효** → R1/단순 레시피가 강함.
3. **foundation 가치 = scratch 실패하는 곳**(few-shot cls infarct·미세구조 seg trigeminal).
4. **meningioma=검출 실패형**(0.13 정체) — 일반 레시피로 안 움직임, 검출 특화 레버 필요.
