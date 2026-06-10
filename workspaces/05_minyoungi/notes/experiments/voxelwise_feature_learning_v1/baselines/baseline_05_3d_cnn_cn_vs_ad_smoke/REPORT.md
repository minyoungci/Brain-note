# Baseline 05 — image-only 3D CNN CN vs AD

## Question
final_tensor T1w image-only 3D CNN이 CN vs AD subject-disjoint split에서 안정적으로 학습되는가?

## Result
- best epoch: 14
- ROC-AUC: **0.8906**
- balanced accuracy: **0.8314**
- accuracy: **0.8788**
- AP(AD): **0.7508**
- confusion matrix [CN, AD]: `[[1068, 112], [62, 194]]`

## Input policy
Image-only final_tensor T1w. ROI features/masks/cohort/scanner/age/sex were not model inputs.
