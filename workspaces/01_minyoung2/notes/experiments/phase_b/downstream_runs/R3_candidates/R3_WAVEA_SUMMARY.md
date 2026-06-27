# R3 ablation Wave-A (06-27 10:56) — 저비용 후보(pretrained), TTA/boundary 없음
기준 R1(pretrained): trig Dice 0.413/NSD 0.786 | men(flair) 0.127
- trig EMA+LLRD(tversky)   :   Dice=0.361 CI[0.326,0.395] | NSD=0.687 CI[0.639,0.733]
- trig EMA+LLRD+dicefocal  :   Dice=0.293 CI[0.265,0.320] | NSD=0.566 CI[0.524,0.613]
- men  EMA+LLRD(tversky)   :   Dice=0.125 CI[0.048,0.217] | NSD=0.147 CI[0.065,0.244]
