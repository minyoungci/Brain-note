# R3 Wave-I (controlled ablation, men 레시피 tversky β0.8 EMA 고정) 06-29 11:24
질문: men 0.159 천장=thick-slice+n23 때문(모델/decoder 아님)? trig를 men 조건으로 변환.
⚠️ 모든 run 동일 레시피(C2). 앵커=n40·thick1(C3). 해석=sufficiency(모달 t2w≠flair·병변형 confound 남음).
재현 타겟: men flair thick-slice n23 = Dice 0.159
## learning curve (n 효과, isotropic thick1)
- n10 :   Dice=0.280 CI[0.229,0.334] | NSD=0.572 CI[0.478,0.673]
- n15 :   Dice=0.356 CI[0.299,0.415] | NSD=0.668 CI[0.601,0.741]
- n20 :   Dice=0.292 CI[0.231,0.352] | NSD=0.584 CI[0.482,0.678]
- n23 :   Dice=0.344 CI[0.300,0.387] | NSD=0.703 CI[0.647,0.760]
- n30 :   Dice=0.351 CI[0.308,0.392] | NSD=0.684 CI[0.625,0.743]
- n40 (앵커=isotropic full) :   Dice=0.395 CI[0.361,0.427] | NSD=0.761 CI[0.721,0.802]
## 해상도 효과 (full n40)
- thick6 (z 6mm 모사) :   Dice=0.432 CI[0.402,0.460] | NSD=0.765 CI[0.737,0.790]
## combo = men 조건 (n23 + thick6)
- combo :   Dice=0.379 CI[0.346,0.412] | NSD=0.728 CI[0.692,0.763]

판정 (2026-06-30 정정 — 자기생성 결론 과장 적발):
  ⚠️ 원 결론("combo가 men 0.16 근접 → sufficiency 증명")은 숫자가 뒷받침하지 않음.
  - combo(n23+thick6) = Dice 0.379 vs 실제 men 0.159 → 2.4배 격차, '근접' 아님.
  - thick6(0.432)은 앵커(0.395)보다 오히려 ↑ — thick-slice 단독이 trig를 망가뜨리지 않음(반대 방향).
  - thick+n 합산 효과는 0.395→0.379(−0.016)뿐. 0.379→0.159의 잔여 격차(~0.22)는 설명 안 됨.
  결론(정정): men 한계는 해상도+데이터량만으로 '충분히 설명되지 않음'. 잔여 격차의 주원인은
  C2/anchor caveat가 명시한 **병변형(extra-axial blob, median 1205vox·편차 1500배)·모달(flair≠t2w)·
  single-modality few-shot 복합**. 방향성("decoder/모델 결함 아님")은 유지되나 sufficiency는 미증명.
  → men 추가 개선엔 멀티모달 learned-fusion 필요(R3 종료 인사이트와 일치).
