# R3 Wave-C (meningioma 검출 개선) 06-28 08:16
기준: R1 men(flair) Dice 0.127 | 진단 median 1205vox·편차1500배·n23
- C1 β0.8(고recall)+EMA  :   Dice=0.159 CI[0.075,0.256] | NSD=0.174 CI[0.089,0.275]
- C2 β0.8+pos4(fg오버샘플):   Dice=0.141 CI[0.068,0.225] | NSD=0.164 CI[0.082,0.263]
- C3 clDice+EMA          :   Dice=0.097 CI[0.042,0.157] | NSD=0.115 CI[0.047,0.220]
