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
| **R3-A** | **EMA+LLRD+dicecldice** | **0.445** | **0.804** | ✅ **best (+0.032/+0.018)** |
| R3-B | clean clDice (no EMA/LLRD) | 0.434 | 0.792 | +0.021 (EMA가 미세 도움) |
| R3-B | clean clDice **scratch** | 0.409 | 0.773 | — (Δ-over-scratch=+0.025, CI겹침) |
| R3-B | clDice+boundary | 중단 | — | Hausdorff DT CPU 극저속(18h 미완)→중단, 비용≫효과 |

**trigeminal 최종 = clDice+EMA+LLRD: Dice 0.445 / NSD 0.804** (R1 0.413/0.786 대비 +0.032/+0.018). clDice가 thin-tubular 연결성 학습으로 승. 단 Δ-over-scratch +0.025(CI겹침)=clDice는 pre·scratch 둘 다 올리는 *레시피 개선*이지 foundation 우월성 확대 아님.

## Meningioma (Task2, n=23) — DSC
| 라운드 | 설정 | Dice | vs R1 |
|---|---|---|---|
| R1 | tversky+bce(β0.7), flair 단일, 1mm | 0.127 | (기준) |
| R2 | 멀티모달 mean-fusion | 0.054 | 🔴 −0.073(flair 희석) |
| R3-A | EMA+LLRD (flair) | 0.125 | ≈ 동일 |
| **R3-C** | **고recall β0.8 + EMA** | **0.159** | ✅ **best +0.032** |
| R3-C | β0.8 + pos4(fg오버샘플) + EMA | 0.141 | +0.014(과샘플은 덜) |
| R3-C | clDice + EMA | 0.097 | 🔻 −0.030(clDice는 tubular전용, blob 부적합) |

**meningioma 최종 = 고recall Tversky β0.8 + EMA: Dice 0.159** (R1 0.127 +25%). 진단(median 1205vox·검출누락 병목)→FN페널티↑가 해결. 절대값은 여전히 낮음(n23 few-shot·단일flair 구조적 한계). 진단: men은 "미세"가 아니라 "편차1500배·few-shot·단일모달"이 한계 — 추가 상승엔 멀티모달 learned-fusion 필요(큰 작업).

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

## 🔬 meningioma 낮음 원인 규명 (2026-06-28, literature-scout + 라벨실측)
- **구조 결함 아님**: pretrained 0.127 ≥ scratch 0.107 (사전학습이 도움). 같은 foundation이 trig선 0.413(scratch 0.164의 2.5배) = 구조는 seg 표현 학습됨.
- **라벨 실측**: Task2 라벨이 **FLAIR-hyperintense**(label/brain 중앙값비 4.47, 전부>1.2) = 종양이 FLAIR서 뚜렷이 밝음 → **정보는 FLAIR에 있음**(T1ce 없어도 보임).
- **literature 대조**: FLAIR-hyperintensity meningioma seg는 n수백서 Dice 0.89 보고(arXiv2512.17566 [VERIFY]); T1ce 단일도 0.76~0.90. BraTS-MEN 4모달 0.87~0.90(상한). few-shot n≤30 meningioma 선례 부재.
- **판정**: 0.16은 데이터 한계 아니라 **레시피 문제**(정보 보이는데 못 뽑음). 적신호=finetune−scratch +0.05(전이 미미). 용의자: ①1500배 크기편차(global Tversky 부적합→size-stratified) ②crop128 큰종양 미수용 ③학습동역학. 단 n23 few-shot이라 0.89 도달 불가, 현실 목표 0.3~0.5.
- **다음=Wave-D**: size-aware sampling/loss + crop 조정으로 men 재시도. trig 교훈(구조특화)대로 men=blob·대편차 특화.

## Wave-D (men 멀티모달 learned-fusion + size-aware, 2026-06-28)
| 방법 | Dice | 결론 |
|---|---|---|
| R2 멀티모달 mean | 0.054 | mean 희석(실패) |
| Wave-D learned-fusion+β0.8 | 0.121 | mean보다↑(0.05→0.12)나 단일 flair 못넘음 |
| Wave-D learned-fusion+gdice | 0.129 | 〃 |
| Wave-D learned scratch | 0.084 | Δ+0.037(여전히 작음) |
| **Wave-C flair단일 β0.8 (best)** | **0.159** | 멀티모달 불필요, flair에 정보 집중 |
- **인사이트**: ①learned-fusion≫mean(mean-init 수정 효과)이나 단일 flair 못넘음=멀티모달이 men 안 올림(dwi/t2s 노이즈). ②**Δ-over-scratch 멀티모달서도 +0.037=작음** → 병목은 모달리티 아니라 **학습방식(full-FT가 foundation prior 못살림)**. VISTA3D Δ+0.61 대비 비정상. → **Wave-E=encoder frozen/low-LR(자료 핵심)이 진짜 레버**(Wave-D가 역으로 입증).

## Wave-E (encoder 보존 frozen/lowlr — VISTA3D식, 2026-06-28)
### trigeminal (tubular/anatomy)
| 방법 | Dice | scratch | Δ-over-scratch |
|---|---|---|---|
| full-FT clDice (Wave-C) | 0.445 | 0.41 | +0.03 |
| frozen | 0.442 | 0.308 | +0.134 |
| **lowlr (best)** | **0.450** | 0.308 | **+0.142** |
### meningioma (lesion/blob)
| 방법 | Dice | scratch | Δ |
|---|---|---|---|
| **full-FT β0.8 (Wave-C best)** | **0.159** | 0.107 | +0.05 |
| frozen | 0.086 | 0.076 | +0.01 |
| lowlr | 0.078 | — | — |
- **결정적 인사이트**: ①trig — 절대성능 0.445→0.450 미세, **그러나 Δ-over-scratch +0.03→+0.14(4배↑)**. full-FT에선 scratch도 encoder 학습해 따라와 "foundation 무용"처럼 보였으나(아티팩트), **frozen하면 scratch=0.308 갇힘 → 우리 foundation prior가 0.13 가치를 함**(VISTA3D Δ+0.61 패턴 확인). ②men — frozen 실패(0.159→0.086), Δ소멸 → foundation prior 무관, lesion-detection은 full-FT 고recall이 답. ③**task-adaptive 처방 확정**: tubular/anatomy=frozen/lowlr, lesion=full-FT. (자료의 "task별 protocol 최적화" 일치.)
- **최종 seg best**: trig=lowlr clDice EMA 0.450/NSD 0.796 | men=full-FT β0.8 EMA 0.159/NSD 0.137

## Wave-F (men anisotropic-aware 전처리, 2026-06-29)
⚠️ C2: spacing 달라 절대값을 1mm-iso(0.159)와 직접비교 불가, 같은-grid Δ만 유효
| 방법 | Dice | scratch | Δ-over-scratch |
|---|---|---|---|
| z=3mm crop128,128,48 | 0.148 | 0.070 | **+0.078** (foundation 살아남음) |
| z=5mm crop128,128,32(~native) | 0.098 | 0.116 | **−0.018** (domain shift) |
- **결정적 인사이트**: z의 정도가 **domain shift**를 좌우. z=3(1mm-iso에 가까움)=foundation prior 살아 Δ+0.078, z=5(완전 native)=shift 커 pre<scratch(prior 죽음). **단 어느 쪽도 1mm-iso 0.159 못 넘음=anisotropic 순이득 없음.** 진단(native z=6.5mm, 1mm-iso가 label 3047→12867 가짜 upsampling)은 옳았으나, foundation이 1mm-iso로 pretrain돼 anisotropic은 domain shift→이득 상쇄. **교훈: 전처리는 pretraining과 정합해야(데이터 최적≠모델 정합).** men 최종 best=Wave-C 1mm-iso full-FT β0.8 EMA **0.159**(불변).

## Wave-G 검토 → 멈춤 (men 개선 루프 종료, 2026-06-29)
- **cascade 비추천 (literature-scout)**: n<30서 cascade가 single-stage 이긴 사례 없음. ①nnU-Net cascade=FOV용(우린 sliding-window 이미) ②BraTS-meningioma n1000도 single-stage 우승 ③유일 small-lesion cascade 성공=218환자/3605종양. FN 전파(final_recall≤stage1_recall) 수학적 보장 → 병목 상류 이동만. (단일 체크포인트 규칙은 "사전학습 체크포인트" 한정이라 cascade 자동위반 아님 — R1 과해석 정정.)
- **prompt token 무익**: 단일 클래스(meningioma)라 VISTA3D식 class prompt 정보 이득 없음.
- **frozen+adapter 충돌**: Wave-E서 men=full-FT 검증과 역방향.
- **blob loss(IPMI2023) = 향후 1순위 미시도 옵션**: instance-level loss로 크기편차1500배·검출병목 직격, drop-in·단일ckpt·추론0. 단 기대이득 작음(MS +5%F1) → 사용자 판단으로 보류.
- **men 최종 = Wave-C 1mm-iso full-FT Tversky β0.8 + EMA: Dice 0.159 / NSD 0.137** (확정). 천장=n23 few-shot+extra-axial+thick-slice 삼중고(데이터 한계).
