# Downstream 7-task 오버나잇 결과 (2026-06-25 13:17)

## seg (Task2,4) — seg_v2 finetune Δ-over-scratch (yucca 1mm, 증강+Tversky+fg+SW+NSD)
### Task4 trigeminal
- pretrained: [seg_v2] task4_trigeminal pretrained (n=40): Dice=0.413 CI[0.381,0.443] | NSD=0.786 CI[0.748,0.822]
- scratch   : [seg_v2] task4_trigeminal scratch (n=40): Dice=0.164 CI[0.132,0.197] | NSD=0.344 CI[0.286,0.399]
### Task2 meningioma(flair)
- pretrained: [seg_v2] task2_meningioma pretrained (n=23): Dice=0.127 CI[0.056,0.214] | NSD=0.155 CI[0.073,0.256]
- scratch   : [seg_v2] task2_meningioma scratch (n=23): Dice=0.107 CI[0.039,0.184] | NSD=0.121 CI[0.049,0.212]

## cls/reg (Task1,3,5) — finetune Δ-over-scratch (yucca 128³)
### task1
-   task1_infarct AUROC: pretrained 0.942 [0.818,1.000] | scratch 0.596 [0.345,0.836] | Δ +0.346
### task3
-   task3_brainage pearson: pretrained 0.947 [0.937,0.955] | scratch 0.910 [0.891,0.927] | Δ +0.037
### task5
-   task5_polymicro AUROC: pretrained 0.986 [0.952,1.000] | scratch 0.997 [0.983,1.000] | Δ -0.010

## Task6 linear probe (frozen, 표현품질, =Task1 데이터)
- task1_infarct      cls    21 4         AUROC    0.817  [0.588,1.000]        | AUROC 0.721

## Task7 fairness
- Task7 fairness: 그룹/인구통계 라벨 로컬 부재. 챌린지 규약상 Task7=embedding 컨테이너 제출→주최측이 그룹별 OvR AUROC/F1 평가. 내부 단독 산출 불가(그룹 메타 필요). Task6 embedding이 동일 표현.
