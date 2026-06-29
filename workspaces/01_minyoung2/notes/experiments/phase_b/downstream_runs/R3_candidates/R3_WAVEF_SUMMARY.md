# R3 Wave-F (men anisotropic-aware) 06-29 02:06
⚠️ C2: spacing이 달라 절대 Dice/NSD를 Wave-C 1mm-iso(0.159/0.137)와 직접비교 불가
   (NSD는 mm단위→z5mm서 체계적으로 더 엄격, Dice도 z거칠어 비교 왜곡). 유효신호=같은-grid Δ-over-scratch(F2vs F3, F1 vs F4)뿐.
참고(절대값, 비교 불가): Wave-C 1mm-iso β0.8 EMA = Dice 0.159 / NSD 0.137
실측: native z=6.5mm(23명 전원 axis2), 1mm-iso는 label 3047→12867 부풀림(가짜 경계)
- F1 z=3mm crop128,128,48        :   Dice=0.148 CI[0.055,0.257] | NSD=0.145 CI[0.061,0.247]
- F2 z=5mm crop128,128,32(~native):   Dice=0.098 CI[0.038,0.171] | NSD=0.102 CI[0.044,0.170]
- F3 z=5mm scratch(Δ)            :   Dice=0.116 CI[0.044,0.195] | NSD=0.130 CI[0.061,0.220]
- F4 z=3mm scratch(Δ)            :   Dice=0.070 CI[0.023,0.126] | NSD=0.069 CI[0.029,0.118]
