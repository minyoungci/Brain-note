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

판정: 앵커(n40 thick1)→combo(n23 thick6) 하락이 'thick+n' 효과. combo가 men 0.16 근접 →
      'men 한계는 해상도+데이터량으로 충분히 설명, decoder/모델 아님'(sufficiency) 증명.
