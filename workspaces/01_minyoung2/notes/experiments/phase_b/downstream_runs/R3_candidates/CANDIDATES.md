# R3 finetuning 개선 후보 (literature-scout 2026-06-26, 근거 기반)

## 진단 (약점별 다른 처방)
- **meningioma Dice 0.13 = 검출/recall 실패** (병변 놓침) → Tversky β>α·fg오버샘플·CarveMix·과적합제어. boundary/TTA 무효(없는 걸 평균 못함).
- **trigeminal 0.41/NSD 0.79 = 연결성(thin tubular)** → clDice/cbDice + boundary loss.
- **NSD=표면지표** → boundary-family(Hausdorff/boundary) loss가 NSD 직접 최적화. region(Dice/Tversky)=DSC.
- **n=23~48 full-finetune = catastrophic forgetting 위험** → LLRD·gradual-unfreeze·weight-soup.

## Top 5 (impact×저비용, 약점 우선)
1. **compound loss 재설계** [High,Low]: trigeminal=DiceFocal/DiceTopK + boundary(warmup λ 0→0.5); meningioma=Tversky β0.7(or FocalTversky γ4/3) recall. NSD엔 boundary항 필수. (Loss Odyssey MedIA'21·Boundary loss MedIA'21·Hausdorff TMI'20)
2. **weight-EMA / greedy model-soup** [High,Low]: 가중치 EMA(decay 0.999) + fold soup. 추론 무료, small-n robust 전 task. (SWA UAI'18·Model Soups ICML'22)
3. **clDice/cbDice (trigeminal 전용)** [High,Med]: soft-clDice aux(λ0.3~0.5). 연결성·NSD. blob(meningioma)엔 무효. (clDice CVPR'21·cbDice MICCAI'24)
4. **LLRD 0.75 + decoder-first unfreeze** [Med-High,Low]: head/dec base_lr, encoder lr×0.75^depth. frozen backbone 보호. (BEiT ICLR'22·ULMFiT ACL'18)
5. **TTA flips + overlap 0.5** [Med,Low]: 3축 flip ×8 + Gaussian overlap. 검출된 구조 DSC/NSD↑. 120초 예산 체크(weight-soup이 무료 대안). (TTA Neurocomputing'19·nnU-Net Nature Methods'21)

## 보조
- nnU-Net recipe(deep supervision·fg oversample 33%) / CarveMix(meningioma blob 증강 MICCAI'21) / PEFT(SSF/BitFit, CNN-seg 미검증 [VERIFY]).

## 120초 예산 주의
flip-TTA×8·overlap0.5×2·5fold = ~80×. weight-soup(단일모델)+1~2축 flip이 ensemble급 무료 win. 단일 pass 시간 H100서 측정 필수.

## 실험 매핑 (R3)
- trigeminal: DiceFocal+clDice+(boundary) + LLRD + weight-EMA + TTA, @0.5mm
- meningioma: Tversky(β0.7)+ fg오버샘플강화 + LLRD + weight-EMA, 멀티모달 @1mm
- 공통: weight-EMA·LLRD부터(저비용 robust), 그 위에 loss·clDice 추가 ablation.
출처: nnU-Net(Nature Methods'21), clDice(CVPR'21), cbDice(MICCAI'24), Boundary loss(MedIA'21), Focal Tversky(ISBI'19), Loss Odyssey(MedIA'21), SWA(UAI'18), Model Soups(ICML'22), CarveMix(MICCAI'21), PEFT(MIDL'24).
